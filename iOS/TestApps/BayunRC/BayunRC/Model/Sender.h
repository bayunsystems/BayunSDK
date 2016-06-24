//
//  Sender.h
//  Bayun
//
//  Created by Preeti Gaur on 17/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Sender : NSManagedObject

@property (nonatomic, retain) NSString * extension;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Message *message;

@end
