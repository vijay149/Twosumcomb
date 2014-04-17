//
//  ImageHelper.m
//  TwoSum
//
//  Created by Demigod on 02/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

#pragma mark - Color

+(UIImage *) changeImageColor:(UIImage *) image byMultiWithR:(CGFloat) red g:(CGFloat) green b:(CGFloat) blue a:(CGFloat)alpha{
    GPUMatrix4x4 colorMatrix = (GPUMatrix4x4){
        {red, 0, 0, 0},
        {0, green, 0, 0},
        {0, 0, blue ,0},
        {0, 0, 0, alpha},
    };
    
    GPUImagePicture *gpuImageBody = [[[GPUImagePicture alloc] initWithImage:image] autorelease];
    GPUImageColorMatrixFilter *colorFiler = [[[GPUImageColorMatrixFilter alloc] init] autorelease];
    colorFiler.colorMatrix = colorMatrix;
    [gpuImageBody addTarget:colorFiler];
    [gpuImageBody processImage];
    
    return colorFiler.imageFromCurrentlyProcessedOutput;
}

#pragma mark - Blend

+(UIImage *) overlayImage:(UIImage *) overlayImage overImage:(UIImage *) image{
    GPUImageNormalBlendFilter *blendFilter = [[[GPUImageNormalBlendFilter alloc] init] autorelease];
    GPUImagePicture *gpuImage = [[[GPUImagePicture alloc] initWithImage:image] autorelease];
    GPUImagePicture *gpuOverlayImage = [[[GPUImagePicture alloc] initWithImage:overlayImage] autorelease];
    
    
    [gpuImage addTarget:blendFilter];
    [gpuOverlayImage addTarget:blendFilter];
    
    [gpuImage processImage];
    [gpuOverlayImage processImage];
    
    return [blendFilter imageFromCurrentlyProcessedOutput];
}

+ (UIImage*) saveAnUIViewToImage: (UIView*) inputView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

+ (void)saveImage: (UIImage*)image {
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}


+ (UIImage*)loadImage {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"test.png"];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
