//
//  MANotificationManager.m
//  Manapp
//
//  Created by Demigod on 08/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MANotificationManager.h"
#import "Event.h"
#import "NSDate+Helper.h"
#import "PartnerMood.h"
#import "DatabaseHelper.h"
#import "Global.h"
@implementation MANotificationManager
+(id)sharedInstance{
    static MANotificationManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MANotificationManager alloc] init];
    });
    
    return instance;
}

#pragma mark - LOCAL NOTIFICATION

#pragma mark - notification functions

#pragma mark - mood notification
//set the notification for mood
-(void) setNotificationForMood:(PartnerMood *)mood forPartner:(Partner *)partner{
    if(!partner){
        DLog(@"No partner was selected, cannot create notification");
        return;
    }
    
    //first, if there isn't any notifications for mood, add new notification for each 3 days
    NSArray *notifications = [self getAllNotificationsForPartner:partner];
    if(notifications.count > 0){
        //no need to to anythink if there is already notification
    }
    else{
        //only do this 9 times since the first time don't need notification
        for(NSInteger i=1; i<= 10; i++){
            //set the event to the notification
            NSDate *notificationTime = [mood.addedTime dateByAddDays:(i * MA_MOOD_CYCLE_STEP)];
            
            //Change push time to 8 PM
            NSCalendar *theCalendar = [NSCalendar currentCalendar];
            NSDateComponents *dayComponent = [[[NSDateComponents alloc]init]autorelease];
            dayComponent.day = i * MA_MOOD_CYCLE_STEP;
            dayComponent.hour = 20;
            notificationTime = [theCalendar dateByAddingComponents:dayComponent toDate:[mood.addedTime beginningOfDay] options:0];
            
            if([notificationTime compare:[NSDate date]] == NSOrderedAscending){
                continue;
            }
            NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:mood.moodID,kNotificationMoodId,[NSNumber numberWithInt:MANotificationTypeMoodInput], kNotificationType, nil];
            
            NSString *notificationBody = [NSString stringWithFormat:@"It is time to set %@'s mood!",partner.name];
            [self setNotificationAtTime:notificationTime body:LSSTRING(notificationBody) action:kAppName data:infoDict];
        }
    }
    
}

//handler when receive mood notification
-(void) moodNotificationHandler:(UILocalNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *notificationType=[userInfo valueForKey:kNotificationType];
    if (notificationType.intValue == MANotificationTypeMoodInput)
    {
        NSString *moodId = [userInfo valueForKey:kNotificationMoodId];
        PartnerMood *mood = [[DatabaseHelper sharedHelper] partnerMoodWithId:moodId];
        if(mood){
            [Util showMessage:[NSString stringWithFormat:@"It is time to set %@'s mood",mood.partner.name] withTitle:kAppName];
        }
    }
}

#pragma mark - event notification
-(void) setNotificationForEvent:(Event *) event{
    //date when the notification will be fired
    if(!event.reminder || [event.reminder isEqualToString:@""]){
        return;
    }
    
    NSInteger reminderSecond = 0;
    if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_NONE]){
        return;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_AT_EVENT]){
        reminderSecond = 0;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_15_MINUTES]){
        reminderSecond = 15 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_30_MINUTES]){
        reminderSecond = 30 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_HOUR]){
        reminderSecond = 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_HOUR]){
        reminderSecond = 2 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_4_HOUR]){
        reminderSecond = 4 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_DAY]){
        reminderSecond = 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_DAY]){
        reminderSecond = 2 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_WEEK]){
        reminderSecond = 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_WEEK]){
        reminderSecond = 2 * 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_MONTH]){
        reminderSecond = 30 * 24 * 60 * 60;
    }
    
    //set the event to the notification
    NSDate *notificationTime = [event.eventTime dateByAddSecond:(reminderSecond)];
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:event.eventName,kNotificationEventName,event.eventTime,kNotificationEventTime,[NSNumber numberWithInt:MANotificationTypeEventReminder],kNotificationType, nil];
    
    [self setNotificationAtTime:notificationTime body:event.eventName action:@"See detail" data:infoDict withEvent:event];
    
