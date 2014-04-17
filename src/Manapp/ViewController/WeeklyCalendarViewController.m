//
//  WeeklyCalendarViewController.m
//  Manapp
//
//  Created by Demigod on 26/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "WeeklyCalendarViewController.h"
#import "HomepageViewController.h"
#import "MonthlyCalendarViewController.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "NSDate+Helper.h"
#import "Event.h"
#import "PartnerMood.h"
#import "MoodHelper.h"
#import "MenstruationUtil.h"
#import "NSDate+Mic.h"

@interface WeeklyCalendarViewController ()
- (void) initialize;

- (void) loadCalendar;
- (void) loadEventView;
- (void) loadMenstruationView;

- (NSArray *) getEventsInWeek:(NSDate *)week;
@property (nonatomic, retain) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *beginOfCurrentWeek;
@property (strong, nonatomic) NSDate *endOfCurrentWeek;
@end

@implementation WeeklyCalendarViewController
@synthesize btnBack = _btnBack;
@synthesize btnMonth = _btnMonth;
@synthesize viewCalendar = _viewCalendar;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize calendarWeekTimelineView = _calendarWeekTimelineView;
@synthesize delegate = _delegate;
@synthesize delegateOfMonthView;


- (void)dealloc {
    self.delegate = nil;
    [_eventDateTemp release];
    [_btnBack release];
    [_btnMonth release];
    [_viewCalendar release];
    [_scrollViewBackground release];
    [_calendarWeekTimelineView release];
    [_eventsView release];
    [_menstruationView release];
    [_selectedDate release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadUI];
  
    
    [self loadCalendar];
    [self loadEventView];
    [self loadMenstruationView];
    [MenstruationUtil checkCurrentDateWithCountDownDateMenstruation];
    
    [self showEventClosestForCurrentMonth];
}

