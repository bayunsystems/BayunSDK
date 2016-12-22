//
//  Utilities.m
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "Utilities.h"
#import "NSDate+TimeAgoConversion.h"


@implementation Utilities

+ (NSString*)s3BucketName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kS3BucketName];
}

+ (NSString*)appId {
    return [NSString stringWithFormat:@"%@",kBayunAppId];
}


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
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCompanyName];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kS3BucketName];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kBucketExists];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
