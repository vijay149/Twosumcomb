//
//  TKCalendarWeekTimelineView.m
//  Based on TKCalendarDayTimelineView by Devin Ross.
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarWeekTimelineView.h"
#import "NSDate+TKCategory.h"
#import "UIImage+TKCategory.h"
#import "TKGlobal.h"
#import "TKEvent.h"
#import "NSDate+Helper.h"
#define HORIZONTAL_OFFSET 1.0
#define VERTICAL_OFFSET 5.0
#define PERIOD_VERT_OFFSET 15.0

#define TIME_WIDTH 0.0
#define TIME_PADDING_LEFT 0.0
//#define TIME_PADDING_LEFT 9.0
//#define TIME_WIDTH 12.0
#define PERIOD_WIDTH 16.0

#define FONT_SIZE 10.0

#define HORIZONTAL_LINE_DIFF 10.0

#define TOP_BAR_HEIGHT 65.0

#define VERTICAL_DIFF_WEEK 1
#define TIMELINE_HEIGHT 32*VERTICAL_OFFSET+23*VERTICAL_DIFF_WEEK

#define EVENT_VERTICAL_DIFF 0.0
#define EVENT_HORIZONTAL_DIFF 2.0

#define EVENT_SAME_HOUR 0.0


@interface TKCalendarWeekTimelineView (private)
@property (readonly) UIImageView *topBackground;
@property (readonly) UILabel *monthYear;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UIImageView *shadow;

@end


@implementation TKCalendarWeekTimelineView

@synthesize delegate=_delegate;
@synthesize events=_events;
@synthesize currentDay=_currentDay;
@synthesize beginningOfWeek=_beginningOfWeek;
@synthesize timelineColor, is24hClock, hourColor, isFiveDayWeek, is15Min, isFirstDayMonday, isHideWeekNumber;

#pragma mark -
#pragma mark Initialisation

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)redrawAllView {
    [self reloadDay];
    [self.timelineView setNeedsDisplay];
}

- (void)setupCustomInitialisation
{
	// Initialization code
	self.events = nil;
	self.currentDay = nil;

	[self addSubview:self.topBackground];
	
	[self addSubview:self.monthYear];
	
	[self addSubviewDayLabels];
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
		
	// Add main scroll view
    self.scrollView.delegate = self;
	[self addSubview:self.scrollView];
	// Add timeline view inside scrollview
	[self.scrollView addSubview:self.timelineView];
	// Get notified when current day is changed
	// Observe when app got online (facebook connect)
	[self addObserver:self forKeyPath: @"currentDay"
					 options:0
					 context:@selector(reloadDay)];
	
    timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(redrawAllView) userInfo:nil repeats:YES];
	[self setupGestureRecognition];
}

- (void) addSubviewDayLabels {
	// Add labels for days, either five or seven
	for (NSInteger i=1; i<=(isFiveDayWeek ? 5 : 7); i++) {
		CGRect dayLabelRect = [self getViewRectForDay:i];
		dayLabelRect.origin.y = 30.0;
		dayLabelRect.size.height = 15.0;
		if (i==1) { 
            day1 = [self dayLabel:day1 inRect:dayLabelRect]; 
            [self addSubview:day1];
            day1.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day1.layer.cornerRadius = 4.0;
            day1.layer.shadowOffset = CGSizeMake(0, 1);
            day1.layer.shadowRadius = 0.3;
            day1.layer.shadowColor = [UIColor whiteColor].CGColor;
            day1.layer.shadowOpacity = 0.5;

        }
		if (i==2) { 
            day2 = [self dayLabel:day2 inRect:dayLabelRect]; 
            [self addSubview:day2];
            day2.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day2.layer.cornerRadius = 4.0;
            day2.layer.shadowOffset = CGSizeMake(0, 1);
            day2.layer.shadowRadius = 0.3;
            day2.layer.shadowColor = [UIColor whiteColor].CGColor;
            day2.layer.shadowOpacity = 0.5;
        }
		if (i==3) { 
            day3 = [self dayLabel:day3 inRect:dayLabelRect]; 
            [self addSubview:day3];
            day3.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day3.layer.cornerRadius = 4.0;
            day3.layer.shadowOffset = CGSizeMake(0, 1);
            day3.layer.shadowRadius = 0.3;
            day3.layer.shadowColor = [UIColor whiteColor].CGColor;
            day3.layer.shadowOpacity = 0.5;
        }
		if (i==4) { 
            day4 = [self dayLabel:day4 inRect:dayLabelRect]; 
            [self addSubview:day4];
            day4.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day4.layer.cornerRadius = 4.0;
            day4.layer.shadowOffset = CGSizeMake(0, 1);
            day4.layer.shadowRadius = 0.3;
            day4.layer.shadowColor = [UIColor whiteColor].CGColor;
            day4.layer.shadowOpacity = 0.5;
        }
		if (i==5) { 
            day5 = [self dayLabel:day5 inRect:dayLabelRect]; 
            [self addSubview:day5];
            day5.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day5.layer.cornerRadius = 4.0;
            day5.layer.shadowOffset = CGSizeMake(0, 1);
            day5.layer.shadowRadius = 0.3;
            day5.layer.shadowColor = [UIColor whiteColor].CGColor;
            day5.layer.shadowOpacity = 0.5;
        }
		if (i==6) { 
            day6 = [self dayLabel:day6 inRect:dayLabelRect]; 
            [self addSubview:day6];
            day6.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day6.layer.cornerRadius = 4.0;
            day6.layer.shadowOffset = CGSizeMake(0, 1);
            day6.layer.shadowRadius = 0.3;
            day6.layer.shadowColor = [UIColor whiteColor].CGColor;
            day6.layer.shadowOpacity = 0.5;
        }
		if (i==7) { 
            day7 = [self dayLabel:day7 inRect:dayLabelRect]; 
            [self addSubview:day7];
            day7.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            day7.layer.cornerRadius = 4.0;
            day7.layer.shadowOffset = CGSizeMake(0, 1);
            day7.layer.shadowRadius = 0.3;
            day7.layer.shadowColor = [UIColor whiteColor].CGColor;
            day7.layer.shadowOpacity = 0.5;
        }
	}
}

- (CGRect) getViewRectForDay:(int)day {
	// For gregorian day index, return view rect
	// TODO: Not very DRY, method repeated in _timelineView
	float weekday_width = (self.bounds.size.width - HORIZONTAL_OFFSET - TIME_WIDTH - TIME_PADDING_LEFT) / (isFiveDayWeek ? 5 : 7);
	
	return CGRectMake(HORIZONTAL_OFFSET + TIME_WIDTH + TIME_PADDING_LEFT + (day-1)*weekday_width, 0.0, weekday_width, self.timelineView.bounds.size.height);
}

- (UILabel *) dayLabel:(UILabel *)uilabel inRect:(CGRect)r {
	if(uilabel==nil){
		uilabel = [[UILabel alloc] initWithFrame:r];
		uilabel.textAlignment = UITextAlignmentCenter;
		uilabel.backgroundColor = [UIColor clearColor];
		uilabel.font = [UIFont fontWithName:@"BankGothic Md BT" size:14];
		uilabel.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return [uilabel autorelease];
}

#pragma mark -
#pragma mark Execut Method When Notification Fire

//help executing a method when a notification fire
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self performSelector: (SEL)context withObject: change];
} 

#pragma mark -
#pragma mark Setup

- (UIScrollView *)scrollView
{
	if (!_scrollView) {
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, TOP_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height-TOP_BAR_HEIGHT - 200)];
		_scrollView.contentSize = CGSizeMake(self.bounds.size.width,TIMELINE_HEIGHT);
		_scrollView.scrollEnabled = TRUE;
		_scrollView.backgroundColor =[UIColor clearColor];
		_scrollView.alwaysBounceVertical = TRUE;
	}
	return _scrollView;
}

