//
//  test.hpp
//  BayunS3
//
//  Created by Preeti Gaur on 04/01/20.
//  Copyright © 2022 bayun. All rights reserved.
//

#ifndef BayunTracer_h
#define BayunTracer_h
#import <Foundation/Foundation.h>

#ifdef __cplusplus

#include <stdio.h>
//#import <DatadogCPP/opentracing.h>

#endif



@interface BayunTracer : NSObject

//+ (instancetype) sharedInstance;
- (void)initTracer;
-(NSString*) createSpan:(NSString *)name tag:(NSString*)tag value:(NSString*)value;
- (void)setSpanTag:(NSString*)tag value:(NSString*)value;
- (void)finishSpan;
- (void)closeTracer;

@end


#endif /* BayunTracer_h */
