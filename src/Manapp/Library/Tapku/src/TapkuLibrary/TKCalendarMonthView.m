//
//  TKCalendarMonthView.m
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

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"

//#define kCalendImagesPath @"TapkuLibrary.bundle/Images/calendar/"
#pragma mark -
@interface NSDate (calendarcategory)

- (NSDate*) firstOfMonth;
- (NSDate*) nextMonth;
- (NSDate*) previousMonth;

@end


#pragma mark -

@implementation NSDate (calendarcategory)

- (NSDate*) firstOfMonth{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
}
- (NSDate*) nextMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	info.month++;
	if(info.month>12){
		info.month = 1;
		info.year++;
	}
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	
}
- (NSDate*) previousMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	info.month--;
	if(info.month<1){
		info.month = 12;
		info.year--;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	
}

@end


#pragma mark -

@interface TKCalendarMonthTiles : UIView {
	
	id target;
	SEL action;
//	NSInteger numberEvent;
	int firstOfPrev,lastOfPrev;
	NSArray *marks;
    //EDIT add event
    NSArray *events;
    NSArray *fertles;
    NSArray *menstrating;
	int today;
	BOOL markWasOnToday;
	
	int selectedDay,selectedPortion;
	
	int firstWeekday, daysInMonth;
	UILabel *dot;
    UIImageView *iconCalendar;
    UIImageView *iconCalendarSelected;
    UIImageView *iconMenstrating;
    UIImageView *iconFertle;
    UIImageView *iconSensitive;
    UIImageView *iconMood;
    
	UILabel *currentDay;
	UIImageView *selectedImageView;
	BOOL startOnSunday;
	NSDate *monthDate;
    BOOL selectionMode;
}
@property (readonly) NSDate *monthDate;
//EDIT add property
@property (nonatomic, retain) NSArray *events;
@property (nonatomic, retain) NSArray *fertles;
@property (nonatomic, retain) NSArray *menstrating;
@property (nonatomic, retain) NSArray *sensitive;
@property (nonatomic, retain) NSArray *moods;
- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday mode:(BOOL)mode;
- (void) setTarget:(id)target action:(SEL)action;

- (void) selectDay:(int)day;
- (NSDate*) dateSelected;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;

@end

#pragma mark -

#define dotFontSize 18.0
#define dateFontSize 22.0

@interface TKCalendarMonthTiles (private)

@property (readonly) UIImageView *selectedImageView;
@property (readonly) UILabel *currentDay;
@property (readonly) UILabel *dot;
@property (readonly) UIImageView *iconCalendar;
@property (readonly) UIImageView *iconMenstrating;
@property (readonly) UIImageView *iconFertle;
@property (readonly) UIImageView *iconSensitive;
@property (readonly) UIImageView *iconCalendarSelected;
@end

#pragma mark -

@implementation TKCalendarMonthTiles
@synthesize monthDate,events,fertles,menstrating,sensitive,moods;


+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{
	
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	
	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	
	
	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];
	
	if(info.weekday > 1 && sunday){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
		
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];		
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone systemTimeZone]];
		
		
	}else if(!sunday && info.weekday != 2){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone systemTimeZone]];
		
		
		
	}else{
		firstDate = currentMonth;
	}
	
	
	
	int daysInMonth = [currentMonth daysBetweenDate:nextMonth];		
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
    
	
	
	if(lastDateInfo.weekday < 7 && sunday){
		
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone systemTimeZone]];
        
	}else if(!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }
        
		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone systemTimeZone]];
        
	}else{
		lastDate = lastInMonth;
	}
	
	
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

