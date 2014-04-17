//
//  MASubmitPopupView.h
//  Manapp
//
//  Created by Demigod on 01/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MASubmitPopupView;

#define MA_SUBMIT_POPUP_KEYBOARD_MOVING_DISTANCE 90

@protocol MASubmitPopupViewDelegate

@optional
-(void) didTouchBackgroundOfSubmitPopupView:(MASubmitPopupView *) view;
-(void) submitPopupView:(MASubmitPopupView *) view submitWithText:(NSString *) text;
@end

@interface MASubmitPopupView : UIView{
    BOOL _didMoveUp;
    UIViewController *ownerController;
}

+(id) sharedInstance;

@property (strong, nonatomic) id<MASubmitPopupViewDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIView *viewPopup;
@property (retain, nonatomic) IBOutlet UILabel *lblMessage;
@property (retain, nonatomic) IBOutlet UILabel *lblFieldName;
@property (retain, nonatomic) IBOutlet UITextField *txtInput;
@property (retain, nonatomic) IBOutlet UIButton *btnSubmit;

-(void) showWithMessage:(NSString *) message inputName:(NSString *) inputName delegate:(id) delegate tag:(NSInteger)tag;
+(void) showMessage:(NSString *) message inputName:(NSString *) inputName delegate:(id) delegate tag:(NSInteger)tag;
- (IBAction)btnSubmit_touchUpInside:(id)sender;
- (IBAction)tapBackground:(id)sender;

- (void) show;
- (void) hide;

- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide;

@end
