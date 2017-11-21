//
//  AWSManager.m
//  BayunS3
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "AWSManager.h"
#import "SecureAWSS3TransferManager.h"
#import "SecureAWSS3Service.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SecureAWSS3TransferManager.h"


@implementation AWSManager

+ (instancetype)sharedInstance {
    static AWSManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) setEncryptionPolicy:(BayunEncryptionPolicy)policy {
    [SecureAWSS3TransferManager defaultS3TransferManager].encryptionPolicy = policy;
}

- (void) setGroupId:(NSString*)groupId {
    [SecureAWSS3TransferManager defaultS3TransferManager].groupId = groupId;
}

/**
 Uploads a file to Amazon S3 bucket.
 @param filePath Local Path of the file to be uploaded.
 */
- (void)uploadFile:(NSURL*)fileURL bucketName:(NSString*)bucketName
           success:(void (^)(void))success
           failure:(void (^)(NSError*))failure{
    __weak typeof(self) weakSelf = self;
    
    //create the AWSS3TransferManagerUploadRequest
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = bucketName;
    uploadRequest.key = [fileURL lastPathComponent];
    uploadRequest.body = fileURL;
    
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.delegate respondsToSelector:@selector(s3UploadProgress:)])
                [weakSelf.delegate s3UploadProgress:(float)totalBytesSent/(float)totalBytesExpectedToSend];
        });
    };
    
    //Create the SecureAWSS3TransferManager object
    SecureAWSS3TransferManager *transferManager = [SecureAWSS3TransferManager defaultS3TransferManager];
    
    weakSelf.isUploadRunning = YES;
    
    // call the SecureAWSS3TransferManager upload method with the uploadRequest , AWSExecutor (responsible for determining how the continuation block will be run) and the completion block (taking the executor and the completion block as parameters to have synchronous secure upload request)
    [transferManager upload:uploadRequest continueWithExecutor:[AWSExecutor mainThreadExecutor]  withBlock:^id(AWSTask *task) {
        if (task.error) {
            if(task.error.code != SecureAWSS3TransferManagerErrorCancelled &&
               task.error.code != SecureAWSS3TransferManagerErrorPaused) {
                //Upload Failed
                //[OPTIONAL] The following error handling conditions are optional and client app may apply checks against the SecureAWSS3TransferManagerErrorType according per its requirement
                
                if (failure) {
                    failure(task.error);
                }
            }
        } else {
            if (success) {
                success();
            }
        }
        return nil;
    }];
}

/**
 Downloads a file from Amazon S3 bucket.
 @param filePath Local Path of the file at which it is downloaded.
 */
- (void)downloadFile:(NSURL *)fileURL
          bucketName:(NSString*)bucketName
             success:(void (^)(void))success
             failure:(void (^)(NSError*))failure{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:fileURL.path]) {
        [fileManager removeItemAtPath:fileURL.path error:&error];
    }
    
    __weak typeof(self) weakSelf = self;
    
    //create the AWSS3TransferManagerDownloadRequest
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = bucketName;
    downloadRequest.key = [fileURL lastPathComponent];
    downloadRequest.downloadingFileURL = fileURL;
    downloadRequest.downloadProgress  = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([weakSelf.delegate respondsToSelector:@selector(s3DownloadProgress:)])
                [weakSelf.delegate s3DownloadProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
        });
    };
    
    //Create the SecureAWSS3TransferManager object
    SecureAWSS3TransferManager *transferManager = [SecureAWSS3TransferManager defaultS3TransferManager];
    
    // call the SecureAWSS3TransferManager download method with the downloadRequest , AWSExecutor (responsible for determining how the continuation block will be run) and the completion block(taking the executor and the completion block as parameters to have synchronous secure download request)
    [transferManager download:downloadRequest continueWithExecutor:[AWSExecutor mainThreadExecutor]  withBlock:^id(AWSTask *task) {
        //Download Completed
        if (task.error){
            if (failure) {
                failure(task.error);
            }
        } else {
            if (success) {
                success();
            }
        }
        return nil;
    }];
    
}

