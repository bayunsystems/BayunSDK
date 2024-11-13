#import "Checkbox.h"
#import "BayunUtilities.h"
#import "BayunConstants.h"

IB_DESIGNABLE
@implementation Checkbox{
    UIButton *checkButton;
    UILabel *label;
    BOOL textIsSet;
}
@synthesize text = _text;
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initInternals];
    }
    return self;
}
- (void) initInternals{
    _boxFillColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    _boxBorderColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    _checkColor = [UIColor whiteColor];
    _isChecked = YES;
    _isEnabled = YES;
    _showTextLabel = NO;
    textIsSet = NO;
    self.backgroundColor = [UIColor clearColor];
}
-(CGSize)intrinsicContentSize{
    if (_showTextLabel) {
        return CGSizeMake(160, 40);
    }
    else{
        return CGSizeMake(40, 40);
    }
}

- (void)drawRect:(CGRect)rect {
  
  // Drawing code
  [_boxFillColor setFill];
  [_boxBorderColor setStroke];
  
  //check if label has already been created... if not create a new label and set some basic styles
  if (!textIsSet) {
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width-50, self.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    textIsSet = YES;
  }
  
  //style label
  label.font = _labelFont;
  label.textColor = _labelTextColor;
  label.text = self.text;
  
  checkButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 20, 20)];
  
  [checkButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
  
  NSData *checkDataImg = [BayunUtilities decodeBase64String:kCheckImageString];
  NSData *uncheckDataImg = [BayunUtilities decodeBase64String:kUncheckImageString];
  
  [checkButton setImage:[UIImage imageWithData:checkDataImg] forState:UIControlStateSelected];
  [checkButton setImage:[UIImage imageWithData:uncheckDataImg] forState:UIControlStateNormal];
  
  [checkButton addTarget:self
                  action:@selector(chkBtnHandler:)
        forControlEvents:UIControlEventTouchUpInside];
  
  [self addSubview:checkButton];
  
  
  //check if control is enabled...lower alpha if not and disable interaction
  if (_isEnabled == YES) {
    self.alpha = 1.0f;
    self.userInteractionEnabled = YES;
  }
  
  else{
    self.alpha = 0.6f;
    self.userInteractionEnabled = NO;
  }
  
  [self setNeedsDisplay];
}


- (void)chkBtnHandler:(UIButton *)sender {
  // If checked, uncheck and visa versa
  [sender setSelected:!sender.isSelected];
  
  [self.delegate checkboxButtonIsPressed:sender];
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self setChecked:!_isChecked];
    return true;
}

-(void)setChecked:(BOOL)isChecked{
    _isChecked = isChecked;
}
-(void)setEnabled:(BOOL)isEnabled{
    _isEnabled = isEnabled;
    [self setNeedsDisplay];
}
-(void)setText:(NSString *)stringValue{
    _text = stringValue;
    [self setNeedsDisplay];
}
@end
