//
//  ListFilesViewController.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListFilesViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noItemsView;

- (IBAction)moreButtonIsPressed:(id)sender;

@end
