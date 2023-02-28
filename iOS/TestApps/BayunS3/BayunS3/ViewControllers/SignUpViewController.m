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

#import "SignUpViewController.h"
#import "AWSCognitoIdentityProvider.h"
#import "ConfirmSignUpViewController.h"
#import "AWSCognitoIdentityUserPool.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"
#import "SecureAuthentication.h"
#import <Bayun/BayunCore.h>

@interface SignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;

@property (weak, nonatomic) IBOutlet UIButton *registerWithPwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerWithBayunOnlyBtn;

@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@property (nonatomic, strong) NSString* sentTo;
@property (strong,nonatomic) NSString *defaultCompanyName;


@property (nonatomic, assign) BOOL registerBayunWithPwd;
@property (nonatomic, assign) BOOL registerWithBayunOnly;

@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *emailView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailUsernameConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailPasswordConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpEmailSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupPasswordSpacingConstraint;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
  self.registerBayunWithPwd = true;
  self.defaultCompanyName = kDefaultCompanyName;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.view addGestureRecognizer:tap];
  [self.registerWithPwdBtn setSelected:false];
  [self.registerWithBayunOnlyBtn setSelected:false];
  
  self.registerBayunWithPwd = false;
  self.registerWithBayunOnly = false;
}

-(void)dismissKeyboard
{
  [self.view endEditing:true];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)changeCompanyButtonIsPressed:(id)sender {
  [self showCompanyAlertViewWithDefaultCompanyName:self.defaultCompanyName];
}

- (void) showCompanyAlertViewWithDefaultCompanyName :(NSString*)companyName {
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
      [[SecureAuthentication sharedInstance] setCompanyName:companyNameTextfield.text];
    } else {
      [SVProgressHUD showErrorWithStatus:@"Company name cannot be nil"];
      [self performSelector:@selector(showCompanyAlertViewWithDefaultCompanyName:) withObject:@"" afterDelay:5];
    }
    //}
  }];
}

- (void)showErrorMessage:(NSString*)errorMessage {
  [[[UIAlertView alloc] initWithTitle:@""
                              message:errorMessage
                             delegate:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil] show];
}


#pragma mark - Navigation

-(void)updateUIConstraints {
  if (self.registerWithBayunOnly == true && self.registerBayunWithPwd == true) {
    self.signUpEmailSpacingConstraint.priority = 500;
    self.signupPasswordSpacingConstraint.priority = 999;
    self.emailView.hidden = true;
    self.phoneView.hidden = true;
    self.passwordView.hidden = false;
  } else {
    
    if (self.registerWithBayunOnly == true) {
      self.emailUsernameConstraint.priority = 999;
      self.emailPasswordConstraint.priority = 500;
      self.signUpEmailSpacingConstraint.priority = 999;
      self.phoneView.hidden = true;
      self.passwordView.hidden = true;
      self.emailView.hidden = false;
    } else {
      self.emailView.hidden = false;
      self.phoneView.hidden = false;
      self.passwordView.hidden = false;
      self.signUpEmailSpacingConstraint.priority = 999;
      self.emailPasswordConstraint.priority = 999;
      self.emailUsernameConstraint.priority = 500;
      self.signupPasswordSpacingConstraint.priority = 500;
    }
  }
  
}

- (IBAction)registerWithBayunOnlyBtnIsPressed:(UIButton*)sender {
  if (sender.isSelected) {
    self.registerWithBayunOnly = false;
  } else {
    self.registerWithBayunOnly = true;
  }
  
  [sender setSelected:!sender.isSelected];
  [self updateUIConstraints];
}


- (IBAction)registerWithPwdBtnIsPressed:(UIButton *)sender {
  
  if (sender.isSelected) {
    self.registerBayunWithPwd = false;
  } else {
    self.registerBayunWithPwd = true;
  }
  
  [sender setSelected:!sender.isSelected];
  [self updateUIConstraints];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([@"confirmSignUpSegue" isEqualToString:segue.identifier]){
    ConfirmSignUpViewController *cvc = segue.destinationViewController;
    cvc.sentTo = self.sentTo;
    cvc.user = [self.pool getUser:self.username.text];
  }
}

