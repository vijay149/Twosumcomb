//
//  TKCalendarMonthView.h
//  Created by Devin Ross on 6/10/10.
//
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#define kMonthlyViewGotDoubleTap        @"kMonthlyViewGotDoubleTap"

typedef enum {
    TapkuMonthlyViewMoodTypeNone                = 0,
    TapkuMonthlyViewMoodTypeMood1               = 1,
    TapkuMonthlyViewMoodTypeMood2               = 2,
    TapkuMonthlyViewMoodTypeMood3               = 3,
    TapkuMonthlyViewMoodTypeMood4               = 4,
    TapkuMonthlyViewMoodTypeMood5               = 5,
    TapkuMonthlyViewMoodTypeMood6               = 6,
    TapkuMonthlyViewMoodTypeMood7               = 7,
} TapkuMonthlyViewMoodType;

@class TKCalendarMonthTiles;
@protocol TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource;


@interface TKCalendarMonthView : UIView {

	TKCalendarMonthTiles *currentTile,*oldTile;
	UIButton *leftArrow, *rightArrow;
	UIImageView *topBackground, *shadow;
	UILabel *monthYear;
	UIScrollView *tileBox;
	BOOL sunday;

	id <TKCalendarMonthViewDelegate> delegate;
	id <TKCalendarMonthViewDataSource> dataSource;

}
- (id) initWithSundayAsFirst:(BOOL)sunday; // or Monday

@property (nonatomic,assign) id <TKCalendarMonthViewDelegate> delegate;
@property (nonatomic,assign) id <TKCalendarMonthViewDataSource> dataSource;
@property (nonatomic, assign) BOOL selectionMode;

- (NSDate*) dateSelected;
- (NSDate*) monthDate;
- (void) selectDate:(NSDate*)date;
- (void) reload;

@end


@protocol TKCalendarMonthViewDelegate <NSObject>
@optional
- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date;
- (BOOL) calendarMonthView:(TKCalendarMonthView*)monthView monthShouldChange:(NSDate*)month animated:(BOOL)animated;
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthWillChange:(NSDate*)month animated:(BOOL)animated;
- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month animated:(BOOL)animated;
@end

@protocol TKCalendarMonthViewDataSource <NSObject>
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView eventsFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView fertleFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView menstratingFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView sensitiveFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;
- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView moodFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate;

@end