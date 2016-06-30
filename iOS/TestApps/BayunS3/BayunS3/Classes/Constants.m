//
//  Constants.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const kIsUserLoggedIn = @"isUserLoggedIn";

NSString *const kBucketExists = @"isBucketExists";
NSString *const kS3BucketName = @"s3BucketName";
NSString *const kCompanyName = @"companyName";

NSString *const kNewFileCreated = @"newFileIsCreated";
NSString *const  kPlaceholderTextView =@"Enter Text Here.\n\nFor this demo, text entered here is encrypted and saved as text file on S3 server.\nOnly employees from same company can view decrypted text.";

NSString *const kErrorMsgNoTextToSave = @"No text to be saved";
NSString *const kErrorMsgInternetConnection = @"Internet appears to be offline";
NSString *const kErrorMsgRequestTimeOut = @"Could not connect to the server. Please try again.";
NSString *const kErrorMsgCouldNotConnectToServer = @"Server is not accessible";
NSString *const kErrorMsgAccessDenied = @"Access Denied.";
NSString *const kErrorMsgUserInActive = @"Please contact your Admin to activate your account.";
NSString *const kErrorMsgSomethingWentWrong = @"Something went wrong.Please try again";
NSString *const kErrorMsgEncryptionFailed = @"Encryption failed.";
NSString *const kErrorMsgDecryptionFailed = @"Decryption failed.";
NSString *const kErrorMsgFileDeletionFailed = @"File could not be deleted. Please try again.";
NSString *const kErrorMsgIncorrectPasscode = @"Incorrect Passcode.";
NSString *const kErrorMsgInvalidCredentials = @"Invalid Credentials.";
NSString *const kErrorMsgAppNotLinked = @"This app is not linked with your Employee Account";


@end
