//
//  RCCryptManager.h
//  BayunRC
//
//  Created by Preeti Gaur on 24/06/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RCCryptManager : NSObject

/**
 Singleton Service Client.
 */
+ (instancetype)sharedInstance;

/**
 * Returns decrypted text
 */
- (NSString*) decryptText :(NSString*) text;

/**
 * Returns encrypted text
 */
- (NSString*) encryptText :(NSString*) text;

@end
