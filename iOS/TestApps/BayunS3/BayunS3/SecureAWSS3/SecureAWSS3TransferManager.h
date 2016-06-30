//
//  SecureAWSS3TransferManager.h
//  
//
//  Created by Preeti-Gaur on 11/18/15.
//
//

#import "AWSS3TransferManager.h"
#import <AWSTask.h>

typedef NS_ENUM(NSInteger, SecureAWSS3TransferManagerErrorType) {
    SecureAWSS3TransferManagerErrorUnknown,
    SecureAWSS3TransferManagerErrorCancelled,
    SecureAWSS3TransferManagerErrorPaused,
    SecureAWSS3TransferManagerErrorCompleted,
    SecureAWSS3TransferManagerErrorInternalInConsistency,
    SecureAWSS3TransferManagerErrorMissingRequiredParameters,
    SecureAWSS3TransferManagerErrorInvalidParameters,
    SecureAWSS3TransferManagerErrorAccessDenied,
    SecureAWSS3TransferManagerErrorUserInactive,
    SecureAWSS3TransferManagerErrorInternetConnection,
    SecureAWSS3TransferManagerErrorSomethingWentWrong,
    SecureAWSS3TransferManagerErrorNoInternetConnection
};

@class SecureAWSS3TransferManagerUploadRequest;
@class SecureAWSS3TransferManagerUploadOutput;
@class SecureAWSS3TransferManagerDownloadRequest;
@class SecureAWSS3TransferManagerDownloadOutput;

/**
 Utility for managing secure transfers to Amazon S3. SecureAWSS3TransferManager provides a simple API for uploading and downloading content to Amazon S3.
 */
@interface SecureAWSS3TransferManager : AWSS3TransferManager

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.
 
  For example, set the default service configuration method in `- application:didFinishLaunchingWithOptions:`
 
 
  *Objective-C*
 
  - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
  AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:S3AccessKey secretKey:S3SecretKey];
 
  AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
  [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
 
  return YES;
}

 Then call the following to get the default service client:
 
 @return The default service client.
 */
+ (instancetype)defaultS3TransferManager;

/**
 Creates a service client with the given service configuration and registers it for the key.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:S3AccessKey secretKey:S3SecretKey];
 
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
    [SecureAWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:@"USWest2S3TransferManager"];
    return YES;
 }
 
 Then call the following to get the service client:

 *Objective-C*
 
 SecureAWSS3TransferManager *S3TransferManager = [SecureAWSS3TransferManager S3TransferManagerForKey:@"USWest2S3TransferManager"];
 
 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
 
 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */

+ (void)registerS3TransferManagerWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerS3TransferManagerWithConfiguration:forKey:` before invoking this method. If `+ registerS3TransferManagerWithConfiguration:forKey:` has not been called in advance or the key does not exist, this method returns `nil`.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kS3AccessKey secretKey:kS3SecretKey];
 
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
    [SecureAWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:@"USWest2S3TransferManager"];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 SecureAWSS3TransferManager *S3TransferManager = [SecureAWSS3TransferManager S3ForKey:@"USWest2S3TransferManager"];
 
 @param key A string to identify the service client.
 
 @return An instance of the service client.
 */
+ (instancetype)S3TransferManagerForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeS3TransferManagerForKey:(NSString *)key;

/*!
 Schedules a new transfer to upload data to Amazon S3.
 @param uploadRequest The upload request.
 @param executor A AWSExecutor responsible for determining how the
 continuation block will be run.
 @param block The block to be run once this task is complete.
 */
- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest continueWithExecutor:(AWSExecutor *)executor withBlock:(AWSContinuationBlock)block;

/*!
 Schedules a new transfer to download data from Amazon S3.
 @param downloadRequest The download request.
 @param executor A AWSExecutor responsible for determining how the
 continuation block will be run.
 @param block The block to be run once this task is complete.
 */
- (void)download:(AWSS3TransferManagerDownloadRequest *)downloadRequest continueWithExecutor:(AWSExecutor *)executor withBlock:(AWSContinuationBlock)block;

@end


