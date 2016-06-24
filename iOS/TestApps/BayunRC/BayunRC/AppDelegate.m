//
//  AppDelegate.m
//  BayunRC
//
//  Created by Preeti Gaur on 23/06/16.
//  Copyright © 2016 bayun. All rights reserved.
//

#import "AppDelegate.h"
#import "ConversationListViewController.h"
#import "LoginViewController.h"
#import "RCAPIManager.h"
#import <Bayun/BayunCore.h>

#define TAssert(cond)		((void) ((cond) ? 0 : printf("-> fail(%d): %s\n", __LINE__, #cond)))

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption{
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Set up coredata-stack
    _stack = [CoreDataStack stackWithStoreNamed:@"BayunRC" identifier:@"main"];
    
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [networkReachability startNotifier];
    self.isNetworkReachable = networkReachability.currentReachabilityStatus;
    
    UINavigationController *navigationController;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kIsUserLoggedIn]) {
        UINavigationController *navigationController = (UINavigationController*) self.window.rootViewController;
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ConversationListViewController"]
                                        animated:NO];
    } else {
        UINavigationController *navigationController = (UINavigationController*) self.window.rootViewController;
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"]
                                        animated:NO];
    }
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    [navigationController.navigationBar setTitleTextAttributes:textTitleOptions];
    [navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0]];
    
    return YES;
}

// Fetches new messages from RingCentral
-(void) getMessageList {
    [[RCAPIManager sharedInstance] getMessageList:nil failure:^(RCError errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (errorCode == RCErrorInternetConnection) {
                [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
            } else if (errorCode == RCErrorInvalidToken) {
                [self logoutWithMessage:kErrorSessionIsExpired];
            } else if (errorCode == RCErrorRequestTimeOut) {
                [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
            } else {
                [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
            }
        });
    }];
}

// Logs out from application with the message if any.
-(void) logoutWithMessage:(NSString*)message {
    [[BayunCore sharedInstance] logoutBayun];
    [RCUtilities clearCacheData];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController;
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kIsUserLoggedIn]) {
        navigationController = (UINavigationController*) self.window.rootViewController;
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ConversationListViewController"]
                                        animated:NO];
    } else {
        navigationController = (UINavigationController*) self.window.rootViewController;
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:NO];
    }
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    
    [navigationController.navigationBar setTitleTextAttributes:textTitleOptions];
    [navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0]];
    
    if (message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.stack.managedObjectContext saveWithType:NSSaveSelfAndParent];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    self.isDeviceTimeFormat24Hours = [RCUtilities isTime24HourFormat];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    [self.stack.managedObjectContext saveWithType:NSSaveSelfAndParent];
}


#pragma mark - Network Reachability Delegate

/*
 * @desc - Gets called as soon as network switches.
 * @param - notification object which caused this method to be called
 */
- (void)reachabilityDidChange:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];
    if ([reachability isReachable]) {
        self.isNetworkReachable = YES;
    } else {
        self.isNetworkReachable = NO;
    }
}


#pragma mark - Core Data stack

//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.bayun.BayunRC" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}




@end
