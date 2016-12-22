//
//  LoginViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 01/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "ListFilesViewController.h"
#import "PasscodeViewController.h"
#import <Bayun/BayunCore.h>

@interface LoginViewController ()

@property (nonatomic) BOOL isKeyboardVisible;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backgroundImageView setImage:[UIImage imageNamed:@"backgroungImage.png"]];
    
    self.companyNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.employeeIdTextField.delegate = self;
    
    self.employeeIdTextField.borderStyle = UITextBorderStyleNone;
    self.companyNameTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    
    [self addLeftViewToTextField:self.employeeIdTextField];
    [self addLeftViewToTextField:self.companyNameTextField];
    [self addLeftViewToTextField:self.passwordTextField];
    
    self.employeeIdTextField.layer.cornerRadius = 3.0f;
    self.companyNameTextField.layer.cornerRadius = 3.0f;
    self.passwordTextField.layer.cornerRadius = 3.0f;
    self.loginButton.layer.cornerRadius = 3.0f;
    
    self.navigationController.navigationBar.hidden = YES;
    self.isKeyboardVisible = NO;
    
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideKeyboard) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) addLeftViewToTextField:(UITextField *)textField {
    textField.leftViewMode = UITextFieldViewModeAlways;
    NSInteger rightViewWidth = 7;
    NSInteger rightViewHeight = 28;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rightViewWidth, rightViewHeight)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)registerButtonIsPressed:(id)sender {
    if (self.isKeyboardVisible) {
        [self hideKeyboard];
    }
    
    NSString *employeeId =  [self.employeeIdTextField.text
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * companyName = [self.companyNameTextField.text
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * password = [self.passwordTextField.text
                           stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [[NSUserDefaults standardUserDefaults] setValue:companyName forKey:kCompanyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (employeeId.length > 0 &&   companyName.length > 0 && password.length > 0) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        if (appDelegate.isNetworkReachable) {
            NSDictionary *postParamsDict = @{@"companyName" : companyName,
                                             @"companyEmployeeId" : employeeId,
                                             @"password" : password,
                                             @"appId" : [Utilities appId]};
            
            [SVProgressHUD show];
            
            //authenticate with Bayun Key Management Server
            [[BayunCore sharedInstance] authenticateWithCredentials:postParamsDict passcode:nil success:^{
                //Bayun Authentication Successful
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kIsUserLoggedIn];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
                
            } failure:^(BayunError errorCode) {
                //Bayun Authentication Failed
                if (errorCode == BayunErrorInternetConnection) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
                } else if (errorCode == BayunErrorRequestTimeOut) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgRequestTimeOut];
                } else if (errorCode == BayunErrorInvalidCredentials) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgInvalidCredentials];
                } else if (errorCode == BayunErrorAccessDenied) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgAccessDenied];
                }else if (errorCode == BayunErrorUserInActive) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgUserInActive];
                } else if (errorCode == BayunErrorCouldNotConnectToServer) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgCouldNotConnectToServer];
                } else if (errorCode == BayunErrorAppNotLinked) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgAppNotLinked];
                } else if (errorCode == BayunErrorInvalidPassword) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgIncorrectPassword];
                } else if (errorCode == BayunErrorAuthenticationFailed) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgAuthenticationFailed];
                } else if (errorCode == BayunErrorInvalidPasscode) {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgIncorrectPasscode];
                } else {
                    [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Complete all fields"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)hideKeyboard {
    if(self.isKeyboardVisible) {
        self.isKeyboardVisible = NO;
        //Slide view down
        [self slideViewBy:140.0f];
        //Hide keyboard
        [self.view endEditing:YES];
    }
}

-(void)slideViewBy:(CGFloat)offset {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    
    CGRect frame = self.view.frame;
    frame.origin.y += offset;
    self.view.frame = frame;
    
    [UIView commitAnimations];
}

#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.companyNameTextField) {
        [self.employeeIdTextField becomeFirstResponder];
        return NO;
    } else if (textField == self.employeeIdTextField) {
        [self.passwordTextField becomeFirstResponder];
        return NO;
    } else if (textField==self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self hideKeyboard];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if(!self.isKeyboardVisible) {
        self.isKeyboardVisible = YES;
        //Slide view up
        [self slideViewBy:-140.0f];
    }
}

@end