- (void)tapGesture:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMonthlyViewGotDoubleTap object:nil];
}
#pragma Mark - EDIT BACKGROUND TO MAKE CALENDAR CELL TRANSPARENT (1/2)
- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday mode:(BOOL)mode {
    self = [super initWithFrame:CGRectZero];
	if(!self) return nil;
    //Edit : EDIT BACKGROUND TO MAKE CALENDAR CELL TRANSPARENT (1/2)
    self.backgroundColor = [UIColor clearColor];
    selectionMode = mode;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tap.numberOfTapsRequired = 2;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    [tap release];
    
	firstOfPrev = -1;
	marks = [markArray retain];
	monthDate = [date retain];
	startOnSunday = sunday;
	
    
	
	TKDateInformation dateInfo = [monthDate dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	firstWeekday = dateInfo.weekday;
	
	
	NSDate *prev = [monthDate previousMonth];
	//NSDate *next = [monthDate nextMonth];
	
	daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
	
	int row = (daysInMonth + dateInfo.weekday - 1);
	if(dateInfo.weekday==1&&!sunday) row = daysInMonth + 6;
	if(!sunday) row--;
	
    
	row = (row / 7) + ((row % 7 == 0) ? 0:1);
	float h = 44 * row;
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = [prev daysBetweenDate:monthDate];		
	if(firstWeekday>1 && sunday){
		firstOfPrev = preDayCnt - firstWeekday+2;
		lastOfPrev = preDayCnt;
	}else if(!sunday && firstWeekday != 2){
		
		if(firstWeekday ==1){
			firstOfPrev = preDayCnt - 5;
		}else{
			firstOfPrev = preDayCnt - firstWeekday+3;
		}
		lastOfPrev = preDayCnt;
        
	}
	
	
    
	
	self.frame = CGRectMake(0, 1, 320, h+1);
	
	[self.selectedImageView addSubview:self.currentDay];
//	[self.selectedImageView addSubview:self.dot];
	self.multipleTouchEnabled = NO;
	
	return self;
}
- (void) dealloc {
	[currentDay release];
	[dot release];
    [iconCalendar release];
    [iconCalendarSelected release];
    [iconMenstrating release];
    [iconSensitive release];
    [iconFertle release];
	[selectedImageView release];
	[marks release];
	[monthDate release];
    [super dealloc];
}

- (void) setTarget:(id)t action:(SEL)a{
	target = t;
	action = a;
}


- (CGRect) rectForCellAtIndex:(int)index{
	
	int row = index / 7;
	int col = index % 7;
	
	return CGRectMake(col*46, row*44+6, 47, 45);
}
#pragma mark - EDIT change text to Top-Right corner
- (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2{
    if (selectionMode) {
        if (mark) {
            r.origin.y -= 7;
            //UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
            UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected.png")];
            [selectedImage drawInRect:r];
            r.origin.y += 7;
        }
    }
	
	NSString *str = [NSString stringWithFormat:@"%d",day];
	
	r.size.height -= 2;
    
    //edit:move the text to the top-right of the cell
    CGRect newR = CGRectMake(r.origin.x + r.size.width/2 - 4, r.origin.y - 4, r.size.width/2 + 3, r.size.height/2);
    //[str drawInRect: r
	[str drawInRect: newR
		   withFont: f1
	  lineBreakMode: UILineBreakModeWordWrap 
		  alignment: UITextAlignmentRight];
	
    //EDIT REMOVE DOT, REPLACE BY CALENDAR ICON
	if(mark){
        r.size.height = 10;
		r.origin.y += 18;
        /*
         [@"•" drawInRect: r
         withFont: f2
         lineBreakMode: UILineBreakModeWordWrap 
         alignment: UITextAlignmentCenter];
         */
        
        // COMMENT: event icon
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/markCalendar"];
        CGRect imageFrame = CGRectMake(r.origin.x + r.size.width/2, r.origin.y + r.size.height - r.size.width/4, r.size.width/3 + 4, r.size.width/3 + 4);
        [calendarIcon drawInRect:imageFrame];
        
        // COMMENT: fertle icon
        UIImage *fertleIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconFertle"];
        CGRect fertleImageFrame = CGRectMake(r.origin.x + 1 , r.origin.y + r.size.height - r.size.width/6, r.size.width/2, r.size.width/4);
        [fertleIcon drawInRect:fertleImageFrame];
        
        // COMMENT: sensitive icon
        UIImage *sensitiveIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconSensitive"];
        CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y + r.size.height - r.size.width/4, r.size.width/3, r.size.width/3);
        [sensitiveIcon drawInRect:sensitiveImageFrame];
        
        // COMMENT: menstrating icon
        UIImage *menstratingIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconMenstrating"];
        CGRect menstratingImageFrame = CGRectMake(r.origin.x + 4, r.origin.y + r.size.height - r.size.width/4 + 3, r.size.width/3, r.size.width/3);
        [menstratingIcon drawInRect:menstratingImageFrame];
	}
}

#pragma mark - EDIT drawRect to draw event icon

// HIEU MODIFIED
- (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark event:(NSInteger)numberOfEvent  fertle:(BOOL)hasFertle menstrating:(BOOL)hasMenstrating sensitive:(BOOL)hasSensitive mood:(TapkuMonthlyViewMoodType) mood font:(UIFont*)f1 font2:(UIFont*)f2{
    if (selectionMode) {
        /*
         if (mark) {
         r.origin.y -= 7;
         //UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
         UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected.png")];
         [selectedImage drawInRect:r];
         r.origin.y += 7;
         }
         */
        if (numberOfEvent > 0) {
            r.origin.y -= 7;
            //UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
            UIImage *selectedImage = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected.png")];
            [selectedImage drawInRect:r];
            r.origin.y += 7;
        }
    }
	
	NSString *str = [NSString stringWithFormat:@"%d",day];
	
	r.size.height -= 2;
    
    //edit:move the text to the top-right of the cell
    CGRect newR = CGRectMake(r.origin.x + r.size.width/2 - 6, r.origin.y - 6, r.size.width/2 + 3, r.size.height/2);
    //[str drawInRect: r
	[str drawInRect: newR
		   withFont: f1
	  lineBreakMode: UILineBreakModeWordWrap 
		  alignment: UITextAlignmentRight];
	
    //EDIT REMOVE DOT, REPLACE BY CALENDAR ICON
    /*
     if(mark){
     r.size.height = 10;
     r.origin.y += 18;
     
     [@"•" drawInRect: r
     withFont: f2
     lineBreakMode: UILineBreakModeWordWrap 
     alignment: UITextAlignmentCenter];
     
     }
     */
    if((numberOfEvent > 0) || hasFertle || hasMenstrating || hasSensitive || (mood != TapkuMonthlyViewMoodTypeNone)){
        r.size.height = 10;
		r.origin.y += 18;
        
        if (numberOfEvent > 0) {
            // COMMENT: event icon
            UIImage *calendarIcon = [UIImage imageNamedTK:(numberOfEvent < 2)?@"TapkuLibrary.bundle/Images/calendar/markCalendar":@"TapkuLibrary.bundle/Images/calendar/markCalendarDouble"];
            CGRect imageFrame = CGRectMake(r.origin.x + r.size.width/2, r.origin.y + r.size.height - r.size.width/4, r.size.width/3 + 4, r.size.width/3 + 4);
            [calendarIcon drawInRect:imageFrame];
        }
        
        if (hasFertle) {
            // COMMENT: fertle icon
            UIImage *fertleIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconFertle"];
            CGRect fertleImageFrame = CGRectMake(r.origin.x, r.origin.y + r.size.height - r.size.width/6, r.size.width/2, r.size.width/4);
            [fertleIcon drawInRect:fertleImageFrame];
        }
        
        if (hasMenstrating) {
            // COMMENT: menstrating icon
            UIImage *menstratingIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconMenstrating"];
            CGRect menstratingImageFrame = CGRectMake(r.origin.x + 4, r.origin.y + r.size.height - r.size.width/4 + 3, r.size.width/3, r.size.width/3);
            [menstratingIcon drawInRect:menstratingImageFrame];            
        }
        
        if (hasSensitive) {
            // COMMENT: menstrating icon
            UIImage *sensitiveIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconSensitive"];
            CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y + r.size.height - r.size.width/4, r.size.width/3, r.size.width/3);
            [sensitiveIcon drawInRect:sensitiveImageFrame];
        }
        
        if(mood != TapkuMonthlyViewMoodTypeNone ){
            UIImage *moodIcon = [self imageMoodWithType:mood];
            
            CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y - r.size.width/2 + 2, r.size.width/3, r.size.width/3);
            [moodIcon drawInRect:sensitiveImageFrame];
        }
    }
}

