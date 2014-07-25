//
//  LoginViewController.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "LoginViewController.h"
#import "MASession.h"
#import "MACheckBoxButton.h"
#import "UITextField+Additional.h"
#import "MANetworkHelper.h"
#import "SignUpViewController.h"
#import "HomepageViewController.h"

@interface LoginViewController ()
-(void) initialize;
-(void) numberOfTimeLoginFail;
@end

@implementation LoginViewController
@synthesize checkboxRememberMe = _checkboxRememberMe;
@synthesize txtPassword = _txtPassword;
@synthesize txtUsername = _txtUsername;
@synthesize btnSignIn = _btnSignIn;
@synthesize btnForgotPassword = _btnForgotPassword;
@synthesize btnSignUp = _btnSignUp;
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize lblRememberMe = _lblRememberMe;

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
    
    [self initialize]; 
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // COMMENT: if application already saved user account then automatically go to the home page.
    BOOL isRememberMe = [[[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_ME] boolValue];
    if (isRememberMe) {
        [self.checkboxRememberMe setCheckWithState:isRememberMe];
        self.txtUsername.text = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
        self.txtPassword.text = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
        [self btnSignIn_touchUpInside:self];
    } else {
        [self.checkboxRememberMe setCheckWithState:isRememberMe];
        self.txtUsername.text = @"";
        self.txtPassword.text = @"";
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_txtUsername release];
    [_txtPassword release];
    [_btnSignIn release];
    [_btnSignUp release];
    [_btnForgotPassword release];
    [_backgroundScrollView release];
    [_checkboxRememberMe release];
    [_lblRememberMe release];
    [super dealloc];
}

#pragma mark - private function
//prepare the graphic and flags
-(void) initialize{
    //prepare the UI
    //padding the textfield
    [self.txtPassword paddingLeftByValue:10];
    [self.txtUsername paddingLeftByValue:10];
    
    [self.txtUsername setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtPassword setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.lblRememberMe setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    
    //remember me checkbox
    self.checkboxRememberMe = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(157, 344, 34, 30) checkStateImage:[UIImage imageNamed:@"btnCheck"] unCheckStateImage:[UIImage imageNamed:@"btnUnCheck"]];
    [self.backgroundScrollView addSubview:self.checkboxRememberMe];
}

