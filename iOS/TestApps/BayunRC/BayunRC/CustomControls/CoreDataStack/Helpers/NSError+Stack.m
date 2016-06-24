//
//  NSError+Stack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 01/01/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import "NSError+Stack.h"

@implementation NSError (Stack)

- (void)log
{
    if (![[self domain] isEqualToString:@"NSCocoaErrorDomain"])
    {
        return;
    }
    
    NSDictionary *userInfo = [self userInfo];
    for (NSArray *detailedError in [userInfo allValues])
    {
        if ([detailedError isKindOfClass:[NSArray class]])
        {
            for (NSError *e in detailedError)
            {
                if ([e respondsToSelector:@selector(userInfo)])
                {
                    NSLog(@"Error Details: %@", [e userInfo]);
                }
                else
                {
                    NSLog(@"Error Details: %@", e);
                }
            }
        }
        else
        {
            NSLog(@"Error: %@", detailedError);
        }
    }
    NSLog(@"Error Message: %@", [self localizedDescription]);
    NSLog(@"Error Domain: %@", [self domain]);
    NSLog(@"Recovery Suggestion: %@", [self localizedRecoverySuggestion]);
}

@end
