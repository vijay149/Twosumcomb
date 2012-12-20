//
//  DatabaseManager.h
//  ManApp
//
//  Created by viet on 7/12/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kEntityPartnerMood          @"PartnerMood"

@class Partner;
@class PartnerInformation;
@class Diet;
@class PartnerAvatar;
@class Hair;
@class Color;
@class Eye;
@class Skin;
@class Event;
@class PartnerSetup;
@class ErogeneousZone;
@class PartnerEroZone;
@class PartnerMood;
@class PartnerMeasurement;
@class PartnerMeasurementItem;
@class PreferenceCategory;
@class PreferenceItem;

@interface DatabaseHelper : NSObject
{
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

+(id) sharedHelper;
- (void)saveContext;

// COMMENT: functions to work with partner table
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex forUserId:(NSInteger) userId;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet forUserId:(NSInteger) userId;
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex;
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet;
-(NSArray*) getAllPartner;
-(NSArray*) getAllPartnerForUserId:(NSInteger) userId;
-(Partner*) getOnePartner;
-(Partner*) getOnePartnerForUserId:(NSInteger) userId;
-(Partner*) getPartnerByName:(NSString *) name;
-(Partner*) getPartnerByName:(NSString *) name forId:(NSInteger) userId;
-(Partner*) getPartnerById:(NSInteger) partnerId;
-(NSInteger) getNumberOfPartnerOfUser:(NSInteger) userId;
-(float) getSetupProgressForPartnerId:(NSInteger) userId;
-(void) increaseSetupProfressForPartnerId:(NSInteger) userId byValue:(NSInteger) incrementValue;
-(void) increaseSetupProfressForPartnerId:(NSInteger) userId byStepName:(NSString*) stepName;
-(BOOL)removePartner:(Partner *)partner;

// COMMENT: functions to work with Color table
-(BOOL) addColorWithHexString:(NSString*) hexString andName:(NSString*) name;
-(void) initColorData;
-(NSArray*) getAllColor;
-(NSArray*) getAllColorForHair;
-(NSArray*) getAllColorForEye;
-(NSArray*) getAllColorForSkin;
-(Color*) getColorWithId:(NSInteger)colorId;
-(Color*) getColorWithCode:(NSString*)colorCode;

// COMMENT: functions to work with partner avatar
-(BOOL) addPartnerAvatarForPartnerId:(NSInteger) partnerId;
-(NSArray*) getAllAvatar;
-(PartnerAvatar*) getPartnerAvatarByPartnerId:(NSInteger) partnerId addIfNotExist:(BOOL) flag;
-(BOOL) updateAvatarHairWithColor:(Color*) color forPartnerId:(NSInteger) partnerId;
-(NSString*) getAvatarHairColorForPartnerId:(NSInteger) partnerId;
-(BOOL) updateAvatarEyeWithColor:(Color*) color forPartnerId:(NSInteger) partnerId;
-(NSString*) getAvatarEyeColorForPartnerId:(NSInteger) partnerId;
-(BOOL) updateAvatarSkinWithColor:(Color*) color forPartnerId:(NSInteger) partnerId;
-(NSString*) getAvatarSkinColorForPartnerId:(NSInteger) partnerId;

-(NSInteger) addHairWithColor:(Color*) color;
-(BOOL) editHairWithId:(NSInteger)hairId WithColor:(Color*) color;
-(Hair*) getHairWithId:(NSInteger)hairId;
-(NSArray*) getAllHair;

// COMMENT: functions to work with partner's avatar eye
-(NSInteger) addEyeWithColor:(Color*) color;
-(BOOL) editEyeWithId:(NSInteger)eyeId WithColor:(Color*) color;
-(Eye*) getEyeWithId:(NSInteger)eyeId;
-(NSArray*) getAllEye;

// COMMENT: functions to work with partner'avatar skin
-(NSInteger) addSkinWithColor:(Color*) color;
-(BOOL) editSkinWithId:(NSInteger)skinId WithColor:(Color*) color;
-(Skin*) getSkinWithId:(NSInteger)skinId;
-(NSArray*) getAllSkin;

// COMMENT: functions to work with partner event
- (BOOL) createNewPartnerEventWithEventName:(NSString *)eventName andEventTime:(NSDate *)eventTime andNote: (NSString *)note andPartnerId:(NSInteger)partnerId andRecurrence: (NSString *)recurrence andReminder: (NSString *)reminder;
- (void) deletePartnerEventDataWithIndex: (NSInteger)index;
-(NSArray*) getAllEvent;
-(NSArray*) getAllEventForPartner:(NSInteger) partnerId;
-(NSArray*) getAllEventOccurAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;
-(NSArray*) getAllRecurringEventsAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;
-(BOOL)hasRecurringEventsAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;
// COMMENT: functions to work with setup process
-(NSArray*) getAllSetupStep;
-(PartnerSetup*) getSetupStepByName:(NSString*) setupName;
-(PartnerSetup*) getSetupStepById:(NSInteger) setupId;
-(NSInteger) addSetupStepWithName:(NSString*) setupName withWeight:(float) setupWeight;
-(void) initSetupStepData;
-(BOOL)removeEventWithID:(NSString *)eventID;

// COMMENT: functions to work with ero zone
-(NSArray*) getAllEroZone;
-(ErogeneousZone*) getEroZoneById:(NSInteger) eroZoneId;
-(NSInteger) addEroZoneWithName:(NSString*) zoneName;
-(void) initEroZoneData;

// COMMENT: functions to work with partner ero zone
-(NSArray*) getAllPartnerEroZone;
-(PartnerEroZone*) getPartnerEroZoneById:(NSInteger) partnerEroZoneId;
-(PartnerEroZone*) getPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId;
-(NSInteger) addPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value;
-(BOOL) editPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value;

// Functions working with tbl PartnerMood
- (PartnerMood *)partnerMoodWithId:(NSString *)moodId;
- (PartnerMood *)partnerMoodWithPartnerId:(NSInteger)partnerId date:(NSDate *)date;
- (void)addMoodValue:(NSNumber *)moodValue forPartnerWithId:(NSInteger)partnerId date:(NSDate *)date;
- (BOOL)removePartnerMoodWithPartnerWithId:(NSInteger)partnerId date:(NSDate *)date;

// Functions working with tbl PartnerMeasurement
- (BOOL)initDefaultMeasurementDataForPartner:(Partner *)partner;
- (BOOL)addNewMeasurementItemForPartnerMeasurement:(PartnerMeasurement *)partnerMeasurement name:(NSString *)name;
- (BOOL)addNewInformationCategoryForPartner:(Partner *)partner withName:(NSString *)name;
- (BOOL)addNewMeasurementCategoryForPartner:(Partner *)partner withName:(NSString *)name;
- (NSArray *)getAllPartnerMeasurementForPartner:(Partner *)partner;
- (NSArray *)getAllItemForPartnerMeasurement:(PartnerMeasurement *)pMeasurement;
- (NSArray *)getAllItemMeasurementForPartner:(Partner *)partner;
// Functions working with tbl PartnerInformation
- (BOOL) initDefaultInformationForPartner:(Partner *)partner;
- (NSArray *)getAllPartnerInformationForPartner:(Partner *)partner;
- (NSArray *)getAllItemForPartnerInformation:(PartnerInformation *)pInformation;
- (NSArray *)getAllItemInformationForPartner:(Partner *)partner;
// Functions working with tbl PartnerPreference
- (BOOL) initDefaultPreferenceForPartner:(Partner *)partner;
- (BOOL) addNewPreferenceCategoryForCategory:(PreferenceCategory *)pPreference withName:(NSString*)name;
- (BOOL) removePreferenceCategory:(PreferenceCategory *)pPreference;
- (NSArray *)getAllPartnerPreferenceForPartner:(Partner *)partner;
- (NSArray *)getAllPartnerPreferenceAtLevel:(NSInteger) level ForPartner:(Partner *)partner parentCategory:(PreferenceCategory*)parent;
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference;
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference isLike:(BOOL) isLike;
- (NSArray *)getAllItemPreferenceForPartner:(Partner *)partner;

- (BOOL)deleteManagedObject:(NSManagedObject *)obj;
- (NSManagedObject *)newManagedObjectForEntity:(NSString *)entity;
@end
