//
//  SignUpViewController.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "SignUpViewController.h"
#import "UITextField+Additional.h"
#import "MANetworkHelper.h"
#import "HomepageViewController.h"
#import "MASession.h"

@interface SignUpViewController ()
-(void) initialize;
@end

@implementation SignUpViewController
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize txtUsername = _txtUsername;
@synthesize txtPassword = _txtPassword;
@synthesize txtRetypePassword = _txtRetypePassword;
@synthesize txtEmail = _txtEmail;
@synthesize btnSignUp = _btnSignUp;
@synthesize btnBack = _btnBack;
@synthesize lblGuide = _lblGuide;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare UI
    [self initialize];
    
    //gesture
    [self addSwipeBackGesture];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundScrollView release];
    [_txtUsername release];
    [_txtPassword release];
    [_txtRetypePassword release];
    [_txtEmail release];
    [_btnSignUp release];
    [_btnBack release];
    [_lblGuide release];
    [super dealloc];
}

#pragma mark - private function
//prepare the graphic and flags
-(void) initialize{
    //prepare the UI
    //padding the textfield and set custom font
    [self.txtEmail paddingLeftByValue:10];
    [self.txtUsername paddingLeftByValue:10];
    [self.txtPassword paddingLeftByValue:10];
    [self.txtRetypePassword paddingLeftByValue:10];
    
    [self.txtUsername setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtPassword setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtEmail setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtRetypePassword setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.lblGuide setFont:[UIFont fontWithName:@"BankGothic Md BT" size:10]];
}

#pragma mark - event handler
- (IBAction)btnSignUp_touchUpInside:(id)sender {
    NSString* usernameInput = self.txtUsername.text;
    NSString* passwordInput = self.txtPassword.text;
    NSString* passwordRetypeInput = self.txtRetypePassword.text;
    NSString* emailInput = self.txtEmail.text;
    
    // COMMENT: check if input information is valid or not
    if([usernameInput isEqualToString:@""] || [passwordInput isEqualToString:@""]|| [passwordRetypeInput isEqualToString:@""] || [emailInput isEqualToString:@""])
    {
        [self showMessage:@"You must fill in all of the fields" title:@"MANAPP" cancelButtonTitle:@"OK"];
    }
    else{
        if(![passwordInput isEqualToString:passwordRetypeInput]){
            [self showMessage:@"Password and Re-type Password not same" title:@"MANAPP" cancelButtonTitle:@"OK"];
        }
        else {
             //COMMENT: sent the data to APIHandler which help us to send request to server
            [self showWaitingHud];
             [[MANetworkHelper sharedHelper] signUpWithUsername:usernameInput password:passwordInput email:emailInput success:^(NSDictionary* responseDictionary){
             
                 // COMMENT: display alert view if the process is success
                 //COMMENT: get response data
                 NSNumber* result = [responseDictionary objectForKey:@"success"];
                 NSString* message = [responseDictionary objectForKey:@"message"];
                 NSNumber *userId = [responseDictionary objectForKey:@"userId"];
                 
                 if([result boolValue] && userId != NULL){
                     //COMMENT: display custom alertview
                     [self showMessage:@"Your account has been created" title:@"MANAPP" cancelButtonTitle:@"OK" delegate:self tag:MANAPP_SIGNUP_VIEW_SUCCESSFULLY_ALERT_TAG];
                     
                     [[NSUserDefaults standardUserDefaults] setObject:userId forKey:MANAPP_DEFAULT_KEY_USER_ID];
                     [[MASession sharedSession] setUserID:[userId intValue]];
                 }
                 else{
                     NSRange rangeOfSubstring = [[[message uppercaseString] uppercaseString] rangeOfString:[MANAPP_MESSAGE_FROM_SERVER_DUPLICATE_EMAIL uppercaseString]];
                     if(rangeOfSubstring.location != NSNotFound){
                         [self showMessage:@"Your email already exist, you can use the forgot password feature to get your password renewed." title:@"MANAPP" cancelButtonTitle:@"Back to homepage" otherButtonTitle:@"Stay here" delegate:self tag:MANAPP_SIGNUP_VIEW_DUPLICATE_EMAIL_ALERT_TAG];
                     }
                     else{
                         [self showMessage:message title:@"MANAPP" cancelButtonTitle:@"OK"];
                     }
                 }
                 
                 // COMMENT: close waiting view
                 [self hideWaitingHud];
             }fail:^(NSError *error) {
                 DLog(@"%@",error);
                 [self hideWaitingHud];
                 
                 [self showMessage:@"There is an error with the server. We cannot process your request." title:@"MANAPP" cancelButtonTitle:@"OK"];
             }];
             
        }
    }
}

- (IBAction)btnBack_touchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - text field delegate + keyboard notification

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:YES];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:YES];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == MANAPP_SIGNUP_VIEW_SUCCESSFULLY_ALERT_TAG){
        [self pushViewControllerByName:@"HomepageViewController"];
    }
    else if(alertView.tag == MANAPP_SIGNUP_VIEW_DUPLICATE_EMAIL_ALERT_TAG){
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
