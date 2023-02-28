//
//  APIManager.m
//  Bayun
//
//  Created by Preeti Gaur on 03/06/2015.
//  Copyright (c) 2023 Bayun Systems, Inc. All rights reserved.
//

#import "BayunAPIManager.h"
#import "BayunAppConfig.h"
#import "BayunUtilities.h"
#import "SecKeyManager.h"
#import "BayunConstants.h"
#import "BayunError.h"
#import "CryptManager.h"
#import "LockboxManager.h"
#import "JFBCrypt.h"
#import "NSUserDefaultsUtility.h"
#import "BayunGroupManager.h"
#import "RSAEncryptionManager.h"
#import "ECCEncryptionManager.h"
#import "AuthenticatedEncryptionManager.h"
#import "BayunLMSError.h"
#include "BayunTracer.h"
#import "SignatureContexts.h"
#import "SignatureMetadata.h"
#import "ThriftFormatter.h"
#import "EmployeePublicKeyMetadata.h"

#define kRetryLimit 3

@interface BayunAPIManager()<UITextFieldDelegate>

@property (nonatomic,assign) BOOL isGetKeyCallRunning;
@property (nonatomic,assign) BOOL isGetEmployeeLockboxCallRunning;
@property (nonatomic,assign) BOOL isGetBayunOauthTokenCallRunning;

@property (strong,nonatomic) NSTimer *employeeLockBoxRefreshTimer;

@property (assign) NSInteger counter;
@property (assign) NSInteger retryCount;
@property (nonatomic,strong) NSMutableArray *getOauthTokenSuccessBlockSpool;
@property (nonatomic,strong) NSMutableArray *getEmpLockboxSuccessBlockSpool;

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passphrase;

@end

@implementation BayunAPIManager


void(^apiManagerfailureBlock)(BayunTracer* ,BayunError, void(^)(BayunError)) = ^(BayunTracer* tracer, BayunError error, void(^failure)(BayunError)) {
  
  [tracer finishSpan];
  if (failure) {
    failure(error);
  }
  return;
};

+ (instancetype)sharedInstance {
  static BayunAPIManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
    sharedInstance.getOauthTokenSuccessBlockSpool = [[NSMutableArray alloc] init];
    sharedInstance.getEmpLockboxSuccessBlockSpool = [[NSMutableArray alloc] init];
  });
  return sharedInstance;
}

#pragma mark - Authenticate APIs

-(NSMutableURLRequest*)requestWithURL:(NSURL*)url
                           parameters:(id)parameters
                           httpMethod:(NSString*)httpMethod
                             is2faAPI:(BOOL)is2faAPI
                            isOpenAPI:(BOOL)isOpenAPI
                               tracer:(NSString*)tracerInfo
                                error:(NSError**)error{
  
  NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [urlRequest setHTTPMethod:httpMethod];
  [urlRequest addValue:tracerInfo forHTTPHeaderField:@"tracer_info"];
  [urlRequest addValue:[NSUserDefaultsUtility tracingLevel] forHTTPHeaderField:@"tracing_log_level"];
  [urlRequest addValue:[NSUserDefaultsUtility appSecret] forHTTPHeaderField:@"app_secret"];
  [urlRequest addValue:[NSUserDefaultsUtility applicationId] forHTTPHeaderField:@"application_id"];
  
  NSString *appPrivateKeyId = [NSUserDefaultsUtility appKeyPairId];
  if(appPrivateKeyId) {
    [urlRequest addValue:appPrivateKeyId forHTTPHeaderField:@"app_key_pair_id"];
  }
  
  if (!isOpenAPI) {
    //Not an Open API, requires auth_token/twofa_token
    if (is2faAPI) {
      
      NSString *twoFAToken = [[SecKeyManager sharedInstance] twoFAToken:nil];
      [urlRequest setValue:twoFAToken
        forHTTPHeaderField:@"twofa_token"];
    } else {
      
      NSString *authToken = [[SecKeyManager sharedInstance] authToken:nil];
      if (!authToken) {
        authToken = @"NULL";
      }
      
      [urlRequest setValue:authToken
        forHTTPHeaderField:@"auth_token"];
    }
  } else {
    NSString *challenge = [NSUserDefaultsUtility challenge];
    if (challenge) {
      [urlRequest addValue:challenge forHTTPHeaderField:@"challenge"];
    }
  }
  
  if (parameters) {
    NSData *postDeviceData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
    [urlRequest setHTTPBody:postDeviceData];
  }
  
  return urlRequest;
}

- (void)getApplicationKeyPairsWith:(NSString*)appId
                         appSecret:(NSString*)appSecret
                           appSalt:(NSString*)salt
                       bayunTracer:(BayunTracer*)tracer
                           success:(void(^)(void))success
                           failure:(void(^)(BayunError))failure {
  
  NSString* lmsAppSecretKey = [[CryptManager sharedInstance] pbkdf2:appSecret salt:salt];
  NSError *error = nil;
  [[SecKeyManager sharedInstance] addLMSAppSecretKey:lmsAppSecretKey error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  [NSUserDefaultsUtility setAppSecret:appSecret];
  [NSUserDefaultsUtility setApplicationId:appId];
  
  NSString *tracerInfo =  [tracer createSpan:@"applicationKeyPairs"
                                         tag:@"BayunAPIManager"
                                       value:@"applicationKeyPairs request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kApplicationKeyPairs]];
  
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:YES tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
        NSLog(@"responseDict getApplicationKeyPairs %@", response);
        NSString *appSecretSalt = [response valueForKey:@"appSecretSalt"];
        [NSUserDefaultsUtility setEncryptionType:[response valueForKey:@"encryptionType"]];
        [NSUserDefaultsUtility setECCCurveType:[response valueForKey:@"eccCurve"]];
        if ([[response valueForKey:@"encryptionType"] isEqualToString:kRSA_AES]) {
          [self addPublicKey:kBayunServerRSAPublicKey tag:SecKeyManager.sharedInstance.bayunServerPublicKeyTag
                 bayunTracer:tracer failure:failure];
        } else if([[response valueForKey:@"encryptionType"] isEqualToString:kECC]) {
          [self addPublicKey:kBayunServerECCPublicKey tag:SecKeyManager.sharedInstance.bayunServerPublicKeyTag
                 bayunTracer:tracer failure:failure];
        }
        
        //Create appPrivKeyDecryptionKey
        NSString *appPrivKeyDecryptionKey = [[CryptManager sharedInstance] pbkdf2:appSecret salt:appSecretSalt];
        NSArray *appKeyPairs = [response valueForKey:@"appKeyPairs"];
        
        for(NSDictionary *appKeyPairData in appKeyPairs) {
          
          //Decrypt App Private Key
          NSError *error = nil;
          NSString *encryptedAppPrivKey = [appKeyPairData valueForKey:@"appPrivateKey"];
          NSData *appPrivateKeyData = [[AuthenticatedEncryptionManager sharedInstance] decrypt:encryptedAppPrivKey
                                                                                       baseKey:appPrivKeyDecryptionKey
                                                                                        baseId:appId bayunTracer:tracer error:&error];
          NSString *appPrivateKey = [[NSString alloc] initWithData:appPrivateKeyData encoding:NSUTF8StringEncoding];
          if (appPrivateKey) {
            if ([[appKeyPairData valueForKey:@"role"] isEqualToString:kAppKeyPairRoleAccess]) {
              [[SecKeyManager sharedInstance] addPrivateKey:appPrivateKey
                                                     forTag:[SecKeyManager sharedInstance].accessAppPrivateKeyTag
                                                      error:&error];
              [NSUserDefaultsUtility setAccessAppKeyPairId:[appKeyPairData valueForKey:@"appKeyPairId"]];
            } else if ([[appKeyPairData valueForKey:@"role"] isEqualToString:kAppKeyPairRoleCreation]) {
              [[SecKeyManager sharedInstance] addPrivateKey:appPrivateKey
                                                     forTag:[SecKeyManager sharedInstance].creationAppPrivateKeyTag
                                                      error:&error];
              [NSUserDefaultsUtility setCreationAppKeyPairId:[appKeyPairData valueForKey:@"appKeyPairId"]];
            } else if ([[appKeyPairData valueForKey:@"role"] isEqualToString:kAppKeyPairRoleAuthorization]) {
              [[SecKeyManager sharedInstance] addPrivateKey:appPrivateKey
                                                     forTag:[SecKeyManager sharedInstance].authorizationAppPrivateKeyTag
                                                      error:&error];
              [NSUserDefaultsUtility setAuthorizationAppKeyPairId:[appKeyPairData valueForKey:@"appKeyPairId"]];
            }
            if (error) {
              if (failure) {
                failure(BayunErrorSomethingWentWrong);
              }
              return;
            }
          } else {
            if (failure) {
              failure(BayunErrorSomethingWentWrong);
              return;
            }
          }
        }
        
        if (success) {
          success();
        }
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  
  [dataTask resume];
}


- (void)authenticateWithCredentials:(BayunAppCredentials*)credentials
                        companyName:(NSString*)companyName
                  companyEmployeeId:(NSString*)companyEmployeeId
                              email:(NSString*)email
                 autoCreateEmployee:(Boolean)autoCreateEmployee
                        bayunTracer:(BayunTracer*)tracer
                            success:(void(^)(void))success
                            failure:(void(^)(BayunError))failure {
  
  // [BayunUtilities clearUserData];
  
  if (!self.isGetBayunOauthTokenCallRunning) {
    self.isGetBayunOauthTokenCallRunning = YES;
    
    [self getApplicationKeyPairsWith:credentials.appId
                           appSecret:credentials.appSecret
                             appSalt:credentials.appSalt
                         bayunTracer:tracer success:^{
      
      [NSUserDefaultsUtility setCompanyName:companyName];
      [NSUserDefaultsUtility setCompanyEmployeeId:companyEmployeeId];
      [NSUserDefaultsUtility setApplicationId:credentials.appId];
      [NSUserDefaultsUtility setAppSecret:credentials.appSecret];
      
      
      NSDictionary *empInfoParameters = [[NSMutableDictionary alloc]
                                         initWithDictionary:@{@"companyName" : companyName,
                                                              @"companyEmployeeId" : companyEmployeeId}];
      if (![email isEqual:[NSNull null]]) {
        [empInfoParameters setValue:email forKey:@"emailAddress"];
      }
      
      NSLog(@"empInfoParameters %@",empInfoParameters);
      
      //get auth and key salts
      [self getEmployeeInfo:empInfoParameters
         autoCreateEmployee:autoCreateEmployee
                bayunTracer:tracer
                    success:success failure:failure];
    } failure:failure];
    
  } else {
    [self.getOauthTokenSuccessBlockSpool addObject:success];
  }
}

- (void)authenticateEmployee:(NSMutableDictionary*)parameters
                  passphrase:(void(^)(void))passphrase
                    password:(NSString*)password
           securityQuestions:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
                 bayunTracer:(BayunTracer*)tracer
                     success:(void(^)(void))success
                     failure:(void(^)(BayunError))failure {
  
  NSString *tracerInfo =  [tracer createSpan:@"authenticate"
                                         tag:@"BayunAPIManager"
                                       value:@"authenticateEmployee request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url;
  NSString *apiName = @"";
  if (password) {
    apiName = @"authenticateEmployeeWithPwd %@";
    NSLog(@"authenticateEmployeeWithPwd %@",parameters);
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAuthenticateEmployee]];
  } else {
    apiName = @"authenticateEmployeeWithoutPwd %@";
    NSLog(@"authenticateEmployeeWithoutPwd %@",parameters);
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAuthenticateWithoutPwd]];
  }
  
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:YES tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"responseDict %@  : %@", apiName, responseDict);
        if (responseDict) {
          [self saveAuthDetails:responseDict bayunTracer:tracer success:^{
            self.password = password;
            MFA mfaSetting = [NSUserDefaultsUtility mfaSetting];
            if (![NSUserDefaultsUtility isAppCreatedWithPassword] ||
                (mfaSetting != MFASingleFAWithPassword)) {
              
              [self getTwoFAData:passphrase
               securityQuestions:securityQuestionsBlock
                     bayunTracer:tracer
                         failure:^(BayunError error) {
                apiManagerfailureBlock(tracer, error, failure);
              }];
              
            } else {
              [self getClientEmployeeData:tracer success:^{
                [tracer finishSpan];
                success();
              } failure:^(BayunError error) {
                apiManagerfailureBlock(tracer, error, failure);
              }];
            }
          } failure:failure];
        }
      } else {
        apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
      }
    } else {
      
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

- (void)registerUser:(NSDictionary*)parameters
         bayunTracer:(BayunTracer*)tracer
             success:(void (^)(void))success
             failure:(void (^)(BayunError))failure {
  NSLog(@"registerUser %@",parameters);
  NSString *tracerInfo = [tracer createSpan:@"registerUser" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kRegisterUser]];
  
  NSError *error;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:YES tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"RegisterUser responseDict %@ : ", responseDict);
        if (responseDict) {
          [NSUserDefaultsUtility setIsTracingEnabled:[responseDict valueForKey:@"isTracingEnabled"]];
          [NSUserDefaultsUtility setTracingLogLevel:[responseDict valueForKey:@"tracingLogLevel"]];
          NSString *userId = [responseDict valueForKey:@"userId"];
          NSString *twoFAToken = [responseDict valueForKey:@"twoFAToken"];
          
          if (![[responseDict valueForKey:@"multiFactorAuthentication"] isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setMFASetting:[responseDict valueForKey:@"multiFactorAuthentication"]];
          }
          
          
          BOOL isSignatureVerified;
          if (![userId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userId
                                                                                        groupId:nil
                                                                                    bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            [NSUserDefaultsUtility setUserId:userId];
          }
          
          if (![twoFAToken isEqual:[NSNull null]])  {
            
            NSError *error = nil;
            [[SecKeyManager sharedInstance] addTwoFAToken:[responseDict valueForKey:@"twoFAToken"] error: &error];
            if (error) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
          }
          
          if (success) {
            success();
          }
        }
      } else {
        apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

- (void)createEmployee:(NSDictionary*)parameters
              password:(NSString*)password
           bayunTracer:(BayunTracer*)tracer
     authorizeEmployee:(void (^)(NSString*))authorizeEmployeeBlock
               success:(void (^)(void))success
               failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo = [tracer createSpan:@"createEmployee" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url;
  bool is2faAPI = false;
  bool isOpenAPI = true;
  if ([parameters valueForKey:@"authPasswordHash"]) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kCreateEmployee]];
  } else {
    is2faAPI = true;
    isOpenAPI = false;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kUserCreateEmployee]];
  }
  
  NSError *error;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:is2faAPI isOpenAPI:isOpenAPI tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"CreateEmployee responseDict %@ : ", responseDict);
        if (responseDict) {
          [self checkForEmployeeAuthorization:parameters
                       authorizeEmployeeBlock:authorizeEmployeeBlock
                                      success:^{
            
            [self saveAuthDetails:responseDict bayunTracer:tracer success:^{
              self.password = password;
              [self getClientEmployeeData:tracer success:success failure:failure];
            } failure:failure];
          } failure:failure];;
        }
      } else {
        apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

- (void)createFirstEmployeeAndCompany:(NSDictionary*)parameters
                             password:(NSString*)password
                          bayunTracer:(BayunTracer*)tracer
                    authorizeEmployee:(void (^)(NSString*))authorizeEmployeeBlock
                              success:(void (^)(void))success
                              failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo =  [tracer createSpan:@"createFirstEmployeeAndCompany"
                                         tag:@"BayunAPIManager"
                                       value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url;
  bool is2faAPI = false;
  if ([parameters valueForKey:@"authPasswordHash"]) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kCreateFirstEmployeeAndCompany]];
  } else {
    is2faAPI = true;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kUserCreateFirstEmployeeAndCompany]];
  }
  
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:is2faAPI isOpenAPI:YES tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"CreateFirstEmployeeAndCompany responseDict %@ : ", responseDict);
        if (responseDict) {
          
          [self checkForEmployeeAuthorization:parameters
                       authorizeEmployeeBlock:authorizeEmployeeBlock
                                      success:^{
            
            [self saveAuthDetails:responseDict bayunTracer:tracer success:^{
              self.password = password;
              [self getClientEmployeeData:tracer success:success failure:failure];
            } failure:failure];
          } failure:failure];
          
        }
      } else {
        apiManagerfailureBlock(tracer,BayunErrorSomethingWentWrong, failure);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

-(NSString*) getUnauthorizedEmpPubKey:(NSString*)companyName
                    companyEmployeeId:(NSString*)companyEmployeeId
                    employeePublicKey:(NSString*)employeePublicKey {
  EmployeePublicKeyMetadata *empPublicKeyMetadata = [[EmployeePublicKeyMetadata alloc] initWithCompanyName:[NSUserDefaultsUtility companyName] companyEmployeeId:[NSUserDefaultsUtility companyEmployeeId] signedPublicKey:employeePublicKey];
  
  ThriftFormatter *tf = [[ThriftFormatter alloc] init];
  NSData *serializedEmpPublicKeyMetadata = [tf serialize:empPublicKeyMetadata];
  NSString *serializedEmpPublicKeyMetadataStr = [BayunUtilities base64StringforData:serializedEmpPublicKeyMetadata];
  return  serializedEmpPublicKeyMetadataStr;
}

-(void)checkForEmployeeAuthorization:(NSDictionary*)parameters
              authorizeEmployeeBlock:(void (^)(NSString*))authorizeEmployeeBlock
                             success:(void (^)(void))success
                             failure:(void (^)(BayunError))failure {
  
  if ([[SecKeyManager sharedInstance] getPrivateKeyForTag:
       SecKeyManager.sharedInstance.authorizationAppPrivateKeyTag error:nil] == nil) {
    
    NSDictionary *employeeKeyPairRequest = [parameters valueForKey:@"employeeKeyPairRequest"];
    NSString *employeePublicKey = [employeeKeyPairRequest valueForKey:@"publicKey"];
    
    NSString *serializedEmpPubKeyMetadataStr = [self getUnauthorizedEmpPubKey:[NSUserDefaultsUtility companyName]
                                                            companyEmployeeId:[NSUserDefaultsUtility companyEmployeeId]
                                                            employeePublicKey:(NSString *)employeePublicKey];
    
    if (authorizeEmployeeBlock && serializedEmpPubKeyMetadataStr) {
      authorizeEmployeeBlock(serializedEmpPubKeyMetadataStr);
    } else {
      failure(BayunErrorAuthenticationFailed);
    }
  } else {
    success();
  }
}

- (void)createEmployeeApp:(NSDictionary*)parameters
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure {
  
  NSError *error;
  NSString *tracerInfo = [tracer createSpan:@"createEmployeeApp" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL *url;
  bool is2faAPI = false;
  if ([parameters valueForKey:@"authPasswordHash"]) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kCreateEmployeeApp]];
  } else {
    is2faAPI = true;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kUserCreateEmployeeApp]];
  }
  
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:is2faAPI isOpenAPI:YES tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      NSError *error = nil;
      NSDictionary *responseDict = [NSJSONSerialization
                                    JSONObjectWithData: data
                                    options: NSJSONReadingMutableContainers
                                    error: &error];
      NSLog(@"CreateEmployeeApp responseDict %@ : ", responseDict);
      if (responseDict) {
        
        if (![[responseDict valueForKey:@"authToken"] isEqual:[NSNull null]]) {
          [[SecKeyManager sharedInstance] addAuthToken:[responseDict valueForKey:@"authToken"] error:&error];
        }
        
        if (![[responseDict valueForKey:@"authTokenExpiry"] isEqual:[NSNull null]]) {
          [NSUserDefaultsUtility setBayunOauthTokenExpirationTime:[responseDict valueForKey:@"authTokenExpiry"]];
        }
      }
      success();
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

