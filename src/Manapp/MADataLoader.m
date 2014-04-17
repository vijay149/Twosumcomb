//
//  MADataLoader.m
//  TwoSum
//
//  Created by Nguyen Huong on 3/11/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

#import "MADataLoader.h"
#import "MessageDTO.h"
#import "AFJSONUtilities.h"
#import "GCDispatch.h"
#import "MANetworkHelper.h"
@implementation MADataLoader

+(id) ShareDataLoader{
    static MADataLoader* dataLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataLoader = [[MADataLoader alloc] init];
    });
    
    return dataLoader;
}
-(void) reLoadEntireData
{
    [[MADataLoader ShareDataLoader] loadPartnerList];
    [[MADataLoader ShareDataLoader] loadPartnerMood];
    [[MADataLoader ShareDataLoader] loadPartner];
    [[MADataLoader ShareDataLoader] loadCurrentPose];
}
-(void) loadPartnerList
{
    _partnerList = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
}
-(void) loadPartnerMood
{
    _partnerMood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:[[MASession sharedSession] currentPartner] date:[NSDate date]];
}
-(void) loadPartner
{
        // if the user don't have any partner yet, redirect them to the create partner page
        _numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
        if (_numberOfAvatar == 0) {
            [[MASession sharedSession] setCurrentPartner:nil];
        }
        else{
            //if there is no partner, automatically pick one partner
            if([[MASession sharedSession] currentPartner] == NULL){
                _currentUserPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
                [[MASession sharedSession] setCurrentPartner:[self.currentUserPartners lastObject]];
            }
        }
}


//loadCurrentPose
- (void) loadCurrentPose {
    CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:[[MASession sharedSession] currentPartner] date:[NSDate date]].moodValue.floatValue;
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    _currentPose = pose;
}

//Load ModdMessageForCurrentPartner
-(void) loadMoodMessageForCurrentPartner
{
    Partner *currentPartner = [MASession sharedSession].currentPartner;
    if(currentPartner){
        if(currentPartner.lastMessageUpdate) {
            //            int minute = [NSDate hourComponentsBetweenDate:currentPartner.lastMessageUpdate andDate:[NSDate date]].minute;
            int hours = [NSDate hourComponentsBetweenDate:currentPartner.lastMessageUpdate andDate:[NSDate date]].hour;//11
            if(hours > 11){
                //            if(minute > 4){
                [[DatabaseHelper sharedHelper] renewMessagesForPartner:currentPartner];
            }
        }
        else{
            currentPartner.lastMessageUpdate = [NSDate date];
            [[DatabaseHelper sharedHelper] renewMessagesForPartner:currentPartner];
        }
        _messages = [[DatabaseHelper sharedHelper] messagesForPartner:currentPartner];
        
        NSLog(@"-------Message: %@", self.messages);
        
        for(NSInteger i = 0; i < 7; i ++){
            NSDate* date = [[NSDate date] beginningOfDay];
            NSLog(@"beginningOfDay %@",date);
            NSLog(@"dateByAddDays %d : %@", i , [date dateByAddDays:i]);
            _events = [[DatabaseHelper sharedHelper] getAllEventOccurAtDate:[date dateByAddDays:i] forPartner:currentPartner.partnerID.integerValue];
            if(self.events.count > 0){
                break;
            }
        }
        NSLog(@"-------Events: %@", self.events);
        
        self.tip = [[DatabaseHelper sharedHelper] getEventMessageForPartner:currentPartner];
        NSLog(@"-------Tips: %@", self.tip);
        
        NSArray *allEvents = [[DatabaseHelper sharedHelper] getAllEventCurrentDateToFutureForPartner:currentPartner.partnerID.integerValue];
        for(Event *event in allEvents){
            NSLog(@"date %@",[NSDate date]);
            if([[MANotificationManager sharedInstance] isEvent:event haveNotificationAtDate:[NSDate date]]){
                [self.notifications addObject:event];
            }
        }
    }
}


