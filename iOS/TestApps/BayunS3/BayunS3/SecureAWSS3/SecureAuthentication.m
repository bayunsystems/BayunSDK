//
//  SecureAuthentication.m
//  CognitoYourUserPoolsSample
//
//  Created by Preeti Gaur on 07/09/17.
//  Copyright © 2017 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAuthentication.h"
#import <Bayun/BayunCore.h>

NSString *const SecureAuthenticationErrorDomain = @"com.bayun.SecureAuthenticationErrorDomain";

@interface SecureAuthentication()

@property (strong,nonatomic) NSString *userPassword;

@end

@implementation SecureAuthentication

+ (instancetype)sharedInstance {
    static SecureAuthentication *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)signUp:(AWSCognitoIdentityUserPool*)pool
      username:(NSString*) username
      password:(NSString*) password
userAttributes:(NSArray<AWSCognitoIdentityUserAttributeType *> *) userAttributes
validationData:(NSArray<AWSCognitoIdentityUserAttributeType *> *) validationData
     withBlock:(AWSContinuationBlock)block {
    
    [[pool signUp:username password:password userAttributes:userAttributes validationData:validationData] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
        
        if (task.error || (task.result.user.confirmedStatus != AWSCognitoIdentityUserStatusConfirmed)) {
            self.userPassword = password;
            block(task);
        } else {
            //authenticate with Bayun
            NSDictionary *postParamsDict = @{@"companyName" : self.companyName,
                                             @"companyEmployeeId" : username,
                                             @"password" : password,
                                             @"appId" : self.appId,
                                             @"appSecret" : self.appSecret
                                             };
            
            //authenticate with Bayun Key Management Server
            [[BayunCore sharedInstance] authenticateWithCredentials:postParamsDict securityQuestions:nil  passphrase:nil autoCreateEmployee:true success:^{
                //Bayun Authentication Successful
                block(task);
                
            } failure:^(BayunError errorCode) {
                
                [self executeBlock:block withBayunError:errorCode];
                
            }];
        }
        return nil;
    }];
}

-(void)confirmSignUpForUser:(AWSCognitoIdentityUser*)user
           confirmationCode:(NSString *) confirmationCode
         forceAliasCreation:(BOOL)forceAliasCreation
                  withBlock:(AWSContinuationBlock)block {
    
    [[user confirmSignUp:confirmationCode forceAliasCreation:forceAliasCreation] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse *> * _Nonnull task) {
            if(task.error){
                if(task.error){
                    block(task);
                }
            }else {
                //return to signin screen
                NSDictionary *postParamsDict = @{@"companyName" : self.companyName,
                                                 @"companyEmployeeId" : user.username,
                                                 @"password" : self.userPassword,
                                                 @"appId" : self.appId};
                
                //authenticate with Bayun Key Management Server
                [[BayunCore sharedInstance] authenticateWithCredentials:postParamsDict securityQuestions:nil passphrase:nil autoCreateEmployee:true success:^{
                    //Bayun Authentication Successful
                    block(task);
                    
                } failure:^(BayunError errorCode) {
                    [self executeBlock:block withBayunError:errorCode];
                }];
            }
        return nil;
    }];
}


-(void)signInPool:(AWSCognitoIdentityUserPool*)pool
         username:(NSString*)username
         password:(NSString*)password
        withBlock:(AWSContinuationBlock)block{
    
    
    AWSCognitoIdentityUser *user = [pool getUser:username];
    [[user getSession:username password:password validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
        
        if (task.error) {
            block(task);
        } else {
            //return to signin screen
            
            NSDictionary *postParamsDict = @{@"companyName" : self.companyName,
                                             @"companyEmployeeId" : username,
                                             @"password" : password,
                                             @"appId" : self.appId,
                                             @"appSecret" : self.appSecret
                                             };
            
           // authenticate with Bayun Key Management Server
            [[BayunCore sharedInstance] authenticateWithCredentials:postParamsDict securityQuestions:nil passphrase:nil autoCreateEmployee:true success:^{
                //Bayun Authentication Successful
                block(task);
            } failure:^(BayunError errorCode) {
                [user signOut];
                [self executeBlock:block withBayunError:errorCode];
            }];
            
        }
        return nil;
    }];
}

