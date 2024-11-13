//
//  Constants.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const kIsUserLoggedIn = @"Is user loggedIn";
NSString *const kCompany = @"Company name";
NSString *const kSelectedEncryptionPolicy = @"EncryptionPolicy";
NSString *const kSelectedKeyGenPolicy = @"KeyGenPolicy";
NSString *const kInvalidCompany = @"Invalid Company";
NSString *const kNewFileCreated = @"New file is created";
NSString *const kDeleteFile = @"Delete File";
NSString *const kGroupDeleted = @"Group deleted.";
NSString *const kGroupJoined = @"Group joined.";
NSString *const kMemberRemovedSuccessfully = @"Member removed from the group successfully";
NSString *const kMemberAddedSuccessfully = @"Member added to the group successfully";
NSString *const kMemberAlreadyExists = @"Member already exists in Group";
NSString *const kMemberDoesNotExists = @"Member doesnot exists in Group";
NSString *const kEmployeeDoesNotExist = @"Employee doesnot exist";
NSString *const kFileDeletedSuccessfully = @"File is deleted sucessfully.";
NSString *const kPermissionDenied = @"Permission Denied";

NSString *const  kPlaceholderTextView =@"Enter Text Here.\n\nFor this demo, text entered here is locked and saved as text file on S3 server.\nOnly employees from same company can view unlocked text.";

NSString *const kErrorMsgNoTextToSave = @"No text to be saved";
NSString *const kErrorMsgFileNotSaved = @"File could not be saved. Please try again.";
NSString *const kErrorMsgFileNameExists = @"File name already exists.";
NSString *const kErrorMsgInternetConnection = @"Internet appears to be offline";
NSString *const kErrorMsgRequestTimeOut = @"Could not connect to the server. Please try again.";
NSString *const kErrorMsgCouldNotConnectToServer = @"Server is not accessible";
NSString *const kErrorMsgAccessDenied = @"Access Denied.";
NSString *const kErrorMsgDevicePasscodeNotSet = @"Device Passcode is not Set.";

NSString *const kErrorMsgUserInActive = @"Please contact your Admin to activate your account.";
NSString *const kErrorMsgSomethingWentWrong = @"Something went wrong.Please try again";
NSString *const kErrorMsgFileDeletionFailed = @"File could not be deleted. Please try again.";
NSString *const kErrorMsgFileDecryptionFailed = @"File could not be opened.";
NSString *const kErrorMsgPasscodeAuthenticationFailed = @"Passcode Authentication Canceled By User.";

NSString *const kErrorMsgGroupDeletionFailed = @"Sorry, cannot delete group at the moment";
NSString *const kErrorMsgDeleteGroupForNonMember = @"Cannot delete group as you are not a member.";

NSString *const kErrorMsgIncorrectPassphrase = @"Incorrect Passphrase.";
NSString *const kErrorMsgIncorrectPassword = @"Incorrect Password.";
NSString *const kErrorMsgAuthenticationFailed = @"Authentication Failed.";
NSString *const kErrorMsgInvalidCredentials = @"Invalid Credentials.";
NSString *const kErrorMsgInvalidAnswers = @"One or more invalid answers.";
NSString *const kErrorMsgInvalidAppSecret = @"Invalid App Secret";
NSString *const kErrorMsgBayunReauthenticationNeeded = @"Bayun ReAuthentication Is Needed";
NSString *const kErrorMsgAppNotLinked = @"Please link this app with your company employee account via Bayun admin-panel first";

NSString *const kConfirmationMsgToJoinPublicGroup = @"Do you want to join the Public Group?";
NSString *const kConfirmationMsgToDeleteGroup = @"Are you sure you want to delete the Group?";
NSString *const kConfirmationMsgToLeaveGroup = @"Are you sure you want to leave the Group?";

AWSRegionType const CognitoIdentityUserPoolRegion = AWSRegionUSWest2;
NSString *const CognitoIdentityUserPoolId = @"Your Cognito Identity UserPoolId";
NSString *const CognitoIdentityUserPoolAppClientId = @"Your Cognito Identity UserPoolAppClientId";
NSString *const CognitoIdentityUserPoolAppClientSecret = @"Your Cognito Identity UserPoolAppClientSecret";
NSString *const CognitoIdentityPoolId = @"Your Cognito IdentityPoolId";

NSString *const kBayunBaseURL = @"Your Bayun Base URL";
NSString *const kBayunAppId = @"Your Bayun AppId";
NSString *const kBayunApplicationSalt = @"Your Bayun Application Salt";
NSString *const kBayunAppSecret = @"Your Bayun AppSecret";
NSString *const kBayunServerKey = @"Your Bayun Server Public Key";
NSString *const kDefaultCompanyName = @"TestCompany";

@end
