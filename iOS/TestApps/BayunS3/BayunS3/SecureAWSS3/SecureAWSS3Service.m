//
//  SecureAWSS3Sevice.m
//  Copyright © 2023 Bayun Systems, Inc. All rights reserved.
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
#import "AWSS3RequestRetryHandler.h"


static NSString *const AWSInfoS3 = @"S3";
NSString *const SecureAWSS3APIVersion = @"s3-2006-03-01";
NSString *const SecureAWSS3ServiceErrorDomain = @"com.bayun.SecureAWSS3ServiceErrorDomain";
NSUInteger const SecureAWSS3ServiceMinimumPartSize = 5 * 1024 * 1024; // 5MB
NSUInteger const SecureAWSS3ServiceByteLimitDefault = 5 * 1024 * 1024; // 5MB
NSTimeInterval const SecureAWSS3ServiceAgeLimitDefault = 0.0; // Keeps the data indefinitely unless it hits the size limit.

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
                } else if (errorCode == BayunErrorInvalidAppSecret) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Invalid App Secret", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorInvalidAppSecret
                                                                     userInfo:userInfo]];
                } else if (errorCode == BayunErrorDecryptionFailed) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Unlocking Failed", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorUnlockingFailed
                                                                     userInfo:userInfo]];
                } else if (errorCode == BayunErrorPasscodeAuthenticationCanceledByUser) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Passcode Authentication Canceled by User", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorPasscodeAuthenticationCanceledByUser
                                                                     userInfo:userInfo]];
                } else if (errorCode == BayunErrorReAuthenticationNeeded) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Reauthentication with Bayun is Needed", nil)};
                    taskNew = [AWSTask taskWithError:[NSError errorWithDomain:SecureAWSS3ServiceErrorDomain
                                                                         code:SecureAWSS3ServiceErrorReAuthenticationNeeded
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
@end
