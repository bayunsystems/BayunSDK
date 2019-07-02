//
//  SecureAWSS3TransferUtility.h
//  BayunS3
//
//  Created by Preeti Gaur on 05/07/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import <AWSS3TransferUtility.h>
#import <Bayun/BayunCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecureAWSS3TransferUtility : AWSS3TransferUtility

@property (strong, nonatomic) NSString *groupId;

/**
 Encryption Policy determines the key for Encryption.
 Default encryption policy is BayunEncryptionPolicyDefault.
 */
@property (nonatomic, assign) BayunEncryptionPolicy encryptionPolicy;

/**
 Key Generation Policy determines what policy is used for Data Encryption Key.
 Default encryption policy is BayunKeyGenerationPolicyStatic.
 */
@property (nonatomic, assign) BayunKeyGenerationPolicy keyGenerationPolicy;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:YourS3AccessKey secretKey:YourS3SecretKey];
 
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
 
 return YES;
 }
 
 Then call the following to get the default service client:
 
 *Objective-C*
 
 AWSS3TransferUtility *S3TransferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
 
 @return The default service client.
 */
+ (instancetype)defaultS3TransferUtility;


/**
 Creates a service client with the given service configuration and registers it for the key.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 
 *Objective-C*
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:YourS3AccessKey secretKey:YourS3SecretKey];
 
 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
 [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:@"USWest2S3TransferUtility"];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 *Objective-C*
 
 SecureAWSS3TransferUtility *S3TransferUtility = [SecureAWSS3TransferUtility S3TransferUtilityForKey:@"USWest2S3TransferUtility"];
 
 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.
 
 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerS3TransferUtilityWithConfiguration:(AWSServiceConfiguration *)configuration
                                            forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerS3TransferUtilityWithConfiguration:forKey:` before invoking this method. If `+ registerS3TransferUtilityWithConfiguration:forKey:` has not been called in advance or the key does not exist, this method returns `nil`.
 
 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
 AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:YourS3AccessKey secretKey:YourS3SecretKey];
 
 AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
 
 [SecureAWSS3TransferUtility registerS3TransferUtilityWithConfiguration:configuration forKey:@"USWest2S3TransferUtility"];
 
 return YES;
 }
 
 Then call the following to get the service client:
 
 SecureAWSS3TransferUtility *S3TransferUtility = [SecureAWSS3TransferUtility S3ForKey:@"USWest2S3TransferUtility"];
 
 @param key A string to identify the service client.
 
 @return An instance of the service client.
 */
+ (instancetype)S3TransferUtilityForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeS3TransferUtilityForKey:(NSString *)key;

/**
 Saves the `NSData` to a temporary directory, locks and uploads it to the specified Amazon S3 bucket.
 
 @param data              The data to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the data.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion hanlder when the upload completes.
 
 @return Returns an instance of `AWSTask`. On successful initialization, `task.result` contains an instance of `AWSS3TransferUtilityUploadTask`.
 */
- (AWSTask *)uploadData:(NSData *)data
                 bucket:(NSString *)bucket
                    key:(NSString *)key
            contentType:(NSString *)contentType
             expression:(nullable AWSS3TransferUtilityUploadExpression *)expression
       completionHander:(nullable AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Uploads the locked file to the specified Amazon S3 bucket.
 
 @param fileURL           The file URL of the file to upload.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param contentType       `Content-Type` of the file.
 @param expression        The container object to configure the upload request.
 @param completionHandler The completion hanlder when the upload completes.
 
 @return Returns an instance of `AWSTask`. On successful initialization, `task.result` contains an instance of `AWSS3TransferUtilityUploadTask`.
 */
- (AWSTask *)uploadFile:(NSURL *)fileURL
                 bucket:(NSString *)bucket
                    key:(NSString *)key
            contentType:(NSString *)contentType
             expression:(nullable AWSS3TransferUtilityUploadExpression *)expression
       completionHander:(nullable AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler;

/**
 Downloads the specified Amazon S3 object as `NSData`.
 
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion hanlder when the download completes.
 
 @return Returns an instance of `AWSTask`. On successful initialization, `task.result` contains an instance of `AWSS3TransferUtilityDownloadTask`.
 */
- (AWSTask *)downloadDataFromBucket:(NSString *)bucket
                                key:(NSString *)key
                         expression:(nullable AWSS3TransferUtilityDownloadExpression *)expression
                   completionHander:(nullable AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler;

/**
 Downloads the specified Amazon S3 object to a file URL.
 
 @param fileURL           The file URL to download the object to. Should not be `nil` even though it is marked as `nullable`.
 @param bucket            The Amazon S3 bucket name.
 @param key               The Amazon S3 object key name.
 @param expression        The container object to configure the download request.
 @param completionHandler The completion hanlder when the download completes.
 
 @return Returns an instance of `AWSTask`. On successful initialization, `task.result` contains an instance of `AWSS3TransferUtilityDownloadTask`.
 */
- (AWSTask *)downloadToURL:(nullable NSURL *)fileURL
                    bucket:(NSString *)bucket
                       key:(NSString *)key
                expression:(nullable AWSS3TransferUtilityDownloadExpression *)expression
          completionHander:(nullable AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler;


@end

NS_ASSUME_NONNULL_END

