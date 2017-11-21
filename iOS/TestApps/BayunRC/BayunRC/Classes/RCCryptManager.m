//
//  RCCryptManager.m
//  BayunRC
//
//  Created by Preeti Gaur on 24/06/16.
//  Copyright © 2016 Bayun Systems, Inc. All rights reserved.
//

#import "RCCryptManager.h"


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
- (void) decryptText :(NSString*) text success:(void (^)(NSString*))success failure:(void (^)(BayunError))failure{

    self.decryptedText = text;
    //Decrypt text using Bayun Library
    [[BayunCore sharedInstance] unlockText:text success:^(NSString *decryptedTextResponse) {
        self.decryptedText = decryptedTextResponse;
        if (success) {
            success(decryptedTextResponse);
        }
        
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorDecryptionFailed (if decryption fails)
        //In the sample app,the message is being returned as is if decryption fails
        
        if (failure) {
            failure(errorCode);
        }
    }];
}

/*
 * Returns encrypted text
 */
-(void)encryptText:(NSString *)text success:(void (^)(NSString*))success failure:(void (^)(BayunError))failure {
    
    //Encrypt text using Bayun Library
    [[BayunCore sharedInstance] lockText:text success:^(NSString *responseText) {
        self.encryptedText = responseText;
        
        if (success) {
            success(responseText);
        }
        
    } failure:^(BayunError errorCode) {
        //errorCode might be BayunErrorUserInActive (if user is not active or cancelled by admin),
        //BayunErrorEncryptionFailed (if encryption fails)
        //In the sample app, nil is being returned if encryption failed
        self.encryptedText = nil;
        
        if (failure) {
            failure(errorCode);
        }
    }];
   
}


@end
