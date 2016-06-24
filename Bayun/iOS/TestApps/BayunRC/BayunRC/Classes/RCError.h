//
//  RCError.h
//  Bayun
//
//  Created by Preeti Gaur on 02/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

//#ifndef Bayun_RCError_h
//#define Bayun_RCError_h
//
//
//#endif

#import <Foundation/Foundation.h>

/*!
 @typedef RCError
 @brief Types of Error
 */
typedef NS_ENUM(NSUInteger, RCError) {
    /**Token is invalid*/
    RCErrorInvalidToken = 0,
    /**Credentials are invalid*/
    RCErrorInvalidCredentials,
    /**No internet connectivity*/
    RCErrorInternetConnection,
    /**Request is timed out*/
    RCErrorRequestTimeOut,
    /**Generic Error*/
    RCErrorSomethingWentWrong
};

