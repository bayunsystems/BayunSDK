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

#import "SignUpViewController.h"
#import "AWSCognitoIdentityProvider.h"
#import "ConfirmSignUpViewController.h"
#import "AWSCognitoIdentityUserPool.h"
#import "DLAVAlertViewTheme.h"
#import "DLAVAlertView.h"
#import "SecureAuthentication.h"

@interface SignUpViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@property (nonatomic, strong) NSString* sentTo;
@property (strong,nonatomic) NSString *defaultCompanyName;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    
    self.defaultCompanyName = @"BayunS3Pool";
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


#pragma mark - Navigation

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
    AWSCognitoIdentityUserAttributeType * phone = [AWSCognitoIdentityUserAttributeType new];
    phone.name = @"phone_number";
    phone.value = self.phone.text;
    AWSCognitoIdentityUserAttributeType * email = [AWSCognitoIdentityUserAttributeType new];
    email.name = @"email";
    email.value = self.email.text;
    
    if(![@"" isEqualToString:phone.value]){
        [attributes addObject:phone];
    }
    if(![@"" isEqualToString:email.value]){
        [attributes addObject:email];
    }
    
    //sign up the user
    
    [SVProgressHUD show];
    [[SecureAuthentication sharedInstance] signUp:self.pool
                                         username:self.username.text password:self.password.text userAttributes:attributes validationData:nil withBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
                                                 
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

/**
 Ensure phone number starts with country code i.e. (+1)
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
    if(textField == self.phone){
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\+(|\\d)*$" options:0 error:nil];
        NSString *proposedPhone = [self.phone.text stringByReplacingCharactersInRange:range withString:string];
        if(proposedPhone.length != 0){
            return [regex numberOfMatchesInString:proposedPhone options:NSMatchingAnchored range:NSMakeRange(0, proposedPhone.length)]== 1;
        }
    }
    return YES;
}

@end
