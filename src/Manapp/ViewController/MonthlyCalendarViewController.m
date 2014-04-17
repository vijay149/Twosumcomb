//
//  MonthlyCalendarViewController.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MonthlyCalendarViewController.h"
#import "HomepageViewController.h"
#import "MASession.h"
#import "Partner.h"
#import "Event.h"
#import "DatabaseHelper.h"
#import "NSDate+Helper.h"
#import "PartnerMood.h"
#import "MoodHelper.h"
#import "Util.h"
#import "LocalNotificationHelper.h"
#import "MenstruationUtil.h"
#import "NSDate+Mic.h"
#import "EGOCache.h"

@interface MonthlyCalendarViewController () {
    BOOL fromSelectingDate;
}
- (void) initializeData;
- (void) initializeCalendar;
- (void) initializeEventView;
- (void) initializeMenstruationView;
- (NSArray *) getEventsInMonth:(NSDate *)month;
- (void) backToHome;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDate *currentDate;
@property (strong, nonatomic) NSDate *finalDate;
@end

@implementation MonthlyCalendarViewController
@synthesize calendarMonthView = _calendarMonthView;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize viewCalendarPlaceHolder = _viewCalendarPlaceHolder;
@synthesize btnBack = _btnBack;
@synthesize btnWeek = _btnWeek;
@synthesize eventsView = _eventsView;
@synthesize menstruationView = _menstruationView;
@synthesize eventsFromCurrentToEndMonth;

- (void)dealloc {
    [_scrollViewBackground release];
    [_viewCalendarPlaceHolder release];
    [_btnBack release];
    [_btnWeek release];
    [_calendarMonthView release];
    [_eventsView release];
    [_menstruationView release];
    [_selectedDate release];
    [_currentDate release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initializeData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Remove all cached data
    [[EGOCache globalCache] clearCache];
    
    //prepare data
    
    //prepare UI
    [self loadUI];
    [self initializeCalendar];
    [self initializeEventView];
    [self initializeMenstruationView];
    [MenstruationUtil checkCurrentDateWithCountDownDateMenstruation];
    
    [self showEventClosestForCurrentMonth];
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.selectedDate &&
        [self.selectedDate getMonth] == [self.calendarMonthView.monthDate getMonth]) {
        [self.calendarMonthView selectDate:self.selectedDate];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}



#pragma mark - init functions

- (void) initializeData{
    
}

-(void) loadUI {
    [self createBackNavigationWithTitle:@"Home" action:@selector(backToHome)];
    [self createRightNavigationWithTitle:@"Week" action:@selector(btnWeek_touchUpInside:)];
    
    //this eventView is attach to a monthly calendar
    self.eventsView.isMonthly = YES;
    
}

- (void) initializeCalendar {
    // COMMENT: monthly calendar view
    if (self.calendarMonthView == nil) {
        _calendarMonthView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES];
        self.calendarMonthView.delegate = self;
        self.calendarMonthView.dataSource = self;
        self.calendarMonthView.backgroundColor = [UIColor clearColor];
        [self.viewCalendarPlaceHolder addSubview:self.calendarMonthView];
        
        //reload the calendar
        [self.calendarMonthView reload];
    }
}

- (void) initializeEventView {

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
        [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
        [self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate];
    }
    else{
        [self.eventsView reloadViewWithEvents:nil eventTimes:nil];
    }
    self.eventsView.scrollViewEvents.hidden = NO;
    [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:NO];
    self.currentDate = [NSDate date];
//    self.finalDate = [NSDate lastDateOfMonth:self.currentDate];
    self.finalDate = [NSDate finalDateOfMonth];
}