- (void)setPassphrase:(NSDictionary *)parameters
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(void))success
              failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"setPassphrase" tag:@"BayunAPIManager" value:@"setPassphrase request"];
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  NSError *error = nil;
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kSetPassphrase]];
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      NSLog(@"Set Passphrase Success");
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

- (void)authorizeEmployee:(NSDictionary*)parameters
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(void))success
                  failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo = [tracer createSpan:@"authorizeEmployee" tag:@"BayunAPIManager" value:@"authorizeEmployee request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAuthorizeEmployee]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      NSLog(@"Authorize Employee Success");
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  
  [dataTask resume];
}

- (void)setSecurityQuestions:(NSDictionary*)parameters
                 bayunTracer:(BayunTracer*)tracer
                     success:(void (^)(void))success
                     failure:(void (^)(BayunError))failure {
  
  NSLog(@"setSecurityQuestions params : %@", parameters);
  NSString *tracerInfo = [tracer createSpan:@"setSecurityQuestions" tag:@"BayunAPIManager" value:@"setSecurityQuestions request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kSetSecurityQuestions]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      NSLog(@"Set SecurityQuestions Success");
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  
  [dataTask resume];
}

#pragma mark - Get Data APIs

- (void)getTwoFAData:(void(^)(void))passphrase
   securityQuestions:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
         bayunTracer:(BayunTracer*)tracer
             failure:(void (^)(BayunError))failure {
  
  NSError *error;
  NSString *tracerInfo = [tracer createSpan:@"getTwoFAData" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kTwoFAData]];
  NSURL * url = components.URL;
  
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"GetTwoFAData responseDict %@ : ", responseDict);
        if (responseDict) {
          [self saveTwoFAData:responseDict
                   passphrase:passphrase
            securityQuestions:securityQuestionsBlock
                  bayunTracer:tracer
                      failure:failure];
        }
      } else {
        apiManagerfailureBlock(tracer,BayunErrorSomethingWentWrong, failure);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}


- (void)saveDeviceInfo:(BayunTracer*)tracer
               success:(void (^)(void))success
               failure:(void (^)(BayunError))failure {
  NSString *tracerInfo = [tracer createSpan:@"saveDeviceInfo" tag:@"BayunAPIManager" value:@"request"];
  
  if (![NSUserDefaultsUtility uniqueDeviceId]) {
    [NSUserDefaultsUtility setUniqueDeviceId:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
  }
  
  
  NSString *companyName = [NSUserDefaultsUtility companyName];
  NSString *companyEmpId = [NSUserDefaultsUtility companyEmployeeId];
  NSString *appId = [NSUserDefaultsUtility applicationId];
  NSString *baseId = [NSString stringWithFormat:@"%@%@%@",companyName,companyEmpId,appId];
  NSString *deviceKey = [[SecKeyManager sharedInstance] generateRandomKey];
  NSString *employeeKey = [[SecKeyManager sharedInstance] employeeKey:nil];
  
  
  //encrypt device info using deviceKey
  NSString *deviceUUID = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[NSUserDefaultsUtility uniqueDeviceId] baseKey:deviceKey baseId:baseId bayunTracer:tracer];
  NSString *model = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[BayunUtilities deviceModelNumber] baseKey:deviceKey baseId:baseId bayunTracer:tracer];
  NSString *os = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[[UIDevice currentDevice] systemName] baseKey:deviceKey baseId:baseId bayunTracer:tracer];
  NSString *version = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[[UIDevice currentDevice] systemVersion] baseKey:deviceKey baseId:baseId bayunTracer:tracer];
  
  //encrypt deviceKey using employeeKey
  NSString *employeeEncryptedDeviceKey = [[AuthenticatedEncryptionManager sharedInstance] encrypt:deviceKey baseKey:employeeKey baseId:baseId bayunTracer:tracer];
  
  //encrypt deviceKey using adminPublicKey
  NSDictionary *result =  [[CryptManager sharedInstance] encrypt:deviceKey publicKeyTag:SecKeyManager.sharedInstance.adminPublicTag baseId:baseId bayunTracer:tracer error:nil];
  
  if (deviceUUID && model && os && version && employeeEncryptedDeviceKey && result ) {
    NSDictionary *deviceInfo = @{
      @"uniqueDeviceId" : deviceUUID,
      @"operatingSystem" : os,
      @"version" : version,
      @"model" : model,
      @"employeeEncryptedDeviceKey" : employeeEncryptedDeviceKey,
      @"adminEncryptedDeviceKey" : [result valueForKey:kEncryptedPlainString],
      @"adminEncryptedDeviceKey_kek" : [result valueForKey:kEncryptedKEK],
      @"brand" : [NSNull null],
      @"manufacturer" : [NSNull null],
      @"versionRelease" : [NSNull null],
      @"versionIncremental" : [NSNull null],
      @"versionSdkNumber" : [NSNull null],
      @"imeiNumber" : [NSNull null],
      @"androidDeviceId" : [NSNull null],
      @"macAddress" : [NSNull null],
      @"host" : [NSNull null],
      @"display" : [NSNull null],
      @"serial" : [NSNull null],
      @"board" : [NSNull null],
      @"bootloader" : [NSNull null],
      @"fingerprint" : [NSNull null],
      @"hardware" : [NSNull null]};
    
    NSError *error;
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:
                                   [NSString stringWithFormat:@"%@%@",kBaseUrl,kDeviceInfo]];
    NSURL * url = components.URL;
    NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:deviceInfo httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
    if (error) {
      [self executeFailureBlock:failure bayunTracer:tracer error:error];
      return;
    }
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      self.isGetBayunOauthTokenCallRunning = NO;
      
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
      NSInteger statusCode = httpResponse.statusCode;
      
      if(200 == statusCode) {
        [tracer finishSpan];
        if (success) {
          success();
        }
      } else {
        [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
      }
    }];
    [dataTask resume];
    
  } else {
    apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
  }
}

