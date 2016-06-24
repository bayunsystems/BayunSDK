//
//  NSManagedObject+Stack.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Stack)

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSInteger)defaultBatchSize;

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request;
+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request;
+ (id)executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

+ (NSUInteger)countFetchRequest:(NSFetchRequest *)request;
+ (NSUInteger)countFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

@end
