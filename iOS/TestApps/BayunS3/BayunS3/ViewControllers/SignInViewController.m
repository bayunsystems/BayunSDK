//
// Copyright 2014-2016 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

#import "SignInViewController.h"
#import "SecureAuthentication.h"
#import <Bayun/BayunCore.h>
#import "Utilities.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"

@interface SignInViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextfield;
@property (strong,nonatomic) NSString *defaultCompanyName;

@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;
@property (nonatomic) BOOL isKeyboardVisible;
@property (nonatomic) CGFloat keyBoardHeight;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isKeyboardVisible = NO;
    self.username.delegate = self;
    self.password.delegate = self;
    
    self.defaultCompanyName = @"BayunS3Pool";
    [[NSUserDefaults standardUserDefaults] setValue:self.defaultCompanyName forKey:kCompany];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.password.text = nil;
    self.username.text = self.usernameText;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideKeyboard) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyBoardDidShow:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyBoardHeight = keyboardFrameBeginRect.size.height;
    
    if(!self.isKeyboardVisible) {
        self.isKeyboardVisible = YES;
        [self slideViewBy:-self.keyBoardHeight];
    }
}

- (void)keyBoardWillHide:(NSNotification*)notification {
    [self hideKeyboard];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
   
    [self.view endEditing:YES];
    [self hideKeyboard];
}

- (void)hideKeyboard {
    if(self.isKeyboardVisible) {
        self.isKeyboardVisible = NO;
        [self slideViewBy:self.keyBoardHeight];
    }
}

- (IBAction)signInPressed:(id)sender {
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    [SVProgressHUD show];
    [[SecureAuthentication sharedInstance] signInPool:pool username:self.username.text password:self.password.text withBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession*> * _Nonnull task) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSError *error = task.error;
            
            if(error){
                [[[UIAlertView alloc] initWithTitle:error.userInfo[@"__type"]
                                            message:error.userInfo[@"message"]
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"Retry", nil] show];
            } else {
                self.usernameText = nil;
                [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
            }
        });
        return nil;
    }];
}

- (IBAction)changeCompanyButtonIsPressed:(id)sender {
    [self showCompanyAlertViewWithDefaultCompanyName:self.defaultCompanyName];
}

- (void)showCompanyAlertViewWithDefaultCompanyName :(NSString*)companyName {
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:nil
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Done", nil];
    alertView.alertViewStyle = DLAVAlertViewStyleDefault;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 80.0)];
    
    CGRect companyNameLabelFrame = CGRectMake(0.0, 0.0, 200.0, 40.0);
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:companyNameLabelFrame];
    companyLabel.text = @"Company Name";
    companyLabel.textAlignment = NSTextAlignmentCenter;
    
    CGRect companyNameTextFieldFrame = CGRectMake(0.0, 50.0, 200.0, 25.0);
    UITextField *companyNameTextfield = [[UITextField alloc] initWithFrame:companyNameTextFieldFrame];
    companyNameTextfield.borderStyle = UITextBorderStyleBezel;
    companyNameTextfield.layer.cornerRadius = 3.0f;
    companyNameTextfield.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    companyNameTextfield.delegate = self;
    companyNameTextfield.textAlignment = NSTextAlignmentCenter;
    companyNameTextfield.text = companyName;
    
    [contentView addSubview:companyLabel];
    [contentView addSubview:companyNameTextfield];
    
    DLAVAlertViewTheme *theme = [DLAVAlertViewTheme defaultTheme];
    theme.backgroundColor = [UIColor whiteColor];
    [alertView applyTheme:theme];
    alertView.contentView = contentView;
    
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        //if (buttonIndex == 1) {
        if (companyNameTextfield.text && ![companyNameTextfield.text isEqualToString:@""]) {
            NSLog(@"company name : %@",companyNameTextfield.text);
            self.defaultCompanyName = companyNameTextfield.text;
            [[NSUserDefaults standardUserDefaults] setValue:companyNameTextfield.text forKey:kCompany];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[SecureAuthentication sharedInstance] setCompanyName:companyNameTextfield.text];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Company name cannot be nil"];
            [self performSelector:@selector(showCompanyAlertViewWithDefaultCompanyName:) withObject:@"" afterDelay:5];
        }
        //}
    }];
}


-(void)getPasswordAuthenticationDetails: (AWSCognitoIdentityPasswordAuthenticationInput *) authenticationInput  passwordAuthenticationCompletionSource: (AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails *> *) passwordAuthenticationCompletionSource {
    self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.usernameText)
            self.usernameText = authenticationInput.lastKnownUsername;
    });
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
    if (textField == self.username) {
        [self.password becomeFirstResponder];
        return NO;
    } else if (textField==self.password) {
        [self.password resignFirstResponder];
        [self hideKeyboard];
        return NO;
    }
    return YES;
}



@end
