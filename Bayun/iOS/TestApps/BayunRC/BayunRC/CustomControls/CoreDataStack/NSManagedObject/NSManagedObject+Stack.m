//
//  NSManagedObject+Stack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSManagedObject+Stack.h"
#import "CoreDataStack.h"
#import "NSError+Stack.h"

@implementation NSManagedObject (Stack)

+ (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = [[CoreDataStack defaultStack] managedObjectContext];
    if (!context)
    {
        [NSException raise:@"NSManagedObjectContext not found" format:@"No default stack is set."];
    }
    return context;
}

+ (NSInteger)defaultBatchSize
{
    return 20;
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request
{
    return [self executeFetchRequest:request inContext:[self managedObjectContext]];
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    if (!request) {
        return nil;
    }
    
    __block NSArray *results = nil;
    [context performBlockAndWait:^
    {
        NSError *error = nil;
        results = [context executeFetchRequest:request error:&error];
        if (results == nil)
        {
            [error log];
        }
    }];
	return results;
}

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request
{
    return [self executeFetchRequestAndReturnFirstObject:request inContext:[self managedObjectContext]];
}

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    if (!request) {
        return nil;
    }
    
	request.fetchLimit = 1;
	NSArray *results = [self executeFetchRequest:request inContext:context];
	if ([results count] == 0)
	{
		return nil;
	}
	return [results lastObject];
}

+ (NSUInteger)countFetchRequest:(NSFetchRequest *)request
{
    return [self countFetchRequest:request inContext:[self managedObjectContext]];
}

+ (NSUInteger)countFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    if (!request) {
        return 0;
    }
    
    NSError *error = nil;
	NSUInteger count = [context countForFetchRequest:request error:&error];
    if (count == NSNotFound)
    {
        [error log];
        return 0;
    }
    return count;
}

@end
