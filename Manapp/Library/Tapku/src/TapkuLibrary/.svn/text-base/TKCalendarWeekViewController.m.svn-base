//
//  TKCalendarWeekViewController.m
//  Based on TKCalendarDayViewController by Devin Ross.
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

#import "TKCalendarWeekViewController.h"
#import "TKCalendarDayEventView.h"
#import "NSDate+TKCategory.h"

@implementation TKCalendarWeekViewController
@synthesize calendarWeekTimelineView;

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}
- (void) viewDidUnload {
	self.calendarWeekTimelineView = nil;
}
- (void) dealloc {
	self.calendarWeekTimelineView = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.calendarWeekTimelineView.isFiveDayWeek = NO;
    self.calendarWeekTimelineView.frame = CGRectMake(0, 0, 320, 416);
    [self.view addSubview:self.calendarWeekTimelineView];
}

- (NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventsForDate:(NSDate *)eventDate{
	return nil;
}
-(NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline eventsInWeekForDate:(NSDate *)eventDate{
    return nil;
}
-(NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline fertleInWeekForDate:(NSDate *)eventDate{
    return nil;
}
-(NSArray *)calendarWeekTimelineView:(TKCalendarWeekTimelineView *)calendarWeekTimeline menstratingInWeekForDate:(NSDate *)eventDate{
    return nil;
}

- (void)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
	NSLog(@"CalendarWeekTimelineView: EventViewWasSelected");
}

- (void)calendarWeekTimelineView:(TKCalendarWeekTimelineView*)calendarWeekTimeline tapDetect:(CGPoint)location{
	NSLog(@"CalendarWeekTimelineView: TapDetect");
}

- (void)calendarPrevWeekClicked:(TKCalendarWeekTimelineView *)calendarWeekTimeline {
    NSLog(@"CalendarWeekTimelineView: calendarPrevWeekClicked");
    UIView *currentView = self.calendarWeekTimelineView.timelineView;
    UIView *theWindow = [currentView superview];
    self.calendarWeekTimelineView.currentDay = [self.calendarWeekTimelineView.currentDay dateByAddingDays:-7];
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[theWindow layer] addAnimation:animation forKey:@"SwitchView"];
}

- (void)calendarNextWeekClicked:(TKCalendarWeekTimelineView *)calendarWeekTimeline {
    NSLog(@"CalendarWeekTimelineView: calendarNextWeekClicked");
    UIView *currentView = self.calendarWeekTimelineView.timelineView;
    UIView *theWindow = [currentView superview];
    self.calendarWeekTimelineView.currentDay = [self.calendarWeekTimelineView.currentDay dateByAddingDays:7];
    // set up an animation for the transition between the views
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

@end