//
//  CreateTextFileViewController.h
//  DemoPhase1
//
//  Created by Preeti Gaur on 29/05/2015.
//  Copyright (c) 2023 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bayun/BayunCore.h>

@interface CreateTextFileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSString *bucketName;

- (IBAction)saveButtonIsPressed:(id)sender;

@property (strong,nonatomic) Group *group;

@end
