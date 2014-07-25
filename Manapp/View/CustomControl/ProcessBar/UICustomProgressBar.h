//This class represent the process bar which display the completion percentage of a process

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UICustomProgressBar : UIView
{
@private
    CGFloat maxValue;
    CGFloat currentValue;
    
    CALayer* progressLayer;
}
-(id) initWithBackgroundImage:(UIImage*)_bgImg progressImage:(UIImage*)_progressImg progressMask:(UIImage*)_progressMaskImg insets:(CGSize)barInset;;

@property (nonatomic) CGFloat currentValue;
@property (nonatomic) CGFloat maxValue;

@end

