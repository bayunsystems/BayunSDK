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
    /**Employee status unknown.*/
    BayunEmployeeStatusUnknown = 0,
    /**Active employee with Admin rights. Can perform all operations.*/
    BayunEmployeeStatusAdmin,
    /**Registered employee but inactive, need to get approved by Admin. Cannot perform any operation.*/
    BayunEmployeeStatusRegistered,
    /**Active employee*/
    BayunEmployeeStatusApproved,
    /**Inactive employee (inactivated by Admin)*/
    BayunEmployeeStatusCancelled,
};


/**
 Provides methods to perform encryption and decryption of texts, files, NSData.
 It also provides methods to Authenticate with Bayun Lockbox Management Server, Validate passcode
 and Logout.
 */
@interface BayunCore : NSObject

/**
 Status of employee e.g. BayunEmployeeStatusAdmin, BayunEmployeeStatusRegistered, BayunEmployeeStatusApproved, 
 BayunEmployeeStatusCancelled or BayunEmployeeStatusUnknown.
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
 Authenticate user with Lockbox Management Server.
 @param credentials NSDictionary mapping companyName, companyEmployeeId, password, appId.
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
 Validates user passcode with Lockbox Management Server.
 @param passcode User passcode
 @param success Success block to be executed after passcode is successfully verified.
 @param failure Failure block to be executed if set passcode fails, returns BayunError.
 
 @see BayunError
 */
- (void)validatePasscode:(NSString*)passcode
                 success:(void (^)(void))success
                 failure:(void (^)(BayunError))failure;

/*!
 Updates user password on Lockbox Management Server.
 @param currentPassword User Current Password
 @param newPassword User New Password
 @param success Success block to be executed after password is successfully updated.
 @param failure Failure block to be executed if update password fails, returns BayunError.
 
 @see BayunError
 */
- (void)changePassword:(NSString*)currentPassword
           newPassword:(NSString*) newPassword
               success:(void (^)(void))success
               failure:(void (^)(BayunError))failure;

/**
 Returns BOOL value for employee active state.
 */
- (BOOL)isEmployeeActive;

/*!
 Locks file. The file at the given file path is overwritten with the locked file.
 @param filePath Path of the file to be locked.
 @param success Success block to be executed after file is successfully locked.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockFile:(NSURL*)fileURL
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure;


/*!
 Locks file. The file at the given file path is overwritten with the unlocked file.
 @param filePath Path of the file to be unlocked.
 @param success Success block to be executed after file is successfully unlocked.
 @param failure Failure block to be executed if unlocking fails, returns BayunError.
 
 @see BayunError
 */
- (void)unlockFile:(NSURL*)fileURL
            success:(void (^)(void))success
            failure:(void (^)(BayunError))failure;


/*!
 Locks text.
 @param text Text to be locked.
 @param success Success block to be executed after text is successfully locked, returns locked text.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockText:(NSString*)text
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;

/*!
 Locks text
 @param text Text to be unlocked.
 @param success Success block to be executed after text is successfully unlocked, returns unlocked text.
 @param failure Failure block to be executed if unlocking fails, returns BayunError.
 
 @see BayunError
 */
- (void)unlockText:(NSString*)text
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;


/*!
 Locks NSData.
 @param data NSData to be locked.
 @param success Success block to be executed after data is successfully locked, returns locked data.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockData:(NSData*)data
            success:(void (^)(NSData*))success
            failure:(void (^)(BayunError))failure;

/*!
 Locks NSData.
 @param data NSData to be unlocked.
 @param success Success block to be executed after data is successfully unlocked, returns unlocked data.
 @param failure Failure block to be executed if unlocking fails, returns BayunError.
 
 @see BayunError
 */
- (void)unlockData:(NSData*)data
            success:(void (^)(NSData*))success
            failure:(void (^)(BayunError))failure;

/*!
 Logs out user and stops background Bayun services.
 */
- (void)deauthenticate;


@end
