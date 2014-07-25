//
//  PartnerEroZone.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ErogeneousZone, Partner;

@interface PartnerEroZone : NSManagedObject

@property (nonatomic, retain) NSNumber * eroZoneID;
@property (nonatomic, retain) NSNumber * partnerEroZoneID;
@property (nonatomic, retain) NSNumber * partnerID;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) ErogeneousZone *fkPartnerEroZoneToEroZone;
@property (nonatomic, retain) Partner *fkPartnerEroZoneToPartner;

@end
