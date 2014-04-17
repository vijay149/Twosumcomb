//
//  LoginViewController.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACommon.h"
#import "MATextField.h"
#import "BaseViewController.h"
#import "MASubmitPopupView.h"
#import "MADataLoader.h"
@class MACheckBoxButton;

#define MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG 10
#define MANAPP_LOGIN_VIEW_OFFLINE_LOGIN_ALERT_TAG 100
#define MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_TEXTFIELD_TAG 11
#define MANAPP_LOGIN_VIEW_VERIFY_EMAIL_ALERT_TAG 12
#define MANAPP_LOGIN_VIEW_FORGOT_USERNAME_TEXTFIELD_TAG 13
#define MANAPP_LOGIN_VIEW_FORGOT_USERNAME_ALERT_TAG 14

@interface LoginViewController : BaseViewController <UITextFieldDelegate, UIAlertViewDelegate,MASubmitPopupViewDelegate>{

}

@property (retain, nonatomic) IBOutlet MATextField *txtUsername;
@property (retain, nonatomic) IBOutlet MATextField *txtPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnSignIn;
@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnForgotUsername;
@property (retain, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (retain, nonatomic) IBOutlet MACheckBoxButton *checkboxRememberMe;
@property (retain, nonatomic) IBOutlet UILabel *lblRememberMe;
@property (retain, nonatomic) IBOutlet UIButton *btnBackground;

- (IBAction)btnSignIn_touchUpInside:(id)sender;
- (IBAction)btnSignUp_touchUpInside:(id)sender;
- (IBAction)btnForgotPassword_touchUpInside:(id)sender;
- (IBAction)btnForgotUsername_touchUpInside:(id)sender;

@end
