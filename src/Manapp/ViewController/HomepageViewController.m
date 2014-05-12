//
//  HomepageViewController.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "HomepageViewController.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "CreatePartnerViewController.h"
#import "NSArray+MACalendar.h"
#import "UIView+Additions.h"
#import "PartnerMood.h"
#import "MASession.h"
#import "MeasurementViewController.h"
#import "HelpViewController.h"
#import "MonthlyCalendarViewController.h"
#import "PartnerBubbleTalkView.h"
#import "AdditionalInformationViewController.h"
#import "MAUserProcessManager.h"
#import "SpecialZoneViewController.h"
#import "MoodHelper.h"
#import "NSDate+Helper.h"
#import "MANotificationManager.h"
#import "MANetworkHelper.h"
#import "AvatarHelper.h"
#import "CustomAvatarViewController.h"
#import "CustomAvatarView.h"
#import "UILabel+Additions.h"
#import "NoteViewController.h"
#import "GCDispatch.h"
#import "MANetworkHelper.h"
#import "HomepageViewController.h"
#import "MACommon.h"
#import "MADeviceUtil.h"
#import "NoteViewController.h"
#import "MoodHelper.h"
#import "ImageHelper.h"
#import "FileUtil.h"
#import "DatabaseHelper.h"
#import "MessageDTO.h"
#import "AFJSONUtilities.h"
#import "UILabel+ESAdjustableLabel.h"
#import "SoLabel.h"
#import "EGOCache.h"

#define kGetMessageInterval 600
@interface HomepageViewController () {
    NSInteger indexOfArrayBubbleTalk;
    NSInteger currentPose;
}
-(void) initialize;
-(void) loadSettingView;
-(void) loadMoodBar;

-(void) loadUI;
-(void) loadProgressBar;

-(BOOL) loadPartner;

-(void) reloadBubbleTalk;

-(void) backSetting:(id)sender;
-(void) doneSetting:(id)sender;

-(void) fillViewWithPartnerData:(Partner *) partner;

-(void) moodSliderValueDidEndEditing:(id)sender;
-(void) moodSliderValueChanged:(id)sender;
-(void) settingForViewPartnerBubbleTalk;

// Actions on Settings
- (void)changeEmail;
-(void) deleteCurrentPartner;
-(void) createNewPartner;

- (void) changeHomeViewWhenShowMoodView:(BOOL) isHidden ;
- (void) loadCurrentPose;
- (void) generateAvatarPreviewMoodDefault: (void(^) (BOOL)) blockResult;
- (void) realTimeUpdateMessage;
@property (nonatomic, assign) BOOL firstTime;
@end

@implementation HomepageViewController
@synthesize btnSetting = _btnSetting;
@synthesize pickerSetting = _pickerSetting;
@synthesize actionSheetSettingPicker = _actionSheetSettingPicker;
@synthesize settingItems = _settingItems;
@synthesize moodSlider = _moodSlider;
@synthesize btnCalendar = _btnCalendar;
@synthesize btnCurrentPartner = _btnCurrentPartner;
@synthesize btnMeasurement = _btnMeasurement;
@synthesize btnNotesPage = _btnNotesPage;
@synthesize btnPreference = _btnPreference;
@synthesize btnSpecialZone = _btnSpecialZone;
@synthesize currentUserPartners = _currentUserPartners;
@synthesize scrollButtonBar = _scrollButtonBar;
@synthesize btnHelp = _btnHelp;
@synthesize splashView = _splashView;

- (void)dealloc {
    [_btnSetting release];
    [_pickerSetting release];
    [_actionSheetSettingPicker release];
    [_settingItems release];
    [_btnCurrentPartner release];
    [_btnCalendar release];
    [_btnPreference release];
    [_btnMeasurement release];
    [_btnSpecialZone release];
    [_btnNotesPage release];
    [_moodSlider release];
    [_currentUserPartners release];
    [_btnHelp release];
    [_scrollButtonBar release];
    [_viewBubbleTalk release];
    [_viewMood release];
    [_btnCreateAvatar release];
    [_btnAdditionalInformation release];
    [_processBar release];
    [_lblProgress release];
    [_btnMood release];
    [_viewAvatar release];
    [_imageViewArrowUp release];
    [_imageViewBubbleTalkArrow release];
    _changePasswordPopupView.delegate = nil;
    [_changePasswordPopupView release];
    _changeEmailPopupView.delegate = nil;
    [_changeEmailPopupView release];
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
    
    //Setting picker
    [self loadSettingView];
    //mood bar
    [self loadMoodBar];
    self.firstTime = YES;
    [self loadPartner];
    //load user data to view
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
    //prepare the UI
    [self loadUI];
    //loadCurrentPose
    [self loadCurrentPose];
    [self realTimeUpdateMessage];

    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)refreshAvatar
{
    [self.customAvatarView removeFromSuperview];
    self.customAvatarView = nil;
    
    self.customAvatarView = (CustomAvatarView *)[Util getView:[CustomAvatarView class]];
    self.customAvatarView.frame = CGRectMake(0, 0, self.viewAvatar.frame.size.width, self.viewAvatar.frame.size.height);
    [self.viewAvatar addSubview:self.customAvatarView];
    [self.customAvatarView loadAvatarForPartner:[MASession sharedSession].currentPartner];
    [self loadAvatar];
    [self.viewAvatar bringSubviewToFront:self.btnMood];
    

}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    
    [self loadSettingView];
    [self loadPartnerMood];
//    [self loadAvatar];
    [self loadProgressBar];
    [self reloadBubbleTalk];
    
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return;
    }

    ///!!!:generateAvatarPreviewMoodDefault
    //    [self generateAvatarPreviewMoodDefault:^(BOOL blockResult)  {}];
    // do something you want to measure
    [self refreshAvatar];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//loadCurrentPose
- (void) loadCurrentPose {
    //HUONGNT COMMENT
    /*
    CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:[[MASession sharedSession] currentPartner] date:[NSDate date]].moodValue.floatValue;
    NSInteger pose = [MoodHelper getPoseByMood:mood];
      currentPose = pose;
     */
    //END
    
    //HUONGNT ADD
    
    currentPose = [[MADataLoader ShareDataLoader] currentPose];
    //END
   
}

#pragma mark - private functions
-(BOOL) loadPartner {
    // if the user don't have any partner yet, redirect them to the create partner page
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    if (numberOfAvatar == 0) {
        [[MASession sharedSession] setCurrentPartner:nil];
        if (!self.isFromSignUp) {
//            [[Util sharedUtil] showLoadingView];
        } else {
            self.isFromSignUp = NO;
            [self realTimeUpdateMessageAction];
        }
        
//        if ([MADeviceUtil getDeviceIOSVersionNumber] < 7) {
//            [self gotoCreatePartnerPage];
//        }
        return NO;
    }
    else{
        //if there is no partner, automatically pick one partner
        if([[MASession sharedSession] currentPartner] == NULL){
            self.currentUserPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
            [[MASession sharedSession] setCurrentPartner:[self.currentUserPartners lastObject]];
        }
        return YES;
    }
}

