//
//  SecureAWSS3TransferUtility.m
//  Copyright © 2023 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAWSS3TransferUtility.h"
#import "AWSS3PreSignedURL.h"
#import "AWSSynchronizedMutableDictionary.h"


#import "AWSS3TransferUtility.h"
#import "AWSS3PreSignedURL.h"
#import "AWSS3Service.h"
#import "AWSS3TransferUtilityDatabaseHelper.h"
#import "AWSS3TransferUtilityTasks.h"
#import "AWSS3CreateMultipartUploadRequest+RequestHeaders.h"
#import "AWSS3TransferUtilityTasks+Completion.h"
#import "AWSS3TransferUtility_private.h"

NSString *const SecureAWSS3TransferUtilityIdentifier = @"com.bayun.SecureAWSS3TransferUtility.Identifier";
NSTimeInterval const SecureAWSS3TransferUtilityTimeoutIntervalForResource = 50 * 60; // 50 minutes

NSString *const SecureAWSS3TransferUtilityUserAgent = @"secure-transfer-utility";
NSString *const SecureAWSS3TransferUtilityErrorDomain= @"com.bayun.SecureAWSS3TransferUtilityErrorDomain";
static NSString *const AWSInfoS3TransferUtility = @"S3TransferUtility";

#pragma mark - Private classes
@interface SecureAWSS3TransferUtility() <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) AWSServiceConfiguration *configuration_;
@property (strong, nonatomic) AWSS3TransferUtilityConfiguration *transferUtilityConfiguration_;
@property (strong, nonatomic) AWSS3PreSignedURLBuilder *preSignedURLBuilder;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *sessionIdentifier;
@property (strong, nonatomic) NSString *temporaryDirectoryPath;
@property (strong, nonatomic) AWSSynchronizedMutableDictionary *taskDictionary;
@property (copy, nonatomic) void (^backgroundURLSessionCompletionHandler)(void);
@property (strong, nonatomic) AWSFMDatabaseQueue *databaseQueue;

@end

@interface AWSS3TransferUtility (Validation)
- (AWSTask *) validateParameters: (NSString * )bucket key:(NSString *)key fileURL:(NSURL *)fileURL accelerationModeEnabled: (BOOL) accelerationModeEnabled;

- (AWSTask *) validateParameters: (NSString * )bucket key:(NSString *)key accelerationModeEnabled: (BOOL) accelerationModeEnabled;

@end

@interface AWSS3PreSignedURLBuilder()

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

@end

#pragma mark - AWSS3TransferUtility

@implementation SecureAWSS3TransferUtility

static AWSSynchronizedMutableDictionary *_serviceClients = nil;
static SecureAWSS3TransferUtility *_defaultS3TransferUtility = nil;

#pragma mark - Initialization methods

- (NSString *)cacheDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [cachePath stringByAppendingPathComponent:AWSInfoS3TransferUtility];
    return cachePath;
}


