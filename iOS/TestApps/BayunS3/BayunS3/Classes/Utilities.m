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

+ (NSString*)appId {
    
    //return @"6dc67116a1f3419cac6074a71c09db2c"; //BayunS3-1
    return @"6acb2ca252da4ef8a3bc599f75535ecd"; //BayunS3
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
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kCompany];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
