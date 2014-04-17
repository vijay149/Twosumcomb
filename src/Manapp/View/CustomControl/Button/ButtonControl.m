//
//  ButtonControl.m
//  TheHappiestBaby
//
//  Created by Chungdv on 3/7/12.
//  Copyright 2012 SETA:CINQ Vietnam., Ltd. All rights reserved.
//

#import "ButtonControl.h"



@implementation ButtonControl

+(id)ButtonWithImageBackground:(UIImage *)image
{
    ButtonControl *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [UIFont fontWithName:@"Helvetica-Bold" size:12];
    btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD_DEFAULT size:FONT_SIZE_DEFAULT];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
	[btn setContentMode:UIViewContentModeScaleAspectFit];
    [btn setBackgroundColor:[UIColor clearColor]];
    return btn;
}

+(id)ButtonWithImage:(UIImage *)image
{
    ButtonControl *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD_DEFAULT size:FONT_SIZE_DEFAULT];
    [btn setImage:image forState:UIControlStateNormal];
	[btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btn setBackgroundColor:[UIColor clearColor]];
    return btn;
}


+(id)ButtonLinkWithTitle:(NSString *)title
{
    ButtonControl *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD_DEFAULT size:FONT_SIZE_DEFAULT];
    btn.titleLabel.textAlignment = UITextAlignmentCenter;
    btn.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    [btn setTitleColor:TEXT_LINK_COLOR_DEFAULT forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTitleColor:TEXT_LINK_HIGHLIGHT_COLOR_DEFAULT forState:UIControlStateHighlighted];
    [btn.layer setBorderWidth:0];
    return btn;
}

+(id)ButtonWithTitle:(NSString *)title
{
    ButtonControl *btn = [UIButton buttonWithType:UIButtonTypeCustom];    
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD_DEFAULT size:FONT_SIZE_DEFAULT];
    btn.titleLabel.textAlignment = UITextAlignmentCenter;
//    btn.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [btn setTitleColor:TEXT_COLOR_DEFAULT forState:UIControlStateNormal];
//    [btn setTitleShadowColor:TEXT_SHADOW_COLOR_DEFAULT forState:UIControlStateNormal];
    [btn setTitleColor:TEXT_LINK_COLOR_DEFAULT forState:UIControlStateHighlighted];
    [btn setBackgroundColor:BUTTON_BACKGROUND_COLOR_DEFAULT];
    [[btn layer] setCornerRadius:BUTTON_CORNER_RADIUS_DEFAULT];    
    return btn;
}

+(id)ButtonWithFullImageBackground:(UIImage *)image
{
    ButtonControl *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    [btn setBackgroundColor:BUTTON_BACKGROUND_COLOR_DEFAULT];
    [[btn layer] setBorderWidth:BUTTON_BORDER_WIDTH_DEFAULT];
    [[btn layer] setBorderColor:[BUTTON_BORDER_COLOR_DEFAULT CGColor]];
    btn.titleLabel.font = [UIFont fontWithName:FONT_BOLD_DEFAULT size:FONT_SIZE_DEFAULT];
    return btn;
}

-(void)dealloc
{
    [super dealloc];
}

+(CGRect)getAutoHeightForButton:(ButtonControl *)btn
{
    CGRect rect = btn.frame;
    CGSize labelSize = [btn.titleLabel.text sizeWithFont:btn.titleLabel.font constrainedToSize:CGSizeMake(rect.size.width, 9999) lineBreakMode:btn.titleLabel.lineBreakMode];
    rect.size.height = labelSize.height;
    return rect;
}

- (void)setAutoHeight{
    if(self){
    CGRect rect = [ButtonControl getAutoHeightForButton:self];
    self.frame = rect;
    }
}

@end