- (TKTimelineWeekView *)timelineView
{
	if (!_timelineView) {
		_timelineView = [[TKTimelineWeekView alloc]initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, TIMELINE_HEIGHT)];
		_timelineView.backgroundColor = [UIColor clearColor];
		_timelineView.delegate = self;
        _timelineView.dataSource = self;
		_timelineView.isFiveDayWeek = self.isFiveDayWeek;
	}
	return _timelineView;
}

- (void)setIsFirstDayMonday:(BOOL)_isFirstDayMonday {
    isFirstDayMonday = _isFirstDayMonday;
    [self reloadDay];
    [_timelineView setNeedsDisplay];
}

-(void)setCurrentDay:(NSDate *)currentDay {
    _currentDay = [currentDay retain];
    [self reloadDay];
    [self.timelineView setNeedsDisplay];
}

-(void)setTimelineColor:(UIColor*) aColor {
	_timelineView.backgroundColor = aColor;
}

-(void)setIs24hClock:(BOOL)aIs24hClock {
    is24hClock = aIs24hClock;
	_timelineView.is24hClock = aIs24hClock;
    [self reloadDay];
    [self.timelineView setNeedsDisplay];
}

-(void)setIsFiveDayWeek:(BOOL)aIsFiveDayWeek {
	_timelineView.isFiveDayWeek = aIsFiveDayWeek;
	isFiveDayWeek = aIsFiveDayWeek;
	
	// Update day labels
    if (isFiveDayWeek) {
        for (NSInteger i=1; i<=5; i++) {
            CGRect dayLabelRect = [self getViewRectForDay:i];
            dayLabelRect.origin.y = 30.0 + TKCALENDAR_WEEK_CONTROL_TOP_PADDING;
            dayLabelRect.size.height = 15.0;
            if (i==1) { day1.frame = dayLabelRect; }
            if (i==2) { day2.frame = dayLabelRect; }
            if (i==3) { day3.frame = dayLabelRect; }
            if (i==4) { day4.frame = dayLabelRect; }
            if (i==5) { day5.frame = dayLabelRect; }
            day6.frame = CGRectNull;
            day7.frame = CGRectNull;
        }
    } else {
        for (NSInteger i=1; i<=7; i++) {
            CGRect dayLabelRect = [self getViewRectForDay:i];
            dayLabelRect.origin.y = 30.0 + TKCALENDAR_WEEK_CONTROL_TOP_PADDING;
            dayLabelRect.size.height = 15.0;
            if (i==1) { day1.frame = dayLabelRect; }
            if (i==2) { day2.frame = dayLabelRect; }
            if (i==3) { day3.frame = dayLabelRect; }
            if (i==4) { day4.frame = dayLabelRect; }
            if (i==5) { day5.frame = dayLabelRect; }
            if (i==6) { day6.frame = dayLabelRect; }
            if (i==7) { day7.frame = dayLabelRect; }
        }
    }
	// Redraw timeline view
	[self reloadDay];
	[self.timelineView setNeedsDisplay];
}

- (void)setIs15Min:(BOOL)aIs15Min {
    _timelineView.is15Min = aIs15Min;
    is15Min = aIs15Min;
    [self reloadDay];
    [self.timelineView setNeedsDisplay];
}

- (void)setIsHideWeekNumber:(BOOL)aisHideWeekNumber {
    isHideWeekNumber = aisHideWeekNumber;
    [self reloadDay];
}
#pragma mark -
#pragma mark View Event

- (void)didMoveToWindow
{
	if (self.window != nil) {
		[self reloadDay];
	}
}

#pragma mark -
#pragma mark Reload Day

