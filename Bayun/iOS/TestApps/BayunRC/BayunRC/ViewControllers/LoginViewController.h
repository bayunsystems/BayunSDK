//
//  LoginViewController.h
//  Bayun
//
//  Created by Preeti Gaur on 01/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//View Controller to login RingCentral and authenticate with the Bayun.

@interface LoginViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *extensionTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIView *parentView;

- (IBAction)logInButtonIsPressed:(id)sender;

@end
