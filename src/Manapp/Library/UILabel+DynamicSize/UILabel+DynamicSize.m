//
//  UILabel+DynamicSize.m
//  VNA_ManageMyAccount
//
//  Created by Tran Ngoc Linh on 3/22/13.
//  Copyright (c) 2013 Fsoft. All rights reserved.
//

#import "UILabel+DynamicSize.h"
#import "NSString+DynamicSize.h"

@implementation UILabel (DynamicSize)

- (void)resizeWidthToFit {
	float width = [self expectedWidth];
	CGRect newFrame = [self frame];
	newFrame.size.width = width;
	[self setFrame:newFrame];
}

- (float)expectedWidth {
	[self setNumberOfLines:1];
    
	return [self.text expectedWidthWithHeight:self.bounds.size.height
	                                     font:self.font
	                            lineBreakMode:self.lineBreakMode];
}

- (void)resizeHeightToFit {
	float height = [self expectedHeightWithWidth:self.bounds.size.width];
	CGRect newFrame = [self frame];
	newFrame.size.height = height;
	[self setFrame:newFrame];
}

- (void)resizeToStretchHeightWithWidth:(float)width {
	float height = [self expectedHeightWithWidth:width];
	CGRect newFrame = [self frame];
	newFrame.size.height = height;
	[self setFrame:newFrame];
}

- (float)expectedHeight {
	[self setNumberOfLines:0];
    
	return [self.text expectedHeightWithWidth:self.bounds.size.width
	                                     font:self.font
	                            lineBreakMode:self.lineBreakMode];
}

- (float)expectedHeightWithWidth:(float)width {
	[self setNumberOfLines:0];
    
	return abs([self.text expectedHeightWithWidth:width
	                                         font:self.font
	                                lineBreakMode:self.lineBreakMode] + 1);
}

@end
