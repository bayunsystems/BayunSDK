//
//  APIManager.h
//  Bayun
//
//  Created by Preeti Gaur on 03/06/2015.
//  Copyright (c) 2023 Bayun Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayunCore.h"
#include "BayunTracer.h"
#import "BayunEnums.h"

@interface BayunAPIManager : NSObject

+ (instancetype)sharedInstance;

- (void)authenticateEmployee:(NSMutableDictionary*)parameters
                  passphrase:(void(^)(void))passphrase
                    password:(NSString*)password
           securityQuestions:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
                 bayunTracer:(BayunTracer*)tracer
                     success:(void(^)(void))success
                     failure:(void(^)(BayunError))failure;

- (void)createEmployee:(NSDictionary*)parameters
              password:(NSString*)password
           bayunTracer:(BayunTracer*)tracer
     authorizeEmployee:(void (^)(NSString*))authorizeEmployeeBlock
               success:(void (^)(void))success
               failure:(void (^)(BayunError))failure;

- (void)createFirstEmployeeAndCompany:(NSDictionary*)parameters
                             password:(NSString*)password
                          bayunTracer:(BayunTracer*)tracer
                    authorizeEmployee:(void (^)(NSString*))authorizeEmployeeBlock
                              success:(void (^)(void))success
                              failure:(void (^)(BayunError))failure;

- (void)createEmployeeApp:(NSDictionary*)parameters
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure ;

- (void)registerUser:(NSDictionary*)parameters
         bayunTracer:(BayunTracer*)tracer
             success:(void (^)(void))success
             failure:(void (^)(BayunError))failure;


- (void)getClientEmployeeData:(BayunTracer*)tracer
                      success:(void (^)(void))success
                      failure:(void (^)(BayunError))failure;

/**
 Validates employee credentials
 */
- (void)validateEmployeeInfo:(NSDictionary*)credentials
                     success:(void(^)(void))success
                     failure:(void(^)(BayunError))failure;

/**
 Returns data needed to
 1.authenticate an existing employee,
 2.register a new company and first employee,
 3.register a new employee of an existing company with Bayun,
 4.create new employeeApp
 @param credentials NSDictionary mapping appId, companyEmployeeId, companyName.
 @param success Success block to be executed after information is successfully retrieved.
 @param failure Failure block to be executed if information could not be retrieved, returns BayunError.
 
 @see BayunError
 */
- (void)getEmployeeInfo:(NSDictionary*)parameters
            bayunTracer:(BayunTracer*)tracer
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;


- (void)authenticateWithCredentials:(BayunAppCredentials*)credentials
                        companyName:(NSString*)companyName
                  companyEmployeeId:(NSString*)companyEmployeeId
                              email:(NSString*)email
                 autoCreateEmployee:(Boolean)autoCreateEmployee
                        bayunTracer:(BayunTracer*)tracer
                            success:(void(^)(void))success
                            failure:(void(^)(BayunError))failure;

/**
 Authenticates the user with Bayun Lockbox Management Server.
 */
- (void)authenticateWithCredentials:(NSDictionary*)credentials
                         passphrase:(void(^)(void))passphrase
                 autoCreateEmployee:(Boolean)autoCreateEmployee
                  securityQuestions:(void(^)(NSArray*))securityQuestionsBlock
                  authorizeEmployee:(void (^)(NSString*))authorizeEmployee
                        bayunTracer:(BayunTracer*)tracer
                            success:(void(^)(void))success
                            failure:(void(^)(BayunError))failure;

/**
 Validates passphrase with LMS
 */
- (void)validatePassphrase:(NSString*)passphrase
                parameters:(NSDictionary *)parameters
               bayunTracer:(BayunTracer*)tracer
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure;


- (void)setSecurityQuestions:(NSDictionary*)parameters
                 bayunTracer:(BayunTracer*)tracer
                     success:(void (^)(void))success
                     failure:(void (^)(BayunError))failure;

- (void)setPassphrase:(NSDictionary *)parameters
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(void))success
              failure:(void (^)(BayunError))failure;

/**
 Validates Security Questions with LMS
 */
- (void)validateSecurityQuestions:(NSDictionary*)parameters
                      bayunTracer:(BayunTracer*)tracer
                          success:(void (^)(void))success
                          failure:(void (^)(BayunError))failure;

- (void)authorizeEmployee:(NSDictionary*)parameters
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure;

