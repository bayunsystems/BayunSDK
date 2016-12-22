//
//  AWSManager.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AWSS3ListObjectsOutput;

@protocol AWSManagerDelegate <NSObject>

@optional

/**
 Implemented to show Upload Progress
 @param progress Upload progress
 */
- (void)s3UploadProgress:(float)progress;

/**
 Implemented to perform operation after upload is completed
 */
- (void)s3UploadCompleted;

/**
 Implemented to show download progress
@param progress Download progress
 */
- (void)s3DownloadProgress:(float)progress;

/**
 Implemented to perform operation after download is completed
 */
- (void)s3DownloadCompleted;

/**
 Implemented to track if file transfered is failed
 @param Error message
 */
- (void)s3FileTransferFailed:(NSString*)errorMessage;

/**
 Implemented to perform operation after bucket object list is downloaded
 @param buketObjectList AWSS3ListObjectsOutput
 */
- (void)s3BucketObjectListDownload:(AWSS3ListObjectsOutput *)bucketObjectsList;

/**
 Implemented to check if file exists for key
 @param exists True/False
 */
- (void)s3FileExistsForKey:(BOOL)exists;

/**
 Implemented to track if file deletion is failed
 */
- (void)s3FileDeletionFailed;

/**
 Implemented to track if file deletion is completed
 */
- (void)s3FileDeletionCompleted;

/**
 Implemented to track if bucket is created.
 */
- (void)s3BucketCreated;

/**
 Implemented to track if bucket already exists
 */
- (void)s3BucketAlreadyExists;

/**
 Implemented to track if bucket creation is failed
 */
- (void)s3BucketCreationFailed;

@end


@interface AWSManager : NSObject

@property (weak, nonatomic) id<AWSManagerDelegate> delegate;
@property (assign) BOOL isUploadRunning;

/**
 Returns singleton service client
 */
+ (instancetype)sharedInstance;

/**
 Uploads a file to Amazon S3 bucket.
 @param filePath Local Path of the file to be uploaded.
 */
- (void)uploadFile:(NSURL*)uploadingFileURL;

/**
 Downloads a file from Amazon S3 bucket.
 @param filePath Local Path of the file at which it is downloaded.
 */
- (void)downloadFileToURL:(NSURL *)downloadingFileURL;

/**
 Downloads all files in Amazon S3 bucket.
 */
- (void)getS3FileList;

/**
 Creates a bucket on Amazon S3.
 @param bucketName Name of bucket to be created
 */
- (void)createS3BucketWithName:(NSString*)bucketName;

/**
 Checks if the file with given key exists in Amazon S3 bucket.
 @param key Key of the file.
 */
- (void)checkFileExistenceForKey:(NSString*) key;

/**
 Deletes a file from Amazon S3 bucket.
 @param fileName Name of the file to be deleted
 */
- (void)deleteFileWithName:(NSString *)fileName;

/**
 Cancels all of the upload and download requests.
 */
- (void)s3CancelAll;
@end
