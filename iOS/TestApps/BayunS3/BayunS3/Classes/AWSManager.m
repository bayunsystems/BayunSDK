//
//  AWSManager.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "AWSManager.h"
#import "SecureAWSS3TransferManager.h"
#import "SecureAWSS3Service.h"
#import <Bayun/BayunCore.h>


@implementation AWSManager


+ (instancetype)sharedInstance {
    static AWSManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/**
 Uploads a file to S3.
 @param filePath Local Path of the file to be uploaded.
 */
- (void)uploadFileFromPath:(NSString*)filePath {
    
        __weak typeof(self) weakSelf = self;
        
        //create the AWSS3TransferManagerUploadRequest
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.bucket = [Utilities s3BucketName];
        uploadRequest.key = [filePath lastPathComponent];
        uploadRequest.body = [NSURL fileURLWithPath:filePath];
        
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
                    if (task.error.code == SecureAWSS3TransferManagerErrorUserInactive) {
                        if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [self.delegate s3FileTransferFailed:kErrorMsgUserInActive];
                            return nil;
                        }
                    }
                    if (task.error.code == SecureAWSS3TransferManagerErrorAccessDenied) {
                        if([weakSelf.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [weakSelf.delegate s3FileTransferFailed:kErrorMsgAccessDenied];
                            return nil;
                        }
                    }
                    if (task.error.code == SecureAWSS3TransferManagerErrorSomethingWentWrong) {
                        if([weakSelf.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [weakSelf.delegate s3FileTransferFailed:kErrorMsgSomethingWentWrong];
                            return nil;
                        }
                    } else {
                        if([weakSelf.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [weakSelf.delegate s3FileTransferFailed:nil];
                        }
                    }
                }
            } else {
                //upload completed
                if([weakSelf.delegate respondsToSelector:@selector(s3UploadCompleted)])
                    [weakSelf.delegate s3UploadCompleted];
            }
            return nil;
        }];
}


/**
 Downloads a file from S3.
 @param filePath Local Path of the file at which it is downloaded.
 */
- (void)downloadFileAtPath:(NSString *)filePath {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
      
        __weak typeof(self) weakSelf = self;
        
        //create the AWSS3TransferManagerDownloadRequest
        AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
        downloadRequest.bucket = [Utilities s3BucketName];
        downloadRequest.key = [filePath lastPathComponent];
        downloadRequest.downloadingFileURL = [NSURL fileURLWithPath:filePath];
        downloadRequest.downloadProgress  = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([weakSelf.delegate respondsToSelector:@selector(s3DownloadProgress:)])
                    [weakSelf.delegate s3DownloadProgress:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
            });
        };
        
        //Create the SecureAWSS3TransferManager object
        SecureAWSS3TransferManager *transferManager = [SecureAWSS3TransferManager defaultS3TransferManager];
        
        // call the SecureAWSS3TransferManager dwonload method with the downloadRequest , AWSExecutor (responsible for determining how the continuation block will be run) and the completion block(taking the executor and the completion block as parameters to have synchronous secure download request)
        [transferManager download:downloadRequest continueWithExecutor:[AWSExecutor mainThreadExecutor]  withBlock:^id(AWSTask *task) {
            //Download Completed
            if (task.error){
                if(task.error.code != SecureAWSS3TransferManagerErrorCancelled &&
                   task.error.code != SecureAWSS3TransferManagerErrorPaused){
                    //Download Failed
                    //[OPTIONAL] The following error handling conditions are optional and client app may apply checks against the SecureAWSS3TransferManagerErrorType as per its requirement
                    if (task.error.code == SecureAWSS3TransferManagerErrorUserInactive) {
                        if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [self.delegate s3FileTransferFailed:kErrorMsgUserInActive];
                            return nil;
                        }
                    }
                    if (task.error.code == SecureAWSS3TransferManagerErrorAccessDenied) {
                        if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [self.delegate s3FileTransferFailed:kErrorMsgAccessDenied];
                            return nil;
                        }
                    } else if (task.error.code == SecureAWSS3TransferManagerErrorNoInternetConnection) {
                        if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [self.delegate s3FileTransferFailed:kErrorMsgInternetConnection];
                            return nil;
                        }
                    } else {
                        if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)]) {
                            [self.delegate s3FileTransferFailed: nil];
                        }
                    }
                }
            } else {
                if([weakSelf.delegate respondsToSelector:@selector(s3DownloadCompleted)])
                    [weakSelf.delegate s3DownloadCompleted];
            }
            return nil;
        }];
    
}

