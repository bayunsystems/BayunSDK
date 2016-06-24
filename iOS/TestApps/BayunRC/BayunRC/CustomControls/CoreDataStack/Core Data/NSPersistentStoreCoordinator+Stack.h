//
//  NSPersistentStoreCoordinator+Stack.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSPersistentStoreCoordinator (Stack)

+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model;
+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model options:(NSDictionary *)options;
+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model options:(NSDictionary *)options configuration:(NSString *)configuration;

+ (NSDictionary *)defaultOptions;

- (NSPersistentStore *)addSQLiteStoreNamed:(NSURL *)storeURL withOptions:(NSDictionary *)options configuration:(NSString *)configuration;
- (NSPersistentStore *)addInMemoryStore;

@end
