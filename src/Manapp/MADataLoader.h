//
//  MADataLoader.h
//  TwoSum
//
//  Created by Nguyen Huong on 3/11/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MoodHelper.h"
#import "PartnerMood.h"
#import "Partner.h"
#import "NSDate+Helper.h"
#import "MANotificationManager.h"
@interface MADataLoader : NSObject
{
    
}
@property (nonatomic,strong) NSArray* partnerList;
@property (nonatomic,strong) PartnerMood *partnerMood;
@property NSInteger numberOfAvatar;
@property (nonatomic,strong) NSArray *currentUserPartners;
@property NSInteger currentPose;
//Partner Bubble Talk
@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) Message *tip;
+(id) ShareDataLoader;
-(void) reLoadEntireData;
- (void)getMessagessListsFromServer;
@end
