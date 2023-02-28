//
//  Utilities.m
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2023 Bayun Systems, Inc. All rights reserved.
//

#import "Utilities.h"
#import "NSDate+TimeAgoConversion.h"
#import <Bayun/BayunCore.h>


@implementation Utilities

+ (id)getFileSize:(id)value {
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"Bytes",@"KB",@"MB",@"GB",@"TB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.0f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString*)getCurrentTimeStampDateString:(NSDate*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSString *dateAsString = [formatter stringFromDate:date];
    return [[formatter dateFromString:dateAsString] timeAgo];
}

+ (void)clearKeychainAndUserDefaults {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCompany];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSelectedKeyGenPolicy];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSelectedEncryptionPolicy];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)logoutUser:(AWSCognitoIdentityUser *)user {
    [[SecureAuthentication sharedInstance] signOut:user];
    [[user getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [Utilities  clearKeychainAndUserDefaults];
                [[BayunCore sharedInstance] logout];
                [SVProgressHUD showErrorWithStatus:task.error.userInfo[NSLocalizedDescriptionKey]];
                //[self.navigationController setToolbarHidden:YES];
            }else {
                //self.response = task.result;
                //self.title = self.user.username;
                //[self.tableView reloadData];
               // [self.navigationController setToolbarHidden:NO];
            }
        });
        return nil;
    }];
}

+ (NSString*)errorStringForBayunError:(BayunError)bayunError {
  
  if (bayunError == BayunErrorAuthenticationFailed) {
    return @"Bayun Authentication Failed.";
  } else if (bayunError == BayunErrorInvalidAppSecret) {
    return @"Invalid App Secret";
  } else if(bayunError == BayunErrorPasscodeAuthenticationCanceledByUser) {
    return @"Passscode Authentication Canceled by User.";
  } else if(bayunError == BayunErrorOneOrMoreIncorrectAnswers) {
    return @"One or more invalid answers.";
  }   else if(bayunError == BayunErrorInvalidPassword) {
    return @"Invalid Password.";
  } else if(bayunError == BayunErrorInvalidPassphrase) {
    return @"Invalid Passphrase.";
  } else if (bayunError ==  BayunErrorCompanyDoesNotExists) {
    return @"Invalid Company Name";
  } else if(bayunError == BayunErrorInvalidCredentials) {
    return @"Invalid Credentials";
  } else if(bayunError == BayunErrorInvalidAppId) {
    return @"Invalid App Id.";
  }else if(bayunError == BayunErrorDevicePasscodeNotSet) {
    return @"Device Passcode is not set.";
  } else if(bayunError == BayunErrorAppNotLinked) {
    return @"App is not linked. Login to the Admin Panel/App and link the app.";
  } else if(bayunError == BayunErrorUserInActive) {
    return @"Please contact your Admin to activate your account.";
  } else if (bayunError == BayunErrorInvalidAppSecret) {
    return @"Invalid App Secret.";
  } else if(bayunError == BayunErrorCouldNotConnectToServer) {
    return @"Could not connect to the Server";
  } else if (bayunError == BayunErrorEmployeeAlreadyExists) {
    return @"Employee already exists";
  } else if (bayunError == BayunErrorEmployeeDoesNotExists) {
    return @"Employee does not exists";
  } else if (bayunError == BayunErrorEmployeeAccountHasPasswordEnabled) {
    return @"Password is enabled for the account being registered without password";
  } else if (bayunError == BayunErrorUserAlreadyExists) {
    return @"User already exists";
  } else if (bayunError == BayunErrorLinkEmployeeUserAccount) {
    return @"Login to Admin Panel to link this User account with the existing Employee account to continue using the SDK APIs.";
  } else if (bayunError == BayunErrorUserAccountHasPasswordEnabled) {
    return @"User password is already enabled for the account being registered";
  } else if (bayunError == BayunErrorEmployeeNotLinkedToApp) {
    return @"Employee Account is not linked to the App";
  } else if (bayunError == BayunErrorUserIsNotRegistered) {
    return @"User is not registered";
  } else if (bayunError == BayunErrorEmployeeAppNotRegistered) {
    return @"Employee App is not registered";
  } else if (bayunError == BayunErrorEmployeeAuthorizationIsPending) {
    return @"Employee Authorization is Pending";
  } else if (bayunError == BayunErrorRegistrationFailedAppNotApproved) {
    return @"Registration failed as the application is not approved. Please contact your Admin for approval.";
  }  else  {
    return @"Something went wrong.";
  }
}


@end
