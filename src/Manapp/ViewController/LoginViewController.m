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
#import "MACommon.h"
#import "UIView+Additions.h"
#import "NSDate+Helper.h"
#import "MADeviceUtil.h"
#import "MessageDTO.h"
#import "Message.h"
#import "DatabaseHelper.h"
#import "AFJSONUtilities.h"
#import "GCDispatch.h"
#import "CreatePartnerViewController.h"

@interface LoginViewController ()
-(void) initialize;
-(void) loadUI;
-(void) numberOfTimeLoginFail;
- (void) saveMesssageDTOFromDictionary:(NSDictionary*) resultDictionary isFromActionException:(BOOL) isFromActionException withsuccess:(void(^)(BOOL)) hasData;
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


- (void)dealloc {
    [_txtUsername release];
    [_txtPassword release];
    [_btnSignIn release];
    [_btnSignUp release];
    [_btnForgotPassword release];
    [_backgroundScrollView release];
    [_checkboxRememberMe release];
    [_lblRememberMe release];
    [_btnBackground release];
    [_btnForgotUsername release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUI];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self fillUIWithData];
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


#pragma mark - private function
//init
-(void) initialize{
    
}

-(void)resignAllTextField{
    [self.txtPassword resignFirstResponder];
    [self.txtUsername resignFirstResponder];
}

#pragma mark - UI functions
//fill data to UI
-(void) fillUIWithData{
    // COMMENT: if application already saved user account then automatically go to the home page.
    BOOL isRememberMe = [MASession sharedSession].rememberMe;
    if (isRememberMe) {
        [self.checkboxRememberMe setCheckWithState:isRememberMe];
        self.txtUsername.text = [MASession sharedSession].username;
        self.txtPassword.text = [MASession sharedSession].password;
        [self goToHomePage];
//        [self btnSignIn_touchUpInside:self];
    } else {
        [self.checkboxRememberMe setCheckWithState:isRememberMe];
        self.txtUsername.text = @"";
        self.txtPassword.text = @"";
    }
}

//prepare the graphic and flags
-(void)loadUI{
    //prepare the UI
    //padding the textfield
    [self.txtUsername changePadding:CGSizeMake(10, 2)];
    [self.txtPassword changePadding:CGSizeMake(10, 2)];
    
//    [self.txtUsername setFont:[UIFont fontWithName:kAppFont size:14]];
//    [self.txtPassword setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.txtPassword setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.txtUsername setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.lblRememberMe setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.btnForgotPassword.titleLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    [self.btnForgotUsername.titleLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    [self.btnSignIn.titleLabel setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.btnSignUp.titleLabel setFont:[UIFont fontWithName:kAppFont size:14]];
    
    //remember me checkbox
    _checkboxRememberMe = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(157, 380, 24, 23) checkStateImage:[UIImage imageNamed:@"btnLoginCheck"] unCheckStateImage:[UIImage imageNamed:@"btnLoginUncheck"]];
    [self.backgroundScrollView addSubview:self.checkboxRememberMe];
}

//handle when login without internet connection
- (void)offlineLogin{
    [[MASession sharedSession] load];
    
    //make sure there is a data for offline login
    if([MASession sharedSession].userID > 0 && ![[MASession sharedSession].userToken isEqualToString:@""]){
        [self showMessage:@"Your internet connection isn't available but you can still login to the app using the previous account which was saved into the device. Do you want to login using that account? " title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"cancel" delegate:self tag:MANAPP_LOGIN_VIEW_OFFLINE_LOGIN_ALERT_TAG];
    }
    else{
        [self showMessage:@"The internet connection isn't available!"];
    }
}

