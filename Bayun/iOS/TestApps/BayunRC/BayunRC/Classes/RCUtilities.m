//
//  RCUtilities.m
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//


#import "User.h"
#import "NSDate+TimeAgoConversion.h"


@implementation RCUtilities : NSObject

/**
 * Returns RingCentral API Base URL
 */
+ (NSString*) baseURL {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Info" ofType: @"plist"];
    return [[NSDictionary dictionaryWithContentsOfFile: path] objectForKey: @"RCBaseURL"];
}

/**
 Returns RingCentral Access Token
 */
+ (NSString*) rcAccessToken {
    NSString *rcAccessToken =[[NSUserDefaults standardUserDefaults] valueForKey:kRCAccessToken];
    if (!rcAccessToken) {
        rcAccessToken = @"NULL";
    }
    return rcAccessToken;
}

/**
 Returns RingCentral Refresh Token
 */
+ (NSString*) rcRefreshToken {
    NSString *rcRefreshToken =[[NSUserDefaults standardUserDefaults] valueForKey:kRCRefreshToken];
    if (!rcRefreshToken) {
        rcRefreshToken = @"NULL";
    }
    return rcRefreshToken;
}

/**
 Returns Phone Number
 */
+ (NSString*) phoneNumber {
    NSString *phoneNumber = [[NSUserDefaults standardUserDefaults] valueForKey:kRCPhoneNumber];
    if (!phoneNumber) {
        phoneNumber = @"NULL";
    }
    return phoneNumber;
}

/**
 Returns Extension
 */
+ (NSString*) extension {
    NSString *extension = [[NSUserDefaults standardUserDefaults] valueForKey:kRCExtension];
    if (!extension) {
        extension = @"NULL";
    }
    return extension;
}

/**
 Returns App Name
 */
+ (NSString*)appName {
   return @"BayunRC";
}

/**
 Returns AppId
 */
+ (NSString*)appId {
    return @"com.bayun.BayunRC";
}

/**
 Returns App User Entity
 */
+ (User*) appUser {
    User *user = [[User findWithPredicate:[NSPredicate predicateWithFormat:@"isAppUser=%@",[NSNumber numberWithBool:YES]]] lastObject];
    return user;
}

/**
 Returns the file size in standard format
 */
+ (id)transformedFileSizeValue:(id)value {
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"Bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.0f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

/**
 Converts and returns NSString to Base64 string.
 */
+ (NSString *)base64String:(NSString *)string {
    NSData *plainData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    return base64String;
}

/**
 Returns the formatted NSDate String.
 */
+(NSString*) getCurrentTimeStampDateString:(NSDate*) date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    NSString *dateAsString = [formatter stringFromDate:date];
    return [[formatter dateFromString:dateAsString] timeAgo];
}

/**
 Returns UIColor from hex string
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

/**
 Returns true if time is 24 hour format else false
 */
+ (BOOL)isTime24HourFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    
    return is24Hour;
}

/**
 Clears the Cache
 */
+(void)clearCacheData {
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCPhoneNumber];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCPassword];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCAccessToken];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCRefreshToken];
   
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsUserLoggedIn];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsAccessDenied];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCLastMessageDate];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCAuthTokenExpIn];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCRefreshTokenExpIn];
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:kRCLastMessageDateString];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

/**
 Returns the formatted time stamp string
 */
+(NSMutableAttributedString*)getTimestamp:(NSDate*)date fontSize:(CGFloat)fontSize {
    UIFont *lightFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    NSMutableAttributedString * string ;
    NSString *d;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d h:mma"];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    
    NSDate *now = [NSDate date];  // now
    NSDate *today;
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay // beginning of this day
                                    startDate:&today // save it here
                                     interval:NULL
                                      forDate:now];
    
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.day = 0;
    NSDate * theDayToday = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:today options:0];
    if ([date compare:theDayToday] == NSOrderedDescending) {
        //return @"today";
        [dateFormatter setDateFormat:@"h:mma"];
        d=[dateFormatter stringFromDate:date];
        string = [[NSMutableAttributedString alloc] initWithString:d ];
        [string addAttribute:NSFontAttributeName value:lightFont range:NSMakeRange(0,d.length)];
        return string;
        
    }
    
    comp.day = -1;
    NSDate * yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:today options:0];
    if ([date compare:yesterday] == NSOrderedDescending) {
        // return @"yesterday";
        [dateFormatter setDateFormat:@"EEE h:mma"];
        d=[dateFormatter stringFromDate:date];
        string = [[NSMutableAttributedString alloc] initWithString:d ];
        [string addAttribute:NSFontAttributeName value:lightFont range:NSMakeRange(0,d.length)];
        return string;
    }
    
    comp.day = -7;      // lets go 7 days back from today
    NSDate * oneWeekBefore = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:today options:0];
    if ([date compare:oneWeekBefore] == NSOrderedDescending) {
        //within 7 days
        [dateFormatter setDateFormat:@"EEE h:mma"];
        d=[dateFormatter stringFromDate:date];
        string = [[NSMutableAttributedString alloc] initWithString:d ];
        [string addAttribute:NSFontAttributeName value:lightFont range:NSMakeRange(0,d.length)];
        return string;
        
    } else {
        comp.day = -365;      // lets go 1 year back from today
        NSDate * oneYearBefore = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:today options:0];
        if ([date compare:oneYearBefore] == NSOrderedDescending) {
            //within 1 year
            [dateFormatter setDateFormat:@"MMM d, h:mma"];
            d=[dateFormatter stringFromDate:date];
            string = [[NSMutableAttributedString alloc] initWithString:d ];
            [string addAttribute:NSFontAttributeName value:lightFont range:NSMakeRange(0,d.length)];
        } else {
            [dateFormatter setDateFormat:@"d/MM/YYYY, h:mma"];
            d=[dateFormatter stringFromDate:date];
            string = [[NSMutableAttributedString alloc] initWithString:d ];
            [string addAttribute:NSFontAttributeName value:lightFont range:NSMakeRange(0,d.length)];
        }
        return string;
    }
}

@end