#pragma mark - EDIT background cell and text size
- (void) drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    //edit: change the background cell of all calendar
	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTile.png")];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);
	
	if(today > 0){
		int pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
		int index = today +  pre-1;
		CGRect r =[self rectForCellAtIndex:index];
		r.origin.y -= 7;
        ///!!!: change by issue MA-365
		[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Tile.png")] drawInRect:r];
	}
	
	int index = 0;
	
	//UIFont *font = [UIFont boldSystemFontOfSize:dateFontSize];
    UIFont *font = [UIFont fontWithName:@"BankGothic Md BT" size:16];
	UIFont *font2 =[UIFont boldSystemFontOfSize:dotFontSize];
	UIColor *color = [UIColor grayColor];

	if(firstOfPrev>=0){
		[color set];
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			r = [self rectForCellAtIndex:index];
//			if ([events count] > 0)
//				[self drawTileInRect:r day:i mark:NO event:[[events objectAtIndex:index] boolValue] font:font font2:font2];
//			else
//				[self drawTileInRect:r day:i mark:NO event:NO font:font font2:font2];
            // HIEU MODIFIED
            NSInteger eventNumber = 0;
            if ([events count] > 0) {
                eventNumber = [[events objectAtIndex:index] intValue];
            }
            
            BOOL hasFertle = NO;
            if ([fertles count] > 0) {
                hasFertle = [[fertles objectAtIndex:index] boolValue];
            }

            BOOL hasMenstrating = NO;
            if ([menstrating count] > 0) {
                hasMenstrating = [[menstrating objectAtIndex:index] boolValue];
            }
            
            BOOL hasSensitive = NO;
            if ([sensitive count] > 0) {
                hasSensitive = [[sensitive objectAtIndex:index] boolValue];
            }
            
            CGFloat mood = -1;
            if ([moods count] > 0) {
                mood = (TapkuMonthlyViewMoodType)[[moods objectAtIndex:index] intValue];
            }
            
            [self drawTileInRect:r day:i mark:NO event:eventNumber fertle:hasFertle menstrating:hasMenstrating sensitive:hasSensitive mood:mood font:font font2:font2];
			index++;
		}
	}
	
	color = [UIColor blackColor];
	[color set];
	for(int i=1; i <= daysInMonth; i++){
		
		r = [self rectForCellAtIndex:index];
        
        
		///!!!: change by issue MA-365 2
        if(today == i) [[UIColor whiteColor] set];
		
//		if ([events count] > 0) 
//			[self drawTileInRect:r day:i mark:NO event:[[events objectAtIndex:index] boolValue] font:font font2:font2];
//		else
//			[self drawTileInRect:r day:i mark:NO event:NO font:font font2:font2];
        
        // HIEU MODIFIED
        NSInteger eventNumber = 0;
        if ([events count] > 0) {
            eventNumber = [[events objectAtIndex:index] intValue];
        }
        
        BOOL hasFertle = NO;
        if ([fertles count] > 0) {
            hasFertle = [[fertles objectAtIndex:index] boolValue];
        }
        
        BOOL hasMenstrating = NO;
        if ([menstrating count] > 0) {
            hasMenstrating = [[menstrating objectAtIndex:index] boolValue];
        }
        
        BOOL hasSensitive = NO;
        if ([sensitive count] > 0) {
            hasSensitive = [[sensitive objectAtIndex:index] boolValue];
        }
        
        CGFloat mood = -1;
        if ([moods count] > 0) {
            mood = (TapkuMonthlyViewMoodType)[[moods objectAtIndex:index] intValue];
        }
        
        [self drawTileInRect:r day:i mark:NO event:eventNumber fertle:hasFertle menstrating:hasMenstrating sensitive:hasSensitive mood:mood font:font font2:font2];

		if(today == i) [color set];
		index++;
	}
	
	[[UIColor grayColor] set];
	int i = 1;
	while(index % 7 != 0){
		r = [self rectForCellAtIndex:index] ;
        
//		if ([events count] > 0) 
//			[self drawTileInRect:r day:i mark:NO event:[[events objectAtIndex:index] boolValue] font:font font2:font2];
//		else
//			[self drawTileInRect:r day:i mark:NO event:NO font:font font2:font2];
        
        // HIEU MODIFIED
        NSInteger eventNumber = 0;
        if ([events count] > 0) {
            eventNumber = [[events objectAtIndex:index] intValue];
        }
        
        BOOL hasFertle = NO;
        if ([fertles count] > 0) {
            hasFertle = [[fertles objectAtIndex:index] boolValue];
        }
        
        BOOL hasMenstrating = NO;
        if ([menstrating count] > 0) {
            hasMenstrating = [[menstrating objectAtIndex:index] boolValue];
        }
        
        BOOL hasSensitive = NO;
        if ([sensitive count] > 0) {
            hasSensitive = [[sensitive objectAtIndex:index] boolValue];
        }
        
        CGFloat mood = -1;
        if ([moods count] > 0) {
            mood = (TapkuMonthlyViewMoodType)[[moods objectAtIndex:index] intValue];
        }
        
        [self drawTileInRect:r day:i mark:NO event:eventNumber fertle:hasFertle menstrating:hasMenstrating sensitive:hasSensitive mood:mood font:font font2:font2];

		i++;
		index++;
	}
	
	
}