+ (instancetype)defaultS3TransferUtility {    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AWSServiceConfiguration *serviceConfiguration = nil;
        AWSS3TransferUtilityConfiguration *transferUtilityConfiguration = [AWSS3TransferUtilityConfiguration new];
        
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] defaultServiceInfo:AWSInfoS3TransferUtility];
        if (serviceInfo) {
            serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                               credentialsProvider:serviceInfo.cognitoCredentialsProvider];
            NSNumber *accelerateModeEnabled = [serviceInfo.infoDictionary valueForKey:@"AccelerateModeEnabled"];
            NSString *bucketName = [serviceInfo.infoDictionary valueForKey:@"Bucket"];
            transferUtilityConfiguration.bucket = bucketName;
            transferUtilityConfiguration.accelerateModeEnabled = [accelerateModeEnabled boolValue];
            transferUtilityConfiguration.timeoutIntervalForResource = SecureAWSS3TransferUtilityTimeoutIntervalForResource;
        }
        
        if (!serviceConfiguration) {
            serviceConfiguration = [AWSServiceManager defaultServiceManager].defaultServiceConfiguration;
        }
        
        if (!serviceConfiguration) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"The service configuration is `nil`. You need to configure `Info.plist` or set `defaultServiceConfiguration` before using this method."
                                         userInfo:nil];
        }
        
        serviceConfiguration.timeoutIntervalForResource = SecureAWSS3TransferUtilityTimeoutIntervalForResource;
        
        _defaultS3TransferUtility = [[SecureAWSS3TransferUtility alloc] initWithConfiguration:serviceConfiguration
                                                                 transferUtilityConfiguration:transferUtilityConfiguration
                                                                                   identifier:nil
                                                                            completionHandler:nil];
        
        _defaultS3TransferUtility.encryptionPolicy = BayunEncryptionPolicyDefault;
    });
    
    return _defaultS3TransferUtility;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)serviceConfiguration
         transferUtilityConfiguration:(AWSS3TransferUtilityConfiguration *)transferUtilityConfiguration
                           identifier:(NSString *)identifier
                    completionHandler:(void (^)(NSError *_Nullable error)) completionHandler {
    return [self initWithConfiguration:serviceConfiguration
          transferUtilityConfiguration:transferUtilityConfiguration identifier:identifier
                          recoverState:NO
                     completionHandler:completionHandler];
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)serviceConfiguration
         transferUtilityConfiguration:(AWSS3TransferUtilityConfiguration *)transferUtilityConfiguration
                           identifier:(NSString *)identifier
                         recoverState:(BOOL)recoverState
                    completionHandler: (void (^)(NSError *_Nullable error)) completionHandler{
    
    // Create a temporary directory for data uploads in the caches directory
    AWSDDLogDebug(@"Temporary dir Path is %@", self.cacheDirectoryPath);
    NSURL *directoryURL = [NSURL fileURLWithPath:self.cacheDirectoryPath];
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
    //Call the completion handler with the error and return nil if unable to create the temporary directory
    if (!result) {
        AWSDDLogError(@"Failed to create a temporary directory: %@", error);
        //Call completion handler if one was provided.
        if (completionHandler) {
            completionHandler(error);
        }
        return nil;
    }
    
    if (identifier) {
        _sessionIdentifier = identifier;
    }
    else {
        _sessionIdentifier = SecureAWSS3TransferUtilityIdentifier;
    }
    
    //Create the NS URL session
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_sessionIdentifier];
    configuration.allowsCellularAccess = serviceConfiguration.allowsCellularAccess;
    configuration.timeoutIntervalForResource = transferUtilityConfiguration.timeoutIntervalForResource;
    
    if(serviceConfiguration.timeoutIntervalForRequest > 0){
        configuration.timeoutIntervalForRequest = serviceConfiguration.timeoutIntervalForRequest;
    }
    configuration.sharedContainerIdentifier = serviceConfiguration.sharedContainerIdentifier;
    
    _session = [NSURLSession sessionWithConfiguration:configuration
                                             delegate:self
                                        delegateQueue:nil];
    
    //If not able to create the session, call completion handler with error and return nil.
    if (!_session ) {
        NSString* message = [NSString stringWithFormat:@"Failed to create a NSURLSession for [%@]", _sessionIdentifier];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message
                                                             forKey:@"Message"];
        NSError *error = [NSError errorWithDomain:AWSS3TransferUtilityErrorDomain
                                             code:AWSS3TransferUtilityErrorClientError
                                         userInfo:userInfo];
        if (completionHandler ) {
            completionHandler(error);
        }
        return nil;
    }
    
    //Setup the client object in the client dictionary
    _configuration_ = [serviceConfiguration copy];
    [_configuration_ addUserAgentProductToken:SecureAWSS3TransferUtilityUserAgent];
    
    if (transferUtilityConfiguration  ) {
        _transferUtilityConfiguration_ = [transferUtilityConfiguration copy];
    }
    else {
        _transferUtilityConfiguration_ = [AWSS3TransferUtilityConfiguration new];
    }
    
    _preSignedURLBuilder = [[AWSS3PreSignedURLBuilder alloc] initWithConfiguration:_configuration_];
    
    //Setup internal Data Structures
    _taskDictionary = [AWSSynchronizedMutableDictionary new];
    
    //Instantiate the Database Helper
    self.databaseQueue = [AWSS3TransferUtilityDatabaseHelper createDatabase:self.cacheDirectoryPath];
    
    return self;
}


+ (void)registerS3TransferUtilityWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [AWSSynchronizedMutableDictionary new];
    });
    
    SecureAWSS3TransferUtility *s3TransferUtility = [[SecureAWSS3TransferUtility alloc] initWithConfiguration:configuration identifier:[NSString stringWithFormat:@"%@.%@", SecureAWSS3TransferUtilityIdentifier, key]];
    
    [_serviceClients setObject:s3TransferUtility
                        forKey:key];
}

