//
//  NSString+DynamicSize.h
//  VNA_ManageMyAccount
//
//  Created by Tran Ngoc Linh on 3/22/13.
//  Copyright (c) 2013 Fsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DynamicSize)

-(float)expectedWidthWithHeight:(float)height font:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode;
-(float)expectedHeightWithWidth:(float)width font:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
