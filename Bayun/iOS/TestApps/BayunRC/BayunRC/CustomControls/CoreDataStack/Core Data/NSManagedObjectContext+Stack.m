//
//  NSManagedObjectContext+Stack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSManagedObjectContext+Stack.h"
#import "NSError+Stack.h"

typedef void(^NSManagedObjectContextPerformBlock)();
typedef void(^NSManagedObjectContextCompletionBlock)(BOOL success, NSError *error);

@implementation NSManagedObjectContext (Saving)

- (void)save
{
    [self performSaveWithType:NSSaveSelf shouldWait:NO completion:nil];
}

- (void)saveOnCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [self performSaveWithType:NSSaveSelf shouldWait:NO completion:completion];
}

- (void)saveWithType:(NSSaveType)type
{
    [self performSaveWithType:type shouldWait:NO completion:nil];
}

- (void)saveWithType:(NSSaveType)type completion:(void(^)(BOOL success, NSError *error))completion
{
    [self performSaveWithType:type shouldWait:NO completion:completion];
}

- (void)saveWithTypeAndWait:(NSSaveType)type
{
    [self performSaveWithType:type shouldWait:YES completion:nil];
}

- (void)performSaveWithType:(NSSaveType)type shouldWait:(BOOL)wait completion:(void(^)(BOOL success, NSError *error))completion
{
    NSManagedObjectContextCompletionBlock finish = ^(BOOL success, NSError *error)
    {
        if (!self.parentContext || type == NSSaveSelf)
        {
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(success, error);
                });
            }
        }
        else if (type == NSSaveSelfAndParent && self.parentContext)
        {
            [self.parentContext performSaveWithType:NSSaveSelf shouldWait:wait completion:completion];
        }
        else if (type == NSSavePersistentStore && self.parentContext)
        {
            [self.parentContext performSaveWithType:NSSavePersistentStore shouldWait:wait completion:completion];
        }
    };
    
    NSManagedObjectContextPerformBlock performBlock = ^
    {
        NSError *error = nil;
        BOOL     saved = NO;
        
        saved = [self save:&error];
        if (!saved)
        {
            [error log];
            if (completion)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(saved, error);
                });
            }
            return;
        }
        
        finish(saved, error);
    };
    
    if (![self hasChanges])
    {
        finish(NO, nil);
        return;
    }
    wait ? [self performBlockAndWait:performBlock] : [self performBlock:performBlock];
}

@end

@implementation NSManagedObjectContext (Merging)

- (void)observeContext:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)observeContextOnMainThread:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesOnMainThread:) name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)stopObservingContext:(NSManagedObjectContext *)context
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:context];
}

- (void)mergeChanges:(NSNotification *)notification;
{
    [self mergeChangesFromContextDidSaveNotification:notification];
}

- (void)mergeChangesOnMainThread:(NSNotification *)notification;
{
    if ([NSThread isMainThread])
    {
        [self mergeChanges:notification];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(mergeChanges:) withObject:notification waitUntilDone:YES];
    }
}

@end
