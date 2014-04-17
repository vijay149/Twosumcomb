//
//  Event.h
//  TwoSum
//
//  Created by Duong Van Dinh on 1/2/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * eventEndTime;
@property (nonatomic, retain) NSDate *finishTime;
@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSDate * eventTime;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * recurrence;
@property (nonatomic, retain) NSString * recurringID;
@property (nonatomic, retain) NSString * reminder;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSDate * eventOccurTime;
@property (nonatomic, retain) Partner *partner;

@end
