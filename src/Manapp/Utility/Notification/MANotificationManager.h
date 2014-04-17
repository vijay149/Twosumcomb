//
//  MANotificationManager.h
//  Manapp
//
//  Created by Demigod on 08/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MACommon.h"
#import "Partner.h"

@class Event;
@class PartnerMood;
@class Partner;

#define kNotificationType @"type"

#define kNotificationMoodId @"moodId"

#define kNotificationEventName @"eventName"
#define kNotificationEventTime @"eventTime"

#define kNotificationObject @"object"

typedef enum {
    MANotificationTypeEventReminder          = 0,
    MANotificationTypeMoodInput              = 1,
} MANotificationType;

@interface MANotificationManager : NSObject
+(id) sharedInstance;

-(void) setNotificationForEvent:(Event *) event;
-(BOOL) isEvent: (Event *)event haveNotificationAtDate:(NSDate *)date;
-(void) eventNotificationHandler:(UILocalNotification *)notification;

-(void) setNotificationForMood:(PartnerMood *)mood forPartner:(Partner *)partner;
-(void) moodNotificationHandler:(UILocalNotification *)notification;

-(NSArray *) getAllNotificationsByType:(MANotificationType) type;
-(NSArray *) getAllNotificationsForPartner:(Partner *)partner;

-(UILocalNotification *) getMoodNotificationOfPartner:(Partner *)partner atDate:(NSDate *)date;

-(void) removeAllNotification;
-(void) removeAllNotificationWithType:(MANotificationType) type;
-(void) removeAllMoodNotificationForPartner:(Partner *)partner;
-(void) removeMoodNotificationOfPartner:(Partner *)partner atDate:(NSDate *)date;
@end
