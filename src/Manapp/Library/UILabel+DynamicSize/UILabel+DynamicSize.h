//
//  UILabel+DynamicSize.h
//  VNA_ManageMyAccount
//
//  Created by Tran Ngoc Linh on 3/22/13.
//  Copyright (c) 2013 Fsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (DynamicSize)

-(void)resizeWidthToFit;
-(void)resizeHeightToFit;
-(void)resizeToStretchHeightWithWidth:(float)width;

-(float)expectedWidth;
-(float)expectedHeight;
-(float)expectedHeightWithWidth:(float)width;

@end