- (void) selectDay:(int)day{
	
	int pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
	
	int tot = day + pre;
	int row = tot / 7;
	int column = (tot % 7)-1;
	
	selectedDay = day;
	selectedPortion = 1;
	
	
	if(day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
        ///!!!: change by issue MA-365
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		
		//self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected.png")];
		markWasOnToday = NO;
	}
	
	
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
//	if ([marks count] > 0) {
//		
//		if([[marks objectAtIndex: row * 7 + column ] boolValue]){
//			[self.selectedImageView addSubview:self.dot];
//		}else{
//			[self.dot removeFromSuperview];
//		}
//		
//		
//	}else{
//		[self.dot removeFromSuperview];
//	}
    
    if ([events count] > 0) {
        if ([[events objectAtIndex:row * 7 + column] boolValue]) {
//            if (events.count > 1) {
//                [self.selectedImageView addSubview:self.iconCalendarSelected];
//            } else {
                [self.selectedImageView addSubview:self.iconCalendar];
//            }
        
        } else {
            [self.iconCalendar removeFromSuperview];
//            [self.iconCalendarSelected removeFromSuperview];
        }
    } else {
        [self.iconCalendar removeFromSuperview];
    }
    
    if ([menstrating count] > 0) {
        if ([[menstrating objectAtIndex:row * 7 + column] boolValue]) {
            [self.selectedImageView addSubview:self.iconMenstrating];
        } else {
            [self.iconMenstrating removeFromSuperview];
        }
    } else {
        [self.iconMenstrating removeFromSuperview];
    }
    
    if ([sensitive count] > 0) {
        if ([[sensitive objectAtIndex:row * 7 + column] floatValue] >= 0) {
            [self.selectedImageView addSubview:self.iconSensitive];
        } else {
            [self.iconSensitive removeFromSuperview];
        }
    } else {
        [self.iconSensitive removeFromSuperview];
    }
    
    if ([moods count] > 0) {
        if ([[moods objectAtIndex:row * 7 + column] intValue] != TapkuMonthlyViewMoodTypeNone) {
            [self.selectedImageView addSubview:[self iconMoodWithMoodType:[[moods objectAtIndex:row * 7 + column] intValue]]];
        } else {
            [self.iconMood removeFromSuperview];
        }
    } else {
        [self.iconMood removeFromSuperview];
    }
    
    if ([fertles count] > 0) {
        if ([[fertles objectAtIndex:row * 7 + column] boolValue]) {
            [self.selectedImageView addSubview:self.iconFertle];
        } else {
            [self.iconFertle removeFromSuperview];
        }
    } else {
        [self.iconFertle removeFromSuperview];
    }
	
	if(column < 0){
		column = 6;
		row--;
	}
	
	CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;
	
	
	
}
- (NSDate*) dateSelected{
	if(selectedDay < 1 || selectedPortion != 1) return nil;
	
	TKDateInformation info = [monthDate dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	info.day = selectedDay;
	NSDate *d = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
	
    
	
	return d;
	
}



- (void) reactToTouch:(UITouch*)touch down:(BOOL)down{
	
	CGPoint p = [touch locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;
	
	if(row == (int) (self.bounds.size.height / 44)) row --;
	
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	
	if(row==0 && column < fir){
		day = firstOfPrev + column;
	}else{
		portion = 1;
		day = row * 7 + column  - firstWeekday+2;
		if(!startOnSunday) day++;
		if(!startOnSunday && fir==6) day -= 7;
        
	}
	if(portion > 0 && day > daysInMonth){
		portion = 2;
		day = day - daysInMonth;
	}
	
	
	if(portion != 1){
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
		markWasOnToday = YES;
	}else if(portion==1 && day == today){
		self.currentDay.shadowOffset = CGSizeMake(0, 1);
		self.dot.shadowOffset = CGSizeMake(0, 1);
        ///!!!: change by issue MA-365
		self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Today Selected Tile.png")];
		markWasOnToday = YES;
	}else if(markWasOnToday){
		self.dot.shadowOffset = CGSizeMake(0, -1);
		self.currentDay.shadowOffset = CGSizeMake(0, -1);
		//self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png")];
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected.png")];
		markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
	
//	if ([marks count] > 0) {
//		if([[marks objectAtIndex: row * 7 + column] boolValue])
//			[self.selectedImageView addSubview:self.dot];
//		else
//			[self.dot removeFromSuperview];
//	}else{
//		[self.dot removeFromSuperview];
//	}
	
    if ([events count] > 0) {
        NSLog(@"index %d",row * 7 + column);
        NSNumber *countEvent = [events objectAtIndex:row * 7 + column];
        NSLog(@"count event: %@",countEvent);
        if ([[events objectAtIndex:row * 7 + column] boolValue]) {
            if ([countEvent integerValue] > 1) {
                [self.selectedImageView addSubview:self.iconCalendarSelected];
            } else {
               [self.selectedImageView addSubview:self.iconCalendar];
            }
        } else {
            [self.iconCalendar removeFromSuperview];
            [self.iconCalendarSelected removeFromSuperview];
        }
    } else {
        [self.iconCalendar removeFromSuperview];
        [self.iconCalendarSelected removeFromSuperview];
    }
    
    if ([menstrating count] > 0) {
        if ([[menstrating objectAtIndex:row * 7 + column] boolValue]) {
            [self.selectedImageView addSubview:self.iconMenstrating];
        } else {
            [self.iconMenstrating removeFromSuperview];
        }
    } else {
        [self.iconMenstrating removeFromSuperview];
    }
    
    if ([sensitive count] > 0) {
        if ([[sensitive objectAtIndex:row * 7 + column] boolValue]) {
            [self.selectedImageView addSubview:self.iconSensitive];
        } else {
            [self.iconSensitive removeFromSuperview];
        }
    } else {
        [self.iconSensitive removeFromSuperview];
    }
    
    if ([moods count] > 0) {
        if ([[moods objectAtIndex:row * 7 + column] intValue] != TapkuMonthlyViewMoodTypeNone) {
            [self.selectedImageView addSubview:[self iconMoodWithMoodType:[[moods objectAtIndex:row * 7 + column] intValue]]];
        } else {
            [self.iconMood removeFromSuperview];
        }
    } else {
        [self.iconMood removeFromSuperview];
    }
    
    if ([fertles count] > 0) {
        if ([[fertles objectAtIndex:row * 7 + column] boolValue]) {
            [self.selectedImageView addSubview:self.iconFertle];
        } else {
            [self.iconFertle removeFromSuperview];
        }
    } else {
        [self.iconFertle removeFromSuperview];
    }
	
	CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;
	
	if(day == selectedDay && selectedPortion == portion) return;
	
	
	
	if(portion == 1){
		selectedDay = day;
		selectedPortion = portion;
		[target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]];
		
	}
	else if(down){
		[target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil]];
		selectedDay = day;
		selectedPortion = portion;
	}
	
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
} 
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:NO];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self reactToTouch:[touches anyObject] down:YES];
}
#pragma mark - EDIT TEXT IN SELECTED FIELD
- (UILabel *) currentDay{
	if(currentDay==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y -= 2;
        CGRect newR = CGRectMake(r.origin.x + r.size.width/2 - 9, r.origin.y, r.size.width/2 + 8, r.size.height/2);
		//currentDay = [[UILabel alloc] initWithFrame:r];
        currentDay = [[UILabel alloc] initWithFrame:newR];
		currentDay.text = @"1";
		currentDay.textColor = [UIColor blackColor];
		currentDay.backgroundColor = [UIColor clearColor];
        //currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
		//currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize - 5];
        currentDay.font = [UIFont fontWithName:@"BankGothic Md BT" size:dateFontSize-5];
		currentDay.textAlignment = UITextAlignmentRight;
//		currentDay.shadowColor = [UIColor darkGrayColor];
//		currentDay.shadowOffset = CGSizeMake(0, -1);
	}
	return currentDay;
}
- (UILabel *) dot{
	if(dot==nil){
		CGRect r = self.selectedImageView.bounds;
		r.origin.y += 29;
		r.size.height -= 31;
		dot = [[UILabel alloc] initWithFrame:r];
		
		dot.text = @"•";
		dot.textColor = [UIColor whiteColor];
		dot.backgroundColor = [UIColor clearColor];
		dot.font = [UIFont boldSystemFontOfSize:dotFontSize];
		dot.textAlignment = UITextAlignmentCenter;
		dot.shadowColor = [UIColor darkGrayColor];
		dot.shadowOffset = CGSizeMake(0, -1);
	}
	return dot;
}

