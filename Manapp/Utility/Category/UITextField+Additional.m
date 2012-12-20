//
//  UITextField+Additional.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "UITextField+Additional.h"

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

@end
