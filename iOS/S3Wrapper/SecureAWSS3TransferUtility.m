//
//  SecureAWSS3TransferUtility.m
//  BayunS3
//
//  Created by Preeti Gaur on 05/07/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAWSS3TransferUtility.h"
#import "AWSS3PreSignedURL.h"
#import "AWSSynchronizedMutableDictionary.h"

NSString *const SecureAWSS3TransferUtilityIdentifier = @"com.bayun.SecureAWSS3TransferUtility.Identifier";
NSTimeInterval const SecureAWSS3TransferUtilityTimeoutIntervalForResource = 50 * 60; // 50 minutes

NSString *const SecureAWSS3TransferUtilityUserAgent = @"secure-transfer-utility";
NSString *const SecureAWSS3TransferUtilityErrorDomain= @"com.bayun.SecureAWSS3TransferUtilityErrorDomain";
static NSString *const AWSInfoS3TransferUtility = @"S3TransferUtility";

#pragma mark - Private classes
@interface SecureAWSS3TransferUtility() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) AWSServiceConfiguration *configuration;
@property (strong, nonatomic) AWSS3PreSignedURLBuilder *preSignedURLBuilder;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *sessionIdentifier;
@property (strong, nonatomic) NSString *temporaryDirectoryPath;
@property (strong, nonatomic) AWSSynchronizedMutableDictionary *taskDictionary;
@property (copy, nonatomic) void (^backgroundURLSessionCompletionHandler)(void);

@end

@interface AWSS3PreSignedURLBuilder()

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

@end

#pragma mark - AWSS3TransferUtility

@implementation SecureAWSS3TransferUtility

static AWSSynchronizedMutableDictionary *_serviceClients = nil;
static SecureAWSS3TransferUtility *_defaultS3TransferUtility = nil;

#pragma mark - Initialization methods

+ (instancetype)defaultS3TransferUtility {    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AWSServiceConfiguration *serviceConfiguration = nil;
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] defaultServiceInfo:AWSInfoS3TransferUtility];
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
        
        
        
        
        _defaultS3TransferUtility = [[SecureAWSS3TransferUtility alloc] initWithConfiguration:serviceConfiguration
                                                                             identifier:nil];
        _defaultS3TransferUtility.encryptionPolicy = BayunEncryptionPolicyDefault;
    });
    
    return _defaultS3TransferUtility;
}

+ (void)registerS3TransferUtilityWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [AWSSynchronizedMutableDictionary new];
    });
    
    SecureAWSS3TransferUtility *s3TransferUtility = [[SecureAWSS3TransferUtility alloc] initWithConfiguration:configuration
                                                                                                   identifier:[NSString stringWithFormat:@"%@.%@", SecureAWSS3TransferUtilityIdentifier, key]];
    [_serviceClients setObject:s3TransferUtility
                        forKey:key];
}

+ (instancetype)S3TransferUtilityForKey:(NSString *)key {
   // return [_serviceClients objectForKey:key];
    @synchronized(self) {
        SecureAWSS3TransferUtility *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }
        
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] serviceInfo:AWSInfoS3TransferUtility
                                                                     forKey:key];
        if (serviceInfo) {
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                                        credentialsProvider:serviceInfo.cognitoCredentialsProvider];
            [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:serviceConfiguration
                                                                      forKey:key];
        }
        
        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeS3TransferUtilityForKey:(NSString *)key {
    //[_serviceClients removeObjectForKey:key];
    SecureAWSS3TransferUtility *transferUtility = [self S3TransferUtilityForKey:key];
    if (transferUtility) {
        [transferUtility.session invalidateAndCancel];
    }
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultS3TransferUtility` or `+ S3TransferUtilityForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)serviceconfiguration
                           identifier:(NSString *)identifier {

   
        self.configuration = [serviceconfiguration copy];
        [self.configuration  addUserAgentProductToken:SecureAWSS3TransferUtilityUserAgent];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _preSignedURLBuilder = [[AWSS3PreSignedURLBuilder alloc] initWithConfiguration:self.configuration ];
#pragma clang diagnostic pop
        
        if (identifier) {
            _sessionIdentifier = identifier;
        } else {
            _sessionIdentifier = SecureAWSS3TransferUtilityIdentifier;
        }
        
        NSURLSessionConfiguration *configuration =  nil;
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_sessionIdentifier];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:_sessionIdentifier];
#pragma clang diagnostic pop
        }
        
        configuration.timeoutIntervalForResource = SecureAWSS3TransferUtilityTimeoutIntervalForResource;
        _session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:nil];
        
        _taskDictionary = [AWSSynchronizedMutableDictionary new];
        
        // Creates a temporary directory for data uploads
        _temporaryDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[_sessionIdentifier aws_md5String]];
        NSURL *directoryURL = [NSURL fileURLWithPath:_temporaryDirectoryPath];
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&error];
        if (!result) {
            AWSLogError(@"Failed to create a temporary directory: %@", error);
        }
        
        // Clean up the temporary directory
        __weak SecureAWSS3TransferUtility *weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [weakSelf cleanUpTemporaryDirectory];
        });
    return self;
}

