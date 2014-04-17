//
//  AddPreferenceItemViewController.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "CustomPickerView.h"

@class MACheckBoxButton;
@class Partner;
@class UIPlaceHolderTextView;
@class PreferenceItem;
@class PreferenceCategory;

#define MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_ALERT_TAG 10
#define MANAPP_ADD_PREFERENCE_ITEM_NEW_CATEGORY_TEXT_FIELD 11
#define MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG 12
#define MANAPP_ADD_PREFERENCE_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG 13
#define MANAPP_ADD_PREFERENCE_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG 14
#define MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG 15
#define MANAPP_ADD_PREFERENCE_ITEM_CONFIRM_RESTORE_CATEGORY_ALERT_TAG 16

#define MANAPP_ADD_PREFERENCE_ITEM_TEXT_VIEW_RESIZE_DISTANCE 0

@interface AddPreferenceItemViewController : BaseViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate,UIAlertViewDelegate,UITextFieldDelegate,CustomPickerViewDelegate>{
    BOOL _deleteState;
    BOOL _isLike;
}

@property (retain, nonatomic) IBOutlet UIButton *btnBackground;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewBackground;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewContent;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;
@property (retain, nonatomic) IBOutlet UIButton *btnLike;
@property (retain, nonatomic) IBOutlet UIButton *btnDislike;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblCategory;
@property (retain, nonatomic) IBOutlet UILabel *lblSubCategory;
@property (retain, nonatomic) IBOutlet UILabel *lblDetail;
@property (retain, nonatomic) IBOutlet UITextField *txtCategory;
@property (retain, nonatomic) IBOutlet UITextField *txtSubCategory;

@property (nonatomic, retain) PreferenceCategory *currentCategory;
@property (nonatomic, retain) PreferenceCategory *currentSubCategory;
@property (nonatomic, retain) NSArray *preferences;
@property (nonatomic, retain) NSArray *subPreferences;
@property (nonatomic, retain) PreferenceItem *preferenceItem;

@property (nonatomic, retain) CustomPickerView *pickerCategory;
@property (nonatomic, retain) CustomPickerView *pickerSubCategory;

- (IBAction)btnDelete_touchUpInside:(id)sender;
- (IBAction)btnLike_touchUpInside:(id)sender;
- (IBAction)btnDislike_touchUpInside:(id)sender;

@end