+ (instancetype)S3TransferUtilityForKey:(NSString *)key {
    // return [_serviceClients objectForKey:key];
    @synchronized(self) {
        SecureAWSS3TransferUtility *serviceClient = [_serviceClients objectForKey:key];
        if (serviceClient) {
            return serviceClient;
        }
        
        AWSServiceInfo *serviceInfo = [[AWSInfo defaultAWSInfo] serviceInfo:AWSInfoS3TransferUtility
                                                                     forKey:key];
        
        AWSS3TransferUtilityConfiguration *transferUtilityConfiguration = [AWSS3TransferUtilityConfiguration new];
        
        if (serviceInfo) {
            AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:serviceInfo.region
                                                                                        credentialsProvider:serviceInfo.cognitoCredentialsProvider];
            
            
            [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:serviceConfiguration
                                                                      forKey:key];
            
            
            
            NSNumber *accelerateModeEnabled = [serviceInfo.infoDictionary valueForKey:@"AccelerateModeEnabled"];
            NSString *bucketName = [serviceInfo.infoDictionary valueForKey:@"Bucket"];
            transferUtilityConfiguration.bucket = bucketName;
            transferUtilityConfiguration.accelerateModeEnabled = [accelerateModeEnabled boolValue];
            transferUtilityConfiguration.timeoutIntervalForResource = SecureAWSS3TransferUtilityTimeoutIntervalForResource;
            
            
            [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:serviceConfiguration transferUtilityConfiguration:transferUtilityConfiguration forKey:key completionHandler:nil];
            
            
        }
        
        return [_serviceClients objectForKey:key];
    }
}

+ (void)removeS3TransferUtilityForKey:(NSString *)key {
    //[_serviceClients removeObjectForKey:key];
    SecureAWSS3TransferUtility *transferUtility = [self S3TransferUtilityForKey:key];
    if (transferUtility) {
        [transferUtility.session invalidateAndCancel];
    }
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultS3TransferUtility` or `+ S3TransferUtilityForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)serviceconfiguration
                           identifier:(NSString *)identifier {
    
    
    self.configuration_ = [serviceconfiguration copy];
    [self.configuration_  addUserAgentProductToken:SecureAWSS3TransferUtilityUserAgent];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _preSignedURLBuilder = [[AWSS3PreSignedURLBuilder alloc] initWithConfiguration:self.configuration_ ];
#pragma clang diagnostic pop
    
    if (identifier) {
        _sessionIdentifier = identifier;
    } else {
        _sessionIdentifier = SecureAWSS3TransferUtilityIdentifier;
    }
    
    NSURLSessionConfiguration *configuration =  nil;
    if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_sessionIdentifier];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:_sessionIdentifier];
#pragma clang diagnostic pop
    }
    
    configuration.timeoutIntervalForResource = SecureAWSS3TransferUtilityTimeoutIntervalForResource;
    _session = [NSURLSession sessionWithConfiguration:configuration
                                             delegate:self
                                        delegateQueue:nil];
    
    _taskDictionary = [AWSSynchronizedMutableDictionary new];
    
    // Creates a temporary directory for data uploads
    _temporaryDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu",(unsigned long)[_sessionIdentifier hash]]];
    NSURL *directoryURL = [NSURL fileURLWithPath:_temporaryDirectoryPath];
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
    if (!result) {
        NSLog(@"Failed to create a temporary directory: %@", error);
    }
    
    // Clean up the temporary directory
    __weak SecureAWSS3TransferUtility *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [weakSelf cleanUpTemporaryDirectory];
    });
    return self;
}

#pragma mark - Upload methods

- (AWSTask<AWSS3TransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(AWSS3TransferUtilityUploadExpression *)expression
                                        completionHandler:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    return [self uploadData:data
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                 expression:expression
          completionHandler:completionHandler];
}

