//
//  CreateTextFileViewController.h
//  DemoPhase1
//
//  Created by Preeti Gaur on 29/05/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateTextFileViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextView *textView;

- (IBAction)saveButtonIsPressed :(id)sender;

@end