/**
 Downloads all files in S3 Bucket.
 */
- (void)getS3FileList {
    AWSS3ListObjectsRequest *listObjectReq = [AWSS3ListObjectsRequest new];
    listObjectReq.bucket = [Utilities s3BucketName];
    
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    [[s3 listObjects:listObjectReq] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if([self.delegate respondsToSelector:@selector(s3FileTransferFailed:)])
                [self.delegate s3FileTransferFailed:nil];
            
        } else {
            //File list download completed
            AWSS3ListObjectsOutput *listObjectsOutput = task.result;
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.delegate respondsToSelector:@selector(s3BucketObjectListDownload:)])
                    [self.delegate s3BucketObjectListDownload:(AWSS3ListObjectsOutput*)listObjectsOutput];
            });
        }
        return nil;
    }] ;
}

/**
 Creates a bucket on S3.
 @param bucketName Name of bucket to be created
 */
- (void)createS3BucketWithName:(NSString*)bucketName {
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    AWSS3CreateBucketRequest *createBucketRequest = [AWSS3CreateBucketRequest new];
    createBucketRequest.bucket = bucketName;
    
    AWSS3CreateBucketConfiguration *createBucketConfiguration = [AWSS3CreateBucketConfiguration new];
    createBucketConfiguration.locationConstraint = AWSS3BucketLocationConstraintUSWest2;
    createBucketRequest.createBucketConfiguration = createBucketConfiguration;
    
    __block BOOL success = NO;
    [[s3 createBucket:createBucketRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            success = NO;
            NSDictionary *userInfo = task.error.userInfo;
            if ([[userInfo valueForKey:@"Code"] isEqualToString:@"BucketAlreadyExists"] ||
                [[userInfo valueForKey:@"Code"] isEqualToString:@"BucketAlreadyOwnedByYou"]) {
                
                //The bucket name is saved for uploading, downloading files
                [[NSUserDefaults standardUserDefaults] setValue:bucketName forKey:kS3BucketName];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBucketExists];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self.delegate s3BucketAlreadyExists];
            } else {
                //bucket creation failed
                [self.delegate s3BucketCreationFailed];
            }
        } else {
            //new bucket is created
            //The bucket name is saved for uploading, downloading files
            [[NSUserDefaults standardUserDefaults] setValue:bucketName forKey:kS3BucketName];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBucketExists];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.delegate s3BucketCreated];
        }
        return nil;
    }];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

/**
 Checks if the file with given key exists in bucket.
 @param key Key of the file.
 */
- (void)checkFileExistenceForKey:(NSString *)key {
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    AWSS3GetObjectRequest *getObjectRequest = [AWSS3GetObjectRequest new];
    getObjectRequest.bucket = [Utilities s3BucketName];
    getObjectRequest.key = key;
    
    __block NSString *filePath = [NSTemporaryDirectory()
                                  stringByAppendingPathComponent:key];
    
    getObjectRequest.downloadingFileURL = [NSURL fileURLWithPath:filePath];
    
    [[s3 getObject:getObjectRequest] continueWithBlock:^id(AWSTask *task) {
        if ([self.delegate respondsToSelector:@selector(s3FileExistsForKey:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.error.code == AWSS3ErrorNoSuchKey) {
                    [self.delegate s3FileExistsForKey:NO];
                } else {
                    [self.delegate s3FileExistsForKey:YES];
                }
            });
        }
        return nil;
    }];
}

/**
 Deletes a file from S3 bucket
 @param fileName Name of the file to be deleted
 */
- (void)deleteFileWithName:(NSString *)fileName {
    AWSS3DeleteObjectRequest *deleteObjectReq = [AWSS3DeleteObjectRequest new];
    deleteObjectReq.bucket = [Utilities s3BucketName];
    deleteObjectReq.key = fileName;
    
    SecureAWSS3 *s3 = [SecureAWSS3 defaultS3];
    
    [[s3 deleteObject:deleteObjectReq] continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             if([self.delegate respondsToSelector:@selector(s3FileDeletionFailed)])
                 [self.delegate s3FileDeletionFailed];
             
         } else {
             //Delete successful
             dispatch_async(dispatch_get_main_queue(), ^{
                 if([self.delegate respondsToSelector:@selector(s3FileDeletionCompleted)])
                     [self.delegate s3FileDeletionCompleted];
                 
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
