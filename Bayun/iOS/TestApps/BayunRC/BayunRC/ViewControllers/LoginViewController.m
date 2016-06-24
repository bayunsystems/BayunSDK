//
//  LoginViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 01/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "RCAPIManager.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "Sender.h"
#import "Receiver.h"
#import <Bayun/BayunCore.h>

@interface LoginViewController ()

@property (nonatomic) BOOL isKeyboardVisible;

@end


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if (phoneNumber.length > 0 &&   extension.length > 0 && password.length > 0) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        if (appDelegate.isNetworkReachable) {
            NSDictionary *credentials = @{@"grant_type":@"password",
                                          @"username" : phoneNumber,
                                          @"extension" : extension,
                                          @"password" : password};
            
            [[RCAPIManager sharedInstance] loginWithCredentials:credentials success:^{
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
                NSDictionary *credentials = @{@"company" : phoneNumber,
                                              @"employee" : extension,
                                              @"password" : password,
                                              @"appName" : [RCUtilities appName],
                                              @"appId" : [RCUtilities appId],
                                              @"passcode" : [NSNull null]};
                
                [[BayunCore sharedInstance] authenticateWithCredentials:credentials passcode:nil success:^{
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kIsUserLoggedIn];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self getExtensionsAndMessages];
                    [self performSegueWithIdentifier:@"MessagesListSegue" sender:nil];
                } failure:^(NSUInteger errorCode) {
                    if (errorCode == BayunErrorUserInActive) {
                        [SVProgressHUD showErrorWithStatus:kErrorUserInActive];
                    } else if (errorCode == BayunErrorInvalidCredentials){
                        [SVProgressHUD showErrorWithStatus:kErrorInvalidCredentials];
                    } else if (errorCode == BayunErrorInvalidPasscode){
                        [SVProgressHUD showErrorWithStatus:kErrorIncorrectPasscode];
                    } else {
                        [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
                    }
                }];
            } failure:^(RCError errorCode) {
                if (errorCode == RCErrorInvalidToken) {
                    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate logoutWithMessage:kErrorSessionIsExpired];
                } else if(errorCode == RCErrorInvalidCredentials) {
                    [SVProgressHUD showErrorWithStatus:kErrorInvalidCredentials];
                } else {
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
        [[RCAPIManager sharedInstance] getMessageList:^{
            [SVProgressHUD dismiss];
        } failure:^(RCError errorCode) {
            if (errorCode == RCErrorInternetConnection) {
                [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
            } else if (errorCode == RCErrorRequestTimeOut) {
                [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
            } else  if (errorCode == RCErrorInvalidToken) {
                AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate logoutWithMessage:kErrorSessionIsExpired];
            } else {
                [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
            }
        }];
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