- (void) initializeMenstruationView {
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
- (NSArray *) getEventsInMonth:(NSDate *)month{
    if([MASession sharedSession].currentPartner){
        NSDate *firstDateOfMonth = [[Util sharedUtil] firstDateOfMonth:month];
        NSDate *lastDayOfMonth = nil;
        NSDate *dateTem = month;
        if (firstDateOfMonth) {
            if ([firstDateOfMonth isSameDay:month]) {
                lastDayOfMonth = [NSDate lastDateOfMonth:month];
            } else {
                lastDayOfMonth = [NSDate firstDateOfMonth:month];
                month = lastDayOfMonth;
                lastDayOfMonth = dateTem;
            }
        }
        NSArray *retVal = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDateForMonthView:firstDateOfMonth toDate:lastDayOfMonth forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        
        DLogInfo(@"retVal = %@", retVal);
        return retVal;
    }
    
    return [[[NSArray alloc] init] autorelease];
}

- (NSArray *) getEventsWithCorrectTimeInMonth:(NSDate *)month{
    if([MASession sharedSession].currentPartner){
        NSDate *firstDateOfMonth = [[Util sharedUtil] firstDateOfMonth:month];
        NSDate *lastDayOfMonth = nil;
        NSDate *dateTem = month;
        if (firstDateOfMonth) {
            if ([firstDateOfMonth isSameDay:month]) {
                lastDayOfMonth = [NSDate lastDateOfMonth:month];
            } else {
                lastDayOfMonth = [NSDate firstDateOfMonth:month];
                month = lastDayOfMonth;
                lastDayOfMonth = dateTem;
            }
        }
        NSArray *retVal = [[DatabaseHelper sharedHelper] getEventWithCorrectTimeValueForMonthView:firstDateOfMonth toDate:lastDayOfMonth forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        
        DLogInfo(@"retVal = %@", retVal);
        return retVal;
    }
    
    return [[[NSArray alloc] init] autorelease];
}

#pragma mark - event handler

- (IBAction)btnWeek_touchUpInside:(id)sender {
    // check for show monthly or week
    [UserDefault setValue:@"YES" forKey:kIsWeek];
    [UserDefault synchronize];
    WeeklyCalendarViewController *weekViewController = [self getViewControllerByName:@"WeeklyCalendarViewController"];
    weekViewController.delegate = self;
    weekViewController.delegateOfMonthView = self;
    self.selectedDate = nil;
    [self nextTo:weekViewController];
}


#pragma mark - text field delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return TRUE;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return TRUE;
}

#pragma mark - TKCalendar datasource
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView eventsFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    DLogInfo(@"startDate: %@ - last date: %@",startDate, lastDate);
    [[Util sharedUtil] showLoadingView];
    NSArray *retVal = [[DatabaseHelper sharedHelper] getAllOccurEventFromDate:startDate toDate:lastDate forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
    DLogInfo(@"retVal = %@", retVal);
    [[Util sharedUtil] hideLoadingView];
    return retVal;
    
    /*
    // COMMENT: get all the event happen at the date range
    NSMutableArray* eventArray = [[[NSMutableArray alloc] init] autorelease];
    // COMMENT: check if the partner is existed or not
    if([MASession sharedSession].currentPartner){
        NSDate *dateStart = startDate;
        while(YES){
            NSInteger numberOfEvents = 0;
            
            // COMMENT: check to see if the current day have any event, if true then push a mark to array to display an icon on this day later
            NSArray* partnerEvents = [[DatabaseHelper sharedHelper] getAllEventOccurAtDate:dateStart forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
            
            if(partnerEvents != NULL && [partnerEvents count] > 0){
                numberOfEvents = partnerEvents.count;
            }
            
            
            [eventArray addObject:[NSNumber numberWithInt:numberOfEvents]];
            
            TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
            info.day++;
            dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
            
            // COMMENT: if the current day is the last date, break from the loop
            if([dateStart compare:lastDate]==NSOrderedDescending) break;
        }
    }
    

    return eventArray;*/
}



-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView fertleFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    if([MASession sharedSession].currentPartner){
        [[Util sharedUtil] showLoadingView];
        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE || [MASession sharedSession].currentPartner.birthControl.boolValue){
            return nil;
        }
        
        //only show fertle if the partner is female
        NSMutableArray* fertleArray = [[[NSMutableArray alloc] init] autorelease];
        
        // COMMENT: check if the partner is existed or not
        if([MASession sharedSession].currentPartner){
            NSDate *dateStart = startDate;
            while(YES){
                // Check to see if the current day is fertle day or not
                BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveFertileInDate:dateStart];
                
                [fertleArray addObject:[NSNumber numberWithBool:ok]];
                
                TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
                info.day++;
                dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
                
                // COMMENT: if the current day is the last date, break from the loop
                if([dateStart compare:lastDate]==NSOrderedDescending) break;
            }
        }
        [[Util sharedUtil] hideLoadingView];
        return fertleArray;
    }
    return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView menstratingFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    if([MASession sharedSession].currentPartner){
        [[Util sharedUtil] showLoadingView];
        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
            return nil;
        }
        
        //only show menstration if the partner is female
        NSMutableArray* menstrationArray = [[[NSMutableArray alloc] init] autorelease];
        
        if([MASession sharedSession].currentPartner){
            NSDate *dateStart = startDate;
            while(YES){
                // COMMENT: check to see if the current day have any event, if true then push a mark to array to display an icon on this day later
                
                BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveMenstrationInDate:dateStart];
                
                [menstrationArray addObject:[NSNumber numberWithBool:ok]];
                
                TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
                info.day++;
                dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
                
                // COMMENT: if the current day is the last date, break from the loop
                if([dateStart compare:lastDate]==NSOrderedDescending) break;
            }
        }
        [[Util sharedUtil] hideLoadingView];
        return menstrationArray;
    }
    return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView sensitiveFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