- (AWSTask<AWSS3TransferUtilityUploadTask *> *)uploadData:(NSData *)data
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(nullable AWSS3TransferUtilityUploadExpression *)expression
                                        completionHandler:(nullable AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    
    // Saves the data as a file in the temporary directory.
    NSString *fileName = [NSString stringWithFormat:@"%@.tmp", [[NSProcessInfo processInfo] globallyUniqueString]];
    NSString *filePath = [self.cacheDirectoryPath stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSError *error = nil;
    BOOL result = [data writeToURL:fileURL
                           options:NSDataWritingAtomic
                             error:&error];
    if (!result) {
        if (completionHandler) {
            AWSS3TransferUtilityUploadTask *uploadTask = [AWSS3TransferUtilityUploadTask new];
            uploadTask.bucket = bucket;
            uploadTask.key = key;
            completionHandler(uploadTask,error);
        }
        return [AWSTask taskWithError:error];
    }
    
    return  [self uploadFile:fileURL
                      bucket:bucket
                         key:key
                 contentType:contentType
                  expression:expression
           completionHandler:completionHandler];
}

- (AWSTask<AWSS3TransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(AWSS3TransferUtilityUploadExpression *)expression
                                        completionHandler:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    return [self uploadFile:fileURL
                     bucket:self.transferUtilityConfiguration.bucket
                        key:key
                contentType:contentType
                 expression:expression
          completionHandler:completionHandler];
}

- (AWSTask<AWSS3TransferUtilityUploadTask *> *)uploadFile:(NSURL *)fileURL
                                                   bucket:(NSString *)bucket
                                                      key:(NSString *)key
                                              contentType:(NSString *)contentType
                                               expression:(AWSS3TransferUtilityUploadExpression *)expression
                                        completionHandler:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    if (!expression) {
        expression = [AWSS3TransferUtilityUploadExpression new];
    }
    
    __block AWSTask *task;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[BayunCore sharedInstance] lockFile:fileURL
                        encryptionPolicy:self.encryptionPolicy
                     keyGenerationPolicy:self.keyGenerationPolicy
                                 groupId:self.groupId
                                 success:^{
        
        task = [self internalUploadFile:fileURL
                                 bucket:bucket
                                    key:key
                            contentType:contentType
                             expression:expression
                   temporaryFileCreated:NO
                      completionHandler:completionHandler];
        
        dispatch_semaphore_signal(semaphore);
    } failure:^(BayunError errorCode) {
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                            code:errorCode
                                                        userInfo:nil];
                AWSS3TransferUtilityUploadTask *task = [AWSS3TransferUtilityUploadTask new];
                completionHandler(task,error);
            });
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return task;
}

- (AWSTask<AWSS3TransferUtilityUploadTask *> *)internalUploadFile:(NSURL *)fileURL
                                                           bucket:(NSString *)bucket
                                                              key:(NSString *)key
                                                      contentType:(NSString *)contentType
                                                       expression:(AWSS3TransferUtilityUploadExpression *)expression
                                             temporaryFileCreated: (BOOL) temporaryFileCreated
                                                completionHandler:(AWSS3TransferUtilityUploadCompletionHandlerBlock)completionHandler {
    
    //Create Expression if required and set it up
    if (!expression) {
        expression = [AWSS3TransferUtilityUploadExpression new];
    }
    [expression setValue:contentType forRequestHeader:@"Content-Type"];
    expression.completionHandler = completionHandler;
    
    //Create TransferUtility Upload Task
    AWSS3TransferUtilityUploadTask *transferUtilityUploadTask = [AWSS3TransferUtilityUploadTask new];
    transferUtilityUploadTask.nsURLSessionID = self.sessionIdentifier;
    transferUtilityUploadTask.databaseQueue = self.databaseQueue;
    transferUtilityUploadTask.transferType = @"UPLOAD";
    transferUtilityUploadTask.bucket = bucket;
    transferUtilityUploadTask.key = key;
    transferUtilityUploadTask.retryCount = 0;
    transferUtilityUploadTask.expression = expression;
    transferUtilityUploadTask.transferID = [[NSUUID UUID] UUIDString];
    transferUtilityUploadTask.file = [fileURL path];
    transferUtilityUploadTask.cancelled = NO;
    transferUtilityUploadTask.temporaryFileCreated = temporaryFileCreated;
    transferUtilityUploadTask.responseData = @"";
    transferUtilityUploadTask.status = AWSS3TransferUtilityTransferStatusInProgress;
    
    //Add to Database
    [AWSS3TransferUtilityDatabaseHelper insertUploadTransferRequestInDB:transferUtilityUploadTask databaseQueue:self->_databaseQueue];
    
    return [self createUploadTask:transferUtilityUploadTask];
}

-(AWSTask<AWSS3TransferUtilityUploadTask *> *) createUploadTask: (AWSS3TransferUtilityUploadTask *) transferUtilityUploadTask {
    return [self createUploadTask:transferUtilityUploadTask startTransfer:YES];
}

