//
//  ExtensionListViewController.m
//  Bayun
//
//  Created by Preeti Gaur on 14/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import "ExtensionListViewController.h"
#import "ConversationViewController.h"
#import "User.h"
#import "Conversation.h"


@interface ExtensionListViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end


/**
 ExtensionListViewController shows the Extension list.
 */
@implementation ExtensionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Select Extension";
    self.tableView.tableFooterView = [[UIView alloc] init] ;
}


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSError *error=nil;
    if ([[self fetchedResultsController] performFetch:&error]) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) backButtonIsPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSFetchviewcontroller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name"
                              ascending:YES
                              selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSManagedObjectCollection *moCollection = [User all];
    [moCollection.fetchRequest setFetchBatchSize:20];
    [moCollection.fetchRequest setPredicate:
    [NSPredicate predicateWithFormat:@"isAppUser=%@",[NSNumber numberWithBool:NO]]];
    [moCollection sortWithDescriptor:sort];
    
    NSFetchedResultsController *theFetchedResultsController = [moCollection fetchedResultsControllerWithSectionNameKeyPath:nil cacheName:nil];
    theFetchedResultsController.delegate = self;
    _fetchedResultsController = theFetchedResultsController;
    
    return _fetchedResultsController;
}


#pragma mark - Table View Delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_fetchedResultsController fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] ;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    User *user = [_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:user.name];
    [cell.detailTextLabel setText:user.extension];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *chatParticipant = [_fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    ConversationViewController *viewController = [[ConversationViewController alloc] init];
    viewController.chatParticipant = chatParticipant;
    
    Conversation *conversation = [[Conversation findWithPredicate:[NSPredicate predicateWithFormat:@"lastMessage.from.extension=%@ OR ANY lastMessage.to.extension= [cd]%@",chatParticipant.extension,chatParticipant.extension]] lastObject];
    viewController.conversation = conversation;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

@end