/**
 Downloads all files in Amazon S3 bucket.
 */
- (void)getBucketFiles:(NSString*)bucketName
               success:(void (^)(AWSS3ListObjectsOutput*))success
               failure:(void (^)(NSError*))failure {
    AWSS3ListObjectsRequest *listObjectReq = [AWSS3ListObjectsRequest new];
    listObjectReq.bucket = bucketName;
    
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    [[s3 listObjects:listObjectReq] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if (failure) {
                failure(task.error);
            }
        } else {
            //File list download completed
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            if (success) {
                success(listObjectsOutput);
            }
        }
        return nil;
    }] ;
}

/**
 Creates a bucket on Amazon S3.
 @param bucketName Name of bucket to be created
 */
- (void)createS3BucketWithName:(NSString*)bucketName
                       success:(void (^)(void))success
                       failure:(void (^)(void))failure {
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    AWSS3CreateBucketRequest *createBucketRequest = [AWSS3CreateBucketRequest new];
    createBucketRequest.bucket = bucketName;
    
    AWSS3CreateBucketConfiguration *createBucketConfiguration = [AWSS3CreateBucketConfiguration new];
    [createBucketConfiguration setLocationConstraint:AWSS3BucketLocationConstraintUSWest2];
    createBucketRequest.createBucketConfiguration = createBucketConfiguration;
    
    [[s3 createBucket:createBucketRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSDictionary *userInfo = task.error.userInfo;
            if ([[userInfo valueForKey:@"Code"] isEqualToString:@"BucketAlreadyExists"] ||
                [[userInfo valueForKey:@"Code"] isEqualToString:@"BucketAlreadyOwnedByYou"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success();
                    }});
            } else {
                //bucket creation failed
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failure) {
                        failure();
                    }
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success();
                }
            });
        }
        
        return nil;
    }];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

/**
 Checks if the file with given key exists in Amazon S3 bucket.
 @param key Key of the file.
 */
- (void)isFileExistsFor:(NSString *)key
             bucketName:(NSString*)bucketName
                success:(void (^)(BOOL))success
                failure:(void (^)(NSError*))failure {
    
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    AWSS3GetObjectRequest *getObjectRequest = [AWSS3GetObjectRequest new];
    getObjectRequest.bucket = bucketName;
    getObjectRequest.key = key;
    
    __block NSString *filePath = [NSTemporaryDirectory()
                                  stringByAppendingPathComponent:key];
    
    getObjectRequest.downloadingFileURL = [NSURL fileURLWithPath:filePath];
    
    [[s3 getObject:getObjectRequest] continueWithBlock:^id(AWSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (task.error.code == AWSS3ErrorNoSuchKey) {
                if (success) {
                    success(NO);
                }
            } else if([[task.error.userInfo valueForKey:@"Code"] isEqualToString:@"AllAccessDisabled"]){
                if (failure) {
                    failure(task.error);
                }
            } else {
                if (success) {
                    success(YES);
                }
            }
        });
        return nil;
    }];
}

/**
 Deletes a file from Amazon S3 bucket
 @param fileName Name of the file to be deleted
 */
- (void)deleteFile:(NSString *)fileName
        bucketName:(NSString*)bucketName
           success:(void (^)(void))success
           failure:(void (^)(NSError*))failure{
    AWSS3DeleteObjectRequest *deleteObjectReq = [AWSS3DeleteObjectRequest new];
    deleteObjectReq.bucket = bucketName;
    deleteObjectReq.key = fileName;
    
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    [[s3 deleteObject:deleteObjectReq] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if (failure) {
                failure(task.error);
            }
            
        } else {
            //Delete successful
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success) {
                    success();
                }
            });
        }
        return nil;
    }] ;
}

/**
 Cancels all of the upload and download requests.
 */
- (void)s3CancelAll {
    SecureAWSS3TransferManager *transferManager = [SecureAWSS3TransferManager defaultS3TransferManager];
    [transferManager cancelAll];
}


@end


