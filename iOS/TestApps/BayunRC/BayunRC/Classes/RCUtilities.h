//
//  RCUtilities.h
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIBarItem.h>



@class User;

@interface RCUtilities : NSObject

/**
 * Returns RingCentral API Base URL
 */
+ (NSString*) baseURL;

/**
 Returns RingCentral Access Token
 */
+ (NSString*)rcAccessToken;

/**
 Returns RingCentral Refresh Token
 */
+ (NSString*)rcRefreshToken;

/**
 Returns Phone Number
 */
+ (NSString*)phoneNumber;

/**
 Returns Extension
 */
+ (NSString*)extension;

/**
 Returns App Name
 */
+ (NSString*)appName;

/**
 Clears the App Id
 */
+ (NSString*)appId;

/**
 Clears the Cache
 */
+ (void)clearCacheData;

/**
 Converts and returns NSString to Base64 string.
 */
+ (NSString *)base64String:(NSString *)string;

/**
 Returns the file size in standard format
 */
+ (id)transformedFileSizeValue:(id)value;

/**
 Returns the formatted NSDate String.
 */
+ (NSString*)getCurrentTimeStampDateString:(NSDate*) date;

/**
 Returns App User Entity
 */
+ (User*)appUser;

/**
 Returns UIColor from hex string
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/**
 Returns true if time is 24 hour format else false
 */
+ (BOOL)isTime24HourFormat ;

/**
 Returns the formatted time stamp string
 */
+ (NSMutableAttributedString*)getTimestamp:(NSDate*)date fontSize:(CGFloat)fontSize;

@end
