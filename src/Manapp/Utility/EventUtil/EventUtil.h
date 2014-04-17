//
//  EventUtil.h
//  TwoSum
//
//  Created by Duong Van Dinh on 10/17/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventUtil : NSObject
+ (EventUtil *) sharedUtil;
+ (BOOL) isAllDayEvent:(NSDate*) startDate withEndDate:(NSDate*) endDate;
+ (BOOL) isAllDayEvent2:(NSDate*) startDate withEndDate:(NSDate*) endDate;
@end
