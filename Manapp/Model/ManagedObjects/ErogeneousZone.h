//
//  ErogeneousZone.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerEroZone;

@interface ErogeneousZone : NSManagedObject

@property (nonatomic, retain) NSNumber * erogeneousZoneID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) PartnerEroZone *fkEroZoneToPartnerEroZone;

@end
