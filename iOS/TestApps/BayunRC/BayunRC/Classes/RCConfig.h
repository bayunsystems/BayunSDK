//
//  RCConfig.h
//  Bayun
//
//  Created by Preeti Gaur on 02/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kApplicationKeySandbox          @"Your Sandbox Application Key"
#define kApplicationSecretKeySandbox    @"Your Sandbox Secret Key"

#define kApplicationKeyProd             @"Your Production Application Key"
#define kApplicationSecretKeyProd       @"Your Production Secret Key"

#define kBayunAppId                     @"Bayun AppId"

#define kRCLoginURL                     @"/restapi/oauth/token"
#define kRCGetMessageList               @"/restapi/v1.0/account/~/extension/~/message-store?messageType=Pager"
#define kRCSendPagerMessage             @"/restapi/v1.0/account/~/extension/~/company-pager"
#define kRCGetExtensionsList            @"/restapi/v1.0/account/~/extension"

#define kTimeToRefreshConversationView  10.0