- (void)reloadDay
{
	// If no current day was given
	// Make it today
	if (!self.currentDay) {
		// Dont' want to inform the observer
		_currentDay = [[NSDate date] retain];
	}
	// Remove all previous view event
	for (id view in self.scrollView.subviews) {
		if (![NSStringFromClass([view class])isEqualToString:@"TKTimelineWeekView"]) {
			[view removeFromSuperview];
		}
	}	
    for (id view in [_timelineView subviews]) {
        [view removeFromSuperview];
    }
	// Determine the first day of the current week
	// From http://stackoverflow.com/questions/3519207/how-to-calculate-first-nsdate-of-current-week
	NSCalendar *gregorian = [NSCalendar currentCalendar];
	NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit fromDate:_currentDay];
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: - ([weekdayComponents weekday] - [gregorian firstWeekday] - (isFirstDayMonday? 0 : 1))];	// Default Monday as first work day
	self.beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract toDate:_currentDay options:0];
	self.timelineView.beginningOfWeek = self.beginningOfWeek;
    
	NSDateFormatter *format = [[NSDateFormatter alloc]init];
	[format setDateFormat:@"MMM yyyy"];
	NSString *displayDate = [format stringFromDate:self.beginningOfWeek];		// was _currentDay
	NSDateComponents *weekComponents = [gregorian components:kCFCalendarUnitWeek fromDate:_currentDay];
    self.monthYear.font = [UIFont fontWithName:@"BankGothic Md BT" size:16];
    if (isHideWeekNumber) {
        self.monthYear.text = [NSString stringWithFormat:@"%@",displayDate];
    } else {
        self.monthYear.text = [NSString stringWithFormat:@"Week %d: %@",[weekComponents week],displayDate];
    }
	
	/*
	 Optional step:
	 beginningOfWeek now has the same hour, minute, and second as the
	 original date (today).
	 To normalize to midnight, extract the year, month, and day components
	 and create a new date from those components.
	 */
	NSDateComponents *components = [gregorian components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
												fromDate: self.beginningOfWeek];
	self.beginningOfWeek = [gregorian dateFromComponents: components];
	
	// Set up day labels
	[format setDateFormat:@"EEE"];
	day1.text = [format stringFromDate:self.beginningOfWeek];
	day2.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:1]];
	day3.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:2]];
	day4.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:3]];
	day5.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:4]];
	day6.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:5]];
	day7.text = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:6]];
    
    day1.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day2.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day3.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day4.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day5.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day6.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    day7.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
    
    BOOL ok = NO;
    int i;
    for (i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
        NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
        if ([displayDay isSameDay:[NSDate date]]) {
            ok = YES;
            break;
        }
	}
    
    ///!!!: comment by issue MA-365
    if (ok) {
        switch (i) {
            case 0:
                day1.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 1:
                day2.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 2:
                day3.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 3:
                day4.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 4:
                day5.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 5:
                day6.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            case 6:
                day7.textColor = [UIColor colorWithRed:0.157 green:0.475 blue:0.929 alpha:1];
                break;
            default:
                break;
        }
    }    
	[format release];
	[componentsToSubtract release];
	
	
	// Ask the delgate about the events that correspond
	// the the currently displayed day view
	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventsForDate:)]) {
		self.events = [self.delegate calendarWeekTimelineView:self eventsForDate:self.currentDay];
		NSMutableArray *sameTimeEvents = [[NSMutableArray alloc] init];

		// Loop over all the days in the week
		for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
			// Reset offset counters for each new day
			NSInteger offsetCount = 0;
			//number of nested appointments
			NSInteger repeatNumber = 0;
			//number of pixels to offset horizontally when they are nested
			CGFloat horizOffset = 0.0f;
			//starting point to check if they match
			CGFloat startMarker = 0.0f;
			CGFloat endMarker = 0.0f;
			NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
			for (TKCalendarDayEventView *event in self.events) {
				// Making sure delgate sending date that match current day
				if ([event.startDate isSameDay:displayDay]) {
					// Get the hour start position
					NSInteger hourStart = [event.startDate dateInformation].hour;
					CGFloat hourStartPosition = roundf((hourStart * VERTICAL_DIFF_WEEK) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
					// Get the minute start position
					// Round minute to each 5
					NSInteger minuteStart = [event.startDate dateInformation].minute;
					minuteStart = round(minuteStart / 5.0) * 5;
					CGFloat minuteStartPosition = roundf((CGFloat)minuteStart / 60.0f * VERTICAL_DIFF_WEEK);
										
					// Get the hour end position
					NSInteger hourEnd = [event.endDate dateInformation].hour;
					if (![event.startDate isSameDay:event.endDate]) {
						hourEnd = 23;
					}
					CGFloat hourEndPosition = roundf((hourEnd * VERTICAL_DIFF_WEEK) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
					// Get the minute end position
					// Round minute to each 5
					NSInteger minuteEnd = [event.endDate dateInformation].minute;
					if (![event.startDate isSameDay:event.endDate]) {
						minuteEnd = 55;
					}
					minuteEnd = round(minuteEnd / 5.0) * 5;
					CGFloat minuteEndPosition = roundf((CGFloat)minuteEnd / 60.0f * VERTICAL_DIFF_WEEK);
					
					CGFloat eventHeight = 0.0;
					
					eventHeight = (hourEndPosition + minuteEndPosition) - hourStartPosition - minuteStartPosition;
					if (eventHeight < VERTICAL_DIFF_WEEK/2) eventHeight = VERTICAL_DIFF_WEEK/2;
					
					//nobre additions - split control and offset control				
					//split control - adjusts balloon widths so their times/titles don't overlap
					//offset control - adjusts starting balloon position so you can see all starts/ends
					if ((hourStartPosition + minuteStartPosition) - startMarker <= VERTICAL_DIFF_WEEK/2) {				
						repeatNumber++;
					}
					else {
						repeatNumber = 0;
						[sameTimeEvents removeAllObjects];
						//if this event starts before the last event's end, we have to offset it!
						if (hourStartPosition + minuteStartPosition < endMarker) {
							horizOffset = EVENT_SAME_HOUR * ++offsetCount;
						}
						else {
							horizOffset = 0.0f;
							offsetCount = 0;
						}
					}		
//                    NSLog(@"%f", horizOffset);
					//refresh the markers
					startMarker = hourStartPosition + minuteStartPosition;				
					endMarker = hourEndPosition + minuteEndPosition;
                    
					// day of week column frame
					CGRect dayRect = [self getViewRectForDay:i+1];

                    CGFloat eventWidth = dayRect.size.width - (repeatNumber*0.1*dayRect.size.width) - 1;
                    CGFloat eventOriginX =  dayRect.origin.x;
                    CGRect eventFrame = CGRectMake(eventOriginX + (repeatNumber*0.1*eventWidth),
                                                  hourStartPosition + minuteStartPosition + EVENT_VERTICAL_DIFF,
                                                  eventWidth,
                                                  eventHeight);
                    
                    /*
					CGFloat eventWidth = dayRect.size.width;
					CGFloat eventOriginX =  dayRect.origin.x;
					CGRect eventFrame = CGRectMake(eventOriginX,
												   hourStartPosition + minuteStartPosition + EVENT_VERTICAL_DIFF,
												   eventWidth,
												   eventHeight);
                    
					*/
					event.frame = CGRectIntegral(eventFrame);
					event.delegate = self;
					[event setNeedsDisplay];
					[self.scrollView addSubview:event];
                    [self.scrollView bringSubviewToFront:event];
					
					for (int i = [sameTimeEvents count]-1; i >= 0; i--) {
						TKCalendarDayEventView *sameTimeEvent = [sameTimeEvents objectAtIndex:i];
						CGRect newFrame = sameTimeEvent.frame;
						newFrame.size.width = eventWidth;
						// newFrame.origin.x = eventOriginX + (i*eventWidth);
						sameTimeEvent.frame = CGRectIntegral(newFrame);
					}				
					[sameTimeEvents addObject:event];
					// Log the extracted date values
					//DLog(@"hourStart: %d minuteStart: %d", hourStart, minuteStart);
				}
				// Reset offset counters for each new day
				[sameTimeEvents removeAllObjects];

			}
		}
		[sameTimeEvents release];
	}
    
    // research
    // COMMENT: add calendar icon to the date where there are at least one event
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventsInWeekForDate:)]){
        NSArray *events = [self.delegate calendarWeekTimelineView:self eventsInWeekForDate:self.currentDay];
        if(events != NULL && [events count] > 0){
            NSInteger numberOfEvents = events.count;
            NSLog(@"number of events: %d",numberOfEvents);
            for (NSInteger i = 0; i<(isFiveDayWeek ? 5 : 7); i++) {
                NSLog(@"i--------: %d",i);
                NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
                NSLog(@"displayday %@",displayDay);
                NSInteger numberOfEventInDay = 0;
                for(NSInteger j = 0; j < numberOfEvents; j++){
                    TKEvent* tkEvent = [events objectAtIndex:j];
                    NSLog(@"tkEvent.recurrence %@",tkEvent.recurrence);
//                    numberOfEventInDay = [self numberOfEventFromRecurringWithDisplayDay:displayDay withTKEvent:tkEvent];
                    numberOfEventInDay = [self numberOfEventFromRecurringWithDisplayDay:displayDay withEvents:events];
                    NSLog(@"number of event in day: %d",numberOfEventInDay);
                    BOOL hasEvent = [self hasEventFromRecurringWithDisplayDay:displayDay withTKEvent:tkEvent];
                    if(hasEvent){
                        [self generateCalendarIconWithIndex:i withNumberOfEventInDay:numberOfEventInDay withIndexJ:j withEvents:events];
                        break;
                    }// end if isSameDay
                }
                
//                for(NSInteger j = 0; j < numberOfEvents; j++){
//                    TKEvent* tkEvent = [events objectAtIndex:j];
//                    BOOL hasEvent = [self hasEventFromRecurringWithDisplayDay:displayDay withTKEvent:tkEvent];
//                    if(hasEvent){
//                        [self generateCalendarIconWithIndex:i withNumberOfEventInDay:numberOfEventInDay withIndexJ:j withEvents:events];
//                        break;
//                    }// end if isSameDay
//                } // end for j
            }
        }
    }
    
    // COMMENT: add fertle icon to the date where there are at least one event
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:fertleInWeekForDate:)]){
        NSArray *fertles = [self.delegate calendarWeekTimelineView:self fertleInWeekForDate:self.currentDay];
        if(fertles != NULL && [fertles count] > 0){
            NSInteger numberOfFertles = [fertles count];
            for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
                NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
                for(NSInteger j=0; j < numberOfFertles; j++){
                    if([displayDay isSameDay:[fertles objectAtIndex:j]]){
                        CGRect currentDayRect = [self getViewRectForDay:i+1];
                        UIImage *fertleIconImage = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconFertle"];
                        CGRect fertleIconFrame = CGRectMake(currentDayRect.origin.x + currentDayRect.size.width/2 + 3, currentDayRect.origin.y + currentDayRect.size.height - fertleIconImage.size.height - 5, currentDayRect.size.width/3, currentDayRect.size.width/3 - 5);
                        UIImageView *fertleIconView = [[UIImageView alloc] initWithFrame:fertleIconFrame];
                        fertleIconView.image = fertleIconImage;
                        [self.scrollView addSubview:fertleIconView];
                        break;
                    }
                }
            }
        }
    }
    
    // COMMENT: add menstrating icon to the date where there are at least one event
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:menstratingInWeekForDate:)]){
        NSArray *menstrating = [self.delegate calendarWeekTimelineView:self menstratingInWeekForDate:self.currentDay];
        if(menstrating != NULL && [menstrating count] > 0){
            NSInteger numberOfMenstrating = [menstrating count];
            for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
                NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
                for(NSInteger j=0; j < numberOfMenstrating; j++){
                    if([displayDay isSameDay:[menstrating objectAtIndex:j]]){
                        CGRect currentDayRect = [self getViewRectForDay:i+1];
                        UIImage *menstratingIconImage = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconMenstrating"];
                        CGRect menstratingIconFrame = CGRectMake(currentDayRect.origin.x + currentDayRect.size.width/2 + 3, currentDayRect.origin.y + currentDayRect.size.height - menstratingIconImage.size.height - 5, currentDayRect.size.width/3, currentDayRect.size.width/3);
                        UIImageView *menstratingIconView = [[[UIImageView alloc] initWithFrame:menstratingIconFrame] autorelease];
                        menstratingIconView.image = menstratingIconImage;
                        [self.scrollView addSubview:menstratingIconView];
                        break;
                    }
                }
            }
        }
    }
    
    // COMMENT: add sensitive icon to the date where there are at least one event
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:sensitiveInWeekForDate:)]){
        NSArray *sensitives = [self.delegate calendarWeekTimelineView:self sensitiveInWeekForDate:self.currentDay];
        if(sensitives != NULL && [sensitives count] > 0){
            NSInteger numberOfSensitives = [sensitives count];
            for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
                NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
                for(NSInteger j=0; j < numberOfSensitives; j++){
                    if([displayDay isSameDay:[sensitives objectAtIndex:j]]){
                        CGRect currentDayRect = [self getViewRectForDay:i+1];
                        UIImage *sensitiveIconImage = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconSensitive"];
                        CGRect sensitiveIconFrame = CGRectMake(currentDayRect.origin.x + currentDayRect.size.width/2 - 5, currentDayRect.origin.y + currentDayRect.size.height - sensitiveIconImage.size.height - 10, currentDayRect.size.width/3, currentDayRect.size.width/3);
                        UIImageView *sensitiveIconView = [[UIImageView alloc] initWithFrame:sensitiveIconFrame];
                        sensitiveIconView.image = sensitiveIconImage;
                        [self.scrollView addSubview:sensitiveIconView];
                        break;
                    }
                }
            }
        }
    }
     
}

