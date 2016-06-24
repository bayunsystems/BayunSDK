//
//  CDObjectImporter.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 30/04/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import "CDObjectImporter.h"
#import "NSManagedObject+Resource.h"

@interface CDObjectImporter ()

@property (nonatomic, strong) NSMutableArray *mutableManagedObjects;
@property (nonatomic, strong) NSMutableDictionary *mutableManagedObjectsForKey;

@end

@implementation CDObjectImporter

- (NSArray *)import
{
    if (self.importedObjects == nil) {
        return nil;
    }
    
    NSDictionary *importedObjectsForIdentifier = [self importedObjectsForIdentifier];
    if (!importedObjectsForIdentifier) {
        return nil;
    }
    
    self.mutableManagedObjects = [NSMutableArray array];
    if (self.shouldDeleteObjects)
    {
        if (self.managedObjects.count == 0) {
            self.managedObjects = [[self.managedObjectClass all] objects];
        }
        [self.mutableManagedObjects addObjectsFromArray:self.managedObjects];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (%K IN %@)", self.managedObjectIdentifier, [importedObjectsForIdentifier allValues]];
        
        NSArray *filteredManagedObjects = [self.managedObjects filteredArrayUsingPredicate:predicate];
        [filteredManagedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([self shouldDeleteObject:obj])
             {
                 [obj delete];
                 [self.mutableManagedObjects removeObject:obj];
             }
         }];
    }
    else
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", self.managedObjectIdentifier, [importedObjectsForIdentifier allValues]];
        NSArray *managedObjects = [[[self.managedObjectClass findWithPredicate:predicate] sortBy:@{ self.managedObjectIdentifier : @YES  }] objects];
        [self.mutableManagedObjects addObjectsFromArray:managedObjects];
    }
    
    self.mutableManagedObjectsForKey = [[self managedObjectsForIdentifier] mutableCopy];
    [importedObjectsForIdentifier enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id identifier, BOOL *stop)
     {
         id managedObject = self.mutableManagedObjectsForKey[identifier];
         if (!managedObject)
         {
             managedObject = [self.managedObjectClass create];
             self.mutableManagedObjectsForKey[identifier] = managedObject;
         }
         
         NSDictionary *data = [self.importedObjects objectAtIndex:[key intValue]];
         [self updateObject:managedObject withData:data];
     }];
    
    return [self.mutableManagedObjects copy];
}

#pragma mark - Override

- (Class)managedObjectClass
{
    return NULL;
}

- (id <NSCopying>)managedObjectIdentifier
{
    return nil;
}

- (id)identifierForData:(NSDictionary *)data atIndex:(NSUInteger)index
{
    return nil;
}

- (BOOL)shouldDeleteObjects
{
    return NO;
}

- (BOOL)shouldDeleteObject:(id)managedObject
{
    return NO;
}

- (void)updateObject:(id)object withData:(NSDictionary *)data
{
    
}

#pragma mark - Private

- (NSDictionary *)importedObjectsForIdentifier
{
    NSMutableDictionary *values = [NSMutableDictionary dictionaryWithCapacity:self.importedObjects.count];
    [self.importedObjects enumerateObjectsUsingBlock:^(id data, NSUInteger idx, BOOL *stop)
     {
         id object = [self identifierForData:data atIndex:idx];
         if (object)
         {
             [values setObject:object forKey:@(idx)];
         }
     }];
    return [values copy];
}

- (NSDictionary *)managedObjectsForIdentifier
{
    NSMutableDictionary *mutableManagedObjectsForIdentifier = [NSMutableDictionary dictionary];
    [self.mutableManagedObjects enumerateObjectsUsingBlock:^(id managedObject, NSUInteger idx, BOOL *stop)
     {
         id identifier = [managedObject valueForKey:(NSString *)self.managedObjectIdentifier];
         if (identifier) {
             [mutableManagedObjectsForIdentifier setObject:managedObject forKey:identifier];
         }
     }];
    return mutableManagedObjectsForIdentifier;
}

@end
