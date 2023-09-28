//
//  LockingKey.h
//  BayunS3
//
//  Created by Preeti Gaur on 28/09/20.
//  Copyright © 2022 bayun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LockingKeys : NSObject

@property (strong, nonatomic) NSString *key; /**Locking Key*/
@property (strong, nonatomic) NSString *signatureKey; /**Private Key to be used for signature generation*/
@property (strong, nonatomic) NSString *signatureVerificationKey; /**Public Key to be used for signature verification*/

@end

