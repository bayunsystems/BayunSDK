//
//  ListFilesViewController.h
//  Bayun
//
//  Created by Preeti Gaur on 02/06/2015.
//  Copyright (c) 2022 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