//    //set the repeat
//    NSDate *nextDate = event.eventTime;
//    
////    while([event.eventEndTime isAfterDate:nextDate]){
//        NSString *strReacur = event.recurrence;
//        if ([strReacur isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
////            nextDate = [nextDate dateByAddDays:1];
//            notificationTime = NSDayCalendarUnit;
//            
//        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]){
//            nextDate = [nextDate dateByAddDays:7];
////            notificationTime = NSWeekdayCalendarUnit;
//        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]){
////            nextDate = [nextDate dateByAddMonth:1];
//            notificationTime = NSMonthCalendarUnit;
//        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]){
//            nextDate = [nextDate dateByAddingYears:1];
////            notificationTime = NSYearCalendarUnit;
//        }
//        else{
////            break;
//        }
//        
////        if([event.eventEndTime isAfterDate:nextDate]){
////            notificationTime = [nextDate dateByAddSecond:reminderSecond];
//            [self setNotificationAtTime:notificationTime body:event.eventName action:@"See detail" data:infoDict];
////        }
////    }
}

-(BOOL) isEvent: (Event *)event haveNotificationAtDate:(NSDate *)date{
    //date when the notification will be fired
    if(!event.reminder || [event.reminder isEqualToString:@""]){
        return NO;
    }
    
    NSInteger reminderSecond = 0;
    if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_NONE]){
        return NO;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_AT_EVENT]){
        reminderSecond = 0;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_15_MINUTES]){
        reminderSecond = 15 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_30_MINUTES]){
        reminderSecond = 30 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_HOUR]){
        reminderSecond = 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_HOUR]){
        reminderSecond = 2 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_4_HOUR]){
        reminderSecond = 4 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_DAY]){
        reminderSecond = 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_DAY]){
        reminderSecond = 2 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_WEEK]){
        reminderSecond = 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_WEEK]){
        reminderSecond = 2 * 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_MONTH]){
        reminderSecond = 30 * 24 * 60 * 60;
    }
    
    //set the event to the notification
    NSDate *notificationTime = [event.eventTime dateByAddSecond:(reminderSecond)];
    
    NSDate *startDate = [notificationTime beginningOfDay];
    NSDate *endDate = [startDate dateByAddDays:1];
    endDate = [endDate dateByAddSecond:-1];
    if([date isBetweenDate:startDate end:endDate]){
        return YES;
    }
    
    //set the repeat
    NSDate *nextDate = event.eventTime;
    while([event.eventEndTime isAfterDate:nextDate]){
        NSString *strReacur = event.recurrence;
        if ([strReacur isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
            nextDate = [nextDate dateByAddDays:1];
        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]){
            nextDate = [nextDate dateByAddDays:7];
        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]){
            nextDate = [nextDate dateByAddMonth:1];
        }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]){
            nextDate = [nextDate dateByAddingYears:1];
        }
        else{
            break;
        }
        
        if([event.eventEndTime isAfterDate:nextDate]){
            notificationTime = [nextDate dateByAddSecond:(reminderSecond)];
            startDate = [notificationTime beginningOfDay];
            endDate = [startDate dateByAddDays:1];
            if([date isBetweenDate:startDate end:endDate]){
                return YES;
            }
        }
    }
    
    return NO;
}

//handler when receive event notification
-(void) eventNotificationHandler:(UILocalNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *notificationType=[userInfo valueForKey:kNotificationType];
    if (notificationType.intValue == MANotificationTypeEventReminder)
    {
        NSString *event = [userInfo valueForKey:kNotificationEventName];
        if(event){
//            [Util showMessage:event withTitle:kAppName];
        }
    }
}