//    if([MASession sharedSession].currentPartner){
//        if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
//            return nil;
//        }
//        
//        //only show menstration if the partner is female
//        NSMutableArray* menstrationArray = [[[NSMutableArray alloc] init] autorelease];
//        
//        if([MASession sharedSession].currentPartner){
//            NSDate *dateStart = startDate;
//            while(YES){
//                // COMMENT: check to see if the current day have any event, if true then push a mark to array to display an icon on this day later
//                
//                BOOL ok = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveSensitiveInDate:dateStart];
//                
//                [menstrationArray addObject:[NSNumber numberWithBool:ok]];
//                
//                TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
//                info.day++;
//                dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
//                
//                // COMMENT: if the current day is the last date, break from the loop
//                if([dateStart compare:lastDate]==NSOrderedDescending) break;
//            }
//        }
//        
//        return menstrationArray;
//    }
    return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView moodFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    if([MASession sharedSession].currentPartner){
        [[Util sharedUtil] showLoadingView];
        NSMutableArray* moodArray = [[[NSMutableArray alloc] init] autorelease];
        int count = 0;
        if([MASession sharedSession].currentPartner){
            NSDate *dateStart = startDate;
            while(YES){
                count++;
                DLogInfo(@"count %d",count);
                // COMMENT: check to see if the current day have any event, if true then push a mark to array to display an icon on this day later
//                PartnerMood* mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:[MASession sharedSession].currentPartner date:dateStart];
                TapkuMonthlyViewMoodType type = TapkuMonthlyViewMoodTypeNone;
//                if(mood){
//                    if(mood.moodValue.floatValue <= 20){
//                        type = TapkuMonthlyViewMoodTypeMood1;
//                    }
//                    else if(mood.moodValue.floatValue <= 40){
//                        type = TapkuMonthlyViewMoodTypeMood2;
//                    }
//                    else if(mood.moodValue.floatValue <= 60){
//                        type = TapkuMonthlyViewMoodTypeMood3;
//                    }
//                    else if(mood.moodValue.floatValue <= 70){
//                        type = TapkuMonthlyViewMoodTypeMood4;
//                    }
//                    else if(mood.moodValue.floatValue <= 80){
//                        type = TapkuMonthlyViewMoodTypeMood5;
//                    }
//                    else if(mood.moodValue.floatValue <= 90){
//                        type = TapkuMonthlyViewMoodTypeMood6;
//                    }
//                    else{
//                        type = TapkuMonthlyViewMoodTypeMood7;
//                    }
//                }
                CGFloat moodValue = [MoodHelper calculateMoodAtDate:dateStart forPartner:[MASession sharedSession].currentPartner];
                
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
//                    else if(moodValue <= 90){
//                        type = TapkuMonthlyViewMoodTypeMood6;
//                    }
//                    else{
//                        type = TapkuMonthlyViewMoodTypeMood7;
//                    }
                }
                else{
//                    type = TapkuMonthlyViewMoodTypeMood1;
                    type = TapkuMonthlyViewMoodTypeNone;
                }
                
                
                [moodArray addObject:[NSNumber numberWithInt:type]];
                
                TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
                info.day++;
                dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
                
                // COMMENT: if the current day is the last date, break from the loop
                if([dateStart compare:lastDate]==NSOrderedDescending) break;
            }
        }
        [[Util sharedUtil] hideLoadingView];
        return moodArray;
    }
    return nil;
}

#pragma mark - TKCalendar delegate
/**********************************************************
 @Function description: select a date will display that date's event on the details view
 @Note:
 ***********************************************************/
