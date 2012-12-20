//
//  PartnerInformation.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner, PartnerInformationItem;

@interface PartnerInformation : NSManagedObject

@property (nonatomic, retain) NSString * infoID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Partner *partner;
@end

@interface PartnerInformation (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PartnerInformationItem *)value;
- (void)removeItemsObject:(PartnerInformationItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
