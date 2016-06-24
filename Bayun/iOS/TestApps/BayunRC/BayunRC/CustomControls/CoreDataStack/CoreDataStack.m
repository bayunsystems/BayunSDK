//
//  CoreDataStack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "CoreDataStack.h"
#import "NSManagedObjectContext+Stack.h"
#import "NSManagedObjectModel+Stack.h"
#import "NSPersistentStoreCoordinator+Stack.h"

static CoreDataStack       *defaultStack = nil;
static NSMutableDictionary *stacks = nil;

@interface CoreDataStack ()

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectContext       *rootManagedObjectContext;

@end

@implementation CoreDataStack

+ (void)load
{
    if (self == [CoreDataStack class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            stacks = [[NSMutableDictionary alloc] init];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
}

- (instancetype)initWithStoreName:(NSString *)storeName
{
    NSURL *documents = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [self initWithStoreURL:[documents URLByAppendingPathComponent:storeName]];
}

- (instancetype)initWithStoreURL:(NSURL *)storeURL
{
    self = [super init];
    if (self)
    {
        _concurrencyType = NSMainQueueConcurrencyType;
        _persistentStoreURL = storeURL;
        _modelBundle = [NSBundle mainBundle];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveOnApplicationToBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveOnApplicationToBackground:) name:UIApplicationWillTerminateNotification object:[UIApplication sharedApplication]];
    }
    return self;
}

#pragma mark - Accessors

- (NSManagedObjectContext *)rootManagedObjectContext
{
    if (_rootManagedObjectContext == nil)
    {
        _rootManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _rootManagedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
	}
    return _rootManagedObjectContext;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:self.concurrencyType];
        if (_managedObjectContext.concurrencyType == NSMainQueueConcurrencyType) {
            _managedObjectContext.parentContext = self.rootManagedObjectContext;
        } else {
            _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];        
//        if (self.modelName) {
//            _managedObjectModel = [NSManagedObjectModel managedObjectModelNamed:self.modelName inBundle:self.modelBundle];
//        }
//
//        if (!_managedObjectModel) {
//            _managedObjectModel = [NSManagedObjectModel mergedManagedObjectModelFromBundle:self.modelBundle];
//        }
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil)
    {
        _persistentStoreCoordinator = [NSPersistentStoreCoordinator coordinatorWithSQLiteStoreURL:self.persistentStoreURL withModel:self.managedObjectModel options:self.persistentStoreOptions configuration:self.persistentStoreConfiguration];
    }
    return _persistentStoreCoordinator;
}

- (NSString *)persistentStoreType
{
    return NSSQLiteStoreType;
}

- (NSDictionary *)persistentStoreOptions
{
    return [NSPersistentStoreCoordinator defaultOptions];
}

#pragma mark - Private

- (void)saveOnApplicationToBackground:(NSNotification *)notification
{
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
    }];
    [self.managedObjectContext saveWithType:NSSaveSelfAndParent];
}

@end

@implementation CoreDataStack (Managing)

+ (instancetype)defaultStack
{
    return defaultStack;
}

+ (void)setDefaultStack:(CoreDataStack *)stack
{
    if (defaultStack)
    {
        @synchronized(defaultStack) {
            defaultStack = stack;
        }
    }
    else {
        defaultStack = stack;
    }
}

+ (instancetype)stackWithIdentifier:(NSString *)identifier
{
    if (!identifier) {
        return nil;
    }
    return stacks[identifier];
}

+ (instancetype)stackWithStoreNamed:(NSString *)storeName identifier:(NSString *)identifier
{
    if (!storeName && !identifier) {
        return nil;
    }
    
    CoreDataStack *stack = stacks[identifier];
    if (!stack)
    {
        stack = [[CoreDataStack alloc] initWithStoreName:storeName];
        stack.modelName = storeName;
        if (!defaultStack && stack.concurrencyType == NSMainQueueConcurrencyType)
        {
            [self setDefaultStack:stack];
        }
        stacks[identifier] = stack;
    }
    return stack;
}

+ (void)removeStackWithIdentifier:(NSString *)identifier
{
    [stacks removeObjectForKey:identifier];
}

@end
