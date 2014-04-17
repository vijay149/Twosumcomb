//
//  EventsView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "EventsView.h"
#import "UIView+Additions.h"
#import "EventItemView.h"
#import "Event.h"
#import "NSDate+Helper.h"
#import "NSArray+MACalendar.h"
#import "MASession.h"
#import "Partner.h"
#import "Util.h"
#import "EventUtil.h"



@interface EventsView()

-(NSInteger) getEventOffSetByIndex:(NSInteger) index;
@end

@implementation EventsView
@synthesize viewFertle = _viewFertle;
@synthesize viewMenstrating = _viewMenstrating;
@synthesize viewCalendar = _viewCalendar;
@synthesize lblFertle = _lblFertle;
@synthesize lblMenstrating = _lblMenstrating;
@synthesize lblCalendar = _lblCalendar;
@synthesize scrollViewEvents = _scrollViewEvents;
@synthesize btnAddEvent = _btnAddEvent;
@synthesize btnMenstration = _btnMenstration;
@synthesize btnRemoveEvent = _btnRemoveEvent;
@synthesize delegate;

- (void)dealloc {
    self.delegate = nil;
    [_viewFertle release];
    [_viewMenstrating release];
    [_viewCalendar release];
    [_lblFertle release];
    [_lblMenstrating release];
    [_lblCalendar release];
    [_scrollViewEvents release];
    [_btnAddEvent release];
    [_btnMenstration release];
    [_btnRemoveEvent release];
    [_events release];
    [_lblDateSelected release];
    [_lblYouGotNothing release];
    [super dealloc];
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
    [self.lblCalendar setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.lblFertle setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.lblMenstrating setFont:[UIFont fontWithName:kAppFont size:12]];
    self.lblDateSelected.font = [UIFont fontWithName:kAppFont size:14];
    self.lblYouGotNothing.font = [UIFont fontWithName:kAppFont size:14];
    [self.btnAddEvent.titleLabel setFont:[UIFont fontWithName:kAppFont size:10]];
    [self.btnMenstration.titleLabel setFont:[UIFont fontWithName:kAppFont size:10]];
    [self.btnRemoveEvent.titleLabel setFont:[UIFont fontWithName:kAppFont size:10]];
    
    self.scrollViewEvents.delegate = self;
    if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
        [self.btnMenstration setHidden:YES];
    }
    else{
        [self.btnMenstration setHidden:NO];
    }
}


#pragma mark - public function
- (void) hideMenstrationView:(BOOL) isHide{
    [self.viewMenstrating setHidden:isHide];
}

- (void) hideFertleView:(BOOL) isHide{
    [self.viewFertle setHidden:isHide];
}

#pragma mark - UI functions
-(void)reloadViewWithEvents:(NSArray *)events eventTimes:(NSArray *)eventTimes
{
    
    if(events.count > 0){
        self.lblYouGotNothing.hidden = YES;
        self.lblDateSelected.hidden = YES;
        self.scrollViewEvents.hidden = NO;
        [self.btnRemoveEvent setHidden:NO];
    }
    else{
        [self.btnRemoveEvent setHidden:YES];
    }
    
    //remove all subview
    [self.scrollViewEvents removeAllSubviews];
    self.events = events;
    self.eventTimes = eventTimes;
    _selectedEventIndex = 0;

    
    
    //add new one
    if(!events || events.count == 0){
        EventItemView *itemView = [[[EventItemView alloc] initWithFrame:CGRectMake(0, 0, self.scrollViewEvents.frame.size.width, self.scrollViewEvents.frame.size.height)] autorelease];
        // Change by https://setaintl2008.atlassian.net/browse/MA-279
        itemView.lblEventTitle.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
        itemView.lblEventDescription.text = @" ";
        itemView.lblEventDescription.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
        [self.scrollViewEvents addSubview:itemView];
        [self.scrollViewEvents setContentSize:CGSizeMake(self.scrollViewEvents.frame.size.width, self.scrollViewEvents.frame.size.height)];
    } else {

        NSInteger numberOfEvent = self.events.count;
        [self.scrollViewEvents setContentSize:CGSizeMake(self.scrollViewEvents.frame.size.width, self.scrollViewEvents.frame.size.height * numberOfEvent)];
        for( NSInteger i = 0; i < numberOfEvent; i++){
            Event *event = events[i];
            NSDate *eventTime = self.eventTimes[i];
            DLogInfo(@"iiiiiiiii%d",i);
            DLogInfo(@"event name: %@",event.eventName);
            DLogInfo(@"event time: %@",event.eventTime);
            EventItemView *itemView = [[[EventItemView alloc] initWithFrame:CGRectMake(0, i * self.scrollViewEvents.frame.size.height, self.scrollViewEvents.frame.size.width, self.scrollViewEvents.frame.size.height)] autorelease];
            itemView.lblEventTitle.text = event.eventName;
            itemView.lblEventDescription.text = [eventTime toString];
            NSDateComponents *dateComponents = [NSDate hourComponentsBetweenDate:event.eventTime andDate:event.eventEndTime];
            NSDateComponents *finishDateC = [NSDate hourComponentsBetweenDate:event.eventTime andDate:event.finishTime];
            NSLog(@"hour %d",dateComponents.hour);
            NSLog(@"minute %d",dateComponents.minute);
            if((dateComponents.hour == 24) || (dateComponents.hour == 23 && dateComponents.minute >= 57) || finishDateC.hour == 24){
                // don't add
            } else {
                itemView.lblEventTime.text = [NSString stringWithFormat:@"%@ - %@",[event.eventTime toTimeOnlyString],[event.finishTime toTimeOnlyString]];
            }
            [self.scrollViewEvents addSubview:itemView];
        }
    }
}

