//
//  NSManagedObject+Resource.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 02/01/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import "NSManagedObject+Resource.h"
#import "NSManagedObject+Stack.h"
#import "NSManagedObjectContext+Stack.h"
#import "NSPredicate+Helpers.h"

@implementation NSManagedObject (Resource)

+ (id <NSManagedObjectCollection>)all
{
   return [self collection];
}

+ (id <NSManagedObjectCollection>)allInContext:(NSManagedObjectContext *)context
{
    return [self collectionWithContext:context];
}

+ (id <NSManagedObjectCollection>)findBy:(NSDictionary *)by
{
    NSManagedObjectCollection *collection = [self collection];
    [collection.fetchRequest setPredicate:[NSPredicate predicateFromDictionary:by]];
    return collection;
}

+ (id <NSManagedObjectCollection>)findBy:(NSDictionary *)by inContext:(NSManagedObjectContext *)context
{
    NSManagedObjectCollection *collection = [self collectionWithContext:context];
    [collection.fetchRequest setPredicate:[NSPredicate predicateFromDictionary:by]];
    return collection;
}

+ (id <NSManagedObjectCollection>)findWhere:(NSString *)where
{
    NSManagedObjectCollection *collection = [self collection];
    [collection.fetchRequest setPredicate:[NSPredicate predicateWithFormat:where]];
    return collection;
}

+ (id <NSManagedObjectCollection>)findWhere:(NSString *)where inContext:(NSManagedObjectContext *)context
{
    NSManagedObjectCollection *collection = [self collectionWithContext:context];
    [collection.fetchRequest setPredicate:[NSPredicate predicateWithFormat:where]];
    return collection;
}

+ (id <NSManagedObjectCollection>)findWithPredicate:(NSPredicate *)predicate
{
    NSManagedObjectCollection *collection = [self collection];
    [collection.fetchRequest setPredicate:predicate];
    return collection;
}

+ (id <NSManagedObjectCollection>)findWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context
{
    NSManagedObjectCollection *collection = [self collectionWithContext:context];
    [collection.fetchRequest setPredicate:predicate];
    return collection;
}

+ (instancetype)create
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:self.managedObjectContext];
}

+ (instancetype)createInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

+ (void)deleteAll
{
    [[self all] delete];
}

+ (void)deleteAllInContext:(NSManagedObjectContext *)context
{
    [[self allInContext:context] delete];
}

+ (instancetype)objectById:(NSManagedObjectID *)objectId
{
    return [self.managedObjectContext objectWithID:objectId];
}

- (void)delete
{
    if (self.managedObjectContext == nil) {
        return;
    }
    [self.managedObjectContext deleteObject:self];
}

- (void)save
{
    [[[self class] managedObjectContext] save];
}

- (void)saveOnCompletion:(void(^)(BOOL success, NSError *error))completion
{
    [[[self class] managedObjectContext] saveOnCompletion:completion];
}

#pragma mark - Private

+ (NSManagedObjectCollection *)collection
{
    return [self collectionWithContext:self.managedObjectContext];
}

+ (NSManagedObjectCollection *)collectionWithContext:(NSManagedObjectContext *)context
{
    NSManagedObjectCollection *collection = [[NSManagedObjectCollection alloc] initWithClass:self.class];
    collection.managedObjectContext = context;
    return collection;
}

@end
