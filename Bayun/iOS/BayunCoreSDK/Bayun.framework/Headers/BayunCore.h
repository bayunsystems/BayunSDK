//
//  BayunCore.h
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayunError.h"

/*!
 @typedef BayunEmployeeStatus
 @brief Types of Employee Status
 */
typedef NS_ENUM( NSInteger, BayunEmployeeStatus) {
    BayunEmployeeStatusUnknown = 0,
    BayunEmployeeStatusAdmin,
    BayunEmployeeStatusRegistered,
    BayunEmployeeStatusApproved,
    BayunEmployeeStatusPromoted,
    BayunEmployeeStatusCancelled,
};


/**
 Provides methods to perform encryption and decryption of texts, files, NSData.
 It also provides methods to Authenticate with Bayun Key Management Server, Validate passcode
 and Logout.
 */
@interface BayunCore : NSObject

/**
 Status of employee e.g. Admin, Registered, Approved, Promoted, Cancelled or Unknown.
 */
@property (nonatomic) BayunEmployeeStatus employeeStatus;


/**
 Returns singleton service client.
 
 Call the following to get the default service client:
 
 *Objective-C*
 BayunCore *BayunCore = [BayunCore sharedInstance];
 
 @return Default service client.
 */
+ (instancetype)sharedInstance;

/*!
 Authenticate user with Key Management Server.
 @param credentials NSDictionary mapping companyName, employeeId, password, appId, appName.
 @param passcode Optional block if passcode is enabled. Provide custom UI block to take
 user passcode and call validatePasscode method to validate the user passcode.
 If nil, default Bayun AlertView is displayed to take user passcode.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if user authentication fails, returns BayunError.
 
 @see BayunError
 */
- (void)authenticateWithCredentials:(NSDictionary *)credentials
                           passcode:(void (^) (void))passcode
                            success:(void (^)(void))success
                            failure:(void (^)(BayunError))failure;

/*!
 Validates user passcode with Key Management Server.
 @param passcode User passcode
 @param success Success block to be executed after passcode is successfully verified.
 @param failure Failure block to be executed if set passcode fails, returns BayunError.
 
 @see BayunError
 */
- (void)validatePasscode:(NSString*)passcode
                 success:(void (^)(void))success
                 failure:(void (^)(BayunError))failure;

/*!
 Encrypts file. The file at the given file path is overwritten with the encrypted file.
 @param filePath Path of the file to be encrypted.
 @param success Success block to be executed after successful file encryption.
 @param failure Failure block to be executed if encryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)encryptFileAtPath:(NSString*)filePath
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure;

/*!
 Decrypts file. The file at the given file path is overwritten with the decrypted file.
 @param filePath Path of the file to be decrypted.
 @param success Success block to be executed after successful file decryption.
 @param failure Failure block to be executed if decryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)decryptFileAtPath:(NSString*)filePath
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure;

/*!
 Encrypts text.
 @param text Text to be encrypted.
 @param success Success block to be executed after successful text encryption, returns encrypted text.
 @param failure Failure block to be executed if encryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)encryptText:(NSString*)text
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;

/*!
 Decrypts text
 @param text Text to be decrypted.
 @param success Success block to be executed after successful text decryption, returns decrypted text.
 @param failure Failure block to be executed if decryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)decryptText:(NSString*)text
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;

/*!
 Encrypts NSData.
 @param data NSdata to be encrypted.
 @param success Success block to be executed after successful data encryption, returns encrypted data.
 @param failure Failure block to be executed if encryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)encryptData:(NSData*)data
            success:(void (^)(NSData*))success
            failure:(void (^)(BayunError))failure;

/*!
 Decrypts NSData.
 @param data NSdata to be decrypted.
 @param success Success block to be executed after successful data decryption, returns decrypted data.
 @param failure Failure block to be executed if decryption fails, returns BayunError.
 
 @see BayunError
 */
- (void)decryptData:(NSData*)data
            success:(void (^)(NSData*))success
            failure:(void (^)(BayunError))failure;

/*!
 Logs out user and stops background Bayun services.
 */
- (void)logoutBayun;


@end
