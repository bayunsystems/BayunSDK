//
//  NSPersistentStoreCoordinator+Stack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSPersistentStoreCoordinator+Stack.h"
#import "NSManagedObjectModel+Stack.h"

static NSPersistentStoreCoordinator *defaultCoordinator = nil;

@implementation NSPersistentStoreCoordinator (Stack)

+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model
{
    return [self coordinatorWithSQLiteStoreURL:storeURL withModel:model options:self.defaultOptions configuration:nil];
}

+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model options:(NSDictionary *)options
{
    return [self coordinatorWithSQLiteStoreURL:storeURL withModel:model options:options configuration:nil];
}

+ (instancetype)coordinatorWithSQLiteStoreURL:(NSURL *)storeURL withModel:(NSManagedObjectModel *)model options:(NSDictionary *)options configuration:(NSString *)configuration
{
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [coordinator addSQLiteStoreNamed:storeURL withOptions:options configuration:configuration];
    if ([[coordinator persistentStores] count] == 0)
    {

    }
    return coordinator;
}

+ (NSDictionary *)defaultOptions
{
    return @{
        NSMigratePersistentStoresAutomaticallyOption : @YES,
        NSInferMappingModelAutomaticallyOption : @YES,
        @"journal_mode" : @"WAL"
    };
}


- (NSPersistentStore *)addSQLiteStoreNamed:(NSURL *)storeURL withOptions:(NSDictionary *)options configuration:(NSString *)configuration
{
//    NSURL *url = [storeFileName isKindOfClass:[NSURL class]] ? storeFileName : [NSPersistentStore MR_urlForStoreName:storeFileName];
    NSError *error = nil;
    
//    [self MR_createPathToStoreFileIfNeccessary:url];
    
    NSPersistentStore *store = [self addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:options error:&error];
    if (!store)
    {
        BOOL isMigrationError = [error code] == NSPersistentStoreIncompatibleVersionHashError || [error code] == NSMigrationMissingSourceModelError;
        if ([[error domain] isEqualToString:NSCocoaErrorDomain] && isMigrationError)
        {
            NSString *rawURL = [storeURL absoluteString];
            NSURL *shmSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-shm"]];
            NSURL *walSidecar = [NSURL URLWithString:[rawURL stringByAppendingString:@"-wal"]];
            
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            [[NSFileManager defaultManager] removeItemAtURL:shmSidecar error:nil];
            [[NSFileManager defaultManager] removeItemAtURL:walSidecar error:nil];
            
            store = [self addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
            if (store)
            {
                error = nil;
            }
        }
    }
    return store;
}

- (NSPersistentStore *)addInMemoryStore
{
    NSError *error = nil;
    NSPersistentStore *store = [self addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    if (!store)
    {
        
    }
    return store;
}

@end
