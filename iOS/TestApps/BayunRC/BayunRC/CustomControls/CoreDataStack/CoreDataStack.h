//
//  CoreDataStack.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *rootManagedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectContext *backgroundObjectContext;
@property (nonatomic, assign)   NSManagedObjectContextConcurrencyType concurrencyType;

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong)   NSString             *modelName;
@property (nonatomic, strong)   NSBundle             *modelBundle;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSURL                        *persistentStoreURL;
@property (nonatomic, readonly) NSString                     *persistentStoreType;
@property (nonatomic, readonly) NSDictionary                 *persistentStoreOptions;
@property (nonatomic, readonly) NSString                     *persistentStoreConfiguration;

- (instancetype)initWithStoreName:(NSString *)storeName;
- (instancetype)initWithStoreURL:(NSURL *)storeURL;

@end

@interface CoreDataStack (Managing)

+ (instancetype)defaultStack;
+ (void)setDefaultStack:(CoreDataStack *)stack;

+ (instancetype)stackWithIdentifier:(NSString *)identifier;
+ (instancetype)stackWithStoreNamed:(NSString *)storeName identifier:(NSString *)identifier;

+ (void)removeStackWithIdentifier:(NSString *)identifier;

@end
