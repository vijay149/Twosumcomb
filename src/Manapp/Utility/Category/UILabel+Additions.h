//
//  UILabel+Additions.h
//  Manapp
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum _UILabelResizeResult{
	UILabelResizeFailed = -1,
	UILabelResizedNoChange = 0,
	UILabelResized = 1,
} UILabelResizeResult;

@interface UILabel (Additions)

-(void) changeSizeToMatchText:(NSString *) text allowWidthChange:(BOOL) allowWidthChange;
-(void) addShadowWithRadius:(CGFloat) radius opacity:(CGFloat) opacity offset:(CGSize) offset color:(UIColor *) color;

//align text to top
- (UILabelResizeResult)alignToTop;

//enlarge height of this label to keep current text and font size
- (UILabelResizeResult)enlargeHeightToKeepFontSize;
- (UILabelResizeResult)enlargeWidthToKeepFontSizeWithLimit:(CGFloat)maxWidth;
//resize font size to keep current text and label size
- (UILabelResizeResult)resizeFontSizeToKeepCurrentRect:(CGFloat)initialFontSize;
@end
