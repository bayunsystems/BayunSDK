//
//  GroupsViewController.h
//  BayunS3
//
//  Created by Preeti Gaur on 06/03/17.
//  Copyright © 2023 bayun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsViewController : UIViewController

@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noItemsView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)createButtonIsPressed:(id)sender;
- (IBAction)segmentIsSelected:(id)sender;

@end
