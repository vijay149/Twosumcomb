//
//  PartnerMeasurement.h
//  TwoSum
//
//  Created by Demigod on 17/05/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner, PartnerMeasurementItem;

@interface PartnerMeasurement : NSManagedObject

@property (nonatomic, retain) NSString * measurementID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Partner *partner;
@end

@interface PartnerMeasurement (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PartnerMeasurementItem *)value;
- (void)removeItemsObject:(PartnerMeasurementItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
