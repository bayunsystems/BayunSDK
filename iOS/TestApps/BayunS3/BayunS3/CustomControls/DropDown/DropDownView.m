//
//  DropDownView.m
//  MKDropdownMenuExample
//
//  Created by Max Konovalov on 18/03/16.
//  Copyright © 2016 Max Konovalov. All rights reserved.
//

#import "DropDownView.h"

@implementation DropDownView

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.textLabel.font = [UIFont systemFontOfSize:self.textLabel.font.pointSize
                                            weight:selected ? UIFontWeightMedium : UIFontWeightLight];
}

@end
