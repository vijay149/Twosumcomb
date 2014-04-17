//
//  MAChangePasswordPopupView.h
//  TwoSum
//
//  Created by Duong Van Dinh on 9/20/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
@protocol MAChangePasswordPopupViewDelegate;
@interface MAChangePasswordPopupView : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate> {

}
- (void)presentWithSuperview:(UIView *)superview;
- (void)removeFromSuperviewWithAnimation;

@property (nonatomic, assign) id <MAChangePasswordPopupViewDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIButton *btnChangePassword;
@property (retain, nonatomic) IBOutlet UIView *viewFormChangePassword;
@property (retain, nonatomic) IBOutlet UILabel *lblCurrentPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (retain, nonatomic) IBOutlet UILabel *lblNewPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtCurrentPassword;
@property (retain, nonatomic) IBOutlet UILabel *lblConfirmPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewChangePassword;
- (IBAction)btnDone:(id)sender;
- (IBAction)btnCancel:(id)sender;
@end

@protocol MAChangePasswordPopupViewDelegate
- (void) changePasswordDidFinish:(MAChangePasswordPopupView *)controller;
- (void) changePassword:(NSString *)currentPassowrd newPassword:(NSString*) newPassword confirmPassword:(NSString*) confirmPassword;
@end