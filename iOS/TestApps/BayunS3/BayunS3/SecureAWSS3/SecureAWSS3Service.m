//
//  SecureAWSS3Sevice.m
//  
//
//  Created by Preeti-Gaur on 12/10/15.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAWSS3Service.h"
#import "AWSS3.h"
#import "AWSNetworking.h"
#import "AWSSignature.h"
#import "AWSService.h"
#import "AWSCategory.h"
#import "AWSNetworking.h"
#import "AWSURLRequestSerialization.h"
#import "AWSURLResponseSerialization.h"
#import "AWSURLRequestRetryHandler.h"
#import "AWSSynchronizedMutableDictionary.h"


static NSString *const AWSInfoS3 = @"S3";
NSString *const SecureAWSS3APIVersion = @"s3-2006-03-01";
NSString *const SecureAWSS3ServiceErrorDomain = @"com.bayun.SecureAWSS3ServiceErrorDomain";
NSUInteger const SecureAWSS3ServiceMinimumPartSize = 5 * 1024 * 1024; // 5MB
NSUInteger const SecureAWSS3ServiceByteLimitDefault = 5 * 1024 * 1024; // 5MB
NSTimeInterval const SecureAWSS3ServiceAgeLimitDefault = 0.0; // Keeps the data indefinitely unless it hits the size limit.

@interface AWSS3TransferManagerUploadRequest ()

@property (nonatomic, assign) AWSS3TransferManagerRequestState state;
@property (nonatomic, assign) NSUInteger currentUploadingPartNumber;
@property (nonatomic, strong) NSMutableArray *completedPartsArray;
@property (nonatomic, strong) NSString *uploadId;
@property (atomic, strong) AWSS3UploadPartRequest *currentUploadingPart;

@property (atomic, assign) int64_t totalSuccessfullySentPartsDataLength;
@end

@interface AWSS3TransferManagerDownloadRequest ()

@property (nonatomic, assign) AWSS3TransferManagerRequestState state;

@end

@interface AWSS3ResponseSerializer : AWSXMLResponseSerializer

@end

@interface AWSS3RequestRetryHandler : AWSURLRequestRetryHandler

@end

@interface AWSRequest()

@property (nonatomic, strong) AWSNetworkingRequest *internalRequest;

@end

@interface AWSS3()

@property (nonatomic, strong) AWSNetworking *networking;
@property (nonatomic, strong) AWSServiceConfiguration *configuration;

@end

@interface AWSServiceConfiguration()

@property (nonatomic, strong) AWSEndpoint *endpoint;

@end

@implementation SecureAWSS3

@synthesize configuration = _configuration;
@synthesize networking = _networking;



static AWSSynchronizedMutableDictionary *_serviceClients = nil;

+ (instancetype)defaultS3 {
    
    static SecureAWSS3 *_defaultS3 = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AWSServiceConfiguration *serviceConfiguration = nil;
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] defaultServiceInfo:AWSInfoS3];
        if (serviceInfo) {
            serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                               credentialsProvider:serviceInfo.cognitoCredentialsProvider];
        }
        
        if (!serviceConfiguration) {
            serviceConfiguration = [AWSServiceManager defaultServiceManager].defaultServiceConfiguration;
        }
        
        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }
        
        _defaultS3 = [[SecureAWSS3 alloc] initWithConfiguration:serviceConfiguration];
        _defaultS3.encryptionPolicy = BayunEncryptionPolicyDefault;
    });
    
    return _defaultS3;

}

+ (void)registerS3WithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [AWSSynchronizedMutableDictionary new];
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [_serviceClients setObject:[[SecureAWSS3 alloc] initWithConfiguration:configuration]
                        forKey:key];
#pragma clang diagnostic pop
}

