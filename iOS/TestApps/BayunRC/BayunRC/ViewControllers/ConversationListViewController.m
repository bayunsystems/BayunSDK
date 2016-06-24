//
//  ListFilesViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "ConversationListViewController.h"
#import "Message.h"
#import "ConversationListCell.h"
#import "RCAPIManager.h"
#import "Sender.h"
#import "Receiver.h"
#import "Conversation.h"
#import "User.h"
#import "ExtensionListViewController.h"
#import "ConversationViewController.h"
#import "RCCryptManager.h"


@interface ConversationListViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

@property (strong , nonatomic) UIBarButtonItem *createButton;
@property (strong,nonatomic) NSArray *s3BucketObjectsArray;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

/**
 ConversationListViewController shows list of conversation
 */
@implementation ConversationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.title = @"Messages";
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.hidden = NO;
    
    [self addNavigationBarButton];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init] ;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor colorWithRed:3/255.0f green:97/255.0f blue:134/255.0f alpha:1.0];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getNewMessages];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSError *error=nil;
    if ([[self fetchedResultsController] performFetch:&error]) {
         [self.tableView reloadData];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.fetchedResultsController.delegate = nil;
}

- (IBAction) createButtonIsPressed :(id)sender {
    UIActionSheet *sheet=[[UIActionSheet alloc]initWithTitle:Nil
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:Nil
                                           otherButtonTitles:@"New Message",@"Logout", nil];
    [sheet showInView:self.view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addNavigationBarButton {
    self.createButton = [[UIBarButtonItem alloc] initWithTitle:@"More"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(createButtonIsPressed:)];
    
    self.navigationItem.rightBarButtonItem = self.createButton;
}

- (void) refreshControlEndRefreshing {
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
}

- (void) refreshInvoked:(id)sender forState:(UIControlState)state {
    [self getNewMessages];
}


- (void) getNewMessages {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (appDelegate.isNetworkReachable) {
        [[RCAPIManager sharedInstance] getMessageList:^{
            [self refreshControlEndRefreshing];
            NSError *error=nil;
            if ([[self fetchedResultsController] performFetch:&error]) {
                [self.tableView reloadData];
            }
        } failure:^(RCError errorCode) {
            [self refreshControlEndRefreshing];
            if (errorCode == RCErrorInternetConnection) {
                [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
            } else if (errorCode == RCErrorInvalidToken) {
                AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate logoutWithMessage:kErrorSessionIsExpired];
            } else if (errorCode == RCErrorRequestTimeOut) {
                [SVProgressHUD showErrorWithStatus:kErrorCouldNotConnectToServer];
            } else {

                [SVProgressHUD showErrorWithStatus:kErrorSomethingWentWrong];
            }
        }];
    } else {
        [self refreshControlEndRefreshing];
        [SVProgressHUD showErrorWithStatus:kErrorInternetConnection];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
            ExtensionListViewController *viewController = [[ExtensionListViewController alloc]init];
            [self.navigationController pushViewController:viewController animated:YES];
    } else if(buttonIndex==1) {
        AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logoutWithMessage:nil];
    }
}

#pragma mark NSFetchviewcontroller
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"lastMessage.creationTime"
                              ascending:NO
                              selector:@selector(compare:)];
    
    NSManagedObjectCollection *moCollection = [Conversation all];
    [moCollection sortWithDescriptor:sort];
    
    NSFetchedResultsController *theFetchedResultsController = [moCollection fetchedResultsControllerWithSectionNameKeyPath:nil cacheName:nil];
    
    theFetchedResultsController.delegate = self;
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Table View Delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ConversationListCell";
    
    ConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ConversationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ConversationListCell" owner:cell options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    Conversation *conversation = [[_fetchedResultsController fetchedObjects]  objectAtIndex:indexPath.row];
    NSString *peerExtension;
   
    if ([conversation.lastMessage.direction isEqualToString:@"Outbound"]) {
        [cell.imageView setImage:[UIImage imageNamed:@"outBound"]];
        Receiver *receiver = [conversation.lastMessage.to lastObject];
        if (receiver.name) {
            [cell.senderNameLabel setText:receiver.name];
        } else {
            [cell.senderNameLabel setText:receiver.extension];
        }
        peerExtension = receiver.extension;
    } else {
        [cell.imageView setImage:[UIImage imageNamed:@"inBound"]];
        
        Sender *sender = conversation.lastMessage.from;
        if (sender.name) {
            [cell.senderNameLabel setText:sender.name];
        } else {
            [cell.senderNameLabel setText:sender.extension];
        }
        
        peerExtension = sender.extension;
    }
    
    [cell.messageLabel setText:conversation.lastMessage.subject];
    
    [cell.messageLabel setText:[[RCCryptManager sharedInstance] decryptText :conversation.lastMessage.subject ]];
    
    [cell.timeStampLabel setText:[RCUtilities getCurrentTimeStampDateString:conversation.lastMessage.creationTime]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Conversation *conversation = [[_fetchedResultsController fetchedObjects]  objectAtIndex:indexPath.row];
    
    ConversationViewController *vc = [[ConversationViewController alloc] init];
    vc.conversation = conversation;
    
    Message *lastMessage = conversation.lastMessage;
    User *chatParticipant;
    if ([lastMessage.direction isEqualToString:@"Inbound"]) {
        chatParticipant = [[User findWithPredicate:[NSPredicate predicateWithFormat:@"extension=%@",lastMessage.from.extension]] lastObject];
    } else {
        chatParticipant = [[User findWithPredicate:[NSPredicate predicateWithFormat:@"extension=%@",[[lastMessage.to lastObject]extension]]] lastObject];
    }
    vc.chatParticipant = chatParticipant;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
