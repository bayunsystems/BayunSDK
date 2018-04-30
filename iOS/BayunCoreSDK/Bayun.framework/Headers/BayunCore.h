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

/*!
 @typedef GroupType
 @brief Types of Group
 */
typedef NS_ENUM( NSInteger, GroupType) {
    /**Group Type Public.*/
    GroupTypePublic = 0,
    /**Group Type Private.*/
    GroupTypePrivate
};

/*!
 @typedef BayunEncryptionPolicy
 @brief Types of Encryption Policy
 */
typedef NS_ENUM(NSUInteger, BayunEncryptionPolicy){
    /**Encryption policy is None, encryption/decryption is not performed.*/
    BayunEncryptionPolicyNone = 0,
    /**Encryption policy is Default, encryption/decryption is performed using policy set on Admin Panel.*/
    BayunEncryptionPolicyDefault,
    /**Encryption policy is Company, encryption/decryption is performed using company key.*/
    BayunEncryptionPolicyCompany,
    /**Encryption policy is Employee, encryption/decryption is performed using employee key.*/
    BayunEncryptionPolicyEmployee,
    /**Encryption policy is Group, encryption/decryption is performed using group key.*/
    BayunEncryptionPolicyGroup
};


/**
 Provides methods to perform encryption and decryption of texts, files, NSData.
 It also provides methods to Authenticate with Bayun Lockbox Management Server, Validate passphrase
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
 @param passphrase Optional block if passphrase is enabled. Provide custom UI block to take
 user passphrase and call validatePassphrase method to validate the user passphrase.
 If nil, default Bayun AlertView is displayed to take user passphrase.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if user authentication fails, returns BayunError.
 
 @see BayunError
 */
- (void)authenticateWithCredentials:(NSDictionary *)credentials
                           passphrase:(void (^) (void))passphrase
                            success:(void (^)(void))success
                            failure:(void (^)(BayunError))failure;

/*!
 Validates user passphrase with Lockbox Management Server.
 @param passphrase User passphrase
 @param success Success block to be executed after passphrase is successfully verified.
 @param failure Failure block to be executed if set passphrase fails, returns BayunError.
 
 @see BayunError
 */
- (void)validatePassphrase:(NSString*)passphrase
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
 @param fileURL URL of the file to be locked.
 @param success Success block to be executed after file is successfully locked.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockFile:(NSURL*)fileURL
         success:(void (^)(void))success
         failure:(void (^)(BayunError))failure;

/*!
 Locks file. The file at the given file path is overwritten with the locked file.
 @param fileURL URL of the file to be locked.
 @param policy  BayunEncryptionPolicy determines the key for locking.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after file is successfully locked.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockFile:(NSURL*)fileURL
encryptionPolicy:(BayunEncryptionPolicy)policy
         groupId:(NSString*)groupId
         success:(void (^)(void))success
         failure:(void (^)(BayunError))failure;


/*!
 Locks file. The file at the given file path is overwritten with the unlocked file.
 @param fileURL URL of the file to be unlocked.
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
 Locks text.
 @param text Text to be locked.
 @param policy  BayunEncryptionPolicy determines the key for locking.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after text is successfully locked, returns locked text.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockText:(NSString*)text
encryptionPolicy:(BayunEncryptionPolicy)policy
         groupId:(NSString*)groupId
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
 @param data    NSData to be locked.
 @param policy  BayunEncryptionPolicy determines the key for locking.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after data is successfully locked, returns locked data.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockData:(NSData*)data
encryptionPolicy:(BayunEncryptionPolicy)policy
         groupId:(NSString*)groupId
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
 Creates Group.
 @param name Group name(Optional).
 @param type Group type. Group can either Public or Private type.
 @param success Success block to be executed after group is successfully created.
 @param failure Failure block to be executed if group creation fails, returns BayunError.
 
 @see BayunError
 */
- (void)createGroupWithName:(NSString*)name
                  groupType:(GroupType)type
                    success:(void (^)(void))success
                    failure:(void (^)(BayunError))failure;



/*!
 Join Public Group.
 @param groupId Group Id of Public Group.
 @param success Success block to be executed after group is successfully joined.
 @param failure Failure block to be executed if group could not be joined, returns BayunError.
 
 @see BayunError
 */
- (void)joinPublicGroup:(NSString*)groupId
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/*!
 Returns Employee Groups(id, name, type).
 @param success Success block to be executed after employee groups are successfully retrieved.
 @param failure Failure block to be executed if employee groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getMyGroups:(void (^)(NSArray*))success
             failure:(void (^)(BayunError))failure;


/*!
 Returns Public Groups that Employee has not joined.
 @param success Success block to be executed after public groups are successfully retrieved.
 @param failure Failure block to be executed if public groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getUnjoinedPublicGroups:(void (^)(NSArray*))success
                         failure:(void (^)(BayunError))failure;


/*!
 Returns Employee's Group Details. Details include groupId, name,type, groupMembers.
 @param groupId Group Id of the Group.
 @param success Success block to be executed after employee groups are successfully retrieved.
 @param failure Failure block to be executed if employee groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getGroupById:(NSString*)groupId
             success:(void (^)(NSDictionary*))success
             failure:(void (^)(BayunError))failure;

/*!
 Adds Member to the Group.
 @param parameters NSDictionary mapping groupId, companyEmployeeId, companyName.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if user authentication fails, returns BayunError.
 
 @see BayunError
 */
- (void)addGroupMember:(NSDictionary*)parameters success:(void (^)(void))success failure:(void (^)(BayunError))failure;


/*!
 Removes Member from the Group.
 @param parameters NSDictionary mapping groupId, companyEmployeeId, companyName.
 @param success Success block to be executed after member is removed from the group successfully.
 @param failure Failure block to be executed if member cannot be removed, returns BayunError.
 
 @see BayunError
 */
- (void)removeGroupMember:(NSDictionary*)parameters success:(void (^)(void))success failure:(void (^)(BayunError))failure;

/*!
 Leave a Group.
 @param groupId GroupId of the group member want to leave.
 @param success Success block to be executed after group is left.
 @param failure Failure block to be executed if group cannot be left, returns BayunError.
 
 @see BayunError
 */
- (void)leaveGroup:(NSString*)groupId success:(void (^)(void))success failure:(void (^)(BayunError))failure;

/*!
 Deletes Group.
 @param groupId GroupId of the group to be deleted.
 @param success Success block to be executed after group is successfully deleted.
 @param failure Failure block to be executed if group deletion fails, returns BayunError.
 
 @see BayunError
 */
- (void)deleteGroup:(NSString*)groupId success:(void (^)(void))success failure:(void (^)(BayunError))failure;

/*!
 Logs out user and stops background Bayun services.
 */
- (void)deauthenticate;


@end