- (UIImageView *)iconCalendar
{
    if (iconCalendar == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/markCalendar"];
        CGRect imageFrame = CGRectMake(r.origin.x + r.size.width/2, r.origin.y + r.size.height - r.size.width/2, r.size.width/3 + 4, r.size.width/3 + 4);
        iconCalendar = [[UIImageView alloc] initWithFrame:r];
        iconCalendar.image = calendarIcon;        
        iconCalendar.frame = imageFrame;
    }
    return iconCalendar;
}

- (UIImageView *)iconCalendarSelected
{
    if (iconCalendarSelected == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/markCalendarDouble"];
        CGRect imageFrame = CGRectMake(r.origin.x + r.size.width/2, r.origin.y + r.size.height - r.size.width/2, r.size.width/3 + 4, r.size.width/3 + 4);
        iconCalendarSelected = [[UIImageView alloc] initWithFrame:r];
        iconCalendarSelected.image = calendarIcon;
        iconCalendarSelected.frame = imageFrame;
    }
    return iconCalendarSelected;
}

- (UIImageView *)iconMenstrating
{
    if (iconMenstrating == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconMenstrating"];
        CGRect menstratingImageFrame = CGRectMake(r.origin.x + 4, r.origin.y + r.size.width/3 + 8, r.size.width/3, r.size.width/3);
        iconMenstrating = [[UIImageView alloc] initWithFrame:r];
        iconMenstrating.image = calendarIcon;
        iconMenstrating.frame = menstratingImageFrame;
    }
    return iconMenstrating;
}

