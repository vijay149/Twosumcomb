//
//  LoginViewController.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACommon.h"
#import "BaseViewController.h"

@class MACheckBoxButton;

#define MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG 10
#define MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_TEXTFIELD_TAG 11

@interface LoginViewController : BaseViewController <UITextFieldDelegate, UIAlertViewDelegate>{

}

@property (retain, nonatomic) IBOutlet UITextField *txtUsername;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnSignIn;
@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (retain, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (retain, nonatomic) IBOutlet MACheckBoxButton *checkboxRememberMe;
@property (retain, nonatomic) IBOutlet UILabel *lblRememberMe;

- (IBAction)btnSignIn_touchUpInside:(id)sender;
- (IBAction)btnSignUp_touchUpInside:(id)sender;
- (IBAction)btnForgotPassword_touchUpInside:(id)sender;

@end