#pragma mark - Get List Data from server
//saveMesssageDTOFromDictionary using when login sync message from server.
- (void) saveMesssageDTOFromDictionary:(NSDictionary*) resultDictionary isFromActionException:(BOOL) isFromActionException withsuccess:(void(^)(BOOL))hasData {
    NSNumber *result = [resultDictionary objectForKey:kAPIStatus];
    if([result boolValue]){
        NSArray *messageData = [resultDictionary objectForKey:@"attr"];
        if(messageData && [messageData isKindOfClass:[NSArray class]]){
            int count = 0;
            for(NSString *messageString in messageData){
                count++;
                DLog(@"background message count: %d",count);
                NSDictionary* messageDict = AFJSONDecode([messageString dataUsingEncoding:NSUTF8StringEncoding], nil);
                if([messageDict isKindOfClass:[NSDictionary class]]){
                    // check if message deleted from server.
                    NSString *deleted = [Util getSafeString:[messageDict objectForKey:@"deleted"]];
                    if (!isFromActionException) {
                        if (![deleted isEqualToString:kMessageDeletedFromServer]) {
                            MessageDTO *messageDTO = [[[MessageDTO alloc] initWithJsonDict:messageDict] autorelease];
                            [[DatabaseHelper sharedHelper] messageFromMessageDTO:messageDTO];
                        }
                    } else {
                        if ([deleted isEqualToString:kMessageDeletedFromServer]) {
                            NSString *messageID = [Util getSafeString:[messageDict objectForKey:@"id"]];
                            BOOL isOk = [[DatabaseHelper sharedHelper] removeMessage:messageID];
                            if (isOk) {
                                DLogInfo(@"delete messageID: %@ is ok.",messageID);
                            }
                        } else {
                            MessageDTO *messageDTO = [[[MessageDTO alloc] initWithJsonDict:messageDict] autorelease];
                            [[DatabaseHelper sharedHelper] messageFromMessageDTO:messageDTO];
                        }
                    }
                    
                }
            }
            hasData(YES);
        }
        else{
            if (!isFromActionException) {
                [self showMessage:LSSTRING(@"Data return is wrong. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
            }
            hasData(NO);
        }
    }
    else{
        [self showMessage:LSSTRING(@"There is an error. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
    }
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)getMessagessListsFromServer{
    /**
     *  Get Message from Server
     */
    [[MADataLoader ShareDataLoader] reLoadEntireData];
    //END
    
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    NSLog(@"start :%f",start);
    // get message on background.
    [GCDispatch performBlockInMainQueue:^{
        [[Util sharedUtil] showLoadingView];
        NSInteger countMessage = [[DatabaseHelper sharedHelper] countAllMessage];
        if (countMessage > 0) {
            NSLog(@"Load from Exception");
            NSNumber *latestUpdate = [UserDefault objectForKey:kLatestUpdateMessage];
            if (latestUpdate) {
                DLogInfo(@"[latestUpdate %f",[latestUpdate doubleValue]);
                [[MANetworkHelper sharedHelper] getMessageExceptionListWithLatestDate:[latestUpdate doubleValue] withsuccess:^(NSDictionary *resultDictionary) {
                    [self saveMesssageDTOFromDictionary:resultDictionary isFromActionException:YES withsuccess:^(BOOL hasData)  {
                        if (hasData) {
                            [UserDefault setObject:[Util getCurrentTimeStamp] forKey:kLatestUpdateMessage];
                            [UserDefault synchronize];
                        }
                        NSLog(@"closeee1");
                        [[Util sharedUtil] hideLoadingView];
                    }];
                } fail:^(NSError *error) {
                    [[Util sharedUtil] hideLoadingView];
                    [self showMessage:LSSTRING(@"There is an error with the server. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
                }];
            } else {
                [[Util sharedUtil] hideLoadingView];
            }
        } else {
            NSLog(@"Load getMessageListWithsuccess");
            [[MANetworkHelper sharedHelper] getMessageListWithsuccess:^(NSDictionary *resultDictionary) {
                [self saveMesssageDTOFromDictionary:resultDictionary isFromActionException:NO withsuccess:^(BOOL hasData) {
                    NSLog(@"closeee");
                    if (hasData) {
                        [UserDefault setObject:[Util getCurrentTimeStamp] forKey:kLatestUpdateMessage];
                        [UserDefault synchronize];
                    }
                    [[Util sharedUtil] hideLoadingView];
                }];
            } fail:^(NSError *error) {
                [[Util sharedUtil] hideLoadingView];
                [self showMessage:LSSTRING(@"There is an error with the server. We cannot synchronize the message list.") title:kAppName cancelButtonTitle:@"OK"];
            }];
        }
    }];
    
	/**
	 *  End Get Message from server
	 */

}

@end
