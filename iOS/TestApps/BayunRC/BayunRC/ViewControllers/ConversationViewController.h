//
//  ConversationViewController.h
//  Bayun
//
//  Created by Preeti Gaur on 20/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSQMessages.h"

@class Conversation,User;
@interface ConversationViewController : JSQMessagesViewController <UINavigationControllerDelegate,JSQMessagesCollectionViewDataSource>

@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) Conversation *conversation;
@property (strong, nonatomic) User *chatParticipant;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end