- (void)signOut:(AWSCognitoIdentityUser*)user {
    [user signOut];
    [[BayunCore sharedInstance] deauthenticate];
}

- (void)forgotPasswordWithBlock:(AWSContinuationBlock)block {
    
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"Forgot Password Not Supported.", nil)};
    AWSTask *task = [AWSTask taskWithError:[NSError errorWithDomain:SecureAuthenticationErrorDomain
                                               code:SecureAuthenticationErrorNotSupported
                                           userInfo:userInfo]];
    
    block(task);
}

- (void) executeBlock:(AWSContinuationBlock)block withBayunError:(BayunError)bayunError {
   
    AWSTask *task;
    
    if (bayunError == BayunErrorAuthenticationFailed) {
        task = [self taskWithErrorType:SecureAuthenticationErrorFailed
                             errorMessage:@"Bayun Authentication Failed."];
    } else if (bayunError == BayunErrorInvalidAppSecret) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidAppSecret
                          errorMessage:@"Invalid App Secret"];
    } else if(bayunError == BayunErrorPasscodeAuthenticationCanceledByUser) {
        task = [self taskWithErrorType:SecureAuthenticationErrorPasscodeAuthenticationCanceledByUser
                          errorMessage:@"Passscode Authentication Canceled by User."];
    } else if(bayunError == BayunErrorOneOrMoreIncorrectAnswers) {
        task = [self taskWithErrorType:SecureAuthenticationErrorOneOrMoreIncorrectAnswers
                          errorMessage:@"One or more invalid answers."];
    }   else if(bayunError == BayunErrorInvalidPassword) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidPassword
                             errorMessage:@"Invalid Password."];
    } else if(bayunError == BayunErrorInvalidPassphrase) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidPassphrase
                             errorMessage:@"Invalid Passphrase."];
    } else if (bayunError ==  BayunErrorCompanyDoesNotExists) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidCompanyName
                             errorMessage:@"Invalid Company Name"];
    } else if(bayunError == BayunErrorInvalidCredentials) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidCredentials
                             errorMessage:@"Invalid Credentials"];
    } else if(bayunError == BayunErrorInvalidAppId) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidAppId
                             errorMessage:@"Invalid App Id."];
    }else if(bayunError == BayunErrorDevicePasscodeNotSet) {
        task = [self taskWithErrorType:SecureAuthenticationErrorDevicePasscodeNotSet
                          errorMessage:@"Device Passcode is not Set."];
    } else if(bayunError == BayunErrorAppNotLinked) {
        task = [self taskWithErrorType:SecureAuthenticationErrorAppNotLinked
                          errorMessage:@"App is not linked. Login to the Admin Panel/App and link the app."];
    } else if(bayunError == BayunErrorUserInActive) {
        task = [self taskWithErrorType:SecureAuthenticationErrorUserInActive
                          errorMessage:@"Please contact your Admin to activate your account."];
    } else if (bayunError == BayunErrorInvalidAppSecret) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidAppSecret
                          errorMessage:@"Invalid App Secret."];
    } else  {
        task = [self taskWithErrorType:SecureAuthenticationErrorSomethingWentWrong
                             errorMessage:@"Something Went Wrong."];
    }
    
    block(task);
}

- (AWSTask*) taskWithErrorType:(SecureAuthenticationErrorType)errorType errorMessage:(NSString*)errorMessage {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(errorMessage, nil)};
    return [AWSTask taskWithError:[NSError errorWithDomain:SecureAuthenticationErrorDomain
                                                         code:errorType
                                                     userInfo:userInfo]];
}

@end
