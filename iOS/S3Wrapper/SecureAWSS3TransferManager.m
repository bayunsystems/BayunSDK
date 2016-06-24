//
//  SecureAWSS3TransferManager.m
//  
//
//  Created by Preeti-Gaur on 11/18/15.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAWSS3TransferManager.h"
#import "AWSS3.h"
#import <AWSTMCache.h>
#import <AWSTask.h>
#import "SecureAWSS3Service.h"


NSUInteger const SecureAWSS3TransferManagerMinimumPartSize = 5 * 1024 * 1024; // 5MB
NSString *const SecureAWSS3TransferManagerCacheName = @"com.bayun.SecureAWSS3TransferManager.CacheName";
NSString *const SecureAWSS3TransferManagerErrorDomain = @"com.bayun.SecureAWSS3TransferManagerErrorDomain";
NSUInteger const SecureAWSS3TransferManagerByteLimitDefault = 5 * 1024 * 1024; // 5MB
NSTimeInterval const SecureAWSS3TransferManagerAgeLimitDefault = 0.0; // Keeps the data indefinitely unless it hits the size limit.


@interface SecureAWSS3TransferManager()

@property (nonatomic, strong) SecureAWSS3 *s3;
@property (nonatomic, strong) AWSTMCache *cache;

@end

@interface AWSS3TransferManagerUploadRequest ()

@property (nonatomic, assign) AWSS3TransferManagerRequestState state;
@property (nonatomic, assign) NSUInteger currentUploadingPartNumber;
@property (nonatomic, strong) NSMutableArray *completedPartsArray;
@property (nonatomic, strong) NSString *uploadId;
@property (nonatomic, strong) NSString *cacheIdentifier;
@property (atomic, strong) AWSS3UploadPartRequest *currentUploadingPart;

@property (atomic, assign) int64_t totalSuccessfullySentPartsDataLength;
@end

@interface AWSS3TransferManagerDownloadRequest ()

@property (nonatomic, assign) AWSS3TransferManagerRequestState state;
@property (nonatomic, strong) NSString *cacheIdentifier;

@end


@implementation SecureAWSS3TransferManager

static AWSSynchronizedMutableDictionary *_serviceClients = nil;


+ (instancetype)defaultS3TransferManager {
    if (![AWSServiceManager defaultServiceManager].defaultServiceConfiguration) {
        return nil;
    }
    
    static SecureAWSS3TransferManager *_defaultS3TransferManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultS3TransferManager = [[SecureAWSS3TransferManager alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration
                                                                              cacheName:SecureAWSS3TransferManagerCacheName];
    });
    return _defaultS3TransferManager;
}

+ (void)registerS3TransferManagerWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [AWSSynchronizedMutableDictionary new];
    });
    
    SecureAWSS3TransferManager *s3TransferManager = [[SecureAWSS3TransferManager alloc] initWithConfiguration:configuration
                                                                                        cacheName:[NSString stringWithFormat:@"%@.%@", SecureAWSS3TransferManagerCacheName, key]];
    [_serviceClients setObject:s3TransferManager
                        forKey:key];
}

+ (instancetype)S3TransferManagerForKey:(NSString *)key {
    return [_serviceClients objectForKey:key];
}

+ (void)removeS3TransferManagerForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration
                           identifier:(NSString *)identifier {
    if (self = [self initWithConfiguration:configuration
                                 cacheName:[NSString stringWithFormat:@"%@.%@", SecureAWSS3TransferManagerCacheName, identifier]]) {
    }
    return self;
}


- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration
                            cacheName:(NSString *)cacheName {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _s3 = [[SecureAWSS3 alloc] initWithConfiguration:configuration];
#pragma clang diagnostic pop
    
    _cache = [[AWSTMCache alloc] initWithName:cacheName
                                     rootPath:[NSTemporaryDirectory() stringByAppendingPathComponent:SecureAWSS3TransferManagerCacheName]];
    _cache.diskCache.byteLimit = SecureAWSS3TransferManagerByteLimitDefault;
    _cache.diskCache.ageLimit = SecureAWSS3TransferManagerAgeLimitDefault;
    return self;
}


- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest
continueWithExecutor:(AWSExecutor *)executor
     withBlock:(AWSContinuationBlock)block{
    [[self upload:uploadRequest] continueWithExecutor:executor
                                            withBlock:^id(AWSTask *task) {
                                                NSLog(@"SECURE UPLOAD COMPLETE");
                                                block([self validateTask:task]);
                                                return nil;
                                            }];
}

- (AWSTask *)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest {
    NSString *cacheKey = nil;
    if ([uploadRequest valueForKey:@"cacheIdentifier"]) {
        cacheKey = [uploadRequest valueForKey:@"cacheIdentifier"];
    } else {
        cacheKey = [[NSProcessInfo processInfo] globallyUniqueString];
        [uploadRequest setValue:cacheKey forKey:@"cacheIdentifier"];
    }
    return [self upload:uploadRequest cacheKey:cacheKey];
}

- (AWSTask *)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest
          cacheKey:(NSString *)cacheKey {
    //validate input
    if ([uploadRequest.bucket length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'bucket' name can not be empty", nil)};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if ([uploadRequest.key length] == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'key' name can not be empty", nil)};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
    }
    if (uploadRequest.body == nil) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"'body' can not be nil", nil)};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorMissingRequiredParameters userInfo:userInfo]];
        
    } else if ([uploadRequest.body isKindOfClass:[NSURL class]] == NO) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid 'body' Type, must be an instance of NSURL Class", nil)};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorInvalidParameters userInfo:userInfo]];
    }
    
    //Check if the task has already completed
    if (uploadRequest.state == AWSS3TransferManagerRequestStateCompleted) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a completed task", nil)]};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCompleted userInfo:userInfo]];
    } else if (uploadRequest.state == AWSS3TransferManagerRequestStateCanceling){
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"can not continue to upload a cancelled task.", nil)]};
        return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCancelled userInfo:userInfo]];
    } else {
        //change state to running
        [uploadRequest setValue:[NSNumber numberWithInteger:AWSS3TransferManagerRequestStateRunning] forKey:@"state"];
    }
    
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[uploadRequest.body path] stringByResolvingSymlinksInPath]
                                                                                error:&error];
    if (!attributes) {
        return [AWSTask taskWithError:error];
    }
    
    unsigned long long fileSize = [attributes fileSize];
    __weak SecureAWSS3TransferManager *weakSelf = self;
    
    AWSTask *task = [AWSTask taskWithResult:nil];
    task = [[[task continueWithSuccessBlock:^id(AWSTask *task) {
        [weakSelf.cache setObject:uploadRequest
                           forKey:cacheKey];
        return nil;
    }] continueWithSuccessBlock:^id(AWSTask *task) {
        //after encryption for file size > 5MB multipart upload is handled by SecureAWSS3Service
        return [weakSelf putObject:uploadRequest fileSize:fileSize cacheKey:cacheKey];
        
    }] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:NSURLErrorDomain]
                && task.error.code == NSURLErrorCancelled) {
                if (uploadRequest.state == AWSS3TransferManagerRequestStatePaused) {
                    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain
                                                                     code:SecureAWSS3TransferManagerErrorPaused
                                                                 userInfo:task.error.userInfo]];
                } else {
                    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain
                                                                     code:SecureAWSS3TransferManagerErrorCancelled
                                                                 userInfo:task.error.userInfo]];
                }
            } else {
                return [AWSTask taskWithError:task.error];
            }
        } else {
            uploadRequest.state = AWSS3TransferManagerRequestStateCompleted;
            [uploadRequest setValue:nil forKey:@"internalRequest"];
            return [AWSTask taskWithResult:task.result];
        }
    }];
    
    return task;
}

