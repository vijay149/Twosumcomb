//
//  Partner.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, PartnerAvatar, PartnerEroZone, PartnerInformation, PartnerMeasurement, PartnerMood, PreferenceCategory;

@interface Partner : NSManagedObject

@property (nonatomic, retain) NSNumber * birthControl;
@property (nonatomic, retain) NSNumber * calendarType;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) NSDate * firstDate;
@property (nonatomic, retain) NSDate * lastPeriod;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * partnerID;
@property (nonatomic, retain) NSString * setupProgress;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *fkPartnerToPartnerAvatar;
@property (nonatomic, retain) PartnerEroZone *fkPartnerToPartnerEroZone;
@property (nonatomic, retain) NSSet *information;
@property (nonatomic, retain) NSSet *measurements;
@property (nonatomic, retain) NSSet *partnerMoods;
@property (nonatomic, retain) NSSet *preferences;
@end

@interface Partner (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addFkPartnerToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkPartnerToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkPartnerToPartnerAvatar:(NSSet *)values;
- (void)removeFkPartnerToPartnerAvatar:(NSSet *)values;

- (void)addInformationObject:(PartnerInformation *)value;
- (void)removeInformationObject:(PartnerInformation *)value;
- (void)addInformation:(NSSet *)values;
- (void)removeInformation:(NSSet *)values;

- (void)addMeasurementsObject:(PartnerMeasurement *)value;
- (void)removeMeasurementsObject:(PartnerMeasurement *)value;
- (void)addMeasurements:(NSSet *)values;
- (void)removeMeasurements:(NSSet *)values;

- (void)addPartnerMoodsObject:(PartnerMood *)value;
- (void)removePartnerMoodsObject:(PartnerMood *)value;
- (void)addPartnerMoods:(NSSet *)values;
- (void)removePartnerMoods:(NSSet *)values;

- (void)addPreferencesObject:(PreferenceCategory *)value;
- (void)removePreferencesObject:(PreferenceCategory *)value;
- (void)addPreferences:(NSSet *)values;
- (void)removePreferences:(NSSet *)values;

@end