- (UIImageView *)iconSensitive
{
    if (iconSensitive == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconSensitive"];
        CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y + r.size.width/3 + 5, r.size.width/3, r.size.width/3);
        iconSensitive = [[UIImageView alloc] initWithFrame:r];
        iconSensitive.image = calendarIcon;
        iconSensitive.frame = sensitiveImageFrame;
    }
    return iconSensitive;
}

- (UIImageView *)iconMood
{
    if (iconMood == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-1"];
        CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y + 5, r.size.width/3, r.size.width/3);
        iconMood = [[UIImageView alloc] initWithFrame:r];
        iconMood.image = calendarIcon;
        iconMood.frame = sensitiveImageFrame;
    }
    return iconMood;
}

- (UIImageView *)iconMoodWithMoodType:(TapkuMonthlyViewMoodType) moodType
{
    if (iconMood == nil) {
        CGRect r = self.selectedImageView.bounds;
        CGRect sensitiveImageFrame = CGRectMake(r.origin.x + 2, r.origin.y + 3, r.size.width/3, r.size.width/3);
        iconMood = [[UIImageView alloc] initWithFrame:r];
        iconMood.frame = sensitiveImageFrame;
    }
    UIImage *calendarIcon = [self imageMoodWithType:moodType];
    iconMood.image = calendarIcon;
    return iconMood;
}

-(UIImage *) imageMoodWithType:(TapkuMonthlyViewMoodType) moodType{
    UIImage *moodIcon = nil;
    switch (moodType) {
        case TapkuMonthlyViewMoodTypeMood1:
            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-1"];
            break;
        case TapkuMonthlyViewMoodTypeMood2:
            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-2"];
            break;
        case TapkuMonthlyViewMoodTypeMood3:
            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-3"];
            break;
        case TapkuMonthlyViewMoodTypeMood4:
            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-4"];
            break;
        case TapkuMonthlyViewMoodTypeMood5:
            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-5"];
            break;
//        case TapkuMonthlyViewMoodTypeMood6:
//            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-6"];
//            break;
//        case TapkuMonthlyViewMoodTypeMood7:
//            moodIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/mood-7"];
//            break;
        default:
            break;
    }
    
    return moodIcon;
}

