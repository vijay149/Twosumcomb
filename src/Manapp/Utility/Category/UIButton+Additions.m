//
//  UIButton+Additions.m
//  IKEA
//
//  Created by Demigod on 03/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import "UIButton+Additions.h"
#import "UIView+Additions.h"

@implementation UIButton (Additions)

-(void)resizeToFitText{
    CGSize stringsize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    [self setWidth:stringsize.width + UIBUTTON_ADDITIONS_HORIZONTAL_PADDING * 2];
    [self setHeight:stringsize.height + UIBUTTON_ADDITIONS_VERTICAL_PADDING * 2];
}

- (void) resizeWidthToFitText{
    CGSize stringsize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    [self setWidth:stringsize.width + UIBUTTON_ADDITIONS_HORIZONTAL_PADDING * 2];
}

- (void) changeTitle:(NSString *)title{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
}

- (void) changeTitleColor:(UIColor *)color{
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
}

- (void) changeTitleAndAutoFitSize:(NSString *) title{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self resizeToFitText];
}

- (void) changeTitleAndAutoFitWidth:(NSString *) title{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self resizeWidthToFitText];
}

- (void) setBackgroundImageWithImageName:(NSString *) imageName{
    [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

- (void) setImageWithImageName:(NSString *) imageName{
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
}

@end