- (void)getClientEmployeeData:(BayunTracer*)tracer
                      success:(void (^)(void))success
                      failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getClientEmployeeData" tag:@"BayunAPIManager" value:@"request"];
  
  NSError *error;
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kEmployeeClientData]];
  NSURL * url = components.URL;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      if (data) {
        NSError *err = nil;
        NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData: data
                                      options: NSJSONReadingMutableContainers
                                      error: &err];
        NSLog(@"GetClientEmployeeData responseDict %@ : ", responseDict);
        if (responseDict) {
          
          //save device info on LMS
          [self saveDeviceInfo:tracer success:nil failure:nil];
          
          BOOL isSignatureVerified = true;
          
          NSString *employeeId = [responseDict valueForKey:@"employeeId"];
          NSString *companyId = [responseDict valueForKey:@"companyId"];
          NSString *employeeAppId = [responseDict valueForKey:@"employeeAppId"];
          NSString *employeeAppPublicKey = [responseDict valueForKey:@"employeeAppPublicKey"];
          
          if (![[responseDict valueForKey:@"employeeAppPrivateKey"] isEqual:[NSNull null]]) {
            NSString *encryptedEmployeeAppPrivateKey = [responseDict valueForKey:@"employeeAppPrivateKey"];
            [NSUserDefaultsUtility setEncryptedEmpAppPrivateKey: encryptedEmployeeAppPrivateKey];
          }
          
          if (![[responseDict valueForKey:@"employeeKeySalt"] isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setEmployeeKeySalt:[responseDict valueForKey:@"employeeKeySalt"]];
          }
          
          if (![[responseDict valueForKey:@"employeeStatus"] isEqual:[NSNull null]]) {
            // save employee status
            [NSUserDefaultsUtility setEmployeeStatus:[responseDict valueForKey:@"employeeStatus"]];
          }
          
          if (![companyId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:companyId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            [NSUserDefaultsUtility setCompanyId:[BayunUtilities separateMessageFromSignatures:companyId]];
          }
          
          if (![employeeId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            [NSUserDefaultsUtility setBayunEmployeeId:[BayunUtilities separateMessageFromSignatures:employeeId]];
          }
          
          if (![employeeAppId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeAppId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            [NSUserDefaultsUtility setBayunEmployeeAppId:[BayunUtilities separateMessageFromSignatures:employeeAppId]];
          }
          
          if (employeeAppPublicKey != nil && ![employeeAppPublicKey isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeAppPublicKey
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            [self addPublicKey:[BayunUtilities separateMessageFromSignatures:employeeAppPublicKey] tag:SecKeyManager.sharedInstance.employeeAppPublicTag bayunTracer:tracer failure:failure];
          }
          
          MFA mfa = [NSUserDefaultsUtility mfaSetting];
          
          void(^getEmployeeLockbox)(void) = ^ {
            [self getEmployeeLockBox:tracer success:^{
              //save employeeClientData
              [self saveEmployeeClientData:responseDict bayunTracer:tracer success:^{
                [self startEmployeeLockBoxRefreshTimer];
              } failure:failure];
              success();
            } failure:failure];
          };
          
          if ([NSUserDefaultsUtility encryptedEmpAppPrivateKey] &&
              (mfa == MFASingleFAWithPassword ||
               mfa == MFATwoFactorAuthenticationWithPassphrase ||
               mfa == MFATwoFactorAuthenticationWithoutPassphrase)) {
            //Login/Register with pwd
            //employeeAppPrivateKey is not NULL, decrypt, save and fetch employee lockbox
            [[CryptManager sharedInstance] decryptEmployeeAppPrivateKey:^{
              
              if ([BayunCore sharedInstance].employeeStatus != BayunEmployeeStatusRegistered &&
                  [BayunCore sharedInstance].employeeStatus != BayunEmployeeStatusCancelled ) {
                //get employeeLockbox
                getEmployeeLockbox();
              } else {
                //save employeeClientData
                [self saveEmployeeClientData:responseDict bayunTracer:tracer success:success failure:failure];
              }
              
            } password:self.password bayunTracer:tracer failure:^(BayunError error) {
              apiManagerfailureBlock(tracer,error, failure);
            }];
          } else {
            //Login/Register without pwd
            getEmployeeLockbox();
            //apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
          }
        }
      } else {
        apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
  
}

- (void)validateEmployeeInfo:(NSDictionary*)credentials
                 bayunTracer:(BayunTracer*)tracer
                     success:(void(^)(void))success
                     failure:(void(^)(BayunError))failure {
  
  [tracer createSpan:@"validateEmployeeInfo" tag:@"BayunAPIManager" value:@"request"];
  
  NSString *company = [credentials valueForKey:@"companyName"];
  NSString *employee = [credentials valueForKey:@"companyEmployeeId"];
  
  if (company && employee) {
    NSDictionary *empInfoParameters  = @{@"companyName" : company,
                                         @"companyEmployeeId" : employee};
    
    [self getEmployeeInfo:empInfoParameters autoCreateEmployee:false bayunTracer:tracer success:^{
      [tracer finishSpan];
      if ([NSUserDefaultsUtility companyId] && [NSUserDefaultsUtility bayunEmployeeId]) {
        [tracer finishSpan];
        if (success) {
          success();
        }
      } else {
        if(![NSUserDefaultsUtility companyId] && ![NSUserDefaultsUtility bayunEmployeeId]) {
          apiManagerfailureBlock(tracer, BayunErrorInvalidCredentials, failure);
        } else if (![NSUserDefaultsUtility companyId]) {
          apiManagerfailureBlock(tracer, BayunErrorCompanyDoesNotExists, failure);
        } else if (![NSUserDefaultsUtility bayunEmployeeId]) {
          apiManagerfailureBlock(tracer, BayunErrorEmployeeNotExistsInGivenCompany, failure);
        }
      }
    } failure:failure];
  } else {
    apiManagerfailureBlock(tracer, BayunErrorCredentialsCannotBeNil, failure);
  }
}

- (void)getEmployeeInfo:(NSDictionary*)parameters
     autoCreateEmployee:(Boolean)autoCreateEmployee
            bayunTracer:(BayunTracer*)tracer
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getEmployeeInfo" tag:@"BayunAPIManager" value:@"request"];
  
  NSString *companyName = [parameters valueForKey:@"companyName"];
  NSString *companyEmployeeId = [parameters valueForKey:@"companyEmployeeId"];
  
  if (companyName && companyEmployeeId) {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kGetEmployeeInfo]];
    
    NSError *error = nil;
    NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:YES tracer:tracerInfo error:&error];
    
    if (error) {
      [self executeFailureBlock:failure bayunTracer:tracer error:error];
      return;
    }
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      self.isGetBayunOauthTokenCallRunning = NO;
      
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
      NSInteger statusCode = httpResponse.statusCode;
      
      if(200 == statusCode) {
        
        if (data) {
          NSError *error = nil;
          
          NSDictionary *responseDict = [NSJSONSerialization
                                        JSONObjectWithData: data
                                        options: NSJSONReadingMutableContainers
                                        error: &error];
          NSLog(@"GetEmployeeInfo responseDict %@ : ", responseDict);
          if (error) {
            apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
            return;
          }
          
          BOOL isSignatureVerified = true;
          NSString *companyId = [responseDict valueForKey:@"companyId"];
          NSString *employeeAppId = [responseDict valueForKey:@"employeeAppId"];
          NSString *employeeId = [responseDict valueForKey:@"employeeId"];
          NSString *ghostEmployeeId = [responseDict valueForKey:@"ghostEmployeeId"];
          NSString *backdoorPublicKey = [responseDict valueForKey:@"backdoorPublicKey"];
          NSString *adminPublicKey = [responseDict valueForKey:@"adminPublicKey"];
          NSString *ghostEmployeePublicKey = [responseDict valueForKey:@"ghostEmployeePublicKey"];
          NSString *appName = [responseDict valueForKey:@"appName"];
          NSString *multiFactorAuthentication = [responseDict valueForKey:@"multiFactorAuthentication"];
          NSString *userStatus = [responseDict valueForKey:@"userStatus"];
          NSString *isAppCreatedWithPassword = [responseDict valueForKey:@"isAppCreatedWithPassword"];
          NSString *challengeWithSignatures = [responseDict valueForKey:@"challenge"];
          NSString *challenge_kek = [responseDict valueForKey:@"challenge_kek"];
          NSString *employeeAppStatus = [responseDict valueForKey:@"employeeAppStatus"];
          
          AuthFlow authFlow = [NSUserDefaultsUtility authFlow];
          [NSUserDefaultsUtility setUserStatus:userStatus];
          if (![multiFactorAuthentication isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setMFASetting:multiFactorAuthentication];
          }
          
          if (![appName isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setAppName:appName];
          }
          
          if (![isAppCreatedWithPassword isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setIsAppCreatedWithPassword:isAppCreatedWithPassword];
          }
          
          BOOL isAppCreatedWithPwd = false;
          if (![isAppCreatedWithPassword isEqual:[NSNull null]] &&
              [isAppCreatedWithPassword isEqualToString:@"true"]) {
            isAppCreatedWithPwd = true;
          }
          
          if (![employeeId isEqual:[NSNull null]]) {
            //Employee Exists
            if ([employeeAppStatus isEqualToString:kEmpAppStatusLinked]) {
              if (authFlow == AuthFlowRegisterWithoutPwd) {
                if (isAppCreatedWithPwd) {
                  apiManagerfailureBlock(tracer, BayunErrorEmployeeAccountHasPasswordEnabled, failure);
                  return;
                } else {
                  apiManagerfailureBlock(tracer, BayunErrorUserAlreadyExists, failure);
                  return;
                }
              } else if(authFlow == AuthFlowRegisterWithPwd) {
                apiManagerfailureBlock(tracer, BayunErrorEmployeeAlreadyExists, failure);
                return;
              } else if (!isAppCreatedWithPwd && [userStatus isEqualToString:kUserStatusPartiallyLinked]) {
                apiManagerfailureBlock(tracer,  BayunErrorLinkEmployeeUserAccount, failure);
                return;
              } else if (authFlow == AuthFlowLoginWithoutPwd && isAppCreatedWithPwd &&
                         ![multiFactorAuthentication isEqualToString:kMFASingleFAWithSecurityQuestions] &&
                         ![multiFactorAuthentication isEqualToString:kMFASingleFAWithSecurityQuestionsAndPassphrase]) {
                apiManagerfailureBlock(tracer, BayunErrorUserAccountHasPasswordEnabled, failure);
                return;
              }
            } else if ([employeeAppStatus isEqualToString:kEmpAppStatusUnlinked]) {
              if (authFlow == AuthFlowLoginWithPwd) {
                apiManagerfailureBlock(tracer, BayunErrorAppNotLinked, failure);
                return;
              }
            } else if ([employeeAppStatus isEqualToString:kEmpAppStatusNotExists]) {
              if (authFlow == AuthFlowLoginWithoutPwd) {
                if ([userStatus isEqualToString:kUserStatusRegistered]) {
                  apiManagerfailureBlock(tracer, BayunErrorEmployeeAppNotRegistered, failure);
                  return;
                } else {
                  apiManagerfailureBlock(tracer, BayunErrorUserIsNotRegistered, failure);
                  return;
                }
              } else if (authFlow == AuthFlowLoginWithPwd) {
                apiManagerfailureBlock(tracer, BayunErrorEmployeeAppNotRegistered, failure);
                return;
              }
            }
          } else {
            //employeId == NULL
            if (authFlow == AuthFlowLoginWithoutPwd ||
                (authFlow == AuthFlowLoginWithPwd && !autoCreateEmployee) ) {
              apiManagerfailureBlock(tracer, BayunErrorEmployeeDoesNotExists, failure);
              return;
            } else if (authFlow == AuthFlowLoginWithPwd ||
                       authFlow == AuthFlowRegisterWithPwd) {
              //employeeId_ = nil, autoCreateEmployee = true for both login and register with pwd
              isAppCreatedWithPwd = true;
              [NSUserDefaultsUtility setIsAppCreatedWithPassword:@"true"];
              if ([multiFactorAuthentication isEqual:[NSNull null]]) {
                [NSUserDefaultsUtility setMFASetting:kMFASingleFAWithPassword];
              }
            }
          }
          
          //Verify Challenge
          isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:challengeWithSignatures
                                                                                      groupId:nil bayunTracer:tracer];
          if (!isSignatureVerified) {
            apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
            return;
          }
          
          NSData *appPrivateKeyTag;
          if (![[NSUserDefaultsUtility authorizationAppKeyPairId] isEqual:[NSNull null]] &&
              [NSUserDefaultsUtility authorizationAppKeyPairId]) {
            appPrivateKeyTag = [SecKeyManager sharedInstance].authorizationAppPrivateKeyTag;
          } else if (![[NSUserDefaultsUtility creationAppKeyPairId] isEqual:[NSNull null]] &&
                     [NSUserDefaultsUtility creationAppKeyPairId]) {
            appPrivateKeyTag = [SecKeyManager sharedInstance].creationAppPrivateKeyTag;
          } else if (![[NSUserDefaultsUtility accessAppKeyPairId] isEqual:[NSNull null]] &&
                     [NSUserDefaultsUtility accessAppKeyPairId]) {
            appPrivateKeyTag = [SecKeyManager sharedInstance].accessAppPrivateKeyTag;
          }
          
          //Decrypt Challenge
          NSString *appId = [NSUserDefaultsUtility applicationId];
          NSArray *challengeAndSignatures = [challengeWithSignatures componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:kSignaturesSeparator]];
          NSString *challenge = [challengeAndSignatures objectAtIndex:0];
          NSString *baseId = [NSString stringWithFormat:@"%@%@%@",companyName,companyEmployeeId,appId];
          NSString *decryptedChallenge = [[CryptManager sharedInstance] decrypt:challenge privateKeyTag:appPrivateKeyTag kek:challenge_kek baseId:baseId bayunTracer:tracer error:&error];
          
          if (!decryptedChallenge) {
            apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
            return;
          }
          
          [NSUserDefaultsUtility setChallenge:decryptedChallenge];
          if (![employeeAppStatus isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setEmployeeAppStatus:employeeAppStatus];
            if([employeeAppStatus isEqualToString:kEmpAppStatusNotExists]) {
              //employeeKeySalt is used in the generation of key to encrypt employeeAppPrivateKey
              if (![[responseDict valueForKey:@"employeeKeySalt"] isEqual:[NSNull null]]) {
                [NSUserDefaultsUtility setEmployeeKeySalt:[responseDict valueForKey:@"employeeKeySalt"]];
              }
            }
          }
          
          
          
          if (![companyId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:companyId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            [NSUserDefaultsUtility setCompanyId:companyId];
          }
          
          if (![ghostEmployeeId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] verify:ghostEmployeeId
                                                     publicKeyTagString:kBayunServerPublicKeyTag
                                               verificationPublicKeyTag:nil groupId:nil
                                                            bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            [NSUserDefaultsUtility setGhostEmployeeId:ghostEmployeeId];
          }
          
          if (![backdoorPublicKey isEqual:[NSNull null]]) {
            
            NSData *tag = [SecKeyManager sharedInstance].backdoorPublicKeyTag;
            [self addPublicKey:backdoorPublicKey tag:tag bayunTracer:tracer failure:failure];
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:backdoorPublicKey
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            if (![BayunUtilities retrieveAndSavePublicKey:backdoorPublicKey publicKeyTag:[SecKeyManager sharedInstance].backdoorPublicKeyTag]) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
          }
          
          if (![adminPublicKey isEqual:[NSNull null]]) {
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:adminPublicKey groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            if (![BayunUtilities retrieveAndSavePublicKey:adminPublicKey publicKeyTag:[SecKeyManager sharedInstance].adminPublicTag]) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
          }
          
          if (![ghostEmployeePublicKey isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] verify:ghostEmployeePublicKey publicKeyTagString:kBayunServerPublicKeyTag verificationPublicKeyTag:nil
                                                                groupId:nil
                                                            bayunTracer:tracer];
            //[[CryptManager sharedInstance] retrieveAndverifyLastSignature:ghostEmployeePublicKey groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            //save ghostEmployeePublicKey in keychain
            if (![BayunUtilities retrieveAndSavePublicKey:ghostEmployeePublicKey publicKeyTag:[SecKeyManager sharedInstance].ghostEmployeePublicTag]) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            //save ghostEmployeePublicKey with signatures in nsuserdefaults
            [NSUserDefaultsUtility setGhostEmpPubKeyWithSignatures:ghostEmployeePublicKey];
          }
          
          if (![employeeId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            
            [NSUserDefaultsUtility setBayunEmployeeId:employeeId];
          }
          
          if (![employeeAppId isEqual:[NSNull null]]) {
            
            isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeAppId
                                                                                        groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
              return;
            }
            [NSUserDefaultsUtility setBayunEmployeeAppId:employeeAppId];
          }
          
          if (![[responseDict valueForKey:@"employeeAuthSalt"] isEqual:[NSNull null]]) {
            [NSUserDefaultsUtility setEmployeeAuthSalt:[responseDict valueForKey:@"employeeAuthSalt"]];
          }
          
          if (success) {
            success();
          }
          
          [tracer finishSpan];
          
        }
      } else {
        
        [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
      }
    }];
    [dataTask resume];
  } else {
    apiManagerfailureBlock(tracer, BayunErrorCredentialsCannotBeNil, failure);
  }
}

/*
 *This method gets the oauth token from LMS
 */
- (void)getBayunOauthToken:(BayunTracer*)tracer success:(void (^)(void))success failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getBayunOauthToken request" tag:@"BayunAPIManager" value:@"request"];
  
  NSString *company = [NSUserDefaultsUtility companyName];
  NSString *employee = [NSUserDefaultsUtility companyEmployeeId];
  NSString *authPasswordHash = [[SecKeyManager sharedInstance] authPasswordHash:nil];
  NSString *appId = [NSUserDefaultsUtility applicationId];
  NSString *employeeAuthSalt = [NSUserDefaultsUtility employeeAuthSalt];
  NSString *employeeKeySalt = [NSUserDefaultsUtility employeeKeySalt];
  
  if (company && employee && authPasswordHash && appId && employeeAuthSalt && employeeAuthSalt) {
    
    
    NSDictionary *parameters = @{@"companyName" : company,
                                 @"companyEmployeeId" :employee,
                                 @"authPasswordHash" :authPasswordHash,
                                 @"appId" : appId,
                                 @"employeeAuthSalt" : employeeAuthSalt,
                                 @"employeeKeySalt" : employeeKeySalt
    };
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAuthenticateEmployee]];
    NSError *error = nil;
    NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:YES tracer:tracerInfo error:&error];
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      self.isGetBayunOauthTokenCallRunning = NO;
      
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
      NSInteger statusCode = httpResponse.statusCode;
      
      NSError *e = nil;
      NSDictionary *responseDict = [NSJSONSerialization
                                    JSONObjectWithData: data
                                    options: NSJSONReadingMutableContainers
                                    error: &e];
      NSLog(@"responseDict %@ : ", responseDict);
      
      if(200 == statusCode) {
        
        NSError *error = nil;
        [[SecKeyManager sharedInstance] addAuthToken:[responseDict valueForKey:@"authToken"] error:&error];
        if (error) {
          [self executeFailureBlock:failure bayunTracer:tracer error:error];
        } else {
          [NSUserDefaultsUtility setBayunOauthTokenExpirationTime:[responseDict valueForKey:@"authTokenExpiry"]];
          
          if (success) {
            success();
          }
        }
        
      } else {
        if (failure) {
          [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
        }
      }
    }];
    [dataTask resume];
  } else {
    apiManagerfailureBlock(tracer, BayunErrorSomethingWentWrong, failure);
  }
}


