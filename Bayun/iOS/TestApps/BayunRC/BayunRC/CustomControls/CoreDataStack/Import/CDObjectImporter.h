//
//  CDObjectImporter.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 30/04/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDObjectImporter : NSObject

@property (nonatomic, strong) NSArray *managedObjects;
@property (nonatomic, strong) NSArray *importedObjects;

@property (nonatomic, readonly) id <NSCopying> managedObjectIdentifier;
@property (nonatomic, readonly) Class          managedObjectClass;

- (NSArray *)import;

- (id)identifierForData:(NSDictionary *)data atIndex:(NSUInteger)index;

- (BOOL)shouldDeleteObjects;
- (BOOL)shouldDeleteObject:(id)managedObject;
- (void)updateObject:(id)managedObject withData:(NSDictionary *)data;

@end
