//
//  ErogeneousZone.h
//  TwoSum
//
//  Created by Demigod on 28/05/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerEroZone;

@interface ErogeneousZone : NSManagedObject

@property (nonatomic, retain) NSNumber * erogeneousZoneID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) PartnerEroZone *fkEroZoneToPartnerEroZone;

@end
