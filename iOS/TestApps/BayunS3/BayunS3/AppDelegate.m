//
//  AppDelegate.m
//  BayunS3
//
//  Created by Preeti Gaur on 27/06/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ListFilesViewController.h"
#import "LoginViewController.h"
#import <Reachability/Reachability.h>
#import <AWSCore/AWSCore.h>
#import <Bayun/BayunCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0]];
    
    
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
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"ListFilesViewController"] animated:NO];
    } else {
        UINavigationController *navigationController = (UINavigationController*) self.window.rootViewController;
        [navigationController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"] animated:NO];
        [Utilities  clearKeychainAndUserDefaults];
    }
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil];
    [navigationController.navigationBar setTitleTextAttributes:textTitleOptions];
    [navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0]];
    
    
    AWSStaticCredentialsProvider *credentialsProvider = [[AWSStaticCredentialsProvider alloc]
                                                         initWithAccessKey:kS3AccessKey
                                                         secretKey:kS3SecretKey];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
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


@end
