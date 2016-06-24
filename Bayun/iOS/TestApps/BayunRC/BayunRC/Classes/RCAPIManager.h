//
//  RCAPIManager.h
//  Bayun
//
//  Created by Preeti Gaur on 02/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCAPIManager : NSObject

/**
 Singleton Service Client.
 */
+ (instancetype)sharedInstance;

/**
 Logs in RingCentral.
 @param credentials NSDictionary mapping user name, extension, password.
 @param success Success block to be executed after successful login.
 @param failure Failure block to be executed if login fails, returns RCError.
 */
- (void)loginWithCredentials:(NSDictionary*)credentials
                    success:(void (^)(void))success
                    failure:(void (^)(RCError))failure;

/**
 Gets list of messages of type Pager and saves in local database.
 @param success Success block to be executed after list of messages is fetched.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void)getMessageList:(void (^)(void))success failure:(void (^)(RCError))failure;

/**
 Sends a pager-message.
 @param success Success block to be executed after message is sent.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void)sendMessage:(NSDictionary*)parameters success:(void (^)(void))success failure:(void (^)(RCError))failure;

/**
 Gets list of extensions.
 @param success Success block to be executed after list of extensions is fetched.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void)getExtensionList:(void (^)(void))success failure:(void (^)(RCError))failure;

@end
