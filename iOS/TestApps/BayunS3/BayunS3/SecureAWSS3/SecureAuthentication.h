//
//  SecureAuthentication.h
//  CognitoYourUserPoolsSample
//
//  Created by Preeti Gaur on 07/09/17.
//  Copyright © 2017 Bayun Systems, Inc. All rights reserved.
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

@interface SecureAuthentication : NSObject

@property (nonatomic,strong) NSString *companyName;
@property (nonatomic,strong) NSString *appId;

+ (instancetype)sharedInstance;

- (void) signUp:(AWSCognitoIdentityUserPool*)pool
       username: (NSString*) username
       password: (NSString*) password
 userAttributes: (NSArray<AWSCognitoIdentityUserAttributeType *> *) userAttributes
 validationData: (NSArray<AWSCognitoIdentityUserAttributeType *> *) validationData
      withBlock:(AWSContinuationBlock)block;

-(void)confirmSignUpForUser:(AWSCognitoIdentityUser*)user
           confirmationCode:(NSString *) confirmationCode
         forceAliasCreation:(BOOL)forceAliasCreation
                  withBlock:(AWSContinuationBlock)block;

-(void)signInPool:(AWSCognitoIdentityUserPool*)pool
         username:(NSString*)username
         password:(NSString*)password
        withBlock:(AWSContinuationBlock)block;

- (void)forgotPasswordWithBlock:(AWSContinuationBlock) block;

@end
