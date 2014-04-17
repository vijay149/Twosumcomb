//
//  MenstruationView.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MADateSelectTextField.h"
#import "MACheckBoxButton.h"

@class MenstruationView;
@class Partner;

@protocol MenstruationViewDelegate

@optional
-(void) menstruationViewDidTouchSaveButton:(MenstruationView *) view;
-(void) menstruationViewDidTouchBackButton:(MenstruationView *) view;
-(void) menstruationViewDidTouchCalendarButton:(MenstruationView *) view;

@end

@interface MenstruationView : UIView{
    
}

@property (retain, nonatomic) id<MenstruationViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet MADateSelectTextField *txtFirstPeriod;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) MACheckBoxButton *checkBoxYes;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblLastPeriod;
@property (retain, nonatomic) IBOutlet UILabel *lblBirthControl;
@property (retain, nonatomic) IBOutlet UILabel *lblYes;
@property (retain, nonatomic) IBOutlet UILabel *lblNo;
@property (retain, nonatomic) IBOutlet UILabel *lblWarning;
@property (retain, nonatomic) IBOutlet UIButton *btnFirstDay;

-(void) fillViewWithPartnerData:(Partner *)partner;

- (IBAction)btnSave_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnFirstDay_touchUpInside:(id)sender;

@end
