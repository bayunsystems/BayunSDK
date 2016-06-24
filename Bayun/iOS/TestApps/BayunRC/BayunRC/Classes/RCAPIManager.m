//
//  RCAPIManager.m
//  Bayun
//
//  Created by Preeti Gaur on 02/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "RCAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import "RCConfig.h"
#import "Message.h"
#import "Sender.h"
#import "Receiver.h"
#import "User.h"
#import "Conversation.h"

@interface RCAPIManager()

@property (nonatomic,assign) BOOL isGetTokenCallRunning;

@end

@implementation RCAPIManager

/**
 Singleton Service Client.
 */
+ (instancetype)sharedInstance {
    static RCAPIManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

/**
 Logs in RingCentral.
 @param credentials NSDictionary mapping user name, extension, password.
 @param success Success block to be executed after successful login.
 @param failure Failure block to be executed if login fails, returns RCError.
 */
- (void) loginWithCredentials:(NSDictionary*)credentials success:(void (^)(void))success failure:(void (^)(RCError))failure {
    if (!self.isGetTokenCallRunning) {
        self.isGetTokenCallRunning = YES;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *base64String = [RCUtilities base64String:[NSString stringWithFormat:@"%@:%@",kApplicationKey,kApplicationSecretKey] ];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",base64String]  forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded"
                         forHTTPHeaderField:@"Content-Type"];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",[RCUtilities baseURL],kRCLoginURL];
        
        [manager POST:url parameters:credentials success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [SVProgressHUD dismiss];
            self.isGetTokenCallRunning = NO;
            
            NSDictionary *responseDict = responseObject;
            
            NSDate *accessTokenExpDate = [[NSDate date] dateByAddingTimeInterval:
                                          [[responseDict valueForKey:@"expires_in"] integerValue]];
            NSDate *refreshTokenExpDate = [[NSDate date] dateByAddingTimeInterval:
                                           [[responseDict valueForKey:@"refresh_token_expires_in"] integerValue]];
            
            [[NSUserDefaults standardUserDefaults] setValue:[responseDict valueForKey:@"access_token"] forKey:kRCAccessToken];
            [[NSUserDefaults standardUserDefaults] setValue:[responseDict valueForKey:@"refresh_token"] forKey:kRCRefreshToken];
            [[NSUserDefaults standardUserDefaults] setValue:accessTokenExpDate forKey:kRCAuthTokenExpIn];
            [[NSUserDefaults standardUserDefaults] setValue:refreshTokenExpDate forKey:kRCRefreshTokenExpIn];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (success) {
                success();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             self.isGetTokenCallRunning = NO;

            if (failure) {
                NSInteger statusCode = operation.response.statusCode;
                if(statusCode == 401) {
                    NSDictionary *errorDict= operation.responseObject;
                    if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenInvalid"]) {
                        failure(RCErrorInvalidToken);
                    }
                } else if(statusCode == 400) {
                    NSDictionary *errorDict= operation.responseObject;
                    if ([[errorDict valueForKey:@"error_description"] isEqualToString:@"Invalid resource owner credentials."]){
                        failure(RCErrorInvalidCredentials);
                    } else {
                        [manager.operationQueue cancelAllOperations];
                         failure(RCErrorSomethingWentWrong);
                    }
                } else {
                    [self failedWithError:error requestOperation:operation failure:failure];
                }
            }
         }];
    }
}