-(void) setNotificationAtTime:(NSDate *) time body:(NSString *) body action:(NSString *)action data:(NSDictionary *) data{
    UILocalNotification *localNotif = [[[UILocalNotification alloc] init] autorelease];
    if (localNotif == nil){
        return;
    }
    localNotif.fireDate = time;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = body;
    // Set the action button
    localNotif.alertAction = action;
    
    // COMMENT: display the notification badge number on the icon
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    
    // Specify custom data for the notification
    localNotif.userInfo = data;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void) setNotificationAtTime:(NSDate *) time body:(NSString *) body action:(NSString *)action data:(NSDictionary *) data withEvent:(Event *)event{
    UILocalNotification *localNotif = [[[UILocalNotification alloc] init] autorelease];
    if (localNotif == nil){
        return;
    }
    localNotif.fireDate = time;
    NSString *strReacur = event.recurrence;
    if ([strReacur isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
        localNotif.repeatInterval = NSDayCalendarUnit;
    }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]){
        localNotif.repeatInterval = NSWeekdayCalendarUnit;
    }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]){
        localNotif.repeatInterval = NSMonthCalendarUnit;
    }else if([strReacur isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]){
        localNotif.repeatInterval = NSYearCalendarUnit;
    }

    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    // Notification details
    localNotif.alertBody = body;
    // Set the action button
    localNotif.alertAction = action;
    
    // COMMENT: display the notification badge number on the icon
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 0;
    
    // Specify custom data for the notification
    localNotif.userInfo = data;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
#pragma mark - get
-(NSArray *) getAllNotificationsByType:(MANotificationType) type{
    NSMutableArray *notifications = [NSMutableArray array];
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *allNotifications = [app scheduledLocalNotifications];
    for (int i=0; i<[allNotifications count]; i++)
    {
        UILocalNotification* oneNotification = [allNotifications objectAtIndex:i];
        NSDictionary *userInfo = oneNotification.userInfo;
        NSNumber *notificationType=[userInfo valueForKey:kNotificationType];
        if (notificationType.intValue == type)
        {
            [notifications addObject:oneNotification];
        }
    }
    
    return notifications;
}

-(NSArray *) getAllNotificationsForPartner:(Partner *)partner{
    NSMutableArray *notifications = [NSMutableArray array];
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *allNotifications = [app scheduledLocalNotifications];
    for (int i=0; i<[allNotifications count]; i++)
    {
        UILocalNotification* oneNotification = [allNotifications objectAtIndex:i];
        NSDictionary *userInfo = oneNotification.userInfo;
        NSNumber *notificationType=[userInfo valueForKey:kNotificationType];
        if (notificationType.intValue == MANotificationTypeMoodInput)
        {
            NSString *moodId = [userInfo valueForKey:kNotificationMoodId];
            PartnerMood *mood = [[DatabaseHelper sharedHelper] partnerMoodWithId:moodId];
            if(mood){
                if([mood.partner isEqual:partner]){
                    [notifications addObject:oneNotification];
                }
            }
        }
    }
    
    return notifications;
}

-(UILocalNotification *) getMoodNotificationOfPartner:(Partner *)partner atDate:(NSDate *)date{
    NSArray *moodNotifications = [self getAllNotificationsByType:MANotificationTypeMoodInput];
    for(UILocalNotification *notification in moodNotifications){
        NSDate *startDate = [notification.fireDate beginningAtMidnightOfDay];
        NSDate *endDate = [startDate dateByAddDays:1];
        endDate = [endDate dateByAddSecond:-1];
        startDate = [startDate dateByAddSecond:-1];
        if([date isBetweenDate:startDate end:endDate]){
            return notification;
        }
    }
    
    return nil;
}

#pragma mark - remove
//remove all notifications (local)
-(void)removeAllNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void) removeAllNotificationWithType:(MANotificationType) type{
    NSArray *notifications = [self getAllNotificationsByType:type];
    for(UILocalNotification *notification in notifications){
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

-(void) removeAllMoodNotificationForPartner:(Partner *)partner{
    NSArray *notifications = [self getAllNotificationsForPartner:partner];
    for(UILocalNotification *notification in notifications){
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

-(void) removeMoodNotificationOfPartner:(Partner *)partner atDate:(NSDate *)date{
    UILocalNotification *notification = [self getMoodNotificationOfPartner:partner atDate:date];
    if(notification){
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}



@end
