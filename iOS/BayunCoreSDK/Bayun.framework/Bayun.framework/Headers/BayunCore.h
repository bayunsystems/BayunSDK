//
//  BayunCore.h
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayunError.h"
#import "LockingKeys.h"
#import "LockingKeys.h"
#import <UIKit/UIKit.h>


/*!
 @typedef BayunEmployeeStatus
 @brief Types of Employee Status
 */
typedef NS_ENUM( NSInteger, BayunEmployeeStatus) {
  /**Active employee with Admin rights.*/
  BayunEmployeeStatusAdmin = 0,
  /**Active employee*/
  BayunEmployeeStatusApproved,
  /**Inactive employee (inactivated by Admin)*/
  BayunEmployeeStatusCancelled,
  /**Registered employee but inactive, need to get approved by Admin. Cannot perform any operation.*/
  BayunEmployeeStatusRegistered,
  /**Active employee with Security Admin rights.*/
  BayunEmployeeStatusSecurityAdmin,
  /**Employee status unknown.*/
  BayunEmployeeStatusUnknown,
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
  BayunEncryptionPolicyGroup,
  BayunEncryptionPolicyGroup_Asymmetric
};

typedef NS_ENUM(NSUInteger, BayunKeyGenerationPolicy){
  /** The default policy dictated by the server is used as specified in the admin-panel settings for that company and user.*/
  BayunKeyGenerationPolicyDefault = 0,
  /** Encryption of every data object is done with same key, that is derived from the Base Key. The Base Key is determined by the Policy tied to the object being locked (e.g. CompanyKey, EmployeeKey, GroupKey).*/
  BayunKeyGenerationPolicyStatic,
  /** Every data object is encrypted with its own unique key that is randomly generated. The random key itself is kept encrypted with a key derived from the Base Key. */
  BayunKeyGenerationPolicyEnvelope,
  /** Every data object is encrypted with its own unique key, that is derived from the Base Key using a multi-dimensional chaining mechanism.*/
  BayunKeyGenerationPolicyChain,
};

typedef NS_ENUM(NSUInteger, TracingStatus) {
  /**The default tracing status is Disabled*/
  TracingStatusDefault = 0,
  /**Tracing is enabled*/
  TracingStatusEnabled,
  /**Tracing is disabled*/
  TracingStatusDisabled
};

@interface SecurityQuestion : NSObject

@property(nonatomic, strong) NSString *questionId;
@property(nonatomic, strong) NSString *questionText;
-(id)initWithId:(NSString *)questionId text:(NSString*)questionText;

@end

@interface SecurityAnswer : NSObject

@property(nonatomic, strong) NSString *questionId;
@property(nonatomic, strong) NSString *answer;
-(id)initWithQuestionId:(NSString *)questionId answer:(NSString*)answer;

@end

@interface SecurityQuestionAnswer : NSObject

@property(nonatomic, strong) NSString *question;
@property(nonatomic, strong) NSString *answer;
-(id)initWithQuestion:(NSString *)question answer:(NSString*)answer;

@end

@interface GroupMember : NSObject

@property(nonatomic, strong) NSString *companyName;
@property(nonatomic, strong) NSString *companyEmployeeId;
-(id)initWithCompanyName:(NSString *)companyName companyEmployeeId:(NSString*)companyEmployeeId;

@end

@interface AddMemberErrObject : NSObject

@property(nonatomic, strong) NSString *errorMessage;
@property(nonatomic, strong) NSArray<GroupMember*> *membersList;
-(id)initWithErrorMessage:(NSString *)errorMessage membersList:(NSArray<GroupMember*>*)membersList;

@end

@interface Group : NSObject

@property(nonatomic, strong) NSString *groupId;
@property(nonatomic, strong) NSString *groupName;
@property(nonatomic, strong) NSString *creatorCompanyName;
@property(nonatomic, strong) NSString *creatorCompanyEmployeeId;
@property(nonatomic) GroupType groupType;
@property(nonatomic, strong) NSArray<GroupMember*> *groupMembers;

@end



@interface BayunAppCredentials : NSObject

@property(nonatomic, strong, readonly) NSString* baseURL;
@property(nonatomic, strong, readonly) NSString* appId;
@property(nonatomic, strong, readonly) NSString* appSecret;
@property(nonatomic, strong, readonly) NSString* appSalt;

-(instancetype)initWithAppId:(NSString*)appId
                   appSecret:(NSString*)appSecret
                     appSalt:(NSString*)appSalt
                     baseURL:(NSString*)baseURL;
@end

@interface BayunCoreConfiguration : NSObject

@property(nonatomic, assign, readonly) TracingStatus tracingStatus;