#pragma mark - control event
-(void) showEventAtIndex:(NSInteger)index{
    if(index < self.events.count){
        Event *event = [self.events objectAtIndex:index];
        if(event){
            _selectedEventIndex = index;
            
            //scroll to the selected event
            [self.scrollViewEvents setContentOffset:CGPointMake(0, [self getEventOffSetByIndex:index]) animated:YES];
        }
    }
}
- (void) showEventClosestToDate:(NSDate *)date isNewInitial:(BOOL) isNewInitial isSelected:(BOOL) isSelected isChangeMonth:(BOOL) isChangeMonth {
    [self showEventClosestToDate:date isNewInitial:isNewInitial isSelected:isSelected isChangeMonth:isChangeMonth events:self.events isCurrentDay:YES];
}

//show the event closest to the selected date
- (void) showEventClosestToDate:(NSDate *)date isNewInitial:(BOOL) isNewInitial isSelected:(BOOL) isSelected isChangeMonth:(BOOL) isChangeMonth events:(NSArray *)eventsAfterToday isCurrentDay:(BOOL)isCurrentDay {
    NSLog(@"date selected %@",date);
    //we priority the later event, so the first step will be get all the event which is later than the selected date and sort them
//    NSArray *laterEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(eventTime >= %@)", date]];
    // Change by issue ma 279
//
    NSArray *array = self.events;
    if (isCurrentDay) {
        array = eventsAfterToday;
        if (eventsAfterToday.count == 0) {
            self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
            self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
            self.lblDateSelected.hidden = NO;
            self.scrollViewEvents.hidden = YES;
            self.lblYouGotNothing.hidden = NO;
            self.btnRemoveEvent.hidden = YES;

            return;
        }
    }
    
    // check show lastest event (include today)
    if (isNewInitial && array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            Event *event = array[i];
//            if ([event.type integerValue] == MANAPP_EVENT_TYPE_EVENT &&  ([event.eventTime isSameDay:date] || [event.eventTime isAfterDate:date])) {
//                _selectedEventIndex = i;
//                self.scrollViewEvents.hidden = NO;
//                self.lblYouGotNothing.hidden = YES;
//                self.lblDateSelected.hidden = YES;
//                [self showEventAtIndex:_selectedEventIndex];
//                self.btnRemoveEvent.hidden = NO;
//                return;
//            }
            if ([event.type integerValue] == MANAPP_EVENT_TYPE_BIRTHDAY) {
                /**
                 *  Cuongnt comment for MA-335
                 *
                 *  @param self.isMonthly <#self.isMonthly description#>
                 *  
                 *  @return <#return value description#>
                 */
                
//                self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
//                self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
//                self.lblDateSelected.hidden = NO;
//                self.scrollViewEvents.hidden = YES;
//                self.lblYouGotNothing.hidden = NO;
//                self.btnRemoveEvent.hidden = YES;
                
                // Cuongnt create
                _selectedEventIndex = isCurrentDay ? i + (self.events.count - array.count) : i;
                self.scrollViewEvents.hidden = NO;
                self.lblYouGotNothing.hidden = YES;
                self.lblDateSelected.hidden = YES;
                [self showEventAtIndex:_selectedEventIndex];
                self.btnRemoveEvent.hidden = NO;
                return;

            } else {
                if ([event.eventTime isSameDay:date] || [event.eventTime isAfterDate:date]) {
//                    self.lblDateSelected.hidden = YES;
//                    self.scrollViewEvents.hidden = NO;
//                    self.lblYouGotNothing.hidden = YES;
//                    self.btnRemoveEvent.hidden = NO;
//
                    
                    // Cuongnt comment
                    _selectedEventIndex = isCurrentDay ? i + (self.events.count - array.count) : i;
                    
                    self.scrollViewEvents.hidden = NO;
                    self.lblYouGotNothing.hidden = YES;
                    self.lblDateSelected.hidden = YES;
                    [self showEventAtIndex:_selectedEventIndex];
                    self.btnRemoveEvent.hidden = NO;
                    return;
                } else {
                    self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
                    self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
                    self.lblDateSelected.hidden = NO;
                    self.scrollViewEvents.hidden = YES;
                    self.lblYouGotNothing.hidden = NO;
                    self.btnRemoveEvent.hidden = YES;
                }
                //                                    self.lblYouGotNothing.text = Translate(@"You got nothing?");
                //                                    self.lblDateSelected.text = [date toString];
            }
        }
    }
    BOOL isExits = NO;
    for (int i = 0; i < array.count; i++) {
       
        NSDate *eventTime = self.eventTimes[i];
//        NSLog(@"event time %@",[eventObj.eventTime toString]);

        BOOL hasEvent = NO;
        if ([date isSameDay:eventTime]) {
            hasEvent = YES;
        }
        if (hasEvent) {
//            DLogInfo(@"same");
//            NSLog(@"event time %@",[eventTime toString]);
//            NSLog(@"event end time %@",[eventObj.finishTime toString]);
//            NSLog(@"selected date %@",[date toString]);
    //            NSInteger nextIndex = [array indexOfObject:[laterEvents firstObject]];
            _selectedEventIndex = isCurrentDay ? i + (self.events.count - array.count) : i;

            self.scrollViewEvents.hidden = NO;
            self.lblYouGotNothing.hidden = YES;
            self.lblDateSelected.hidden = YES;
            [self showEventAtIndex:_selectedEventIndex];
            self.btnRemoveEvent.hidden = NO;
            isExits = YES;
            break;
        } else {

        }
    }
    //in case there is no event later than the selected date, we find a new array which contain all the event that happen before the selected time
    if (!isExits) {
        //[NSPredicate predicateWithFormat:@"(eventTime < %@)  change to >=  for same https://setaintl2008.atlassian.net/browse/MA-279
//        for (NSArray *arrayEvent in array) {
//            NSArray *soonerEvents = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(eventTime >= %@)", date]];
        if (array.count == 0) {
//            if (isSelected) {
////                self.lblYouGotNothing.text = Translate(@"You got nothing?");
//                self.lblDateSelected.hidden = NO;
//                self.scrollViewEvents.hidden = YES;
//                self.lblYouGotNothing.hidden = NO;
//                self.lblDateSelected.text = [date toString];
//                self.btnRemoveEvent.hidden = YES;
//            } else {
//                self.lblDateSelected.hidden = YES;
//                self.scrollViewEvents.hidden = NO;
//                self.lblYouGotNothing.hidden = YES;
//                self.lblDateSelected.text = [date toString];
//                self.btnRemoveEvent.hidden = YES;
//            }
            if (!isChangeMonth && isSelected) {
                self.lblYouGotNothing.text = Translate(@"You got nothing?");
                self.lblDateSelected.hidden = NO;
                self.scrollViewEvents.hidden = YES;
                self.lblYouGotNothing.hidden = NO;
                self.lblDateSelected.text = [date toString];
                self.btnRemoveEvent.hidden = YES;
            } else {
                self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
                self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
                self.lblDateSelected.hidden = YES;
                self.scrollViewEvents.hidden = NO;
                self.lblYouGotNothing.hidden = YES;
                self.lblDateSelected.text = [date toString];
                self.btnRemoveEvent.hidden = YES;
            }


        }
        for (int i = 0; i < array.count; i++) {
            //        NSArray *listEvent = [array objectAtIndex:i];
            //        for (int j = 0; j < listEvent.count; j++) {
            Event *eventObj = array[i];
            NSDate *eventTime = self.eventTimes[i];
            NSLog(@"event time %@",[eventTime toString]);
            
            BOOL hasEvent = NO;
            if ([date isSameDay:eventTime]) {
                hasEvent = YES;
            }
            // Cuongnt comment for FirstMeet and BirthDate
//            if (!isSelected && ![eventObj.type isEqualToNumber:[NSNumber numberWithInt:MANAPP_EVENT_TYPE_FIRSTMEET]]) {
//                hasEvent = YES;
//            }
            /**
             *  Cuongnt changed
             */
            if (!isSelected && eventObj) {
                hasEvent = YES;
            }
            if (hasEvent) {
                _selectedEventIndex = isCurrentDay ? i + (self.events.count - array.count) : i;

                [self showEventAtIndex:_selectedEventIndex];
                self.scrollViewEvents.hidden = NO;
                self.lblYouGotNothing.hidden = YES;
                self.lblDateSelected.hidden = YES;
                self.lblDateSelected.text = [date toString];
                self.btnRemoveEvent.hidden = NO;
//            } else {
//                self.scrollViewEvents.hidden = YES;
//                self.lblYouGotNothing.hidden = NO;
//                self.lblDateSelected.hidden = NO;
//                self.lblDateSelected.text = [date toString];
//                self.btnRemoveEvent.hidden = YES;
                break;
                
            } else {
//                if (isNewInitial) {
//                    self.lblDateSelected.hidden = YES;
//                    self.scrollViewEvents.hidden = NO;
//                    self.lblYouGotNothing.hidden = YES;
//                    self.lblDateSelected.text = [date toString];
//                    self.btnRemoveEvent.hidden = YES;
//                } else {
                    if (isSelected && !isChangeMonth) {
                        self.lblYouGotNothing.text = Translate(@"You got nothing?");
                        self.lblDateSelected.hidden = NO;
                        self.scrollViewEvents.hidden = YES;
                        self.lblYouGotNothing.hidden = NO;
                        self.lblDateSelected.text = [date toString];
                        self.btnRemoveEvent.hidden = YES;
                    } else {
                        // check show lastest event (include today)
                        if (array.count > 0) {
                            for (int i = 0; i < array.count; i++) {
                                Event *event = array[i];
                                DLogInfo(@"event: %@",event.eventTime);
                                if ([event.type integerValue] == MANAPP_EVENT_TYPE_BIRTHDAY) {
                                    self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
                                    self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");

                                } else {
                                    if ([event.eventTime isAfterDate:date]) {

                                        self.lblDateSelected.hidden = YES;
                                        self.scrollViewEvents.hidden = NO;
                                        self.lblYouGotNothing.hidden = YES;
                                        self.btnRemoveEvent.hidden = NO;
                                    } else {
                                        self.lblYouGotNothing.text = (self.isMonthly) ? Translate(@"Are you even trying?") : Translate(@"Time to plan ahead!");
                                        self.lblDateSelected.text = (self.isMonthly) ? Translate(@"Nothing coming up this month?") : Translate(@"Nothing this week?");
                                        self.lblDateSelected.hidden = NO;
                                        self.scrollViewEvents.hidden = YES;
                                        self.lblYouGotNothing.hidden = NO;
                                        self.btnRemoveEvent.hidden = YES;
                                    }
//                                    self.lblYouGotNothing.text = Translate(@"You got nothing?");
//                                    self.lblDateSelected.text = [date toString];
                                }

//                                break;
                            }

                        }
                    }
//                }
            }
        }// end for
//        }
    } else {// else isexits
        
    }
}