//init function
-(void) initialize {
}

//prepare the UI
-(void)loadUI {
    // scroll for buttons at the bottom
    [self.scrollButtonBar setContentSize:CGSizeMake(self.btnCurrentPartner.frame.origin.x + self.btnCurrentPartner.frame.size.width, self.scrollButtonBar.frame.size.height)];
    self.scrollButtonBar.showsHorizontalScrollIndicator = NO;
    
    self.customAvatarView = (CustomAvatarView *)[Util getView:[CustomAvatarView class]];
    self.customAvatarView.frame = CGRectMake(0, 0, self.viewAvatar.frame.size.width, self.viewAvatar.frame.size.height);
    [self.viewAvatar addSubview:self.customAvatarView];
    [self.customAvatarView loadAvatarForPartner:[MASession sharedSession].currentPartner];
    
    [self loadAvatar];
    
    //bubble talk
    [self.viewBubbleTalk setFrame:CGRectMake(168, 70, self.viewBubbleTalk.frame.size.width, self.viewBubbleTalk.frame.size.height)];
    if (IS_IPHONE_5) {
         [self.viewBubbleTalk setFrame:CGRectMake(168, 110, self.viewBubbleTalk.frame.size.width, self.viewBubbleTalk.frame.size.height)];
    }
    self.viewBubbleTalk.hidden = YES;
    [GCDispatch performBlock:^{
        [self reloadBubbleTalk];
        [self.view addSubview:self.viewBubbleTalk];
    } inMainQueueAfterDelay:0];
    

    if(IS_IPHONE_5){
        CGFloat paddingIphone5 = 50;
        [self.viewMood setOriginY:(self.viewMood.frame.origin.y - paddingIphone5)];
        [self.viewAvatar setOriginY:(self.viewAvatar.frame.origin.y - paddingIphone5)];
        [self.viewBubbleTalk setOriginY:(self.viewBubbleTalk.frame.origin.y - paddingIphone5)];
        [self.viewBubbleTalk setOrigin:CGPointMake(153, -70)];
    }
    DLogInfo(@"self.viewavatar y: %f",self.viewAvatar.frame.origin.y);
    
    
    [self.viewAvatar bringSubviewToFront:self.btnMood];
}

-(void) reloadView{
    [self reloadBubbleTalk];
    [self loadProgressBar];
    [self loadAvatar];
    [self loadPartnerMood];
}


//get the current progress of this partner
-(void) loadProgressBar {
    [self.processBar setMinValue:0];
	[self.processBar setMaxValue:100];
    NSInteger progressValue = (NSInteger)[[MAUserProcessManager sharedInstance] getProcessForCurrentPartner];
	[self.processBar setRealProgress:progressValue];
    
    self.lblProgress.text = [NSString stringWithFormat:@"%d%%",progressValue];
    [self.lblProgress setFont:[UIFont fontWithName:kAppFont size:11]];
}

//change avatar base on the partner sex
-(void) loadAvatar {
    //avatar
    [self.customAvatarView reloadWithPartner:[MASession sharedSession].currentPartner];
    
    if([[MASession sharedSession] currentPartner].sex.integerValue == MANAPP_SEX_FEMALE) {
        [self.btnCreateAvatar setImage:[UIImage imageNamed:@"iconFemaleConfig"] forState:UIControlStateNormal];
        self.btnCurrentPartner.frame = CGRectMake(self.btnCurrentPartner.frame.origin.x, -3, self.btnCurrentPartner.frame.size.width, self.btnCurrentPartner.frame.size.height);
        [self.btnCurrentPartner setImage:[UIImage imageNamed:@"iconFemaleAvatar"] forState:UIControlStateNormal];
    }
    else{
        [self.btnCreateAvatar setImage:[UIImage imageNamed:@"iconMaleConfig"] forState:UIControlStateNormal];
        self.btnCurrentPartner.frame = CGRectMake(self.btnCurrentPartner.frame.origin.x, -5, self.btnCurrentPartner.frame.size.width, self.btnCurrentPartner.frame.size.height);
        [self.btnCurrentPartner setImage:[UIImage imageNamed:@"iconMaleAvatar"] forState:UIControlStateNormal];
        
    }
}

//UI for the mood bar
-(void) loadMoodBar {
    if (!_moodSlider) {
        // Init slider
        _moodSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 370, 10)];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
        _moodSlider.transform = trans;
        [_moodSlider addTarget:self action:@selector(moodSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_moodSlider addTarget:self action:@selector(moodSliderValueDidEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [_moodSlider setOriginX:0];
        [_moodSlider setOriginY:20];
        [_moodSlider setThumbImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];
        UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [_moodSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [_moodSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
        
        [self.viewMood addSubview:_moodSlider];
    }
    
    [self.viewMood bringSubviewToFront:self.btnMood];
}

-(void) loadPartnerMood {
    if([MASession sharedSession].currentPartner) {
        if ([[Util objectForKey:kMoodDefaultFirstStart] boolValue]) {//kMoodDefaultFirstStart when app first install.
            [Util setValue:[NSNumber numberWithBool:NO] forKey:kMoodDefaultFirstStart];
        }
        
        CGFloat moodValue = [MoodHelper calculateMoodAtDate:[NSDate date] forPartner:[MASession sharedSession].currentPartner];
        [self.moodSlider setValue:[MoodHelper convertMoodToSliderValue:moodValue]];
    }
    else{
        [self.moodSlider setValue:0];
    }
    
    
}

//UI for the setting picker
-(void) loadSettingView {
    //setting list data
    
    //init the settingItems list if it isn't existed
    if (!_settingItems) {
        _settingItems = [[NSMutableArray alloc] init];
    }
    [self.settingItems removeAllObjects];
    
    // add data to setting picker
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR];
    
    //HUONGNT MARK BEGIN: NEED TO REPLACE
    NSArray* _partnerList = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
    //END
    
    //HUONGNT ADD
//    partnerList = [[MADataLoader ShareDataLoader] partnerList];
    //END
    for(int i=0; i<[_partnerList count]; i++)
    {
        Partner* partner = [_partnerList objectAtIndex:i];
        [self.settingItems addObject:[NSString stringWithFormat:MANAPP_SETTING_MENU_ITEM_PARTNER,partner.name]];
    }
    self.currentUserPartners = partnerList;
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_RESET_NOTIFICATIONS];
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD];
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_CHANGE_EMAIL];
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_LOGOUT];
    [self.pickerSetting reloadAllComponents];
    [self.pickerSetting setBackgroundColor:[UIColor whiteColor]];

    
    //setting UI
    // COMMENT: actionset for setting picker
    if(!self.actionSheetSettingPicker){
        self.actionSheetSettingPicker = [[UIActionSheet alloc] initWithTitle:nil
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:nil];
        
        [self.actionSheetSettingPicker setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [self.actionSheetSettingPicker setBackgroundColor:[UIColor clearColor]];
        // COMMENT: generate setting picker
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        _pickerSetting = [[UIPickerView alloc] initWithFrame:pickerFrame];
        _pickerSetting.showsSelectionIndicator = YES;
        _pickerSetting.dataSource = self;
        _pickerSetting.delegate = self;
        [self.actionSheetSettingPicker addSubview:_pickerSetting];
        
        // COMMENT: add toolbar with done button to the picker (with two button at the bar)
        UIToolbar * pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        UIBarButtonItem *backBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backSetting:)] autorelease];
        [barItems addObject:backBtn];
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(doneSetting:)] autorelease];
        [barItems addObject:doneBtn];
        [pickerToolbar setItems:barItems animated:YES];
        [self.actionSheetSettingPicker addSubview:pickerToolbar];
    }
}

