//
//  PartnerMoodView.m
//  Manapp
//
//  Created by Demigod on 13/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "PartnerMoodView.h"
#import "NSDate+Helper.h"
#import "MoodHelper.h"
#import "MASession.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "PartnerMood.h"

@implementation MASlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    return CGRectMake((bounds.size.width - 36) * value, -5, 35, 33);
}

@end


@implementation PartnerMoodView


- (void)dealloc {
    [_btnCancel release];
    [_btnDone release];
    [_sliderMood release];
    [_txtDate release];
    [_btnDatePicker release];
    [_imageSad release];
    [_imageSmile release];
    [super dealloc];
}


-(void) layoutSubviews{
    [super layoutSubviews];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return;
    }
    NSString *imageName = @"";
    //slider
    float moodValue = 0;
    NSInteger partnerID = [MASession sharedSession].currentPartner.partnerID.integerValue;
    NSString *key = [NSString stringWithFormat:@"%@%d",kValueMoodSelected,partnerID];
    moodValue = [[UserDefault objectForKey:key] floatValue];
    Partner *partner =  [MASession sharedSession].currentPartner;
    CGFloat mood = 0.0f;
    if (partner) {
        //mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
        mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    }
    if (mood != moodValue) {
        moodValue = mood;
    }
    if (moodValue > 0) {
        NSLog(@"mood value %f",moodValue);
        CGFloat valueMood =  [MoodHelper convertMoodToSliderValue2:moodValue];
        [self.sliderMood setValue:valueMood];
        //        CGFloat valueMood =  [MoodHelper convertSliderValueToMood:moodValue];
        imageName = [MoodHelper getImageNameStarForSlideOnMood:moodValue];
        [self.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    } else {
        imageName = [MoodHelper getImageNameStarForSlideOnMood:0];
        [self.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.sliderMood setThumbImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    }
    
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.sliderMood setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.sliderMood setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
    
    if(!self.actionSheetDatePicker){
        self.actionSheetDatePicker = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        [self.actionSheetDatePicker setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        // COMMENT: generate setting picker
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        _datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.datePicker addTarget:self action:@selector(datePicker_valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.actionSheetDatePicker addSubview:self.datePicker];
        [self.datePicker setMaximumDate:[NSDate date]];
        [self.datePicker setDate:[[NSDate date] dateByAddDays:-1]];
        
        // COMMENT: add toolbar with done button to the picker (with two button at the bar)
        UIToolbar * pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        UIBarButtonItem *backBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backDatePicker:)] autorelease];
        [barItems addObject:backBtn];
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(doneDatePicker:)] autorelease];
        [barItems addObject:doneBtn];
        [pickerToolbar setItems:barItems animated:YES];
        [self.actionSheetDatePicker addSubview:pickerToolbar];
    }
    
    self.datePicker.date = [NSDate date];
    self.txtDate.text = [self.datePicker.date toString];
}


#pragma mark - event handler
//click the back button on top of the setting picker
-(void) backDatePicker:(id)sender{
    [self.actionSheetDatePicker dismissWithClickedButtonIndex:0 animated:YES];
}

-(void) doneDatePicker:(id)sender{
    [self.actionSheetDatePicker dismissWithClickedButtonIndex:0 animated:YES];
    self.txtDate.text = [self.datePicker.date toString];
}

- (IBAction)btnDone_touchUpInside:(id)sender {
    [self.delegate didClickDoneInPartnerMoodView:self];
}

- (IBAction)btnDatePicker_touchUpInside:(id)sender {
    [self.actionSheetDatePicker showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [self.actionSheetDatePicker setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)btnCancel_touchUpInside:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(didCancelInPartnerMoodView:)]) {
        [self.delegate didCancelInPartnerMoodView:self];
    }
}

- (IBAction)datePicker_valueChanged:(id)sender {
}

- (IBAction) sliderValueChangedAction:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(changeSliderIcon:)]) {
        [self.delegate changeSliderIcon:sender];
    }
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
@end