+ (instancetype)S3ForKey:(NSString *)key {
    //return [_serviceClients objectForKey:key];
    @synchronized(self) {
        SecureAWSS3 *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }
        
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] serviceInfo:AWSInfoS3
                                                                     forKey:key];
        if (serviceInfo) {
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                                        credentialsProvider:serviceInfo.cognitoCredentialsProvider];
            [SecureAWSS3 registerS3WithConfiguration:serviceConfiguration
                                        forKey:key];
        }
        
        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeS3ForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultS3` or `+ S3ForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration {
    
    _configuration = [configuration copy];
    
    _configuration.endpoint = [[AWSEndpoint alloc] initWithRegion:_configuration.regionType
                                                          service:AWSServiceS3
                                                     useUnsafeURL:NO];
    
    AWSSignatureV4Signer *signer = [[AWSSignatureV4Signer alloc] initWithCredentialsProvider:_configuration.credentialsProvider
                                                                                    endpoint:_configuration.endpoint];
    AWSNetworkingRequestInterceptor *baseInterceptor = [[AWSNetworkingRequestInterceptor alloc] initWithUserAgent:_configuration.userAgent];
    _configuration.requestInterceptors = @[baseInterceptor, signer];
    
    _configuration.baseURL = _configuration.endpoint.URL;
    _configuration.retryHandler = [[AWSS3RequestRetryHandler alloc] initWithMaximumRetryCount:_configuration.maxRetryCount];
    
    _networking = [[AWSNetworking alloc] initWithConfiguration:_configuration];
    
    return self;
}


-(NSString *)urlStringWithBucketName:(NSString *)bucketName objectName:(NSString *)objectName subResource:(NSString *)subResource {
    if (!bucketName) return nil;
    NSString *keyPath;
    NSString *resQuery;
    
    keyPath  = (objectName == nil ? [NSString stringWithFormat:@"%@", bucketName] : [NSString stringWithFormat:@"%@/%@", bucketName, [objectName aws_stringWithURLEncoding]]);
    resQuery = (subResource == nil ? @"" : [NSString stringWithFormat:@"?%@", subResource]);
    
    return [NSString stringWithFormat:@"%@/%@%@", self.configuration.endpoint.URL, keyPath, resQuery];
}


#pragma mark - Service method

- (AWSTask *)getObject:(AWSS3GetObjectRequest *)request {
    return [[super getObject:request] continueWithBlock:^id(AWSTask *task) {
        __block AWSTask *taskNew = task;
        
        if (task.error) {
            return [AWSTask taskWithError:task.error];
        }
        
        if (task.result) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [[BayunCore sharedInstance] unlockFile:request.downloadingFileURL success:^{
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (errorCode == BayunErrorAccessDenied) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"User Authentication Failed", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorAccessDenied
                                                                     userInfo:userInfo]];
                } else if (errorCode == BayunErrorUserInActive) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"User Inactive", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorUserInactive
                                                                     userInfo:userInfo]];
                } else {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Something Went Wrong", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorSomethingWentWrong
                                                                     userInfo:userInfo]];
                }
                 dispatch_semaphore_signal(semaphore);
            }];
            //wait for BayunCore to unlock the file before returning the task
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (taskNew) {
                return taskNew;
            }
        }
        return task;
    }];
}

- (AWSTask *)putObject:(AWSS3PutObjectRequest *)request {
    __block AWSTask *task;
  
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[BayunCore sharedInstance] lockFile:request.body
                        encryptionPolicy:self.encryptionPolicy
                                 groupId:self.groupId
                                 success:^{
        NSError *error = nil;
        NSURL *url = request.body;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[url path] stringByResolvingSymlinksInPath]
                                                                                    error:&error];
        unsigned long long fileSize = [attributes fileSize];
        request.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
        //if file size is greater than 5MB convert the putObject request to AWSS3UploadPartRequest
        
        if (fileSize > SecureAWSS3ServiceMinimumPartSize) {
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = request.bucket;
            uploadRequest.key = request.key;
            uploadRequest.body = request.body;
            uploadRequest.internalRequest = request.internalRequest;
            
            task =  [self multipartUpload:uploadRequest fileSize:fileSize];
        } else {
            task =    [super putObject:request];
        }
        dispatch_semaphore_signal(semaphore);
    } failure:^(BayunError errorCode) {
        if (errorCode == BayunErrorAccessDenied) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"User Authentication Failed", nil)};
            task = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                              code:SecureAWSS3ServiceErrorAccessDenied
                                                          userInfo:userInfo]];
        } else if (errorCode == BayunErrorUserInActive) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"User Inactive", nil)};
            task = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                              code:SecureAWSS3ServiceErrorUserInactive
                                                          userInfo:userInfo]];
        } else {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Something Went Wrong", nil)};
            task = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                              code:SecureAWSS3ServiceErrorSomethingWentWrong
                                                          userInfo:userInfo]];
        }
         dispatch_semaphore_signal(semaphore);
    }];
    //wait for BayunCore to lock the file before returning the task
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return task;
}

