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
    /**If user access is denied(authentication token expires), library returns BayunErrorAccessDenied*/
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
    /**If passcode for validation is nil, library returns BayunErrorPasscodeCannotBeNil*/
    BayunErrorPasscodeCannotBeNil,
    /**If text for encryption/decryption is nil, library returns BayunErrorTextCannotBeNil*/
    BayunErrorTextCannotBeNil,
    /**If file url for encryption/decryption is nil, library returns BayunErrorFileUrlCannotBeNil*/
    BayunErrorFileUrlCannotBeNil,
    /**If data for encryption/decryption is nil, library returns BayunErrorDataCannotBeNil*/
    BayunErrorDataCannotBeNil,
    /**If encryption fails, library returns BayunErrorEncryptionFailed*/
    BayunErrorEncryptionFailed,
    /**If decryption fails, library returns BayunErrorDecryptionFailed*/
    BayunErrorDecryptionFailed,
    /**If password is invalid, library returns BayunErrorInvalidPassword*/
    BayunErrorInvalidPassword,
    /**If passcode is invalid, library returns BayunErrorInvalidPasscode*/
    BayunErrorInvalidPasscode,
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