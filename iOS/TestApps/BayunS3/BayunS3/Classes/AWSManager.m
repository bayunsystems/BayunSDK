//
//  AWSManager.m
//  BayunS3
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import "AWSManager.h"
#import "SecureAWSS3TransferUtility.h"
#import "SecureAWSS3Service.h"
#import <MobileCoreServices/MobileCoreServices.h>

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
    [SecureAWSS3TransferUtility defaultS3TransferUtility].encryptionPolicy = policy;
}

- (void) setKeyGenerationPolicy:(BayunKeyGenerationPolicy)policy {
  [SecureAWSS3TransferUtility defaultS3TransferUtility].keyGenerationPolicy = policy;
}

- (void) setGroupId:(NSString*)groupId {
  [SecureAWSS3TransferUtility defaultS3TransferUtility].groupId = groupId;
}

/**
 Uploads a file to Amazon S3 bucket.
 @param filePath Local Path of the file to be uploaded.
 */
- (void)uploadFile:(NSURL*)fileURL
        bucketName:(NSString*)bucketName
           success:(void (^)(void))success
           failure:(void (^)(NSError*))failure{
  __weak typeof(self) weakSelf = self;
    
  SecureAWSS3TransferUtility *transferUtility = [SecureAWSS3TransferUtility defaultS3TransferUtility];
  
  AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
  expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if([weakSelf.delegate respondsToSelector:@selector(s3UploadProgress:)]) {
        [weakSelf.delegate s3UploadProgress:progress.fractionCompleted];
      }
    });
  };
  
  
  AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (error) {
        //weakSelf.statusLabel.text = @"Failed to Upload";
      } else {
        if (success) {
          success();
        }
      }
    });
  };
  
  NSString *fileExtension = [fileURL pathExtension];
  NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
  NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
  
  [[transferUtility uploadFile:fileURL bucket:bucketName key:[fileURL lastPathComponent] contentType:contentType expression:expression completionHandler:completionHandler] continueWithBlock:^id(AWSTask *task) {
    
    if (task.error) {
      
      if ([[task.error.userInfo valueForKey:@"Message"] isEqualToString:@"The specified bucket does not exist"]) {
        [self createS3BucketWithName:bucketName success:^{
          [self uploadFile:fileURL bucketName:bucketName success:success failure:failure];
        } failure:failure];
      } else {
        //Upload Failed
        //[OPTIONAL] The following error handling conditions are optional and client app may apply checks against the SecureAWSS3TransferManagerErrorType according to its requirement
        
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
  
  weakSelf.isUploadRunning = YES;
  
  // call the SecureAWSS3TransferManager upload method with the uploadRequest , AWSExecutor (responsible for determining how the continuation block will be run) and the completion block (taking the executor and the completion block as parameters to have synchronous secure upload request)
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
  
  //Configure AWSServiceManager defaultServiceConfiguration
  SecureAWSS3TransferUtility *transferUtility = [SecureAWSS3TransferUtility defaultS3TransferUtility];
  
  AWSS3TransferUtilityDownloadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [SVProgressHUD dismiss];
      if (error) {
      }
      if (data) {
        UIImage *image = [UIImage imageWithData:data];
        if (success) {
          success();
        }
      }
      
      if (location) {
        if (success) {
          success();
        }
      }
    });
  };
  
  //Create the TransferUtility expression and add the progress block to it.
  //This would be needed to report on progress tracking
  AWSS3TransferUtilityDownloadExpression *expression = [AWSS3TransferUtilityDownloadExpression new];
  expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if([weakSelf.delegate respondsToSelector:@selector(s3DownloadProgress:)])
        [weakSelf.delegate s3DownloadProgress:progress.fractionCompleted];
    });
  };
  
  [[transferUtility downloadToURL:fileURL bucket:bucketName key:[fileURL lastPathComponent] expression:expression completionHander:completionHandler] continueWithBlock:^id(AWSTask *task){
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
    listObjectReq.bucket = [bucketName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
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
                       failure:(void (^)(NSError*))failure {
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
                        failure(task.error);
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
}


@end