- (BOOL) hasEventFromRecurringWithDisplayDay:(NSDate*)displayDay withTKEvent:(TKEvent*) tkEvent  {
    BOOL hasEvent = NO;
    if ([displayDay isSameDay:tkEvent.eventTime]) {
        hasEvent = YES;
    }
    if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] && ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            hasEvent = YES;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] && (([displayDay daysBetweenDate:tkEvent.eventTime] % 7 == 0)  && ![displayDay isAfterDate:tkEvent.eventEndTime])) {
            hasEvent = YES;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] &&
            [displayDay getDay] == [tkEvent.eventTime getDay]  &&
            ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            hasEvent = YES;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] &&
            [displayDay getDay] == [tkEvent.eventTime getDay]  &&
            [displayDay getMonth] == [tkEvent.eventTime getMonth] &&
            ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            hasEvent = YES;
        }
    }
    
    return hasEvent;
}

- (NSInteger) numberOfEventFromRecurringWithDisplayDay:(NSDate*)displayDay withTKEvent:(TKEvent*) tkEvent  {
    NSInteger numberOfEvent = 0;
    if ([displayDay isSameDay:tkEvent.eventTime]) {
        numberOfEvent++;
    }
    if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] && ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            numberOfEvent++;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
        if ([displayDay isSameDay:tkEvent.eventTime] || [displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime]) {
            numberOfEvent++;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] &&
            [displayDay getDay] == [tkEvent.eventTime getDay]  &&
            ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            numberOfEvent++;
        }
    }
    else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
        if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] &&
            [displayDay getDay] == [tkEvent.eventTime getDay]  &&
            [displayDay getMonth] == [tkEvent.eventTime getMonth]  &&
            ![displayDay isAfterDate:tkEvent.eventEndTime]) {
            numberOfEvent++;
        }
    }

    return numberOfEvent;
}

- (NSInteger) numberOfEventFromRecurringWithDisplayDay:(NSDate*)displayDay withEvents:(NSArray*) events  {
    NSInteger numberOfEvent = 0;
    for (TKEvent *tkEvent in events) {
        
        if ([displayDay isSameDay:tkEvent.eventOccurTime]) {
            numberOfEvent++;
        }
//        if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
//            if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] && ![displayDay isAfterDate:tkEvent.eventEndTime]) {
//                numberOfEvent++;
//            }
//        }
//        else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
//            if ([displayDay isSameDay:tkEvent.eventTime] || [displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime]) {
//                numberOfEvent++;
//            }
//        }
//        else if ([tkEvent.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
//            if ([displayDay isBetweenDate:tkEvent.eventTime end:tkEvent.eventEndTime] && [displayDay isSameDay: [tkEvent.eventTime dateByAddMonth:1]]  && ![displayDay isAfterDate:tkEvent.eventEndTime]) {
//                numberOfEvent++;
//            }
//        }
    }
    return numberOfEvent;
}

- (void) generateCalendarIconWithIndex:(NSInteger) i withNumberOfEventInDay:(NSInteger) numberOfEventInDay withIndexJ:(NSInteger) j withEvents:(NSArray*) events  {
    CGRect currentDayRect = [self getViewRectForDay:i + 1];
    
    //event icon
    UIImage *calendarIconImage = [UIImage imageNamedTK:(numberOfEventInDay > 1)?@"TapkuLibrary.bundle/Images/calendar/markCalendarDouble":@"TapkuLibrary.bundle/Images/calendar/markCalendar"];
    CGRect eventIconFrame = CGRectMake(currentDayRect.origin.x + 5, currentDayRect.origin.y + currentDayRect.size.height - 21, currentDayRect.size.width/3, currentDayRect.size.width/3);
    UIImageView *calendarIconView = [[[UIImageView alloc] initWithFrame:eventIconFrame] autorelease];
    calendarIconView.image = calendarIconImage;
    [self.scrollView addSubview:calendarIconView];
    
    //display time
    TKEvent *event = [events objectAtIndex:j];
    
    NSCalendar *gregorianCal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *dateComps = [gregorianCal components: (NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate: event.eventTime];
    UILabel *eventTimeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(currentDayRect.origin.x + 2, currentDayRect.origin.y + TKCALENDAR_WEEK_CONTROL_SIZE_TIME_ORIGIN_Y, currentDayRect.size.width - 4, TKCALENDAR_WEEK_CONTROL_SIZE_TIME_SIZE_HEIGHT)] autorelease];
    eventTimeLabel.minimumFontSize = 8;
    eventTimeLabel.backgroundColor = [UIColor clearColor];
    eventTimeLabel.font = [UIFont boldSystemFontOfSize:10];
    if ([NSDate isAllDayEvent:event.eventTime withEndDate:event.eventEndTime]) {
        eventTimeLabel.text = [NSString stringWithFormat:@"%@ : %@",event.eventTitle, [event.eventTime toString]];
    } else {
        eventTimeLabel.text = [NSString stringWithFormat:@"%@ : %02d:%02d:%02d",event.eventTitle, [dateComps hour],[dateComps minute],[dateComps second]];
    }
    eventTimeLabel.numberOfLines = 3;
    [self.scrollView addSubview:eventTimeLabel];
}


- (BOOL) isAllDayEvent:(NSDate*) startDate withEndDate:(NSDate*) endDate {
    BOOL isAllDayEvent = NO;
    NSDateComponents *dateComponents = [NSDate hourComponentsBetweenDate:startDate andDate:endDate];
    NSLog(@"hour %d",dateComponents.hour);
    NSLog(@"minute %d",dateComponents.minute);
    if((dateComponents.hour == 24) || (dateComponents.hour == 23 && dateComponents.minute >= 57)){
        isAllDayEvent = YES;
    }
    return isAllDayEvent;
}

#pragma mark -
#pragma mark Tap Detecting View

