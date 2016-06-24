//
//  NSManagedObjectCollection.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 17/04/14.
//  Copyright (c) 2014 Menno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol NSManagedObjectCollection <NSObject>

@required
@property (nonatomic, readonly) NSArray   *objects;
@property (nonatomic, readonly) NSArray   *objectIDs;
@property (nonatomic, readonly) NSArray   *objectDictionaries;
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) id firstObject;
@property (nonatomic, readonly) id lastObject;

- (NSFetchedResultsController *)fetchedResultsController;
- (NSFetchedResultsController *)fetchedResultsControllerWithSectionNameKeyPath:(NSString *)sectionKeyPath;
- (NSFetchedResultsController *)fetchedResultsControllerWithSectionNameKeyPath:(NSString *)sectionKeyPath cacheName:(NSString *)cacheName;

- (NSArray *)take:(NSInteger)amount;
- (NSArray *)takeInRange:(NSRange)range;

- (NSDictionary *)groupBy:(NSString *)keyPath;

- (instancetype)sortBy:(NSDictionary *)sort;
- (instancetype)sortWithDescriptor:(NSSortDescriptor *)sortDescriptor;
- (instancetype)sortWithDescriptors:(NSArray *)sortDescriptors;

- (id)createIfNotExists;
- (void)delete;

@end


@interface NSManagedObjectCollection : NSObject <NSManagedObjectCollection>

@property (nonatomic, strong) NSFetchRequest         *fetchRequest;
@property (nonatomic, assign) Class                   managedObjectClass;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithClass:(Class)managedObjectClass;

@end
