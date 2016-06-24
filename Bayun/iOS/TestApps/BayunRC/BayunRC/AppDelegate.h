//
//  AppDelegate.h
//  BayunRC
//
//  Created by Preeti Gaur on 23/06/16.
//  Copyright © 2016 bayun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class CoreDataStack;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CoreDataStack *stack;
@property (nonatomic,assign) BOOL isDeviceTimeFormat24Hours;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL isNetworkReachable;

- (NSURL *)applicationDocumentsDirectory;
- (void)logoutWithMessage:(NSString*)message;


@end

