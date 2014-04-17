//
//  ButtonControl.h
//  TheHappiestBaby
//
//  Created by Chungdv on 3/7/12.
//  Copyright 2012 SETA:CINQ Vietnam., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MACommon.h"
#import <QuartzCore/QuartzCore.h>

#define FONT_NORMAL_DEFAULT @"HelveticaNeue"
#define FONT_BOLD_DEFAULT @"Helvetica-Bold"
#define FONT_ITALIC_DEFAULT @"Helvetica-Bold"
#define FONT_BOLD_ITALIC_DEFAULT @"Helvetica-BoldOblique"
#define FONT_SIZE_DEFAULT 12

#define TEXT_COLOR_DEFAULT RGB(0,0,0)
#define TEXT_SHADOW_COLOR_DEFAULT RGB(236,235,240)
#define TEXT_LINK_COLOR_DEFAULT RGB(22,26,222)
#define TEXT_LINK_SHADOW_COLOR_DEFAULT RGB(213,201,240)
#define TEXT_LINK_HIGHLIGHT_COLOR_DEFAULT RGB(124, 123, 124)

#define BUTTON_BACKGROUND_COLOR_DEFAULT RGB(175, 173, 184)
#define BUTTON_BORDER_WIDTH_DEFAULT 1.0
#define BUTTON_BORDER_COLOR_DEFAULT RGB(125,125,125)
#define BUTTON_CORNER_RADIUS_DEFAULT 8.0

@interface ButtonControl : UIButton {
    
}

+(id)ButtonWithImageBackground:(UIImage *)image;
+(id)ButtonLinkWithTitle:(NSString *)title;
+(id)ButtonWithTitle:(NSString *)title;
+(id)ButtonWithFullImageBackground:(UIImage *)image;
+(id)ButtonWithImage:(UIImage *)image;

-(void)dealloc;
+(CGRect)getAutoHeightForButton:(ButtonControl *)btn;

- (void)setAutoHeight;

@end