#pragma mark - Validate Credentials APIs

- (void)changePassword:(NSDictionary *)parameters
           bayunTracer:(BayunTracer*)tracer
               success:(void (^)(void))success
               failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo = [tracer createSpan:@"changePassword" tag:@"BayunAPIManagerv" value:@"changePassword"];
  
  NSError *error;
  NSDictionary *postParameters;
  
  //Derive currentPasswordAuthHash
  NSString *currentPassword = [parameters valueForKey:@"currentPassword"];
  NSString *currentPwdAuthHash = [[CryptManager sharedInstance] pbkdf2:currentPassword salt:[NSUserDefaultsUtility employeeAuthSalt]];
  
  //Derive newPasswordAuthHash
  NSString *newPassword = [parameters valueForKey:@"newPassword"];
  NSString *newPwdAuthHash = [[CryptManager sharedInstance] pbkdf2:newPassword salt:[NSUserDefaultsUtility employeeAuthSalt]];
  
  NSString *employeeAppPrivateKey = [[SecKeyManager sharedInstance] getPrivateKeyForTag:
                                     [SecKeyManager sharedInstance].employeeAppPrivateTag error:&error];
  
  if (employeeAppPrivateKey) {
    
    NSString *employeeKeySalt = [NSUserDefaultsUtility employeeKeySalt];
    NSString *baseKey = [[CryptManager sharedInstance] pbkdf2:newPassword salt:employeeKeySalt];
    NSString *companyEmployeeId = [NSUserDefaultsUtility companyEmployeeId];
    
    NSString * encryptedEmpAppPrivateKey = [[AuthenticatedEncryptionManager sharedInstance] encrypt:employeeAppPrivateKey
                                                                                            baseKey:baseKey
                                                                                             baseId:companyEmployeeId
                                                                                        bayunTracer:tracer];
    
    if (encryptedEmpAppPrivateKey) {
      
      postParameters = @{@"encryptedEmployeeAppPrivateKey": encryptedEmpAppPrivateKey,
                         @"newAuthPasswordHash" : newPwdAuthHash,
                         @"oldAuthPasswordHash": currentPwdAuthHash};
      
      NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
      NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
      
      NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kChangePassword]];
      
      NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:postParameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
      if (error) {
        [self executeFailureBlock:failure bayunTracer:tracer error:error];
        return;
      }
      NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = httpResponse.statusCode;
        if(200 == statusCode) {
          NSLog(@"ChangePassword Success");
          NSError *error = nil;
          [[SecKeyManager sharedInstance] addAuthPasswordHash:newPwdAuthHash error:&error];
          
          if (error) {
            [self executeFailureBlock:failure bayunTracer:tracer error:error];
          } else {
            [tracer finishSpan];
            if (success) {
              success();
            }
          }
          
        } else {
          [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
        }
      }];
      [dataTask resume];
    } else {
      [self executeFailureBlock:failure bayunTracer:tracer error:error];
    }
  } else {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
  }
}

- (void)validatePassphrase:(NSString*)passphrase
                parameters:(NSDictionary *)parameters
               bayunTracer:(BayunTracer*)tracer
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"validatePassphrase" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  NSError *error = nil;
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kValidatePassphrase]];
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      
      NSError *e = nil;
      NSDictionary *responseDict = [NSJSONSerialization
                                    JSONObjectWithData: data
                                    options: NSJSONReadingMutableContainers
                                    error: &e];
      
      NSLog(@"ValidatePassphrase responseDict %@ : ", responseDict);
      NSError *error = nil;
      
      if (![[responseDict valueForKey:@"authToken"] isEqual:[NSNull null]]) {
        [[SecKeyManager sharedInstance] addAuthToken:[responseDict valueForKey:@"authToken"] error:&error];
      }
      
      if (![[responseDict valueForKey:@"authTokenExpiry"] isEqual:[NSNull null]]) {
        [NSUserDefaultsUtility setBayunOauthTokenExpirationTime:[responseDict valueForKey:@"authTokenExpiry"]];
      }
      
      BOOL isSignatureVerified = true;
      self.passphrase = passphrase;
      NSString *userId = [responseDict valueForKey:@"userId"];
      NSString *userPublicKey = [responseDict valueForKey:@"userPublicKey"];
      
      if (![userPublicKey isEqual:[NSNull null]]) {
        isSignatureVerified =  [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userPublicKey groupId:nil bayunTracer:tracer];
        if (!isSignatureVerified) {
          apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
          return;
        }
        [BayunUtilities retrieveAndSavePublicKey:userPublicKey publicKeyTag:SecKeyManager.sharedInstance.userPublicTag];
      };
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userId
                                                                                  groupId:@""
                                                                              bayunTracer:tracer];
      if (!isSignatureVerified) {
        apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
        return;
      }
      
      [NSUserDefaultsUtility setUserId:[BayunUtilities separateMessageFromSignatures:userId]];
      [NSUserDefaultsUtility setUserKeySalt:[responseDict valueForKey:@"userKeySalt"]];
      [NSUserDefaultsUtility setEncryptedUserPrivateKey:[responseDict valueForKey:@"userPrivateKey"]];
      
      //Decrypt user private key
      [[CryptManager sharedInstance] decryptUserPrivateKey:^{
        
        if (![[responseDict valueForKey:@"authToken"] isEqual:[NSNull null]]) {
          //get employee client data
          [self getClientEmployeeData:tracer success:^{
            [tracer finishSpan];
            if (success) {
              success();
            }
          }  failure:failure];
        } else {
          if (success) {
            success();
          }
        }
      } passphrase:self.passphrase bayunTracer:tracer failure:failure];
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/**
 Validates Security Questions.
 @param parameters An Array of NSDictionary mapping authAnswerHash, questionId.
 @param success Success block to be executed after security questions are validated successfully.
 @param failure Failure block to be executed if validate security questions fails, returns BayunAdminError.
 */
- (void)validateSecurityQuestions:(NSDictionary*)parameters
                      bayunTracer:(BayunTracer*)tracer
                          success:(void (^)(void))success
                          failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"validateSecurityQuestions" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kValidateSecurityQuestions]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:YES isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger statusCode = httpResponse.statusCode;
    
    NSError *e = nil;
    NSDictionary *responseDict = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
    NSLog(@"ValidateSecurityQuestions responseDict %@ : ", responseDict);
    if(200 == statusCode) {
      
      NSError *error = nil;
      
      if (![[responseDict valueForKey:@"authToken"] isEqual:[NSNull null]]) {
        [[SecKeyManager sharedInstance] addAuthToken:[responseDict valueForKey:@"authToken"] error:&error];
      }
      
      if (![[responseDict valueForKey:@"authTokenExpiry"] isEqual:[NSNull null]]) {
        [NSUserDefaultsUtility setBayunOauthTokenExpirationTime:[responseDict valueForKey:@"authTokenExpiry"]];
      }
      
      BOOL isSignatureVerified = true;
      NSString *userPublicKey = [responseDict valueForKey:@"userPublicKey"];
      if (![userPublicKey isEqual:[NSNull null]]) {
        isSignatureVerified =  [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userPublicKey groupId:nil bayunTracer:tracer];
        if (!isSignatureVerified) {
          apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
          return;
        }
        [BayunUtilities retrieveAndSavePublicKey:userPublicKey publicKeyTag:SecKeyManager.sharedInstance.userPublicTag];
      };
      
      
      NSString *userId = [responseDict valueForKey:@"userId"];
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userId
                                                                                  groupId:@""
                                                                              bayunTracer:tracer];
      if (!isSignatureVerified) {
        apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
        return;
      }
      
      [NSUserDefaultsUtility setUserId:[BayunUtilities separateMessageFromSignatures:userId]];
      [NSUserDefaultsUtility setEncryptedUserPrivateKeyParts:[responseDict valueForKey:@"userPrivateKeyParts"]];
      [NSUserDefaultsUtility setAnswerKeySalts:[responseDict valueForKey:@"answerKeySalts"]];
      
      NSArray *validQuestionIds = [responseDict valueForKey:@"validQuestionIds"];
      // user is logged with company credentials or registered with credential, select the respective company
      NSPredicate *filter = [NSPredicate predicateWithFormat:@"questionId IN %@",
                             validQuestionIds];
      NSArray *answersValidated = [NSUserDefaultsUtility answersValidated];
      NSArray *validAnswers = [answersValidated filteredArrayUsingPredicate:filter];
      
      //combine user private key parts and save userPrivateKey
      [[CryptManager sharedInstance] combineAndSaveUserPrivateKeyParts:validAnswers bayunTracer:tracer success:^{
        
        if (![[responseDict valueForKey:@"authToken"] isEqual:[NSNull null]]) {
          //get employee client data
          [self getClientEmployeeData:tracer success:^{
            [tracer finishSpan];
            if (success) {
              success();
            }
          }  failure:failure];
        } else {
          if (success) {
            success();
          }
        }
        
      } failure:failure];
      
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

#pragma mark - Lockbox APIs

- (void)getEmployeePublicKey:(NSDictionary*)parameters
                 bayunTracer:(BayunTracer*)tracer
                     success:(void (^)(NSArray<AddMemberErrObject*>*))success
                     failure:(void (^)(BayunError))failure {
  
  [self getEmployeePublicKeys:parameters bayunTracer:tracer success:success failure:failure];
  // [self getEmployeePublicKeys:requestParams bayunTracer:tracer success:success failure:failure];
  
  //  NSString *tracerInfo = [tracer createSpan:@"getEmployeePublicKey" tag:@"BayunAPIManager" value:@"request"];
  //
  //  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  //  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
  //                                                               delegate: nil
  //                                                          delegateQueue: [NSOperationQueue mainQueue]];
  //
  //  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kGetEmployeePublicKey]];
  //  NSError *error = nil;
  //  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters  httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  //  if (error) {
  //    [self executeFailureBlock:failure bayunTracer:tracer error:error];
  //    return;
  //  }
  //
  //  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
  //    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
  //
  //    NSInteger statusCode = httpResponse.statusCode;
  //    if(200 == statusCode) {
  //
  //      NSError *e = nil;
  //      NSDictionary *responseDict = [NSJSONSerialization
  //                                    JSONObjectWithData: data
  //                                    options: NSJSONReadingMutableContainers
  //                                    error: &e];
  //
  //      [tracer finishSpan];
  //      if (success) {
  //        success(responseDict);
  //      }
  //    } else {
  //      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
  //    }
  //  }];
  //  [dataTask resume];
  
}

- (void)getEmployeePublicKeys:(NSDictionary*)parameters
                  bayunTracer:(BayunTracer*)tracer
                      success:(void (^)(NSArray<AddMemberErrObject*>*))success
                      failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getEmployeePublicKey" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject
                                                               delegate: nil
                                                          delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kGetEmployeePublicKeys]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters  httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      
      NSError *e = nil;
      NSArray *responseDict = [NSJSONSerialization
                               JSONObjectWithData: data
                               options: NSJSONReadingMutableContainers
                               error: &e];
      
      NSLog(@"GetEmployeePublicKeys responseDict %@ : ", responseDict);
      
      NSString* trustedEmpPubKeySignatureErrMsg = @"TrustedEmployeePublicKeySignature could not be verified by EmployeePublicKey";
      NSString* empPubKeySignatureErrMsg = @"Employee Public Key could not be verified";
      NSString* empPubKeyAuthSignatureErrMsg = @"Employee Public Key could not be verified by AuthorizationAppPublicKey";
      NSString* empPubKeyServerSignatureErrMsg = @"Employee Public Key could not be verified by BayunServerPublicKey";
//      NSString* empApprovalKeyNullErrMsg = @"Employee Approval Verification Key is Null";
//      NSString* adminPubKeyNotVerifiedErrMsg = @"Admin Public Key could not be verified";
//      NSString* ghostEmpPubKeyNotVerifiedErrMsg = @"Ghost Employee Public Key could not be verified";
      
      NSMutableArray<GroupMember*>* trustedEmpPubKeySignatureMembers = [[NSMutableArray alloc] init];
      NSMutableArray<GroupMember*>* empPubKeySignatureMembers = [[NSMutableArray alloc] init];
      NSMutableArray<GroupMember*>* empPubKeyAuthSignatureMembers = [[NSMutableArray alloc] init];
      NSMutableArray<GroupMember*>* empPubKeyServerSignatureMembers = [[NSMutableArray alloc] init];