- (void)showEventClosestForCurrentMonth
{
    [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
    [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO events:[self getEventFromCurrentDateToEndDate:[NSDate date]] isCurrentDay:YES];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSDate *today = [NSDate date];
    self.beginOfCurrentWeek = [today beginningOfWeek];
    self.endOfCurrentWeek = [self getEndDateOfWeek:today];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.selectedDate) {
        [self.calendarWeekTimelineView.timelineView setSelectedDate:self.selectedDate];
        [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:YES isChangeMonth:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - init functions
- (void) initialize{
    
}

-(void) loadUI{
    [self createBackNavigationWithTitle:@"Home" action:@selector(btnBack_touchUpInside:)];
    [self createRightNavigationWithTitle:@"Month" action:@selector(btnMonth_touchUpInside:)];
    
    self.calendarWeekTimelineView.timelineView.dataSource = self;
    //this eventView is attach to a weekly calendar
    self.eventsView.isMonthly = NO;
}

- (void) loadEventView{
    //hide the menstration and fertile icons if partner is male
    if([MASession sharedSession].currentPartner){
        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
            [self.eventsView hideFertleView:YES];
            [self.eventsView hideMenstrationView:YES];
        }
    }
    
    self.eventsView.frame = CGRectMake(0 , self.scrollViewBackground.frame.size.height - self.eventsView.frame.size.height, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
    self.eventsView.delegate = self;
    [self.scrollViewBackground addSubview:self.eventsView];
    if([MASession sharedSession].currentPartner){
        NSArray *arrEvents = [self getEventFromCurrentDateToEndDate:[NSDate date]];
        if (!arrEvents || arrEvents.count == 0) {
            self.eventsView.lblYouGotNothing.hidden = YES;
            [self.eventsView reloadViewWithEvents:[self getEventsInWeek:[NSDate date]] eventTimes:[self getEventTimesInWeek:[NSDate date]]];
            
        }else{
            [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO];
            [self.eventsView reloadViewWithEvents:[self getEventsInWeek:[NSDate date]] eventTimes:[self getEventTimesInWeek:[NSDate date]]];
            // when next or previous month will refresh selected date.
        }
//        [self.eventsView reloadViewWithEvents:[self getEventsInWeek:[NSDate date]]];
//        [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO];// when next or previous month will refresh selected date.
    }
    else{
        [self.eventsView reloadViewWithEvents:nil eventTimes:nil];
    }
}

- (void) loadMenstruationView{
    self.menstruationView.delegate = self;
    self.menstruationView.frame = CGRectMake(0 , 0, self.menstruationView.frame.size.width, self.menstruationView.frame.size.height);
    self.menstruationView.txtFirstPeriod.text = MANAPP_MENSTRATIONVIEW_DEFAULT_LAST_PERIOD;
    
    if([MASession sharedSession].currentPartner){
        self.menstruationView.lblLastPeriod.text = [NSString stringWithFormat:@"Please enter the first day of %@'s last Period",[MASession sharedSession].currentPartner.name];
    }
    else{
        self.menstruationView.lblLastPeriod.text = @"Please enter the first day of your partner's last period";
    }
}

#pragma mark - private function
- (void) loadCalendar{
    self.calendarWeekTimelineView.backgroundColor = [UIColor clearColor];
	self.calendarWeekTimelineView.isFiveDayWeek = NO;
    self.calendarWeekTimelineView.frame = CGRectMake(0, 0, 320, 250);
    [self.calendarWeekTimelineView setIsHideWeekNumber:YES];
    [self.viewCalendar addSubview:self.calendarWeekTimelineView];
}

#pragma mark - event getter
- (NSArray *) getEventsInWeek:(NSDate *)week{
    if([MASession sharedSession].currentPartner){
//        NSDate *lastDayOfWeek = [NSDate lastDateOfWeek:week];
        NSDate *startDateOfWeek = [self convertDateToMomentTimeOfDate:week withFormatTime:@"00:00:00"];
        NSDate *endOfWeek = [self getEndDateOfWeek:week];
        NSDate *lastDayOfWeek = [self convertDateToMomentTimeOfDate:endOfWeek withFormatTime:@"23:59:59"];
        
//        return [[DatabaseHelper sharedHelper] getAllEventOccurFromDate:week toDate:lastDayOfWeek forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        NSArray *retVal = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDate:startDateOfWeek toDate:lastDayOfWeek forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        
        DLogInfo(@"retVal = %@", retVal);
        return retVal;
    }
    return [[[NSArray alloc] init] autorelease];
}

- (NSArray *) getEventTimesInWeek:(NSDate *)week{
    if([MASession sharedSession].currentPartner){
        //        NSDate *lastDayOfWeek = [NSDate lastDateOfWeek:week];
        NSDate *startDateOfWeek = [self convertDateToMomentTimeOfDate:week withFormatTime:@"00:00:00"];
        NSDate *endOfWeek = [self getEndDateOfWeek:week];
        NSDate *lastDayOfWeek = [self convertDateToMomentTimeOfDate:endOfWeek withFormatTime:@"23:59:59"];
        
        //        return [[DatabaseHelper sharedHelper] getAllEventOccurFromDate:week toDate:lastDayOfWeek forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        NSArray *retVal = [[DatabaseHelper sharedHelper] getAllListEventTimeOccurFromDate:startDateOfWeek toDate:lastDayOfWeek forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        
        DLogInfo(@"retVal = %@", retVal);
        return retVal;
    }
    return [[[NSArray alloc] init] autorelease];
}

#pragma mark - event handler
- (IBAction)btnBack_touchUpInside:(id)sender {
    [self backToHomepage];
}

- (IBAction)btnMonth_touchUpInside:(id)sender {
    // check for show monthly or week
    [UserDefault setValue:@"NO" forKey:kIsWeek];
    [UserDefault synchronize];
    [self popToView:[MonthlyCalendarViewController class]];
//    [self back];
}

- (void) backToHomepage{
    UIViewController *homeViewController = nil;
    for(UIViewController *vc in self.navigationController.viewControllers){
        if([vc isKindOfClass:[HomepageViewController class]]){
            homeViewController = vc;
        }
    }
    if(homeViewController){
        [self.navigationController popToViewController:homeViewController animated:YES];
    }
}

#pragma mark - EventViews delegate
-(void)didTouchAddEventButtonInEventsView:(EventsView *)view{
    //add event view
    AddEventViewController *addEventViewController = [self getViewControllerByName:@"AddEventViewController"];
    if (!self.eventDateTemp) {
        self.eventDateTemp = [NSDate date];
    }
    addEventViewController.selectedDate = self.eventDateTemp;
    addEventViewController.delegate = self;

    UINavigationController *addEventNavigationViewController = [[[UINavigationController alloc] initWithRootViewController:addEventViewController] autorelease];
    [self presentViewController:addEventNavigationViewController animated:YES completion:^{}];
}

-(void)didTouchMenstrationButtonInEventsView:(EventsView *)view{
    [self showModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
    [self.menstruationView fillViewWithPartnerData:[MASession sharedSession].currentPartner];
    
}

-(void)didTouchRemoveEventButtonInEventsView:(EventsView *)view{
    Event *currentEvent = [self.eventsView getSelectedEvent];
    if(currentEvent){
        AddEventViewController *addEventViewController = [self getViewControllerByName:@"AddEventViewController"];
        [addEventViewController changeUIToEditModeWithEvent:currentEvent];
        addEventViewController.delegate = self;
        self.selectedDate = currentEvent.eventTime;
        UINavigationController *addEventNavigationViewController = [[[UINavigationController alloc] initWithRootViewController:addEventViewController] autorelease];
        [self presentViewController:addEventNavigationViewController animated:YES completion:^{}];
    }
}

#pragma mark - AddEventViewControllerDelegate
-(void)addEventViewControllerDidDeleteEvent:(AddEventViewController *)view{
    [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
    [self.calendarWeekTimelineView reloadDay];
    [self.delegateOfMonthView setNilForSelectedDate];
    [self.delegate didChangeEventInWeeklyCalendar:self];
    // re-handle data after delete
   
    NSLog(@"Selected Date: %@", [NSDate stringFromDate:self.selectedDate]);
    NSLog(@"Begin Date: %@", [NSDate stringFromDate:self.beginOfCurrentWeek]);
    NSLog(@"End Date: %@", [NSDate stringFromDate:self.endOfCurrentWeek]);
    if ([self.selectedDate isBetweenDate:self.beginOfCurrentWeek end:self.endOfCurrentWeek]) {
        NSArray *arrEvents = [self getEventFromCurrentDateToEndDate:[NSDate date]];
        if (!arrEvents || arrEvents.count == 0) {
            self.eventsView.lblYouGotNothing.hidden = YES;
            [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
            [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO];// when next or previous month will refresh selected date.
            
        }else{
            [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO];// when next or previous month will refresh selected date.
        }
    }

}

-(void)addEventViewControllerDidSaveEvent:(AddEventViewController *)view{
    [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
    [self.calendarWeekTimelineView reloadDay];
    [self.delegateOfMonthView setNilForSelectedDate];
    [self.delegate didChangeEventInWeeklyCalendar:self];
    [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:YES isChangeMonth:NO];
}

#pragma mark - menstruation view delegate
- (void)menstruationViewDidTouchSaveButton:(MenstruationView *)view{
    if ([self.menstruationView.txtFirstPeriod.text isEqualToString:MANAPP_MENSTRATIONVIEW_DEFAULT_LAST_PERIOD]) {
        [self showMessage:@"Please enter the first day of your's partner last period"];
    }
    else if([MASession sharedSession].currentPartner){
        NSDate *lastPeriod = [NSDate dateFromString:self.menstruationView.txtFirstPeriod.text withStyle:MANAPP_DATETIME_DEFAULT_TYPE];
        BOOL saveResult = [[DatabaseHelper sharedHelper] setMenstruationForPartner:[[MASession sharedSession].currentPartner.partnerID intValue] lastPeriod:lastPeriod usingBirthControl:self.menstruationView.checkBoxYes.isChecked];
        
        if(saveResult){
            // save date  menstruation expiration alert
            // 120 will show alert expiration.
            // change [NSDate date] to : lastPeriod
            [Util setValue:[lastPeriod dateByAddDays:120] forKey:kMenstruatationExpiration];
            //            [Util setValue:[[NSDate date] dateByAddMinute:1] forKey:kMenstruatationExpiration];
            [Util setValue:[NSNumber numberWithInt:0] forKey:kCountDownMenstruatationExpiration];
            [Util setValue:[NSNumber numberWithBool:NO] forKey:kMessageShowed];
            //reload the partner to get the new data
            [[MASession sharedSession] reloadPartner];
            [self showMessage:@"Menstruation data saved, the road to happiness partially paved" title:kAppName cancelButtonTitle:@"Close" delegate:self tag:-1];            
        }
    }else{
        [self showMessage:@"Please create partner before editing"];
    }
    
    [self.calendarWeekTimelineView reloadDay];
}

#define mark - UIAlertViewDelegate
// hiden menstruation View 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"buttonIndex %d",buttonIndex);
    [self menstruationViewDidTouchBackButton:nil];
}

-(void) menstruationViewDidTouchBackButton:(MenstruationView *)view{
    [self hideModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
}

#pragma mark - weekly view delegate
- (NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventsForDate:(NSDate *)eventDate{
	return nil;
}


/**********************************************************
 @Function description: display a calendar icon on the date when there are events occur
 @Note:
 ***********************************************************/
-(NSArray*)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline eventsInWeekForDate:(NSDate *)eventDate{
    if(![MASession sharedSession].currentPartner){
        return nil;
    }
    
    NSMutableArray *eventsDateArray = [[[NSMutableArray alloc] init] autorelease];
    
//    NSArray* partnerEvents = [[DatabaseHelper sharedHelper] getAllEventOccurFromDate:self.calendarWeekTimelineView.beginningOfWeek toDate:[NSDate lastDateOfWeek:self.calendarWeekTimelineView.beginningOfWeek] forPartner:[MASession sharedSession].currentPartner.partnerID.intValue];
//    
//    NSInteger numberOfEvent = partnerEvents.count;
    
//    // COMMENT: return a list of datetime object which indicated when the event will occur
//    for(NSInteger i = 0; i < numberOfEvent; i++){
//        Event *event = [partnerEvents objectAtIndex:i];
//        if(event.eventTime != NULL){
//            TKEvent *tkEvent = [[[TKEvent alloc] init] autorelease];
//            DLogInfo(@"event time week view:  %@",event.eventTime);
//            tkEvent.eventTime = event.eventTime;
//            tkEvent.eventTitle = event.eventName;
//            tkEvent.eventEndTime = event.eventEndTime;
//            [eventsDateArray addObject:tkEvent];
//        }
//    }
    [[Util sharedUtil] showLoadingView];
//    NSArray *retVal = [[DatabaseHelper sharedHelper] getAllOccurEventFromDate:self.calendarWeekTimelineView.beginningOfWeek toDate:[NSDate lastDateOfWeek:self.calendarWeekTimelineView.beginningOfWeek] forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
//    DLogInfo(@"retVal = %@", retVal);
    DLogInfo(@"self.calendarWeekTimelineView.beginningOfWeek: %@",self.calendarWeekTimelineView.beginningOfWeek);
    DLogInfo(@"to date: %@",[NSDate lastDateOfWeek:self.calendarWeekTimelineView.beginningOfWeek]);
    NSArray *retVal = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDate:self.calendarWeekTimelineView.beginningOfWeek toDate:[NSDate lastDateOfWeek:self.calendarWeekTimelineView.beginningOfWeek] forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
    for (Event *event in retVal) {
        if(event.eventTime != NULL){
            TKEvent *tkEvent = [[[TKEvent alloc] init] autorelease];
            DLogInfo(@"event time week view:  %@",event.eventTime);
            tkEvent.eventTime = event.eventTime;
            tkEvent.eventTitle = event.eventName;
            tkEvent.eventEndTime = event.eventEndTime;
            tkEvent.recurrence = event.recurrence;
            tkEvent.eventOccurTime = event.eventOccurTime;
            DLogInfo(@"repeat: %@",event.recurrence);
            [eventsDateArray addObject:tkEvent];
        }
    }
    [[Util sharedUtil] hideLoadingView];
    return eventsDateArray;
}

-(NSArray*)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline fertleInWeekForDate:(NSDate *)eventDate{
    if([MASession sharedSession].currentPartner){
        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE || [MASession sharedSession].currentPartner.birthControl.boolValue){
            return nil;
        }
        
        //only show fertle date if partner is female
        // COMMENT: check if the partner is existed or not. If true then get all events for that partner
        NSMutableArray *fertlesDateArray = [[[NSMutableArray alloc] init] autorelease];
        NSDate *dateStart = [eventDate dateByAddingDays:-7];
        NSDate *dateEnd = [eventDate dateByAddingDays:7];
        [[Util sharedUtil] showLoadingView];
        while (YES) {
            BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveFertileInDate:dateStart];
            
            if (ok) {
                [fertlesDateArray addObject:dateStart];
            }
            
            TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
            info.day++;
            dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
            
            if([dateStart compare:dateEnd] == NSOrderedDescending) break;
        }
        [[Util sharedUtil] hideLoadingView];
        return fertlesDateArray;
    }
    return nil;
}

-(NSArray*)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline menstratingInWeekForDate:(NSDate *)eventDate{
    if([MASession sharedSession].currentPartner){
        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
            return nil;
        }
        
        //only show if the partner is female
        // COMMENT: check if the partner is existed or not. If true then get all events for that partner
        NSMutableArray *menstrationsDateArray = [[[NSMutableArray alloc] init] autorelease];
        NSDate *dateStart = [eventDate dateByAddingDays:-7];
        NSDate *dateEnd = [eventDate dateByAddingDays:7];
        [[Util sharedUtil] showLoadingView];
        while (YES) {
            BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveMenstrationInDate:dateStart];
            if (ok) {
                [menstrationsDateArray addObject:dateStart];
            }
            
            TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
            info.day++;
            dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
            
            if([dateStart compare:dateEnd]==NSOrderedDescending) break;
        }
        [[Util sharedUtil] hideLoadingView];
        return menstrationsDateArray;
    }
    return nil;
}

-(NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline sensitiveInWeekForDate:(NSDate *)eventDate{
//    if([MASession sharedSession].currentPartner){
//        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
//            return nil;
//        }
//        
//        //only show if the partner is female
//        // COMMENT: check if the partner is existed or not. If true then get all events for that partner
//        NSMutableArray *sensitiveDateArray = [[[NSMutableArray alloc] init] autorelease];
//        NSDate *dateStart = [eventDate dateByAddingDays:-7];
//        NSDate *dateEnd = [eventDate dateByAddingDays:7];
//        
//        while (YES) {
//            BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveSensitiveInDate:dateStart];
//            if (ok) {
//                [sensitiveDateArray addObject:dateStart];
//            }
//            
//            TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
//            info.day++;
//            dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
//            
//            if([dateStart compare:dateEnd]==NSOrderedDescending) break;
//        }
//        
//        return sensitiveDateArray;
//    }
    return nil;
}

-(NSNumber *)timelineWeekView:(TKTimelineWeekView *)timelineWeekView moodForDate:(NSDate *)eventDate{
    if([MASession sharedSession].currentPartner){
//        PartnerMood* mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:[MASession sharedSession].currentPartner date:eventDate];
//        
//        TapkuWeeklyViewMoodType type = TapkuWeeklyViewMoodTypeNone;
//        if(mood){
//            if(mood.moodValue.floatValue <= 20){
//                type = TapkuWeeklyViewMoodTypeMood1;
//            }
//            else if(mood.moodValue.floatValue <= 40){
//                type = TapkuWeeklyViewMoodTypeMood2;
//            }
//            else if(mood.moodValue.floatValue <= 60){
//                type = TapkuWeeklyViewMoodTypeMood3;
//            }
//            else if(mood.moodValue.floatValue <= 70){
//                type = TapkuWeeklyViewMoodTypeMood4;
//            }
//            else if(mood.moodValue.floatValue <= 80){
//                type = TapkuWeeklyViewMoodTypeMood5;
//            }
//            else if(mood.moodValue.floatValue <= 90){
//                type = TapkuWeeklyViewMoodTypeMood6;
//            }
//            else{
//                type = TapkuWeeklyViewMoodTypeMood7;
//            }
//        }
        [[Util sharedUtil] showLoadingView];
        CGFloat moodValue = [MoodHelper calculateMoodAtDate:eventDate forPartner:[MASession sharedSession].currentPartner];
        
        TapkuWeeklyViewMoodType type = TapkuWeeklyViewMoodTypeNone;
        if(moodValue >= 0){
            if(moodValue >= 0 && moodValue <= 20){
                type = TapkuMonthlyViewMoodTypeMood1;
            }
            else if(moodValue > 20 && moodValue <= 40){
                type = TapkuMonthlyViewMoodTypeMood2;
            }
            else if(moodValue > 40 && moodValue <= 60){
                type = TapkuMonthlyViewMoodTypeMood3;
            }
            else if(moodValue > 60 && moodValue <= 80){
                type = TapkuMonthlyViewMoodTypeMood4;
            }
            else if(moodValue > 80){
                type = TapkuMonthlyViewMoodTypeMood5;
            }
//          else if(moodValue <= 90){
//               type = TapkuMonthlyViewMoodTypeMood6;
//           }
//           else{
//                        type = TapkuMonthlyViewMoodTypeMood7;
//                    }
        }
        
        NSNumber *mood = [NSNumber numberWithInt:type];
        [[Util sharedUtil] hideLoadingView];
        return mood;
    }
    return nil;
}

- (void)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
	DLog(@"CalendarWeekTimelineView: EventViewWasSelected");
}

- (void)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline tapDetect:(CGPoint)location{
    NSDate *eventDate = [[self.calendarWeekTimelineView getTimeAndDayFromPointWithoutMinute:location] dateByAddingTimeInterval:-1];
    eventDate = [eventDate dateOnly];
    self.eventDateTemp = eventDate;
    self.selectedDate = eventDate;
    [self.eventsView showEventClosestToDate:eventDate isNewInitial:NO isSelected:YES isChangeMonth:NO];
    [self hideModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
}

- (void)calendarPrevWeekClicked:(TKCalendarWeekTimelineView *)calendarWeekTimeline {
    [calendarWeekTimeline.timelineView setSelectedDate:nil];    
    self.selectedDate = nil;
    
    UIView *currentView = self.calendarWeekTimelineView.timelineView;
    UIView *theWindow = [currentView superview];
    self.calendarWeekTimelineView.currentDay = [self.calendarWeekTimelineView.currentDay dateByAddingDays:-7];
    
    if ([[self.calendarWeekTimelineView.currentDay beginningOfWeek] isSameDay:[[NSDate date] beginningOfWeek]]) {
        [self showEventClosestForCurrentMonth];
    } else {
        //load new event to event view
        [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
        if (self.selectedDate) {
            if ([self.selectedDate isAfterDate:self.calendarWeekTimelineView.currentDay]) {
                [self.eventsView showEventClosestToDate:self.calendarWeekTimelineView.currentDay isNewInitial:YES isSelected:NO isChangeMonth:YES];// when next or previous month will refresh selected date.
            } else {
                [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:YES isSelected:NO isChangeMonth:YES];// when next or previous month will refresh selected date.
            }
            
        } else {
            [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:YES];// when next or previous month will refresh selected date.
            // COMMENT: set up an animation for the transition between the views
        }
    }
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[theWindow layer] addAnimation:animation forKey:@"SwitchView"];
}

- (void)calendarNextWeekClicked:(TKCalendarWeekTimelineView *)calendarWeekTimeline {
    [calendarWeekTimeline.timelineView setSelectedDate:nil];
    self.selectedDate = nil;
    
    UIView *currentView = self.calendarWeekTimelineView.timelineView;
    UIView *theWindow = [currentView superview];
    self.calendarWeekTimelineView.currentDay = [self.calendarWeekTimelineView.currentDay dateByAddingDays:7];
    
    //load new event to event view
    if ([[self.calendarWeekTimelineView.currentDay beginningOfWeek] isSameDay:[[NSDate date] beginningOfWeek]]) {
        [self showEventClosestForCurrentMonth];
    } else {
        [self.eventsView reloadViewWithEvents:[self getEventsInWeek:self.calendarWeekTimelineView.beginningOfWeek] eventTimes:[self getEventTimesInWeek:self.calendarWeekTimelineView.beginningOfWeek]];
        if (self.selectedDate) {
            [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:NO isChangeMonth:YES];// when next or previous month will refresh selected date.
        } else {
            [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:NO isSelected:NO isChangeMonth:YES];// when next or previous month will refresh selected date.
            // COMMENT: set up an animation for the transition between the views
        }
    }
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[theWindow layer] addAnimation:animation forKey:@"SwitchView"];
}

- (TKCalendarWeekTimelineView *) calendarWeekTimelineView{
	if (!_calendarWeekTimelineView) {
		_calendarWeekTimelineView = [[TKCalendarWeekTimelineView alloc]initWithFrame:self.view.bounds];
		_calendarWeekTimelineView.delegate = self;
	}
	return _calendarWeekTimelineView;
}

- (void)calendarModeChanged:(TKCalendarWeekTimelineView *)calendarWeekTimeline {
}

// Scroll all scrollviews to the same position
- (void)calendarScrollViewDidScroll:(TKCalendarWeekTimelineView *)calendarWeekTimeline scrollView:(UIScrollView *)scrollView {
}

#pragma mark  - re-handle Closet Date
- (NSArray *)getEventFromCurrentDateToEndDate:(NSDate *)currentDate{
    NSArray *retVal = nil;
    NSDate *startDateConverted = [self convertDateToMomentTimeOfDate:currentDate withFormatTime:@"00:00:00"];
    NSDate *lastDayOfWeek =[self getEndDateOfWeek:currentDate];
    NSDate *lastDateConverted = [self convertDateToMomentTimeOfDate:lastDayOfWeek withFormatTime:@"23:59:59"];
    retVal = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDate:startDateConverted toDate:lastDateConverted forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
    return retVal;

}

- (NSDate *)convertDateToMomentTimeOfDate:(NSDate *)convertDate withFormatTime:(NSString *)formatTime{
    NSDate *resultDate = nil;
    NSString *strConverDate = [NSDate stringFromDate:convertDate];
    NSString *newStr = [strConverDate substringToIndex:11];
    NSString *formatDate = [newStr stringByAppendingFormat:@"%@", formatTime];
    resultDate = [NSDate dateFromString:formatDate];
    return resultDate;
}

- (NSDate *)getEndDateOfWeek:(NSDate *)today{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents     = [gregorian components:NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    NSDateComponents *componentsToSubtract  = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: (0 - [weekdayComponents weekday]) + 2];
    [componentsToSubtract setHour: 0 - [weekdayComponents hour]];
    [componentsToSubtract setMinute: 0 - [weekdayComponents minute]];
    [componentsToSubtract setSecond: 0 - [weekdayComponents second]];
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    NSDateComponents *componentsToAdd = [gregorian components:NSDayCalendarUnit fromDate:beginningOfWeek];
    [componentsToAdd setDay:6];
    NSDate *endOfWeek = [gregorian dateByAddingComponents:componentsToAdd toDate:beginningOfWeek options:0];
    return endOfWeek;
}
@end
