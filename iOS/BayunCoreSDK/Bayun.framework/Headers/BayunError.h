//
//  BayunError.h
//  Bayun
//
//  Created by Preeti Gaur on 22/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

/*!
 @typedef BayunError
 @brief Types of Bayun Error
 */
typedef NS_ENUM(NSUInteger, BayunError) {
    /**If user access is denied(authentication token expires) or if user does not have right to perform certain operation, library returns BayunErrorAccessDenied*/
    BayunErrorAccessDenied = 0,
    /**If user authentication fails, library returns BayunErrorAuthenticationFailed*/
    BayunErrorAuthenticationFailed,
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
    /**If text for encryption/decryption is nil, library returns BayunErrorTextCannotBeNil*/
    BayunErrorTextCannotBeNil,
    /**If file url for encryption/decryption is nil, library returns BayunErrorFileUrlCannotBeNil*/
    BayunErrorFileUrlCannotBeNil,
    /**If data for encryption/decryption is nil, library returns BayunErrorDataCannotBeNil*/
    BayunErrorDataCannotBeNil,
    /**If CompanyName is nil, library returns BayunErrorCompanyNameCannotBeNil*/
    BayunErrorCompanyNameCannotBeNil,
    /**If company name is invalid, library returns BayunErrorInvalidCompanyName*/
    BayunErrorInvalidCompanyName,
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
};
