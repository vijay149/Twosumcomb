//
// NSDate+Helper.h
//
// Created by Billy Gray on 2/26/09.
// Copyright (c) 2009–2012, ZETETIC LLC
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the ZETETIC LLC nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY ZETETIC LLC ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL ZETETIC LLC BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDate+Helper.h"
//Date time type
#define MANAPP_DATETIME_DEFAULT_TYPE NSDateFormatterMediumStyle
#define MANAPP_DATETIME_TIME_DEFAULT_TYPE NSDateFormatterMediumStyle
#define MANAPP_TIME_DEFAULT_TYPE NSDateFormatterShortStyle
@implementation NSDate (Helper)

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit) 
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	[mdf release];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;
		case 1:
			text = @"Yesterday";
			break;
		default:
			text = [NSString stringWithFormat:@"%d days ago", daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSDate *)fromString:(NSString *)string{
    return [NSDate dateFromString:string withStyle:MANAPP_DATETIME_DEFAULT_TYPE];
}

+ (NSDate *)dateFromString:(NSString *)string {
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	[inputFormatter release];
	return date;
}

+ (NSDate *)dateFromString:(NSString *)string withStyle:(NSDateFormatterStyle)style {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateStyle:style];
	NSDate *date = [inputFormatter dateFromString:string];
	[inputFormatter release];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style {
	return [date stringWithStyle:style];
}

+ (NSString *)stringFromDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style {
	return [date stringWithDateTimeStyle:style];
}

+ (NSString *)stringFromTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style {
    return [date stringWithTimeOnlyStyle:style];
}


