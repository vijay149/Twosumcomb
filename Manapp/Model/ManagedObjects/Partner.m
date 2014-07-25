//
//  Partner.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "Partner.h"
#import "Event.h"
#import "PartnerAvatar.h"
#import "PartnerEroZone.h"
#import "PartnerInformation.h"
#import "PartnerMeasurement.h"
#import "PartnerMood.h"
#import "PreferenceCategory.h"


@implementation Partner

@dynamic birthControl;
@dynamic calendarType;
@dynamic dateOfBirth;
@dynamic firstDate;
@dynamic lastPeriod;
@dynamic name;
@dynamic partnerID;
@dynamic setupProgress;
@dynamic sex;
@dynamic userID;
@dynamic events;
@dynamic fkPartnerToPartnerAvatar;
@dynamic fkPartnerToPartnerEroZone;
@dynamic information;
@dynamic measurements;
@dynamic partnerMoods;
@dynamic preferences;

@end
