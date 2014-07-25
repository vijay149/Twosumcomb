//
//  AddMeasurementItemController.h
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

@class PartnerMeasurementItem;
@class Partner;
@class UIPlaceHolderTextView;

#define MANAPP_ADD_MEASUREMENT_ITEM_NEW_CATEGORY_ALERT_TAG 10
#define MANAPP_ADD_MEASUREMENT_ITEM_NEW_CATEGORY_TEXT_FIELD 11
#define MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_DETAIL_TAG 12
#define MANAPP_ADD_MEASUREMENT_ITEM_DELETEBUTTON_INFORMATION_CATEGORY_TAG 13
#define MANAPP_ADD_MEASUREMENT_ITEM_SUCCESSFULLY_CREATION_ALERT_TAG 14
#define MANAPP_ADD_MEASUREMENT_ITEM_CONFIRM_DELETE_CATEGORY_ALERT_TAG 15

#define MANAPP_ADD_MEASUREMENT_ITEM_TEXT_VIEW_RESIZE_DISTANCE 20

@interface AddMeasurementItemController : BaseViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate,UIAlertViewDelegate>{
    BOOL _deleteState;
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewBackground;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerItem;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewContent;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;

@property (nonatomic, retain) PartnerMeasurementItem *measurementItem;
@property (nonatomic, retain) NSArray *partnerMeasurements;

- (IBAction)btnDelete_touchUpInside:(id)sender;

@end
