//
//  PasscodeViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 24/11/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "PasscodeViewController.h"
#import <Bayun/BayunCore.h>


@interface PasscodeViewController ()

@property (strong,nonatomic) NSMutableString *passcodeString;
@property (strong,nonatomic) NSString *onboardingToken;
@property (strong,nonatomic) NSString *onboardingEmail;

@end

@implementation PasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.passcodeString = [[NSMutableString alloc]init];
    
    [self.codeTextfield becomeFirstResponder];
    self.codeTextfield.delegate = self;
    
    self.digit1Textfield.userInteractionEnabled = NO;
    self.digit2Textfield.userInteractionEnabled = NO;
    self.digit3Textfield.userInteractionEnabled = NO;
    self.digit4Textfield.userInteractionEnabled = NO;
    
    self.digit1Textfield.delegate = self;
    self.digit2Textfield.delegate = self;
    self.digit3Textfield.delegate = self;
    self.digit4Textfield.delegate = self;

    self.digit1Textfield.borderStyle = UITextBorderStyleNone;
    self.digit1Textfield.layer.cornerRadius=5.0f;
    
    self.digit2Textfield.borderStyle = UITextBorderStyleNone;
    self.digit2Textfield.layer.cornerRadius=5.0f;
    
    self.digit3Textfield.borderStyle = UITextBorderStyleNone;
    self.digit3Textfield.layer.cornerRadius=5.0f;
    
    self.digit4Textfield.borderStyle = UITextBorderStyleNone;
    self.digit4Textfield.layer.cornerRadius=5.0f;
    
    
    self.digit1Textfield.layer.borderWidth = 2.0;
    self.digit1Textfield.layer.borderColor = [[UIColor colorWithRed:51/255.0f green:204/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    self.digit2Textfield.layer.borderWidth = 2.0;
    self.digit2Textfield.layer.borderColor = [[UIColor colorWithRed:51/255.0f green:204/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    self.digit3Textfield.layer.borderWidth = 2.0;
    self.digit3Textfield.layer.borderColor = [[UIColor colorWithRed:51/255.0f green:204/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    self.digit4Textfield.layer.borderWidth = 2.0;
    self.digit4Textfield.layer.borderColor = [[UIColor colorWithRed:51/255.0f green:204/255.0f blue:255/255.0f alpha:1.0]CGColor];
    
    [self.continueButton setEnabled:NO];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *string = [NSString stringWithFormat:@"Enter Your Passcode"];
    NSRange boldRange = NSMakeRange(10,5);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]
                       range:boldRange];
    
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:NSMakeRange(0,attrString.length)];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(newLength > 4) {
        return NO;
    }

    NSString *finalString;
    
    if (![string isEqualToString:@""]) {
        [self.passcodeString appendString:string];
        finalString = [NSString stringWithFormat:@"%@",self.passcodeString];
    } else {
        if (newLength>0) {
            self.passcodeString = [[self.passcodeString substringToIndex:[self.passcodeString length] - 1] mutableCopy];
            finalString = self.passcodeString;
        } else {
            [self clearTextFields];
            finalString = @"";
        }
    }
    
    if (finalString.length == 4 ) {
        [self.continueButton setEnabled:YES];
    } else {
        [self.continueButton setEnabled:NO];
        
        if (finalString.length == 3 ) {
            self.digit4Textfield.text = @"";
        } else if(finalString.length ==2) {
            self.digit4Textfield.text = @"";
            self.digit3Textfield.text = @"";
        } else if(finalString.length ==1) {
            self.digit4Textfield.text = @"";
            self.digit3Textfield.text = @"";
            self.digit2Textfield.text = @"";
        }
    }
    
    if (finalString.length > 0) {
        for (int i=0; i<finalString.length; i++) {
            if (i== 0) {
                if ([finalString characterAtIndex:i] != ' ') {
                    [self.digit1Textfield setText:[NSString stringWithFormat:@"%c",[finalString characterAtIndex:i]]];
                } else {
                    [self.digit1Textfield setText:@""];
                }
            }
            
            if(i==1) {
                if ([finalString characterAtIndex:i] != ' ') {
                    [self.digit2Textfield setText:[NSString stringWithFormat:@"%c",[finalString characterAtIndex:i]]];
                } else {
                    [self.digit2Textfield setText:@""];
                }
            }
            
            if(i==2) {
                [self.digit3Textfield setText:[NSString stringWithFormat:@"%c",[finalString characterAtIndex:i]]];
            }
            
            if(i==3) {
                [self.digit4Textfield setText:[NSString stringWithFormat:@"%c",[finalString characterAtIndex:i]]];
            }
        }
    } else {
        [self clearTextFields];
        return NO;
    }
    return YES;
}

-(void)clearTextFields {
    self.digit4Textfield.text = @"";
    self.digit3Textfield.text = @"";
    self.digit2Textfield.text = @"";
    self.digit1Textfield.text = @"";
    self.codeTextfield.text = @"";
    self.passcodeString = [NSMutableString stringWithString:@""];
    self.continueButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startOverButtonIsPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonIspressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)continueButtonIsPressed:(id)sender {
    
    [SVProgressHUD show];
    
    [[BayunCore sharedInstance] validatePasscode:self.passcodeString  success:^{

        [SVProgressHUD dismiss];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kIsUserLoggedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
        
    } failure:^(NSUInteger errorCode) {
        
        [SVProgressHUD dismiss];
        if (errorCode == BayunErrorInvalidPasscode) {
            [self clearTextFields];
            [SVProgressHUD showErrorWithStatus:kErrorMsgIncorrectPasscode];
        } else if (errorCode == BayunErrorInvalidCredentials) {
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showErrorWithStatus:kErrorMsgInvalidCredentials];
        } else if (errorCode == BayunErrorInternetConnection) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgInternetConnection];
        } else if (errorCode == BayunErrorRequestTimeOut) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgRequestTimeOut];
        } else if (errorCode == BayunErrorAccessDenied) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgAccessDenied];
        } else if (errorCode == BayunErrorCouldNotConnectToServer) {
            [SVProgressHUD showErrorWithStatus:kErrorMsgCouldNotConnectToServer];
        } else {
            [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
        }
        
    }];
}

- (IBAction)skipButtonIsPressed:(id)sender {
    [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
}
@end
