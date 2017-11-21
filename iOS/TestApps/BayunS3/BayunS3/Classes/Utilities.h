//
//  Utilities.h
//  Bayun
//
//  Created by Preeti Gaur on 11/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIBarItem.h>

typedef NS_ENUM(NSInteger, alertViewTag) {
    alertViewTagNameFile = 0,
    alertViewTagSaveFile
};

@interface Utilities : NSObject

+ (void)clearKeychainAndUserDefaults;
+ (id)getFileSize:(id)value;
+ (NSString*)getCurrentTimeStampDateString:(NSDate*) date;
+ (NSString*)appId;

@end