#pragma mark - get,set
//get the offset of the event in the scroll view
-(NSInteger) getEventOffSetByIndex:(NSInteger) index{
    if(index < self.events.count){
        return index * self.scrollViewEvents.frame.size.height;
    }
    
    return 0;
}

-(Event *) getSelectedEvent{
    if(_selectedEventIndex < self.events.count){
        Event *event = [self.events objectAtIndex:_selectedEventIndex];
        if(event){
            return event;
        }
    }
    
    return nil;
}

-(NSInteger) getEventIndexByOffset:(CGPoint) offset{
    NSInteger index = offset.y / self.scrollViewEvents.frame.size.height;
    
    return index;
}

#pragma mark - event handler
- (IBAction)btnRemoveEvent_touchUpInside:(id)sender {
    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(didTouchRemoveEventButtonInEventsView:)]) {
        [self.delegate didTouchRemoveEventButtonInEventsView:self];
    }
}

- (IBAction)btnAddEvent_touchUpInside:(id)sender {
    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(didTouchAddEventButtonInEventsView:)]) {
        [self.delegate didTouchAddEventButtonInEventsView:self];
    }
}

- (IBAction)btnMenstration_touchUpInside:(id)sender {
    if (self.delegate && [(NSObject*)self.delegate respondsToSelector:@selector(didTouchMenstrationButtonInEventsView:)]) {
        [self.delegate didTouchMenstrationButtonInEventsView:self];
    }
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint currentOffset = self.scrollViewEvents.contentOffset;
    _selectedEventIndex = [self getEventIndexByOffset:currentOffset];
}
@end
