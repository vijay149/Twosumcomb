//
//  ImageHelper.h
//  TwoSum
//
//  Created by Demigod on 02/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface ImageHelper : NSObject

#pragma mark - Color
+(UIImage *) changeImageColor:(UIImage *) image byMultiWithR:(CGFloat) red g:(CGFloat) green b:(CGFloat) blue a:(CGFloat) alpha;

#pragma mark - Blend
+(UIImage *) overlayImage:(UIImage *) overlayImage overImage:(UIImage *) image;

//Save an UIView to an UIImage
+ (UIImage*) saveAnUIViewToImage: (UIView*) inputView;
+ (void)saveImage: (UIImage*)image;
+ (UIImage*)loadImage;
@end
