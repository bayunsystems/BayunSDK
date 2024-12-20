//
//  RCConstants.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import "RCConstants.h"

@implementation RCConstants

NSString *const kIsUserLoggedIn = @"isUserLoggedIn";
NSString *const kIsAccessDenied = @"isAccessDenied";

NSString *const kRCPhoneNumber = @"rcPhoneNumber";
NSString *const kRCExtension = @"rcExtension";
NSString *const kRCPassword = @"rcPassword";
NSString *const kRCRefreshToken = @"rcRefreshToken";
NSString *const kRCAccessToken = @"rcAccessToken";
NSString *const kRCAuthTokenExpIn = @"rcAuthTokenExpIn";
NSString *const kRCRefreshTokenExpIn =@"rcRefreshTokenExpIn";
NSString *const kRCLastMessageDate = @"rcLastMessageDate";
NSString *const kRCLastMessageDateString = @"rcLastMessageDateString";
NSString *const kRCServer = @"RCServer";

NSString *const kErrorInternetConnection = @"Internet appears to be offline";
NSString *const kErrorRequestTimeOut = @"Could not connect to the server. Please try again.";
NSString *const kErrorCouldNotConnectToServer = @"Server is not accessible";
NSString *const kErrorAccessDenied = @"Access is denied";
NSString *const kErrorSomethingWentWrong = @"Something went wrong. Please try again";
NSString *const kErrorIncorrectPasscode = @"Incorrect Passphrase.";
NSString *const kErrorInvalidCredentials = @"Invalid Credentials.";
NSString *const kErrorAccountIsLocked = @"The account is locked out due to multiple unsuccessful logon attempts. Please use Single Sign-on way to authenticate.";
NSString *const kErrorUserInActive = @"Please contact your Admin to activate your account.";
NSString *const kErrorBayunAuthenticationIsNeeded = @"Bayun Authentication is Needed.";
NSString *const kErrorSessionIsExpired = @"Session is expired.";
NSString *const kErrorCompleteAllFields = @"Complete all fields";
NSString *const kErrorMessageCouldNotBeSent = @"Message could not be sent.";
NSString *const kErrorMsgAuthenticationFailed = @"Authentication Failed.";
NSString *const kErrorMsgAppNotLinked = @"Please link this app with your company employee account via Bayun admin-panel first";
NSString *const kErrorMsgPasscodeAuthenticationFailed = @"Passcode Authentication Canceled By User.";
NSString *const kErrorMsgDevicePasscodeNotSet = @"Device Passcode Is Not Set";
NSString *const kErrorMsgAdminRegistrationIncomplete = @"Please contact your Admin to complete his Bayun registration.";
NSString *const kErrorMsgEmployeeAppIsNotRegistered = @"Employee App is not registered";
NSString *const kErrorRegistrationFailedAppNotApproved = @"Registration failed as the application is not approved. Please contact your Admin for approval.";

@end
