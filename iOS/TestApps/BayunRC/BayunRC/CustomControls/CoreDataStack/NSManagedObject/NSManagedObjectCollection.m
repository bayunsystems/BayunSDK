//
//  NSManagedObjectCollection.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 17/04/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import "NSManagedObjectCollection.h"
#import "NSManagedObject+Resource.h"
#import "NSManagedObject+Stack.h"
#import "NSSortDescriptor+Helpers.h"

@implementation NSManagedObjectCollection

- (instancetype)initWithClass:(Class)managedObjectClass
{
    self = [super init];
    if (self)
    {
        self.managedObjectClass = managedObjectClass;
        self.fetchRequest = [[NSFetchRequest alloc] init];
    }
    return self;
}

- (NSArray *)objects
{
    return [self.managedObjectClass executeFetchRequest:self.fetchRequest inContext:self.managedObjectContext];
}

- (NSArray *)objectIDs
{    
    self.fetchRequest.resultType = NSManagedObjectIDResultType;
    return [self objects];
}

- (NSArray *)objectDictionaries
{
    self.fetchRequest.resultType = NSDictionaryResultType;
    return [self objects];
}

- (NSUInteger)count
{
    return [self.managedObjectClass countFetchRequest:self.fetchRequest inContext:self.managedObjectContext];
}

- (id)object
{
    return [self.managedObjectClass executeFetchRequestAndReturnFirstObject:self.fetchRequest inContext:self.managedObjectContext];
}

- (id)firstObject
{
    return [[self objects] firstObject];
}

- (id)lastObject
{
    return [[self objects] lastObject];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerWithSectionNameKeyPath:(NSString *)sectionKeyPath
{
    return [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:nil];
}

- (NSFetchedResultsController *)fetchedResultsControllerWithSectionNameKeyPath:(NSString *)sectionKeyPath cacheName:(NSString *)cacheName
{
    return [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionKeyPath cacheName:cacheName];

}

- (NSArray *)take:(NSInteger)amount
{
    self.fetchRequest.fetchLimit = amount;
    return [self objects];
}

- (NSArray *)takeInRange:(NSRange)range
{
    self.fetchRequest.fetchLimit = range.length;
    self.fetchRequest.fetchOffset = range.location;
    return [self objects];
}

- (NSDictionary *)groupBy:(NSString *)keyPath
{
    NSMutableDictionary *groupedObjects = [NSMutableDictionary dictionary];
    NSArray *items = [[self sortBy:@{ keyPath : @YES }] objects];
    [items enumerateObjectsUsingBlock:^(id entity, NSUInteger idx, BOOL *stop)
    {
        id <NSCopying> groupedKey = [entity valueForKey:keyPath];
        if (groupedKey)
        {
            NSMutableArray *objectsForKey = groupedObjects[groupedKey];
            if (!objectsForKey) {
                objectsForKey = [NSMutableArray array];
            }
            [objectsForKey addObject:entity];
            groupedObjects[groupedKey] = objectsForKey;
        }
    }];
    return [NSDictionary dictionaryWithDictionary:groupedObjects];
}

- (instancetype)sortBy:(NSDictionary *)sort
{
    self.fetchRequest.sortDescriptors = [NSSortDescriptor sortDescriptorsFromDictionary:sort];
    return self;
}

- (instancetype)sortWithDescriptor:(NSSortDescriptor *)sortDescriptor
{
    self.fetchRequest.sortDescriptors = @[ sortDescriptor ];
    return self;
}

- (instancetype)sortWithDescriptors:(NSArray *)sortDescriptors
{
    self.fetchRequest.sortDescriptors = sortDescriptors;
    return self;
}

- (id)createIfNotExists
{
    NSManagedObject *object = [self object];
    if (!object) {
        return [self.managedObjectClass create];
    }
    return object;
}

- (void)delete
{
    [self.objects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[NSManagedObject class]]) {
            [obj delete];
        }
    }];
}

#pragma mark - Accessors

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    if ([_managedObjectContext isEqual:managedObjectContext]) {
        return;
    }
    
    _managedObjectContext = managedObjectContext;
    [self updateEntity];
}

#pragma mark - Private

- (void)updateEntity
{
    NSString *entityName = NSStringFromClass(self.managedObjectClass);
    if (entityName && self.managedObjectContext) {
        self.fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    }
    else {
        self.fetchRequest.entity = nil;
    }
}

@end
