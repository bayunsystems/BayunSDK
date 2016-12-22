//
//  Constants.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const kIsUserLoggedIn = @"Is user loggedIn";

NSString *const kBucketExists = @"Is bucket exists";
NSString *const kS3BucketName = @"AWS3 bucket name";
NSString *const kCompanyName = @"Company name";

NSString *const kNewFileCreated = @"New file is created";
NSString *const  kPlaceholderTextView =@"Enter Text Here.\n\nFor this demo, text entered here is locked and saved as text file on S3 server.\nOnly employees from same company can view unlocked text.";

NSString *const kErrorMsgNoTextToSave = @"No text to be saved";
NSString *const kErrorMsgFileNotSaved = @"File could not be saved. Please try again.";
NSString *const kErrorMsgFileNameExists = @"File name already exists.";
NSString *const kErrorMsgInternetConnection = @"Internet appears to be offline";
NSString *const kErrorMsgRequestTimeOut = @"Could not connect to the server. Please try again.";
NSString *const kErrorMsgCouldNotConnectToServer = @"Server is not accessible";
NSString *const kErrorMsgAccessDenied = @"Access Denied.";
NSString *const kErrorMsgPermissionDenied = @"Permission Denied";
NSString *const kErrorMsgUserInActive = @"Please contact your Admin to activate your account.";
NSString *const kErrorMsgSomethingWentWrong = @"Something went wrong.Please try again";
NSString *const kErrorMsgFileDeletionFailed = @"File could not be deleted. Please try again.";
NSString *const kErrorMsgIncorrectPasscode = @"Incorrect Passcode.";
NSString *const kErrorMsgIncorrectPassword = @"Incorrect Password.";
NSString *const kErrorMsgAuthenticationFailed = @"Authentication Failed.";
NSString *const kErrorMsgInvalidCredentials = @"Invalid Credentials.";
NSString *const kErrorMsgAppNotLinked = @"Please link this app with your company employee account via Bayun admin-panel first";


@end