- (NSURLSessionUploadTask *)getURLSessionUploadTaskWithRequest:(NSURLRequest *) request
                                                      fromFile:(NSURL *) fileURL
                                                         error:(NSError **) errorPtr {
    @try {
        return [self.session uploadTaskWithRequest:request
                                          fromFile:fileURL];
    } @catch (NSException *exception) {
        AWSDDLogWarn(@"Exception in upload task %@", exception.debugDescription);
        NSString *exceptionReason = [exception.reason copy];
        NSString *errorMessage = [NSString stringWithFormat:@"Exception from upload task."];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  errorMessage, @"Message",
                                  exceptionReason, @"Reason", nil];
        if (errorPtr != NULL) {
            *errorPtr = [NSError errorWithDomain:AWSS3TransferUtilityErrorDomain
                                            code:AWSS3TransferUtilityErrorUnknown
                                        userInfo:userInfo];
        }
    }
    return nil;
}

-(AWSTask<AWSS3TransferUtilityUploadTask *> *) createUploadTask:(AWSS3TransferUtilityUploadTask *) transferUtilityUploadTask
                                                  startTransfer:(BOOL) startTransfer {
    //Create PreSigned URL Request
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = transferUtilityUploadTask.bucket;
    getPreSignedURLRequest.key = transferUtilityUploadTask.key;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:_transferUtilityConfiguration_.timeoutIntervalForResource];
    AWSDDLogDebug(@"Value of timeoutIntervalForResource is %ld", (long)_transferUtilityConfiguration_.timeoutIntervalForResource);
    getPreSignedURLRequest.minimumCredentialsExpirationInterval = _transferUtilityConfiguration_.timeoutIntervalForResource;
    getPreSignedURLRequest.accelerateModeEnabled = self.transferUtilityConfiguration.isAccelerateModeEnabled;
    
    [transferUtilityUploadTask.expression assignRequestHeaders:getPreSignedURLRequest];
    [transferUtilityUploadTask.expression assignRequestParameters:getPreSignedURLRequest];
    
    return [[self.preSignedURLBuilder getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(AWSTask *task) {
        NSURL *presignedURL = task.result;
        NSError *error = task.error;
        if ( error ) {
            AWSDDLogError(@"Error: %@", error);
            return [AWSTask taskWithError:error];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        request.HTTPMethod = @"PUT";
        
        [request setValue:self.configuration.userAgent forHTTPHeaderField:@"User-Agent"];
        
        for (NSString *key in transferUtilityUploadTask.expression.requestHeaders) {
            [request setValue: transferUtilityUploadTask.expression.requestHeaders[key] forHTTPHeaderField:key];
        }
        AWSDDLogDebug(@"Request headers:\n%@", request.allHTTPHeaderFields);
        NSURLSessionUploadTask *uploadTask = [self getURLSessionUploadTaskWithRequest:request
                                                                             fromFile:[NSURL fileURLWithPath:transferUtilityUploadTask.file]
                                                                                error:&error];
        
        if (uploadTask == nil) {
            AWSDDLogError(@"Error: %@", error);
            return [AWSTask taskWithError:error];
        }
        
        transferUtilityUploadTask.sessionTask = uploadTask;
        if ( startTransfer) {
            transferUtilityUploadTask.status = AWSS3TransferUtilityTransferStatusInProgress;
        }
        else {
            transferUtilityUploadTask.status = AWSS3TransferUtilityTransferStatusPaused;
        }
        
        AWSDDLogDebug(@"Setting taskIdentifier to %@", @(transferUtilityUploadTask.sessionTask.taskIdentifier));
        
        //Add to task Dictionary
        [self.taskDictionary setObject:transferUtilityUploadTask forKey:@(transferUtilityUploadTask.sessionTask.taskIdentifier) ];
        
        //Update Database
        [AWSS3TransferUtilityDatabaseHelper updateTransferRequestInDB:transferUtilityUploadTask.transferID
                                                           partNumber:[NSNumber numberWithInt:0]
                                                       taskIdentifier:transferUtilityUploadTask.sessionTask.taskIdentifier
                                                                 eTag:@""
                                                               status:transferUtilityUploadTask.status
                                                          retry_count:transferUtilityUploadTask.retryCount
                                                        databaseQueue:self->_databaseQueue];
        if (startTransfer) {
            [uploadTask resume];
        }
        
        return [AWSTask taskWithResult:transferUtilityUploadTask];
    }];
}


#pragma mark - Download methods

- (AWSTask *)downloadDataFromBucket:(NSString *)bucket
                                key:(NSString *)key
                         expression:(AWSS3TransferUtilityDownloadExpression *)expression
                   completionHander:(AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    
    AWSS3TransferUtilityDownloadCompletionHandlerBlock completionBlock = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
        
        //Downloaded completed
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        if (data) {
            // unlock the data using Bayun unlockData method
            [[BayunCore sharedInstance] unlockData:data success:^(NSData *data){
                //Data unlocking completed
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                                    code:errorCode
                                                                userInfo:nil];
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        } else {
            completionHandler(task,location,data,error);
        }
    };
    return  [self internalDownloadToURL:nil bucket:bucket key:key expression:expression completionHandler:completionBlock];
}

- (AWSTask *)downloadToURL:(NSURL *)fileURL
                    bucket:(NSString *)bucket
                       key:(NSString *)key
                expression:(AWSS3TransferUtilityDownloadExpression *)expression
          completionHander:(AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    if (!expression) {
        expression = [AWSS3TransferUtilityDownloadExpression new];
    }
    
    AWSS3TransferUtilityDownloadCompletionHandlerBlock completionBlock = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
        
        //Downloaded completed
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        if (data) {
            // unlock the data using Bayun unlockData method
            [[BayunCore sharedInstance] unlockData:data success:^(NSData *data){
                //Data unlocking completed
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                                    code:errorCode
                                                                userInfo:nil];
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        else if(location) {
            // unlock the file using Bayun unlockFile method
            [[BayunCore sharedInstance] unlockFile:fileURL success:^{
                //File unlocking completed
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            } failure:^(BayunError errorCode){
                if (completionHandler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error = [[NSError alloc] initWithDomain:SecureAWSS3TransferUtilityErrorDomain
                                                                    code:errorCode
                                                                userInfo:nil];
                        completionHandler(task,location,data,error);
                    });
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        } else {
            completionHandler(task,location,data,error);
        }
    };
    
    return [self internalDownloadToURL:fileURL
                                bucket:bucket
                                   key:key
                            expression:expression
                     completionHandler:completionBlock];
    
}



- (AWSTask<AWSS3TransferUtilityDownloadTask *> *)internalDownloadToURL:(NSURL *)fileURL
                                                                bucket:(NSString *)bucket
                                                                   key:(NSString *)key
                                                            expression:(AWSS3TransferUtilityDownloadExpression *)expression
                                                     completionHandler:(AWSS3TransferUtilityDownloadCompletionHandlerBlock)completionHandler {
    
    //Create Expression if required and set completion Handler.
    if (!expression) {
        expression = [AWSS3TransferUtilityDownloadExpression new];
    }
    expression.completionHandler = completionHandler;
    
    //Create Download Task and set it up.
    AWSS3TransferUtilityDownloadTask *transferUtilityDownloadTask = [AWSS3TransferUtilityDownloadTask new];
    transferUtilityDownloadTask.nsURLSessionID = self.sessionIdentifier;
    transferUtilityDownloadTask.databaseQueue = self.databaseQueue;
    transferUtilityDownloadTask.transferType = @"DOWNLOAD";
    transferUtilityDownloadTask.location = fileURL;
    transferUtilityDownloadTask.bucket = bucket;
    transferUtilityDownloadTask.key = key;
    transferUtilityDownloadTask.expression = expression;
    transferUtilityDownloadTask.transferID = [[NSUUID UUID] UUIDString];
    transferUtilityDownloadTask.file = [fileURL absoluteString];
    transferUtilityDownloadTask.cancelled = NO;
    transferUtilityDownloadTask.retryCount = 0;
    transferUtilityDownloadTask.responseData = @"";
    transferUtilityDownloadTask.status = AWSS3TransferUtilityTransferStatusInProgress;
    
    //Create task in database
    [AWSS3TransferUtilityDatabaseHelper insertDownloadTransferRequestInDB:transferUtilityDownloadTask databaseQueue:self->_databaseQueue];
    
    return [self createDownloadTask:transferUtilityDownloadTask];
}

-(AWSTask<AWSS3TransferUtilityDownloadTask *> *) createDownloadTask: (AWSS3TransferUtilityDownloadTask *) transferUtilityDownloadTask {
    return [self createDownloadTask:transferUtilityDownloadTask startTransfer:YES];
}

-(AWSTask<AWSS3TransferUtilityDownloadTask *> *) createDownloadTask: (AWSS3TransferUtilityDownloadTask *) transferUtilityDownloadTask
                                                      startTransfer: (BOOL) startTransfer {
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = transferUtilityDownloadTask.bucket;
    getPreSignedURLRequest.key = transferUtilityDownloadTask.key;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodGET;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:_transferUtilityConfiguration_.timeoutIntervalForResource];
    getPreSignedURLRequest.minimumCredentialsExpirationInterval = _transferUtilityConfiguration_.timeoutIntervalForResource;
    getPreSignedURLRequest.accelerateModeEnabled = self.transferUtilityConfiguration.isAccelerateModeEnabled;
    
    [transferUtilityDownloadTask.expression assignRequestHeaders:getPreSignedURLRequest];
    [transferUtilityDownloadTask.expression assignRequestParameters:getPreSignedURLRequest];
    
    return [[self.preSignedURLBuilder getPreSignedURL:getPreSignedURLRequest] continueWithSuccessBlock:^id(AWSTask *task) {
        NSURL *presignedURL = task.result;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        request.HTTPMethod = @"GET";
        
        [request setValue:[AWSServiceConfiguration baseUserAgent] forHTTPHeaderField:@"User-Agent"];
        
        for (NSString *key in transferUtilityDownloadTask.expression.requestHeaders) {
            [request setValue:transferUtilityDownloadTask.expression.requestHeaders[key] forHTTPHeaderField:key];
        }
        
        AWSDDLogDebug(@"Request headers:\n%@", request.allHTTPHeaderFields);
        
        NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request];
        transferUtilityDownloadTask.sessionTask = downloadTask;
        if (startTransfer) {
            transferUtilityDownloadTask.status = AWSS3TransferUtilityTransferStatusInProgress;
        }
        else {
            transferUtilityDownloadTask.status = AWSS3TransferUtilityTransferStatusPaused;
        }
        AWSDDLogDebug(@"Setting taskIdentifier to %@", @(transferUtilityDownloadTask.sessionTask.taskIdentifier));
        
        //Add to taskDictionary
        [self.taskDictionary setObject:transferUtilityDownloadTask forKey:@(transferUtilityDownloadTask.sessionTask.taskIdentifier) ];
        
        //Update Database
        [AWSS3TransferUtilityDatabaseHelper updateTransferRequestInDB:transferUtilityDownloadTask.transferID
                                                           partNumber:[NSNumber numberWithInt:0]
                                                       taskIdentifier:transferUtilityDownloadTask.sessionTask.taskIdentifier
                                                                 eTag:@""
                                                               status:transferUtilityDownloadTask.status
                                                          retry_count:transferUtilityDownloadTask.retryCount
                                                        databaseQueue:self.databaseQueue];
        
        if ( startTransfer) {
            [downloadTask resume];
        }
        return [AWSTask taskWithResult:transferUtilityDownloadTask];
    }];
}

#pragma mark - Utility methods

- (void)cleanUpTemporaryDirectory {
    NSError *error = nil;
    NSArray *contentsOfDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.temporaryDirectoryPath
                                                                                       error:&error];
    if (!contentsOfDirectory) {
        NSLog(@"Failed to retrieve the contents of the tempoprary directory: %@", error);
    }
    
    // Goes through the temporary directory.
    __weak SecureAWSS3TransferUtility *weakSelf = self;
    [contentsOfDirectory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *fileName = (NSString *)obj;
        NSString *filePath = [weakSelf.temporaryDirectoryPath stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
                                                                                    error:&error];
        if (!attributes) {
            NSLog(@"Failed to load temporary file attributes: %@", error);
        }
        NSDate *fileCreationDate = [attributes objectForKey:NSFileCreationDate];
        // Removes an 'expired' temporary file.
        // Adds 60 seconds buffer to detemine if a file was 'expired'. e.g. Removes files older than 51 minutes old.
        if ([fileCreationDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970] - SecureAWSS3TransferUtilityTimeoutIntervalForResource - 60) {
            BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                                     error:&error];
            if (!result) {
                NSLog(@"Failed to remove a temporary file: %@", error);
            }
        }
    }];
}


@end