//handle login with internet connection
- (void)login{
    //hide the keyboard
    [self resignAllTextField];
    
    // check if user was blocked because failed to login too many time
    NSDate* timeUntilLoginAgain = [[NSUserDefaults standardUserDefaults] objectForKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
    if(timeUntilLoginAgain){
        if([timeUntilLoginAgain compare:[NSDate date]] == NSOrderedDescending){
            
            NSDateComponents *components = [NSDate hourComponentsBetweenDate:[NSDate date] andDate:timeUntilLoginAgain];
            
            [self showMessage:[NSString stringWithFormat:Translate(@"You are currently blocked because you failed to login too many time. Please wait for %d hour, %d minutes, %d seconds until you can login again"),[components hour],[components minute],[components second]]];
            return;
        }
    }
    
    //show the loading view
    [self showWaitingHud];
    
    //send request to login
    // COMMENT: get user input and generate an url for request
    NSString* userInput = self.txtUsername.text;
    NSString* passInput = self.txtPassword.text;
    
    [[MANetworkHelper sharedHelper] loginWithUserName:userInput passWord:passInput success:^(NSDictionary* resultDictionary){
        //get suggest flag
        NSNumber *loginResult = [resultDictionary objectForKey:kAPIStatus];
        //get userId
        NSNumber *userId = [resultDictionary objectForKey:kAPILoginUserId];
        //get user status ( to check if this user is actived or not)
        NSNumber *userStatus = [resultDictionary objectForKey:kAPILoginUserState];
        
        // COMMENT: if login successfully
        if([loginResult boolValue] && userId != NULL)
        {
            // save the login information if rememberme was checked
            [MASession sharedSession].rememberMe = self.checkboxRememberMe.isChecked;
//            if (self.checkboxRememberMe.isChecked) {
//                [MASession sharedSession].username = self.txtUsername.text;
//                [MASession sharedSession].password = self.txtPassword.text;
//
//            } else {
//                [MASession sharedSession].username = @"";
//                [MASession sharedSession].password = @"";
//            }
            
            // always store infor username and password. to use check global app.
            [MASession sharedSession].username = self.txtUsername.text;
            [MASession sharedSession].password = self.txtPassword.text;
            // COMMENT: save user id to a global variable and session
            NSString* token = [resultDictionary objectForKey:kAPILoginToken];
            [MASession sharedSession].userToken = token;
            [MASession sharedSession].userID = userId.integerValue;
            
            //if this user is active, set his maximum number of partner to 1, otherwise it is 2
            if(userStatus.intValue == 1){
                [[MASession sharedSession] setMaximumPartnerAllow:MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT];
            }
            else{
                [[MASession sharedSession] setMaximumPartnerAllow:MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT_NOT_ACTIVE];
            }
            
            [[MASession sharedSession] save];
            
            //reset the number of time login fail
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
            
            //check if user is active or not, if not, show the message to allow user to resend the email
            if(userStatus.intValue == 1){
                // COMMENT: go to home page
                [self goToHomePage];
            }
            else{
                [self showMessage:@"Your Email address is unverified, without a verified email address you wont be able to create a 2nd partner, click the OK to resend the verification email and then check your email" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_LOGIN_VIEW_VERIFY_EMAIL_ALERT_TAG];
            }
            
        }
        else
        {
            // COMMENT: fail to sign in
            //punish for fail to login too many time
            [self numberOfTimeLoginFail];
            NSNumber *numberOfTimeLoginFail = [[NSUserDefaults standardUserDefaults] objectForKey:MANAPP_DEFAULT_KEY_NUMBER_TIME_LOGIN_FAIL];
            
            if(!numberOfTimeLoginFail || [numberOfTimeLoginFail intValue] < 3){
                // COMMENT: fail to sign in
                [self showMessage:LSSTRING(@"Username or Password is incorrrect") title:kAppName cancelButtonTitle:@"OK"];
                self.txtPassword.text = @"";
            }
        }
        
        //hide the waiting hud
        [self hideWaitingHud];
    }fail:^(NSError* error){
        DLog(@"%@",error);
        
        //hide the waiting hud
        [self hideWaitingHud];
        
        [self showMessage:LSSTRING(@"There is an error with the server. We cannot process your request.") title:kAppName cancelButtonTitle:@"OK"];
    }];
}

//saveMesssageDTOFromDictionary using when login sync message from server.
- (void) saveMesssageDTOFromDictionary:(NSDictionary*) resultDictionary isFromActionException:(BOOL) isFromActionException withsuccess:(void(^)(BOOL))hasData {
    NSNumber *result = [resultDictionary objectForKey:kAPIStatus];
    if([result boolValue]){
        NSArray *messageData = [resultDictionary objectForKey:@"attr"];
        if(messageData && [messageData isKindOfClass:[NSArray class]]){
            int count = 0;
            for(NSString *messageString in messageData){
                count++;
                DLog(@"background message count: %d",count);
                NSDictionary* messageDict = AFJSONDecode([messageString dataUsingEncoding:NSUTF8StringEncoding], nil);
                if([messageDict isKindOfClass:[NSDictionary class]]){
                    // check if message deleted from server.
                    NSString *deleted = [Util getSafeString:[messageDict objectForKey:@"deleted"]];
                    if (!isFromActionException) {
                        if (![deleted isEqualToString:kMessageDeletedFromServer]) {
                            MessageDTO *messageDTO = [[[MessageDTO alloc] initWithJsonDict:messageDict] autorelease];
                            [[DatabaseHelper sharedHelper] messageFromMessageDTO:messageDTO];
                        }
                    } else {
                        if ([deleted isEqualToString:kMessageDeletedFromServer]) {
                            NSString *messageID = [Util getSafeString:[messageDict objectForKey:@"id"]];
                            BOOL isOk = [[DatabaseHelper sharedHelper] removeMessage:messageID];
                            if (isOk) {
                                DLogInfo(@"delete messageID: %@ is ok.",messageID);
                            }
                        } else {
                            MessageDTO *messageDTO = [[[MessageDTO alloc] initWithJsonDict:messageDict] autorelease];
                            [[DatabaseHelper sharedHelper] messageFromMessageDTO:messageDTO];
                        }
                    }

                }
            }
            hasData(YES);
        }
        else{
            if (!isFromActionException) {
                [self showMessage:LSSTRING(@"Data return is wrong. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
            }
            hasData(NO);
        }
    }
    else{
        [self showMessage:LSSTRING(@"There is an error. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
    }
}

- (void)goToHomePage {
    //HUONGNT ADD
    //Load data here
    [[MADataLoader ShareDataLoader] reLoadEntireData];
    //END
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSLog(@"start :%f",start);
    // get message on background.
    [GCDispatch performBlockInMainQueue:^{
        [[Util sharedUtil] showLoadingView];
        NSInteger countMessage = [[DatabaseHelper sharedHelper] countAllMessage];
        if (countMessage > 0) {
            NSLog(@"Load from Exception");
            NSNumber *latestUpdate = [UserDefault objectForKey:kLatestUpdateMessage];
            if (latestUpdate) {
                DLogInfo(@"[latestUpdate %f",[latestUpdate doubleValue]);
                [[MANetworkHelper sharedHelper] getMessageExceptionListWithLatestDate:[latestUpdate doubleValue] withsuccess:^(NSDictionary *resultDictionary) {
                    [self saveMesssageDTOFromDictionary:resultDictionary isFromActionException:YES withsuccess:^(BOOL hasData)  {
                        if (hasData) {
                            [UserDefault setObject:[Util getCurrentTimeStamp] forKey:kLatestUpdateMessage];
                            [UserDefault synchronize];
                        }
                        NSLog(@"closeee1");
                        [[Util sharedUtil] hideLoadingView];
                    }];
                } fail:^(NSError *error) {
                    [[Util sharedUtil] hideLoadingView];
                    [self showMessage:LSSTRING(@"There is an error with the server. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
                }];
            } else {
                [[Util sharedUtil] hideLoadingView];
            }
        } else {
            NSLog(@"Load getMessageListWithsuccess");
            [[MANetworkHelper sharedHelper] getMessageListWithsuccess:^(NSDictionary *resultDictionary) {
                [self saveMesssageDTOFromDictionary:resultDictionary isFromActionException:NO withsuccess:^(BOOL hasData) {
                    NSLog(@"closeee");
                    if (hasData) {
                        [UserDefault setObject:[Util getCurrentTimeStamp] forKey:kLatestUpdateMessage];
                        [UserDefault synchronize];
                    }
                    [[Util sharedUtil] hideLoadingView];
                }];
            } fail:^(NSError *error) {
                [[Util sharedUtil] hideLoadingView];
                [self showMessage:LSSTRING(@"There is an error with the server. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
            }];
        }
    }];
    
    [self gotoNextView];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    NSLog(@"login end: in %f",end - start);
}

- (void)gotoNextView
{
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    if (numberOfAvatar == 0) {
        [[MASession sharedSession] setCurrentPartner:nil];
        // Goto create partner view
        HomepageViewController *homeVC = NEW_VC(HomepageViewController);
        CreatePartnerViewController *createPartnerVC = NEW_VC(CreatePartnerViewController);
        [self.navigationController setViewControllers:@[self, homeVC, createPartnerVC] animated:NO];
    }
    else{
        // Goto Home view
        HomepageViewController *vc = NEW_VC(HomepageViewController);
        [self nextTo:vc];

    }
}

#pragma mark - event handler
- (IBAction)btnSignIn_touchUpInside:(id)sender {
    if(![MADeviceUtil connectedToNetwork] && ![MADeviceUtil connectedToWiFi]){
        [self offlineLogin];
    }
    else{
        [self login];
    }
}

- (IBAction)btnSignUp_touchUpInside:(id)sender {
    SignUpViewController *vc = NEW_VC(SignUpViewController);
    [self nextTo:vc];
}

- (IBAction)btnForgotPassword_touchUpInside:(id)sender {
    [self resignAllTextField];
    [MASubmitPopupView showMessage:LSSTRING(@"Please enter the email address associated with your account and an email will be sent to you.") inputName:LSSTRING(@"Email Address") delegate:self tag:MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG];
}

- (IBAction)btnForgotUsername_touchUpInside:(id)sender {
    [self resignAllTextField];
    [MASubmitPopupView showMessage:LSSTRING(@"Please enter the email address associated with your account and an email will be sent to you.") inputName:LSSTRING(@"Email Address") delegate:self tag:MANAPP_LOGIN_VIEW_FORGOT_USERNAME_ALERT_TAG];
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
    if([numberOfTimeLoginFail intValue] >= 3 && [numberOfTimeLoginFail intValue] < 5){
        [self showMessage:LSSTRING(@"If you don't remember your password, please select 'Forgot password' to renew your password.")];
    }
    //user have to wait after 5 times fail to login
    else if([numberOfTimeLoginFail intValue] >= 5){
        // if user failed to login more than 5 times, we need to stop user from login for a period of time
        NSInteger failCount = [numberOfTimeLoginFail intValue];
        switch (failCount) {
            case 5:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:60];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:LSSTRING(@"You failed to login to many time, you will be blocked for one minute.")];
            }
                break;
            case 9:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:5*60];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:LSSTRING(@"You failed to login to many time, you will be blocked for 5 minutes.")];
            }
                break;
            case 13:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:60*60];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:LSSTRING(@"You failed to login to many time, you will be blocked for one hour.")];
            }
                break;
            case 17:
            {
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:60*60*24];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:LSSTRING(@"You failed to login to many time, you will be blocked for day.")];
            }
                break;
            default:
                break;
        }
        
        if((failCount != 5 && failCount != 9 && failCount != 13 && failCount != 17) || (failCount > 17 && ((failCount - 17) % 4)!=0)){
            
            if((failCount > 17 && ((failCount - 17) % 4)==0)){
                NSDate *timeWhenUserCanLoginAgain = [[NSDate date] dateByAddingTimeInterval:60*60*24];
                [[NSUserDefaults standardUserDefaults] setObject:timeWhenUserCanLoginAgain forKey:MANAPP_DEFAULT_KEY_WAITTIME_UNTIL_LOGIN];
                [self showMessage:LSSTRING(@"You failed to login to many time, you will be blocked for day.")];
                return;
            }
            
            [self showMessage:LSSTRING(@"Username or Password is incorrrect")];
        }
    }

}

