//
//  HelpViewController.h
//  Manapp
//
//  Created by Demigod on 02/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "UIViewController+SlideTransitions.h"

@interface HelpViewController : BaseViewController<UIScrollViewDelegate>{
    UIImageView *currentImageView;
    NSInteger _currentPhotoIndex;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollAvatar;



@end
