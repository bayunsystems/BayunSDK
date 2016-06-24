//
//  RCConstants.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
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

NSString *const kErrorInternetConnection = @"Internet appears to be offline";
NSString *const kErrorRequestTimeOut = @"Could not connect to the server. Please try again.";
NSString *const kErrorCouldNotConnectToServer = @"Server is not accessible";
NSString *const kErrorAccessDenied = @"Access is denied";
NSString *const kErrorSomethingWentWrong = @"Something went wrong. Please try again";
NSString *const kErrorIncorrectPasscode = @"Incorrect Passcode.";
NSString *const kErrorInvalidCredentials = @"Invalid Credentials.";
NSString *const kErrorUserInActive = @"Please contact your Admin to activate your account.";
NSString *const kErrorSessionIsExpired = @"Session is expired.";
NSString *const kErrorCompleteAllFields = @"Complete all fields";
NSString *const kErrorMessageCouldNotBeSent = @"Message could not be sent.";
@end
