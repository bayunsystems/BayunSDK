//
//  Message.h
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conversation, Receiver, Sender;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageStatus;
@property (nonatomic, retain) NSString * readStatus;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) Sender *from;
@property (nonatomic, retain) NSOrderedSet *to;
@property (nonatomic, retain) Conversation *conversation;
@property (nonatomic, retain) Conversation *lastMessageConversation;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)insertObject:(Receiver *)value inToAtIndex:(NSUInteger)idx;
- (void)removeObjectFromToAtIndex:(NSUInteger)idx;
- (void)insertTo:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeToAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInToAtIndex:(NSUInteger)idx withObject:(Receiver *)value;
- (void)replaceToAtIndexes:(NSIndexSet *)indexes withTo:(NSArray *)values;
- (void)addToObject:(Receiver *)value;
- (void)removeToObject:(Receiver *)value;
- (void)addTo:(NSOrderedSet *)values;
- (void)removeTo:(NSOrderedSet *)values;
@end
