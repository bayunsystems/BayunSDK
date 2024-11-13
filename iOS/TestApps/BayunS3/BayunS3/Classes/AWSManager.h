//
//  AWSManager.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bayun/BayunCore.h>

@class AWSS3ListObjectsOutput;

@protocol AWSManagerDelegate <NSObject>

@optional

/**
 Implemented to show Upload Progress
 @param progress Upload progress
 */
- (void)s3UploadProgress:(float)progress;

/**
 Implemented to show download progress
 @param progress Download progress
 */
- (void)s3DownloadProgress:(float)progress;

@end

@interface AWSManager : NSObject

@property (weak, nonatomic) id<AWSManagerDelegate> delegate;
@property (assign) BOOL isUploadRunning;

/**
 Returns singleton service client
 */
+ (instancetype)sharedInstance;

/**
 Sets type of Encryption policy
 */
- (void)setEncryptionPolicy:(BayunEncryptionPolicy)policy;

/**
 Sets type of Key Generation policy
 */
- (void) setKeyGenerationPolicy:(BayunKeyGenerationPolicy)policy;

/**
 Sets Group Id
 */
- (void)setGroupId:(NSString*)groupId;

/**
 Uploads a file to Amazon S3 bucket.
 @param filePath Local Path of the file to be uploaded.
 */
- (void)uploadFile:(NSURL*)fileURL
        bucketName:(NSString*)bucketName
           success:(void (^)(void))success
           failure:(void (^)(NSError*))failure;

/**
 Downloads a file from Amazon S3 bucket.
 @param filePath Local Path of the file at which it is downloaded.
 */
- (void)downloadFile:(NSURL *)downloadingFileURL
          bucketName:(NSString*)bucketName
             success:(void (^)(void))success
             failure:(void (^)(NSError*))failure;

/**
 Downloads all files in Amazon S3 bucket.
 */
- (void)getBucketFiles:(NSString*)bucketName
               success:(void (^)(AWSS3ListObjectsOutput*))success
               failure:(void (^)(NSError*))failure;

/**
 Creates a bucket on Amazon S3.
 @param bucketName Name of bucket to be created
 */
- (void)createS3BucketWithName:(NSString*)bucketName
                       success:(void (^)(void))success
                       failure:(void (^)(NSError*))failure;

/**
 Checks if the file with given key exists in Amazon S3 bucket.
 @param key Key of the file.
 */
- (void)isFileExistsFor:(NSString*) key
             bucketName:(NSString*)bucketName
                success:(void (^)(BOOL))success
                failure:(void (^)(NSError*))failure;

/**
 Deletes a file from Amazon S3 bucket.
 @param fileName Name of the file to be deleted
 */
- (void)deleteFile:(NSString *)fileName
        bucketName:(NSString*)bucketName
           success:(void (^)(void))success
           failure:(void (^)(NSError*))failure;

/**
 Cancels all of the upload and download requests.
 */
- (void)s3CancelAll;
@end
