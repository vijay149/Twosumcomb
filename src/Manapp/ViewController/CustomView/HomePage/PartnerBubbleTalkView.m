//
//  PartnerBubbleTalkView.m
//  Manapp
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "PartnerBubbleTalkView.h"
#import "MASession.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "UIView+Additions.h"
#import "UILabel+Additions.h"
#import "Event.h"
#import "NSDate+Helper.h"
#import "MoodHelper.h"
#import "Message.h"
#import "MANotificationManager.h"
#import "NSString+Additional.h"
#import "UILabel+ESAdjustableLabel.h"
#import "EventUtil.h"
#import "NSDate+Helper.h"
#import "SoLabel.h"
#import "NSArray+Additions.h"

#define CELL_CONTENT_WIDTH 175.0f
#define CELL_CONTENT_MARGIN 10.0f

static const NSString * MACalendarHints = @"Calendar Hints";
static const NSString * MAMoodBites = @"Mood Bites";
static const NSString * MAUsefulBits = @"Useful Bits";

@interface PartnerBubbleTalkView()
-(void) loadMoodMessageForCurrentPartner;
-(void) reloadEventsUI;
@end

@implementation PartnerBubbleTalkView

- (void)dealloc {
    [_messages release];
    [_events release];
    [_notifications release];
    [_partnerBubbleTalk release];
    [super dealloc];
}



#pragma mark - load functions
//reload the data of the bubble talk
-(void)reloadBubbleTalk{
    [self loadMoodMessageForCurrentPartner];
    [self reloadEventsUI];
}

//load the event list for the current partner
-(void) loadMoodMessageForCurrentPartner {
    Partner *currentPartner = [MASession sharedSession].currentPartner;
    if(currentPartner){
        if(currentPartner.lastMessageUpdate) {
            //MA_454
            /*
            //            int minute = [NSDate hourComponentsBetweenDate:currentPartner.lastMessageUpdate andDate:[NSDate date]].minute;
            int hours = [NSDate hourComponentsBetweenDate:currentPartner.lastMessageUpdate andDate:[NSDate date]].hour;//11
            if(hours > 11){
                //            if(minute > 4){
                [[DatabaseHelper sharedHelper] renewMessagesForPartner:currentPartner];
            }
            */
             [[DatabaseHelper sharedHelper] renewMessagesForPartner:currentPartner];
        }
        else{
            currentPartner.lastMessageUpdate = [NSDate date];
            [[DatabaseHelper sharedHelper] renewMessagesForPartner:currentPartner];
        }
        self.messages = [[DatabaseHelper sharedHelper] messagesForPartner:currentPartner];
        
        NSLog(@"-------Message: %@", self.messages);
        
        for(NSInteger i = 0; i < 7; i ++){
            NSDate* date = [[NSDate date] beginningOfDay];
            NSLog(@"beginningOfDay %@",date);
            NSLog(@"dateByAddDays %d : %@", i , [date dateByAddDays:i]);
            self.events = [[DatabaseHelper sharedHelper] getAllEventOccurAtDate:[date dateByAddDays:i] forPartner:currentPartner.partnerID.integerValue];
            if(self.events.count > 0){
                break;
            }
        }
        
        NSLog(@"-------Events: %@", self.events);
        
        self.tip = [[DatabaseHelper sharedHelper] getEventMessageForPartner:currentPartner];
        NSLog(@"-------Tips: %@", self.tip);
        
        //        //        NSArray *allEvents = [[DatabaseHelper sharedHelper] getAllEventForPartner:currentPartner.partnerID.integerValue];
        //        // change get all events to only events by current date and in future.
        ////        NSArray *allEvents = [[DatabaseHelper sharedHelper] getAllEventCurrentDateToFutureForPartner:currentPartner.partnerID.integerValue];
        ////        NSArray *arrNo = [[DatabaseHelper sharedHelper] getAllEventOccurAtDate:[NSDate date] forPartner:currentPartner.partnerID.integerValue];
        //        NSDate *startD = [[NSDate date] dateByAddDays:-1];
        //        NSDate *endD = [[NSDate date] dateByAddDays:1];
        //        NSArray *arrNo = [[DatabaseHelper sharedHelper] getAllListEventOccurFromDateForMonthView:startD toDate:endD forPartner:[[MASession sharedSession].currentPartner.partnerID intValue]];
        //        id obj = nil;
        //        if (arrNo.count > 0) {
        //            obj = [arrNo randomObject];
        //        }
        //        self.notifications = [NSMutableArray array];
        //        if (obj) {
        //            [self.notifications addObject:obj];
        //        }
        ////        for(Event *event in allEvents){
        ////            NSLog(@"date %@",[NSDate date]);
        ////            if([[MANotificationManager sharedInstance] isEvent:event haveNotificationAtDate:[NSDate date]]){
        ////                [self.notifications addObject:event];
        ////            }
        ////        }
        
        NSArray *allEvents = [[DatabaseHelper sharedHelper] getAllEventCurrentDateToFutureForPartner:currentPartner.partnerID.integerValue];
        for(Event *event in allEvents){
            NSLog(@"date %@",[NSDate date]);
            if([[MANotificationManager sharedInstance] isEvent:event haveNotificationAtDate:[NSDate date]]){
                [self.notifications addObject:event];
            }
        }
    }
}

