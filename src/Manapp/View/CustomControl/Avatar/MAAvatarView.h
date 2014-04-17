//
//  MAAvatarView.h
//  TwoSum
//
//  Created by Demigod on 02/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface MAAvatarView : UIView

@property(nonatomic, strong) UIImageView *imgViewBody;
@property(nonatomic, strong) UIColor *bodyColor;

-(void) reload;
-(void)reloadWithSessionColor;

@end
