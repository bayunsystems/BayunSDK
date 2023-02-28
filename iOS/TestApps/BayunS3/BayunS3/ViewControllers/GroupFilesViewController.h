//
//  GroupFilesViewController.h
//  BayunS3
//
//  Created by Preeti Gaur on 03/04/17.
//  Copyright © 2023 bayun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bayun/BayunCore.h>

@interface GroupFilesViewController : UIViewController

@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noItemsView;
@property (strong, nonatomic) Group *group;

- (IBAction)manageButtonIsPressed:(id)sender;


@end
