//
//  PartnerMoodView.h
//  Manapp
//
//  Created by Demigod on 13/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PartnerMoodView;

@interface MASlider : UISlider

@end

@protocol PartnerMoodViewDelegate

- (void) didCancelInPartnerMoodView:(PartnerMoodView *)view;
- (void) didClickDoneInPartnerMoodView:(PartnerMoodView *)view;
- (void) changeSliderIcon:(id)sender;
@end

@interface PartnerMoodView : UIView<UITextFieldDelegate>{
    
}
@property (nonatomic, strong) id<PartnerMoodViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnDone;
@property (retain, nonatomic) IBOutlet UISlider *sliderMood;
@property (retain, nonatomic) IBOutlet UITextField *txtDate;
@property (retain, nonatomic) IBOutlet UIButton *btnDatePicker;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (retain, nonatomic) UIActionSheet* actionSheetDatePicker;
@property (retain, nonatomic) IBOutlet UIImageView *imageSad;
@property (retain, nonatomic) IBOutlet UIImageView *imageSmile;

- (IBAction)btnDone_touchUpInside:(id)sender;
- (IBAction)btnDatePicker_touchUpInside:(id)sender;
- (IBAction)btnCancel_touchUpInside:(id)sender;
- (IBAction)datePicker_valueChanged:(id)sender;
- (IBAction) sliderValueChangedAction:(id)sender;
@end
