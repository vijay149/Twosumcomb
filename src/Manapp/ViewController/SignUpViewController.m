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
#import "UITextField+Additional.h"
#import "UIView+Additions.h"

@interface SignUpViewController ()
-(void) loadUI;
-(void) resignAllTextField;
@end

@implementation SignUpViewController
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize txtUsername = _txtUsername;
@synthesize txtPassword = _txtPassword;
@synthesize txtRetypePassword = _txtRetypePassword;
@synthesize txtEmail = _txtEmail;
@synthesize btnSignUp = _btnSignUp;
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
    [self loadUI];
    
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
    [_lblGuide release];
    [_btnBackground release];
    [super dealloc];
}

#pragma mark - private function
//prepare the graphic and flags
-(void) loadUI{
    //prepare the UI
    [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:@selector(back)];
    [self moveNavigationButtonsToView:self.backgroundScrollView];
    //padding the textfield and set custom font
    [self.txtEmail paddingLeftByValue:5];
    [self.txtUsername paddingLeftByValue:5];
    [self.txtPassword paddingLeftByValue:5];
    [self.txtRetypePassword paddingLeftByValue:5];
    
    [self.txtPassword       setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.txtUsername       setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.txtEmail          setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.txtRetypePassword setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.lblGuide          setFont:[UIFont fontWithName:kAppFont size:9]];
    
    [self.btnSignUp.titleLabel setFont:[UIFont fontWithName:kAppFont size:12]];
}

-(void)resignAllTextField{
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtRetypePassword resignFirstResponder];
    [self.txtEmail resignFirstResponder];
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
        [self showMessage:LSSTRING(@"You must fill in all of the fields") title:kAppName cancelButtonTitle:@"OK"];
    }
    else{
        if(![passwordInput isEqualToString:passwordRetypeInput]){
            [self showMessage:LSSTRING(@"Password and Re-type Password not same") title:kAppName cancelButtonTitle:@"OK"];
        }
        else {
             //COMMENT: sent the data to APIHandler which help us to send request to server
            [self showWaitingHud];
             [[MANetworkHelper sharedHelper] signUpWithUsername:usernameInput password:passwordInput email:emailInput success:^(NSDictionary* responseDictionary){
             
                 // COMMENT: display alert view if the process is success
                 //COMMENT: get response data
                 NSNumber  *result = [responseDictionary objectForKey:kAPIStatus];
                 NSString  *message = [responseDictionary objectForKey:kAPIMessage];
                 NSNumber  *userId = [responseDictionary objectForKey:kAPISignUpUserId];
                 
                 if([result boolValue] && userId != NULL){
                     //COMMENT: display custom alertview
                     [self showMessage:LSSTRING(@"Your account has been created") title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_SIGNUP_VIEW_SUCCESSFULLY_ALERT_TAG];
                     
                     [[NSUserDefaults standardUserDefaults] setObject:userId forKey:MANAPP_DEFAULT_KEY_USER_ID];
                     [[MASession sharedSession] setUserID:[userId intValue]];
                     [[MASession sharedSession] setMaximumPartnerAllow:MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT_NOT_ACTIVE];
                     [[MASession sharedSession] setPassword:passwordInput];
                     [[MASession sharedSession] save];
                 }
                 else{
                     NSRange rangeOfSubstring = [[[message uppercaseString] uppercaseString] rangeOfString:[MANAPP_MESSAGE_FROM_SERVER_DUPLICATE_EMAIL uppercaseString]];
                     if(rangeOfSubstring.location != NSNotFound){
                         [self showMessage:LSSTRING(@"Your email already exist, you can use the forgot password feature to get your password renewed.") title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_SIGNUP_VIEW_DUPLICATE_EMAIL_ALERT_TAG];
                     }
                     else{
                         [self showMessage:message title:kAppName cancelButtonTitle:@"OK"];
                     }
                 }
                 
                 // COMMENT: close waiting view
                 [self hideWaitingHud];
             }fail:^(NSError *error) {
                 [self hideWaitingHud];
                 
                 [self showMessage:LSSTRING(@"There is an error with the server. We cannot process your request.") title:kAppName cancelButtonTitle:@"OK"];
             }];
            
        }
    }
}

#pragma mark - text field delegate + keyboard notification

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _currentResponseView = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:self.txtUsername]){
        [self.txtPassword becomeFirstResponder];
        [self scrollView:self.backgroundScrollView changeOffsetToView:self.txtPassword];
    }
    else if([textField isEqual:self.txtPassword]){
        [self.txtRetypePassword becomeFirstResponder];
        [self scrollView:self.backgroundScrollView changeOffsetToView:self.txtRetypePassword];
    }
    else if([textField isEqual:self.txtRetypePassword]){
        [self.txtEmail becomeFirstResponder];
        [self scrollView:self.backgroundScrollView changeOffsetToView:self.txtEmail];
    }
    else if([textField isEqual:self.txtEmail]){
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self.btnBackground setSize:self.backgroundScrollView.frame.size];
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:YES];
    
    [self scrollView:self.backgroundScrollView changeOffsetToView:_currentResponseView];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:YES];
    [self.btnBackground setSize:self.backgroundScrollView.frame.size];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == MANAPP_SIGNUP_VIEW_SUCCESSFULLY_ALERT_TAG){
        [self gotoNextView];
        /**
         *  Get messages from Server
         */
        
        [[MADataLoader ShareDataLoader] getMessagessListsFromServer];
    }
    else if(alertView.tag == MANAPP_SIGNUP_VIEW_DUPLICATE_EMAIL_ALERT_TAG){
        if(buttonIndex == 0){
            [self back];
        }
    }
}

- (void)gotoNextView
{
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    if (numberOfAvatar == 0) {
        [[MASession sharedSession] setCurrentPartner:nil];
        // Goto create partner view
        HomepageViewController *homeVC = NEW_VC(HomepageViewController);
        CreatePartnerViewController *createPartnerVC = NEW_VC(CreatePartnerViewController);
        [self.navigationController setViewControllers:@[self.navigationController.viewControllers[0], homeVC, createPartnerVC] animated:NO];
    }
    else{
        // Goto Home view
        HomepageViewController *vc = NEW_VC(HomepageViewController);
        [self nextTo:vc];
        
    }
}

@end