//      NSMutableArray<GroupMember*>* empApprovalKeyNullMembers = [[NSMutableArray alloc] init];
//      NSMutableArray<GroupMember*>* adminPubKeyNotVerifiedMembers = [[NSMutableArray alloc] init];
//      NSMutableArray<GroupMember*>* ghostEmpPubKeyNotVerifiedMembers = [[NSMutableArray alloc] init];

      NSMutableArray<AddMemberErrObject*>* errObjects = [[NSMutableArray alloc] init];
      NSArray *employeePublicKeyResponse = [responseDict valueForKey:@"employeePublicKeyResponse"];
      NSArray *errorList = [responseDict valueForKey:@"errorList"];
      
      for (NSDictionary *errObj in errorList) {
        NSString *errorMessage = [errObj valueForKey:@"errorMessage"];
        NSArray *membersList = [errObj valueForKey:@"membersList"];
        
        NSMutableArray *groupMembers = [[NSMutableArray alloc] init];
        for (NSDictionary *groupMember in membersList) {
          GroupMember *member = [[GroupMember alloc] initWithCompanyName:[groupMember valueForKey:@"companyName"] companyEmployeeId:@"companyEmployeeId"];
          [groupMembers addObject:member];
        }
        
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:errorMessage membersList:groupMembers];
        [errObjects addObject:errObj];
      }
      
      for (NSDictionary *employeePublicKeyInfo in employeePublicKeyResponse) {
        BOOL isPubKeyVerified = true;
        BOOL isSignatureVerified = true;
        NSString *appPublicKeyWithSignatures = [employeePublicKeyInfo valueForKey:@"appPublicKey"];
        NSString *companyName = [employeePublicKeyInfo valueForKey:@"companyName"];
        NSString *companyEmployeeId = [employeePublicKeyInfo valueForKey:@"companyEmployeeId"];
        NSString *employeePublicKeyWithSignatures = [employeePublicKeyInfo valueForKey:@"publicKey"];
        NSString *empApprovalVerificationKeyWithSignatures = [employeePublicKeyInfo valueForKey:@"employeeApprovalVerificationKey"];
        NSString *trustedEmployeePublicKeySignature = [employeePublicKeyInfo valueForKey:@"trustedEmployeePublicKeySignature"];
        NSString *publicKeyWithSignatures = [employeePublicKeyInfo valueForKey:@"publicKey"];
        NSString *publicKey = [BayunUtilities separateMessageFromSignatures:publicKeyWithSignatures];
        
        if (![trustedEmployeePublicKeySignature isEqual:[NSNull null]]) {
          //Verify PublicKey using Employee's self PublicKey as trustedEmployeePublicKeySignature exists
          NSArray *signatureAndMetadata = [trustedEmployeePublicKeySignature componentsSeparatedByString:@"$"];
          isSignatureVerified = [[CryptManager sharedInstance] verify:publicKey
                                                            signature:signatureAndMetadata[0] publicKeyTag:SecKeyManager.sharedInstance.employeePublicTag context:[SignatureContexts employeePublicKeyContext] bayunTracer:tracer];
          
          if (!isSignatureVerified) {
            isPubKeyVerified = false;
            GroupMember *member = [[GroupMember alloc] initWithCompanyName:companyName companyEmployeeId:companyEmployeeId];
            [trustedEmpPubKeySignatureMembers addObject:member];
          } else {
            [NSUserDefaultsUtility setTrustedSignatureExists:true companyEmployeeId:companyEmployeeId];
          }
        } else {
          if (![[NSUserDefaultsUtility companyName] isEqualToString:companyName]) {
            
            isSignatureVerified = [self verifyEmployeePublicKeySignature:employeePublicKeyWithSignatures empApprovalVerificationKeyWithSignatures:empApprovalVerificationKeyWithSignatures bayunTracer:tracer];
            if (!isSignatureVerified) {
              isPubKeyVerified = false;
              GroupMember *member = [[GroupMember alloc] initWithCompanyName:companyName companyEmployeeId:companyEmployeeId];
              [empPubKeySignatureMembers addObject:member];
            }
          } else {
        
            NSData *appPublicKeyTag = [NSUserDefaultsUtility extEmployeeAppPublicKeyTag:companyName companyEmployeeId:companyEmployeeId];
            
            [[SecKeyManager sharedInstance] addPublicKey:[BayunUtilities separateMessageFromSignatures:appPublicKeyWithSignatures]
                                                  forTag:appPublicKeyTag error:&error];
            
            //Verify PublicKey using AuthorizationAppPublicKey
            isSignatureVerified = [[CryptManager sharedInstance] verify:employeePublicKeyWithSignatures publicKeyTagString:kAuthorizationAppPubKeyTag verificationPublicKeyTag:appPublicKeyTag groupId:nil
                                                            bayunTracer:tracer];
            if (!isSignatureVerified) {
              isPubKeyVerified = false;
              GroupMember *member = [[GroupMember alloc] initWithCompanyName:companyName companyEmployeeId:companyEmployeeId];
              [empPubKeyAuthSignatureMembers addObject:member];
            }
            
            //Verify EmployeePublicKey Signature using BayunServerPublicKey
            isSignatureVerified = [[CryptManager sharedInstance] verify:employeePublicKeyWithSignatures publicKeyTagString:kBayunServerPublicKeyTag verificationPublicKeyTag:nil groupId:nil bayunTracer:tracer];
            if (!isSignatureVerified) {
              isPubKeyVerified = false;
              GroupMember *member = [[GroupMember alloc] initWithCompanyName:companyName companyEmployeeId:companyEmployeeId];
              [empPubKeyServerSignatureMembers addObject:member];
            }
          }
        }
        
        if (isPubKeyVerified) {
          NSData *publicKeyTag = [NSUserDefaultsUtility employeePublicKeyTag:companyName
                                                           companyEmployeeId:companyEmployeeId];
          [[SecKeyManager sharedInstance] addPublicKey:publicKey forTag:publicKeyTag error:&error];
        }
      }
      
      if (trustedEmpPubKeySignatureMembers.count > 0) {
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:trustedEmpPubKeySignatureErrMsg membersList:trustedEmpPubKeySignatureMembers];
        [errObjects addObject:errObj];
      }
      
      if (empPubKeySignatureMembers.count > 0) {
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:empPubKeySignatureErrMsg membersList:empPubKeySignatureMembers];
        [errObjects addObject:errObj];
      }
      
      if (empPubKeyAuthSignatureMembers.count > 0) {
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:empPubKeyAuthSignatureErrMsg membersList:empPubKeyAuthSignatureMembers];
        [errObjects addObject:errObj];
      }
      
      if (empPubKeyServerSignatureMembers.count > 0) {
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:empPubKeyServerSignatureErrMsg membersList:empPubKeyServerSignatureMembers];
        [errObjects addObject:errObj];
      }
      
      [tracer finishSpan];
      if (success) {
        success(errObjects);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
  
}



- (void)getEmployeeLockBox:(BayunTracer*)tracer
                   success:(void (^)(void))success
                   failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo = [tracer createSpan:@"getEmployeeLockBox" tag:@"BayunAPIManager" value:@"request"];
  
  // check oauth token expiration time
  NSDate* currentDate = [NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]];
  NSNumber *oauthTokenExpirationTime = [NSUserDefaultsUtility bayunOauthTokenExpirationTime];
  NSDate* oauthTokenExpirationDate = [NSDate dateWithTimeIntervalSince1970:[oauthTokenExpirationTime doubleValue] / 1000];
  
  if (![[[SecKeyManager sharedInstance] authToken:nil] isEqualToString:@"NULL"] &&
      [currentDate compare:oauthTokenExpirationDate] == NSOrderedAscending) {
    //oauth token is valid
    
    if (!self.isGetEmployeeLockboxCallRunning) {
      self.isGetEmployeeLockboxCallRunning = YES;
      NSURLSession *defaultSession = [NSURLSession sharedSession];
      
      NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?employeeAppId=%@",kBaseUrl,kGetEmployeeLockBox,[NSUserDefaultsUtility bayunEmployeeAppId]]];
      
      NSError *error = nil;
      NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
      if (error) {
        [self executeFailureBlock:failure bayunTracer:tracer error:error];
        return;
      }
      
      dispatch_semaphore_t sema = dispatch_semaphore_create(0);
      NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_semaphore_signal(sema);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = httpResponse.statusCode;
        
        if(200 == statusCode) {
          NSError *e = nil;
          NSDictionary *employeeLockBox = [NSJSONSerialization
                                           JSONObjectWithData: data
                                           options: NSJSONReadingMutableContainers
                                           error: &e];
          
          NSLog(@"EmployeeLockBox responseDict %@ : ", employeeLockBox);
          NSString *employeeStatus = [employeeLockBox valueForKey:@"employeeStatus"];
          [NSUserDefaultsUtility setEmployeeStatus:employeeStatus];
          
          if (![employeeStatus isEqualToString:@"Registered"] && ![employeeStatus isEqualToString:@"Cancelled"]) {
            
            // save employee lockbox
            NSError *error;
            BOOL isLockboxSaved =  [self saveEmployeeLockBoxLocally:employeeLockBox error:&error bayunTracer:tracer];
            if (isLockboxSaved) {
              
              // trigger employee lockbox refresh timer
              [self startEmployeeLockBoxRefreshTimer];
              
              [tracer finishSpan];
              if (success) {
                success();
              }
            } else {
              [self executeFailureBlock:failure bayunTracer:tracer error:error];
            }
            
            if (self.getEmpLockboxSuccessBlockSpool.count > 0) {
              for (void (^ success)(void) in self.getEmpLockboxSuccessBlockSpool) {
                success();
              }
              [self.getEmpLockboxSuccessBlockSpool removeAllObjects];
            }
          } else {
            [BayunUtilities clearDataEncryptionKeys];
            [BayunUtilities clearEmployeeKeys];
            
            apiManagerfailureBlock(tracer, BayunErrorUserInActive, failure);
          }
        } else {
          
          if (400 == statusCode) {
            apiManagerfailureBlock(tracer, BayunErrorAccessDenied, failure);
          } else {
            
            [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
          }
        }
        self.isGetEmployeeLockboxCallRunning = NO;
      }];
      [dataTask resume];
      dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }  else {
      [self.getEmpLockboxSuccessBlockSpool addObject:success];
    }
  } else {
    // oauth token is expired, get oauth token
    [self getBayunOauthToken:tracer success:^{
      [self getEmployeeLockBox:tracer success:^{
        [tracer finishSpan];
        if (success) {
          success();
        }
      } failure:failure];
    } failure:failure];
  }
}

#pragma mark - Group APIs

/*
 *Create Group API
 */
- (void)createGroup:(NSDictionary*)parameters
        bayunTracer:(BayunTracer*)tracer
            success:(void (^)(NSString*))success
            failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"createGroup" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kCreateGroup]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
        NSLog(@"CreateGroup responseDict %@ : ", response);
        NSString *groupId = [response valueForKey:@"groupId"];
        
        if (groupId && success) {
          success(groupId);
        }
      }
    } else {
      
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Join Public Group API
 */
- (void)joinPublicGroup:(NSDictionary*)parameters
            bayunTracer:(BayunTracer*)tracer
                success:(void (^)(void))success
                failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"joinPublicGroup" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kJoinPublicGroup]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"JoinPublicGroup responseDict");
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Get Groups List API
 */
- (void)getMyGroups:(BayunTracer*)tracer success:(void (^)(NSArray*))success
            failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getMyGroups" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kGetMyGroups]];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSArray *response = [NSJSONSerialization
                             JSONObjectWithData: data
                             options: NSJSONReadingMutableContainers
                             error: &e];
        NSLog(@"GetMyGroups responseDict %@ : ", response);
        if (success) {
          success(response);
        }
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}


/*
 *Get Unjoined Public Groups List API
 */
- (void)getUnjoinedPublicGroups:(BayunTracer*)tracer success:(void (^)(NSArray*))success
                        failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getUnjoinedPublicGroups" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kGetUnjoinedPublicGroups]];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession
                                    dataTaskWithRequest:urlRequest
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSArray *response = [NSJSONSerialization
                             JSONObjectWithData: data
                             options: NSJSONReadingMutableContainers
                             error: &e];
        NSLog(@"GetUnjoinedPublicGroups responseDict %@ : ", response);
        if (success) {
          success(response);
        }
      }
    } else {
      
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Get Group by GroupId API
 */
- (void) getGroupById:(NSString*)groupId
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(NSDictionary*))success
              failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo = [tracer createSpan:@"getGroupById" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kGetGroupById]];
  NSURLQueryItem *groupIdItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
  components.queryItems = @[groupIdItem];
  
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
        NSLog(@"GetGroupById responseDict %@ : ", response);
        if (success) {
          success(response);
        }
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
  
}

/*
 *Get GroupKey by GroupId API
 */
- (void)getJoinedGroupKey:(NSString*)groupId
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(NSDictionary*))success
                  failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getJoinedGroupKey" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kGetGroupKeyByGroupId]];
  NSURLQueryItem *groupIdItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
  components.queryItems = @[groupIdItem];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil  httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
        NSLog(@"GetJoinedGroupKey responseDict %@ : ", response);
        if (success) {
          success(response);
        }
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Get GroupKey of a public group by GroupId API
 */
- (void)getPublicGroupKey:(NSString*)groupId
              bayunTracer:(BayunTracer*)tracer
                  success:(void (^)(NSDictionary*))success
                  failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"getPublicGroupKey" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kGetPublicGroupKey]];
  NSURLQueryItem *groupIdItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
  components.queryItems = @[groupIdItem];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"GET" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    self.isGetBayunOauthTokenCallRunning = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      [tracer finishSpan];
      if (data) {
        NSError *e = nil;
        NSDictionary *response = [NSJSONSerialization
                                  JSONObjectWithData: data
                                  options: NSJSONReadingMutableContainers
                                  error: &e];
        NSLog(@"GetPublicGroupKey responseDict %@ : ", response);
        if (success) {
          success(response);
        }
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}


/*
 *Add Member to Group API
 */
- (void)addMember:(NSDictionary*)parameters
      bayunTracer:(BayunTracer*)tracer
          success:(void (^)(void))success
          failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"addMember" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAddMember]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"Add Member success");
      
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}


/*
 *API to add multiple members to a Group
 */
- (void)addMembers:(NSDictionary*)parameters
       bayunTracer:(BayunTracer*)tracer
           success:(void (^)(NSArray<AddMemberErrObject*>*, NSString*))success
           failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"addMembers" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kAddMembers]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];

  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"Add members success");
      
      NSError *e = nil;
      NSDictionary *response = [NSJSONSerialization
                                JSONObjectWithData: data
                                options: NSJSONReadingMutableContainers
                                error: &e];
      
      NSMutableArray<AddMemberErrObject*>* errObjects = [[NSMutableArray alloc] init];
      
      NSString *addedMembersCount = [response valueForKey:@"addedMembersCount"];
      NSArray *membersNotAdded = [response valueForKey:@"membersNotAdded"];
      
      for (NSDictionary *errObj in membersNotAdded) {
        NSString *errorMessage = [errObj valueForKey:@"errorMessage"];
        NSArray *membersList = [errObj valueForKey:@"membersList"];
        
        NSMutableArray *groupMembers = [[NSMutableArray alloc] init];
        for (NSDictionary *groupMember in membersList) {
          GroupMember *member = [[GroupMember alloc] initWithCompanyName:[groupMember valueForKey:@"companyName"] companyEmployeeId:[groupMember valueForKey:@"companyEmployeeId"]];
          [groupMembers addObject:member];
        }
        
        AddMemberErrObject *errObj = [[AddMemberErrObject alloc] initWithErrorMessage:errorMessage membersList:groupMembers];
        [errObjects addObject:errObj];
      }
      
      [tracer finishSpan];
      if (success) {
        NSArray *errorObjects = [[NSArray alloc] initWithArray:errObjects];
        success(errorObjects, addedMembersCount);
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Remove Member from Group API
 */
- (void)removeMember:(NSDictionary*)parameters
         bayunTracer:(BayunTracer*)tracer
             success:(void (^)(void))success
             failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"removeMember" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kRemoveMember]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"Remove member success");
      
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}


/*
 *Remove Member from Group API
 */
- (void)removeMembers:(NSDictionary*)parameters
          bayunTracer:(BayunTracer*)tracer
              success:(void (^)(void))success
              failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo = [tracer createSpan:@"removeMembers" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kRemoveMembers]];
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:parameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"Remove members success");
      
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Delete Group API
 */
