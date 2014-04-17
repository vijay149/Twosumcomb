//
//  UIImage+Additions.m
//  Manapp
//
//  Created by Demigod on 04/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizeByRatio:(CGPoint) ratio{
    return [UIImage imageWithImage:self scaledToSize:CGSizeMake(ratio.x * self.size.width, ratio.y * self.size.height)];
}
- (UIImage *)resizeByRatioX:(CGFloat) ratio{
    return [self resizeByRatio:CGPointMake(ratio, 1)];
}
- (UIImage *)resizeByRatioY:(CGFloat) ratio{
    return [self resizeByRatio:CGPointMake(1, ratio)];
}
@end