-(instancetype)initWithTracingStatus:(TracingStatus)tracingStatus;

@end

/**
 Provides methods to perform encryption and decryption of texts, files, NSData.
 It also provides methods to Authenticate with Bayun Lockbox Management Server, Validate passphrase
 and Logout.
 */
@interface BayunCore : NSObject

/**
 @See BayunEmployeeStatus.
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

/**
 Configure BayunCore with BayunCoreConfiguration
 @param configuration BayunCoreConfiguration
 */
-(void)configure:(BayunCoreConfiguration*)configuration;

/*!
 Register with CompanyName, CompanyEmployeeId and Password.
 @param companyName companyName.
 @param companyEmployeeId companyEmployeeId.
 @param password password.
 @param bayunAppCredentials BayunAppCredentials instance initialized with AppId, AppSecret and Salt.
 @param authorizeEmployee Block to be executed if employee public key authorization is pending, returns employeePublicKey
 @param success Success block to be executed after successful registration.
 @param failure Failure block to be executed if registration fails, returns BayunError.
 
 @see BayunError
 */
-(void)registerWithCompanyName:(NSString *)companyName
              uiViewController:(UIViewController *)uiViewController
             companyEmployeeId:(NSString *)companyEmployeeId
                      password:(NSString *)password
           bayunAppCredentials:(BayunAppCredentials*)credentials
     authorizeEmployeeCallback:(void (^)(NSString*))authorizeEmployee
                       success:(void (^)(void))success
                       failure:(void (^)(BayunError))failure;

/*!
 Register with CompanyName, CompanyEmployeeId and Email.
 @param companyName companyName.
 @param companyEmployeeId companyEmployeeId.
 @param email email.
 @param bayunAppCredentials BayunAppCredentials instance initialized with appId, appSecret and appSalt.
 @param authorizeEmployee Block to be executed if employee public key authorization is pending, returns employeePublicKey
 @param success Success block to be executed after successful registration.
 @param failure Failure block to be executed if registration fails, returns BayunError.
 
 @see BayunError
 */
-(void)registerWithCompanyName:(NSString *)companyName
              uiViewController:(UIViewController *)uiViewController
             companyEmployeeId:(NSString *)companyEmployeeId
                         email:(NSString *)email
           isCompanyOwnedEmail:(BOOL)isCompanyOwnedEmail
           bayunAppCredentials:(BayunAppCredentials*)credentials
    newUserCredentialsCallback:(void (^)(void))newUserCredentialsCallback
     securityQuestionsCallback:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsCallback
            passphraseCallback:(void (^)(void))passphraseCallback
     authorizeEmployeeCallback:(void (^)(NSString*))authorizeEmployeeCallback
                       success:(void (^)(void))success
                       failure:(void (^)(BayunError))failure;

/*!
 Login with CompanyName, CompanyEmployeeId and Password.
 @param companyName companyName.
 @param companyEmployeeId companyEmployeeId.
 @param password password.
 @param autoCreateEmployee Boolean Determines whether or not an employee should be created on LMS
 if not exists in the given company.
 @param securityQuestions Optional block if 2-FA is enabled. Provide custom UI block to take
 user security question answers and call validateSecurityQuestions method to validate the answers.
 If nil, default Bayun AlertView is displayed to take user answers to the security questions.
 @param passphrase Optional block if passphrase is enabled. Provide custom UI block to take
 user passphrase and call validatePassphrase method to validate the user passphrase.
 If nil, default Bayun AlertView is displayed to take user passphrase.
 @param bayunAppCredentials BayunAppCredentials instance initialized with appId, appSecret and appSalt.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if login fails, returns BayunError.
 
 @see BayunError
 */
-(void)loginWithCompanyName:(NSString *)companyName
           uiViewController:(UIViewController *)uiViewController
          companyEmployeeId:(NSString *)companyEmployeeId
                   password:(NSString *)password
         autoCreateEmployee:(BOOL)autoCreateEmployee
  securityQuestionsCallback:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
         passphraseCallback:(void(^)(void))passphraseBlock
        bayunAppCredentials:(BayunAppCredentials*)credentials
                    success:(void (^)(void))success
                    failure:(void (^)(BayunError))failure;

/*!
 Login with CompanyName, CompanyEmployeeId, Email.
 @param companyName companyName.
 @param companyEmployeeId companyEmployeeId.
 @param email email.
 @param securityQuestions Optional block. Provide custom UI block to take
 user security question answers and call validateSecurityQuestions method to validate the answers.
 If nil, default Bayun AlertView is displayed to take user answers to the security questions.
 @param passphrase Optional block if passphrase is enabled. Provide custom UI block to take
 user passphrase and call validatePassphrase method to validate the user passphrase.
 If nil, default Bayun AlertView is displayed to take user passphrase.
 @param bayunAppCredentials BayunAppCredentials instance initialized with AppId, AppSecret and Salt.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if login fails, returns BayunError.
 
 @see BayunError
 */
