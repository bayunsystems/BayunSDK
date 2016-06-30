//
//  SecureAWSS3Sevice.h
//  
//
//  Created by Preeti-Gaur on 12/10/15.
//
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import "AWSS3Model.h"
#import <AWSS3/AWSS3Service.h>

typedef NS_ENUM(NSInteger, SecureAWSS3ServiceErrorType) {
    SecureAWSS3ServiceErrorUnknown,
    SecureAWSS3ServiceErrorCancelled,
    SecureAWSS3ServiceErrorPaused,
    SecureAWSS3ServiceErrorCompleted,
    SecureAWSS3ServiceErrorInternalInConsistency,
    SecureAWSS3ServiceErrorMissingRequiredParameters,
    SecureAWSS3ServiceErrorInvalidParameters,
    SecureAWSS3ServiceErrorAccessDenied,
    SecureAWSS3ServiceErrorUserInactive,
    SecureAWSS3ServiceErrorEncryptionFailed,
    SecureAWSS3ServiceErrorDecryptionFailed,
    SecureAWSS3ServiceErrorInternetConnection,
    SecureAWSS3ServiceErrorSomethingWentWrong,
    SecureAWSS3ServiceErrorNoInternetConnection
};

/**
 
 */
@interface SecureAWSS3 :AWSS3

/**
 The service configuration used to instantiate this service client.
 
 @warning Once the client is instantiated, do not modify the configuration object. It may cause unspecified behaviors.
 */
@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.
 
 For example, set the default service configuration method in `- application:didFinishLaunchingWithOptions:`
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
 AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kS3AccessKey secretKey:kS3SecretKey];
 
 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
 
 return YES;
 }
 
 Then call the following to get the default service client:
 
 *Objective-C*
 
 SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
 
 @return The default service client.
 
 */
+ (instancetype)defaultS3;

/**
 Creates a service client with the given service configuration and registers it for the key.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
  
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 
 AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kS3AccessKey secretKey:kS3SecretKey];
 
 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
 [SecureAWSS3 registerS3WithConfiguration:configuration forKey:@"USWest2S3"];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 *Objective-C*
 
 SecureAWSS3 *S3 = [SecureAWSS3 S3ForKey:@"USWest2S3"];
 
 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
 
 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerS3WithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerS3WithConfiguration:forKey:` before invoking this method. If `+ registerS3WithConfiguration:forKey:` has not been called in advance or the key does not exist, this method returns `nil`.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kS3AccessKey secretKey:kS3SecretKey];
 
 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
 [SecureAWSS3 registerS3WithConfiguration:configuration forKey:@"USWest2S3"];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 *Objective-C*
 
 SecureAWSS3 *S3 = [SecureAWSS3 S3ForKey:@"USWest2S3"];
 
 @param key A string to identify the service client.
 
 @return An instance of the service client.
 */
+ (instancetype)S3ForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeS3ForKey:(NSString *)key;

/**
 Retrieves and decrypts objects from Amazon S3.
 
 @param request A container for the necessary parameters to execute the GetObject service method.
 
 @return An instance of `AWSTask`. On successful execution, `task.result` will contain an instance of `AWSS3GetObjectOutput`. On failed execution, `task.error` may contain an `NSError` with `AWSS3ErrorDomain` or `SecureAWSS3ServiceErrorDomain` domain.
 
 @see AWSS3GetObjectRequest
 @see AWSS3GetObjectOutput
 */
- (AWSTask *)getObject:(AWSS3GetObjectRequest *)request;


/**
 Adds an object to a bucket after encryption.
 
 @param request A container for the necessary parameters to execute the PutObject service method.
 
 @return An instance of `AWSTask`. On successful execution, `task.result` will contain an instance of `AWSS3PutObjectOutput`.
 
 @see AWSS3PutObjectRequest
 @see AWSS3PutObjectOutput
 */
- (AWSTask *)putObject:(AWSS3PutObjectRequest *)request;



@end




