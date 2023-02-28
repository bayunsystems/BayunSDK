//
//  SecureAuthentication.h
//  Copyright © 2023 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSCognitoIdentityProvider.h"

typedef NS_ENUM(NSInteger, SecureAuthenticationErrorType) {
  SecureAuthenticationErrorUnknown,
  SecureAuthenticationErrorFailed,
  SecureAuthenticationErrorInvalidPassword,
  SecureAuthenticationErrorPasscodeAuthenticationCanceledByUser,
  SecureAuthenticationErrorOneOrMoreIncorrectAnswers,
  SecureAuthenticationErrorInvalidPassphrase,
  SecureAuthenticationErrorInvalidAppId,
  SecureAuthenticationErrorInvalidCompanyName,
  SecureAuthenticationErrorInvalidCredentials,
  SecureAuthenticationErrorAccessDenied,
  SecureAuthenticationErrorInvalidAppSecret,
  SecureAuthenticationErrorNotSupported,
  SecureAuthenticationErrorInternetConnection,
  SecureAuthenticationErrorAppNotLinked,
  SecureAuthenticationErrorUserInActive,
  SecureAuthenticationErrorDevicePasscodeNotSet,
  SecureAuthenticationErrorSomethingWentWrong,
  SecureAuthenticationErrorNoInternetConnection,
  SecureAuthenticationErrorCouldNotConnectToServer,
  SecureAuthenticationErrorEmployeeDoesNotExists,
  SecureAuthenticationErrorEmployeeAlreadyExists,
  SecureAuthenticationErrorEmployeeAccountHasPasswordEnabled,
  SecureAuthenticationErrorUserAlreadyExists,
  SecureAuthenticationErrorLinkEmployeeUserAccount,
  SecureAuthenticationErrorUserAccountHasPasswordEnabled,
  SecureAuthenticationErrorEmployeeNotLinkedToApp,
  SecureAuthenticationErrorUserIsNotRegistered,
  SecureAuthenticationErrorEmployeeAppNotRegistered,
  SecureAuthenticationErrorEmployeeAuthorizationIsPending,
  SecureAuthenticationErrorRegistrationFailedAppNotApproved
};

@interface SecureAuthentication : NSObject

@property (nonatomic,strong) NSString *companyName;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *appId;
@property (nonatomic,strong) NSString *appSecret;
@property (nonatomic,strong) NSString *appSalt;

+ (instancetype)sharedInstance;

- (void) signUp:(AWSCognitoIdentityUserPool*)pool
       username: (NSString*)username
       password: (NSString*)password
 userAttributes: (NSArray<AWSCognitoIdentityUserAttributeType *> *)userAttributes
 validationData: (NSArray<AWSCognitoIdentityUserAttributeType *> *)validationData
registerBayunWithPwd:(BOOL)registerBayunWithPwd
      withBlock:(AWSContinuationBlock)block;

- (void)confirmSignUpForUser:(AWSCognitoIdentityUser*)user
           confirmationCode:(NSString *)confirmationCode
         forceAliasCreation:(BOOL)forceAliasCreation
                  withBlock:(AWSContinuationBlock)block;

- (void)signInPool:(AWSCognitoIdentityUserPool*)pool
         username:(NSString*)username
         password:(NSString*)password
        withBlock:(AWSContinuationBlock)block;

- (void)signOut:(AWSCognitoIdentityUser*)user;

- (void)forgotPasswordWithBlock:(AWSContinuationBlock)block;


@end