//go to create partner page
- (void) gotoCreatePartnerPage
{
    CreatePartnerViewController* createPartnerViewController = NEW_VC(CreatePartnerViewController);
    createPartnerViewController.delegate = self;
    [self nextToView:createPartnerViewController];
    [self.splashView removeFromSuperview];
}

//fill view with partner data
-(void) fillViewWithPartnerData:(Partner *) partner {
    //if there is a partner, fill its data to view, if not, reset all the view
    if(partner){
        //mood bar
        
        //HUONGNT COMMENT
        //PartnerMood *partnerMood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]];
        //END
        
        //HUONGNTADD
        partnerMood = [[MADataLoader ShareDataLoader] partnerMood];
        //END
        self.moodSlider.value = (CGFloat)(100 - [partnerMood.moodValue intValue])/100;
    }
    else {
        //mood bar
        self.moodSlider.value = 0;
    }
}

-(void) createNewPartner {
    //check to see if this account have more than the avatars allowed or not, if true, denied access to this function
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    if(numberOfAvatar < [MASession sharedSession].maximumPartnerAllow){
        [[MASession sharedSession] setCurrentPartner:nil];
        [self gotoCreatePartnerPage];
    }
    else{
        int userId =  [[[MASession sharedSession] currentPartner].userID intValue];
        [[MANetworkHelper sharedHelper] checkActive:[NSString stringWithFormat:@"%d",userId] success:^(NSDictionary *response) {
            DLogInfo(@"max %d",[MASession sharedSession].maximumPartnerAllow);
            if ([MASession sharedSession].maximumPartnerAllow == MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT) {
                [self showMessage:[NSString stringWithFormat:LSSTRING(@"Reach maximum number of Partner allowed (%d partners)."),[MASession sharedSession].maximumPartnerAllow] title:kAppName cancelButtonTitle:@"OK"];
            } else {
                NSNumber *userStatus = [response objectForKey:kAPILoginUserState];
                DLogInfo(@"message return %d",[userStatus intValue]);
                if (userStatus && userStatus.intValue == 1) {
                    [[MASession sharedSession] setMaximumPartnerAllow:MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT];
                    [[MASession sharedSession] setCurrentPartner:nil];
                    [self gotoCreatePartnerPage];
                } else {
                    [self showMessage:@"To create your 2nd Partner you need to verify your email address, click the OK to resend the verification email and then check your email" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MA_HOME_REACH_MAXIMUM_PARTNET_ALERT_TAG];
                }
            }

        } fail:^(NSError *error) {
            DLogInfo(@"error return %@",[error description]);
        }];
//        if([MASession sharedSession].maximumPartnerAllow == MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT_NOT_ACTIVE){
//            [self showMessage:@"To create your 2nd Partner you need to verify your email address, click the OK to resend the verification email and then check your email" title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MA_HOME_REACH_MAXIMUM_PARTNET_ALERT_TAG];
//        }
//        else{
//            [self showMessage:[NSString stringWithFormat:LSSTRING(@"Reach maximum number of Partner allowed (%d partners)."),[MASession sharedSession].maximumPartnerAllow] title:kAppName cancelButtonTitle:@"OK"];
//        }
    }
}

-(void) deleteCurrentPartner {
    if ([[DatabaseHelper sharedHelper] removePartner:[[MASession sharedSession] currentPartner]]) {
        [self showMessage:LSSTRING(@"Partner deleted")];
        
        [[MASession sharedSession] setCurrentPartner:nil];
        
        //reload the partner list
        self.currentUserPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
    } else {
        [self showMessage:LSSTRING(@"Could not delete current partner")];
    }
    
    //if there isn't any partner left
    if (self.currentUserPartners.count <= 0) {
        [self.btnCurrentPartner setTitle:LSSTRING(@"Create new partner") forState:UIControlStateNormal];
    }
    //if not, pick lastest partner
    else {
        [[MASession sharedSession] setCurrentPartner:[self.currentUserPartners firstObject]];
    }
    
    // Reload view with changes
    [self loadSettingView];
    [self reloadBubbleTalk];
}

- (void)changeEmail {
    //hide the gray background
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
    
    // show the alertview with textfield
    NSMutableArray *subsControl = [[[NSMutableArray alloc] init] autorelease];
    
    UITextField *txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 40.0, 260.0, 25.0)];
    txtPassword.font = [UIFont systemFontOfSize:14];
    txtPassword.placeholder = @"Please input your current password";
    txtPassword.secureTextEntry = YES;
    txtPassword.delegate = self;
    [txtPassword setBackgroundColor:[UIColor whiteColor]];
    txtPassword.tag = MA_HOME_CHANGE_EMAIL_PASSWORD_TEXTFIELD;
    [subsControl addObject:txtPassword];
    
    UITextField *txtNewEmail = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 70.0, 260.0, 25.0)];
    txtNewEmail.font = [UIFont systemFontOfSize:14];
    txtNewEmail.placeholder = @"Please input your new email";
    txtNewEmail.delegate = self;
    [txtNewEmail setBackgroundColor:[UIColor whiteColor]];
    txtNewEmail.tag = MA_HOME_CHANGE_EMAIL_TEXTFIELD;
    
    [subsControl addObject:txtNewEmail];
    
    [self showMessage:@"\n\n" title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Change Email" delegate:self tag:MA_HOME_CHANGE_EMAIL_ALERT_TAG subControls:subsControl];
}


