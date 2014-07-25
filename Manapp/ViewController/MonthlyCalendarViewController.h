//
//  MonthlyCalendarViewController.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "EventsView.h"
#import "EventItemView.h"
#import "MenstruationView.h"

@class TKCalendarMonthView;

@interface MonthlyCalendarViewController : BaseViewController<TKCalendarMonthViewDataSource, TKCalendarMonthViewDelegate, EventsViewDelegate, UITextFieldDelegate>{
    
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewBackground;
@property (retain, nonatomic) IBOutlet UIView *viewCalendarPlaceHolder;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnWeek;
@property (retain, nonatomic) IBOutlet EventsView *eventsView;
@property (retain, nonatomic) IBOutlet MenstruationView *menstruationView;

@property (retain, nonatomic) TKCalendarMonthView *calendarMonthView;

- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnWeek_touchUpInside:(id)sender;

@end
