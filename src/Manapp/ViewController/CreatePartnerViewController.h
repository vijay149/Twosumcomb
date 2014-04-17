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

#define MANAPP_CREATE_PARTNER_VIEW_SAVE_SUCCESS_ALERT_TAG 9
#define MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG 10
#define MANAPP_CREATE_PARTNER_VIEW_CONFIRM_DELETE_PARTNER 11
#define MANAPP_CREATE_PARTNER_VIEW_DUPLICATE_PARTNER_NAME 12

@protocol CreatePartnerViewControllerDelegate
@optional
- (void)createPartnerViewController:(CreatePartnerViewController *)view didUpdateForPartner:(NSInteger)partnerId;
- (void)createPartnerViewControllerDidDeletePartner:(CreatePartnerViewController *)view;
- (void)createPartnerViewController:(CreatePartnerViewController *)view didAddPartner:(NSInteger)partnerId;
- (void)createPartnerViewController:(CreatePartnerViewController *)view didChangeToPartner:(Partner *)partner;
@end

@interface CreatePartnerViewController : BaseViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	BOOL _isDuplicateNameMessageVisible;
}

@property (nonatomic, retain) id <CreatePartnerViewControllerDelegate> delegate;
@property (retain, nonatomic) UIDatePicker *datePickerDateOfBirth;
@property (retain, nonatomic) UIDatePicker *datePickerFirstMeet;
@property (retain, nonatomic) UIView *datePickerView;
@property (retain, nonatomic) MACheckBoxButton *checkBoxMale;
@property (retain, nonatomic) MACheckBoxButton *checkBoxFemale;
@property (retain, nonatomic) UICustomProgressBar *processBar;

@property (retain, nonatomic) IBOutlet UIView *viewProcessBar;
@property (retain, nonatomic) IBOutlet UILabel *lblProcessBar;
@property (retain, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (retain, nonatomic) IBOutlet UITextField *txtPartnerName;
@property (retain, nonatomic) IBOutlet UITextField *txtDateOfBirth;
@property (retain, nonatomic) IBOutlet UITextField *txtFirstMeetDate;

@property (retain, nonatomic) IBOutlet UIButton *btnDeletePartner;
@property (retain, nonatomic) IBOutlet UIButton *btnHelp;
@property (retain, nonatomic) IBOutlet UIButton *btnDateOfBirth;
@property (retain, nonatomic) IBOutlet UIButton *btnFirstMet;
@property (retain, nonatomic) IBOutlet UIButton *btnBackground;
@property (retain, nonatomic) IBOutlet UILabel *lblProcessValue;
@property (retain, nonatomic) IBOutlet UILabel *lblCreatePartnerTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblAdvice;
@property (retain, nonatomic) IBOutlet UILabel *lblPartnerName;
@property (retain, nonatomic) IBOutlet UILabel *lblDateOfBirth;
@property (retain, nonatomic) IBOutlet UILabel *lblFirstMeetDate;
@property (retain, nonatomic) IBOutlet UILabel *lblMale;
@property (retain, nonatomic) IBOutlet UILabel *lblFemale;
@property (retain, nonatomic) IBOutlet UILabel *lblGender;

- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;
- (IBAction)btnDeletePartner_touchUpInside:(id)sender;
- (IBAction)btnHelp_touchUpInside:(id)sender;
- (IBAction)btnDateOfBirth_touchUpInside:(id)sender;
- (IBAction)btnFirstMet_touchUpInside:(id)sender;


@end
