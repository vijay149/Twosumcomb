//
//  MAChangeEmailPopupView.h
//  TwoSum
//
//  Created by Duong Van Dinh on 9/20/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BSKeyboardControls.h"
@protocol MAChangeEmailPopupViewDelegate;
@interface MAChangeEmailPopupView : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate> {
    
}
- (void)presentWithSuperview:(UIView *)superview;
- (void)removeFromSuperviewWithAnimation;

@property (nonatomic, assign) id <MAChangeEmailPopupViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITextField *txtCurrentPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtNewEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnSubmit;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UILabel *lblNewEmail;
@property (retain, nonatomic) IBOutlet UILabel *lblCurrentPassword;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewChangeEmail;
@property (retain, nonatomic) IBOutlet UILabel *lblChangeEmailForm;


@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

- (IBAction)btnDone:(id)sender;
- (IBAction)btnCancel:(id)sender;
@end

@protocol MAChangeEmailPopupViewDelegate
- (void) changeEmailDidFinish:(MAChangeEmailPopupView *)controller;
- (void) changeEmail:(NSString *)currentPassowrd newEmail:(NSString*) newEmail;
@end