-(NSTimeInterval)getSecondsFromOffset:(CGFloat)offset {
	CGFloat hora = (offset - VERTICAL_OFFSET)/VERTICAL_DIFF_WEEK;
	NSInteger intHour = (int)hora;
	CGFloat minutePart = hora-intHour;
	NSInteger intMinute = 0;
	if (minutePart > 0.5) {
		intMinute = 30;		
	}
	return (NSTimeInterval)(intHour*60*60 + intMinute*60);
}

- (void)tapDetectingView:(TapDetectingView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
    NSDate *selectedDate = [[[self getTimeAndDayFromPointWithoutMinute:tapPoint] dateByAddingTimeInterval:-1] dateOnly];
    NSLog(@"%@", selectedDate);
    self.timelineView.selectedDate = selectedDate;
    
	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventViewWasSelected:)]) {
		if (view != _timelineView) 
			[self.delegate calendarWeekTimelineView:self eventViewWasSelected:(TKCalendarDayEventView *)view];
		else
			[self.delegate calendarWeekTimelineView:self tapDetect:tapPoint];
	}
}

- (void)tapDetectingView:(TapDetectingView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
	CGPoint pointInTimeLine = CGPointZero;
	[self.delegate calendarWeekTimelineView:self tapDetect:tapPoint];
	if ([view isKindOfClass:[TKTimelineWeekView class]]) {
		pointInTimeLine = tapPoint;
		//self.isFiveDayWeek = !self.isFiveDayWeek;
		NSDateFormatter *format = [[NSDateFormatter alloc]init];
		[format setDateFormat:@"MMM dd yyyy hh:mm"];	
		NSLog(@"Double Tapped TimelineView at date %@",[format stringFromDate:[self getTimeAndDayFromPoint:pointInTimeLine]]);
		NSLog(@"Double Tapped TimelineView at point %@", NSStringFromCGPoint(pointInTimeLine));
		[format release];
        if ([self.delegate respondsToSelector:@selector(calendarWeekTimelineView:doubleTapAtDate:)]) {
            [self.delegate calendarWeekTimelineView:self doubleTapAtDate:[self getTimeAndDayFromPoint:pointInTimeLine]];
        }
        //[self.delegate calendarModeChanged:self];
	}
	else {
		pointInTimeLine = [view convertPoint:tapPoint toView:self.scrollView];
		NSLog(@"Double Tapped EventView at point %@", NSStringFromCGPoint(pointInTimeLine));		
        if ([self.delegate respondsToSelector:@selector(calendarWeekTimelineView:doubleTapAtDate:)]) {
            [self.delegate calendarWeekTimelineView:self doubleTapAtDate:[self getTimeAndDayFromPoint:pointInTimeLine]];
        }
	}
//	if (self.delegate && [self.delegate respondsToSelector:@selector(calendarWeekTimelineView:eventDateWasSelected:)]) {
//		[self.delegate calendarWeekTimelineView:self eventDateWasSelected:[self getTimeAndDayFromPoint:pointInTimeLine]];
//	}
}

- (NSDate*)getTimeAndDayFromPoint:(CGPoint)tapPoint {
	// Given tapPoint within _timeLineView, return day of the week and time
	NSDate *selectedDay = self.beginningOfWeek;

	for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++)
		if (CGRectContainsPoint([self getViewRectForDay:i+1],tapPoint)) 
			selectedDay = [self.beginningOfWeek dateByAddingDays:i];	

	return [selectedDay dateByAddingTimeInterval:[self getSecondsFromOffset:tapPoint.y]];
}

- (NSDate*)getTimeAndDayFromPointWithoutMinute:(CGPoint)tapPoint{
    // Given tapPoint within _timeLineView, return day of the week and time
	NSDate *selectedDay = self.beginningOfWeek;
    
    // EDIT: add this since beginningOfWeek seem wrong (late by one day)
    NSDateComponents *dayComponent = [[[NSDateComponents alloc] init] autorelease];
    dayComponent.day = 1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    selectedDay = [theCalendar dateByAddingComponents:dayComponent toDate:selectedDay options:0];
    
	for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++)
		if (CGRectContainsPoint([self getViewRectForDay:i+1],tapPoint)) 
			selectedDay = [selectedDay dateByAddingDays:i];	
	return selectedDay;
}

#pragma mark -
#pragma mark Swipe Detection

- (void) setupGestureRecognition {
	// Attached UIGesture recognizers to the timeLineView
	UISwipeGestureRecognizer *recognizer;
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousWeek:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionRight;	// default
    [self addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextWeek:)];
	recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:recognizer];
    recognizer.delegate = self;
    [recognizer release];
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
    // If gesture was within bounds of timelineView then allow
//    if (touch.view == self) {
//        return YES;
//    }
//    return NO;
    return YES;
}


#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

#pragma mark EDIT TOP BACKGROUND (TO TRANSPARENT)
//EDIT TOP BACKGROUDN (WITH LEFT AND RIGHT ARROW)
- (UIImageView *) topBackground{
	if(topBackground==nil){
        //topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
        //Edit background(not add image)
        topBackground = [[UIImageView alloc] init];
	}
	return topBackground;
}

#pragma mark EDIT TOP LABEL (MONTH - YEAR) (TO TRANSPARENT)
- (UILabel *) monthYear{
	if(monthYear==nil){
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 320, 28)];
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
		//monthYear.font = [UIFont boldSystemFontOfSize:22];
        //EDIT font
        monthYear.font = [UIFont fontWithName:@"BankGothic Md BT" size:22];
        //monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
        //EDIT color
		monthYear.textColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
	}
	return monthYear;
}

-(void) nextWeek:(id)sender {
//	NSDate *tomorrow = [self.currentDay dateByAddingDays:7];
//	self.currentDay = tomorrow;
	//[self.delegate calendarWeekTimelineView:self tapDetect:CGPointMake(0, 0)];
    [self.delegate calendarNextWeekClicked:self];
}

-(void) previousWeek:(id)sender {
//	NSDate *yesterday = [self.currentDay dateByAddingDays:-7];
//	self.currentDay = yesterday;
	//[self.delegate calendarWeekTimelineView:self tapDetect:CGPointMake(0, 0)];
    [self.delegate calendarPrevWeekClicked:self];
}

- (UIButton *) leftArrow{
	if(leftArrow==nil){
		leftArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(previousWeek:) forControlEvents:UIControlEventTouchUpInside];
		
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		
		//leftArrow.frame = CGRectMake(0, 0, 48, 38);
        //EDIT position
        leftArrow.frame = CGRectMake(75, 0, 48, 38);
	}
	return leftArrow;
}
- (UIButton *) rightArrow{
	if(rightArrow==nil){
		rightArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(nextWeek:) forControlEvents:UIControlEventTouchUpInside];
		//rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
        //EDIT position
        rightArrow.frame = CGRectMake(320 - 20 - 105, 0, 48, 38);
		
		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
		
	}
	return rightArrow;
}
- (UIImageView *) shadow{
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	// Remove observers
	[self removeObserver:self forKeyPath: @"currentDay"];
	
	[_currentDay release];
	[_beginningOfWeek release];
	[_events release];
	[_timelineView release];
	[_scrollView release];

	[timelineColor release];
	[hourColor release];
	
	[rightArrow release];
	[leftArrow release];
	[topBackground release];
	[shadow release];
	[monthYear release];
	
	[day1 release];
	[day2 release];
	[day3 release];
	[day4 release];
	[day5 release];
	[day6 release];
	[day7 release];
    [timer invalidate];
    [super dealloc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.delegate calendarScrollViewDidScroll:self scrollView:self.scrollView];
}

@end

@implementation TKTimelineWeekView

@synthesize times=_times;
@synthesize periods=_periods;
@synthesize is24hClock, hourColor, isFiveDayWeek, is15Min;
@synthesize beginningOfWeek = _beginningOfWeek;
@synthesize highlightCurrentDay = _highlightCurrentDay;
@synthesize dataSource;
@synthesize availableTimes = _availableTimes;
@synthesize selectedDate = _selectedDate;

