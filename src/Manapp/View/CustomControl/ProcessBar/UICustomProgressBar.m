//
//  UICustomProgressBar.m
//  ManAppFirstVersion
//
//  Created by viet on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UICustomProgressBar.h"
#import "UIImage+Additions.h"

@implementation UICustomProgressBar

@synthesize currentValue, maxValue;

-(void) dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        maxValue = 100.0f;
    }
    return self;
}

-(id) initWithBackgroundImage:(UIImage*)_bgImg progressImage:(UIImage*)_progressImg progressMask:(UIImage*)_progressMaskImg insets:(CGSize)barInset;
{
    if(self = [super initWithFrame:CGRectMake(0, 0, _bgImg.size.width, _bgImg.size.height)])
    {
        // add mask to image to make it transparent (only the part we need)
        CALayer* maskLayer = [[[CALayer alloc] init] autorelease];
        maskLayer.frame = CGRectMake(barInset.width, barInset.height, _progressMaskImg.size.width, _progressMaskImg.size.height);
        maskLayer.contents = (id)_progressMaskImg.CGImage;
        self.layer.mask = maskLayer;
        
        // making background layer;
        CALayer* bgLayer = [[CALayer alloc] init];
        bgLayer.frame = self.bounds;
        bgLayer.contents = (id)_bgImg.CGImage;
        [self.layer addSublayer:bgLayer];
        [bgLayer release];
        
        progressLayer = [[[CALayer alloc] init] autorelease];
        progressLayer.frame = CGRectMake(barInset.width, barInset.height, _progressImg.size.width, _progressImg.size.height);
        progressLayer.contents = (id)_progressImg.CGImage;
        
        [self.layer addSublayer:progressLayer];
        
    }
    return self;
}

-(id) initWithBackgroundImage:(UIImage*)_bgImg progressImage:(UIImage*)_progressImg progressMask:(UIImage*)_progressMaskImg insets:(CGSize)barInset barWidth:(NSInteger)width{
    CGFloat ratio = (CGFloat)width / _progressImg.size.width;

    _bgImg = [_bgImg resizeByRatioX:ratio];
    _progressImg = [_progressImg resizeByRatioX:ratio];
    _progressMaskImg = [_progressMaskImg resizeByRatioX:ratio];
    
    if(self = [super initWithFrame:CGRectMake(0, 0, _bgImg.size.width, _bgImg.size.height)])
    {
        // add mask to image to make it transparent (only the part we need)
        CALayer* maskLayer = [[[CALayer alloc] init] autorelease];
        maskLayer.frame = CGRectMake(barInset.width, barInset.height, _progressMaskImg.size.width, _progressMaskImg.size.height);
        maskLayer.contents = (id)_progressMaskImg.CGImage;
        self.layer.mask = maskLayer;
        
        // making background layer;
        CALayer* bgLayer = [[CALayer alloc] init];
        bgLayer.frame = self.bounds;
        bgLayer.contents = (id)_bgImg.CGImage;
        [self.layer addSublayer:bgLayer];
        [bgLayer release];
        
        progressLayer = [[[CALayer alloc] init] autorelease];
        progressLayer.frame = CGRectMake(barInset.width, barInset.height, _progressImg.size.width, _progressImg.size.height);
        progressLayer.contents = (id)_progressImg.CGImage;
        
        [self.layer addSublayer:progressLayer];
        
    }
    return self;
}

-(void) setCurrentValue:(CGFloat)val
{
    currentValue = val;
    // calculate progressLayerPosition depends on currentValue Here
    CGRect f = progressLayer.frame;
    f.origin.x = f.size.width / maxValue * currentValue - f.size.width;
    progressLayer.frame = f;
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