-(void)loginWithCompanyName:(NSString*)companyName
           uiViewController:(UIViewController *)uiViewController
          companyEmployeeId:(NSString *)companyEmployeeId
  securityQuestionsCallback:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
         passphraseCallback:(void(^)(void))passphraseBlock
        bayunAppCredentials:(BayunAppCredentials*)credentials
                    success:(void (^)(void))success
                    failure:(void (^)(BayunError))failure;

/*!
 Sets Security Questions & Answers for a new user being created,
 as well as an optional Passphrase. By default, the SDK uses
 AlertView to take User’s input to set Security Questions & Answers, Passphrase.
 The developer can optionally provide a custom UI block i.e newUserCredentialsCallback in registerWithCompanyName:companyEmployeeId:email:isCompanyOwnedEmail:bayunAppCredentials:
 newUserCredentialsCallback:securityQuestionsCallback:passphraseCallback:authorizeEmployeeCallback:success:failure:
 method for taking User’s input, to match with the look-and-feel of the app, instead of relying on the default alert-view.
 @param securityQuestions An array of five SecurityQuestionAnswer objects to be set.
 @param passphrase Optional, if passphrase is to be enabled.
 @param authorizeEmployeeCallback Block to be executed if employee public key authorization is pending, returns employeePublicKey.
 @param success Success block to be executed if credentials are set successfully.
 @param failure Failure block to be executed if credentials could not be set, returns BayunError.
 
 */
-(void)setNewUserCredentials:(NSArray<SecurityQuestionAnswer*>*)securityQuestions
                  passphrase:(NSString *)passphrase
   authorizeEmployeeCallback:(void (^)(NSString*))authorizeEmployee
                     success:(void (^)(void))success
                     failure:(void (^)(BayunError))failure;

/*!
 Validates user passphrase with Lockbox Management Server.
 @param passphrase User passphrase
 @param success Success block to be executed after passphrase is successfully verified.
 @param failure Failure block to be executed if validate passphrase fails, returns BayunError.
 @see BayunError
 */
- (void)validatePassphrase:(NSString*)passphrase
 authorizeEmployeeCallback:(void (^)(NSString*))authorizeEmployee
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure;

/*!
 Validates security questions with Lockbox Management Server.
 @param parameters An array of SecurityAnswer object.
 @param success Success block to be executed after security questions are successfully verified.
 @param failure Failure block to be executed if validate security questions fails, returns BayunError.
 
 @see BayunError
 */
- (void)validateSecurityQuestions:(NSArray<SecurityAnswer*>*)answers
        authorizeEmployeeCallback:(void (^)(NSString*))authorizeEmployee
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
 Returns locking key along with keys for signature generation and signature verification for an encryption policy.
 @param encryptionPolicy BayunEncryptionPolicy determines the key to be used to generate the lockingKey.
 @param keyGenerationPolicy BayunKeyGenerationPolicy determines the policy to be used to generate the lockingKey.
 @param groupId  GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 If encryption-policy is other than BayunEncryptionPolicyGroup then groupId should be empty string.
 
 @see BayunError
 */
- (void) getLockingKeyFor:(BayunEncryptionPolicy)encryptionPolicy
      keyGenerationPolicy:(BayunKeyGenerationPolicy)keyGenerationPolicy
                  groupId:(NSString*)groupId
                  success:(void (^)(LockingKeys*))success
                  failure:(void (^)(BayunError))failure;

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
 @param encryptionPolicy  BayunEncryptionPolicy determines the key for locking.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after file is successfully locked.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 @see BayunError
 */
- (void)lockFile:(NSURL*)fileURL
encryptionPolicy:(BayunEncryptionPolicy)policy
keyGenerationPolicy:(BayunKeyGenerationPolicy)keyGenerationPolicy
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
 @param encryptionPolicy  BayunEncryptionPolicy determines the key for locking.
 @param keyGenerationPolicy  BayunKeyGenerationPolicy determines the policy to generate encryption key.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after text is successfully locked, returns locked text.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockText:(NSString*)text
