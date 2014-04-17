//
//  MACheckBoxButton.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MACheckBoxButton.h"

@implementation MACheckBoxButton
@synthesize isChecked = _isChecked;
@synthesize imageStateChecked = _imageStateChecked;
@synthesize imageStateUnChecked = _imageStateUnChecked;
@synthesize isAllowToggle = _isAllowToggle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isChecked = FALSE;
        self.isAllowToggle = TRUE;
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame checkStateImage:(UIImage*) stateCheckedImage unCheckStateImage:(UIImage*) stateUnCheckedImage{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _isChecked = FALSE;
        self.isAllowToggle = TRUE;
        self.imageStateUnChecked = stateUnCheckedImage;
        self.imageStateChecked = stateCheckedImage;
        [self setCheckWithState:NO];
        
        [self addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - event handler
//toggle the button
-(void)toggleCheckBox{
    if(self.isAllowToggle){
        [self setCheckWithState:!self.isChecked];
    }
    else{
        if(!self.isChecked){
            [self setCheckWithState:!self.isChecked];
        }
    }
}

//change the state and the image of the check box when touched
-(void) setCheckWithState:(BOOL) checkState{
    if(checkState){
        self.isChecked = checkState;
        [self setBackgroundImage:self.imageStateChecked forState:UIControlStateNormal];
        [self setBackgroundImage:self.imageStateChecked forState:UIControlStateHighlighted];
    }
    else{
        self.isChecked = checkState;
        [self setBackgroundImage:self.imageStateUnChecked forState:UIControlStateNormal];
        [self setBackgroundImage:self.imageStateUnChecked forState:UIControlStateHighlighted];
    }
}

//function which will be call when click the button
-(void) check:(id)sender{
    [self toggleCheckBox];
}

@end
