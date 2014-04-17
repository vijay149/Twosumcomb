//
// NSDate+Helper.h
//
// Created by Billy Gray on 2/26/09.
// Copyright (c) 2009, 2010, ZETETIC LLC
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


#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;

+ (NSDate *)fromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)string withStyle:(NSDateFormatterStyle)style;
+ (NSString *)stringFromDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+ (NSString *)stringFromDateTime:(NSDate *)date withStyle:(NSDateFormatterStyle)style;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;

- (NSString *)toString;
- (NSString *)toTimeString;
- (NSString *)toTimeOnlyString;
- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithStyle:(NSDateFormatterStyle)style ;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *) toLocalTime;
- (NSDate *) toGlobalTime;

- (NSInteger) numberOfDayUntilDate:(NSDate *)date;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)beginningAtMidnightOfDay;
- (NSDate *)endOfWeek;

- (NSDate *)dateByAddSecond:(NSInteger) seconds;
- (NSDate *)dateByAddMinute:(NSInteger) minutes;
- (NSDate *)dateByAddDays:(NSInteger) days;
- (NSDate *)dateByAddMonth:(NSInteger) months;
- (NSDate *) dateByAddingYears:(NSUInteger)years;
+ (NSDate *)lastDateOfMonth:(NSDate *) month;
+ (NSDate *)lastDateOfWeek:(NSDate *) week;
+(NSDate *)firstDateOfMonth:(NSDate *)month;
+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;
+ (NSDate*)parseDate:(NSString*)inStrDate format:(NSString*)inFormat;
- (NSDate *)dateOnly;

+ (NSDateComponents *) hourComponentsBetweenDate:(NSDate *)firstDate andDate:(NSDate *)endDate;
+ (NSInteger) dayBetweenDay:(NSDate *) firstDay andDay:(NSDate *)lastDay;
- (NSInteger) getMonth;
- (NSInteger) getDay;
- (NSInteger) getYear;
+ (NSInteger) dayUntilBirthDate:(NSDate *)birthDate;


/**
 *  Compare date time
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
- (BOOL) isAfterDate:(NSDate *)date;
- (BOOL) isBetweenDate:(NSDate *)start end:(NSDate *)end;
+ (NSString *)toStringWithOutSimiColon:(NSDate *)date;
+ (NSString *)toStringWithOutSimiColonWithOutTime:(NSDate *)date;
+ (BOOL) isAllDayEvent:(NSDate*) startDate withEndDate:(NSDate*) endDate;
- (BOOL) isSameDay:(NSDate*)anotherDate;
- (NSInteger) daysBetweenDate:(NSDate*)d;

-(BOOL) isLaterThanOrEqualTo:(NSDate*)date;
-(BOOL) isEarlierThanOrEqualTo:(NSDate*)date;
-(BOOL) isLaterThan:(NSDate*)date;
-(BOOL) isEarlierThan:(NSDate*)date;

@end
