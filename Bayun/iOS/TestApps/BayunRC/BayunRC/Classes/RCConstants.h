//
//  RCConstants.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCConstants : NSObject

extern NSString *const kIsAccessDenied;
extern NSString *const kIsUserLoggedIn;

extern NSString *const kRCPhoneNumber;
extern NSString *const kRCExtension;
extern NSString *const kRCPassword;
extern NSString *const kRCAccessToken;
extern NSString *const kRCAuthTokenExpIn;
extern NSString *const kRCRefreshToken;
extern NSString *const kRCRefreshTokenExpIn;
extern NSString *const kRCLastMessageDate;
extern NSString *const kRCLastMessageDateString;

extern NSString *const kErrorUserInActive;
extern NSString *const kErrorInternetConnection;
extern NSString *const kErrorRequestTimeOut;
extern NSString *const kErrorCouldNotConnectToServer;
extern NSString *const kErrorAccessDenied;
extern NSString *const kErrorSomethingWentWrong;
extern NSString *const kErrorIncorrectPasscode;
extern NSString *const kErrorInvalidCredentials;
extern NSString *const kErrorSessionIsExpired;
extern NSString *const kErrorCompleteAllFields;
extern NSString *const kErrorMessageCouldNotBeSent;
@end
