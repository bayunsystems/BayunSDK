//
//  LoginViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 01/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "RCAPIManager.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "Sender.h"
#import "Receiver.h"
#import <Bayun/BayunCore.h>
#import "CTCheckbox.h"
#import "RCConfig.h"

@interface LoginViewController ()

@property (nonatomic) BOOL isKeyboardVisible;

@end


@implementation LoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Set default - RC Production Server
  [[NSUserDefaults standardUserDefaults] setObject:@"Production" forKey:kRCServer];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self.checkbox addTarget:self action:@selector(checkboxDidChange:) forControlEvents:UIControlEventValueChanged];
  self.checkbox.textLabel.text = @"Point to Sandbox Server";
  [self.checkbox setColor:[UIColor whiteColor] forControlState:UIControlStateNormal];
  [self.checkbox setColor:[UIColor whiteColor] forControlState:UIControlStateDisabled];
  
  [self.backgroundImageView setImage:[UIImage imageNamed:@"backgroungImage.png"]];
  
  self.extensionTextField.delegate = self;
  self.passwordTextField.delegate = self;
  self.usernameTextField.delegate = self;
  
  self.usernameTextField.borderStyle = UITextBorderStyleNone;
  self.extensionTextField.borderStyle = UITextBorderStyleNone;
  self.passwordTextField.borderStyle = UITextBorderStyleNone;
  
  [self addLeftViewToTextField:self.usernameTextField];
  [self addLeftViewToTextField:self.extensionTextField];
  [self addLeftViewToTextField:self.passwordTextField];
  
  self.usernameTextField.layer.cornerRadius = 3.0f;
  self.extensionTextField.layer.cornerRadius = 3.0f;
  self.passwordTextField.layer.cornerRadius = 3.0f;
  self.loginButton.layer.cornerRadius = 3.0f;
  
  self.navigationController.navigationBar.hidden = YES;
  self.isKeyboardVisible = NO;
  
}

- (void)checkboxDidChange:(CTCheckbox *)checkbox
{
  if (checkbox.checked) {
    NSLog(@"Sandbox");
    [[NSUserDefaults standardUserDefaults] setObject:@"Sandbox" forKey:kRCServer];
  } else {
    NSLog(@"Production");
    [[NSUserDefaults standardUserDefaults] setObject:@"Production" forKey:kRCServer];
  }
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(hideKeyboard)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}



