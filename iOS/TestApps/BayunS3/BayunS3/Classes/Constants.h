//
//  Constants.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSServiceEnum.h"

@interface Constants : NSObject

extern NSString *const kCompany;
extern NSString *const kEncryptionPolicy;

extern NSString *const kIsUserLoggedIn;
extern NSString *const kPlaceholderTextView ;
extern NSString *const kNewFileCreated;

extern NSString *const kDeleteFile;
extern NSString *const kInvalidCompany;
extern NSString *const kGroupDeleted;
extern NSString *const kGroupJoined;
extern NSString *const kMemberRemovedSuccessfully;
extern NSString *const kMemberAddedSuccessfully;
extern NSString *const kMemberAlreadyExists;
extern NSString *const kMemberDoesNotExists;
extern NSString *const kEmployeeDoesNotExist;
extern NSString *const kGroupJoined;
extern NSString *const kFileDeletedSuccessfully;
extern NSString *const kPermissionDenied;

extern NSString *const kErrorMsgNoTextToSave;
extern NSString *const kErrorMsgFileNotSaved;
extern NSString *const kErrorMsgFileNameExists;
extern NSString *const kErrorMsgInternetConnection;
extern NSString *const kErrorMsgRequestTimeOut;
extern NSString *const kErrorMsgCouldNotConnectToServer;
extern NSString *const kErrorMsgAccessDenied;
extern NSString *const kErrorMsgSomethingWentWrong;
extern NSString *const kErrorMsgFileDeletionFailed;

extern NSString *const kErrorMsgIncorrectPassphrase;
extern NSString *const kErrorMsgInvalidCredentials;
extern NSString *const kErrorMsgUserInActive;
extern NSString *const kErrorMsgAppNotLinked;
extern NSString *const kErrorMsgIncorrectPassword;
extern NSString *const kErrorMsgAuthenticationFailed;

extern NSString *const kErrorMsgGroupDeletionFailed;
extern NSString *const kErrorMsgDeleteGroupForNonMember;

extern NSString *const kConfirmationMsgToJoinPublicGroup;
extern NSString *const kConfirmationMsgToDeleteGroup;
extern NSString *const kConfirmationMsgToLeaveGroup;



extern AWSRegionType const CognitoIdentityUserPoolRegion;
extern NSString *const CognitoIdentityUserPoolId;
extern NSString *const CognitoIdentityUserPoolAppClientId;
extern NSString *const CognitoIdentityUserPoolAppClientSecret;
extern NSString *const CognitoIdentityPoolId;

extern NSString *const BayunAppId;


@end
