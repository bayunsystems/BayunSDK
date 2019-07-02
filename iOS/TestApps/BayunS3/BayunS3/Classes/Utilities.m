//
//  Utilities.m
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "Utilities.h"
#import "NSDate+TimeAgoConversion.h"
#import <Bayun/BayunCore.h>


@implementation Utilities

+ (id)getFileSize:(id)value {
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"Bytes",@"KB",@"MB",@"GB",@"TB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.0f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString*)getCurrentTimeStampDateString:(NSDate*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSString *dateAsString = [formatter stringFromDate:date];
    return [[formatter dateFromString:dateAsString] timeAgo];
}

+ (void)clearKeychainAndUserDefaults {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCompany];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSelectedKeyGenPolicy];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kSelectedEncryptionPolicy];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (void)logoutUser:(AWSCognitoIdentityUser *)user {
    [[SecureAuthentication sharedInstance] signOut:user];
    [[user getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [Utilities  clearKeychainAndUserDefaults];
                [[BayunCore sharedInstance] deauthenticate];
                [SVProgressHUD showErrorWithStatus:task.error.userInfo[NSLocalizedDescriptionKey]];
            }
        });
        return nil;
    }];
}


@end