+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
    /* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    
	NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
													 fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	NSString *displayString = nil;
	
	// comparing against midnight
    NSComparisonResult midnight_result = [date compare:midnight];
	if (midnight_result == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		[componentsToSubtract release];
        NSComparisonResult lastweek_result = [date compare:lastweek];
		if (lastweek_result == NSOrderedDescending) {
            if (displayTime) {
                [displayFormatter setDateFormat:@"EEEE h:mm a"];
            } else {
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
            }
		} else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];
			
			NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
														   fromDate:date];
			NSInteger thatYear = [dateComponents year];			
			if (thatYear >= thisYear) {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d"];
                }
			} else {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d, yyyy"];
                }
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
    
    [displayFormatter release];
    
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return timestamp_str;
}

- (NSString *)stringWithStyle:(NSDateFormatterStyle)style {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:style];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return timestamp_str;
}

- (NSString *)stringWithDateTimeStyle:(NSDateFormatterStyle)style{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:style];
    [outputFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return timestamp_str;
}

- (NSString *)stringWithTimeOnlyStyle:(NSDateFormatterStyle)style{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setTimeStyle:style];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return timestamp_str;
}

-(NSString *)toString{
    return [NSDate stringFromDate:self withStyle:MANAPP_DATETIME_DEFAULT_TYPE];
}

-(NSString *)toTimeString{
    return [NSDate stringFromDateTime:self withStyle:MANAPP_DATETIME_DEFAULT_TYPE];
}

-(NSString *)toTimeOnlyString{
    return [NSDate stringFromTime:self withStyle:MANAPP_TIME_DEFAULT_TYPE];
}

- (NSString *)string {
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return outputString;
}

//negative value if the date is before the current date
- (NSInteger) numberOfDayUntilDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
	NSDateComponents *components = [calendar components:NSDayCalendarUnit
                                                        fromDate:self
                                                          toDate:date
                                                         options:0];
    return components.day;
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
						   interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	} 
	
	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	[componentsToSubtract release];
	
	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)toLocalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSDate *)toGlobalTime
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

- (NSDate*) beginningAtMidnightOfDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])]; //7-> 8
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
	[componentsToAdd release];
	
	return endOfWeek;
}

+ (NSString *)dateFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {	
	return [NSDate timestampFormatString];
}
+ (NSDate*)parseDate:(NSString*)inStrDate format:(NSString*)inFormat {
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setLocale:[NSLocale systemLocale]];
    [dtFormatter setDateFormat:inFormat];
    NSDate* dateOutput = [dtFormatter dateFromString:inStrDate];
    [dtFormatter release];
    return dateOutput;
}

- (NSDate *)dateOnly
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:self];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

- (NSDate *)dateByAddSecond:(NSInteger) seconds{
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[[NSDateComponents alloc]init]autorelease];
    dayComponent.second = seconds;
    return [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)dateByAddMinute:(NSInteger) minutes{
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[[NSDateComponents alloc]init]autorelease];
    dayComponent.minute = minutes;
    return [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)dateByAddDays:(NSInteger) days{
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *dayComponent = [[[NSDateComponents alloc]init]autorelease];
    dayComponent.day = days;
    return [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
}

- (NSDate *)dateByAddMonth:(NSInteger) months{
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDateComponents *monthComponent = [[[NSDateComponents alloc]init]autorelease];
    monthComponent.month = months;
    return [theCalendar dateByAddingComponents:monthComponent toDate:self options:0];
}

- (NSDate *) dateByAddingYears:(NSUInteger)years{
    NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];
	c.year = years;
	return [[NSCalendar currentCalendar] dateByAddingComponents:c toDate:self options:0];
}

+(NSDate *)lastDateOfMonth:(NSDate *)month{
    NSDate *nextMonth = [month dateByAddMonth:1];
    return [nextMonth dateByAddDays:-1];
}

+(NSDate *)firstDateOfMonth:(NSDate *)month {
    NSDate *previousMonth = [month dateByAddMonth:-1];
    return [previousMonth dateByAddDays:1];
}

+ (NSDate *)lastDateOfWeek:(NSDate *) week{
    return [week dateByAddDays:7];
}

+ (NSDateComponents *)hourComponentsBetweenDate:(NSDate *)firstDate andDate:(NSDate *)endDate{
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit| NSSecondCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:unitFlags
                                                        fromDate:firstDate
                                                          toDate:endDate
                                                         options:0];
    return components;
}

+(NSInteger) dayBetweenDay:(NSDate *) firstDay andDay:(NSDate *)lastDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
	NSDateComponents *components = [calendar components:NSDayCalendarUnit
                                               fromDate:firstDay
                                                 toDate:lastDay
                                                options:0];
    return components.day;
}

- (NSInteger) getMonth{
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit| NSYearCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:unitFlags fromDate:self];
    return components.month;
}

- (NSInteger) getDay{
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit| NSYearCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:unitFlags fromDate:self];
    return components.day;
}

- (NSInteger) getYear{
    NSCalendar *gregorianCalendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit| NSYearCalendarUnit;
    NSDateComponents *components = [gregorianCalendar components:unitFlags fromDate:self];
    return components.year;
}

+ (NSInteger) dayUntilBirthDate:(NSDate *)birthDate{
    
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    
    NSDateComponents *thisYearComponents = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
    NSDateComponents *birthDayComponents = [calendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:birthDate];
    [birthDayComponents setYear:[thisYearComponents year]];
    
    NSDate *birthDayThisYear = [calendar dateFromComponents:birthDayComponents];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:[NSDate date] toDate:birthDayThisYear options:0];
    if ([difference day] > 0) {
        // this years birthday is already over. calculate distance to next years birthday
        [birthDayComponents setYear:[thisYearComponents year]+1];
        birthDayThisYear = [calendar dateFromComponents:birthDayComponents];
        difference = [calendar components:NSDayCalendarUnit fromDate:[NSDate date] toDate:birthDayThisYear options:0];
    }
    
    
    return [difference day];
}

#pragma mark - compare datetime

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedAscending);
}

-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date {
    return !([self compare:date] == NSOrderedDescending);
}
-(BOOL) isLaterThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedDescending);
    
}
-(BOOL) isEarlierThan:(NSDate*)date {
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL) isAfterDate:(NSDate *)date{
    if ([self compare:date] == NSOrderedDescending){
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL) isBetweenDate:(NSDate *)start end:(NSDate *)end{
    if([self isAfterDate:start] && [end isAfterDate:self]){
        return YES;
    }
    return NO;
}

+ (NSString *)toStringWithOutSimiColon:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MMMM dd yyyy HH:mm a"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return  formattedDateString;
}

+ (NSString *)toStringWithOutSimiColonWithOutTime:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"MMMM dd yyyy"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return  formattedDateString;
}

+ (BOOL) isAllDayEvent:(NSDate*) startDate withEndDate:(NSDate*) endDate {
    BOOL isAllDayEvent = NO;
    NSDateComponents *dateComponents = [NSDate hourComponentsBetweenDate:startDate andDate:endDate];
    NSLog(@"hour %d",dateComponents.hour);
    NSLog(@"minute %d",dateComponents.minute);
    if((dateComponents.hour == 24) || (dateComponents.hour == 23 && dateComponents.minute >= 57)){
        isAllDayEvent = YES;
    }
    return isAllDayEvent;
}

- (BOOL) isSameDay:(NSDate*)anotherDate{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

- (NSInteger) daysBetweenDate:(NSDate*)d{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *  startDate = [self dateOnly];
    NSDate * endDate = [d dateOnly];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    startDate = [formatter dateFromString:[startDate stringWithFormat:@"yyyy-MM-dd"]];
    endDate = [formatter dateFromString:[endDate stringWithFormat:@"yyyy-MM-dd"]];

    NSInteger startDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                           inUnit: NSEraCalendarUnit forDate:startDate];
    NSInteger endDay=[calendar ordinalityOfUnit:NSDayCalendarUnit
                                         inUnit: NSEraCalendarUnit forDate:endDate];
    return abs(endDay-startDay);
}




@end
