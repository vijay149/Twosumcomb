//
//  PartnerMood.h
//  Manapp
//
//  Created by Demigod on 12/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface PartnerMood : NSManagedObject

@property (nonatomic, retain) NSDate * addedTime;
@property (nonatomic, retain) NSString * moodID;
@property (nonatomic, retain) NSNumber * moodValue;
@property (nonatomic, retain) NSNumber * isSample;
@property (nonatomic, retain) Partner *partner;

@end