- (AWSTask *)putObject:(AWSS3TransferManagerUploadRequest *)uploadRequest
             fileSize:(unsigned long long) fileSize
             cacheKey:(NSString *)cacheKey {
    uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
    AWSS3PutObjectRequest *putObjectRequest = [AWSS3PutObjectRequest new];
    [putObjectRequest aws_copyPropertiesFromObject:uploadRequest];
    __weak SecureAWSS3TransferManager *weakSelf = self;
    
    AWSTask *uploadTask = [[weakSelf.s3 putObject:putObjectRequest] continueWithBlock:^id(AWSTask *task) {
        
        //delete cached Object if state is not Paused
        if (uploadRequest.state != AWSS3TransferManagerRequestStatePaused) {
            [weakSelf.cache removeObjectForKey:cacheKey];
        }
        
        if (task.error) {
            return [AWSTask taskWithError:task.error];
        }
        
        AWSS3TransferManagerUploadOutput *uploadOutput = [AWSS3TransferManagerUploadOutput new];
        if (task.result) {
            AWSS3PutObjectOutput *putObjectOutput = task.result;
            [uploadOutput aws_copyPropertiesFromObject:putObjectOutput];
        }
        return uploadOutput;
    }];
    return uploadTask;
}


- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest continueWithExecutor:(AWSExecutor *)executor withBlock:(AWSContinuationBlock)block {
    [[super download:downloadRequest] continueWithExecutor:executor withBlock:^id(AWSTask *task) {
        block([self validateTask:task]);
        return nil;
    }];
}

/**
 *Converts the AWSTask which error != nil to task with error domain SecureAWSS3TransferManagerErrorDomain
 */
-(AWSTask*)validateTask:(AWSTask *)task {
    NSError *error = task.error;
    if ([task.error.domain isEqualToString:@"com.amazonaws.AWSS3TransferManagerErrorDomain"]) {
        switch (task.error.code) {
            case AWSS3TransferManagerErrorMissingRequiredParameters:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorMissingRequiredParameters userInfo:error.userInfo]];
                
            case AWSS3TransferManagerErrorInvalidParameters:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorInvalidParameters userInfo:error.userInfo]];
                
            case AWSS3TransferManagerErrorCompleted:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCompleted userInfo:error.userInfo]];
                
            case AWSS3TransferManagerErrorCancelled:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCancelled userInfo:error.userInfo]];
                
            case AWSS3TransferManagerErrorPaused:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorPaused userInfo:error.userInfo]];
                
                break;
            case AWSS3TransferManagerErrorInternalInConsistency:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorInternalInConsistency userInfo:error.userInfo]];
                
            case -1009:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorNoInternetConnection userInfo:error.userInfo]];
                
            default:
                return task;
        }
    } else if ([task.error.domain isEqualToString:@"com.bayun.SecureAWSS3ServiceErrorDomain"]) {
        switch (task.error.code) {
                
            case SecureAWSS3ServiceErrorMissingRequiredParameters:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorMissingRequiredParameters userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorInvalidParameters:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorInvalidParameters userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorCompleted:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCompleted userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorCancelled:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorCancelled userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorPaused:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorPaused userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorInternalInConsistency:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorInternalInConsistency userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorUserInactive:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorUserInactive userInfo:error.userInfo]];
                
            case SecureAWSS3ServiceErrorSomethingWentWrong:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorSomethingWentWrong userInfo:error.userInfo]];
                
            case -1009:
                return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorNoInternetConnection userInfo:error.userInfo]];
                
            default:
            {
                if ([task.error.domain isEqualToString:@"com.amazonaws.AWSS3ErrorDomain"]) {
                    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3TransferManagerErrorDomain code:SecureAWSS3TransferManagerErrorSomethingWentWrong userInfo:error.userInfo]];
                }
                return task;
            }
        }
    } else {
        return task;
    }
}


@end




