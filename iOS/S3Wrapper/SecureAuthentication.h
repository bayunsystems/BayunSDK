//
//  SecureAuthentication.h
//  CognitoYourUserPoolsSample
//
//  Created by Preeti Gaur on 07/09/17.
//  Copyright © 2017 Bayun Systems, Inc. All rights reserved
//

#import <Foundation/Foundation.h>
#import "AWSCognitoIdentityProvider.h"

typedef NS_ENUM(NSInteger, SecureAuthenticationErrorType) {
    SecureAuthenticationErrorUnknown,
    SecureAuthenticationErrorFailed,
    SecureAuthenticationErrorInvalidPassword,
    SecureAuthenticationErrorInvalidPassphrase,
    SecureAuthenticationErrorInvalidAppId,
    SecureAuthenticationErrorInvalidCompanyName,
    SecureAuthenticationErrorInvalidCredentials,
    SecureAuthenticationErrorAccessDenied,
    SecureAuthenticationErrorNotSupported,
    SecureAuthenticationErrorInternetConnection,
    SecureAuthenticationErrorSomethingWentWrong,
    SecureAuthenticationErrorNoInternetConnection
};

/**
 Utility for managing authentication with aws cognito along with Bayun authentication. SecureAuthentication provides a simple API for signin  and signup with aws cognito and Bayun.
 */
@interface SecureAuthentication : NSObject

@property (nonatomic,strong) NSString *companyName;
@property (nonatomic,strong) NSString *appId;

+ (instancetype)sharedInstance;

/**
 Sign up a new user
 */
- (void)signUp:(AWSCognitoIdentityUserPool*)pool
      username:(NSString*) username
      password:(NSString*) password
userAttributes:(NSArray<AWSCognitoIdentityUserAttributeType *> *) userAttributes
validationData:(NSArray<AWSCognitoIdentityUserAttributeType *> *) validationData
     withBlock:(AWSContinuationBlock)block;

/**
 Confirm a users' sign up with the confirmation code
 */
-(void)confirmSignUpForUser:(AWSCognitoIdentityUser*)user
           confirmationCode:(NSString *) confirmationCode
         forceAliasCreation:(BOOL)forceAliasCreation
                  withBlock:(AWSContinuationBlock)block;

/**
 Get a session with the following username and password
 */
-(void)signInPool:(AWSCognitoIdentityUserPool*)pool
         username:(NSString*)username
         password:(NSString*)password
        withBlock:(AWSContinuationBlock)block;

/**
 Forgot Password
 */
- (void)forgotPasswordWithBlock:(AWSContinuationBlock) block;

/**
 Remove all sessions from the keychain for this user.
 */
- (void)signout:(AWSCognitoIdentityUser*)user;

@end
