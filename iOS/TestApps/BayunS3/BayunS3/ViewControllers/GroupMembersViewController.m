//
//  GroupMembersViewController.m
//  BayunS3
//
//  Created by Preeti Gaur on 05/04/17.
//  Copyright © 2023 bayun. All rights reserved.
//

#import "GroupMembersViewController.h"
#import <Bayun/BayunCore.h>

@interface GroupMembersViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) NSArray<GroupMember*> *groupMembers;

@end

@implementation GroupMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Members";
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init] ;
    
    [self setUpView];
    [self getGroupDetails];
}

- (void) setUpView {
    if(self.groupMembers.count > 0) {
        self.tableView.hidden = false;
        self.noItemsView.hidden = true;
        [self.tableView reloadData];
    } else {
        self.tableView.hidden = true;
        self.noItemsView.hidden = false;
    }
}

- (void)getGroupDetails {
    
    [SVProgressHUD show];
    [[BayunCore sharedInstance] getGroupById:self.groupId success:^(Group *group) {
        [SVProgressHUD dismiss];
        self.groupMembers = group.groupMembers;
        [self setUpView];
        
    } failure:^(BayunError error) {
        [SVProgressHUD showErrorWithStatus:kErrorMsgSomethingWentWrong];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    GroupMember *member = [self.groupMembers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = member.companyEmployeeId;
    cell.detailTextLabel.text = member.companyName;
    cell.detailTextLabel.font=[UIFont fontWithName:@"Helvetica" size:9.0];
    
    cell.imageView.image = [UIImage imageNamed:@"Member"];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    
    GroupMember *member = [self.groupMembers objectAtIndex:indexPath.row];
    NSString *memberId = member.companyEmployeeId;

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:[NSString stringWithFormat:@"Remove %@ from Members?",memberId]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
      
      [[BayunCore sharedInstance] removeFromGroup:self.groupId groupMember:member success:^{
        [self getGroupDetails];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ removed from Members",memberId]];
      } failure:^(BayunError error) {
        [SVProgressHUD showErrorWithStatus:@"Something Went Wrong"];
      }];
    }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Cancel"
                               style:UIAlertActionStyleDefault
                               handler:nil];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