- (IBAction)logInButtonIsPressed:(id)sender {
  if (self.isKeyboardVisible) {
    [self hideKeyboard];
  }
  
  NSString *phoneNumber = [self.usernameTextField.text
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString * extension = [self.extensionTextField.text
                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString * password = [self.passwordTextField.text
                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  
  if (phoneNumber.length > 0  && password.length > 0) {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (appDelegate.isNetworkReachable) {
      
      NSMutableDictionary *loginCredentials = [[NSMutableDictionary alloc] init];
      [loginCredentials setObject:@"password" forKey:@"grant_type"];
      [loginCredentials setObject:phoneNumber forKey:@"username"];
      [loginCredentials setObject:password forKey:@"password"];
      
      if (extension) {
        [loginCredentials setObject:extension forKey:@"extension"];
      }
      
      [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
      [[RCAPIManager sharedInstance] loginWithCredentials:loginCredentials success:^{
        //Delete entities for User, Receiver, Sender, Message, Conversation
        [Message deleteAll];
        [User deleteAll];
        [Receiver deleteAll];
        [Sender deleteAll];
        [Conversation deleteAll];
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.stack.managedObjectContext saveWithType:NSSaveSelfAndParent];
        
        [[NSUserDefaults standardUserDefaults] setValue:extension forKey:kRCExtension ];
        [[NSUserDefaults standardUserDefaults] setValue:phoneNumber forKey:kRCPhoneNumber ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //authenticate with Bayun Key Management Server after authenticating with RingCentral
        
        BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:[RCUtilities appId]
                                                                               appSecret:[RCUtilities appSecret]
                                                                                 appSalt:[RCUtilities appSalt]
                                                                                 baseURL:kBaseURL];
        
        [[BayunCore sharedInstance] loginWithCompanyName:phoneNumber companyEmployeeId:extension password:password autoCreateEmployee:true securityQuestionsCallback:nil passphraseCallback:nil bayunAppCredentials:appCredentials success:^{
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kIsUserLoggedIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self getExtensionsAndMessages];
            [self performSegueWithIdentifier:@"MessagesListSegue" sender:nil];
          });
        } failure:^(BayunError errorCode) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (errorCode == BayunErrorUserInActive) {
              [SVProgressHUD showErrorWithStatus:kErrorUserInActive];
            } if (errorCode == BayunErrorAppNotLinked) {
              [SVProgressHUD showErrorWithStatus:kErrorMsgAppNotLinked];
            } else if (errorCode == BayunErrorInvalidCredentials){
              [SVProgressHUD showErrorWithStatus:kErrorInvalidCredentials];
            } else if (errorCode == BayunErrorInvalidPassphrase){
              [SVProgressHUD showErrorWithStatus:kErrorIncorrectPasscode];
            } else if (errorCode == BayunErrorAuthenticationFailed){
              [SVProgressHUD showErrorWithStatus:kErrorMsgAuthenticationFailed];
            } else if(errorCode == BayunErrorDevicePasscodeNotSet) {
              [SVProgressHUD showErrorWithStatus:kErrorMsgDevicePasscodeNotSet];
            } else if(errorCode == BayunErrorPasscodeAuthenticationCanceledByUser) {
              [SVProgressHUD showErrorWithStatus:kErrorMsgPasscodeAuthenticationFailed];
            } else if(errorCode == BayunErrorEmployeeAppNotRegistered) {
              [SVProgressHUD showErrorWithStatus:kErrorMsgEmployeeAppIsNotRegistered];
            } else if(errorCode == BayunErrorRegistrationFailedAppNotApproved) {
                [SVProgressHUD showErrorWithStatus:kErrorRegistrationFailedAppNotApproved];
            }
            else {
              [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
            }
          });
        }];
        
      } failure:^(RCError errorCode) {
        [SVProgressHUD dismiss];
        if (errorCode == RCErrorInvalidToken) {
          AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
          [appDelegate logoutWithMessage:kErrorSessionIsExpired];
        } else if(errorCode == RCErrorInvalidCredentials) {
          [SVProgressHUD showErrorWithStatus:kErrorInvalidCredentials];
        } else if(errorCode == RCErrorAccountLocked) {
          [SVProgressHUD showErrorWithStatus:kErrorAccountIsLocked];
        }else {
          AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
          [appDelegate logoutWithMessage:kErrorSomethingWentWrong];
        }
      }];
    } else {
      [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
    }
  } else {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:kErrorCompleteAllFields
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
  }
}

/**
 * Fetches extension list and pager-messages from RingCentral
 */
- (void) getExtensionsAndMessages {
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
  [[RCAPIManager sharedInstance] getExtensionList:^{
    [SVProgressHUD dismiss];
    //        [[RCAPIManager sharedInstance] getMessageList:^{
    //            [SVProgressHUD dismiss];
    //        } failure:^(RCError errorCode) {
    //            if (errorCode == RCErrorInternetConnection) {
    //                [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
    //            } else if (errorCode == RCErrorRequestTimeOut) {
    //                [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
    //            } else  if (errorCode == RCErrorInvalidToken) {
    //                AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //                [appDelegate logoutWithMessage:kErrorSessionIsExpired];
    //            } else {
    //                [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
    //            }
    //        }];
  } failure:^(RCError errorCode) {
    if (errorCode == RCErrorInternetConnection) {
      [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
    } else if (errorCode == RCErrorRequestTimeOut) {
      [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
    } else {
      [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
    }
  }];
}

#pragma mark - View Related Methods

- (void) addLeftViewToTextField:(UITextField *)textField {
  textField.leftViewMode = UITextFieldViewModeAlways;
  NSInteger rightViewWidth = 7;
  NSInteger rightViewHeight = 28;
  textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightViewWidth, rightViewHeight)];
}

- (void)hideKeyboard {
  if(self.isKeyboardVisible) {
    self.isKeyboardVisible = NO;
    
    //Slide view down
    [self slideViewBy:140.0f];
    
    //Hide keyboard
    [self.view endEditing:YES];
  }
}


- (void)slideViewBy:(CGFloat)offset {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.4f];
  
  CGRect frame = self.view.frame;
  frame.origin.y += offset;
  self.view.frame = frame;
  
  [UIView commitAnimations];
}

#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if (textField == self.extensionTextField) {
    [self.usernameTextField becomeFirstResponder];
    return NO;
  } else if (textField == self.usernameTextField) {
    [self.passwordTextField becomeFirstResponder];
    return NO;
  } else if (textField==self.passwordTextField) {
    [self.passwordTextField resignFirstResponder];
    [self hideKeyboard];
    return NO;
  }
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  if(!self.isKeyboardVisible) {
    self.isKeyboardVisible = YES;
    //Slide view up
    [self slideViewBy:-140.0f];
  }
}

@end