///!!!: change password don't use
- (void) changePassword {
    //    - (void)changePassword:(NSString*) password forUser:(NSString *) userId success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail
    //hide the gray background
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
    
    // show the alertview with textfield
    NSMutableArray *subsControl = [[[NSMutableArray alloc] init] autorelease];
    
    UITextField *txtPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 40.0, 260.0, 25.0)];
    txtPassword.font = [UIFont systemFontOfSize:14];
    txtPassword.placeholder = @"Please input your current password";
    txtPassword.secureTextEntry = YES;
    txtPassword.delegate = self;
    [txtPassword setBackgroundColor:[UIColor whiteColor]];
    txtPassword.tag = MA_HOME_CHANGE_PASSWORD_CURRENT_TEXTFIELD;
    [subsControl addObject:txtPassword];
    
    UITextField *txtNewPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 70.0, 260.0, 25.0)];
    txtNewPassword.font = [UIFont systemFontOfSize:14];
    txtNewPassword.placeholder = @"Please input your new password";
    txtNewPassword.secureTextEntry = YES;
    txtNewPassword.delegate = self;
    [txtNewPassword setBackgroundColor:[UIColor whiteColor]];
    txtNewPassword.tag = MA_HOME_CHANGE_PASSWORD_NEW_TEXTFIELD;
    [subsControl addObject:txtNewPassword];
    
    UITextField *txtConfirmNewPassword = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 100.0, 260.0, 25.0)];
    txtConfirmNewPassword.font = [UIFont systemFontOfSize:14];
    txtConfirmNewPassword.placeholder = @"Please input your confirm password";
    txtConfirmNewPassword.delegate = self;
    txtConfirmNewPassword.secureTextEntry = YES;
    [txtConfirmNewPassword setBackgroundColor:[UIColor whiteColor]];
    txtConfirmNewPassword.tag = MA_HOME_CHANGE_PASSWORD_CONFIRM_TEXTFIELD;
    
    [subsControl addObject:txtConfirmNewPassword];
    
    [self showMessage:@"\n\n\n\n" title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Change Password" delegate:self tag:MA_HOME_CHANGE_PASSWORD_ALERT_TAG subControls:subsControl];
}


