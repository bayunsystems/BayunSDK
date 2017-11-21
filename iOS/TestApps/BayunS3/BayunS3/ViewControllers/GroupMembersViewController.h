//
//  GroupMembersViewController.h
//  BayunS3
//
//  Created by Preeti Gaur on 05/04/17.
//  Copyright © 2017 bayun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMembersViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noItemsView;


@property (strong,nonatomic) NSString *groupId;

@end
