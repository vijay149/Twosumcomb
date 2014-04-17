//
//  KOAProgressBar.h
//  KOAProgress
//
//  Created by Miroslav Perović on 7/5/12.
//  Copyright (c) 2012 KeepOnApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KOAProgressBar;

enum components {
	progressComponent,
	stripesComponent
};

@protocol KOAProgressBarDelegate

@optional
-(void) didTouchKOAProgressBar:(KOAProgressBar *) processBar;

@end

@interface KOAProgressBar : UIProgressView

@property (strong, nonatomic) IBOutlet id<KOAProgressBarDelegate> delegate;
@property (getter = isDisplayedWhenStopped) BOOL displayedWhenStopped;
@property (strong) UIColor *shadowColor;
@property (strong) UIColor *stripeColor;
@property float stripeWidth;
@property float inset;
@property float radius;
@property (readonly) float realProgress;
@property (strong) UIColor *progressBarColorBackground;
@property (strong) UIColor *progressBarColorBackgroundGlow;
@property (strong) UIColor *lighterProgressColor;
@property (strong) UIColor *darkerProgressColor;
@property (strong) UIColor *lighterStripeColor;
@property (strong) UIColor *darkerStripeColor;
@property float timerInterval;
@property float progressValue;

@property (readonly) float minValue;
@property (readonly) float maxValue;

- (void)setMinValue:(float)mValue;
- (void)setMaxValue:(float)mValue;
- (void)setRealProgress:(float)realProgress;

- (id)initWithFrame:(CGRect)frame duration:(float)duration;
- (void)setAnimationDuration:(float)duration;

- (void)startAnimation:(id)sender;
- (void)stopAnimation:(id)sender;

@end
