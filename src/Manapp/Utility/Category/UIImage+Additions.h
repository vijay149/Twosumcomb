//
//  UIImage+Additions.h
//  Manapp
//
//  Created by Demigod on 04/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)resizeByRatio:(CGPoint) ratio;
- (UIImage *)resizeByRatioX:(CGFloat) ratio;
- (UIImage *)resizeByRatioY:(CGFloat) ratio;
@end
