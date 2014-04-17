//
//  MACheckBoxButton.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MACheckBoxButton : UIButton{
    BOOL _isChecked;
}

@property BOOL isChecked;
@property BOOL isAllowToggle;
@property (nonatomic, retain) UIImage *imageStateChecked;
@property (nonatomic, retain) UIImage *imageStateUnChecked;

-(id) initWithFrame:(CGRect)frame checkStateImage:(UIImage*) stateCheckedImage unCheckStateImage:(UIImage*) stateUnCheckedImage;

-(void) toggleCheckBox;
-(void) setCheckWithState:(BOOL) checkState;
-(void) check:(id)sender;
@end
