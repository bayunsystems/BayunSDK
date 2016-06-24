//
//  NSManagedObjectContext+Stack.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, NSSaveType)
{
    NSSaveSelf,
    NSSaveSelfAndParent,
    NSSavePersistentStore
};

@interface NSManagedObjectContext (Saving)

- (void)save;
- (void)saveOnCompletion:(void(^)(BOOL success, NSError *error))completion;

- (void)saveWithType:(NSSaveType)type;
- (void)saveWithType:(NSSaveType)type completion:(void(^)(BOOL success, NSError *error))completion;

- (void)saveWithTypeAndWait:(NSSaveType)type;

@end


@interface NSManagedObjectContext (Merging)

- (void)observeContext:(NSManagedObjectContext *)otherContext;
- (void)stopObservingContext:(NSManagedObjectContext *)otherContext;

@end