#pragma mark - text field delegate + keyboard notification

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:self.txtUsername]){
        [self.txtPassword becomeFirstResponder];
        [self scrollView:self.backgroundScrollView changeOffsetToView:self.txtPassword];
    }
    else if([textField isEqual:self.txtPassword]){
        [textField resignFirstResponder];
        [self btnSignIn_touchUpInside:self.btnSignIn];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    if([[MASubmitPopupView sharedInstance] superview] == nil){
        [self.btnBackground setSize:self.backgroundScrollView.frame.size];
        [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:YES];
    }
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:YES];
    [self.btnBackground setSize:self.backgroundScrollView.frame.size];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // COMMENT: if this alertview is the forget password view
    if(alertView.tag == MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG)
    {
        
    }
    else if(alertView.tag == MANAPP_LOGIN_VIEW_VERIFY_EMAIL_ALERT_TAG){
        if(buttonIndex == 0){
            if([MASession sharedSession].userID > 0){
                [GCDispatch performBlockInBackgroundQueue:^{
                    [self showWaitingHud];
                    [[MANetworkHelper sharedHelper] requestVerifyEmailForUserId:[NSString stringWithFormat:@"%d",[MASession sharedSession].userID] success:^(NSDictionary *response) {
                        NSString *responseMsg = [[MANetworkHelper sharedHelper] parseRequestVerifyEmailResult:response];
                        if(!responseMsg){
                            [self showMessage:@"The verification was sent to your email."];
                        }
                        else{
                            [self showMessage:[NSString stringWithFormat:@"Cannot resend email : %@",responseMsg]];
                        }
                        
                        [self hideWaitingHud];
                        
//                        [self goToHomePage];
                    } fail:^(NSError *error) {
                        [self hideWaitingHud];
                        [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
//                        [self goToHomePage];
                    }];
                } completion:^{
                    [self goToHomePage];
                }];

            }
        }
        else{
            [GCDispatch performBlock:^{
                [self goToHomePage];
            } inMainQueueAfterDelay:0.5f];
            // COMMENT: go to home page
            
        }
    }
    else if(alertView.tag == MANAPP_LOGIN_VIEW_OFFLINE_LOGIN_ALERT_TAG){
        if(buttonIndex == 0){
            HomepageViewController *vc = NEW_VC(HomepageViewController);
            [self nextTo:vc];
        }
    }
}

