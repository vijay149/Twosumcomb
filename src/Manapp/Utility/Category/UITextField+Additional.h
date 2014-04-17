//
//  UITextField+Additional.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UITextField (Additional)

-(void) paddingWithPaddingRect:(CGRect) paddingRect;
-(void) paddingLeftByValue:(CGFloat) value;
-(void) paddingTopByValue:(CGFloat) value;
-(void) resizeVerticalToFitText:(NSString *) text;
@end
