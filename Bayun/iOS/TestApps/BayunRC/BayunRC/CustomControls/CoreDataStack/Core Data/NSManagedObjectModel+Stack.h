//
//  NSManagedObjectModel+Stack.h
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (Stack)

+ (instancetype)managedObjectModelNamed:(NSString *)modelFileName;
+ (instancetype)managedObjectModelNamed:(NSString *)modelFileName inBundle:(NSBundle *)bundle;

+ (instancetype)mergedManagedObjectModelFromBundle:(NSBundle *)bundle;
+ (instancetype)mergedManagedObjectModelFromAllBundles;

@end
