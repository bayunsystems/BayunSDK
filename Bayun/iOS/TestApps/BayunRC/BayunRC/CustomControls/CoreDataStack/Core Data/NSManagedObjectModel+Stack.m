//
//  NSManagedObjectModel+Stack.m
//  CoreDataStack
//
//  Created by Menno Wildeboer on 29/12/13.
//  Copyright (c) 2013 Menno. All rights reserved.
//

#import "NSManagedObjectModel+Stack.h"

@implementation NSManagedObjectModel (Stack)

+ (instancetype)managedObjectModelNamed:(NSString *)modelFileName
{
    return [self managedObjectModelNamed:modelFileName inBundle:[NSBundle mainBundle]];
}

+ (instancetype)managedObjectModelNamed:(NSString *)modelFileName inBundle:(NSBundle *)bundle
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:modelFileName withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

+ (instancetype)mergedManagedObjectModelFromBundle:(NSBundle *)bundle
{
    return [NSManagedObjectModel mergedModelFromBundles:@[ bundle ]];
}

+ (instancetype)mergedManagedObjectModelFromAllBundles
{
    return [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
}

@end
