//
//  NSSortDescriptor+Helpers.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 30/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSSortDescriptor+Helpers.h"

@implementation NSSortDescriptor (Helpers)

+ (NSArray *)sortDescriptorsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *descriptors = [NSMutableArray arrayWithCapacity:dictionary.count];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSNumber class]])
        {
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:[obj boolValue]];
            [descriptors addObject:sortDescriptor];
        }
    }];
    return descriptors;
}

@end