#pragma mark - MASumbitPopoverView
-(void)submitPopupView:(MASubmitPopupView *)view submitWithText:(NSString *)text{
    if(view.tag == MANAPP_LOGIN_VIEW_FORGOT_PASSWORD_ALERT_TAG){
        if(text){
            // COMMENT: display waiting screen
            [self showWaitingHud];
            
            [[MANetworkHelper sharedHelper] requestNewPasswordAtMail:text success:^(NSDictionary* resultDictionary){
                NSNumber* requestResult = [resultDictionary objectForKey:@"success"];
                if([requestResult boolValue])
                {
                    NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                    [self showMessage:responseMessage title:kAppName cancelButtonTitle:@"OK"];
                }
                else
                {
                    NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                    [self showMessage:responseMessage title:kAppName cancelButtonTitle:@"OK"];
                }
                [self hideWaitingHud];
            }fail:^(NSError *error) {
                [self hideWaitingHud];
                
                [self showMessage:LSSTRING(@"There is an error with the server. We cannot process your request.") title:kAppName cancelButtonTitle:@"OK"];
            }];
        }
    }
    else{
        if(text){
            // COMMENT: display waiting screen
            [self showWaitingHud];
            
            [[MANetworkHelper sharedHelper] requestNewUsernameAtMail:text success:^(NSDictionary* resultDictionary){
                NSNumber* requestResult = [resultDictionary objectForKey:@"success"];
                if([requestResult boolValue])
                {
                    NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                    [self showMessage:responseMessage title:kAppName cancelButtonTitle:@"OK"];
                }
                else
                {
                    NSString* responseMessage= [resultDictionary objectForKey:@"message"];
                    [self showMessage:responseMessage title:kAppName cancelButtonTitle:@"OK"];
                }
                [self hideWaitingHud];
            }fail:^(NSError *error) {
                [self hideWaitingHud];
                
                [self showMessage:LSSTRING(@"There is an error with the server. We cannot process your request.") title:kAppName cancelButtonTitle:@"OK"];
            }];
        }
    }
}

-(void)didTouchBackgroundOfSubmitPopupView:(MASubmitPopupView *)view{
    DLog(@"Close forgot password field");
}

- (void)viewDidUnload {
    [self setBtnForgotUsername:nil];
    [super viewDidUnload];
}
@end