encryptionPolicy:(BayunEncryptionPolicy)policy
keyGenerationPolicy:(BayunKeyGenerationPolicy)encryptionPolicy
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
 @param encryptionPolicy  BayunEncryptionPolicy determines the key for locking.
 @param keyGenerationPolicy  BayunKeyGenerationPolicy determines the policy to generate encryption key.
 @param groupId GroupId is required if encryptionPolicy is BayunEncryptionPolicyGroup.
 @param success Success block to be executed after data is successfully locked, returns locked data.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)lockData:(NSData*)data
encryptionPolicy:(BayunEncryptionPolicy)policy
keyGenerationPolicy:(BayunKeyGenerationPolicy)keyGenerationPolicy
         groupId:(NSString*)groupId
         success:(void (^)(NSData*))success
         failure:(void (^)(BayunError))failure;

/*!
 Configures a stream locking operation and returns metadata as a string in the success callback which is used to configure
 a stream unlocking operation in 'configUnlockStream:' method.
 'configLockStream:' method should be called once before locking data in a stream using 'lockStream:'
 @param streamId   StreamId uniquely identifies a stream
 @param encryptionPolicy  BayunEncryptionPolicy determines the key for locking.
 @param keyGenerationPolicy  BayunKeyGenerationPolicy determines the policy to generate encryption key.
 @param success Success block to be executed after the configuration, returns  metadata.
 @param failure Failure block to be executed if configuration fails, returns BayunError.
 
 @see BayunError
 */
- (void)configLockStream:(NSString*)streamId
        encryptionPolicy:(BayunEncryptionPolicy)encryptinPolicy
     keyGenerationPolicy:(BayunKeyGenerationPolicy)kgp
                 success:(void(^)(NSString*))success
                 failure:(void(^)(BayunError))failure;

/*!
 Locks a stream data.
 @param streamId   StreamId uniquely identifies a stream
 @param data    NSData to be locked.
 @param success Success block to be executed after data is successfully locked, returns locked data.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
-(void)lockStream:(NSString*)streamId
             data:(NSData*)data
          success:(void (^)(NSData*))success
          failure:(void (^)(BayunError))failure;
/*!
 Configures a stream unlocking operation.
 'configUnlockStream:' method should be called once before unlocking data in a stream using 'unlockStream:'
 @param metadata  metadata which is returned in 'configLockStream:' method success callback.
 @param success Success block to be executed after the configuration.
 @param failure Failure block to be executed if configuration fails, returns BayunError.
 
 @see BayunError
 */
- (void)configUnlockStream:(NSString*)metadata
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure;

/*!
 Unlocks a stream data.
 @param streamId   StreamId uniquely identifies a stream
 @param data    NSData to be unlocked.
 @param success Success block to be executed after data is successfully unlocked, returns unlocked data.
 @param failure Failure block to be executed if unlocking fails, returns BayunError.
 
 @see BayunError
 */
-(void)unlockStream:(NSString*)streamId
               data:(NSData*)data
            success:(void (^)(NSData*))success
            failure:(void (^)(BayunError))failure;

/*!
 Locks values of defined keys in Json.
 @param json NSDictionary to be locked. Values of keys are locked.
 @param keysFormatDictionary NSDictionary determines the format of the keys for locking.
 Format of keys need to be defined here e.g. @{@"keyName" : @"keyFormat"}. The format can be String, Number, Email.
 @param success Success block to be executed after json is successfully locked, returns json having locked values.
 @param failure Failure block to be executed if locking fails, returns BayunError.
 
 @see BayunError
 */
- (void)encryptJson:(NSDictionary*)json
         keysFormat:(NSDictionary*)keysFormatDictionary
            success:(void (^)(NSDictionary*))success
            failure:(void (^)(BayunError))failure;


/*!
 Unlocks values of defined keys in Json.
 @param json NSDictionary to be unlocked. Values of keys are unlocked.
 @param keysFormatDictionary NSDictionary determines the format of the keys for unlocking.
 Format of keys need to be defined here e.g. @{@"keyName" : @"keyFormat"}.
 The format can be String, Number, Email.
 @param success Success block to be executed after json is successfully unlocked, returns json having unlocked values.
 @param failure Failure block to be executed if unlocking fails, returns BayunError.
 
 @see BayunError
 */
- (void)decryptJson:(NSDictionary*)json
         keysFormat:(NSDictionary*)keysFormatDictionary
            success:(void (^)(NSDictionary*))success
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
 Returns GroupId of the group created.
 @param failure Failure block to be executed if group creation fails, returns BayunError.
 
 @see BayunError
 */
- (void)createGroup:(NSString*)name
          groupType:(GroupType)type
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;

/*!
 Join Public Group.
 @param groupId Group Id of Public Group.
 @param creatorCompanyName Company name of the group creator.
 @param creatorCompanyEmployeeId Company Employee Id of the group creator.
 @param success Success block to be executed after group is successfully joined.
 @param failure Failure block to be executed if group could not be joined, returns BayunError.
 
 @see BayunError
 */
