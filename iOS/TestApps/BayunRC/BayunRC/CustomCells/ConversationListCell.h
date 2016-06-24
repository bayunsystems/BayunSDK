//
//  ConversationListCell.h
//  Bayun
//
//  Created by Preeti Gaur on 20/07/2015.
//  Copyright (c) 2015 Bayun Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *msgDirectionImageView;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeStampLabel;

@end