#pragma mark -
#pragma mark Initialisation

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (_selectedDate) {
        [_selectedDate release];
    }
    _selectedDate = [selectedDate retain];
    [self setNeedsDisplay];
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when xibless (interface buildder)
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Custom initialization
		[self setupCustomInitialisation];
    }
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
// Only when using xib (interface buildder)
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		// Custom initialization
		[self setupCustomInitialisation];
	}
	return self;
}

- (void)setupCustomInitialisation
{
	// Initialization code
    _highlightCurrentDay = YES; // Default
}

#pragma mark -
#pragma mark Setup

// Setup array consisting of string
// representing time aka 12 (12 am), 1 (1 am) ... 25 x

- (void)setIs24hClock:(BOOL)_is24hClock {
    is24hClock = _is24hClock;
    if (_times) {
        [_times release];
        _times = nil;
    }
    if (_periods) {
        [_periods release];
        _periods = nil;        
    }
    [self setNeedsDisplay];
}

- (NSArray *)times
{
	if (!_times) {
		if (is24hClock) {
			_times = [[NSArray alloc]initWithObjects:
					  @"0",
					  @"1",
					  @"2",
					  @"3",
					  @"4",
					  @"5",
					  @"6",
					  @"7",
					  @"8",
					  @"9",
					  @"10",
					  @"11",
					  @"12",
					  @"13",
					  @"14",
					  @"15",
					  @"16",
					  @"17",
					  @"18",
					  @"19",
					  @"20",
					  @"21",
					  @"22",
					  @"23",
					  @"0",
					  nil];
		}
		else {
			_times = [[NSArray alloc]initWithObjects:
					  @"12",
					  @"1",
					  @"2",
					  @"3",
					  @"4",
					  @"5",
					  @"6",
					  @"7",
					  @"8",
					  @"9",
					  @"10",
					  @"11",
					  @"Noon",
					  @"1",
					  @"2",
					  @"3",
					  @"4",
					  @"5",
					  @"6",
					  @"7",
					  @"8",
					  @"9",
					  @"10",
					  @"11",
					  @"12",
					  nil];
		}

	}
	return _times;
}

// Setup array consisting of string
// representing time periods aka AM or PM
// Matching the array of times 25 x

- (NSArray *)periods
{
	if (is24hClock) return nil;
	if (!_periods) {
		_periods = [[NSArray alloc]initWithObjects:
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"AM",
				  @"",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"PM",
				  @"AM",
				  nil];
	}
	return _periods;
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
    
    return YES;
}