/**
 Get Employee Public Key API
 */
- (void) getEmployeePublicKey:(NSDictionary*)parameters
                  bayunTracer:(BayunTracer*)tracer
                      success:(void (^)(NSArray<AddMemberErrObject*>*))success
                      failure:(void (^)(BayunError))failure;

- (void)getEmployeePublicKeys:(NSDictionary*)parameters
                  bayunTracer:(BayunTracer*)tracer
                      success:(void (^)(NSArray<AddMemberErrObject*>*))success
                      failure:(void (^)(BayunError))failure;
/**
 *Create Group API
 */
- (void)createGroup:(NSDictionary*)parameters
        bayunTracer:(BayunTracer*)tracer
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure;
/**
 *Join Public Group
 */
- (void)joinPublicGroup:(NSDictionary*)parameters
            bayunTracer:(BayunTracer*)tracer
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/**
 *Get Employee's Groups  API
 */
- (void)getMyGroups:(BayunTracer*)tracer
            success:(void (^)(NSArray*))success
            failure:(void (^)(BayunError))failure;

/*
 *Get Unjoined Public Groups API
 */
- (void)getUnjoinedPublicGroups:(BayunTracer*)tracer
                        success:(void (^)(NSArray*))success
                        failure:(void (^)(BayunError))failure;

/**
 *Get Group By Id  API
 */
- (void) getGroupById:(NSString*)groupId
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(NSDictionary*))success
              failure:(void (^)(BayunError))failure;

/**
 *Returns public group Key By GroupId
 */
- (void) getPublicGroupKey:(NSString*)groupId
               bayunTracer:(BayunTracer*)tracer
                   success:(void (^)(NSDictionary*))success
                   failure:(void (^)(BayunError))failure;


/**
 *Returns Group Key By GroupId
 */
- (void) getJoinedGroupKey:(NSString*)groupId
               bayunTracer:(BayunTracer*)tracer
                   success:(void (^)(NSDictionary*))success
                   failure:(void (^)(BayunError))failure;


/*
 *Add Member to Private Group API
 */
- (void)addMember:(NSDictionary*)parameters
      bayunTracer:(BayunTracer*)tracer
          success:(void (^)(void))success
          failure:(void (^)(BayunError))failure;

- (void)addMembers:(NSDictionary*)parameters
       bayunTracer:(BayunTracer*)tracer
           success:(void (^)(NSArray<AddMemberErrObject*>*, NSString*))success
           failure:(void (^)(BayunError))failure;

/*
 *Removes Member from the group
 */
- (void)removeMember:(NSDictionary*)parameters
         bayunTracer:(BayunTracer*)tracer
             success:(void (^)(void))success
             failure:(void (^)(BayunError))failure;


/*
 *Removes list of members from the group
 */
- (void)removeMembers:(NSDictionary*)parameters
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(void))success
              failure:(void (^)(BayunError))failure;

/*
 *Leave Group API
 */
- (void)leaveGroup:(NSString*)groupId
       bayunTracer:(BayunTracer*)tracer
           success:(void (^)(void))success
           failure:(void (^)(BayunError))failure;

/*
 *Delete Group API
 */
- (void)deleteGroup:(NSString*)groupId
        bayunTracer:(BayunTracer*)tracer
            success:(void (^)(void))success
            failure:(void (^)(BayunError))failure;

/**
 Change password on LMS
 */
- (void) changePassword:(NSDictionary *)parameters
            bayunTracer:(BayunTracer*)tracer
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure;

/**
 Gets employee lockbox from Bayun Lockbox Management Server.
 */
- (void)getEmployeeLockBox:(BayunTracer*)tracer
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure;

/**
 Saves encryption/decryption stats on Bayun Lockbox Management Server.
 */
- (void)saveEmployeeStatistics:(BayunTracer*)tracer
                       success:(void (^)(void))success
                       failure:(void (^)(BayunError))failure;

- (void)invalidateEmployeeLockboxRefreshTimer;

- (void)saveEmployeeAppStatisticsKeys:(NSDictionary*)parameters
                               tracer:(BayunTracer*)tracer
                              success:(void (^)(void))success
                              failure:(void (^)(BayunError))failure;

- (void)getTwoFAData:(void(^)(void))passphrase
   securityQuestions:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
         bayunTracer:(BayunTracer*)tracer
             failure:(void (^)(BayunError))failure;

@end
