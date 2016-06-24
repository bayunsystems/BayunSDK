//
//  NSPredicate+Helpers.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 30/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSPredicate+Helpers.h"

@implementation NSPredicate (Helpers)

+ (instancetype)predicateFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:dictionary.count];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop)
     {
         NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
         [predicates addObject:predicate];
     }];
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

@end
