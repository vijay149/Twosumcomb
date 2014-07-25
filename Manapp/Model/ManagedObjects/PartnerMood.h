//
//  PartnerMood.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner;

@interface PartnerMood : NSManagedObject

@property (nonatomic, retain) NSDate * addedTime;
@property (nonatomic, retain) NSString * moodID;
@property (nonatomic, retain) NSNumber * moodValue;
@property (nonatomic, retain) Partner *partner;

@end