- (void)deleteGroup:(NSString*)groupId
        bayunTracer:(BayunTracer*)tracer
            success:(void (^)(void))success
            failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo =  [tracer createSpan:@"deleteGroup" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kDeleteGroup]];
  NSURLQueryItem *groupIdItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
  components.queryItems = @[groupIdItem];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"Delete Group success");
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

/*
 *Leave Group API
 */
- (void)leaveGroup:(NSString*)groupId
       bayunTracer:(BayunTracer*)tracer
           success:(void (^)(void))success
           failure:(void (^)(BayunError))failure {
  
  
  NSString *tracerInfo =[tracer createSpan:@"leaveGroup" tag:@"BayunAPIManager" value:@"request"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURLComponents *components = [NSURLComponents componentsWithString:
                                 [NSString stringWithFormat:@"%@%@",kBaseUrl,kLeaveGroup]];
  NSURLQueryItem *groupIdItem = [NSURLQueryItem queryItemWithName:@"groupId" value:groupId];
  components.queryItems = @[groupIdItem];
  NSURL * url = components.URL;
  NSError *error = nil;
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:nil httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    if(200 == statusCode) {
      NSLog(@"leaveGroup success");
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

#pragma mark - Statistics APIs


- (void)saveEmployeeStatistics:(BayunTracer*)tracer
                       success:(void (^)(void))success
                       failure:(void (^)(BayunError))failure {
  
  NSString *tracerInfo  = @"";
  
  if (tracer) {
    tracerInfo = [tracer createSpan:@"saveStats" tag:@"BayunAPIManager" value:@"request"];
    [tracer setSpanTag:@"companyName" value:[NSUserDefaultsUtility companyName]];
    [tracer setSpanTag:@"companyEmployeeId" value:[NSUserDefaultsUtility companyEmployeeId]];
  }
  
  NSNumber *encryptionCount;
  NSNumber *decryptionCount;
  NSNumber *lastOperationTime;
  
  NSString *statisticsKey = [[SecKeyManager sharedInstance] statisticsKey:nil];
  if (statisticsKey) {
    if (![NSUserDefaultsUtility numberOfEncryptions]) {
      encryptionCount = @0;
    } else {
      encryptionCount = [NSUserDefaultsUtility numberOfEncryptions];
    }
    
    if (![NSUserDefaultsUtility numberOfDecryptions]) {
      decryptionCount = @0;
    } else {
      decryptionCount = [NSUserDefaultsUtility numberOfDecryptions];
    }
    
    if (![NSUserDefaultsUtility lastOperationTime]) {
      lastOperationTime = @0;
    } else {
      lastOperationTime = [NSUserDefaultsUtility lastOperationTime];
    }
    
    NSString *appId = [NSUserDefaultsUtility applicationId];
    NSString *baseId = [NSString stringWithFormat:@"%@%@%@",[NSUserDefaultsUtility companyName], [NSUserDefaultsUtility companyEmployeeId], appId];
    
    //Encrypt stats using statisticsKey
    NSString *encEncryptionCount = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[NSString stringWithFormat:@"%@",encryptionCount] baseKey:statisticsKey baseId:baseId bayunTracer:tracer];
    NSString *encDecryptionCount = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[NSString stringWithFormat:@"%@",decryptionCount] baseKey:statisticsKey baseId:baseId bayunTracer:tracer];
    NSString *encLastOperationTime = [[AuthenticatedEncryptionManager sharedInstance] encrypt:[NSString stringWithFormat:@"%@",lastOperationTime] baseKey:statisticsKey baseId:baseId bayunTracer:tracer];
    NSString *lmsStatisticsKey = [[SecKeyManager sharedInstance] generateLMSStatisticsKeyFor:appId tracer:tracer];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    if (encEncryptionCount && encDecryptionCount && encLastOperationTime && lmsStatisticsKey) {
      NSDictionary *postParameters = @{@"encryptionCount": encEncryptionCount,
                                       @"decryptionCount": encDecryptionCount,
                                       @"lastOperationTime": encLastOperationTime,
                                       @"lmsStatisticsKey": lmsStatisticsKey
      };
      
      NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kEmployeeStatistics]];
      NSError *error = nil;
      NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:postParameters httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
      if (error) {
        [self executeFailureBlock:failure bayunTracer:tracer error:error];
        return;
      }
      
      NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSInteger statusCode = httpResponse.statusCode;
        
        if(200 == statusCode) {
          NSLog(@"saveEmployeeStatistics success");
          
          [NSUserDefaultsUtility setNumberOfEncryptions:[NSNumber numberWithInteger:0]];
          [NSUserDefaultsUtility setNumberOfDecryptions:[NSNumber numberWithInteger:0]];
          [self updateLastStatsSyncTime];
          [tracer finishSpan];
          if (success) {
            success();
          }
        } else {
          [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
        }
      }];
      [dataTask resume];
    }
  }
}

-(void)saveEmployeeAppStatisticsKey:(BayunTracer*)tracer
                            success:(void(^)(void))success
                            failure:(void(^)(BayunError))failure {
  NSString *tracerInfo  = @"";
  
  if (tracer) {
    tracerInfo = [tracer createSpan:@"saveEmployeeAppStatisticsKeys" tag:@"BayunAPIManager" value:@"request"];
    [tracer setSpanTag:@"companyName" value:[NSUserDefaultsUtility companyName]];
    [tracer setSpanTag:@"companyEmployeeId" value:[NSUserDefaultsUtility companyEmployeeId]];
  }
  
  NSError *error = nil;
  NSString *encryptionCount = @"0";
  NSString *decryptionCount = @"0";
  NSString *companyName = [NSUserDefaultsUtility companyName];
  NSString *companyEmployeeId = [NSUserDefaultsUtility companyEmployeeId];
  NSString *appId = [NSUserDefaultsUtility applicationId];
  NSString *employeeAppId = [NSUserDefaultsUtility bayunEmployeeAppId];
  NSString *statisticsKeyBaseId = [NSString stringWithFormat:@"%@%@%@",companyName,companyEmployeeId,appId];
  NSString *statisticsKey = [[SecKeyManager sharedInstance] statisticsKey:&error];
  NSMutableDictionary *postParams = [[NSMutableDictionary alloc] init];
  
  //Encrypt statisticsKey using admin public key
  NSDictionary *adminEncStatisticsKey = [[CryptManager sharedInstance] encrypt:statisticsKey publicKeyTag:SecKeyManager.sharedInstance.adminPublicTag baseId:statisticsKeyBaseId bayunTracer:tracer error:&error];
  [postParams setValue:[adminEncStatisticsKey valueForKey:kEncryptedPlainString] forKey:@"adminEncryptedStatisticsKey"];
  [postParams setValue:[adminEncStatisticsKey valueForKey:kEncryptedKEK] forKey:@"adminEncryptedStatisticsKey_kek"];
  
  //Encrypt statisticsKey using lmsStatisticsKey
  NSString *lmsStatisticsKey = [[SecKeyManager sharedInstance] generateLMSStatisticsKeyFor:appId tracer:tracer];
  NSString *baseId = [NSString stringWithFormat:@"lms%@%@%@",companyName,companyEmployeeId,appId];
  NSString *lmsEncryptedStatisticsKey = [[AuthenticatedEncryptionManager sharedInstance] encrypt:statisticsKey baseKey:lmsStatisticsKey baseId:baseId bayunTracer:tracer];
  
  [postParams setValue:lmsEncryptedStatisticsKey forKey:@"lmsEncryptedStatisticsKey"];
  [postParams setValue:employeeAppId forKey:@"employeeAppId"];
  
  //Encrypt encryption and decryption count
  NSString *encEncryptionCount = [[AuthenticatedEncryptionManager sharedInstance] encrypt:encryptionCount baseKey:statisticsKey baseId:statisticsKeyBaseId bayunTracer:tracer];
  NSString *encDecryptionCount = [[AuthenticatedEncryptionManager sharedInstance] encrypt:decryptionCount baseKey:statisticsKey baseId:statisticsKeyBaseId bayunTracer:tracer];
  
  [postParams setValue:encEncryptionCount forKey:@"encryptionCount"];
  [postParams setValue:encDecryptionCount forKey:@"decryptionCount"];
  
  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  
  NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kBaseUrl,kSaveEmployeeAppStatisticsKeys]];
  NSMutableURLRequest * urlRequest = [self requestWithURL:url parameters:postParams httpMethod:@"POST" is2faAPI:NO isOpenAPI:NO tracer:tracerInfo error:&error];
  
  if (error) {
    [self executeFailureBlock:failure bayunTracer:tracer error:error];
    return;
  }
  
  NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    NSInteger statusCode = httpResponse.statusCode;
    
    if(200 == statusCode) {
      NSLog(@"saveEmployeeAppStatisticsKey success");
      
      [NSUserDefaultsUtility setNumberOfEncryptions:[NSNumber numberWithInteger:0]];
      [NSUserDefaultsUtility setNumberOfDecryptions:[NSNumber numberWithInteger:0]];
      [self updateLastStatsSyncTime];
      [tracer finishSpan];
      if (success) {
        success();
      }
    } else {
      [self executeFailureBlock:failure data:data error:error statusCode:statusCode bayunTracer:tracer];
    }
  }];
  [dataTask resume];
}

#pragma mark - Internal Methods


/**
 Verifies the signature on employeePublicKey generated by adminPrivateKey(explicit approval) or ghostEmployeePrivateKey(auto approval)
 */
-(BOOL)verifyEmployeePublicKeySignature:(NSString*)publicKeyWithSignatures
empApprovalVerificationKeyWithSignatures:(NSString*)empApprovalVerificationKeyWithSignatures
                            bayunTracer:(BayunTracer*)tracer{
  
  
  NSString *signature;
  NSString *context;
  NSString *publicKey = [BayunUtilities separateMessageFromSignatures:publicKeyWithSignatures];
  NSString *employeeApprovalVerificationKey = [BayunUtilities separateMessageFromSignatures:empApprovalVerificationKeyWithSignatures];
  
  NSData *employeeApprovalVerificationKeyTag = [[NSString stringWithFormat:@"employeeApprovalVerificationKeyTag"] dataUsingEncoding:NSUTF8StringEncoding];
  
  NSError *error = nil;
  [[SecKeyManager sharedInstance] addPublicKey:employeeApprovalVerificationKey
                                        forTag:employeeApprovalVerificationKeyTag error:&error];
  
  //employeePublicKeyWithSignatures's format is employeePublicKey#Signature$metadata#signature$metadata
  NSArray *messageAndSignatures = [publicKeyWithSignatures componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:kSignaturesSeparator]];
  
  for (int index = 1; index < messageAndSignatures.count; index ++) {
    //signatureWithMetadata's format is signature+$+metadata
    NSString *signatureWithMetadata = [messageAndSignatures objectAtIndex:index];
    
    NSArray *signatureAndMetadata = [signatureWithMetadata componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:kSignatureMetadataSeparator]];
    NSString *signatureMetadataString = [signatureAndMetadata objectAtIndex:1];
    SignatureMetadata *signatureMetadata = [[ThriftFormatter sharedInstance] deserialize:[BayunUtilities decodeBase64String:signatureMetadataString] toClass:SignatureMetadata.class];
    
    if ([signatureMetadata.signatureVerificationKey isEqualToString:kAdminPublicKeyTag] ||
        [signatureMetadata.signatureVerificationKey isEqualToString:kGhostEmployeePublicKeyTag]) {
      
      if ([signatureMetadata.signatureVerificationKey isEqualToString:kAdminPublicKeyTag]) {
        //Verify employee's admin public key
        BOOL isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:empApprovalVerificationKeyWithSignatures groupId:nil bayunTracer:tracer];
        if (!isSignatureVerified) {
          return false;
        }
      } else {
        //Verify and save ghostEmployeePublicKey
        BOOL isSignatureVerified = [[CryptManager sharedInstance] verify:empApprovalVerificationKeyWithSignatures publicKeyTagString:kBayunServerPublicKeyTag verificationPublicKeyTag:nil groupId:nil bayunTracer:tracer];
        
        NSString *empApprovalVerificationKey = [BayunUtilities separateMessageFromSignatures:empApprovalVerificationKeyWithSignatures];
        
        if (!isSignatureVerified) {
          return false;
        }
        //Save ghostEmployeePublicKey
        [[SecKeyManager sharedInstance] addPublicKey:empApprovalVerificationKey forTag:employeeApprovalVerificationKeyTag error:&error];
      }
      signature = [signatureAndMetadata objectAtIndex:0];
      context = signatureMetadata.context;
      break;
    }
  }
  
  if (!signature || !context) {
    return false;
  }
  
  return  [[CryptManager sharedInstance] verify:publicKey signature:signature
                                   publicKeyTag:employeeApprovalVerificationKeyTag context:context bayunTracer:tracer];
}

- (void)addPublicKey:(NSString*)publicKey
                 tag:(NSData*)tag
         bayunTracer:(BayunTracer*)tracer
             failure:(void(^)(BayunError))failure  {
  
  NSError *errorSavingKeys = nil;
  [[SecKeyManager sharedInstance] addPublicKey:publicKey
                                        forTag:tag
   
                                         error:&errorSavingKeys];
  if (errorSavingKeys) {
    apiManagerfailureBlock(tracer,BayunErrorSomethingWentWrong, failure);
    return;
  }
}

-(void)saveAuthDetails:(NSDictionary*)authDetail
           bayunTracer:(BayunTracer*)tracer
               success:(void(^)(void))success
               failure:(void(^)(BayunError))failure{
  
  
  //authenticateEmployee API returns authToken, authTokenExpiry when 2FA is disabled OR twoFAToken when 2FA is enabled.
  //twoFAToken needs to be passed in the header for validation in /validatePassphrase and /validateSecurityQuestions API
  if (![[authDetail valueForKey:@"authToken"] isEqual:[NSNull null]]) {
    
    NSError *error = nil;
    [[SecKeyManager sharedInstance] addAuthToken:[authDetail valueForKey:@"authToken"] error:&error];
    
    if (error) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
    } else {
      [NSUserDefaultsUtility setIs2FAEnabled:NO];
      if (![[authDetail valueForKey:@"authTokenExpiry"] isEqual:[NSNull null]]) {
        [NSUserDefaultsUtility setBayunOauthTokenExpirationTime:[authDetail valueForKey:@"authTokenExpiry"]];
      } else {
        apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
        return;
      }
    }
    
  } else if (![[authDetail valueForKey:@"twoFAToken"] isEqual:[NSNull null]]) {
    [NSUserDefaultsUtility setIs2FAEnabled:YES];
    
    NSError *error = nil;
    [[SecKeyManager sharedInstance] addTwoFAToken:[authDetail valueForKey:@"twoFAToken"] error: &error];
    if (error) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
  } else if([[authDetail valueForKey:@"authToken"] isEqual:[NSNull null]] && ([[SecKeyManager sharedInstance] getPrivateKeyForTag:
                                                                               SecKeyManager.sharedInstance.authorizationAppPrivateKeyTag error:nil] != nil)) {
    //AuthToken is received as null when authAppPrivateKey is not available on client side and authAppPrivateKey cannot be verified on LMS
    apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
    return;
  }
  
  if (success) {
    success();
  }
}

