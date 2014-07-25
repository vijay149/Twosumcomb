//
//  CreatePartnerViewController.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

@class MACheckBoxButton;
@class CreatePartnerViewController;
@class Partner;
@class UICustomProgressBar;

#define MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG 10

@protocol CreatePartnerViewControllerDelegate
@optional
-(void) createPartnerViewController:(CreatePartnerViewController*)view didUpdateForPartner:(NSInteger) partnerId;
-(void) createPartnerViewControllerDidDeletePartner:(CreatePartnerViewController*)view;
-(void) createPartnerViewController:(CreatePartnerViewController*)view didAddPartner:(NSInteger) partnerId;
@end

@interface CreatePartnerViewController : BaseViewController<UITextFieldDelegate, UIAlertViewDelegate>{

}

@property (nonatomic, retain) id<CreatePartnerViewControllerDelegate> delegate;
@property (retain, nonatomic) UIDatePicker *datePickerDateOfBirth;
@property (retain, nonatomic) UIDatePicker *datePickerFirstMeet;
@property (retain, nonatomic) UIView *datePickerView;
@property (retain, nonatomic) MACheckBoxButton *checkBoxMale;
@property (retain, nonatomic) MACheckBoxButton *checkBoxFemale;
@property (retain, nonatomic) MACheckBoxButton *checkBoxUSCalendar;
@property (retain, nonatomic) MACheckBoxButton *checkBoxIntCalendar;
@property (retain, nonatomic) UICustomProgressBar *processBar;

@property (retain, nonatomic) IBOutlet UIView *viewProcessBar;
@property (retain, nonatomic) IBOutlet UILabel *lblProcessBar;
@property (retain, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (retain, nonatomic) IBOutlet UITextField *txtPartnerName;
@property (retain, nonatomic) IBOutlet UITextField *txtDateOfBirth;
@property (retain, nonatomic) IBOutlet UITextField *txtFirstMeetDate;

@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnDeletePartner;
@property (retain, nonatomic) IBOutlet UIButton *btnCreateAvatar;
@property (retain, nonatomic) IBOutlet UIButton *btnPreference;
@property (retain, nonatomic) IBOutlet UIButton *btnMeasurement;
@property (retain, nonatomic) IBOutlet UIButton *btnAdditionalInformation;
@property (retain, nonatomic) IBOutlet UILabel *lblProcessValue;
@property (retain, nonatomic) IBOutlet UILabel *lblCreatePartnerTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblAdvice;
@property (retain, nonatomic) IBOutlet UILabel *lblPartnerName;
@property (retain, nonatomic) IBOutlet UILabel *lblDateOfBirth;
@property (retain, nonatomic) IBOutlet UILabel *lblFirstMeetDate;
@property (retain, nonatomic) IBOutlet UILabel *lblCalendarType;
@property (retain, nonatomic) IBOutlet UILabel *lblUSCalendar;
@property (retain, nonatomic) IBOutlet UILabel *lblInternationalCalendar;
@property (retain, nonatomic) IBOutlet UILabel *lblMale;
@property (retain, nonatomic) IBOutlet UILabel *lblFemale;

- (IBAction)backgroundView_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;
- (IBAction)btnDeletePartner_touchUpInside:(id)sender;
- (IBAction)btnCreateAvatar_touchUpInside:(id)sender;
- (IBAction)btnPreference_touchUpInside:(id)sender;
- (IBAction)btnMeasurement_touchUpInside:(id)sender;
- (IBAction)btnAdditionalInformation_touchUpInside:(id)sender;


@end
