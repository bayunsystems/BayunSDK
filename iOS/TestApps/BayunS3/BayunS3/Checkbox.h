//
//  Checkbox.h
//  CustomCheckboxExample
//
//  Created by kelley.ricker on 1/12/16.
//  Copyright © 2016 GrapeCity. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CheckboxDelegate <NSObject>

-(void) checkboxButtonIsPressed:(UIButton*) sender;

@end


@interface Checkbox : UIControl

-(void)setChecked:(BOOL)isChecked;
-(void)setEnabled:(BOOL)isEnabled;
-(void)setText:(NSString *)stringValue;

@property (weak, nonatomic) id<CheckboxDelegate> delegate;
@property IBInspectable UIColor *checkColor;
@property IBInspectable UIColor *boxFillColor;
@property IBInspectable UIColor *boxBorderColor;
@property IBInspectable UIFont *labelFont;
@property IBInspectable UIColor *labelTextColor;

@property IBInspectable BOOL isEnabled;
@property IBInspectable BOOL isChecked;
@property IBInspectable BOOL showTextLabel;
@property (nonatomic, strong) IBInspectable  NSString *text;

@end
