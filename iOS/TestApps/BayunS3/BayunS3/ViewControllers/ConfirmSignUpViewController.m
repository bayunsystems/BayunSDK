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

#import "ConfirmSignUpViewController.h"
#import <Bayun/BayunCore.h>
#import "SecureAuthentication.h"
//#import "SignInViewController.h"

@interface ConfirmSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UILabel *sentToLabel;
@end

@implementation ConfirmSignUpViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.username.text = self.user.username;
    self.sentToLabel.text = [NSString stringWithFormat:@"Code sent to: %@", self.sentTo];
}

#pragma mark - Navigation

- (IBAction)confirm:(id)sender {
    [SVProgressHUD show];
    [[SecureAuthentication sharedInstance] confirmSignUpForUser:self.user confirmationCode:self.code.text forceAliasCreation:YES withBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse *> * _Nonnull task) {
        [SVProgressHUD dismiss];
            if(task.error){
                dispatch_async(dispatch_get_main_queue(), ^{

                  if([[task.error.userInfo valueForKey:@"NSLocalizedDescription"] isEqualToString:@"Employee Authorization is Pending"]) {
                    
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@""
                                                 message:[task.error.userInfo valueForKey:@"NSLocalizedDescription"]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    //Add Buttons
                    UIAlertAction* okButton = [UIAlertAction
                                                actionWithTitle:@"Ok"
                                                style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                        //return to signin screen
                        ((SignInViewController *)self.navigationController.viewControllers[0]).usernameText = self.user.username;
                        [self.navigationController popToRootViewControllerAnimated:YES];
                      });
                    }];
                    
                    [alert addAction:okButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                  } else if([task.error.userInfo valueForKey:@"NSLocalizedDescription"]) {
                      [[[UIAlertView alloc] initWithTitle:@""
                                                  message:[task.error.userInfo valueForKey:@"NSLocalizedDescription"]
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"OK", nil] show];
                    } else {
                        // [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
                        [[[UIAlertView alloc] initWithTitle:@""
                                                    message:kErrorMsgSomethingWentWrong
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil] show];
                    }
                });
            }else {
              dispatch_async(dispatch_get_main_queue(), ^{
                //return to signin screen
                ((SignInViewController *)self.navigationController.viewControllers[0]).usernameText = self.user.username;
                [self.navigationController popToRootViewControllerAnimated:YES];
              });
            }
        return nil;
    }];
}

- (IBAction)resend:(id)sender {
    //resend the confirmation code
    [[self.user resendConfirmationCode] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                            message:task.error.userInfo[@"message"]
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }else {
                [[[UIAlertView alloc] initWithTitle:@"Code Resent"
                                       message:[NSString stringWithFormat:@"Code resent to: %@", task.result.codeDeliveryDetails.destination]
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] show];
            }
        });
        return nil;
    }];
}
@end
