//
//  GroupsViewController.h
//  BayunS3
//
//  Created by Preeti Gaur on 06/03/17.
//  Copyright © 2017 bayun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noItemsView;

- (IBAction)createButtonIsPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)segmentIsSelected:(id)sender;

@end