- (void)joinPublicGroup:(NSString*)groupId
     creatorCompanyName:(NSString*)creatorCompanyName
creatorCompanyEmployeeId:(NSString*)creatorCompanyEmployeeId
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/*!
 Returns Employee Groups(id, name, type).
 @param success Success block to be executed after employee groups are successfully retrieved.
 @param failure Failure block to be executed if employee groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getMyGroups:(void (^)(NSArray<Group*>*))success
            failure:(void (^)(BayunError))failure;


/*!
 Returns Public Groups that Employee has not joined.
 @param success Success block to be executed after public groups are successfully retrieved.
 @param failure Failure block to be executed if public groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getUnjoinedPublicGroups:(void (^)(NSArray<Group*>*))success
                        failure:(void (^)(BayunError))failure;


/*!
 Returns Employee's Group Details. Details include groupId, name,type, groupMembers.
 @param groupId Group Id of the Group.
 @param success Success block to be executed after employee groups are successfully retrieved.
 @param failure Failure block to be executed if employee groups could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getGroupById:(NSString*)groupId
             success:(void (^)(Group*))success
             failure:(void (^)(BayunError))failure;

/*!
 Adds Member to the Group.
 @param groupId GroupId of the group.
 @param groupMember GroupMember with companyName and companyEmployeeId.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if user authentication fails, returns BayunError.
 
 @see BayunError
 */
- (void)addInGroup:(NSString*)groupId
       groupMember:(GroupMember*)groupMember
           success:(void (^)(NSArray<AddMemberErrObject*>*, NSString*))success
           failure:(void (^)(BayunError))failure;

/*!
 Adds Multiple Member to the Group.
 @param groupId GroupId of the group.
 @param groupMembers NSArray of GroupMember.
 @param success Success block to be executed after successful user authentication.
 @param failure Failure block to be executed if user authentication fails, returns BayunError.
 @see BayunError
 */
- (void)addInGroup:(NSString*)groupId
      groupMembers:(NSArray<GroupMember*>*)groupMembers
           success:(void (^)(NSArray<AddMemberErrObject*>*, NSString*))success
           failure:(void (^)(BayunError))failure;

/*!
 Removes Member from the Group.
 @param groupMember NSDictionary mapping groupId, companyEmployeeId, companyName.
 @param success Success block to be executed after member is removed from the group successfully.
 @param failure Failure block to be executed if member cannot be removed, returns BayunError.
 
 @see BayunError
 */
- (void)removeFromGroup:(NSString*)groupId
            groupMember:(GroupMember*)groupMember
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/*!
 Removes list of members from the Group.
 @param groupId GroupId of the group.
 @param groupMembers NSArray of GroupMember.
 @param success Success block to be executed after members are removed from the group successfully.
 @param failure Failure block to be executed if member cannot be removed, returns BayunError.
 
 @see BayunError
 */
- (void)removeFromGroup:(NSString*)groupId
           groupMembers:(NSArray<GroupMember*>*)groupMembers
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/*!
 Removes Member from the Group except the list of group members. Calling member is not removed from the group.
 For the calling member to be removed from the group, use leaveGroup API.
 @param groupId GroupId of the group.
 @param groupMembers NSArray of GroupMember.
 @param removeCallingMember Boolean determines whether or not remove the calling member from the group.
 @param success Success block to be executed after members are removed from the group successfully.
 @param failure Failure block to be executed if member cannot be removed, returns BayunError.
 
 @see BayunError
 */
- (void)removeFromGroup:(NSString*)groupId
             exceptList:(NSArray<GroupMember*>*)groupMembers
    removeCallingMember:(BOOL)removeCallingMember
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/*!
 Leave a Group.
 @param groupId GroupId of the group member want to leave.
 @param success Success block to be executed after group is left.
 @param failure Failure block to be executed if group cannot be left, returns BayunError.
 
 @see BayunError
 */
- (void)leaveGroup:(NSString*)groupId
           success:(void (^)(void))success
           failure:(void (^)(BayunError))failure;

/*!
 Deletes Group.
 @param groupId GroupId of the group to be deleted.
 @param success Success block to be executed after group is successfully deleted.
 @param failure Failure block to be executed if group deletion fails, returns BayunError.
 
 @see BayunError
 */
- (void)deleteGroup:(NSString*)groupId
            success:(void (^)(void))success
            failure:(void (^)(BayunError))failure;

/*!
 Logs out user and stops background Bayun services.
 */
- (void)logout;


@end
