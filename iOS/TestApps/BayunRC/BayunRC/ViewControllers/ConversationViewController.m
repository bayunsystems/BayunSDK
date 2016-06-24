//
//  ConversationViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 20/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "ConversationViewController.h"
#import "User.h"
#import "Message.h"
#import "Conversation.h"
#import "RCMessage.h"
#import "RCAPIManager.h"
#import "RCConfig.h"
#import <AVFoundation/AVFoundation.h>
#import "RCCryptManager.h"

@interface ConversationViewController ()<UITextViewDelegate>

@property (strong,nonatomic) NSMutableArray *messages;
@property (strong,nonatomic) Message *lastMessage;
@property (strong,nonatomic) NSTimer *timerToRefreshMessages;
@end

/**
 ConversationViewController shows all the messages in a conversation.
 */
@implementation ConversationViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    self.messages = [[NSMutableArray alloc] init];
    
    self.senderId = [RCUtilities appUser].extension;
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    self.inputToolbar.contentView.textView.placeHolder = @"Your Message...";
    
    
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory
                                    outgoingMessagesBubbleImageWithColor:[RCUtilities colorFromHexString:@"#bcd4ee"]];
    self.incomingBubbleImageData = [bubbleFactory
                                    incomingMessagesBubbleImageWithColor:[RCUtilities colorFromHexString:@"#ffffff"]];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.inputToolbar.contentView.textView.delegate = self;
    self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    self.inputToolbar.contentView.textView.delegate = self;
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backarrow"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backButtonIsPressed:)];
    self.navigationItem.leftBarButtonItem=newBackButton;
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kIsAccessDenied];
    
    if (self.conversation) {
        self.lastMessage = self.conversation.lastMessage;
    }
    
    self.timerToRefreshMessages = [NSTimer timerWithTimeInterval:kTimeToRefreshConversationView
                                                          target:self
                                                        selector:@selector(getNewMessages)
                                                        userInfo:nil
                                                         repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timerToRefreshMessages
                              forMode:NSDefaultRunLoopMode];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.collectionView reloadData];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    [self sortMessages];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.inputToolbar.contentView.textView resignFirstResponder];
    [self invalidateMessageRefreshTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) backButtonIsPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setTitle {
    self.title = self.chatParticipant.name;
}


- (void)setUpLeftBarButton:(BOOL)isUploadRunning {
    self.inputToolbar.contentView.leftBarButtonItem.enabled = YES;
    self.inputToolbar.contentView.leftBarButtonItem.alpha = 1.0;
}

/*
 * Sends pager-message
 */
