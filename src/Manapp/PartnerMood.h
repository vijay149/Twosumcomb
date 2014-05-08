//
//  PartnerMood.h
//  TwoSum
//
//  Created by NguyenHuong on 5/8/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface PartnerMood : NSManagedObject

@property (nonatomic, retain) NSDate * addedTime;
@property (nonatomic, retain) NSNumber * isSample;
@property (nonatomic, retain) NSString * moodID;
@property (nonatomic, retain) NSNumber * moodValue;
@property (nonatomic, retain) NSNumber * isUserInput;
@property (nonatomic, retain) Partner *partner;

@end