- (UIImageView *)iconFertle
{
    if (iconFertle == nil) {
        CGRect r = self.selectedImageView.bounds;
        UIImage *calendarIcon = [UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/iconFertle"];
        CGRect menstratingImageFrame = CGRectMake(r.origin.x + 2 , r.origin.y + r.size.width/3 + 5, (r.size.width/2)- 3, r.size.width/4);
        iconFertle = [[UIImageView alloc] initWithFrame:r];
        iconFertle.contentMode = UIViewContentModeScaleAspectFill;
        iconFertle.image = calendarIcon;
        iconFertle.frame = menstratingImageFrame;
    }
    return iconFertle;
}

- (UIImageView *) selectedImageView{
	if(selectedImageView==nil){
		selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/bgCalendarTileSelected"]];
        //selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected"]];
	}
	return selectedImageView;
}

@end

#pragma mark -

@interface TKCalendarMonthView (private)

@property (readonly) UIScrollView *tileBox;
@property (readonly) UIImageView *topBackground;
@property (readonly) UILabel *monthYear;
@property (readonly) UIButton *leftArrow;
@property (readonly) UIButton *rightArrow;
@property (readonly) UIImageView *shadow;

@end

#pragma mark -
@implementation TKCalendarMonthView
@synthesize delegate,dataSource;
@synthesize selectionMode;


- (id) init{
	self = [self initWithSundayAsFirst:YES];
    selectionMode = NO;
	return self;
}
#pragma Mark - EDIT BACKGROUND TO MAKE CALENDAR CELL TRANSPARENT (2/2) AND TO CHANGE LABEL FOR THE DAY IN WEEK
- (id) initWithSundayAsFirst:(BOOL)s{
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
    //Edit BACKGROUND TO MAKE CALENDAR CELL TRANSPARENT (2/2)
    //self.backgroundColor = [UIColor grayColor];
	self.backgroundColor = [UIColor clearColor];
    
	sunday = s;
	
	
	
	currentTile = [[[TKCalendarMonthTiles alloc] initWithMonth:[[NSDate date] firstOfMonth] marks:nil startDayOnSunday:sunday mode:self.selectionMode] autorelease];
	[currentTile setTarget:self action:@selector(tile:)];
	
	[currentTile setTarget:self action:@selector(tile:)];
	CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
    
	
	self.frame = r;
	
	
	[currentTile retain];
	
	[self addSubview:self.topBackground];
	[self.tileBox addSubview:currentTile];
	[self addSubview:self.tileBox];
	
	NSDate *date = [NSDate date];
	self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString],[date yearString]];
	[self addSubview:self.monthYear];
	
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.shadow];
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
	
	
	TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	
	NSTimeZone *tz = [NSTimeZone systemTimeZone];
	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 6;
	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 7;
	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 8;
	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 9;
	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 10;
	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 11;
	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	[dateFormat release];
    
    
	
	NSArray *ar;
	if(sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
	else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
	
    //EDIT LABEL FOR DAYS IN WEEK
    /*
     int i = 0;
     for(NSString *s in ar){
     
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
     [self addSubview:label];
     label.text = s;
     label.textAlignment = UITextAlignmentCenter;
     label.shadowColor = [UIColor whiteColor];
     label.shadowOffset = CGSizeMake(0, 1);
     label.font = [UIFont systemFontOfSize:11];
     label.backgroundColor = [UIColor clearColor];
     label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
     
     i++;
     [label release];
     }
     */
    
    int i = 0;
	for(NSString *s in ar){
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i + 1, 29, 45, 15)];
		[self addSubview:label];
		label.text = s;
		label.textAlignment = UITextAlignmentCenter;
		label.font = [UIFont fontWithName:@"BankGothic Md BT" size:12];
		label.textColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:1];
        label.backgroundColor = [UIColor colorWithRed:0.0f/255 green:0.0f/255 blue:0.0f/255 alpha:0.7f];
        label.layer.cornerRadius = 4.0;
        label.layer.shadowOffset = CGSizeMake(0, -1);
        label.layer.shadowRadius = 0.4;
        label.layer.shadowColor = [UIColor blackColor].CGColor;
        label.layer.shadowOpacity = 0.6;
        
		i++;
		[label release];
	}
    
	return self;
}
- (void) dealloc {
	[shadow release];
	[topBackground release];
	[leftArrow release];
	[monthYear release];
	[rightArrow release];
	[tileBox release];
	[currentTile release];
    [super dealloc];
}


- (NSDate*) dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	return localNextMonth;
}
#pragma mark - change delegate to get event icon (1/3)
- (void) changeMonthAnimation:(UIView*)sender{
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    //EDIT get event array from delegate
    NSArray *eventArray = [dataSource calendarMonthView:self eventsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *fertlesArray = [dataSource calendarMonthView:self fertleFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *menstratingArray = [dataSource calendarMonthView:self menstratingFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *sensitiveArray = [dataSource calendarMonthView:self sensitiveFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *moodArray = [dataSource calendarMonthView:self moodFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:sunday mode:self.selectionMode];
    newTile.events = eventArray;
    newTile.fertles = fertlesArray;
    newTile.menstrating = menstratingArray;
    newTile.sensitive = sensitiveArray;
    newTile.moods = moodArray;
	[newTile setTarget:self action:@selector(tile:)];
	
	int overlap =  0;
	
	if(isNext){
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
	}else{
		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	newTile.alpha = 0;
	[self.tileBox addSubview:newTile];
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	newTile.alpha = 1;
    
	[UIView commitAnimations];
	
	
	
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.4];
	
	
	
	if(isNext){
		
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
		
	}else{
		
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
	}
	
	
	[UIView commitAnimations];
	
	oldTile = currentTile;
	currentTile = newTile;
	
	
	
	monthYear.text = [NSString stringWithFormat:@"%@ %@",[localNextMonth monthString],[localNextMonth yearString]];
	
	
    
}
- (void) changeMonth:(UIButton *)sender{
	
	NSDate *newDate = [self dateForMonthChange:sender];
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newDate animated:YES] ) 
		return;
	
	
	if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] ) 
		[delegate calendarMonthView:self monthWillChange:newDate animated:YES];
	
    
	
	
	[self changeMonthAnimation:sender];
	if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[delegate calendarMonthView:self monthDidChange:currentTile.monthDate animated:YES];
    
}
- (void) animationEnded{
	self.userInteractionEnabled = YES;
	[oldTile removeFromSuperview];
	[oldTile release];
	oldTile = nil;
}