#pragma mark - Upload methods

- (AWSTask *)uploadData:(NSData *)data
                 bucket:(NSString *)bucket
                    key:(NSString *)key
            contentType:(NSString *)contentType
             expression:(AWSS3TransferUtilityUploadExpression *)expression
       completionHander:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    
    return [super uploadData:data
                      bucket:bucket
                         key:key
                 contentType:contentType
                  expression:expression
            completionHandler:completionHandler];
}

- (AWSTask *)uploadFile:(NSURL *)fileURL
                 bucket:(NSString *)bucket
                    key:(NSString *)key
            contentType:(NSString *)contentType
             expression:(AWSS3TransferUtilityUploadExpression *)expression
       completionHander:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    if (!expression) {
        expression = [AWSS3TransferUtilityUploadExpression new];
    }

    __block AWSTask *task;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[BayunCore sharedInstance] lockFile:fileURL
                        encryptionPolicy:self.encryptionPolicy
                                 groupId:self.groupId
                                 success:^{
        
        task = [super uploadFile:fileURL
                          bucket:bucket
                             key:key
                     contentType:contentType
                      expression:expression
                completionHandler:completionHandler];
        
        dispatch_semaphore_signal(semaphore);
    } failure:^(BayunError errorCode) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                            code:errorCode
                                                        userInfo:nil];
                AWSS3TransferUtilityUploadTask *task = [AWSS3TransferUtilityUploadTask new];
                completionHandler(task,error);
            });
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return task;
}

#pragma mark - Download methods

- (AWSTask *)downloadDataFromBucket:(NSString *)bucket
                                key:(NSString *)key
                         expression:(AWSS3TransferUtilityDownloadExpression *)expression
                   completionHander:(AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    
    
    return [super downloadDataFromBucket:bucket key:key expression:expression completionHandler:completionHandler] ;
}

- (AWSTask *)downloadToURL:(NSURL *)fileURL
                    bucket:(NSString *)bucket
                       key:(NSString *)key
                expression:(AWSS3TransferUtilityDownloadExpression *)expression
          completionHander:(AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    if (!expression) {
        expression = [AWSS3TransferUtilityDownloadExpression new];
    }
    
    AWSS3TransferUtilityDownloadCompletionHandlerBlock completionBlock = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
        
        //Downloaded completed
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        if (data) {
            // unlock the data using Bayun unlockData method
            [[BayunCore sharedInstance] unlockData:data success:^(NSData *data){
                //Data unlocking completed
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                                    code:errorCode
                                                                userInfo:nil];
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        else if(location) {
            // unlock the file using Bayun unlockFile method
            [[BayunCore sharedInstance] unlockFile:fileURL success:^{
                //File unlocking completed
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                                    code:errorCode
                                                                userInfo:nil];
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        } else {
            completionHandler(task,location,data,error);
        }
    };

    return [super downloadToURL:fileURL
                         bucket:bucket
                            key:key
                     expression:expression
               completionHandler:completionBlock];
   
}

#pragma mark - Utility methods

- (void)cleanUpTemporaryDirectory {
    NSError *error = nil;
    NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.temporaryDirectoryPath
                                                                                       error:&error];
    if (!contentsOfDirectory) {
        AWSLogError(@"Failed to retrieve the contents of the tempoprary directory: %@", error);
    }
    
    // Goes through the temporary directory.
    __weak SecureAWSS3TransferUtility *weakSelf = self;
    [contentsOfDirectory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        NSString *filePath = [weakSelf.temporaryDirectoryPath stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
                                                                                    error:&error];
        if (!attributes) {
            AWSLogError(@"Failed to load temporary file attributes: %@", error);
        }
        NSDate *fileCreationDate = [attributes objectForKey:NSFileCreationDate];
        // Removes an 'expired' temporary file.
        // Adds 60 seconds buffer to detemine if a file was 'expired'. e.g. Removes files older than 51 minutes old.
        if ([fileCreationDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970] - SecureAWSS3TransferUtilityTimeoutIntervalForResource - 60) {
            BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                                     error:&error];
            if (!result) {
                AWSLogError(@"Failed to remove a temporary file: %@", error);
            }
        }
    }];
}


@end