- (void)saveTwoFAData:(NSDictionary*)responseDict
           passphrase:(void(^)(void))passphrase
    securityQuestions:(void(^)(NSArray<SecurityQuestion*>*))securityQuestionsBlock
          bayunTracer:(BayunTracer*)tracer
              failure:(void(^)(BayunError))failure {
  
  
  NSString *email = [responseDict valueForKey:@"email"];
  [NSUserDefaultsUtility setEmail:email];
  
  //security questions exists only if 2-FA is Enabled
  NSArray *securityQuestionsArray = [responseDict valueForKey:@"securityQuestions"];
  NSMutableArray<SecurityQuestion*> *securityQuestions = [[NSMutableArray alloc] init];
  
  if (![securityQuestionsArray isEqual:[NSNull null]]) {
  
    for(NSDictionary *question in securityQuestionsArray) {
      NSString *questionId = [question valueForKey:@"questionId"];
      NSString *questionText = [question valueForKey:@"questionText"];
      SecurityQuestion *securityQuestion = [[SecurityQuestion alloc] initWithId:questionId text:questionText];
      [securityQuestions addObject:securityQuestion];
    }
    
   // [NSUserDefaultsUtility setSecurityQuestions:securityQuestionsArray];
  }
  
  if (![[responseDict valueForKey:@"answerAuthSalt"] isEqual:[NSNull null]]) {
    NSArray *answerSalts = [responseDict valueForKey:@"answerAuthSalt"];
    if (answerSalts) {
      [NSUserDefaultsUtility setAnswerAuthSalts:answerSalts];
    }
  }
  
  if (![[responseDict valueForKey:@"isPassphraseActive"] isEqual:[NSNull null]] &&
      [[responseDict valueForKey:@"isPassphraseActive"] isEqualToString:@"true"]) {
    
    if (![[responseDict valueForKey:@"userAuthSalt"] isEqual:[NSNull null]]) {
      [NSUserDefaultsUtility setUserAuthSalt:[responseDict valueForKey:@"userAuthSalt"]];
      [NSUserDefaultsUtility setIsPassphraseActive:YES];
      [tracer finishSpan];
      passphrase();
    } else {
      apiManagerfailureBlock(tracer,BayunErrorAuthenticationFailed, failure);
      return;
    }
  } else {
    [tracer finishSpan];
    //When 2FA is enabled, passphrase is inactive, security questions are validated
    securityQuestionsBlock([NSArray arrayWithArray:securityQuestions]);
  }
}

- (void)saveEmployeeClientData:(NSDictionary*)responseDict
                   bayunTracer:(BayunTracer*)tracer
                       success:(void(^)(void))success
                       failure:(void(^)(BayunError))failure {
  
  [tracer createSpan:@"saveEmployeeClientData" tag:@"BayunAPIManager" value:@"save data"];
  
  NSError *error = nil;
  NSString *companyKey = [[SecKeyManager sharedInstance] companyKey:&error];
  if (!companyKey) {
    apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
    return;
  }
  NSString *companyName = [NSUserDefaultsUtility companyName];
  
  if ((![[responseDict valueForKey:@"defaultEncryptionMode"] isEqual:[NSNull null]])) {
    NSData *data  = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"defaultEncryptionMode"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    NSString *defaultEncryptionMode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!defaultEncryptionMode) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    [NSUserDefaultsUtility setEncryptionMode:defaultEncryptionMode];
  }
  
  if ((![[responseDict valueForKey:@"defaultEncryptionPolicy"] isEqual:[NSNull null]])) {
    NSData *data = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"defaultEncryptionPolicy"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    
    NSString *defaultEncryptionPolicy = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!defaultEncryptionPolicy) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    [NSUserDefaultsUtility setEncryptionPolicy:defaultEncryptionPolicy];
  }
  
  if ((![[responseDict valueForKey:@"defaultKeyGenerationPolicy"] isEqual:[NSNull null]])) {
    NSData *data = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"defaultKeyGenerationPolicy"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    NSString *defaultKeyGenerationPolicy = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!defaultKeyGenerationPolicy) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    [NSUserDefaultsUtility setKeyGenerationPolicy:defaultKeyGenerationPolicy];
  }
  
  if (![[responseDict valueForKey:@"encryptionStatus"] isEqual:[NSNull null]] ) {
    NSData *data = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"encryptionStatus"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    NSString *encryptionStatus = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!encryptionStatus) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    [NSUserDefaultsUtility setIsEncryptionEnabled:encryptionStatus];
  }
  
  if (![[responseDict valueForKey:@"statsSyncTime"] isEqual:[NSNull null]]) {
    NSData *data = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"statsSyncTime"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    NSString *statsSyncTime = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!statsSyncTime) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    [NSUserDefaultsUtility setStatsSyncTime:[NSNumber numberWithInteger:[statsSyncTime integerValue]]];
  }
  
  if (![[responseDict valueForKey:@"lockboxExpiry"] isEqual:[NSNull null]]) {
    NSData *data = [[AuthenticatedEncryptionManager sharedInstance] decrypt:[responseDict valueForKey:@"lockboxExpiry"] baseKey:companyKey baseId:companyName bayunTracer:tracer error:&error];
    NSString *lockboxExpiry = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!lockboxExpiry) {
      apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
      return;
    }
    NSInteger lockboxExpiryInMins = [lockboxExpiry integerValue];
    NSTimeInterval lockboxExpiryTime = [[[NSDate date] dateByAddingTimeInterval: (lockboxExpiryInMins * 60)] timeIntervalSince1970] * 1000;
    [NSUserDefaultsUtility setLockboxExpirationTime:[NSNumber numberWithInteger:lockboxExpiryTime]];
    [NSUserDefaultsUtility setLockboxExpirationPeriod:[NSNumber numberWithInt:[lockboxExpiry intValue]]];
  }
  
#warning need to fix
  if (![[responseDict valueForKey:@"lmsEncryptedStatisticsKey"] isEqual:[NSNull null]] ) {
    
    NSString *appId = [NSUserDefaultsUtility applicationId];
    [self decryptStatisticsKey:[responseDict valueForKey:@"lmsEncryptedStatisticsKey"]
                         appId:appId tracer:tracer failure:failure];
    
  } else {
    
    NSArray *statisticsKeys = [responseDict valueForKey:@"statisticsKeys"];
    
    if (statisticsKeys.count > 0) {
      NSDictionary *statisticsKeyInfo = [statisticsKeys objectAtIndex:0];
      NSString *appId = [statisticsKeyInfo valueForKey:@"appId"];
      NSString *lmsEncryptedStatisticsKey = [statisticsKeyInfo valueForKey:@"lmsEncryptedStatisticsKey"];
      [self decryptStatisticsKey:lmsEncryptedStatisticsKey
                           appId:appId tracer:tracer failure:failure];
      
      [self saveEmployeeAppStatisticsKey:tracer success:success failure:failure];
    }
  }
  
  if (success) {
    success();
  }
}

-(void)decryptStatisticsKey:(NSString*)lmsEncryptedStatisticsKey
                      appId:(NSString*)appId
                     tracer:(BayunTracer*)tracer
                    failure:(void(^)(BayunError))failure{
  NSError *error = nil;
  NSString *companyName = [NSUserDefaultsUtility companyName];
  NSString *companyEmpId = [NSUserDefaultsUtility companyEmployeeId];
  NSString *lmsStatisticsKey = [[SecKeyManager sharedInstance] generateLMSStatisticsKeyFor:appId tracer:tracer];
  NSString *baseId = [NSString stringWithFormat:@"lms%@%@%@",companyName,companyEmpId,appId];
  NSData *statisticsKeyData = [[AuthenticatedEncryptionManager sharedInstance] decrypt:lmsEncryptedStatisticsKey baseKey:lmsStatisticsKey baseId:baseId bayunTracer:tracer error:&error];
  NSString *statisticsKey = [[NSString alloc] initWithData:statisticsKeyData encoding:NSUTF8StringEncoding];
  if (!statisticsKey) {
    apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
    return;
  } else {
    [[SecKeyManager sharedInstance] addStatisticsKey:statisticsKey error:nil];
  }
}

/**
 Updates the last time at which stats synced on server
 */
- (void)updateLastStatsSyncTime {
  NSTimeInterval lastSyncTime = [[NSDate date] timeIntervalSince1970];
  double milliseconds= [[NSString stringWithFormat:@"%f",lastSyncTime] doubleValue]*1000;
  long long lastSyncTimeValue = (long long) milliseconds;
  [NSUserDefaultsUtility setLastStatsSyncTime:[NSNumber numberWithLongLong:lastSyncTimeValue]];
}

/**
 Starts the employee lockbox timer
 */
- (void)startEmployeeLockBoxRefreshTimer {
  NSNumber *lockboxExpirationPeriod = [NSUserDefaultsUtility lockboxExpirationPeriod]; //in mins
  if (lockboxExpirationPeriod) {
    NSTimeInterval lockboxExpPeriodExcludingBuffer = ([lockboxExpirationPeriod intValue] * 60) - 1;  // i.e 1secs
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
      if (self.employeeLockBoxRefreshTimer) {
        [self.employeeLockBoxRefreshTimer invalidate];
        self.employeeLockBoxRefreshTimer = nil;
      }
      self.employeeLockBoxRefreshTimer = [NSTimer timerWithTimeInterval:lockboxExpPeriodExcludingBuffer
                                                                 target:weakSelf
                                                               selector:@selector(getEmployeeLockBox:)
                                                               userInfo:nil
                                                                repeats:YES];
      [[NSRunLoop mainRunLoop] addTimer:self.employeeLockBoxRefreshTimer
                                forMode:NSDefaultRunLoopMode];
    });
  }
}


- (void)getEmployeeLockBox:(NSTimer*)timer{
  BayunTracer *tracer = [[BayunTracer alloc] init];
  [tracer createSpan:@"getEmployeeLockBox" tag:@"BayunAPIManager" value:@"periodic refresh"];
  
  [self getEmployeeLockBox:tracer success:^{
    [tracer closeTracer];
  } failure:^(BayunError error) {
    [tracer closeTracer];
  }];
  
  NSArray *joinedGroupIds =  [NSUserDefaultsUtility joinedGroupIds];
  
  if (joinedGroupIds.count > 0) {
    for(NSString *groupId in joinedGroupIds) {
      
#warning add span
      [[BayunGroupManager sharedInstance] getJoinedGroupKeyFor:groupId bayunTracer:nil success:nil failure:^(BayunError error) {
        if  (error == BayunErrorInvalidGroupId ||
             error == BayunErrorEmployeeDoesNotBelongToGroup) {
          [NSUserDefaultsUtility removeGroupIdFromJoinedGroupIds:groupId];
        }
      }];
    }
  }
}

/*
 Invalidates the employee lockbox refresh timer
 */
- (void)invalidateEmployeeLockboxRefreshTimer {
  [[BayunAPIManager sharedInstance].employeeLockBoxRefreshTimer invalidate];
  [BayunAPIManager sharedInstance].employeeLockBoxRefreshTimer =nil;
}

/**
 Decrypts and saves the keys present in employee lockbox to key chain
 */
