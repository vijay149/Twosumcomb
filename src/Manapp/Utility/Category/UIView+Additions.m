//
//  UIView+Additions.m
//  MedTalk
//
//  Created by Hieu Bui on 8/12/12.
//  Copyright (c) 2012 SETACINQ Vietnam. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView(Additions)

- (void)setWidth:(CGFloat)widthValue
{
    CGRect frame = self.frame;
    frame.size.width = widthValue;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)heightValue
{
    CGRect frame = self.frame;
    frame.size.height = heightValue;
    self.frame = frame;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)xValue
{
    CGRect frame = self.frame;
    frame.origin.x = xValue;
    self.frame = frame;
}

- (void)setOriginY:(CGFloat)yValue
{
    CGRect frame = self.frame;
    frame.origin.y = yValue;
    self.frame = frame;
}

- (void)moveToBelowView:(UIView *)view
{
    if (!view || [view isKindOfClass:[NSNull class]]) {
        return;
    }
    CGRect frame = view.frame;
    [self setOriginY:frame.origin.y + frame.size.height];
}

-(void)moveToBelowView:(UIView *)view withPadding:(CGFloat)padding{
    if (!view || [view isKindOfClass:[NSNull class]]) {
        return;
    }
    CGRect frame = view.frame;
    [self setOriginY:frame.origin.y + frame.size.height + padding];
}

- (void)makeRoundCorner:(CGFloat) cornerRadius{
    self.layer.cornerRadius = cornerRadius;
}

- (void)makeBorderWithWidth:(CGFloat) width andColor:(UIColor*) color{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

-(void)removeAllSubviews{
    NSArray *viewsToRemove = [self subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

- (void)moveBy:(CGPoint) distance duration:(CGFloat) duration{
    [UIView animateWithDuration:duration animations:^{
        [self setOriginX:(self.frame.origin.x + distance.x)];
        [self setOriginY:(self.frame.origin.y + distance.y)];
    }];
}

- (void)moveHorizontalBy:(NSInteger) xDistance duration:(CGFloat) duration{
    [self moveBy:CGPointMake(xDistance, 0) duration:duration];
}

- (void)moveVerticalBy:(NSInteger) yDistance duration:(CGFloat) duration{
    [self moveBy:CGPointMake(0, yDistance) duration:duration];
}

- (void)moveToBottomOfSuperView{
    [self setHeight:self.superview.frame.size.height - self.frame.size.height];
}

@end
