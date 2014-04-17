//
//  EventUtil.m
//  TwoSum
//
//  Created by Duong Van Dinh on 10/17/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "EventUtil.h"
#import "NSDate+Helper.h"


#define TIMEZONE [NSTimeZone systemTimeZone]
@implementation EventUtil

+ (EventUtil *)sharedUtil {
    static EventUtil *_sharedUtil = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtil = [[EventUtil alloc] init];
    });
    
    return _sharedUtil;
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

+ (BOOL) isAllDayEvent2:(NSDate*) startDate withEndDate:(NSDate*) endDate {
    BOOL isAllDayEvent = NO;
    NSDateComponents *dateComponents = [NSDate hourComponentsBetweenDate:startDate andDate:endDate];
    NSLog(@"hour %d",dateComponents.hour);
    NSLog(@"minute %d",dateComponents.minute);
    int kDate =  dateComponents.hour % 24;
    if((kDate == 0 || dateComponents.hour == 24) || (dateComponents.hour == 23 && dateComponents.minute >= 57)){
        isAllDayEvent = YES;
    }
    return isAllDayEvent;
}



#pragma mark - UTil Date

//-(NSDate*)lastDayOfMonth
//{
//    NSInteger dayCount = [self numberOfDaysInMonthCount];
//    
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    
//    NSDateComponents *comp = [calendar components:
//                              NSYearCalendarUnit |
//                              NSMonthCalendarUnit |
//                              NSDayCalendarUnit fromDate:[NSDate date]];
//    
//    [comp setDay:dayCount];
//    
//    return [calendar dateFromComponents:comp];
//}
//
//-(NSInteger)numberOfDaysInMonthCount
//{
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:TIMEZONE]];
//    
//    NSRange dayRange = [calendar rangeOfUnit:NSDayCalendarUnit
//                                      inUnit:NSMonthCalendarUnit
//                                     forDate:[NSDate date]];
//    
//    return dayRange.length;
//}
@end
