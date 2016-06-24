//
//  RCMessage.h
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessageData.h"
@class Message;

@interface RCMessage : NSObject<JSQMessageData>

- (id)initWithMessage:(Message *)message;

@end
