//
//  Event.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventID;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSDate * eventTime;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * recurrence;
@property (nonatomic, retain) NSString * recurringID;
@property (nonatomic, retain) NSString * reminder;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) Partner *partner;

@end
