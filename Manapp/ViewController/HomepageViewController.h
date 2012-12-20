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

@class Partner;
@class HomepageViewController;

@protocol HomePageViewControllerDelegate <NSObject>

- (void)userDidLogout:(HomepageViewController *)vc;

@end

@interface HomepageViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate,CreatePartnerViewControllerDelegate>{
    NSArray *_currentUserPartners;
    NSString *_selectedSettingItem;
}

@property (retain, nonatomic) id<HomePageViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UIButton *btnSetting;
@property (retain, nonatomic) IBOutlet UIButton *btnCurrentPartner;
@property (retain, nonatomic) IBOutlet UIButton *btnCalendar;
@property (retain, nonatomic) IBOutlet UIButton *btnPreference;
@property (retain, nonatomic) IBOutlet UIButton *btnMeasurement;
@property (retain, nonatomic) IBOutlet UIButton *btnSpecialZone;
@property (retain, nonatomic) IBOutlet UIButton *btnNotePage;

@property (retain, nonatomic) IBOutlet UILabel *lblMood;

@property (retain, nonatomic) UIPickerView *pickerSetting;
@property (retain, nonatomic) UIActionSheet* actionSheetSettingPicker;
@property (nonatomic, retain) UISlider *moodSlider;

@property (retain, nonatomic) NSMutableArray *settingItems;
@property (retain, nonatomic) NSArray *currentUserPartners;


- (IBAction)btnSetting_touchUpInside:(id)sender;
- (IBAction)btnCurrentPartner_touchUpInside:(id)sender;
- (IBAction)btnCalendar_touchUpInside:(id)sender;
- (IBAction)btnPreference_touchUpInside:(id)sender;
- (IBAction)btnMeasurement_touchUpInside:(id)sender;
- (IBAction)btnSpecialZone_touchUpInside:(id)sender;
- (IBAction)btnNotePage_touchUpInside:(id)sender;

@end