-(void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date{
    [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
    [self.eventsView showEventClosestToDate:date isNewInitial:NO isSelected:YES isChangeMonth:NO];
    self.selectedDate = date;
    DLogInfo(@"self.selectedDate %@",self.selectedDate);
    [self hideModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
    fromSelectingDate = YES;
}

- (void)showEventClosestForCurrentMonth
{
    [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
    [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:YES isSelected:NO isChangeMonth:YES events:[self getAllEventFromCurrentDateToEndDateOfMonth] isCurrentDay:YES];
}

-(void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated{
    if (!fromSelectingDate) {
        self.selectedDate = nil;
    }
    fromSelectingDate = NO;
    
    [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
    NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [inputFormatter setDateFormat:@"dd/MM/yyyy"];
    NSInteger monthResult = [[[NSCalendar currentCalendar] components: NSMonthCalendarUnit fromDate: [NSDate date] toDate: month options: 0] month];
    NSLog(@"---------------------------->>%d", monthResult);
    if (monthResult >= 0) {
        if ([month compare:[NSDate date]] == NSOrderedAscending || [month compare:[NSDate date]] == NSOrderedSame) {
            [self showEventClosestForCurrentMonth];
        } else {
            if (self.selectedDate) {
                BOOL isLastDayOfMonth = [[Util sharedUtil] isLastDateOfMonth:self.selectedDate];
                if (isLastDayOfMonth) {
                    [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:YES isChangeMonth:YES];
                    self.selectedDate = nil;
                } else {
                    [self.eventsView showEventClosestToDate:month isNewInitial:NO isSelected:NO isChangeMonth:YES];
                }
            } else {
                [self.eventsView showEventClosestToDate:month isNewInitial:NO isSelected:NO isChangeMonth:YES];
            }
        }
    } else {
        [self.eventsView showEventClosestToDate:[NSDate date] isNewInitial:NO isSelected:NO isChangeMonth:YES];
    }
}

#pragma mark - EventViews delegate
-(void)didTouchAddEventButtonInEventsView:(EventsView *)view{
    //add event view
    AddEventViewController *addEventViewController = [self getViewControllerByName:@"AddEventViewController"];
    DLogInfo(@"date selected 2222: %@",[self.calendarMonthView dateSelected]);
    if (![self.calendarMonthView dateSelected]) {
        [self.calendarMonthView selectDate:[NSDate date]];
    }
    addEventViewController.selectedDate = [self.calendarMonthView dateSelected];
    DLogInfo(@"date %@",[self.calendarMonthView dateSelected]);
    addEventViewController.delegate = self;
    UINavigationController *addEventNavigationViewController = [[[UINavigationController alloc] initWithRootViewController:addEventViewController] autorelease];
    [self presentViewController:addEventNavigationViewController animated:YES completion:^{}];
}

-(void)didTouchMenstrationButtonInEventsView:(EventsView *)view{
    [self showModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
    [self.menstruationView fillViewWithPartnerData:[MASession sharedSession].currentPartner];
    if([MASession sharedSession].currentPartner && [MASession sharedSession].currentPartner.isNewForCycle.boolValue){
        [self showMessage:@"TwoSum is not to be used for pregnancy planning or prevention"];
        
        [[DatabaseHelper sharedHelper] updateFirstTimeUserCycleStatus:NO forPartner:[MASession sharedSession].currentPartner];
    }
}

-(void)didTouchRemoveEventButtonInEventsView:(EventsView *)view{
    Event *currentEvent = [self.eventsView getSelectedEvent];
    if(currentEvent){
        AddEventViewController *addEventViewController = [self getViewControllerByName:@"AddEventViewController"];
        [addEventViewController changeUIToEditModeWithEvent:currentEvent];
        addEventViewController.delegate = self;
        UINavigationController *addEventNavigationViewController = [[[UINavigationController alloc] initWithRootViewController:addEventViewController] autorelease];
        [self presentViewController:addEventNavigationViewController animated:YES completion:^{}];
    }
}

#pragma mark - AddEventViewControllerDelegate
-(void)addEventViewControllerDidDeleteEvent:(AddEventViewController *)view{
    [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
    [self.calendarMonthView reload];
    [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:YES isChangeMonth:NO];
    if (self.selectedDate) {
        DLogInfo(@"self.selectedDate %@",self.selectedDate);
//        [self.calendarMonthView selectDate:[self.selectedDate dateByAddingDays:1]];
    }
    
}

-(void)addEventViewControllerDidSaveEvent:(AddEventViewController *)view{
    [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
    [self.calendarMonthView reload];
    [self.eventsView showEventClosestToDate:self.selectedDate isNewInitial:NO isSelected:YES isChangeMonth:NO];
    if (self.selectedDate) {
        DLogInfo(@"self.selectedDate %@",self.selectedDate);
//        [self.calendarMonthView selectDate:[self.selectedDate dateByAddingDays:1]];
    }
}

#pragma mark - menstruation view delegate
- (void)menstruationViewDidTouchSaveButton:(MenstruationView *)view{
    if ([self.menstruationView.txtFirstPeriod.text isEqualToString:MANAPP_MENSTRATIONVIEW_DEFAULT_LAST_PERIOD]) {
        [self showMessage:@"Please enter the first day of your's partner last period"];
    }
    else if([MASession sharedSession].currentPartner){
        NSDate *lastPeriod = [NSDate dateFromString:self.menstruationView.txtFirstPeriod.text withStyle:MANAPP_DATETIME_DEFAULT_TYPE];
        BOOL saveResult = [[DatabaseHelper sharedHelper] setMenstruationForPartner:[[MASession sharedSession].currentPartner.partnerID intValue] lastPeriod:lastPeriod usingBirthControl:self.menstruationView.checkBoxYes.isChecked];
        NSLog(@"lastPeriod: %@",lastPeriod);
        if(saveResult){
            // save date  menstruation expiration alert
            // 120 will show alert expiration.
            // change [NSDate date] to : lastPeriod
            [Util setValue:[lastPeriod dateByAddDays:120] forKey:kMenstruatationExpiration];
            //            [Util setValue:[[NSDate date] dateByAddMinute:1] forKey:kMenstruatationExpiration];
            [Util setValue:[NSNumber numberWithInt:0] forKey:kCountDownMenstruatationExpiration];
            [Util setValue:[NSNumber numberWithBool:NO] forKey:kMessageShowed];
            [[MASession sharedSession] reloadPartner];
            [self showMessage:@"Menstruation data saved, the road to happiness partially paved" title:kAppName cancelButtonTitle:@"Close" delegate:self tag:-1];
        }
    }else{
        [self showMessage:@"Please create partner before editing"];
    }
    
    [self.calendarMonthView reload];
}



#define mark - UIAlertViewDelegate
//// hiden menstruation View
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"buttonIndex %d",buttonIndex);
    [self menstruationViewDidTouchBackButton:nil];
}



-(void) menstruationViewDidTouchBackButton:(MenstruationView *)view{
    [self hideModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
}

#pragma mark - week calendar view delegate
-(void)didChangeEventInWeeklyCalendar:(WeeklyCalendarViewController *)vc {
    if ([self.calendarMonthView.monthDate getMonth] == [[NSDate date] getMonth]) {
        [self showEventClosestForCurrentMonth];
    } else {
        [self.eventsView reloadViewWithEvents:[self getEventsInMonth:self.calendarMonthView.monthDate] eventTimes:[self getEventsWithCorrectTimeInMonth:self.calendarMonthView.monthDate]];
        [self.eventsView showEventClosestToDate:self.calendarMonthView.monthDate isNewInitial:NO isSelected:NO isChangeMonth:NO];
    }
    [self.calendarMonthView reload];
}

- (void) backToHome {
    [self popToView:[HomepageViewController class]];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - Check ClosetDate that has event
-(NSMutableArray *)getEventsFromTKCalendarMonthView:(TKCalendarMonthView *)monthView eventsFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{

    NSMutableArray *result = nil;
    [[Util sharedUtil] showLoadingView];
    NSArray *retVal = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDateForMonthView:startDate toDate:lastDate forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];

    DLogInfo(@"retVal = %@", retVal);
    [[Util sharedUtil] hideLoadingView];
    result = [NSMutableArray arrayWithArray:retVal];
    return result;
}

- (NSDate *)convertDateToMomentTimeOfDate:(NSDate *)convertDate withFormatTime:(NSString *)formatTime{
    NSDate *resultDate = nil;
    NSString *strConverDate = [NSDate stringFromDate:convertDate];
    NSString *newStr = [strConverDate substringToIndex:11];
    NSString *formatDate = [newStr stringByAppendingFormat:@"%@", formatTime];
    resultDate = [NSDate dateFromString:formatDate];
    return resultDate;
}

- (NSMutableArray *)getAllEventFromCurrentDateToEndDateOfMonth{
    NSMutableArray *result = nil;
    NSDate *startDate = [self convertDateToMomentTimeOfDate:self.currentDate withFormatTime:@"00:00:00"];
    NSDate *endDate = [self.finalDate lastOfMonthDate];
    result = [self getEventsFromTKCalendarMonthView:self.calendarMonthView eventsFromDate:startDate toDate:endDate];
    return result;
}


- (void)setNilForSelectedDate{
    self.selectedDate = nil;
}
@end