/**
 Gets list of messages of type Pager and saves in local database.
 @param success Success block to be executed after list of messages is fetched.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void) getMessageList:(void (^)(void))success failure:(void (^)(RCError))failure {
    NSDate *accessTokenExpDate = [[NSUserDefaults standardUserDefaults] valueForKey:kRCAuthTokenExpIn];
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:accessTokenExpDate] == NSOrderedAscending) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[RCUtilities rcAccessToken]]  forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSString *url;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:kRCLastMessageDateString]) {
            url = [NSString stringWithFormat:@"%@%@&dateFrom=%@",[RCUtilities baseURL],kRCGetMessageList,[[NSUserDefaults standardUserDefaults] valueForKey:kRCLastMessageDateString]];
        }
        else{
            url = [NSString stringWithFormat:@"%@%@&dateFrom=0",[RCUtilities baseURL],kRCGetMessageList];
        }
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *messages = [responseObject valueForKey:@"records"];
            for (NSDictionary *messageDict in messages) {
                [self createAndSaveMessage:messageDict];
            }
            [self saveManagedObjectContext];
            if (success) {
                success();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSInteger statusCode = operation.response.statusCode;
             if(statusCode == 401) {
                 NSDictionary *errorDict= operation.responseObject;
                 if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenExpired"]) {
                     void (^successBlock)(void) = ^{
                         [self getMessageList:success failure:failure];
                     };
                     
                     [self refreshAccessToken:successBlock failure:failure];
                 } else if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenInvalid"]) {
                     failure(RCErrorInvalidToken);
                     [manager.operationQueue cancelAllOperations];
                 }                 
             } else {
                 [self failedWithError:error requestOperation:operation failure:failure];
             }
         }];
    } else {
        void (^successBlock)(void) = ^{
            [self getMessageList:success failure:failure];
        };
        [self refreshAccessToken:successBlock failure:failure];
    }
}

/**
 Sends a pager-message.
 @param success Success block to be executed after message is sent.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void) sendMessage:(NSDictionary*)parameters success:(void (^)(void))success failure:(void (^)(RCError))failure {
    NSDate *accessTokenExpDate = [[NSUserDefaults standardUserDefaults] valueForKey:kRCAuthTokenExpIn];
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:accessTokenExpDate] == NSOrderedAscending) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[RCUtilities rcAccessToken]]  forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",[RCUtilities baseURL],kRCSendPagerMessage];
        
        [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self getMessageList:success failure:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [SVProgressHUD dismiss];
             NSInteger statusCode = operation.response.statusCode;
             if(statusCode == 401) {
                 NSDictionary *errorDict= operation.responseObject;
                 if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenExpired"]) {
                     void (^successBlock)(void) = ^{
                         [self sendMessage:parameters success:success failure:failure];
                     };
                     [self refreshAccessToken:successBlock failure:failure];
                 } else if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenInvalid"]) {
                     if (failure) {
                         failure(RCErrorInvalidToken);
                     }
                     [manager.operationQueue cancelAllOperations];
                 }
             } else {
                 [self failedWithError:error requestOperation:operation failure:failure];
             }
         }];
    } else {
        void (^successBlock)(void) = ^{
            [self sendMessage:parameters success:success failure:failure];
        };
        [self refreshAccessToken:successBlock failure:failure];
    }
}

/**
 Gets list of extensions.
 @param success Success block to be executed after list of extensions is fetched.
 @param failure Failure block to be executed if encryption fails, returns RCError.
 */
- (void) getExtensionList:(void (^)(void))success failure:(void (^)(RCError))failure {
    NSDate *accessTokenExpDate = [[NSUserDefaults standardUserDefaults] valueForKey:kRCAuthTokenExpIn];
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:accessTokenExpDate] == NSOrderedAscending) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[RCUtilities rcAccessToken]]  forHTTPHeaderField:@"Authorization"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSString *url = [NSString stringWithFormat:@"%@%@",[RCUtilities baseURL],kRCGetExtensionsList];
        
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *extensions= [responseObject valueForKey:@"records"];
            NSMutableArray *extensionsArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *extensionInfo in extensions) {
                User *user = [[User findWithPredicate:[NSPredicate predicateWithFormat:@"extension=%@",[extensionInfo valueForKey:@"extensionNumber"]]] lastObject];
                
                NSString *appUserExtension = [[NSUserDefaults standardUserDefaults] valueForKey: kRCExtension];
                
                if (user == nil) {
                    user = [User create];
                    user.userId = [[extensionInfo valueForKey:@"id"] stringValue];
                    user.name = [extensionInfo valueForKey:@"name"];
                    user.extension = [extensionInfo valueForKey:@"extensionNumber"];
                    
                    if ([appUserExtension isEqualToString:[extensionInfo valueForKey:@"extensionNumber"]]) {
                        user.isAppUser = [NSNumber numberWithBool:YES];
                    } else {
                        user.isAppUser = [NSNumber numberWithBool:NO];
                    }
                    [user save];
                    [extensionsArray addObject:user.extension];
                }
            }
            [self saveManagedObjectContext];
            if (success) {
                success();
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSInteger statusCode = operation.response.statusCode;
             if(statusCode == 401) {
                 NSDictionary *errorDict= operation.responseObject;
                 if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenExpired"]) {
                     void (^successBlock)(void) = ^{
                         [self getExtensionList:success failure:failure];
                     };
                     [self refreshAccessToken:successBlock failure:failure];
                 } else if ([[errorDict valueForKey:@"errorCode"] isEqualToString:@"TokenInvalid"]) {
                     [manager.operationQueue cancelAllOperations];
                     if (failure) {
                         failure(RCErrorInvalidToken);
                     }
                 }
             } else {
                 [self failedWithError:error requestOperation:operation failure:failure];
             }
         }];
    } else {
        void (^successBlock)(void) = ^{
            [self getExtensionList:success failure:failure];
        };
        [self refreshAccessToken:successBlock failure:failure];
    }
}

