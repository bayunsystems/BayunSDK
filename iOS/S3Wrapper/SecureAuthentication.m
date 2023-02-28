//
//  SecureAuthentication.m
//  Copyright © 2023 Bayun Systems, Inc. All rights reserved.
//

#import "SecureAuthentication.h"
#import <Bayun/BayunCore.h>

NSString *const SecureAuthenticationErrorDomain = @"com.bayun.SecureAuthenticationErrorDomain";

@interface SecureAuthentication()

@property (strong,nonatomic) NSString *userPassword;
@property (nonatomic,assign) BOOL registerBayunWithPassword;

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
registerBayunWithPwd:(BOOL)registerBayunWithPwd
     withBlock:(AWSContinuationBlock)block {
  
  for(AWSCognitoIdentityUserAttributeType *type in userAttributes) {
    if ([type.name isEqualToString:@"email"]) {
      self.email = type.value;
    }
  }
  
  self.registerBayunWithPassword = registerBayunWithPwd;
  
  [[pool signUp:username password:password userAttributes:userAttributes validationData:validationData] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
    
    if (task.error || (task.result.user.confirmedStatus != AWSCognitoIdentityUserStatusConfirmed)) {
      self.userPassword = password;
      block(task);
    } else {
      
      //Register with Bayun Key Management Server
      BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:self.appId
                                                                             appSecret:self.appSecret
                                                                               appSalt:self.appSalt
                                                                               baseURL:kBayunBaseURL];
      
      if (registerBayunWithPwd) {
        [[BayunCore sharedInstance] registerWithCompanyName:self.companyName
                                          companyEmployeeId:username
                                                   password:password
                                        bayunAppCredentials:appCredentials
                                  authorizeEmployeeCallback:^(NSString *employeePublicKey) {
          NSLog(@"employeePublicKey : %@",employeePublicKey);
          //Authorization of employeePublicKey is Pending
          [self executeBlock:block withBayunError:BayunErrorEmployeeAuthorizationIsPending];
          
        } success:^{
          //Bayun Authentication Successful
          block(task);
        } failure:^(BayunError errorCode) {
          [self executeBlock:block withBayunError:errorCode];
        }];
        
      } else {
        
        [[BayunCore sharedInstance] registerWithCompanyName:self.companyName
                                          companyEmployeeId:username
                                                      email:self.email
                                        isCompanyOwnedEmail:true
                                        bayunAppCredentials:appCredentials
                                 newUserCredentialsCallback:nil
                                  securityQuestionsCallback:nil
                                         passphraseCallback:nil
                                  authorizeEmployeeCallback:^(NSString *employeePublicKey) {
          NSLog(@"employeePublicKey : %@",employeePublicKey);
          //Authorization of employeePublicKey is Pending
          [self executeBlock:block withBayunError:BayunErrorEmployeeAuthorizationIsPending];
          
        } success:^{
          //Bayun Authentication Successful
          block(task);
        } failure:^(BayunError errorCode) {
          [self executeBlock:block withBayunError:errorCode];
        }];
      }
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
              BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:self.appId
                                                                                     appSecret:self.appSecret
                                                                                       appSalt:self.appSalt
                                                                                       baseURL:kBayunBaseURL];
              
              if (self.registerBayunWithPassword) {
                
                [[BayunCore sharedInstance] registerWithCompanyName:self.companyName companyEmployeeId:user.username password:self.userPassword bayunAppCredentials:appCredentials authorizeEmployeeCallback:^(NSString *employeePublicKey) {
                  NSLog(@"employeePublicKey : %@",employeePublicKey);
                  //Authorization of employeePublicKey is Pending
                  [self executeBlock:block withBayunError:BayunErrorEmployeeAuthorizationIsPending];
                } success:^{
                  //Bayun Authentication Successful
                  block(task);
                } failure:^(BayunError errorCode) {
                  [self executeBlock:block withBayunError:errorCode];
                }];
              } else {
                
                [[BayunCore sharedInstance] registerWithCompanyName:self.companyName
                                                  companyEmployeeId:user.username
                                                              email:self.email
                                                isCompanyOwnedEmail:true
                                                bayunAppCredentials:appCredentials
                                         newUserCredentialsCallback:nil
                                          securityQuestionsCallback:nil
                                                 passphraseCallback:nil
                                          authorizeEmployeeCallback:^(NSString *employeePublicKey) {
                  NSLog(@"employeePublicKey : %@",employeePublicKey);
                  //Authorization of employeePublicKey is Pending
                  [self executeBlock:block withBayunError:BayunErrorEmployeeAuthorizationIsPending];
                  
                } success:^{
                  //Bayun Authentication Successful
                  block(task);
                } failure:^(BayunError errorCode) {
                  [self executeBlock:block withBayunError:errorCode];
                }];
              }
              
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
          BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:self.appId
                                                                                 appSecret:self.appSecret
                                                                                   appSalt:self.appSalt
                                                                                   baseURL:kBayunBaseURL];
          
          [[BayunCore sharedInstance] loginWithCompanyName:self.companyName
                                         companyEmployeeId:username
                                                  password:password
                                        autoCreateEmployee:true
                                 securityQuestionsCallback:nil
                                        passphraseCallback:nil
                                       bayunAppCredentials:appCredentials
                                                   success:^{
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
    [[BayunCore sharedInstance] logout];
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
                          errorMessage:@"Device Passcode is not set."];
    } else if(bayunError == BayunErrorAppNotLinked) {
        task = [self taskWithErrorType:SecureAuthenticationErrorAppNotLinked
                          errorMessage:@"App is not linked. Login to the Admin Panel/App and link the app."];
    } else if(bayunError == BayunErrorUserInActive) {
        task = [self taskWithErrorType:SecureAuthenticationErrorUserInActive
                          errorMessage:@"Please contact your Admin to activate your account."];
    } else if (bayunError == BayunErrorInvalidAppSecret) {
        task = [self taskWithErrorType:SecureAuthenticationErrorInvalidAppSecret
                          errorMessage:@"Invalid App Secret."];
    } else if(bayunError == BayunErrorCouldNotConnectToServer) {
      task = [self taskWithErrorType:SecureAuthenticationErrorCouldNotConnectToServer
                        errorMessage:@"Could not connect to the Server"];
    } else if (bayunError == BayunErrorEmployeeAlreadyExists) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeAlreadyExists
                        errorMessage:@"Employee already exists"];
    } else if (bayunError == BayunErrorEmployeeDoesNotExists) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeDoesNotExists
                        errorMessage:@"Employee does not exists"];
    } else if (bayunError == BayunErrorEmployeeAccountHasPasswordEnabled) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeAccountHasPasswordEnabled
                        errorMessage:@"Password is enabled for the account being registered without password"];
    } else if (bayunError == BayunErrorUserAlreadyExists) {
      task = [self taskWithErrorType:SecureAuthenticationErrorUserAlreadyExists
                        errorMessage:@"User already exists"];
    } else if (bayunError == BayunErrorLinkEmployeeUserAccount) {
      task = [self taskWithErrorType:SecureAuthenticationErrorLinkEmployeeUserAccount
                        errorMessage:@"Login to Admin Panel to link this User account with the existing Employee account to continue using the SDK APIs."];
    } else if (bayunError == BayunErrorUserAccountHasPasswordEnabled) {
      task = [self taskWithErrorType:SecureAuthenticationErrorUserAccountHasPasswordEnabled
                        errorMessage:@"User password is already enabled for the account being registered"];
    } else if (bayunError == BayunErrorEmployeeNotLinkedToApp) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeNotLinkedToApp
                        errorMessage:@"Employee Account is not linked to the App"];
    } else if (bayunError == BayunErrorUserIsNotRegistered) {
      task = [self taskWithErrorType:SecureAuthenticationErrorUserIsNotRegistered
                        errorMessage:@"User is not registered"];
    } else if (bayunError == BayunErrorEmployeeAppNotRegistered) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeAppNotRegistered
                        errorMessage:@"Employee App is not registered"];
    } else if (bayunError == BayunErrorEmployeeAuthorizationIsPending) {
      task = [self taskWithErrorType:SecureAuthenticationErrorEmployeeAuthorizationIsPending
                        errorMessage:@"Employee Authorization is Pending"];
    } else if (bayunError == BayunErrorRegistrationFailedAppNotApproved) {
      task = [self taskWithErrorType:SecureAuthenticationErrorRegistrationFailedAppNotApproved
                        errorMessage:@"Registration failed as the application is not approved. Please contact your Admin for approval."];
    }
    else  {
        task = [self taskWithErrorType:SecureAuthenticationErrorSomethingWentWrong
                             errorMessage:@"Something went wrong."];
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
