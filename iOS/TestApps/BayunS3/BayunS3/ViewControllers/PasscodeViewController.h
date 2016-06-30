//
//  PasscodeViewController.h
//  Bayun
//
//  Created by Preeti Gaur on 24/11/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasscodeViewController : UIViewController<UITextFieldDelegate>

@property(strong,nonatomic) NSString *email;

@property (strong, nonatomic) IBOutlet UITextField *digit1Textfield;
@property (strong, nonatomic) IBOutlet UITextField *digit2Textfield;
@property (strong, nonatomic) IBOutlet UITextField *digit3Textfield;
@property (strong, nonatomic) IBOutlet UITextField *digit4Textfield;
@property (strong, nonatomic) IBOutlet UITextField *codeTextfield;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;


- (IBAction)backButtonIspressed:(id)sender;
- (IBAction)continueButtonIsPressed:(id)sender;
- (IBAction)skipButtonIsPressed:(id)sender;


@end
