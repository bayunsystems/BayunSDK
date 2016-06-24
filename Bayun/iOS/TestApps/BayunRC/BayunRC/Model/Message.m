//
//  Message.m
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "Message.h"
#import "Conversation.h"
#import "Receiver.h"
#import "Sender.h"


@implementation Message

@dynamic creationTime;
@dynamic direction;
@dynamic messageId;
@dynamic messageStatus;
@dynamic readStatus;
@dynamic subject;
@dynamic from;
@dynamic to;
@dynamic conversation;
@dynamic lastMessageConversation;

@end
