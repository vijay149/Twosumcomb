//
//  MASubmitPopupView.m
//  Manapp
//
//  Created by Demigod on 01/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MASubmitPopupView.h"
#import "UITextField+Additional.h"
#import "UIView+Additions.h"
#import "UILabel+Additions.h"
#import "BaseViewController.h"
#import "MAAppDelegate.h"
#import "UIView+Additions.h"

@implementation MASubmitPopupView

+(id)sharedInstance{
    static MASubmitPopupView* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [(MASubmitPopupView *)[Util getView:[MASubmitPopupView class]] retain];
    });
    
    return instance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _didMoveUp = FALSE;
    }
    return self;
}

#pragma mark - static functions
+(void) showMessage:(NSString *) message inputName:(NSString *) inputName delegate:(id) delegate tag:(NSInteger)tag{
    [[MASubmitPopupView sharedInstance] showWithMessage:message inputName:inputName delegate:delegate tag:tag];
}
#pragma mark - functions

-(void) showWithMessage:(NSString *) message inputName:(NSString *) inputName delegate:(id) delegate tag:(NSInteger)tag{
    self.lblMessage.text = message;
    self.lblFieldName.text = inputName;
    self.txtInput.delegate = delegate;
    self.delegate = delegate;
    self.tag = tag;
    [self show];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    
    //change font
    [self.lblFieldName setFont:[UIFont fontWithName:@"AppleGothic" size:13]];
    [self.lblMessage setFont:[UIFont fontWithName:@"AppleGothic" size:13]];
    [self.btnSubmit.titleLabel setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.txtInput setFont:[UIFont fontWithName:@"AppleGothic" size:14]];
    
    //change size
    [self.lblMessage changeSizeToMatchText:self.lblMessage.text allowWidthChange:NO];
    
    [self.lblFieldName moveToBelowView:self.lblMessage withPadding:10];
    [self.txtInput moveToBelowView:self.lblFieldName withPadding:5];
    [self.btnSubmit moveToBelowView:self.txtInput withPadding:5];
    
    //change the container size
    CGFloat marginBottom = 10;                          // margin with the bottom of the alert
    CGFloat different = self.btnSubmit.frame.size.height + self.btnSubmit.frame.origin.y + marginBottom - self.viewPopup.frame.size.height;
    if(different > 0){
        [self.viewPopup setHeight:self.viewPopup.frame.size.height + different];
    }
    else{
        [self.viewPopup setHeight:self.btnSubmit.frame.size.height + self.btnSubmit.frame.origin.y+ marginBottom];
    }
    
    if(IS_IPHONE_5){
        self.viewPopup.center = self.center;
    }
}

- (void)dealloc {
    [_viewPopup release];
    [_lblMessage release];
    [_lblFieldName release];
    [_txtInput release];
    [_btnSubmit release];
    [super dealloc];
}

#pragma mark - public view controller
-(void)show{
    [self setOriginX:-self.frame.size.width];
    MAAppDelegate* appDelegate = (MAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:self];
    
    //notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setOriginX:0];
    } completion:^(BOOL finished) {}];
}

-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        [self setOriginX:-self.frame.size.width];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
        
    }];
}

#pragma mark - event handler
- (IBAction)btnSubmit_touchUpInside:(id)sender {
    [self.delegate submitPopupView:self submitWithText:self.txtInput.text];
    [self hide];
}

- (IBAction)tapBackground:(id)sender {
    [self.delegate didTouchBackgroundOfSubmitPopupView:self];
    [self hide];
}

#pragma mark - notification handler
- (void)keyboardWillShow:(NSNotification*)notification{
    if(!_didMoveUp){
        _didMoveUp = TRUE;
        [UIView animateWithDuration:0.2 animations:^{
            [self.viewPopup setOriginY:self.viewPopup.frame.origin.y - MA_SUBMIT_POPUP_KEYBOARD_MOVING_DISTANCE];
        } completion:^(BOOL finished) {}];
    }
}

- (void)keyboardWillHide{
    if(_didMoveUp){
        _didMoveUp = FALSE;
        [UIView animateWithDuration:0.2 animations:^{
            [self.viewPopup setOriginY:self.viewPopup.frame.origin.y + MA_SUBMIT_POPUP_KEYBOARD_MOVING_DISTANCE];
        } completion:^(BOOL finished) {}];
    }
}
@end