- (IBAction)signUp:(id)sender {
  NSMutableArray * attributes = [NSMutableArray new];
//  AWSCognitoIdentityUserAttributeType * phone = [AWSCognitoIdentityUserAttributeType new];
//  phone.name = @"phone_number";
//  phone.value = self.phone.text;
  AWSCognitoIdentityUserAttributeType * email = [AWSCognitoIdentityUserAttributeType new];
  email.name = @"email";
  email.value = self.email.text;
  
//  if(![@"" isEqualToString:phone.value]){
//    [attributes addObject:phone];
//  }
  if(![@"" isEqualToString:email.value]){
    [attributes addObject:email];
  }
  
  NSString *password = self.password.text;
  //sign up the user
  if (self.registerWithBayunOnly) {
    [SVProgressHUD show];
    void (^successBlock)(void) = ^{
      [[NSUserDefaults standardUserDefaults] setBool:true forKey:kIsUserLoggedIn];
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        //return to signin screen
        ((SignInViewController *)self.navigationController.viewControllers[0]).usernameText = self.username.text;
        [self.navigationController popToRootViewControllerAnimated:YES];
      });
    };
    
   
    //Register with Bayun Key Management Server
    BayunAppCredentials *appCredentials = [[BayunAppCredentials alloc] initWithAppId:kBayunAppId
                                                                           appSecret:kBayunAppSecret
                                                                             appSalt:kBayunApplicationSalt
                                                                             baseURL:kBayunBaseURL];
    
    if (![password isEqual:[NSNull null]] && ![password isEqualToString:@""]) {
      [[BayunCore sharedInstance] registerWithCompanyName:self.defaultCompanyName
                                        companyEmployeeId:self.username.text
                                                 password:password
                                      bayunAppCredentials:appCredentials
                                authorizeEmployeeCallback:^(NSString *employeePublicKey) {
        
        NSLog(@"employeePublicKey : %@",employeePublicKey);
        //Authorization of employeePublicKey is Pending
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD dismiss];
          [self showErrorMessage:[Utilities errorStringForBayunError:BayunErrorEmployeeAuthorizationIsPending]];
        });
      } success:^{
        //Bayun Authentication Successful
        successBlock();
      } failure:^(BayunError errorCode) {
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
          NSString *errorStr = [Utilities errorStringForBayunError:errorCode];
          [self showErrorMessage:errorStr];
        });
      }];
    } else {
      
      NSString *email = self.email.text;
      NSString *username = self.username.text;
      if (![email isEqual:[NSNull null]] && ![email isEqualToString:@""] &&
          ![username isEqual:[NSNull null]] && ![username isEqualToString:@""]) {
        [[BayunCore sharedInstance] registerWithCompanyName:self.defaultCompanyName
                                          companyEmployeeId:username
                                                      email:email
                                        isCompanyOwnedEmail:true
                                        bayunAppCredentials:appCredentials
                                 newUserCredentialsCallback:nil
                                  securityQuestionsCallback:nil
                                         passphraseCallback:nil
                                  authorizeEmployeeCallback:^(NSString *employeePublicKey) {
          NSLog(@"employeePublicKey : %@",employeePublicKey);
          //Authorization of employeePublicKey is Pending
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self showErrorMessage:[Utilities errorStringForBayunError:BayunErrorEmployeeAuthorizationIsPending]];
          });
        } success:^{
          //Bayun Authentication Successful
          successBlock();
        } failure:^(BayunError errorCode) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSString *errorStr = [Utilities errorStringForBayunError:errorCode];
            [self showErrorMessage:errorStr];
          });
        }];
      } else {
        [SVProgressHUD dismiss];
      }
    }
  } else {
    [SVProgressHUD show];
    [[SecureAuthentication sharedInstance] signUp:self.pool
                                         username:self.username.text
                                         password:password
                                   userAttributes:attributes
                                   validationData:nil
                             registerBayunWithPwd:self.registerBayunWithPwd
                                        withBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
      
      NSLog(@"Successful signUp user: %@",task.result.user.username);
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if(task.error){
          [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                      message:task.error.userInfo[@"message"]
                                     delegate:nil
                            cancelButtonTitle:@"Ok"
                            otherButtonTitles:nil] show];
        }else if(task.result.user.confirmedStatus != AWSCognitoIdentityUserStatusConfirmed){
          self.sentTo = task.result.codeDeliveryDetails.destination;
          [self performSegueWithIdentifier:@"confirmSignUpSegue" sender:sender];
        }
        else{
          [self.navigationController popToRootViewControllerAnimated:YES];
        }});
      return nil;
    }];
  }
}

/**
 Ensure phone number starts with country code i.e. (+1)
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
  return YES;
}

@end