#pragma mark - event handler
- (IBAction)btnSignIn_touchUpInside:(id)sender {
    //hide the keyboard
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    // check if user was blocked because failed to login too many time
    NSDate* timeUntilLoginAgain = [[NSUserDefaults standardUserDefaults] objectForKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
    if(timeUntilLoginAgain){
        if([timeUntilLoginAgain compare:[NSDate date]] == NSOrderedDescending){
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit;
            NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                                fromDate:[NSDate date]
                                                                  toDate:timeUntilLoginAgain
                                                                 options:0];
            
            [self showMessage:[NSString stringWithFormat:@"You are currently blocked because you failed to login too many time. Please wait for %d hour, %d minutes, %d seconds until you can login again",[components hour],[components minute],[components second]]];
            return;
        }
    }
    
    //user touch the login button
    
    //show the loading view
    [self showWaitingHud];
    
    //send request to login
    // COMMENT: get user input and generate an url for request
    NSString* userInput = self.txtUsername.text;
    NSString* passInput = self.txtPassword.text;
    
    [[MANetworkHelper sharedHelper] loginWithUserName:userInput passWord:passInput success:^(NSDictionary* resultDictionary){
        //get suggest flag
        NSNumber *loginResult = [resultDictionary objectForKey:@"success"];
        //get userId
        NSNumber *userId = [resultDictionary objectForKey:@"userId"];
        
        // COMMENT: if login successfully
        if([loginResult boolValue] && userId != NULL)
        {
            // save the login information if rememberme was checked
            [[NSUserDefaults standardUserDefaults] setValue:self.checkboxRememberMe.isChecked?@"1":@"0" forKey:MANAPP_DEFAULT_KEY_REMEMBER_ME];
            if (self.checkboxRememberMe.isChecked) {
                [[NSUserDefaults standardUserDefaults] setValue:self.txtUsername.text forKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
                [[NSUserDefaults standardUserDefaults] setValue:self.txtPassword.text forKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
            } else {
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
            }
            
            // COMMENT: save user id to a global variable and session
            NSString* token = [resultDictionary objectForKey:@"token"];
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:MANAPP_DEFAULT_KEY_USER_TOKEN];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:MANAPP_DEFAULT_KEY_USER_ID];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //session
            [[MASession sharedSession] setUserID:[userId intValue]];
            [[MASession sharedSession] setUserToken:token];
            
            
            //reset the number of time login fail
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
            
            // COMMENT: go to home page
            [self pushViewControllerByName:@"HomepageViewController"];
        }
        else
        {
            // COMMENT: fail to sign in
            //punish for fail to login too many time
            [self numberOfTimeLoginFail];
            NSNumber *numberOfTimeLoginFail = [[NSUserDefaults standardUserDefaults] objectForKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
            
            if(!numberOfTimeLoginFail || [numberOfTimeLoginFail intValue] < 3){
                // COMMENT: fail to sign in
                [self showMessage:@"Sorry your username and password don't match" title:@"MANAPP" cancelButtonTitle:@"OK"];
                self.txtUsername.text = @"";
                self.txtPassword.text = @"";
            }
        }
        
        //hide the waiting hud
        [self hideWaitingHud];
    }fail:^(NSError* error){
        DLog(@"%@",error);
        
        //hide the waiting hud
        [self hideWaitingHud];
        
        [self showMessage:@"There is an error with the server. We cannot process your request." title:@"MANAPP" cancelButtonTitle:@"OK"];
    }];

}

- (IBAction)btnSignUp_touchUpInside:(id)sender {
    [self pushViewControllerByName:@"SignUpViewController"];
}

- (IBAction)btnForgotPassword_touchUpInside:(id)sender {
    //the field to inout email
    UITextField *txtForgotPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    [txtForgotPassword setBackgroundColor:[UIColor whiteColor]];
    txtForgotPassword.tag = MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_TEXTFIELD_TAG;
    txtForgotPassword.borderStyle = UITextBorderStyleRoundedRect;
    
    NSMutableArray *subcontrols = [[[NSMutableArray alloc] init] autorelease];
    [subcontrols addObject:txtForgotPassword];
    
    [self showMessage:@"\n\nPlease input your username or email to verify that you are the owner of this account." title:@"Forgot your password?" cancelButtonTitle:@"Cancel" otherButtonTitle:@"Send" delegate:self tag:MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG subControls:subcontrols];
}

#pragma mark - private function
//check the number of time login fail, depend on the fail number, the user have to wait for a period of time
-(void) numberOfTimeLoginFail{
    // get number of time user logined
    NSNumber *numberOfTimeLoginFail = [[NSUserDefaults standardUserDefaults] objectForKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
    
    // if this is the first time fail
    if(!numberOfTimeLoginFail){
        numberOfTimeLoginFail = [NSNumber numberWithInt:1];
        [[NSUserDefaults standardUserDefaults] setObject:numberOfTimeLoginFail forKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
    }
    else{
        numberOfTimeLoginFail = [NSNumber numberWithInt:([numberOfTimeLoginFail intValue] + 1)];
        [[NSUserDefaults standardUserDefaults] setObject:numberOfTimeLoginFail forKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
    }
    
    //show alert if fail to login more than 3 times
    if([numberOfTimeLoginFail intValue] >= 3 && [numberOfTimeLoginFail intValue] < 6){
        [self showMessage:@"If you don't remember your password, please select 'Forgot password' to renew your password."];
    }
    //user have to wait after 6 times fail to login
    else if([numberOfTimeLoginFail intValue] >= 6){
        // if user failed to login more than 6 times, we need to stop user from login for a period of time
        switch ([numberOfTimeLoginFail intValue]) {
            case 6:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:60];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:@"You failed to login to many time, you will be block for one minute."];
            }
                break;
            case 7:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:2*60];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:@"You failed to login to many time, you will be block for two minute."];
            }
                break;
            default:
                break;
        }
    }

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
    // COMMENT: if this alertview is the forget password view
    if(alertView.tag == MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG)
    {
        if(buttonIndex == 0){
            DLog(@"Cancel button clicked");
        }
        else {
            //get the textfield
            UITextField *txtForgotPassword = (UITextField *)[alertView viewWithTag:MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_TEXTFIELD_TAG];
            if(txtForgotPassword){
                // COMMENT: display waiting screen
                [self showWaitingHud];
                
                // COMMENT: send changing password request
                [[MANetworkHelper sharedHelper] requestNewPasswordAtMail:txtForgotPassword.text success:^(NSDictionary* resultDictionary){
                    NSNumber* requestResult = [resultDictionary objectForKey:@"success"];
                    if([requestResult boolValue])
                    {
                        NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                        [self showMessage:responseMessage title:@"MANAPP" cancelButtonTitle:@"OK"];
                    }
                    else
                    {
                        NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                        [self showMessage:responseMessage title:@"MANAPP" cancelButtonTitle:@"OK"];
                    }
                    [self hideWaitingHud];
                }fail:^(NSError *error) {
                    DLog(@"%@",error);
                    [self hideWaitingHud];
                    
                    [self showMessage:@"There is an error with the server. We cannot process your request." title:@"MANAPP" cancelButtonTitle:@"OK"];
                }];
            }
        }
    }
}


@end
