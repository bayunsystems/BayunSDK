//
//  RCCryptManager.h
//  BayunRC
//
//  Created by Preeti Gaur on 24/06/16.
//  Copyright © 2022 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bayun/BayunCore.h>


@interface RCCryptManager : NSObject

/**
 Singleton Service Client.
 */
+ (instancetype)sharedInstance;

- (void) decryptText :(NSString*) text success:(void (^)(NSString*))success failure:(void (^)(BayunError))failure;

/**
 * Returns encrypted text
 */
-(void)encryptText:(NSString *)text success:(void (^)(NSString*))success failure:(void (^)(BayunError))failure;

@end
