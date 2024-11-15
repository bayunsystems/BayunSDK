//
//  AppDelegate.m
//  BayunS3
//
//  Created by Preeti Gaur on 27/06/16.
//  Copyright © 2023 Bayun Systems, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ListFilesViewController.h"
#import <Reachability/Reachability.h>
#import "AWSS3/AWSS3TransferUtility.h"
#import <AWSCore/AWSCore.h>
#import "AWSCognitoIdentityUserPool.h"
#import "SecureAuthentication.h"
#import <Bayun/BayunCore.h>

@interface AppDelegate ()

@property (strong,nonatomic) NSMutableDictionary *mutableDictionary;
@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AWSDDLog sharedInstance].logLevel = AWSDDLogLevelVerbose;
    
    // Override point for customization after application launch.
    
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
  [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0]];

  if (@available(iOS 15.0, *)) {
    UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navBarAppearance configureWithOpaqueBackground];
    navBarAppearance.backgroundColor = [UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0];
    [UINavigationBar appearance].standardAppearance = navBarAppearance;
    [UINavigationBar appearance].scrollEdgeAppearance = [UINavigationBar appearance].standardAppearance;
  }
        
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [networkReachability startNotifier];
    self.isNetworkReachable = networkReachability.currentReachabilityStatus;
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    //create a pool
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion
                                                                                credentialsProvider:nil];
    
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:CognitoIdentityUserPoolAppClientId  clientSecret:CognitoIdentityUserPoolAppClientSecret poolId:CognitoIdentityUserPoolId];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration
                                                           userPoolConfiguration:configuration forKey:@"UserPool"];
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    pool.delegate = self;
    
    //Configure AWSServiceManager defaultServiceConfiguration
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:CognitoIdentityUserPoolRegion
                                                          identityPoolId:CognitoIdentityPoolId];
    
    AWSServiceConfiguration *awsServiceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = awsServiceConfiguration;

    AWSS3TransferUtilityConfiguration *tuConfig = [AWSS3TransferUtilityConfiguration new];
    tuConfig.timeoutIntervalForResource = 200;
  
    [AWSS3TransferUtility registerS3TransferUtilityWithConfiguration:awsServiceConfiguration transferUtilityConfiguration:tuConfig forKey:@"UserPool"];

    [SecureAuthentication sharedInstance].companyName = kDefaultCompanyName;
    [SecureAuthentication sharedInstance].appId =  kBayunAppId;
    [SecureAuthentication sharedInstance].appSecret = kBayunAppSecret;
    [SecureAuthentication sharedInstance].appSalt = kBayunApplicationSalt;
  
  if(![[NSUserDefaults standardUserDefaults] boolForKey:kIsUserLoggedIn]) {
    [self startPasswordAuthentication];
  }
    return YES;
}

//set up password authentication ui to retrieve username and password from the user
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
  NSLog(@"startPasswordAuthentication");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(!self.navigationController){
        self.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"signinController"];
    }
    
    if(!self.signInViewController){
        self.signInViewController = self.navigationController.viewControllers[0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //rewind to login screen
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        //display login screen if it isn't already visibile
        if(!(self.navigationController.isViewLoaded && self.navigationController.view.window))
        {
          self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
        }
    });
    return self.signInViewController;
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
