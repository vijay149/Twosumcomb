//
//  HomepageViewController.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MACommon.h"
#import "BaseViewController.h"
#import "CreatePartnerViewController.h"
#import "KOAProgressBar.h"
#import "PartnerMoodView.h"
#import "MAAvatarView.h"
#import "PartnerBubbleTalkView.h"
#import "MAChangePasswordPopupView.h"
#import "MAChangeEmailPopupView.h"
#import "MADataLoader.h"
@class PartnerBubbleTalkView;
@class Partner;
@class HomepageViewController;
@class CustomAvatarView;

#define MA_HOME_REACH_MAXIMUM_PARTNET_ALERT_TAG 99
#define MA_HOME_CHANGE_EMAIL_ALERT_TAG 100
#define MA_HOME_CHANGE_EMAIL_TEXTFIELD 101
#define MA_HOME_CHANGE_EMAIL_PASSWORD_TEXTFIELD 102
#define MA_HOME_CHANGE_PASSWORD_CURRENT_TEXTFIELD 103
#define MA_HOME_CHANGE_PASSWORD_NEW_TEXTFIELD 104
#define MA_HOME_CHANGE_PASSWORD_CONFIRM_TEXTFIELD 105
#define MA_HOME_CHANGE_PASSWORD_ALERT_TAG 106
@interface HomepageViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate,CreatePartnerViewControllerDelegate,KOAProgressBarDelegate, PartnerMoodViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,PagedFlowViewDataSource,PagedFlowViewDelegate,MAChangePasswordPopupViewDelegate,MAChangeEmailPopupViewDelegate>{
    NSArray *_currentUserPartners;
    NSString *_selectedSettingItem;
    
    
    //HUONGNT ADD
    NSArray* partnerList;
    PartnerMood *partnerMood;
}

@property (retain, nonatomic) IBOutlet UIButton *btnSetting;
@property (retain, nonatomic) IBOutlet UIButton *btnCurrentPartner;
@property (retain, nonatomic) IBOutlet UIButton *btnCalendar;
@property (retain, nonatomic) IBOutlet UIButton *btnPreference;
@property (retain, nonatomic) IBOutlet UIButton *btnMeasurement;
@property (retain, nonatomic) IBOutlet UIButton *btnSpecialZone;
@property (retain, nonatomic) IBOutlet UIButton *btnNotesPage;
@property (retain, nonatomic) IBOutlet UIButton *btnHelp;
@property (retain, nonatomic) IBOutlet UIButton *btnCreateAvatar;
@property (retain, nonatomic) IBOutlet UIButton *btnAdditionalInformation;
@property (retain, nonatomic) IBOutlet UIButton *btnMood;
@property (retain, nonatomic) IBOutlet UIView *viewAvatar;
@property (retain, nonatomic) CustomAvatarView *customAvatarView;

@property (retain, nonatomic) PartnerMoodView *viewMoodDetail;
@property (retain, nonatomic) IBOutlet PartnerBubbleTalkView *viewBubbleTalk;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollButtonBar;
@property (retain, nonatomic) IBOutlet UIImageView *imgMoodBg;
@property (retain, nonatomic) IBOutlet UIView *viewMood;
@property (retain, nonatomic) IBOutlet KOAProgressBar *processBar;
@property (retain, nonatomic) IBOutlet UILabel *lblProgress;

@property (retain, nonatomic) UIPickerView *pickerSetting;
@property (retain, nonatomic) UIActionSheet* actionSheetSettingPicker;
@property (nonatomic, retain) UISlider *moodSlider;

@property (retain, nonatomic) NSMutableArray *settingItems;
@property (retain, nonatomic) NSArray *currentUserPartners;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewArrowUp;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewBubbleTalkArrow;

@property (retain, nonatomic) MAChangePasswordPopupView *changePasswordPopupView;
@property (retain, nonatomic) MAChangeEmailPopupView *changeEmailPopupView;
@property (nonatomic) BOOL isFromSignUp;

@property (strong, nonatomic) IBOutlet UIView *splashView;
- (IBAction)btnSetting_touchUpInside:(id)sender;
- (IBAction)btnCurrentPartner_touchUpInside:(id)sender;
- (IBAction)btnCalendar_touchUpInside:(id)sender;
- (IBAction)btnPreference_touchUpInside:(id)sender;
- (IBAction)btnMeasurement_touchUpInside:(id)sender;
- (IBAction)btnSpecialZone_touchUpInside:(id)sender;
- (IBAction)btnSummaryNotePage_touchUpInside:(id)sender;
- (IBAction)btnHelp_touchUpInside:(id)sender;
- (IBAction)btnCreateAvatar_touchUpInside:(id)sender;
- (IBAction)btnAdditionalInformation_touchUpInside:(id)sender;
- (IBAction)btnMood_touchUpInside:(id)sender;
@end
