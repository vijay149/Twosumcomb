//
//  UITextField+Additional.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "UITextField+Additional.h"
#import "UIView+Additions.h"

@implementation UITextField (Additional)

//padding 4 side
-(void) paddingWithPaddingRect:(CGRect) paddingRect{
    UIView *paddingView = [[[UIView alloc] initWithFrame:paddingRect] autorelease];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

//padding left
-(void) paddingLeftByValue:(CGFloat) value{
    [self paddingWithPaddingRect:CGRectMake(0, 0, value, 0)];
}

-(void) paddingTopByValue:(CGFloat) value{
    [self paddingWithPaddingRect:CGRectMake(0, 0, 0, value)];
}

-(void) resizeVerticalToFitText:(NSString *) text{
    CGFloat verticalMargin = 10;
    
    CGSize maximumSize = CGSizeMake(self.frame.size.width, 9999);
    CGSize myStringSize = [text sizeWithFont:self.font
                               constrainedToSize:maximumSize
                                   lineBreakMode:NSLineBreakByCharWrapping];
    
    [self setHeight:myStringSize.height + verticalMargin * 2];
}

@end