-(void) sendMessage:(NSDictionary*)parameters {
    [[RCAPIManager sharedInstance]sendMessage:parameters success:^{
        [self doneSendingMessage];
        [self refreshMessages];
        [self scrollToBottomAnimated:YES];
    } failure:^(RCError errorCode) {
        if (errorCode == RCErrorInternetConnection) {
            [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
        } else if (errorCode == RCErrorRequestTimeOut) {
            [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
        } else if (errorCode == RCErrorInvalidToken) {
            AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate logoutWithMessage:kErrorSessionIsExpired];
        } else {
            [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
        }
    }];
    
}

/*
 * Fetches new pager messages
 */
-(void) getNewMessages {
    [[RCAPIManager sharedInstance]getMessageList:^{
        [self refreshMessages];
    } failure:^(RCError errorCode) {
        if (errorCode == RCErrorInvalidToken) {
            AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate logoutWithMessage:kErrorSessionIsExpired];
        } else if(errorCode == RCErrorSomethingWentWrong) {
            [self invalidateMessageRefreshTimer];
        }
    }];
}

/*
 * Invalidates the messages refresh timer
 */
-(void) invalidateMessageRefreshTimer {
    [self.timerToRefreshMessages invalidate];
    self.timerToRefreshMessages = nil;
}

#pragma mark - Methods for Sort and Refresh Pager Messages

-(void) sortMessages {
    if (self.conversation) {
        self.lastMessage = self.conversation.lastMessage;
        
        [self.messages removeAllObjects];
        
        for (Message *message in self.conversation.messages) {
            [self.messages addObject:message];
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationTime" ascending:YES];
        [self.messages sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:YES];
    }
    [SVProgressHUD dismiss];
}

-(void) refreshMessages {
    Conversation *conversation = [[Conversation findWithPredicate:
                                   [NSPredicate predicateWithFormat:@"conversationId=%@",self.conversation.conversationId]] lastObject];
   
    if (conversation) {
        self.conversation = conversation;
    } else {
        conversation = [[Conversation findWithPredicate:[NSPredicate predicateWithFormat:@"lastMessage.from.extension=%@ OR ANY lastMessage.to.extension= [cd]%@",self.chatParticipant.extension,self.chatParticipant.extension]] lastObject];
        self.conversation = conversation;
    }
    
    if ((self.lastMessage && ![self.lastMessage isEqual:self.conversation.lastMessage]) || self.lastMessage == nil) {
        [self sortMessages];
    }

}

#pragma mark - Messages view data source: REQUIRED

- (void)setSendingMessage {
    self.inputToolbar.contentView.rightBarButtonItem.enabled = NO;
    self.inputToolbar.contentView.textView.placeHolder = @"";
    self.inputToolbar.contentView.textView.text = @"";
}

- (void)doneSendingMessage {
    self.inputToolbar.contentView.textView.text = @"";
    [self performSelector:@selector(setPlaceholderText) withObject:nil afterDelay:0.3];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
   
}

- (void) setPlaceholderText {
    self.inputToolbar.contentView.textView.placeHolder  = @"Your Message...";
}

#pragma mark - JSQMessagesViewController


- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsAccessDenied];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self setSendingMessage];
    NSString *message = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    NSDictionary *recipient = @{@"extensionNumber" : self.chatParticipant.extension};
    NSDictionary *sender = @{@"extensionNumber" :
                                 [[NSUserDefaults standardUserDefaults] valueForKey:kRCExtension]};
    
    NSArray *recipientArray = [[NSArray alloc] initWithObjects:recipient, nil];
    
    [parameters setObject:recipientArray forKey:@"to"];
    [parameters setObject:sender forKey:@"from"];
    
    
   NSString *encryptedMessage =  [[RCCryptManager sharedInstance] encryptText:message];
    if (encryptedMessage) {
        [parameters setObject:encryptedMessage  forKey:@"text"];
        [self sendMessage:parameters];
    } else {
        [SVProgressHUD showErrorWithStatus:kErrorMessageCouldNotBeSent];
    }
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessage *message =[[RCMessage alloc] initWithMessage:[self.messages objectAtIndex:indexPath.row]];
    return message;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    RCMessage *message =[[RCMessage alloc] initWithMessage:[self.messages objectAtIndex:indexPath.row]];
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    return self.incomingBubbleImageData;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
      return nil;
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *con
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    //BMLOG(@"1:1 cellForItemAtIndexPath:%d",indexPath.row);
    
    RCMessage *message = [[RCMessage alloc] initWithMessage:[self.messages objectAtIndex:indexPath.row]];
    
    if([message.senderId isEqualToString:[[RCUtilities appUser] extension]]) {
        cell.textView.textColor =[RCUtilities colorFromHexString:@"#383838"];;
    } else {
        cell.textView.textColor =[RCUtilities colorFromHexString:@"#383838"];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : [RCUtilities colorFromHexString:@"#0072bc"],
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}


#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     */
    return 0.0f;
    
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    if( indexPath.row == [self.messages count] - 1 ) {
        RCMessage *message =[[RCMessage alloc] initWithMessage:[self.messages objectAtIndex:indexPath.row]] ;
        if ([self.senderId isEqualToString:message.senderId]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
    }
    return 0.0f;
}


#pragma mark - Messages view delegate: OPTIONAL

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}

- (BOOL)allowsPanToDismissKeyboard {
    return YES;
}


@end