- (BOOL)isCurrentWeek {
    NSDate *beginDate = self.beginningOfWeek;
    NSDate *endDate = [self.beginningOfWeek dateByAddingDays:6];
    if ([self date:[NSDate date] isBetweenDate:beginDate andDate:endDate]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Drawing code
	// Here Draw timeline from 12 am to noon to 12 am next day
	
	// Just making sure that times and periods are correctly initialized
	// Should have exactly the same number of objects
	if ((!is24hClock && self.times.count != self.periods.count)) {
		return;
	}
	
	// Times appearance
	//UIFont *timeFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
	//UIColor *timeColor = hourColor ? hourColor : [UIColor blackColor];
	
	// Periods appearance
	//UIFont *periodFont = [UIFont systemFontOfSize:FONT_SIZE];
	//UIColor *periodColor = hourColor ? hourColor : [UIColor grayColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    _highlightCurrentDay = NO;
    if (_highlightCurrentDay) {
        // Highlight current day
        NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
        [format setDateFormat:@"dd-MM-yyyy"];
        NSString *currentDayString = [format stringFromDate:[NSDate date]];
        BOOL match = NO;
        int i = 0;
        for (i = 0; i < 7; i++) {
            NSString *compareString = [format stringFromDate:[self.beginningOfWeek dateByAddingDays:i]];
            if ([compareString isEqualToString:currentDayString]) {
                match = YES;
                break;
            }
        }
        if (match) {
            CGContextSaveGState(context);
            CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.2);
            CGRect currentDayRect = [self getViewRectForDay:i + 1];
            //CGContextFillRect(context, currentDayRect);
            
            //draw round rectangle
            CGFloat radius = 10;
            CGFloat width = CGRectGetWidth(currentDayRect);
            CGFloat height = CGRectGetHeight(currentDayRect);
            
            // Make sure corner radius isn't larger than half the shorter side
            if (radius > width/2.0)
                radius = width/2.0;
            if (radius > height/2.0)
                radius = height/2.0;    
            
            CGFloat minx = CGRectGetMinX(currentDayRect);
            CGFloat midx = CGRectGetMidX(currentDayRect);
            CGFloat maxx = CGRectGetMaxX(currentDayRect);
            CGFloat miny = CGRectGetMinY(currentDayRect);
            CGFloat midy = CGRectGetMidY(currentDayRect);
            CGFloat maxy = CGRectGetMaxY(currentDayRect);
            CGContextMoveToPoint(context, minx, midy);
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            //Draw days text
            UIColor *timeColor = hourColor ? hourColor : [UIColor blackColor];
            [timeColor set];
            NSDate *currentDate = [self.beginningOfWeek dateByAddingDays:i];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* compoNents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
            NSString *currentDay = [NSString stringWithFormat:@"%d",[compoNents day]];
            //CGRect dayFrame = [self getViewRectForDay:i + 1];
            CGRect stringFrame = CGRectMake(currentDayRect.origin.x + currentDayRect.size.width/2 - 3, currentDayRect.origin.y, currentDayRect.size.width/2, currentDayRect.size.width/2);
            UIFont *dayFont = [UIFont boldSystemFontOfSize:15];
            [currentDay drawInRect:CGRectIntegral(stringFrame)
                          withFont:dayFont 
                     lineBreakMode:UILineBreakModeWordWrap 
                         alignment:UITextAlignmentRight];
            
            CGContextRestoreGState(context);
        }
    } else { // Booking Appointment Mode
        for (int i = 0; i < 7; i++) {
            CGContextSaveGState(context);
            CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.1);
            CGRect currentDayRect = [self getViewRectForDay:i + 1];
            CGContextFillRect(context, currentDayRect);
            CGContextRestoreGState(context);
        }
        
        // Highlight available time
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(timelineWeekView:availableTimeForDate:)]) {
            self.availableTimes = [self.dataSource timelineWeekView:self availableTimeForDate:self.beginningOfWeek];
            
            // Loop over all the days in the week
            for (NSInteger i=0; i<(isFiveDayWeek ? 5 : 7); i++) {
                // Reset offset counters for each new day
                NSInteger offsetCount = 0;
                //number of nested appointments
                NSInteger repeatNumber = 0;
                //number of pixels to offset horizontally when they are nested
                CGFloat horizOffset = 0.0f;
                //starting point to check if they match
                CGFloat startMarker = 0.0f;
                CGFloat endMarker = 0.0f;
                NSDate *displayDay = [self.beginningOfWeek dateByAddingDays:i];
                for (TKCalendarDayEventView *event in self.availableTimes) {
                    // Making sure delgate sending date that match current day
                    if ([event.startDate isSameDay:displayDay]) {
                        // Get the hour start position
                        NSInteger hourStart = [event.startDate dateInformation].hour;
                        CGFloat hourStartPosition = roundf((hourStart * VERTICAL_DIFF_WEEK) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
                        // Get the minute start position
                        // Round minute to each 5
                        NSInteger minuteStart = [event.startDate dateInformation].minute;
                        minuteStart = round(minuteStart / 5.0) * 5;
                        CGFloat minuteStartPosition = roundf((CGFloat)minuteStart / 60.0f * VERTICAL_DIFF_WEEK);
                        
                        // Get the hour end position
                        NSInteger hourEnd = [event.endDate dateInformation].hour;
                        if (![event.startDate isSameDay:event.endDate]) {
                            hourEnd = 23;
                        }
                        CGFloat hourEndPosition = roundf((hourEnd * VERTICAL_DIFF_WEEK) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
                        // Get the minute end position
                        // Round minute to each 5
                        NSInteger minuteEnd = [event.endDate dateInformation].minute;
                        if (![event.startDate isSameDay:event.endDate]) {
                            minuteEnd = 55;
                        }
                        minuteEnd = round(minuteEnd / 5.0) * 5;
                        CGFloat minuteEndPosition = roundf((CGFloat)minuteEnd / 60.0f * VERTICAL_DIFF_WEEK);
                        
                        CGFloat eventHeight = 0.0;
                        
                        eventHeight = (hourEndPosition + minuteEndPosition) - hourStartPosition - minuteStartPosition;
                        if (eventHeight < VERTICAL_DIFF_WEEK/2) eventHeight = VERTICAL_DIFF_WEEK/2;
                        
                        //nobre additions - split control and offset control				
                        //split control - adjusts balloon widths so their times/titles don't overlap
                        //offset control - adjusts starting balloon position so you can see all starts/ends
                        if ((hourStartPosition + minuteStartPosition) - startMarker <= VERTICAL_DIFF_WEEK/2) {				
                            repeatNumber++;
                        }
                        else {
                            repeatNumber = 0;
                            //if this event starts before the last event's end, we have to offset it!
                            if (hourStartPosition + minuteStartPosition < endMarker) {
                                horizOffset = EVENT_SAME_HOUR * ++offsetCount;
                            }
                            else {
                                horizOffset = 0.0f;
                                offsetCount = 0;
                            }
                        }			
//                        NSLog(@"%f", horizOffset);
                        //refresh the markers
                        startMarker = hourStartPosition + minuteStartPosition;				
                        endMarker = hourEndPosition + minuteEndPosition;
                        
                        // day of week column frame
                        CGRect dayRect = [self getViewRectForDay:i+1];
                        
                        CGFloat eventWidth = dayRect.size.width - (repeatNumber*0.1*dayRect.size.width) - 1;
                        CGFloat eventOriginX =  dayRect.origin.x;
                        CGRect eventFrame = CGRectMake(eventOriginX + (repeatNumber*0.1*eventWidth),
                                                       hourStartPosition + minuteStartPosition + EVENT_VERTICAL_DIFF,
                                                       eventWidth,
                                                       eventHeight);

                        event.frame = CGRectIntegral(eventFrame);
                        [event setNeedsDisplay];
                        [self addSubview:event];
                        CGContextSaveGState(context);
                        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                        CGContextFillRect(context, event.frame);
                        CGContextRestoreGState(context);
                    }
                }
            }
        }
    }

	
    //EDIT REMOVE TIME STRING (LEFTMOST COLUMN) AND LINE
    /*
	// Draw each times string
	for (NSInteger i=0; i<self.times.count; i++) {
		// Draw time
		[timeColor set];
		
		NSString *time = [self.times objectAtIndex:i];
		
		CGRect timeRect = CGRectMake(HORIZONTAL_OFFSET, VERTICAL_OFFSET + i * VERTICAL_DIFF, TIME_WIDTH + (is24hClock?PERIOD_WIDTH:0), FONT_SIZE + 4.0);
		
		// Find noon
		if (!is24hClock && i == 24/2) {
			timeRect = CGRectMake(2, VERTICAL_OFFSET + i * VERTICAL_DIFF, TIME_WIDTH + PERIOD_WIDTH, FONT_SIZE + 4.0);
		}
		
		[time drawInRect:CGRectIntegral(timeRect)
			   withFont:timeFont 
		  lineBreakMode:UILineBreakModeWordWrap 
			  alignment:UITextAlignmentLeft];
		
		// Draw period
		// Only if it is not noon
		if (!is24hClock && i != 24/2) {
			[periodColor set];
			
			NSString *period = [self.periods objectAtIndex:i];
			
			[period drawInRect: CGRectIntegral(CGRectMake(HORIZONTAL_OFFSET, PERIOD_VERT_OFFSET + i * VERTICAL_DIFF, PERIOD_WIDTH, FONT_SIZE + 4.0)) 
					  withFont: periodFont 
				 lineBreakMode: UILineBreakModeWordWrap 
					 alignment: UITextAlignmentLeft];
		}
		
		// Draw straight line
		CGContextRef context = UIGraphicsGetCurrentContext();
		// Save the context state 
		CGContextSaveGState(context);
		// Draw line with a black stroke color
		CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
		// Draw line with a 1.0 stroke width
		CGContextSetLineWidth(context, 0.5);
		// Translate context for clear line
		CGContextTranslateCTM(context, -0.5, -0.5);
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0));
		CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0));
		CGContextStrokePath(context);
		
		if (i != self.times.count-1) {		
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 2.0));
			CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 2.0));
			CGFloat dash1[] = {2.0, 1.0};
			CGContextSetLineDash(context, 0.0, dash1, 2);
			CGContextStrokePath(context);
            
            if (is15Min) {
                // Draw 15min line
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 4.0));
                CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(VERTICAL_DIFF / 4.0));
                CGFloat dash1[] = {2.0, 1.0};
                CGContextSetLineDash(context, 0.0, dash1, 2);
                CGContextStrokePath(context);

                // Draw 45min line
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, HORIZONTAL_OFFSET + TIME_WIDTH + HORIZONTAL_LINE_DIFF, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(3 * VERTICAL_DIFF / 4.0));
                CGContextAddLineToPoint(context, self.bounds.size.width, VERTICAL_OFFSET + i * VERTICAL_DIFF + roundf((FONT_SIZE + 4.0) / 2.0) + roundf(3 * VERTICAL_DIFF / 4.0));
                CGContextSetLineDash(context, 0.0, dash1, 2);
                CGContextStrokePath(context);
            }
		}
        // Restore the context state
		CGContextRestoreGState(context);
	}
     */
    
    //EDIT REMOVE HOURS VERTICAL LINES
    /*
	// Draw vertical lines
	// Save the context state 
	CGContextSaveGState(context);
	// Draw line with a black stroke color
	CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
	// Draw line with a 1.0 stroke width
	CGContextSetLineWidth(context, 0.5);
	// Translate context for clear line
	CGContextTranslateCTM(context, -0.5, -0.5);

	// Stroke either six or four vertical lines
	for (NSInteger i=1; i<(self.isFiveDayWeek ? 5 : 7); i++) {
		CGContextBeginPath(context);
		CGRect dayRect = [self getViewRectForDay:i];
		CGContextMoveToPoint(context,    CGRectGetMaxX(dayRect), 0.0);
		CGContextAddLineToPoint(context, CGRectGetMaxX(dayRect), self.bounds.size.height);
		CGContextStrokePath(context);		
	}
	// Restore the context state
    CGContextRestoreGState(context);
     */
    
    //EDIT DRAW ROUND RECTANGLE
    NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
    [format setDateFormat:@"dd-MM-yyyy"];
    //NSString *currentDayString = [format stringFromDate:[NSDate date]];
    int i = 0;
    for (i = 0; i < 7; i++) {
        NSDate *d = [self.beginningOfWeek dateByAddingDays:i];
            CGRect dayFrame = [self getViewRectForDay:i + 1];
            TapkuWeeklyViewMoodType moodType = (TapkuWeeklyViewMoodType)[self.dataSource timelineWeekView:self moodForDate:d].intValue;
            NSDictionary *colorDict = [self getColorForMoodType:moodType];
            CGContextSaveGState(context);
        
            CGContextSetRGBFillColor(context, [[colorDict objectForKey:kTapkuRed] floatValue], [[colorDict objectForKey:kTapkuGreen] floatValue], [[colorDict objectForKey:kTapkuBlue] floatValue], [[colorDict objectForKey:kTapkuAlpha] floatValue]);
//            if( i == 0)
//                CGContextSetRGBFillColor(context, 38.0/255, 188.0/255, 199.0/255, 1.0);
//            else if( i == 1)
//                CGContextSetRGBFillColor(context, 41.0/255, 189.0/255, 79.0/255, 1.0);
//            else if( i == 2)
//                CGContextSetRGBFillColor(context, 160.0/255, 210.0/255, 65.0/255, 1.0);
//            else if( i == 3)
//                CGContextSetRGBFillColor(context, 219.0/255, 218.0/255, 59.0/255, 1.0);
//            else if( i == 4)
//                CGContextSetRGBFillColor(context, 187.0/255, 68.0/255, 44.0/255, 1.0);
//            else if( i == 5)
//                CGContextSetRGBFillColor(context, 174.0/255, 51.0/255, 25.0/255, 1.0);
//            else if( i == 6)
//                CGContextSetRGBFillColor(context, 169.0/255, 41.0/255, 13.0/255, 1.0);
//            else
//                CGContextSetRGBFillColor(context, 0.0, 1.0, 0.0, 0.3);
            //CGContextFillRect(context, currentDayRect);
            //draw round rectangle
            CGFloat radius = 4;
            CGFloat width = CGRectGetWidth(dayFrame);
            CGFloat height = CGRectGetHeight(dayFrame);
            
            // Make sure corner radius isn't larger than half the shorter side
            if (radius > width/2.0)
                radius = width/2.0;
            if (radius > height/2.0)
                radius = height/2.0;    
            
            CGFloat minx = CGRectGetMinX(dayFrame);
            CGFloat midx = CGRectGetMidX(dayFrame);
            CGFloat maxx = CGRectGetMaxX(dayFrame);
            CGFloat miny = CGRectGetMinY(dayFrame);
            CGFloat midy = CGRectGetMidY(dayFrame);
            CGFloat maxy = CGRectGetMaxY(dayFrame);

            CGSize shadowSize = CGSizeMake(2, 1);
            if(i != 0){
                CGContextSetShadowWithColor(context, shadowSize, 4,
                                            [UIColor colorWithRed:0 green:0
                                                             blue:0 alpha:0.6].CGColor);
            }
            CGContextMoveToPoint(context, minx, midy);
            CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
            CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
            CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
            CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);
        
            CGContextSetShadowWithColor(context, shadowSize, 10,
                                    [UIColor clearColor].CGColor);
        
            if (_selectedDate != nil) {
                if ([[d dateOnly] compare:[self.selectedDate dateOnly]] == NSOrderedSame) {
                    UIImage *img = [UIImage imageNamed:@"bgCalendarWeekTileSelected"];
                    [img drawInRect:dayFrame];
                }
            }
            
            //EDIT Draw days text
            UIColor *timeColor = hourColor ? hourColor : [UIColor blackColor];
            [timeColor set];
            NSDate *currentDate = [self.beginningOfWeek dateByAddingDays:i];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* compoNents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
            NSString *currentDay = [NSString stringWithFormat:@"%d",[compoNents day]];
            //CGRect dayFrame = [self getViewRectForDay:i + 1];
            CGRect stringFrame = CGRectMake(dayFrame.origin.x + dayFrame.size.width/2 - 3, dayFrame.origin.y, dayFrame.size.width/2, dayFrame.size.width/2);
            UIFont *dayFont = [UIFont boldSystemFontOfSize:15];
            [currentDay drawInRect:CGRectIntegral(stringFrame)
                          withFont:dayFont 
                     lineBreakMode:UILineBreakModeWordWrap 
                         alignment:UITextAlignmentRight];
            
            //EDIT DRAW ICON
            /*
            UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/markCalendar"];
            CGRect imageFrame = CGRectMake(dayFrame.origin.x + dayFrame.size.width/2 - 3, dayFrame.origin.y + dayFrame.size.height - dayFrame.size.width/3, dayFrame.size.width/3, dayFrame.size.width/3);
            [calendarIcon drawInRect:imageFrame];
            */
            CGContextRestoreGState(context);
//        }
    }
    
    // Draw current time line
    if ([self isCurrentWeek]) {
        NSInteger currentHour = [[NSDate date] dateInformation].hour;
        CGFloat currentHourPosition = roundf((currentHour * VERTICAL_DIFF_WEEK) + VERTICAL_OFFSET + ((FONT_SIZE + 4.0) / 2.0));
        NSInteger currentMinute = [[NSDate date] dateInformation].minute;
        currentMinute = round(currentMinute / 5.0) * 5;
        CGFloat currentMinutePosition = roundf((CGFloat)currentMinute / 60.0f * VERTICAL_DIFF_WEEK);
        CGFloat currentTimeY = currentHourPosition + currentMinutePosition;
        
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddEllipseInRect(context, CGRectMake(20, currentTimeY - 3, 6, 6));
        CGContextFillPath(context);
        
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(context, 1.0);
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 26, currentTimeY);
        CGContextAddLineToPoint(context, 320, currentTimeY);
        CGContextStrokePath(context);
        // End of Draw current time line
    }
}