- (NSDate*) dateSelected{
	return [currentTile dateSelected];
}
- (NSDate*) monthDate{
	return [currentTile monthDate];
}
#pragma mark - edit delegate to get event array (2/3)
- (void) selectDate:(NSDate*)date{
	TKDateInformation info = [date dateInformation];
	//TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDate *month = [date firstOfMonth];
	
	if([month isEqualToDate:[currentTile monthDate]]){
		[currentTile selectDay:info.day];
		return;
	}else {
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:month animated:YES] ) 
			return;
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
			[delegate calendarMonthView:self monthWillChange:month animated:YES];
		
		
		NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
		NSArray *data = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        //EDIT get event array from delegate
        NSArray *eventArray = [dataSource calendarMonthView:self eventsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *fertlesArray = [dataSource calendarMonthView:self fertleFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *menstratingArray = [dataSource calendarMonthView:self menstratingFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *sensitiveArray = [dataSource calendarMonthView:self sensitiveFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        NSArray *moodArray = [dataSource calendarMonthView:self moodFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
		TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month 
																			  marks:data 
																   startDayOnSunday:sunday mode:self.selectionMode];
        //Edit assign event array to calendar
        newTile.events = eventArray;
        newTile.fertles = fertlesArray;
        newTile.menstrating = menstratingArray;
        newTile.sensitive = sensitiveArray;
        newTile.moods = moodArray;
        
		[newTile setTarget:self action:@selector(tile:)];
		[currentTile removeFromSuperview];
		[currentTile release];
		currentTile = newTile;
		[self.tileBox addSubview:currentTile];
		self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
        
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString],[date yearString]];
		[currentTile selectDay:info.day];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:date animated:NO];
		
		
	}
}
#pragma mark - edit delegate to get event icon (3/3)
- (void) reload{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    //EDIT get event array
    NSArray *eventArray = [dataSource calendarMonthView:self eventsFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *fertlesArray = [dataSource calendarMonthView:self fertleFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *menstratingArray = [dataSource calendarMonthView:self menstratingFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	NSArray *sensitiveArray = [dataSource calendarMonthView:self sensitiveFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    NSArray *moodArray = [dataSource calendarMonthView:self moodFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    
	TKCalendarMonthTiles *refresh = [[[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] marks:ar startDayOnSunday:sunday mode:self.selectionMode] autorelease];
    //EDIT assign event array
    refresh.events = eventArray;
    refresh.fertles = fertlesArray;
    refresh.menstrating = menstratingArray;
    refresh.sensitive = sensitiveArray;
    refresh.moods = moodArray;
    
	[refresh setTarget:self action:@selector(tile:)];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	[currentTile release];
	currentTile = [refresh retain];
	
}

- (void) tile:(NSArray*)ar{
	
	if([ar count] < 2){
		
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[delegate calendarMonthView:self didSelectDate:[self dateSelected]];
        
	}else{
		
		int direction = [[ar lastObject] intValue];
		UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
		
		NSDate* newMonth = [self dateForMonthChange:b];
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
			return;
		
		if ([delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])					
			[delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
		
		
		
		[self changeMonthAnimation:b];
		
		int day = [[ar objectAtIndex:0] intValue];
        
        
		// thanks rafael
		TKDateInformation info = [[currentTile monthDate] dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
		info.day = day;
        
        NSDate *dateForMonth = [NSDate dateFromDateInformation:info  timeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; 
		[currentTile selectDay:day];
		
		
		if([delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[delegate calendarMonthView:self didSelectDate:dateForMonth];
		
		if([delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[delegate calendarMonthView:self monthDidChange:dateForMonth animated:YES];
        
		
	}
	
}

#pragma mark Properties
#pragma mark EDIT TOP BACKGROUND (TO TRANSPARENT)
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
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tileBox.frame.size.width, 28)];
		
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
        //EDIT font
        monthYear.font = [UIFont fontWithName:@"BankGothic Md BT" size:18];
        monthYear.textColor = [UIColor blackColor];
	}
	return monthYear;
}
#pragma mark - EDIT change calendar top left and right arrow
- (UIButton *) leftArrow{
	if(leftArrow==nil){
		leftArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		
		
		
        
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		
		//leftArrow.frame = CGRectMake(0, 0, 48, 38);
        //EDIT position
        leftArrow.frame = CGRectMake(73, 0, 48, 28);
	}
	return leftArrow;
}

- (UIButton *) rightArrow{
	if(rightArrow==nil){
		rightArrow = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		//rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
        //EDIT position
        rightArrow.frame = CGRectMake(320- 45 - 75, 0, 48, 28);
		
        
        
		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
		
	}
	return rightArrow;
}
- (UIScrollView *) tileBox{
	if(tileBox==nil){
		tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 320, currentTile.frame.size.height)];
	}
	return tileBox;
}
- (UIImageView *) shadow{
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}

@end