-(BOOL)saveEmployeeLockBoxLocally:(NSDictionary*)employeeLockBox error:(NSError**)error bayunTracer:tracer{
  
  BOOL isSignatureVerified = true;
  NSString *employeePublicKey = [employeeLockBox valueForKey:@"employeePublicKey"];
  NSString *encryptedCompanyPrivateKey = [employeeLockBox valueForKey:@"companyPrivateKey"];
  NSString *companyKey_kek = [employeeLockBox valueForKey:@"companyKey_kek"];
  NSString *companyPrivateKey_kek = [employeeLockBox valueForKey:@"companyPrivateKey_kek"];
  NSString *encryptedCompanyKey = [employeeLockBox valueForKey:@"companyKey"];
  NSString *encryptedEmployeeKey = [employeeLockBox valueForKey:@"employeeKey"];
  NSString *employeeKey_kek = [employeeLockBox valueForKey:@"employeeKey_kek"];
  NSString *employeeSigningPrivateKey_kek = [employeeLockBox valueForKey:@"employeeSigningPrivateKey_kek"];
  NSString *encEmpSigningPrivateKey = [employeeLockBox valueForKey:@"employeeSigningPrivateKey"];
  NSString *employeeSigningPublicKey = [employeeLockBox valueForKey:@"employeeSigningPublicKey"];
  NSString *employeePrivateKeyOuterKEK = [employeeLockBox valueForKey:@"employeePrivateKeyOuter_kek"];
  //NSString *userEncryptedEmpPrivateKey = [employeeLockBox valueForKey:@"employeePrivateKey"];
  NSString *employeePrivateKeyInnerKEK = [employeeLockBox valueForKey:@"employeePrivateKeyInner_kek"];
  NSString *companyPublicKey = [employeeLockBox valueForKey:@"companyPublicKey"];
  NSString *userPublicKey = [employeeLockBox valueForKey:@"userPublicKey"];
  NSString *employeePrivateKey = [employeeLockBox valueForKey:@"employeePrivateKey"];
  
  BayunEncryptionType encryptionType = [NSUserDefaultsUtility encryptionType];
  
  if (employeePublicKey != nil && ![employeePublicKey isEqual:[NSNull null]]) {
    
    isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeePublicKey
                                                                                groupId:nil bayunTracer:tracer];
    if (!isSignatureVerified) {
      return false;
    }
    //Add employee public key to keychain
    [[SecKeyManager sharedInstance] addPublicKey:[BayunUtilities separateMessageFromSignatures:employeePublicKey]
                                          forTag:[SecKeyManager sharedInstance].employeePublicTag
                                           error:error];
    [NSUserDefaultsUtility setEmpPubKeyWithSignatures:employeePublicKey];
    if (*error)
      return false;
  }
  
  if (userPublicKey != nil && ![userPublicKey isEqual:[NSNull null]]) {
    
    isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:userPublicKey
                                                                                groupId:nil bayunTracer:tracer];
    if (!isSignatureVerified) {
      return false;
    }
    //Add employee public key to keychain
    [[SecKeyManager sharedInstance] addPublicKey:[BayunUtilities separateMessageFromSignatures:userPublicKey]
                                          forTag:[SecKeyManager sharedInstance].userPublicTag
                                           error:error];
    [NSUserDefaultsUtility setEmpPubKeyWithSignatures:employeePublicKey];
    if (*error)
      return false;
  }
  
  if (encryptionType == BayunEncryptionTypeECC) {
    if (![employeeKey_kek isEqual:[NSNull null]]) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeKey_kek
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
    if (![companyKey_kek isEqual:[NSNull null]]  &&
        encryptionType == BayunEncryptionTypeECC) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:companyKey_kek
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
    if (![companyPrivateKey_kek isEqual:[NSNull null]]) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:companyPrivateKey_kek
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
    if (![employeeSigningPrivateKey_kek isEqual:[NSNull null]]) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeSigningPrivateKey_kek
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
    if (![employeePrivateKeyOuterKEK isEqual:[NSNull null]]) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeePrivateKeyOuterKEK
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
    if (![employeePrivateKeyInnerKEK isEqual:[NSNull null]]) {
      isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeePrivateKeyInnerKEK
                                                                                  groupId:nil bayunTracer:tracer];
      if (!isSignatureVerified) {
        return false;
      }
    }
    
  }
  
  if (![employeeSigningPublicKey isEqual:[NSNull null]]) {
    isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:employeeSigningPublicKey
                                                                                groupId:nil bayunTracer:tracer];
    if (!isSignatureVerified) {
      return false;
    }
  }
  
  if (![companyPublicKey isEqual:[NSNull null]]) {
    isSignatureVerified = [[CryptManager sharedInstance] retrieveAndverifyLastSignature:companyPublicKey
                                                                                groupId:nil bayunTracer:tracer];
    if (!isSignatureVerified) {
      return false;
    }
    
    [[SecKeyManager sharedInstance] addPublicKey:[BayunUtilities separateMessageFromSignatures:companyPublicKey] forTag:SecKeyManager.sharedInstance.companyPublicKeyTag error:error];
    if (*error)
      return false;
  }
  
  if (employeePrivateKey) {
    
    NSString *decryptedEmpPrivKey;
    //Employee private key is kept encrypted with employeeApp public key(inner key) and user public key(outer key)
    //Therefore, employee private key is first decrypted with user private key and then employeeApp private key
    
    if (![employeePrivateKeyOuterKEK isEqual:[NSNull null]]) {
      if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
        employeePrivateKeyOuterKEK = [BayunUtilities separateMessageFromSignatures:employeePrivateKeyOuterKEK];
      }
      decryptedEmpPrivKey = [[CryptManager sharedInstance] decrypt:employeePrivateKey
                                                     privateKeyTag:[SecKeyManager sharedInstance].userPrivateTag               kek:employeePrivateKeyOuterKEK
                                                            baseId:[NSUserDefaultsUtility userId]
                                                       bayunTracer:tracer
                                                             error:error];
      employeePrivateKey = decryptedEmpPrivKey;
    }
    
    
    if (![employeePrivateKeyInnerKEK isEqual:[NSNull null]]) {
      if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
        employeePrivateKeyInnerKEK = [BayunUtilities separateMessageFromSignatures:employeePrivateKeyInnerKEK];
      }
      decryptedEmpPrivKey = [[CryptManager sharedInstance] decrypt:employeePrivateKey
                                                     privateKeyTag:[SecKeyManager sharedInstance].employeeAppPrivateTag
                                                               kek:employeePrivateKeyInnerKEK
                                                            baseId:[NSUserDefaultsUtility companyEmployeeId]
                                                       bayunTracer:tracer
                                                             error:error];
    }
    
    if (decryptedEmpPrivKey) {
      [[SecKeyManager sharedInstance] addPrivateKey:decryptedEmpPrivKey
                                             forTag:[SecKeyManager sharedInstance].employeePrivateTag
                                              error:error];
    } else { return false; }
  }
  
  if (![encryptedCompanyPrivateKey isEqual:[NSNull null]]) {
    
    if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
      companyPrivateKey_kek = [BayunUtilities separateMessageFromSignatures:companyPrivateKey_kek];
    }
    NSString *companyPrivateKey = [[CryptManager sharedInstance] decrypt:encryptedCompanyPrivateKey
                                                           privateKeyTag:[SecKeyManager sharedInstance].employeePrivateTag
                                                                     kek:companyPrivateKey_kek
                                                                  baseId:[NSUserDefaultsUtility companyEmployeeId]
                                                             bayunTracer:tracer
                                                                   error:error];
    if (companyPrivateKey) {
      //Add company key to keychain
      [[SecKeyManager sharedInstance] addPrivateKey:companyPrivateKey forTag:SecKeyManager.sharedInstance.companyPrivateKeyTag error:error];
      if (*error)
        return false;
    } else {
      return false;
    }
  }
  
  if (![encryptedCompanyKey isEqual:[NSNull null]]) {
    if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
      companyKey_kek = [BayunUtilities separateMessageFromSignatures:companyKey_kek];
    }
    NSString *companyKey = [[CryptManager sharedInstance] decrypt:encryptedCompanyKey
                                                    privateKeyTag:[SecKeyManager sharedInstance].employeePrivateTag
                                                              kek:companyKey_kek
                                                           baseId:[NSUserDefaultsUtility companyEmployeeId]
                                                      bayunTracer:tracer
                                                            error:error];
    if (companyKey) {
      //Add company key to keychain
      [[SecKeyManager sharedInstance] addCompanyKey:companyKey error:error];
      if (*error)
        return false;
    } else {
      return false;
    }
  }
  
  if (![encryptedEmployeeKey isEqual:[NSNull null]]) {
    if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
      employeeKey_kek = [BayunUtilities separateMessageFromSignatures:employeeKey_kek];
    }
    NSString *employeeKey = [[CryptManager sharedInstance] decrypt:encryptedEmployeeKey
                                                     privateKeyTag:[SecKeyManager sharedInstance].employeePrivateTag
                                                               kek:employeeKey_kek
                                                            baseId:[NSUserDefaultsUtility companyEmployeeId]
                                                       bayunTracer:tracer
                                                             error:error];
    if (employeeKey) {
      //Add company key to keychain
      [[SecKeyManager sharedInstance] addEmployeeKey:employeeKey error:error];
      if (*error)
        return false;
    } else {
      return false;
    }
  }
  
  
  if (![encEmpSigningPrivateKey isEqual:[NSNull null]]) {
    if ([NSUserDefaultsUtility encryptionType] == BayunEncryptionTypeECC) {
      employeeSigningPrivateKey_kek = [BayunUtilities separateMessageFromSignatures:employeeSigningPrivateKey_kek];
    }
    NSString *employeeSigningPrivateKey = [[CryptManager sharedInstance] decrypt:encEmpSigningPrivateKey
                                                                   privateKeyTag:[SecKeyManager sharedInstance].employeePrivateTag
                                                                             kek:employeeSigningPrivateKey_kek
                                                                          baseId:[NSUserDefaultsUtility companyEmployeeId]
                                                                     bayunTracer:tracer
                                                                           error:error];
    if (employeeSigningPrivateKey && employeeSigningPublicKey) {
      //Add employeeSigningPrivateKey to keychain
      [[SecKeyManager sharedInstance] addPrivateKey:employeeSigningPrivateKey
                                             forTag:[SecKeyManager sharedInstance].employeeSignaturePrivateTag error:error];
      if (*error)
        return false;
      
      //Add employeeSigningPublicKey to keychain
      [[SecKeyManager sharedInstance] addPublicKey:[BayunUtilities separateMessageFromSignatures:employeeSigningPublicKey]
                                            forTag:[SecKeyManager sharedInstance].employeeSignaturePublicTag
                                             error:error];
      if (*error)
        return false;
    } else {
      return false;
    }
  }
  
  if (![[employeeLockBox valueForKey:@"expiry"] isEqual:[NSNull null]]) {
    //save company key expiration time
    [NSUserDefaultsUtility setLockboxExpirationTime:[employeeLockBox valueForKey:@"expiry"]];
  }
  
  if (![[employeeLockBox valueForKey:@"isTracingEnabled"] isEqual:[NSNull null]]) {
    //save isTracingEnabled flag
    [NSUserDefaultsUtility setIsTracingEnabled:[employeeLockBox valueForKey:@"isTracingEnabled"]];
  }
  
  if (![[employeeLockBox valueForKey:@"tracingLogLevel"] isEqual:[NSNull null]]) {
    //save company key expiration time
    [NSUserDefaultsUtility setTracingLogLevel:[employeeLockBox valueForKey:@"tracingLogLevel"]];
  }
  
  NSInteger lockboxExpiryInMins = [[NSUserDefaultsUtility lockboxExpirationPeriod] integerValue];
  NSTimeInterval lockboxExpiryTime = [[[NSDate date] dateByAddingTimeInterval: (lockboxExpiryInMins * 60)] timeIntervalSince1970] * 1000;
  [NSUserDefaultsUtility setLockboxExpirationTime:[NSNumber numberWithInteger:lockboxExpiryTime]];
  return true;
}

- (void)executeFailureBlock:(void (^)(BayunError))failure bayunTracer:(BayunTracer*)tracer error:(NSError*) error {
  if (error && error.code == errSecUserCanceled) {
    [tracer setSpanTag:@"error" value:@"BayunErrorPasscodeAuthenticationCanceledByUser"];
    apiManagerfailureBlock(tracer, BayunErrorPasscodeAuthenticationCanceledByUser, failure);
  } else {
    [tracer setSpanTag:@"error" value:@"BayunErrorSomethingWentWrong"];
    apiManagerfailureBlock(tracer, BayunErrorAuthenticationFailed, failure);
  }
}

- (void)executeFailureBlock:(void (^)(BayunError))failure
                       data:(NSData*)data
                      error:(NSError*)error
                 statusCode:(NSInteger)statusCode
                bayunTracer:(BayunTracer*)tracer{
  
  if (failure) {
    if (data) {
      
      NSError *error;
      NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData: data
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
      
      if ([[responseObject valueForKey:kErrorType] isEqualToString:kLMSErrorAccessDenied] ||
          [[responseObject valueForKey:kErrorType] isEqualToString:kLMSErrorInvalidOperation]) {
        
        NSString *errorMessage = [responseObject valueForKey:kErrorMessage];
        
        [tracer setSpanTag:@"error" value:errorMessage];
        [tracer finishSpan];
        
        if ([errorMessage isEqualToString:kLMSErrorInvalidToken]) {
          failure(BayunErrorReAuthenticationNeeded);
        } if ([errorMessage isEqualToString:kLMSErrorExpiredToken]) {
          failure(BayunErrorReAuthenticationNeeded);
        }  else if ([errorMessage isEqualToString:kLMSErrorInvalidCredentials]) {
          failure(BayunErrorInvalidCredentials);
        } else if ([errorMessage isEqualToString:kLMSErrorInvalidAppSecret]) {
          failure(BayunErrorInvalidAppSecret);
        } else if([errorMessage isEqualToString:kLMSErrorIncorrectPassword]) {
          failure(BayunErrorInvalidPassword);
        } else if([errorMessage isEqualToString:kLMSErrorIncorrectPassphrase]) {
          failure(BayunErrorInvalidPassphrase);
        } else if([errorMessage isEqualToString:kLMSErrorEmployeeDeactivated]) {
          failure(BayunErrorUserInActive);
        } else if([errorMessage isEqualToString:kLMSErrorAppNotLinked]) {
          failure(BayunErrorAppNotLinked);
        } else if([errorMessage isEqualToString:kLMSErrorAppIdNotExists]) {
          failure(BayunErrorInvalidAppId);
        } else if([errorMessage isEqualToString:kLMSErrorCompanyNotExists]) {
          failure( BayunErrorCompanyDoesNotExists);
        } else if ([errorMessage isEqualToString:kLMSErrorInvalidAnswers]) {
          failure(BayunErrorOneOrMoreIncorrectAnswers);
        } else if([errorMessage isEqualToString:kLMSErrorTriedToCreateDuplicateEntry]) {
          failure(BayunErrorInvalidOperation);
        } else if ([errorMessage isEqualToString:kLMSErrorGroupIdNotExists]) {
          failure(BayunErrorInvalidGroupId);
        } else if ([errorMessage isEqualToString:kLMSErrorEmployeeIdNotExists]) {
          failure(BayunErrorEmployeeDoesNotExists);
        }  else if ([errorMessage isEqualToString:kLMSErrorEmpAndCompanyNotExists]) {
          failure(BayunErrorEmployeeDoesNotExists);
        } else if ([errorMessage isEqualToString:kLMSErrorEmployeeNotLinkedToGroup]) {
          failure(BayunErrorEmployeeDoesNotBelongToGroup);
        } else if ([errorMessage isEqualToString:kLMSErrorEmployeeNotMemberOfGroup]) {
          failure(BayunErrorEmployeeDoesNotBelongToGroup);
        } else if([errorMessage isEqualToString:kLMSErrorEmpIdAlreadyExistsInGroup]) {
          failure(BayunErrorMemberAlreadyExistsInGroup);
        } else if([errorMessage isEqualToString:kLMSErrorEmpIdNotExistsInGroup]) {
          failure(BayunErrorMemberDoesNotExistsInGroup);
        } else if([errorMessage isEqualToString:kLMSErrorGroupIsNotPublic]) {
          failure(BayunErrorCannotJoinPrivateGroup);
        } else if([errorMessage isEqualToString:kLMSErrorCompanyAlreadyExists]) {
          failure(BayunErrorCompanyAlreadyExists);
        } else if([errorMessage isEqualToString:kLMSErrorEmployeeAlreadyExists]) {
          failure(BayunErrorEmployeeAlreadyExists);
        } else if ([errorMessage isEqualToString:kLMSErrorEmpDoesnotExistInGroupToRemove]) {
          failure(BayunErrorMemberDoesNotExistsInGroup);
        } else if ([errorMessage isEqualToString:kLMSErrorEmployeeDoesNotExists]) {
          failure(BayunErrorEmployeeDoesNotExists);
        } else if ([errorMessage isEqualToString:kLMSErrorEmployeeAuthorizationPending]) {
          failure(BayunErrorEmployeeAuthorizationIsPending);
        }  else {
          failure(BayunErrorSomethingWentWrong);
        }
      } else {
        
        [tracer setSpanTag:@"error" value:@"BayunErrorSomethingWentWrong"];
        [tracer finishSpan];
        failure(BayunErrorSomethingWentWrong);
      }
    } else {
      
      if (-1009 == error.code) {
        [tracer setSpanTag:@"error" value:@"BayunErrorInternetConnection"];
        failure(BayunErrorInternetConnection);
      } else if (-1001 == error.code) {
        
        [tracer setSpanTag:@"error" value:@"BayunErrorRequestTimeOut"];
        failure(BayunErrorRequestTimeOut);
      } else if (400 == statusCode) {
        
        [tracer setSpanTag:@"error" value:@"BayunErrorAccessDenied"];
        failure(BayunErrorAccessDenied);
      } else if (404 == statusCode || -1004 == error.code) {
        
        [tracer setSpanTag:@"error" value:@"BayunErrorCouldNotConnectToServer"];
        failure(BayunErrorCouldNotConnectToServer);
      } else {
        
        [tracer setSpanTag:@"error" value:@"BayunErrorSomethingWentWrong"];
        failure(BayunErrorSomethingWentWrong);
      }
      [tracer finishSpan];
    }
  }
}
@end