#pragma mark - UIFunctions
-(void)reloadEventsUI{
    if(![[MASession sharedSession] currentPartner]){
        return;
    }
    self.partnerBubbleTalk = [[PartnerBubbleTalk alloc] init];
    CGFloat messageHeight = self.frame.size.height;
    //remove all the subview
    
    //name label (name say)
    CGFloat currentHeight = 0;
    
    CGFloat titleHeight = 0;
    UILabel *nameLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, 10)] autorelease];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    //    nameLabel.font = [UIFont boldSystemFontOfSize:10.5f];
    nameLabel.font = [UIFont fontWithName:kAppFont size:10];
    titleHeight = 10;
    currentHeight += titleHeight;
    
    if([[MASession sharedSession] currentPartner]){
        NSString *nameText = [NSString stringWithFormat:LSSTRING(@"%@ Says:"),[[MASession sharedSession] currentPartner].name];
        
        [nameLabel changeSizeToMatchText:nameText allowWidthChange:NO];
        nameLabel.text = nameText;
        nameLabel.font = [UIFont fontWithName:kAppFont size:10];
        [nameLabel setHeight:nameLabel.frame.size.height];
    }
    
    for(Event *event in self.events){
        if (event) {
            
            //change label text
            if (event.eventName && ![Util isNullOrNilObject:event.eventName] && [Util trimSpace:event.eventName].length > 0) {
                NSString *eventTime = [NSDate toStringWithOutSimiColon:event.eventTime];
                //                NSString *eventEndTime = [NSDate toStringWithOutSimiColon:event.eventEndTime];
                DLogInfo(@"event time: %@",eventTime);
                // future event.
                NSString *eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@ on %@", MACalendarHints ,event.eventName, eventTime];
                // today event
                if (event.eventTime && [[event.eventTime toString] isEqualToString:[[NSDate date] toString]]) {
                   eventTime = [NSString stringWithFormat:@"today %@",[event.eventTime toTimeOnlyString]];
                    eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@, %@", MACalendarHints ,event.eventName, eventTime];
                }
                // All day events
                if ([EventUtil isAllDayEvent2:event.eventTime withEndDate:event.finishTime]) {
                    eventTime = [NSDate toStringWithOutSimiColonWithOutTime:event.eventTime];
                    if (event.eventTime && [[event.eventTime toString] isEqualToString:[[NSDate date] toString]]) {// all day events  today
                        eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@, today", MACalendarHints ,event.eventName];
                    } else {
                        eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@ on %@", MACalendarHints ,event.eventName, event.eventTime.toString];
                    }
                    NSLog(@"---eventTime ToString: %@", [event.eventTime toString]);
                }
                if (event.type.intValue == MANAPP_EVENT_TYPE_BIRTHDAY) {
                    NSString *eventTime = [NSDate toStringWithOutSimiColonWithOutTime:event.eventTime];
                    eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@ on %@", MACalendarHints ,event.eventName, eventTime];
                }
                if (event.type.intValue == MANAPP_EVENT_TYPE_FIRSTMEET) {
                    NSString *eventTime = [NSDate toStringWithOutSimiColonWithOutTime:event.eventTime];
                    eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@ on %@", MACalendarHints ,event.eventName, eventTime];
                }

                CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                CGSize size = [eventItemText sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                SoLabel *label = [[SoLabel alloc]initWithFrame:CGRectMake(5, 5, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, MAX(size.height, 110))];
                
                label.text = eventItemText;
                [label setLineBreakMode:NSLineBreakByWordWrapping];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont fontWithName:kAppFont size:10];
                [label changeSizeToMatchText:eventItemText allowWidthChange:NO];
                [label setNumberOfLines:0];
                [label sizeToFit];
                
                DLogInfo(@"label.font.pointSize: %f",label.font.pointSize);
                DLogInfo(@"height bound %f",label.bounds.size.height);
                [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%f",MAX(size.height, 110.0f)]];
                [self.partnerBubbleTalk.arrayLabelBubbleTalk addObject:label];
                [self.partnerBubbleTalk.arrayIsLastBubbleTalk addObject:[NSNumber numberWithBool:NO]];
                currentHeight += messageHeight;
            }
            
        }
    }
    
    for(Event *event in self.notifications){
        if (event) {
            
            
            //change label text
            if (event.eventName && ![Util isNullOrNilObject:event.eventName] && [Util trimSpace:event.eventName].length > 0) {
                NSString *eventItemText = nil;
                if ([EventUtil isAllDayEvent2:event.eventTime withEndDate:event.finishTime]){
                    eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@", MACalendarHints,event.eventName];
                }else{
                    eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@", MACalendarHints,event.eventName];
                }
                
                
                NSLog(@"EVENT NOTIFICATION:EVENT TEXT: %@", eventItemText);
                CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                CGSize size = [eventItemText sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                SoLabel *label = [[SoLabel alloc]initWithFrame:CGRectMake(5, 5, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, MAX(size.height, 110))];
                
                label.text = eventItemText;
                [label setLineBreakMode:NSLineBreakByWordWrapping];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont fontWithName:kAppFont size:10];
                [label changeSizeToMatchText:eventItemText allowWidthChange:NO];
                [label setNumberOfLines:0];
                [label sizeToFit];
                
                DLogInfo(@"label.font.pointSize: %f",label.font.pointSize);
                DLogInfo(@"height bound %f",label.bounds.size.height);
                [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%f",MAX(size.height, 110.0f)]];
                
                [self.partnerBubbleTalk.arrayLabelBubbleTalk addObject:label];
                [self.partnerBubbleTalk.arrayIsLastBubbleTalk addObject:[NSNumber numberWithBool:NO]];
                currentHeight += messageHeight;
            }
            
        }
    }
    
    if(self.tip){
        
        //change label text
        NSString *contentForMessage = [[DatabaseHelper sharedHelper] getContentForMessage:self.tip partner:[MASession sharedSession].currentPartner];
        if (contentForMessage && ![Util isNullOrNilObject:contentForMessage] && [Util trimSpace:contentForMessage].length > 0) {
            NSString *eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@", MAUsefulBits ,contentForMessage];
            CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
            CGSize size = [eventItemText sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            SoLabel *label = [[SoLabel alloc]initWithFrame:CGRectMake(5, 5, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, MAX(size.height, 110))];
            
            
            NSLog(@"EVENT TIP:EVENT TEXT: %@", eventItemText);
            
            label.text = eventItemText;
            [label setLineBreakMode:NSLineBreakByWordWrapping];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:kAppFont size:10];
            [label changeSizeToMatchText:eventItemText allowWidthChange:NO];
            [label setNumberOfLines:0];
            [label sizeToFit];
            
            [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%f",MAX(size.height, 110)]];
            [self.partnerBubbleTalk.arrayLabelBubbleTalk addObject:label];
            [self.partnerBubbleTalk.arrayIsLastBubbleTalk addObject:[NSNumber numberWithBool:NO]];
            currentHeight += messageHeight;
        }
        
    }
    for(Message *message in self.messages){
        if (![Util isNullOrNilObject:message]) {
            
            //change label text
            
            NSString *contentForMessage = nil;
            if (message.sex.intValue == [MASession sharedSession].currentPartner.sex.intValue) {
                contentForMessage = [[DatabaseHelper sharedHelper] getContentForMessage:message partner:[MASession sharedSession].currentPartner];
                if (contentForMessage && ![Util isNullOrNilObject:contentForMessage] && [Util trimSpace:contentForMessage].length > 0) {
                    NSString *eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@", MAUsefulBits, contentForMessage];
                    if ([message.type isEqualToString:MANAPP_MESSAGE_TYPE_MOOD] || [message.type isEqualToString:MANAPP_MESSAGE_TYPE_MOOD_FUTURE]) {
                        eventItemText = [NSString stringWithFormat:@"%@:\r\n\n%@", MAMoodBites, contentForMessage];
                        DLogInfo(@"is moodddddddddddddd");
                    }
                    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
                    CGSize size = [eventItemText sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                    SoLabel *label = [[SoLabel alloc]initWithFrame:CGRectMake(5, 5, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, MAX(size.height, 110))];
                    
                    NSLog(@"EVENT MESSAGE:EVENT TEXT: %@", eventItemText);
                    
                    label.text = eventItemText;
                    [label setLineBreakMode:NSLineBreakByWordWrapping];
                    label.backgroundColor = [UIColor clearColor];
                    label.textColor = [UIColor whiteColor];
                    label.font = [UIFont fontWithName:kAppFont size:10];
                    [label changeSizeToMatchText:eventItemText allowWidthChange:NO];
                    
                    NSLog(@"lbl eventItem %@",eventItemText);
                    NSLog(@"height label %f",label.frame.size.height);
                    [label setNumberOfLines:0];
                    [label sizeToFit];
                    //                [label setFrame:CGRectMake(5, 10, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, MAX(size.height, 44.0f))];
                    
                    [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%f",MAX(size.height, 110)]];
                    
                    //                [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%f",MAX(size.height, 44.0f)]];
                    [self.partnerBubbleTalk.arrayLabelBubbleTalk addObject:label];
                    [self.partnerBubbleTalk.arrayIsLastBubbleTalk addObject:[NSNumber numberWithBool:NO]];
                    currentHeight += messageHeight;
                }
                
            }
        }
        
    }
    
    // Last item using scroll around
    /**
     *  <#Description#>
     *
     *  @param 5             <#5 description#>
     *  @param currentHeight <#currentHeight description#>
     *  @param 5             <#5 description#>
     *  @param 0             <#0 description#>
     *
     *  @return <#return value description#>
     */
    //    SoLabel *label = [[SoLabel alloc] initWithFrame:CGRectMake(5, currentHeight, MANAPP_PARTNER_BUBBLE_TALK_WIDTH - 5, 0)];
    //    label.backgroundColor = [UIColor clearColor];
    //    label.textColor = [UIColor whiteColor];
    //    label.font = [UIFont systemFontOfSize:12];
    //    label.tag = kIsLastItem;
    //    [label setNumberOfLines:0];
    //    [label sizeToFit];
    //
    //    [self.partnerBubbleTalk.arrayHeightBubbleTalk addObject:[NSString stringWithFormat:@"%d",kIsLastItem]];
    //    [self.partnerBubbleTalk.arrayLabelBubbleTalk addObject:label];
    //    [self.partnerBubbleTalk.arrayIsLastBubbleTalk addObject:[NSNumber numberWithBool:YES]];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)layoutSubviews{
    [super layoutSubviews];
}

@end
