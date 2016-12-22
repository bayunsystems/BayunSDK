//
//  RCCryptManager.m
//  BayunRC
//
//  Created by Preeti Gaur on 24/06/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "RCCryptManager.h"
#import <Bayun/BayunCore.h>

@interface RCCryptManager()

@property (strong,nonatomic) __block NSString *decryptedText;
@property (strong,nonatomic) __block NSString *encryptedText;
@end

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
 * Returns decrypted text
 */
- (NSString*) decryptText :(NSString*) text {

    self.decryptedText = text;
    //Decrypt text using Bayun Library
    [[BayunCore sharedInstance] unlockText:text success:^(NSString *decryptedTextResponse) {
        self.decryptedText = decryptedTextResponse;
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorDecryptionFailed (if decryption fails)
        //In the sample app,the message is being returned as is if decryption fails
        self.decryptedText = text;
    }];
    
    return self.decryptedText;
}

/*
 * Returns encrypted text
 */
-(NSString*) encryptText:(NSString *)text {
    
    //Encrypt text using Bayun Library
    [[BayunCore sharedInstance] lockText:text success:^(NSString *responseText) {
        self.encryptedText = responseText;
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorEncryptionFailed (if encryption fails)
        //In the sample app, nil is being returned if encryption failed
        self.encryptedText = nil;
    }];
    return self.encryptedText;
}


@end
