//
//  UILabel+Additions.m
//  Manapp
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "MADeviceUtil.h"
@implementation UILabel (Additions)
-(void) changeSizeToMatchText:(NSString *) text allowWidthChange:(BOOL) allowWidthChange{
    CGSize textSize;    
    if (iOS7OrLater) {
        if (text && [text respondsToSelector:@selector(sizeWithAttributes:)]){
            textSize = [text sizeWithAttributes: @{NSFontAttributeName: self.font}];// ios 7
        }
    }else{
        textSize = [text sizeWithFont:self.font];
    }
    if(allowWidthChange){
        [self setSize:textSize];
    }
    else{
        NSInteger numberOfLine = (NSInteger)(textSize.width / self.frame.size.width) + 1;
        [self setHeight:(textSize.height * numberOfLine )];
        self.numberOfLines = numberOfLine + 1;
    }
}

-(void) addShadowWithRadius:(CGFloat) radius opacity:(CGFloat) opacity offset:(CGSize) offset color:(UIColor *)color{
    self.layer.shadowColor = [color CGColor];
    self.layer.shadowOffset = offset;
    
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
        
    self.layer.masksToBounds = NO;
}

- (UILabelResizeResult)alignToTop
{
	CGFloat originalLabelHeight = self.frame.size.height;
    
	CGRect rect = [self textRectForBounds:self.bounds limitedToNumberOfLines:999];
    
	CGRect newRect = self.frame;
	newRect.size.height = rect.size.height;
    
	self.frame = newRect;
	
	if(self.frame.size.height == originalLabelHeight)
		return UILabelResizedNoChange;
	else
		return UILabelResized;
}

- (UILabelResizeResult)enlargeHeightToKeepFontSize
{
	CGFloat originalLabelHeight = self.frame.size.height;
    
	CGRect rect = [self textRectForBounds:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 9999.0f) limitedToNumberOfLines:999];
	
	CGRect newRect = self.frame;
	newRect.size.height = rect.size.height;
	
	self.frame = newRect;
    
    self.numberOfLines = 9999;
	
	if(self.frame.size.height == originalLabelHeight)
		return UILabelResizedNoChange;
	else
		return UILabelResized;
}

- (UILabelResizeResult)enlargeWidthToKeepFontSizeWithLimit:(CGFloat)maxWidth
{
	CGFloat originalLabelWidth = self.frame.size.width;
    
	CGRect rect = [self textRectForBounds:CGRectMake(self.frame.origin.x, self.frame.origin.y, 9999.0f, self.frame.size.height) limitedToNumberOfLines:1];
    
	CGRect newRect = self.frame;
    if(rect.size.width > maxWidth){
        newRect.size.width = maxWidth;
    }
    else{
        newRect.size.width = rect.size.width;
    }
    
    self.frame = newRect;
    
    if(self.frame.size.width == originalLabelWidth)
        return UILabelResizedNoChange;
    else
        return UILabelResized;
}

- (UILabelResizeResult)resizeFontSizeToKeepCurrentRect:(CGFloat)initialFontSize
{
	CGFloat originalLabelHeight = self.frame.size.height;
	CGFloat labelHeight = 0.0f;
	UIFont* font = self.font;
    
	for(CGFloat f = initialFontSize; f > self.minimumFontSize; f -= 1.0f)
	{
		font = [font fontWithSize:f];
		CGSize constraintSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
		CGSize labelSize = [self.text sizeWithFont:font
								 constrainedToSize:constraintSize
									 lineBreakMode:UILineBreakModeWordWrap];
        
		labelHeight = labelSize.height;
		if(labelHeight <= originalLabelHeight)
			break;
	}
    
	self.font = font;
	
	if(labelHeight == originalLabelHeight)
		return UILabelResizedNoChange;
	else if(labelHeight < originalLabelHeight)
		return UILabelResized;
	else
		return UILabelResizeFailed;
}
@end
