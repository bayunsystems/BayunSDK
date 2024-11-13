//
// Copyright 2023-2023 Amazon.com,
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

@property (nonatomic, assign) BOOL signInWithBayunOnly;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *companyNameTextfield;
@property (weak, nonatomic) IBOutlet UIButton *signInWithPwdBtn;
@property (strong,nonatomic) NSString *defaultCompanyName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInTopConstraintToUsername;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signInTopConstraintToPwd;
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;
@property (weak, nonatomic) IBOutlet UIButton *signInWithBayunButton;
@property (nonatomic) BOOL isKeyboardVisible;
@property (nonatomic) CGFloat keyBoardHeight;
@end

@implementation SignInViewController

- (IBAction)signInWithBayunBtnIsPressed:(UIButton *)sender {
  
  if (sender.isSelected) {
    self.signInWithBayunOnly = false;
  } else {
    self.signInWithBayunOnly = true;
  }
  [sender setSelected:!sender.isSelected];
}


-(void)viewDidLoad {

    [super viewDidLoad];
    [Utilities clearKeychainAndUserDefaults];
    [self.signInWithPwdBtn setHidden:true];
    self.signInTopConstraintToUsername.priority = 500;
    self.signInTopConstraintToPwd.priority = 900;
    self.isKeyboardVisible = NO;
    self.username.delegate = self;
    self.password.delegate = self;
    self.defaultCompanyName = kDefaultCompanyName;
    [[NSUserDefaults standardUserDefaults] setValue:self.defaultCompanyName forKey:kCompany];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.password.text = nil;
    self.username.text = self.usernameText;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewEndEditing) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
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
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    if(!self.isKeyboardVisible) {
        self.keyBoardHeight = keyboardFrameBeginRect.size.height;
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

- (void)viewEndEditing {
    [self.view endEditing:YES];
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
  
  
  if (self.signInWithBayunOnly) {
    BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:kBayunAppId
                                                                           appSecret:kBayunAppSecret
                                                                             appSalt:kBayunApplicationSalt
                                                                             baseURL:kBayunBaseURL
                                                                bayunServerPublicKey:kBayunServerKey
    ];
    
    void(^successBlock)(void) = ^{
      [[NSUserDefaults standardUserDefaults] setBool:true forKey:kIsUserLoggedIn];
      dispatch_async( dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.usernameText = nil;
        
        //Set Encryption Policy to Default in the default value of Dropdown Menu
        [[NSUserDefaults standardUserDefaults] setInteger:BayunEncryptionPolicyDefault forKey:kSelectedEncryptionPolicy];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
      });
    };
    
    [[BayunCore sharedInstance] loginWithCompanyName:self.defaultCompanyName
                                    uiViewController:self
                                   companyEmployeeId:self.username.text
                                            password:self.password.text
                                  autoCreateEmployee:true
                           securityQuestionsCallback:nil
                                  passphraseCallback:nil
                                 bayunAppCredentials:appCredentials
                                             success:^{
      
//      [[BayunCore sharedInstance] unlockText:@"CwABAAAAEBuBLw5XRT4KKtj2Edgf0UAIAAIAAAACCAADAAAAAggABAAAAAALAAUAAAAQlcyNy3DfP3bLqVxMXjU3GwgACAAAAAMKAAoAAAAAPTfvfAgACwAAAAAA" success:^(NSString *text) {
//        NSLog(@"unlocked text : %@", text);
//      } failure:^(BayunError error) {
//
//      }];
      //Bayun Authentication Successful
      successBlock();
    } failure:^(BayunError errorCode) {
      [SVProgressHUD dismiss];
      NSString *errorStr = [Utilities errorStringForBayunError:errorCode];
      [self showErrorMessage:errorStr];
    }];
  } else {
      
      [[SecureAuthentication sharedInstance] signInPool:pool
                                               username:self.username.text
                                               password:self.password.text
                                              withBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession*> * _Nonnull task) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD dismiss];
          NSError *error = task.error;
          if(error){
            [SVProgressHUD dismiss];
            if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:kErrorMsgDevicePasscodeNotSet]) {
              [self showErrorMessage:kErrorMsgDevicePasscodeNotSet];
            } else  if ([[error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:kErrorMsgInvalidAnswers]) {
              [self showErrorMessage:kErrorMsgInvalidAnswers];
            } else  if ([error.userInfo valueForKey:@"message"] != nil) {
              [self showErrorMessage:[error.userInfo valueForKey:@"message"]];
            }  else {
              [self showErrorMessage:[error.userInfo valueForKey:@"NSLocalizedDescription"]];
            }
          } else {
            self.usernameText = nil;
    
            //Set Encryption Policy to Default in the default value of Dropdown Menu
            [[NSUserDefaults standardUserDefaults] setInteger:BayunEncryptionPolicyDefault forKey:kSelectedEncryptionPolicy];
            [[NSUserDefaults standardUserDefaults] synchronize];
    
            [self performSegueWithIdentifier:@"ListFilesSegue" sender:nil];
          }
        });
        return nil;
      }];
  }
}

- (void) showErrorMessage:(NSString*)errorMessage {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (IBAction)changeCompanyButtonIsPressed:(id)sender {
    [self showCompanyAlertViewWithDefaultCompanyName:self.defaultCompanyName];
}

- (void)showCompanyAlertViewWithDefaultCompanyName :(NSString*)companyName {
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
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
            [[NSUserDefaults standardUserDefaults] setValue:[companyNameTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:kCompany];
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



- (IBAction)loginWithPwdButton:(id)sender {
}
@end
