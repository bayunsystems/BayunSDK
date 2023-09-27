//
//  BayunError.h
//  Bayun
//
//  Created by Preeti Gaur on 22/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/*!
 @typedef BayunError
 @brief Types of Bayun Error
 */
typedef NS_ENUM(NSUInteger, BayunError) {
  /**If user access is denied(authentication token expires) or if user does not have right to perform certain operation, library returns BayunErrorAccessDenied*/
  BayunErrorAccessDenied = 0,
  /**If app secret is Invalid, library returns BayunErrorInvalidAppSecret*/
  BayunErrorInvalidAppSecret,
  /**If user authentication fails, library returns BayunErrorAuthenticationFailed*/
  BayunErrorAuthenticationFailed,
  /**If user cancels the passcode authentication, library returns BayunErrorPasscodeAuthenticationCanceledByUser*/
  BayunErrorPasscodeAuthenticationCanceledByUser,
  /**If authentication needs to be done again, library returns BayunErrorReAuthenticationNeeded*/
  BayunErrorReAuthenticationNeeded,
  /**If there is no internet connectivity, library returns BayunErrorInternetConnection*/
  BayunErrorInternetConnection,
  /**If request has timed out, library returns BayunErrorRequestTimeOut*/
  BayunErrorRequestTimeOut,
  /**If Lockbox Management Server could not be reached, library returns BayunErrorCouldNotConnectToServer*/
  BayunErrorCouldNotConnectToServer,
  /**If credentails for authentication are nil, library returns BayunErrorCredentialsCannotBeNil*/
  BayunErrorCredentialsCannotBeNil,
  /**If passphrase for validation is nil, library returns BayunErrorPassphraseCannotBeNil*/
  BayunErrorPassphraseCannotBeNil,
  /**If password is nil, library returns BayunErrorPasswordCannotBeNil*/
  BayunErrorPasswordCannotBeNil,
  /**If text for encryption/decryption is nil, library returns BayunErrorTextCannotBeNil*/
  BayunErrorTextCannotBeNil,
  /**If file url for encryption/decryption is nil, library returns BayunErrorFileUrlCannotBeNil*/
  BayunErrorFileUrlCannotBeNil,
  /**If employee doesn't exists in the given company, library returns BayunErrorEmployeeNotExistsInGivenCompany*/
  BayunErrorEmployeeNotExistsInGivenCompany,
  /**If data for encryption/decryption is nil, library returns BayunErrorDataCannotBeNil*/
  BayunErrorDataCannotBeNil,
  /**If CompanyName is nil, library returns BayunErrorCompanyNameCannotBeNil*/
  BayunErrorCompanyNameCannotBeNil,
  /**If Email is nil, library returns BayunErrorEmailCannotBeNil*/
  BayunErrorEmailCannotBeNil,
  /**If company name is invalid, library returns  BayunErrorCompanyDoesNotExists*/
  BayunErrorCompanyDoesNotExists,
  /**If CompanyEmployeeId is nil, library returns BayunErrorCompanyEmployeeIdCannotBeNil*/
  BayunErrorCompanyEmployeeIdCannotBeNil,
  /**If GroupId is nil, library returns BayunErrorGroupIdCannotBeNil*/
  BayunErrorGroupIdCannotBeNil,
  /**Employee does not exists*/
  BayunErrorEmployeeDoesNotExists,
  /**If groupId does not exists for GroupId, library returns BayunErrorGroupDoesNotExistsForGroupId*/
  BayunErrorInvalidGroupId,
  /**If employee does not belong to Group, library returns BayunErrorGroupDoesNotExistsForGroupId*/
  BayunErrorEmployeeDoesNotBelongToGroup,
  /**If member  already exists in the Group, library returns BayunErrorMemberAlreadyExistsInGroup*/
  BayunErrorMemberAlreadyExistsInGroup,
  /**If member does not exists in the Group, library returns BayunErrorMemberDoesNotExistsInGroup*/
  BayunErrorMemberDoesNotExistsInGroup,
  /**If member  tries to join private in the Group, library returns BayunErrorCannotJoinPrivateGroup*/
  BayunErrorCannotJoinPrivateGroup,
  /**If encryption fails, library returns BayunErrorEncryptionFailed*/
  BayunErrorEncryptionFailed,
  /**If decryption fails, library returns BayunErrorDecryptionFailed*/
  BayunErrorDecryptionFailed,
  /**If key for encryption is not found in provided JSON, library returns BayunErrorKeyNotFoundInJSON*/
  BayunErrorKeyNotFoundInJSON,
  /**If input json is NULL, library returns BayunErrorNoInputJSON*/
  BayunErrorNoInputJSON,
  /**If input key format json is NULL, library returns BayunErrorNoInputJSON*/
  BayunErrorNoKeyFormatDictionary,
  /**If password is invalid, library returns BayunErrorInvalidPassword*/
  BayunErrorInvalidPassword,
  /**If passphrase is invalid, library returns BayunErrorInvalidPassphrase*/
  BayunErrorInvalidPassphrase,
  /**If credentials are invalid, library returns BayunErrorInvalidCredentials*/
  BayunErrorInvalidCredentials,
  /**If employee Status is Inactive, library returns BayunErrorUserInActive*/
  BayunErrorUserInActive,
  /**If app is not linked with Employee Account, library returns BayunErrorAppNotLinked*/
  BayunErrorAppNotLinked,
  /**If app id is invalid, library returns BayunErrorInvalidAppId*/
  BayunErrorInvalidAppId,
  /**If error is unknown, library returns BayunErrorSomethingWentWrong*/
  BayunErrorSomethingWentWrong,
  /**If device passcode is not set, library returns BayunErrorDevicePasscodeNotSet*/
  BayunErrorDevicePasscodeNotSet,
  /**If user answers less than Three security questions, library returns BayunErrorAtleastThreeAnswersRequired*/
  BayunErrorAtleastThreeAnswersRequired,
  /**If user has provided wrong answers for more than Two out of Five security questions, library returns BayunErrorIncorrectAnswers*/
  BayunErrorOneOrMoreIncorrectAnswers,
  /**Tried to Create Duplicate Entry **/
  BayunErrorTriedToCreateDuplicateEntry,
  /**Company with the given name already exists on LMS **/
  BayunErrorCompanyAlreadyExists,
  /**Employee with the given employeeId already exists in the company**/
  BayunErrorEmployeeAlreadyExists,
  /**Invalid Operation**/
  BayunErrorInvalidOperation,
  /**If employee public key could not be verified, library returns BayunErrorEmployeePublicKeyVerificationFailed**/
  BayunErrorEmployeePublicKeyVerificationFailed,
  /**If employee id could not be verified, library returns BayunErrorEmployeeIdVerificationFailed**/
  BayunErrorEmployeeIdVerificationFailed,
  /**If company id could not be verified, library returns BayunErrorCompanyIdVerificationFailed**/
  BayunErrorCompanyIdVerificationFailed,
  /**If company id could not be verified, library returns BayunErrorAdminPublicKeyVerificationFailed**/
  BayunErrorAdminPublicKeyVerificationFailed,
  /**If lock stream could not be configured, library returns BayunErrorConfigLockStreamFailed**/
  BayunErrorConfigLockStreamFailed,
  /**If unlock stream could not be configured, library returns BayunErrorConfigUnlockStreamFailed**/
  BayunErrorConfigUnlockStreamFailed,
  /**If group creation fails, library returns BayunErrorGroupCreationFailed**/
  BayunErrorGroupCreationFailed,
  /**If user password  is already enabled for the account being registered **/
  BayunErrorUserAccountHasPasswordEnabled,
  /**If  password  is already enabled for the account being registered without password **/
  BayunErrorEmployeeAccountHasPasswordEnabled,
  /**If signature verification fails, library returns BayunErrorOneOrMoreTextFieldsAreEmpty **/
  BayunErrorSignatureVerificationFailed,
  /**If all security questions and answers are not set, library returns BayunErrorOneOrMoreTextFieldsAreEmpty **/
  BayunErrorOneOrMoreTextFieldsAreEmpty,
  /**If group member is nil, library returns BayunErrorGroupMembersCannotBeNil **/
  BayunErrorGroupMemberCannotBeNil,
  /**If group members array is nil, library returns BayunErrorGroupMembersCannotBeNil **/
  BayunErrorGroupMembersCannotBeNil,
  /**If authorization app private key is nil**/
  BayunErrorAuthorizationAppPrivateKeyNotFound,
  /**If user is already registered**/
  BayunErrorUserAlreadyExists,
  /**Login to Admin Panel to link this User Account with the existing Employee Account to continue using the SDK APIs.*/
  BayunErrorLinkEmployeeUserAccount,
  /**Employee Account Is Not Linked to the App*/
  BayunErrorEmployeeNotLinkedToApp,
  /**No User Account to login without password*/
  BayunErrorUserIsNotRegistered,
  /**Employee App is not registered*/
  BayunErrorEmployeeAppNotRegistered,
  /**Employee Public Key Authorization Is Pending*/
  BayunErrorEmployeeAuthorizationIsPending,
  /**One or more incorrect input*/
  BayunErrorIncorrectInput,
  /**If BayunAppCredentials is nil, library returns BayunErrorBayunAppCredentialsCannotBeNil **/
  BayunErrorBayunAppCredentialsCannotBeNil,
  /**If registration is requested and application is not approved, library returns BayunErrorRegistrationFailedAppNotApproved **/
  BayunErrorRegistrationFailedAppNotApproved
};