- (void)logout {
    [[MASession sharedSession] logout];
    
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//toggle mood view
- (void)changeMoodViewShowingState:(BOOL) isShow {
    if(isShow){
        if(self.viewMoodDetail){
            [self.viewMoodDetail removeFromSuperview];
            self.viewMoodDetail = nil;
           // self.viewMoodDetail = (PartnerMoodView *)[Util getView:[PartnerMoodView class]];
            //[self.view addSubview:self.viewMoodDetail];
        }
        self.viewMoodDetail = (PartnerMoodView *)[Util getView:[PartnerMoodView class]];
        self.viewMoodDetail.delegate = self;
        [self.viewMoodDetail setOrigin:CGPointMake(0, self.view.frame.size.height)];
        [self.viewMoodDetail setHidden:YES];
        [self.view addSubview:self.viewMoodDetail];
        
        
        if(self.viewMoodDetail.hidden){
            self.viewMoodDetail.hidden = NO;
            [self.viewMoodDetail setSize:self.view.frame.size];
            [UIView animateWithDuration:0.3 animations:^{
                [self.viewMoodDetail setOriginY:0];
            } completion:^(BOOL finished) {
            }];
        }
    }
    else{
        if(!self.viewMoodDetail.hidden){
            [self.viewMoodDetail setSize:self.view.frame.size];
            [UIView animateWithDuration:0.3 animations:^{
                [self.viewMoodDetail setOriginY:self.view.frame.size.height];
            } completion:^(BOOL finished) {
                self.viewMoodDetail.hidden = YES;
            }];
        }
    }
}

#pragma mark - event handler
//click the setting button will show the setting scroll view
- (IBAction)btnSetting_touchUpInside:(id)sender {
    [self.actionSheetSettingPicker showInView:[[UIApplication sharedApplication] keyWindow]];
    [self.actionSheetSettingPicker setBounds:CGRectMake(0, 0, 320, 485)];
    [self.pickerSetting reloadComponent:0];
}

- (IBAction)btnCurrentPartner_touchUpInside:(id)sender {
    [self gotoCreatePartnerPage];
}

- (IBAction)btnCalendar_touchUpInside:(id)sender {
    if ([UserDefault objectForKey:kIsWeek]) {
        NSString *isWeekView = [UserDefault objectForKey:kIsWeek];
        if ([isWeekView isEqual:@"YES"]) {
            [self pushViewControllerByName:@"WeeklyCalendarViewController"];
        } else {
            [self pushViewControllerByName:@"MonthlyCalendarViewController"];
        }
    } else {
        [self pushViewControllerByName:@"MonthlyCalendarViewController"];
    }
}

- (IBAction)btnPreference_touchUpInside:(id)sender {
    if(![[MASession sharedSession] currentPartner])
    {
        [self showErrorMessage:LSSTRING(@"Please select a partner first!")];
    }
    else{
        [self pushViewControllerByName:@"PreferenceViewController"];
    }
}

- (IBAction)btnMeasurement_touchUpInside:(id)sender {
    // COMMENT: go to measurement view (alert show up if not partner was selected)
    if(![[MASession sharedSession] currentPartner])
    {
        [self showErrorMessage:LSSTRING(@"Please select a partner first!")];
    }
    else{
        [self pushViewControllerByName:@"MeasurementViewController"];
    }
}

- (IBAction)btnSpecialZone_touchUpInside:(id)sender {
    if([MASession sharedSession].currentPartner){
        SpecialZoneViewController *vc = NEW_VC(SpecialZoneViewController);
        [self nextTo:vc];
    }
    else{
        [self showMessage:LSSTRING(@"Please select a partner first!")];
    }
}

- (IBAction)btnSummaryNotePage_touchUpInside:(id)sender {
    if([MASession sharedSession].currentPartner){
        NoteViewController *noteVC = NEW_VC(NoteViewController);
        [self nextTo:noteVC];
    }
    else{
        [self showMessage:LSSTRING(@"Please select a partner first!")];
    }
}

- (IBAction)btnHelp_touchUpInside:(id)sender {
    MAAppDelegate *appdelegate = (MAAppDelegate*)[[UIApplication sharedApplication] delegate];
    appdelegate.indexImageShow = kIndexHelpShowHomepage;
    
    [self pushViewControllerByName:@"HelpViewController"];
}

- (IBAction)btnCreateAvatar_touchUpInside:(id)sender {
    
    //only allow to go the create avatar after we have one partner
    if([MASession sharedSession].currentPartner){
        CustomAvatarViewController *vc = NEW_VC(CustomAvatarViewController);
        [self nextTo:vc];
    }
}

- (IBAction)btnAdditionalInformation_touchUpInside:(id)sender {
    
    // COMMENT: go to addition view (alert show up if not partner was selected)
    if([[MASession sharedSession] currentPartner])
    {
        AdditionalInformationViewController *vc = NEW_VC(AdditionalInformationViewController);
        [self nextTo:vc];
    }
    else{
        [self showMessage:LSSTRING(@"Please select a partner first!")];
    }
}

//button to show mood view
- (IBAction)btnMood_touchUpInside:(id)sender {
    [self changeHomeViewWhenShowMoodView:YES];
    [self changeMoodViewShowingState:YES];
}

//click the back button on top of the setting picker
-(void) backSetting:(id)sender{
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
}

//click the done button on the setting picker view to select the current item
-(void) doneSetting:(id)sender{
    _selectedSettingItem = [self.settingItems objectAtIndex:[self.pickerSetting selectedRowInComponent:0]];
    if([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR])
    {
        [self createNewPartner];
    }
    else if([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD])
    {
        [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
        self.changePasswordPopupView = [[MAChangePasswordPopupView alloc] initWithNibName:@"MAChangePasswordPopupView"  bundle:nil];
        if (self.changePasswordPopupView) {
            self.changePasswordPopupView.delegate = self;
            [self.changePasswordPopupView presentWithSuperview:self.view];
        }
        return;
    }
    else if ([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_LOGOUT]) {
        [self logout];
        return;
    }
    else if ([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_CHANGE_EMAIL]) {
        [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
        self.changeEmailPopupView = [[MAChangeEmailPopupView alloc] initWithNibName:@"MAChangeEmailPopupView"  bundle:nil];
        if (self.changeEmailPopupView) {
            self.changeEmailPopupView.delegate = self;
            [self.changeEmailPopupView presentWithSuperview:self.view];
        }
        return;
    }else if ([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_RESET_NOTIFICATIONS]){
        [self showMessage:@"You will deleted all the reminders and notifications? Are you sure about this?" title:kAppName cancelButtonTitle:@"YES" otherButtonTitle:@"NO" delegate:self tag:MANAPP_ADD_EVENT_VIEW_DELETE_ALL_NOTIFICATION];
    }
    else
    {
        // COMMENT: first we have to get the username from the item string (remove "Profile" text)
        NSString *selectedPartnerName = [[_selectedSettingItem componentsSeparatedByString:@"Select "] lastObject];
        selectedPartnerName = [selectedPartnerName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        // COMMENT: get partner id from name and save to the globar variable
        Partner *selectedPartner = [[DatabaseHelper sharedHelper] getPartnerByName:selectedPartnerName];
        
        if(selectedPartner){
            //set the last used date
            [[DatabaseHelper sharedHelper] setLastUsedTimeWithCurrentDateForPartner:selectedPartner.partnerID.intValue];
            [[MASession sharedSession] setCurrentPartner:selectedPartner];
            [self loadProgressBar];//reload progressbar.
        }
        [self reloadView];
        //        [self performSelector:@selector(reloadView) withObject:nil afterDelay:2];
    }
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
    
}

// mood bar stop after get changed
- (void) moodSliderValueDidEndEditing:(id)sender{
    if([[MASession sharedSession] currentPartner])
    {
        NSNumber *moodValue = [NSNumber numberWithFloat:[MoodHelper convertSliderValueToMood:self.moodSlider.value]];
        [[DatabaseHelper sharedHelper] addMoodValue:moodValue forPartner:[[MASession sharedSession] currentPartner] date:[NSDate date]];
    }
    
    [self loadAvatar];
}

// mood bar being changed
- (void) moodSliderValueChanged:(id)sender
{
    
}

#pragma mark - setting picker view datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.settingItems count];
}

#pragma mark - setting picker view delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.settingItems objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedSettingItem = [self.settingItems objectAtIndex:row];
}

#pragma mark - create partner view delegate
-(void)createPartnerViewController:(CreatePartnerViewController *)view didUpdateForPartner:(NSInteger)partnerId{
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

-(void)createPartnerViewController:(CreatePartnerViewController *)view didAddPartner:(NSInteger)partnerId{
    //reload the setting picker
    [self loadSettingView];
    [self.pickerSetting reloadAllComponents];
    
    //fill the view with new user
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

-(void)createPartnerViewControllerDidDeletePartner:(CreatePartnerViewController *)view{
    //reload the setting picker
    [self loadSettingView];
    [self.pickerSetting reloadAllComponents];
}

-(void)createPartnerViewController:(CreatePartnerViewController *)view didChangeToPartner:(Partner *)partner{
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

#pragma mark - mood view delegate
-(void)didCancelInPartnerMoodView:(PartnerMoodView *)view{
    [self.customAvatarView.imgShirt setHidden:NO];// when change mood
    [self loadAvatar];
    [self changeHomeViewWhenShowMoodView:NO];
    [self changeMoodViewShowingState:NO];
}

-(void)didClickDoneInPartnerMoodView:(PartnerMoodView *)view{
    if([[MASession sharedSession] currentPartner])
    {
        NSNumber *moodValue = [NSNumber numberWithFloat:[MoodHelper convertSliderReverseValueToMood:self.viewMoodDetail.sliderMood.value]];
        // using for login: set value default mood.
        NSLog(@"self.viewMoodDetail.sliderMood.value %f",self.viewMoodDetail.sliderMood.value);
        NSInteger partnerID = [MASession sharedSession].currentPartner.partnerID.integerValue;
        NSString *key = [NSString stringWithFormat:@"%@%d",kValueMoodSelected,partnerID];
        [UserDefault setValue:moodValue forKey:key];
        [UserDefault synchronize];
        
        NSDate *date = [NSDate fromString:self.viewMoodDetail.txtDate.text];
        PartnerMood *mood = [[DatabaseHelper sharedHelper] addMoodValue:moodValue forPartner:[[MASession sharedSession] currentPartner] date:date];
        //User input
        mood.isUserInput = [NSNumber numberWithBool:YES];
            //check the cycle number
            NSLog(@"added time %@",mood.addedTime);
            NSInteger cycle = [NSDate dayBetweenDay:[mood.addedTime beginningAtMidnightOfDay] andDay:[date beginningAtMidnightOfDay]]/ 30;
            NSInteger day = [NSDate dayBetweenDay:[mood.addedTime beginningAtMidnightOfDay] andDay:[date beginningAtMidnightOfDay]]% 30 + 1;
            NSString *key1 = [NSString stringWithFormat:@"kMood_%d_%d_%f_%d", cycle, day, [date timeIntervalSince1970],[[MASession sharedSession] currentPartner].partnerID.integerValue];
            [[EGOCache globalCache] setString:[NSString stringWithFormat:@"%d",[moodValue integerValue]] forKey:key1];
            [self reloadBubbleTalk];
        
        if(mood){
            //remove the previous mood notification in this day
            [[MANotificationManager sharedInstance] removeMoodNotificationOfPartner:[[MASession sharedSession] currentPartner] atDate:date];
            // add notification for mood (reminder after 3 days)
            [[MANotificationManager sharedInstance] setNotificationForMood:mood forPartner:[[MASession sharedSession] currentPartner]];
        }
    }
    //    [self.customAvatarView.imgShirt setHidden:NO];// when change mood
    [self loadPartnerMood];
    [self changeMoodViewShowingState:NO];
    [self loadAvatar];
   // [self reloadBubbleTalk];
    [self changeHomeViewWhenShowMoodView:NO];
}

- (void) changeSliderIcon:(id)sender {
    NSLog(@"slider value: %f", [(UISlider *)sender value]);
    UISlider *slider = (UISlider *)sender;
    if (slider) {
        NSNumber *moodValue = [NSNumber numberWithFloat:[MoodHelper convertSliderReverseValueToMood:slider.value]];
        NSString *imageName = [MoodHelper getImageNameStarForSlideOnMood:[moodValue floatValue]];
        NSLog(@"mood value: %f",[moodValue floatValue]);
        [self.viewMoodDetail.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.viewMoodDetail.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
        NSInteger pose = [MoodHelper getPoseByMood:[moodValue floatValue]];
        DLogInfo(@"pose : %d",pose);
        if (pose != currentPose) {
            currentPose = pose;
            [self.customAvatarView reloadPartnerPreviewMood:[[MASession sharedSession] currentPartner] withPose:pose];
        }
        // using when generateimage.
        //            NSString *imageName = [NSString stringWithFormat:@"avatar_male_preview_mood_%d",pose];
        //            if([[MASession sharedSession] currentPartner].sex.integerValue == MANAPP_SEX_FEMALE) {
        //                imageName = [NSString stringWithFormat:@"avatar_female_preview_mood_%d",pose];
        //            }
        //            if (imageName) {
        //                UIImage *image =  [FileUtil imageInDocumentWithName:imageName];
        //                if (image) {
        //                    [self.customAvatarView.imgShirt setHidden:YES];
        //                    self.customAvatarView.imgAvatar.image = image;
        //                    currentPose = pose;
        //                } else {// default app create first time will don't exist avatar_female_preview_mood_
        //                    // if change pant or shirt, shoe... will create image avatar_female_preview_mood_
        //                    //load image default
        //                    self.customAvatarView.imgAvatar.image = [UIImage imageNamed:imageName];
        //                    currentPose = pose;
        //                }
        //            }
        
    }
}

// don't use
- (void) generateAvatarPreviewMoodDefault: (void(^) (BOOL)) blockResult {
    if ([[MASession sharedSession] currentPartner]) {
        NSString *imageNameDefault = [NSString stringWithFormat:@"avatar_male_preview_mood_%d",0];
        if([[MASession sharedSession] currentPartner].sex.integerValue == MANAPP_SEX_FEMALE) {
            imageNameDefault = [NSString stringWithFormat:@"avatar_female_preview_mood_%d",0];
        }
        
        UIImage *image =  [FileUtil imageInDocumentWithName:imageNameDefault];
        if (!image) {
            for (int i = 0; i < 5; i++) {
                NSString *imageName = [NSString stringWithFormat:@"avatar_female_preview_mood_%d",i];
                BOOL isOk = [FileUtil saveImage:[UIImage imageNamed:imageName] toDocumentWithName:imageName];
                if (isOk) {
                    DLogInfo(@"image %@",imageName);
                }
            }
        } else {
            DLogInfo(@"Image is exist");
        }
    }
}

#pragma mark - KOAprocessbar delegate
-(void)didTouchKOAProgressBar:(KOAProgressBar *)processBar{
    [self showMessage:[[MAUserProcessManager sharedInstance] hintToGetOneHundred]];
}

- (void)viewDidUnload {
    [self setBtnMood:nil];
    [self setViewAvatar:nil];
    [self setImageViewArrowUp:nil];
    [self setImageViewBubbleTalkArrow:nil];
    [super viewDidUnload];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == MA_HOME_REACH_MAXIMUM_PARTNET_ALERT_TAG){
        if(buttonIndex == 0){
            if([MASession sharedSession].userID > 0){
                [self showWaitingHud];
                int userId =  [[[MASession sharedSession] currentPartner].userID intValue];
                [[MANetworkHelper sharedHelper] requestVerifyEmailForUserId:[NSString stringWithFormat:@"%d", userId] success:^(NSDictionary *response) {
                    NSString *responseMsg = [[MANetworkHelper sharedHelper] parseRequestVerifyEmailResult:response];
                    if(!responseMsg){
                        [self showMessage:@"The email was sent successfully, please check your email!"];
                    }
                    else{
                        [self showMessage:[NSString stringWithFormat:@"Cannot resend email : %@",responseMsg]];
                    }
                    
                    [self hideWaitingHud];
                } fail:^(NSError *error) {
                    [self hideWaitingHud];
                    [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
                }];
            }
        }
    }
    else if(alertView.tag == MA_HOME_CHANGE_EMAIL_ALERT_TAG){
        UITextField *txtNewEmail = (UITextField *)[alertView viewWithTag: MA_HOME_CHANGE_EMAIL_TEXTFIELD];
        UITextField *txtPassword = (UITextField *)[alertView viewWithTag: MA_HOME_CHANGE_EMAIL_PASSWORD_TEXTFIELD];
        [txtNewEmail resignFirstResponder];
        [txtPassword resignFirstResponder];
        // add button clicked
        if(buttonIndex == 1)
        {
            if([txtPassword.text isEqualToString:@""] || txtPassword.text == nil){
                [self showMessage:@"Please don't input an empty string!"];
                return;
            } else {
                if (![txtPassword.text isEqual:[MASession sharedSession].password]) {
                    [self showMessage:@"Current password is wrong!"];
                    return;
                }
            }
            //validate email
            if([txtNewEmail.text isEqualToString:@""] || txtNewEmail.text == nil){
                [self showMessage:@"Please don't input an empty string!"];
                return;
            }
            
            [self showWaitingHud];
            [[MANetworkHelper sharedHelper] changeEmail:txtNewEmail.text forUser:[NSString stringWithFormat:@"%d",[MASession sharedSession].userID] success:^(NSDictionary *response) {
                NSString *responseMsg = [[MANetworkHelper sharedHelper] parseChangeEmailResult:response];
                [self showMessage:responseMsg];
                
                [self hideWaitingHud];
            } fail:^(NSError *error) {
                [self hideWaitingHud];
                [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
            }];
        }
    }// end else change email
    else if(alertView.tag == MA_HOME_CHANGE_PASSWORD_ALERT_TAG){///!!!: change password don't use
        UITextField *txtCurrentPassoword = (UITextField *)[alertView viewWithTag: MA_HOME_CHANGE_PASSWORD_CURRENT_TEXTFIELD];
        NSLog(@"current pass %@",txtCurrentPassoword.text);
        UITextField *txtNewPassword = (UITextField *)[alertView viewWithTag: MA_HOME_CHANGE_PASSWORD_NEW_TEXTFIELD];
        UITextField *txtConfirmNewPassword = (UITextField *)[alertView viewWithTag: MA_HOME_CHANGE_PASSWORD_CONFIRM_TEXTFIELD];
        [txtCurrentPassoword resignFirstResponder];
        [txtNewPassword resignFirstResponder];
        [txtConfirmNewPassword resignFirstResponder];
        // add button clicked
        if(buttonIndex == 1)
        {
            if([Util isNullOrNilObject:txtCurrentPassoword.text] || [txtCurrentPassoword.text isEqualToString:@""]){
                [self showMessage:@"Please don't input an empty string!"];
                return;
            } else {
                if (![txtCurrentPassoword.text isEqual:[MASession sharedSession].password]) {
                    [self showMessage:@"Current password is wrong!"];
                    return;
                }
            }
            if([Util isNullOrNilObject:txtNewPassword.text] || [txtNewPassword.text isEqualToString:@""]){
                [self showMessage:@"Please don't input an empty string!"];
                return;
            }
            
            if([Util isNullOrNilObject:txtConfirmNewPassword.text] || [txtConfirmNewPassword.text isEqualToString:@""]){
                [self showMessage:@"Please don't input an empty string!"];
                return;
            } else {
                if (![txtConfirmNewPassword.text isEqual:txtNewPassword.text]) {
                    [self showMessage:@"Confirm password do not match."];
                    return;
                }
            }
            
            [self showWaitingHud];
            
            [[MANetworkHelper sharedHelper] changePassword:txtNewPassword.text forUser:[NSString stringWithFormat:@"%d",[MASession sharedSession].userID] success:^(NSDictionary *response) {
                NSString *responseMsg = [[MANetworkHelper sharedHelper] parseChangeEmailResult:response];
                if ([MASession sharedSession].rememberMe) {
                    [MASession sharedSession].password = txtNewPassword.text;
                }
                [self showMessage:responseMsg];
                
                [self hideWaitingHud];
            } fail:^(NSError *error) {
                [self hideWaitingHud];
                [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
            }];
        }
    }else if(alertView.tag == MANAPP_ADD_EVENT_VIEW_DELETE_ALL_NOTIFICATION){
        if(buttonIndex == 0){
            [[MANotificationManager sharedInstance] removeAllNotificationWithType:MANotificationTypeEventReminder];
            [self showMessage:@"All reminder were deleted!"];
        }
    }
    
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}



////////////////////////////////////////////////////////////////////////////////////////////////////


-(void) settingForViewPartnerBubbleTalk {
    self.viewBubbleTalk.delegate = self;
    self.viewBubbleTalk.dataSource = self;
    //    self.viewBubbleTalk.minimumPageAlpha = 0.0;
    //    self.viewBubbleTalk.minimumPageScale = 0.8;
    self.viewBubbleTalk.orientation = PagedFlowViewOrientationVertical;
}

-(void)reloadBubbleTalk {
    [self settingForViewPartnerBubbleTalk];
    [self.viewBubbleTalk reloadBubbleTalk];
    
    [self.viewBubbleTalk scrollToPage:0];
    
    @try {
        [self.viewBubbleTalk scrollToPage:2];
    }
    @catch (NSException *exception) {
        [self.viewBubbleTalk scrollToPage:1];
    }
    @finally {
        DLog(@"Log from finally");
    }
   // [self.viewBubbleTalk scrollToPage:[self.viewBubbleTalk.partnerBubbleTalk.arrayLabelBubbleTalk count]-1];
    if (self.viewBubbleTalk.partnerBubbleTalk.arrayLabelBubbleTalk.count >4) {
        [self.viewBubbleTalk scrollToPage:4];
    }
    [self.viewBubbleTalk scrollToPage:0];
    // init default height
    self.viewBubbleTalk.hidden = YES;
    PartnerBubbleTalk *currentPartner = self.viewBubbleTalk.partnerBubbleTalk;
    if (currentPartner && currentPartner.arrayHeightBubbleTalk && currentPartner.arrayHeightBubbleTalk.count > 0) {
        CGFloat height = [currentPartner.arrayHeightBubbleTalk[0] floatValue];
        NSLog(@"height %f",height);
        CGFloat xDefault = 168;
        CGFloat widthDefault = 166;
        CGFloat yDefault = 70;
        CGFloat yDefaultImageArrowUp = 0;
        if (iOS7OrLater) {
            yDefault = 70;
            yDefaultImageArrowUp = 15;
            if (IS_IPHONE_5) {
                yDefaultImageArrowUp = 15;
                yDefault = 110;
            }
            self.imageViewArrowUp.frame = CGRectMake(self.imageViewArrowUp.frame.origin.x, yDefaultImageArrowUp, self.imageViewArrowUp.frame.size.width, self.imageViewArrowUp.frame.size.height);
        } else {
            yDefault = 70;
            yDefaultImageArrowUp = 15;
            if (IS_IPHONE_5) {
                yDefault = 110;
            }
            self.imageViewArrowUp.frame = CGRectMake(self.imageViewArrowUp.frame.origin.x, yDefaultImageArrowUp, self.imageViewArrowUp.frame.size.width, self.imageViewArrowUp.frame.size.height);
        }
        if (height > 50) {
            self.viewBubbleTalk.frame = CGRectMake(xDefault, yDefault, widthDefault, height + 40);
        } else {
            self.viewBubbleTalk.frame = CGRectMake(xDefault, yDefault, widthDefault, height + 10);
        }
        self.viewBubbleTalk.hidden = NO;
    }
 
}


#pragma mark -
#pragma mark PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    //    DLogInfo(@"x %f",self.viewBubbleTalk.frame.origin.x);
    return  CGSizeMake(self.viewBubbleTalk.frame.size.width - 30, 150);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"Scrolled to pagxe # %d", index);
    @try {
        PartnerBubbleTalk *currentPartner =  self.viewBubbleTalk.partnerBubbleTalk;
        if (index >= 0 && currentPartner && currentPartner.arrayHeightBubbleTalk && currentPartner.arrayHeightBubbleTalk.count > 0 ) {
            CGFloat height = [[currentPartner.arrayHeightBubbleTalk objectAtIndex:index] floatValue];
            DLogInfo(@"height %f",height);
            NSNumber *isLast = [currentPartner.arrayIsLastBubbleTalk objectAtIndex:index];
            CGFloat yDefault = 80;
            CGFloat yDefaultImageArrowUp = 0;
            if (iOS7OrLater) {
                yDefault = 70;
                yDefaultImageArrowUp = 15;
                if (IS_IPHONE_5) {
                    yDefaultImageArrowUp = 15;
                    yDefault = 100;
                }
                self.imageViewArrowUp.frame = CGRectMake(self.imageViewArrowUp.frame.origin.x, yDefaultImageArrowUp, self.imageViewArrowUp.frame.size.width, self.imageViewArrowUp.frame.size.height);
            } else {
                yDefault = 70;
                yDefaultImageArrowUp = 15;
                if (IS_IPHONE_5) {
                    yDefault = 100;
                    yDefaultImageArrowUp = 15;
                }
                self.imageViewArrowUp.frame = CGRectMake(self.imageViewArrowUp.frame.origin.x, yDefaultImageArrowUp, self.imageViewArrowUp.frame.size.width, self.imageViewArrowUp.frame.size.height);
            }
            if ([isLast boolValue]) {
                DLogInfo(@"is last item");
                [self.viewBubbleTalk scrollToPage:0];
            }
            NSLog(@"BubbleViewFrame: X = %f, Y = %f, W = %f, H = %f", self.viewBubbleTalk.frame.origin.x, self.viewBubbleTalk.frame.origin.y, self.viewBubbleTalk.frame.size.width, self.viewBubbleTalk.frame.size.height);

        }
    }
    @catch (NSException *exception) {
        DLog(@"%@",[exception description]);
    }
}


- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    //    NSLog(@"Tapped on page # %d", index);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView Datasource

- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return self.viewBubbleTalk.partnerBubbleTalk.arrayLabelBubbleTalk.count;
}

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    
    NSLog(@"Dequeue Cell: %d",index);
    
    SoLabel *label = (SoLabel *)[flowView dequeueReusableCell];
    if (!label) {
        label = [[SoLabel alloc]init];
    }
    if ([self.viewBubbleTalk.partnerBubbleTalk.arrayLabelBubbleTalk count]> 0) {
        label = [self.viewBubbleTalk.partnerBubbleTalk.arrayLabelBubbleTalk objectAtIndex:index];
        if (![Util isNullOrNilObject:label] && ![Util isNullOrNilObject:label.text]) {
            [label adjustLabel];
            [label setNumberOfLines:0];
            [label sizeToFit];
        }
    }

    return label;
}

#pragma mark - MAChangeEmailPopupViewDelegate
- (void)changeEmailDidFinish:(MAChangeEmailPopupView *)controller {
	if (self.changeEmailPopupView) {
		[self.changeEmailPopupView removeFromSuperviewWithAnimation];
	}
}

- (void) changeEmail:(NSString *)currentPassowrd newEmail:(NSString *)newEmail {
    if([currentPassowrd isEqualToString:@""] || currentPassowrd == nil || [newEmail isEqualToString:@""] || newEmail == nil){
        [self showMessage:@"Please don't input an empty string!"];
        return;
    }
    DLogInfo(@"password: %@",[MASession sharedSession].password);
    if (![currentPassowrd isEqual:[MASession sharedSession].password]) {
        [self showMessage:@"Current password is wrong!"];
        return;
    }
    if (![Util validateEmail:newEmail]) {
        [self showMessage:@"Please enter a valid email address!"];
        return;
    }
    
    [self showWaitingHud];
    [[MANetworkHelper sharedHelper] changeEmail:newEmail forUser:[NSString stringWithFormat:@"%d",[MASession sharedSession].userID] success:^(NSDictionary *response) {
        NSString *responseMsg = [[MANetworkHelper sharedHelper] parseChangeEmailResult:response];
        [self showMessage:responseMsg];
        
        [self hideWaitingHud];
        if (self.changeEmailPopupView) {
            [self.changeEmailPopupView removeFromSuperviewWithAnimation];
        }
    } fail:^(NSError *error) {
        [self hideWaitingHud];
        [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
    }];
}

#pragma mark - MAChangePasswordPopupViewDelegate
- (void)changePasswordDidFinish:(MAChangePasswordPopupView *)controller {
	if (self.changePasswordPopupView) {
		[self.changePasswordPopupView removeFromSuperviewWithAnimation];
	}
}

- (void)changePassword:(NSString *)currentPassowrd newPassword:(NSString *)newPassword confirmPassword:(NSString *)confirmPassword {
    [[MASession sharedSession] load];
    if([Util isNullOrNilObject:currentPassowrd] || [currentPassowrd isEqualToString:@""] || [Util isNullOrNilObject:newPassword] || [newPassword isEqualToString:@""] || [Util isNullOrNilObject:confirmPassword] || [confirmPassword isEqualToString:@""]){
        [self showMessage:@"Please don't input an empty string!"];
        return;
    } else {
        
    }
    DLogInfo(@"password: %@",[MASession sharedSession].password);
    if (![currentPassowrd isEqual:[MASession sharedSession].password]) {
       
        [self showMessage:@"Current password is wrong!"];
        return;
    }
    if (![confirmPassword isEqual:newPassword]) {
        [self showMessage:@"Confirm password do not match."];
        return;
    }
    
    [self showWaitingHud];
    
    [[MANetworkHelper sharedHelper] changePassword:newPassword forUser:[NSString stringWithFormat:@"%d",[MASession sharedSession].userID] success:^(NSDictionary *response) {
        NSString *responseMsg = [[MANetworkHelper sharedHelper] parseChangeEmailResult:response];
        if ([response objectForKey:@"success"] && [[response objectForKey:@"success"] boolValue] == YES) {
            [MASession sharedSession].password = newPassword;
        }
        [self showMessage:responseMsg];
        [self hideWaitingHud];
        if (self.changePasswordPopupView) {
            [self.changePasswordPopupView removeFromSuperviewWithAnimation];
        }
    } fail:^(NSError *error) {
        [self hideWaitingHud];
        [self showMessage:[NSString stringWithFormat:@"Error : %@",error.localizedDescription]];
    }];
}

- (void) changeHomeViewWhenShowMoodView:(BOOL) isHidden {
    CGFloat x = -32;// default
    CGFloat y = 27;// default
    if (IS_IPHONE_5) {
        y = 64;// default
    }
    CGFloat width = 269; // default
    CGFloat height = 400;// default
    NSLog(@"self.viewAvatar.frame %f  --: %f",self.viewAvatar.frame.origin.x, self.viewAvatar.frame.origin.y);
    NSLog(@"w %f  height: %f",self.viewAvatar.frame.size.width, self.viewAvatar.frame.size.height);
    if (isHidden) {
        x = 25;
        y = 5;
        height = 370;
        width = 249;
        if (IS_IPHONE_5) {
            y = 50;
        }
    }
    self.viewAvatar.frame = CGRectMake(x, y, width, height);
    self.btnHelp.hidden = isHidden;
    self.btnSetting.hidden = isHidden;
    self.lblProgress.hidden = isHidden;
    self.processBar.hidden = isHidden;
    self.viewBubbleTalk.hidden = isHidden;
}


- (void) realTimeUpdateMessage {
    [NSTimer scheduledTimerWithTimeInterval:kGetMessageInterval
                                     target:self
                                   selector:@selector(realTimeUpdateMessageAction)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) realTimeUpdateMessageAction {
    if(![MADeviceUtil connectedToNetwork] && ![MADeviceUtil connectedToWiFi]) {
        return;
    }
    if ([MASession sharedSession].currentPartner) {
        DLogInfo(@"showLoadingView on realTimeUpdateMessageAction.");
        [[Util sharedUtil] showLoadingView];
        NSNumber *latestUpdate = [UserDefault objectForKey:kLatestUpdateMessage];
        if (latestUpdate) {
            DLogInfo(@"[latestUpdate  %f",[latestUpdate doubleValue]);
            [[MANetworkHelper sharedHelper] getMessageExceptionListWithLatestDate:[latestUpdate doubleValue] withsuccess:^(NSDictionary *resultDictionary) {
                [self saveMesssageDTOFromDictionary:resultDictionary isFromActionException:YES withsuccess:^(BOOL hasData)  {
                    if (hasData) {
                        DLogInfo(@"time:-----:%@",[Util getCurrentTimeStamp]);
                        [UserDefault setObject:[Util getCurrentTimeStamp] forKey:kLatestUpdateMessage];
                        [UserDefault synchronize];
                        DLogInfo(@"reload bubble talk");
                        [self reloadBubbleTalk];
                    } else {
                        DLogInfo(@"no data");
                    }
                    [[Util sharedUtil] hideLoadingView];
                }];
            } fail:^(NSError *error) {
                [[Util sharedUtil] hideLoadingView];
                [self showMessage:LSSTRING(@"There is an error with the server. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
            }];
        } else {
            [[Util sharedUtil] hideLoadingView];
            
        }
        DLogInfo(@"real time called");
    } else {
        DLogInfo(@"current partner empty.");
    }
    
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




#pragma mark - Auto Rotation
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

- (void) nextToView:(UIViewController *)vc{
    [self.navigationController pushViewController:vc animated:NO];
}

-(void) loadEntireData
{
    
}
@end
