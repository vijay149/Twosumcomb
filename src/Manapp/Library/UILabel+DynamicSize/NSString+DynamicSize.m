//
//  NSString+DynamicSize.m
//  VNA_ManageMyAccount
//
//  Created by Tran Ngoc Linh on 3/22/13.
//  Copyright (c) 2013 Fsoft. All rights reserved.
//

#import "NSString+DynamicSize.h"

@implementation NSString (DynamicSize)

-(float)expectedWidthWithHeight:(float)height font:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode {

    CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, height);

    CGSize expectedLabelSize = [self sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:lineBreakMode];
    return expectedLabelSize.width;
}

-(float)expectedHeightWithWidth:(float)width font:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode {

    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);

    CGSize expectedLabelSize = [self sizeWithFont:font
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:lineBreakMode];
    return expectedLabelSize.height;
}

@end