- (void) refreshAccessToken:(void (^)(void))success failure:(void (^)(NSUInteger))failure {
    NSMutableDictionary *credentials = [[NSMutableDictionary alloc] init];
    [credentials setObject:@"refresh_token" forKey:@"grant_type"];
    [credentials setObject:[RCUtilities rcRefreshToken] forKey:@"refresh_token"];
    [self loginWithCredentials:credentials success:success failure:failure];
}

#pragma mark - Helper Methods

- (void) failedWithError:(NSError*)error
        requestOperation:(AFHTTPRequestOperation*)operation
                 failure:(void (^)(NSUInteger))failure {
    if (failure) {
        if (-1009 == error.code) {
            failure(RCErrorInternetConnection);
        } else if (-1001 == error.code) {
            failure(RCErrorRequestTimeOut);
        } else {
            failure(RCErrorSomethingWentWrong);
        }
    }
}

/**
 *  Creates and saves new message in Core Data
 */
- (void) createAndSaveMessage:(NSDictionary*) messageDict {
    
    NSDate *lastMessageDate = [[NSUserDefaults standardUserDefaults] valueForKey:kRCLastMessageDate];
    NSDictionary *msgSenderInfo = [messageDict valueForKey:@"from"];
    NSArray *msgReceiverInfo = [messageDict valueForKey:@"to"];
    Conversation *conversation = [[Conversation findWithPredicate:[NSPredicate predicateWithFormat:@"conversationId=%@",[[messageDict valueForKey:@"conversationId"] stringValue]]] createIfNotExists];
    
    Message *message = [[Message findWithPredicate:[NSPredicate predicateWithFormat:@"messageId=%@",
                                                    [[messageDict valueForKey:@"id"] stringValue]]] firstObject];
    // if new message, create and save message in core data
    if (message == nil) {
        message = [Message create];
        message.messageId = [[messageDict valueForKey:@"id"] stringValue];
        message.messageStatus = [messageDict valueForKey:@"messageStatus"];
        message.readStatus = [messageDict valueForKey:@"readStatus"];
        message.subject = [messageDict valueForKey:@"subject"];// decryptedSubject;
        message.direction = [messageDict valueForKey:@"direction"];
        
        NSString *createdTimeString = [messageDict valueForKey:@"creationTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000Z"];
        NSDate *createdTime = [dateFormatter dateFromString:createdTimeString];
        
        message.creationTime = createdTime;
    
        Sender *sender = [Sender create];
        sender.extension = [msgSenderInfo valueForKey:@"extensionNumber"];
        sender.name = [msgSenderInfo valueForKey:@"name"];
        sender.message = message;
        [sender save];
        
        for (NSDictionary *receiverDict in msgReceiverInfo) {
            Receiver *receiver = [Receiver create];
            receiver.extension = [receiverDict valueForKey:@"extensionNumber"];
            receiver .name = [receiverDict valueForKey:@"name"];
            receiver.message = message;
            [receiver save];
        }
        
        NSDictionary *convDict = [messageDict valueForKey:@"conversation"];
        conversation.conversationId = [convDict valueForKey:@"id"];
        [conversation addMessagesObject:message];
        
        message.conversation = conversation;
        
        if (conversation.lastMessage == nil) {
            conversation.lastMessage = message;
            message.lastMessageConversation = conversation;
        } else {
            if ([conversation.lastMessage.creationTime compare:message.creationTime] == NSOrderedAscending) {
                conversation.lastMessage = message;
                message.lastMessageConversation = conversation;
            }
        }
        
        [conversation save];
        [message save];
        [self saveManagedObjectContext];
        
        if (lastMessageDate) {
            if ([lastMessageDate compare:message.creationTime] == NSOrderedAscending) {
                lastMessageDate = message.creationTime;
                [[NSUserDefaults standardUserDefaults]setObject:message.creationTime forKey:kRCLastMessageDate];
                [[NSUserDefaults standardUserDefaults]setObject:[messageDict valueForKey:@"creationTime"] forKey:kRCLastMessageDateString];
            }
        } else {
            lastMessageDate = message.creationTime;
            [[NSUserDefaults standardUserDefaults]setObject:lastMessageDate forKey:kRCLastMessageDate];
            [[NSUserDefaults standardUserDefaults]setObject:[messageDict valueForKey:@"creationTime"] forKey:kRCLastMessageDateString];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 * saves Managed Object Context
 */
- (void) saveManagedObjectContext {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [appDelegate.stack.managedObjectContext saveWithType:NSSaveSelfAndParent];
}


@end
