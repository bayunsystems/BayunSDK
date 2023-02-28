//
//  RCMessage.m
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2023 Bayun Systems, Inc. All rights reserved.
//

#import "RCMessage.h"
#import "Message.h"
#import "User.h"
#import "Sender.h"
#import "Receiver.h"
#import "RCCryptManager.h"
#import <Bayun/BayunError.h>


@interface RCMessage()

@property (strong, nonatomic) Message *message;
@property (strong, nonatomic) id media;
@property (assign) CGSize originalMediaSize;
@property (assign, nonatomic) BOOL isdecrypted;
@property (strong, nonatomic) NSString *decryptedMessage;


@end

/**
 *
 */
@implementation RCMessage

-(id)initWithMessage:(Message *)message {
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

-(NSString *)text {
    
    //    __block NSString *message = self.message.subject;
    //    [[RCCryptManager sharedInstance] decryptText:self.message.subject success:^(NSString *decryptedMessage) {
    //        message =  decryptedMessage;
    //    } failure:^(BayunError error) {
    //        message = self.message.subject;
    //    }];
    
    if (self.isdecrypted) {
        return self.decryptedMessage;
    }
    __block NSString *message = self.message.subject;
    
    if (message != nil) {
        
        [[RCCryptManager sharedInstance] decryptText:message success:^(NSString *decryptedMessage) {
            message =  decryptedMessage;
            self.decryptedMessage = decryptedMessage;
            self.isdecrypted = true;
        } failure:^(BayunError error) {
            message = self.message.subject;
            self.decryptedMessage = nil;
        }];
    }
    
    return message;
}

-(NSString *)senderId {
    return  self.message.from.extension;
}

-(BOOL) isOutgoing {
    return [self.message.from.extension isEqualToString:[[RCUtilities appUser] extension]];
}

-(NSString *) senderDisplayName {
   return  self.message.from.name;
}

-(BOOL)showSender {
    return NO;
}

-(id)media {
    return nil;
}

-(NSDate *)date {
    return self.message.creationTime;
}

-(Message *)message {
    return _message;
}

- (NSUInteger)hash {
    NSUInteger contentHash;
    contentHash = self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

-(BOOL) isMediaMessage {
    return NO;
}

@end
