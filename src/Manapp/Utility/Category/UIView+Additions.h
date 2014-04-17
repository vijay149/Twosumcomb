//
//  UIView+Additions.h
//  MedTalk
//
//  Created by Hieu Bui on 8/12/12.
//  Copyright (c) 2012 SETACINQ Vietnam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView(Additions)

- (void)setWidth:(CGFloat)widthValue;
- (void)setHeight:(CGFloat)heightValue;
- (void)setSize:(CGSize)size;
- (void)setOrigin:(CGPoint)origin;
- (void)setOriginX:(CGFloat)xValue;
- (void)setOriginY:(CGFloat)yValue;
- (void)moveToBelowView:(UIView *)view;
- (void)moveToBelowView:(UIView *)view withPadding:(CGFloat) padding;
- (void)removeAllSubviews;
- (void)makeRoundCorner:(CGFloat) cornerRadius;
- (void)makeBorderWithWidth:(CGFloat) width andColor:(UIColor*) color;
- (void)moveBy:(CGPoint) distance duration:(CGFloat) duration;
- (void)moveHorizontalBy:(NSInteger) xDistance duration:(CGFloat) duration;
- (void)moveVerticalBy:(NSInteger) yDistance duration:(CGFloat) duration;
- (void)moveToBottomOfSuperView;
@end
