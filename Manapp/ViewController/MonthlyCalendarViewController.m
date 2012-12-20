//
//  MonthlyCalendarViewController.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MonthlyCalendarViewController.h"
#import "AddEventViewController.h"

@interface MonthlyCalendarViewController ()
- (void) initializeData;
- (void) initializeCalendar;
- (void) initializeEventView;
- (void) initializeMenstruationView;
@end

@implementation MonthlyCalendarViewController
@synthesize calendarMonthView = _calendarMonthView;
@synthesize scrollViewBackground = _scrollViewBackground;
@synthesize viewCalendarPlaceHolder = _viewCalendarPlaceHolder;
@synthesize btnBack = _btnBack;
@synthesize btnWeek = _btnWeek;
@synthesize eventsView = _eventsView;
@synthesize menstruationView = _menstruationView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare data
    [self initializeData];
    
    //prepare UI
    [self initializeCalendar];
    [self initializeEventView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollViewBackground release];
    [_viewCalendarPlaceHolder release];
    [_btnBack release];
    [_btnWeek release];
    [_calendarMonthView release];
    [_eventsView release];
    [_menstruationView release];
    [super dealloc];
}

#pragma mark - init functions

- (void) initializeData{
    
}
- (void) initializeCalendar{
    // COMMENT: monthly calendar view
    if (self.calendarMonthView == nil) {
        self.calendarMonthView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES];
        self.calendarMonthView.delegate = self;
        self.calendarMonthView.dataSource = self;
        self.calendarMonthView.backgroundColor = [UIColor clearColor];
        [self.viewCalendarPlaceHolder addSubview:self.calendarMonthView];
        
        //reload the calendar
        [self.calendarMonthView reload];
    }
}

- (void) initializeEventView{
    self.eventsView.frame = CGRectMake(0 , self.scrollViewBackground.frame.size.height - self.eventsView.frame.size.height, self.eventsView.frame.size.width, self.eventsView.frame.size.height);
    self.eventsView.delegate = self;
    [self.scrollViewBackground addSubview:self.eventsView];
    [self.eventsView reloadViewWithEvents:nil];
}

- (void) initializeMenstruationView{
    self.menstruationView.frame = CGRectMake(0 , 0, self.menstruationView.frame.size.width, self.menstruationView.frame.size.height);
}

#pragma mark - event handler
- (IBAction)btnBack_touchUpInside:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnWeek_touchUpInside:(id)sender {
    
}

#pragma mark - TKCalendar datasource
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
	return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView eventsFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView fertleFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    return nil;
}

-(NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView menstratingFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate{
    return nil;
}

#pragma mark - TKCalendar delegate
/**********************************************************
 @Function description: select a date will display that date's event on the details view
 @Note:
 ***********************************************************/
-(void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date{
    
}

#pragma mark - EventViews delegate
-(void)didTouchAddEventButtonInEventsView:(EventsView *)view{
    //add event view
    AddEventViewController *addEventViewController = [self getViewControllerByName:@"AddEventViewController"];
    //addEventViewController.delegate = self;
    UINavigationController *addEventNavigationViewController = [[[UINavigationController alloc] initWithRootViewController:addEventViewController] autorelease];
    [self presentViewController:addEventNavigationViewController animated:YES completion:^{}];
}

-(void)didTouchMenstrationButtonInEventsView:(EventsView *)view{
    [self showModalView:self.menstruationView direction:MAModalViewDirectionBottom autoAddSubView:YES];
}

-(void)didTouchRemoveEventButtonInEventsView:(EventsView *)view{
    
}

@end
