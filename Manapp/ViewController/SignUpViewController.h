//
//  SignUpViewController.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACommon.h"
#import "BaseViewController.h"

#define MANAPP_SIGNUP_VIEW_SUCCESSFULLY_ALERT_TAG 10
#define MANAPP_SIGNUP_VIEW_DUPLICATE_EMAIL_ALERT_TAG 11

@interface SignUpViewController : BaseViewController<UITextFieldDelegate, UIAlertViewDelegate>{
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (retain, nonatomic) IBOutlet UITextField *txtUsername;
@property (retain, nonatomic) IBOutlet UITextField *txtPassword;
@property (retain, nonatomic) IBOutlet UITextField *txtRetypePassword;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnSignUp;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UILabel *lblGuide;

- (IBAction)btnSignUp_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;

@end
