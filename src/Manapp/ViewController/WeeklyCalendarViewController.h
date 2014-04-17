//
//  WeeklyCalendarViewController.h
//  Manapp
//
//  Created by Demigod on 26/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "BaseViewController.h"
#import "AddEventViewController.h"
#import "MACommon.h"
#import "EventsView.h"
#import "EventItemView.h"
#import "MenstruationView.h"

@class WeeklyCalendarViewController;

@protocol WeeklyCalendarViewControllerDelegate

@optional
-(void) didChangeEventInWeeklyCalendar:(WeeklyCalendarViewController *)vc;

@end

@interface WeeklyCalendarViewController : BaseViewController<TKCalendarWeekTimelineViewDelegate, EventsViewDelegate, UITextFieldDelegate, AddEventViewControllerDelegate, MenstruationViewDelegate,TKTimelineWeekViewDelegate,UIAlertViewDelegate>{
    
}

@property (nonatomic, retain) id<WeeklyCalendarViewControllerDelegate> delegate;
@property (strong, nonatomic) id delegateOfMonthView;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnMonth;
@property (retain, nonatomic) IBOutlet UIView *viewCalendar;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewBackground;
@property (nonatomic, retain) TKCalendarWeekTimelineView *calendarWeekTimelineView;
@property (retain, nonatomic) IBOutlet EventsView *eventsView;
@property (retain, nonatomic) IBOutlet MenstruationView *menstruationView;
@property (retain, nonatomic) NSDate *eventDateTemp;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnMonth_touchUpInside:(id)sender;

@end
