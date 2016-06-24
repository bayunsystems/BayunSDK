//
//  RCCryptManager.m
//  BayunRC
//
//  Created by Preeti Gaur on 24/06/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "RCCryptManager.h"
#import <Bayun/BayunCore.h>

@implementation RCCryptManager

/**
 Singleton Service Client.
 */
+ (instancetype)sharedInstance {
    
    static RCCryptManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

/*
 * Returns encrypted text
 */
- (NSString*) decryptText :(NSString*) text {
    
    __block NSString *decryptedText;
    //Decrypt text using Bayun Library
    [[BayunCore sharedInstance]decryptText:text success:^(NSString *decryptedTextResponse) {
        decryptedText = decryptedTextResponse;
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorDecryptionFailed (if decryption fails)
        //In the sample app,the message is being returned as is if decryption fails
        decryptedText = text;
    }];
    
    return decryptedText;
}

/*
 * Returns decrypted text
 */
-(NSString*) encryptText:(NSString *)text {
    
    __block NSString *encryptedText;
    //Encrypt text using Bayun Library
    [[BayunCore sharedInstance]encryptText:text success:^(NSString *responseText) {
        encryptedText = responseText;
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorEncryptionFailed (if encryption fails)
        //In the sample app, nil is being returned if encryption failed
        encryptedText = nil;
    }];
    return encryptedText;
}


@end