- (CGRect) getViewRectForDay:(int)day {
	// For gregorian day index, return view rect
	float weekday_width = (self.bounds.size.width - HORIZONTAL_OFFSET - TIME_WIDTH - TIME_PADDING_LEFT) / (self.isFiveDayWeek ? 5 : 7);
    CGFloat paddingTop = 3.0f;
	return CGRectMake(HORIZONTAL_OFFSET + TIME_WIDTH + TIME_PADDING_LEFT + (day-1)*weekday_width, paddingTop, weekday_width, self.bounds.size.height - paddingTop);
}

-(NSDictionary *) getColorForMoodType:(TapkuWeeklyViewMoodType) type{
    NSMutableDictionary *colorData = [NSMutableDictionary dictionary];
    switch (type) {
        case TapkuWeeklyViewMoodTypeMood1:
        {
            // change for same with color star
//            [colorData setObject:[NSNumber numberWithFloat:223.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:45.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
            
            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:160.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
        }
            break;
        case TapkuWeeklyViewMoodTypeMood2:
        {
//            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:234.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
            [colorData setObject:[NSNumber numberWithFloat:62.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:169.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:159.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
        }
            break;
        case TapkuWeeklyViewMoodTypeMood3:
        {
//            [colorData setObject:[NSNumber numberWithFloat:158.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:212.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
            [colorData setObject:[NSNumber numberWithFloat:82.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:208.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:23.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
        }
            break;
        case TapkuWeeklyViewMoodTypeMood4:
        {
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:191.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:28.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
        }
            break;
        case TapkuWeeklyViewMoodTypeMood5:
        {
//            [colorData setObject:[NSNumber numberWithFloat:42.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:246.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
            [colorData setObject:[NSNumber numberWithFloat:251.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:185.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:23.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
        }
            break;
//        case TapkuWeeklyViewMoodTypeMood6:
//        {
//            [colorData setObject:[NSNumber numberWithFloat:98.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:212.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
//        }
//            break;
//        case TapkuWeeklyViewMoodTypeMood7:
//        {
//            [colorData setObject:[NSNumber numberWithFloat:6.0f/255] forKey:kTapkuRed];
//            [colorData setObject:[NSNumber numberWithFloat:0.0f/255] forKey:kTapkuGreen];
//            [colorData setObject:[NSNumber numberWithFloat:148.0f/255] forKey:kTapkuBlue];
//            [colorData setObject:[NSNumber numberWithFloat:1] forKey:kTapkuAlpha];
//        }
//            break;
        default:
        {
            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuRed];
            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuGreen];
            [colorData setObject:[NSNumber numberWithFloat:255.0f/255] forKey:kTapkuBlue];
            [colorData setObject:[NSNumber numberWithFloat:0.6] forKey:kTapkuAlpha];
        }
            break;
    }
    return colorData;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[_times release];
	[_periods release];
	[hourColor release];
	
    [super dealloc];
}


@end