- (AWSTask *)multipartUpload:(AWSS3TransferManagerUploadRequest *)uploadRequest
                   fileSize:(unsigned long long) fileSize{
    NSUInteger partCount = ceil((double)fileSize / SecureAWSS3ServiceMinimumPartSize);
    
    AWSTask *initRequest = nil;
    __weak SecureAWSS3 *weakSelf = self;
    
    //if it is a new request, Init multipart upload request
    if (uploadRequest.currentUploadingPartNumber == 0) {
        AWSS3CreateMultipartUploadRequest *createMultipartUploadRequest = [AWSS3CreateMultipartUploadRequest new];
        [createMultipartUploadRequest aws_copyPropertiesFromObject:uploadRequest];
        [createMultipartUploadRequest setValue:[AWSNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest
        initRequest = [weakSelf createMultipartUpload:createMultipartUploadRequest];
        [uploadRequest setValue:[NSMutableArray arrayWithCapacity:partCount] forKey:@"completedPartsArray"];
    } else {
        //if it is a paused request, skip initMultipart Upload request.
        initRequest = [AWSTask taskWithResult:nil];
    }
    
    AWSS3CompleteMultipartUploadRequest *completeMultipartUploadRequest = [AWSS3CompleteMultipartUploadRequest new];
    [completeMultipartUploadRequest aws_copyPropertiesFromObject:uploadRequest];
    [completeMultipartUploadRequest setValue:[AWSNetworkingRequest new] forKey:@"internalRequest"]; //recreate a new internalRequest
    
    AWSTask *uploadTask = [[[initRequest continueWithSuccessBlock:^id(AWSTask *task) {
        AWSS3CreateMultipartUploadOutput *output = task.result;
        
        if (output.uploadId) {
            completeMultipartUploadRequest.uploadId = output.uploadId;
            uploadRequest.uploadId = output.uploadId; //pass uploadId to the request for reference.
        } else {
            completeMultipartUploadRequest.uploadId = uploadRequest.uploadId;
        }
        
        AWSTask *uploadPartsTask = [AWSTask taskWithResult:nil];
        NSUInteger c = uploadRequest.currentUploadingPartNumber;
        if (c == 0) {
            c = 1;
        }
        
        __block int64_t multiplePartsTotalBytesSent = 0;
        
        for (NSUInteger i = c; i < partCount + 1; i++) {
            uploadPartsTask = [uploadPartsTask continueWithSuccessBlock:^id(AWSTask *task) {
                
                //Cancel this task if state is canceling
                if (uploadRequest.state == AWSS3TransferManagerRequestStateCanceling) {
                    //return a error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"S3 MultipartUpload has been cancelled.", nil)]};
                    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                      code:SecureAWSS3ServiceErrorCancelled
                                                                  userInfo:userInfo]];
                }
                //Pause this task if state is Paused
                if (uploadRequest.state == AWSS3TransferManagerRequestStatePaused) {
                    //return an error task
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"S3 MultipartUpload has been paused.", nil)]};
                    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                      code:SecureAWSS3ServiceErrorPaused
                                                                  userInfo:userInfo]];
                }
                
                NSUInteger dataLength = i == partCount ? (NSUInteger)fileSize - ((i - 1) * SecureAWSS3ServiceMinimumPartSize) : SecureAWSS3ServiceMinimumPartSize;
                
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[uploadRequest.body path]];
                [fileHandle seekToFileOffset:(i - 1) * SecureAWSS3ServiceMinimumPartSize];
                NSData *partData = [fileHandle readDataOfLength:dataLength];
                NSURL *tempURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]]];
                [partData writeToURL:tempURL atomically:YES];
                partData = nil;
                [fileHandle closeFile];
                
                AWSS3UploadPartRequest *uploadPartRequest = [AWSS3UploadPartRequest new];
                uploadPartRequest.bucket = uploadRequest.bucket;
                uploadPartRequest.key = uploadRequest.key;
                uploadPartRequest.partNumber = @(i);
                uploadPartRequest.body = tempURL;
                uploadPartRequest.contentLength = @(dataLength);
                uploadPartRequest.uploadId = output.uploadId?output.uploadId:uploadRequest.uploadId;
                
                uploadRequest.currentUploadingPart = uploadPartRequest; //retain the current uploading parts for cancel/pause purpose
                
                //reprocess the progressFeed received from s3 client
                uploadPartRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
                    
                    AWSNetworkingRequest *internalRequest = [uploadRequest valueForKey:@"internalRequest"];
                    if (internalRequest.uploadProgress) {
                        int64_t previousSentDataLengh = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                        if (multiplePartsTotalBytesSent == 0) {
                            multiplePartsTotalBytesSent += bytesSent;
                            multiplePartsTotalBytesSent += previousSentDataLengh;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        } else {
                            multiplePartsTotalBytesSent += bytesSent;
                            internalRequest.uploadProgress(bytesSent,multiplePartsTotalBytesSent,fileSize);
                        }
                    }
                };
                
                return [[[weakSelf uploadPart:uploadPartRequest] continueWithSuccessBlock:^id(AWSTask *task) {
                    AWSS3UploadPartOutput *partOuput = task.result;
                    
                    AWSS3CompletedPart *completedPart = [AWSS3CompletedPart new];
                    completedPart.partNumber = @(i);
                    completedPart.ETag = partOuput.ETag;
                    
                    NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];
                    
                    if (![completedParts containsObject:completedPart]) {
                        [completedParts addObject:completedPart];
                    }
                    
                    int64_t totalSentLenght = [[uploadRequest valueForKey:@"totalSuccessfullySentPartsDataLength"] longLongValue];
                    totalSentLenght += dataLength;
                    
                    [uploadRequest setValue:@(totalSentLenght) forKey:@"totalSuccessfullySentPartsDataLength"];
                    
                    //set currentUploadingPartNumber to i+1 to prevent it be downloaded again if pause happened right after parts finished.
                    uploadRequest.currentUploadingPartNumber = i + 1;
                    return nil;
                }] continueWithBlock:^id(AWSTask *task) {
                    NSError *error = nil;
                    [[NSFileManager defaultManager] removeItemAtURL:tempURL
                                                              error:&error];
                    if (error) {
                        NSLog(@"Failed to delete a temporary file for part upload: [%@]", error);
                    }
                    
                    if (task.error) {
                        return [AWSTask taskWithError:task.error];
                    } else {
                        return nil;
                    }
                }];
            }];
        }
        
        return uploadPartsTask;
    }] continueWithSuccessBlock:^id(AWSTask *task) {
        //If all parts upload succeed, send completeMultipartUpload request
        NSMutableArray *completedParts = [uploadRequest valueForKey:@"completedPartsArray"];
        if ([completedParts count] != partCount) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"completedParts count is not equal to totalPartCount. expect %lu but got %lu",(unsigned long)partCount,(unsigned long)[completedParts count]],@"completedParts":completedParts};
            return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                              code:SecureAWSS3ServiceErrorUnknown
                                                          userInfo:userInfo]];
        }
        
        AWSS3CompletedMultipartUpload *completedMultipartUpload = [AWSS3CompletedMultipartUpload new];
        completedMultipartUpload.parts = completedParts;
        completeMultipartUploadRequest.multipartUpload = completedMultipartUpload;
        
        return [weakSelf completeMultipartUpload:completeMultipartUploadRequest];
    }] continueWithBlock:^id(AWSTask *task) {
        
        if (uploadRequest.state == AWSS3TransferManagerRequestStateCanceling) {
            [weakSelf abortMultipartUploadsForRequest:uploadRequest];
        }
        
        if (task.error) {
            return [AWSTask taskWithError:task.error];
        }
        
        AWSS3TransferManagerUploadOutput *uploadOutput = [AWSS3TransferManagerUploadOutput new];
        if (task.result) {
            AWSS3CompleteMultipartUploadOutput *completeMultipartUploadOutput = task.result;
            [uploadOutput aws_copyPropertiesFromObject:completeMultipartUploadOutput];
        }
        
        return uploadOutput;
    }];
    
    return uploadTask;
}


- (void)abortMultipartUploadsForRequest:(AWSS3TransferManagerUploadRequest *)uploadRequest{
    AWSS3AbortMultipartUploadRequest *abortMultipartUploadRequest = [AWSS3AbortMultipartUploadRequest new];
    abortMultipartUploadRequest.bucket = uploadRequest.bucket;
    abortMultipartUploadRequest.key = uploadRequest.key;
    abortMultipartUploadRequest.uploadId = uploadRequest.uploadId;
    
    __weak SecureAWSS3 *weakSelf = self;
    
    [[weakSelf abortMultipartUpload:abortMultipartUploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Received response for abortMultipartUpload with Error:%@",task.error);
        } else {
            NSLog(@"Received response for abortMultipartUpload.");
        }
        return nil;
    }];
}


@end
