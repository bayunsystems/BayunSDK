//
//  NSManagedObject+Resource.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 02/01/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObjectCollection.h"

@interface NSManagedObject (Resource)

+ (id <NSManagedObjectCollection>)all;
+ (id <NSManagedObjectCollection>)allInContext:(NSManagedObjectContext *)context;

+ (id <NSManagedObjectCollection>)findBy:(NSDictionary *)by;
+ (id <NSManagedObjectCollection>)findBy:(NSDictionary *)by inContext:(NSManagedObjectContext *)context;

+ (id <NSManagedObjectCollection>)findWhere:(NSString *)where;
+ (id <NSManagedObjectCollection>)findWhere:(NSString *)where inContext:(NSManagedObjectContext *)context;

+ (id <NSManagedObjectCollection>)findWithPredicate:(NSPredicate *)predicate;
+ (id <NSManagedObjectCollection>)findWithPredicate:(NSPredicate *)predicate inContext:(NSManagedObjectContext *)context;

+ (instancetype)create;
+ (instancetype)createInContext:(NSManagedObjectContext *)context;

+ (void)deleteAll;
+ (void)deleteAllInContext:(NSManagedObjectContext *)context;

+ (instancetype)objectById:(NSManagedObjectID *)objectId;

- (void)delete;
- (void)save;
- (void)saveOnCompletion:(void(^)(BOOL success, NSError *error))completion;

@end
