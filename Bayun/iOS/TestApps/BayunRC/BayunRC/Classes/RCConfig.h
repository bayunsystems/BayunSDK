//
//  RCConfig.h
//  Bayun
//
//  Created by Preeti Gaur on 02/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kRCLoginURL                     @"/restapi/oauth/token"
#define kRCGetMessageList               @"/restapi/v1.0/account/~/extension/~/message-store?messageType=Pager"
#define kRCSendPagerMessage             @"/restapi/v1.0/account/~/extension/~/company-pager"
#define kRCGetExtensionsList            @"/restapi/v1.0/account/~/extension"
#define kApplicationKey                 @"M-bmKDClTeC-gQrj6PKTIA"
#define kApplicationSecretKey           @"Xt-Qnk2hS-ik8gxptWubBA2kFzlQ5KRf2FURpmjwkPeQ"

#define kApplicationKeyProd             @"ca8131daB66F7c186fd162be0A12831C79c76374598392b59252338bccc98fcf"
#define kApplicationSecretKeyProd       @"126846BFa18ac532ca4d0dfc4250ee3816fe867561072F5BC0601136fbc96028"

#define kTimeToRefreshConversationView  10.0

