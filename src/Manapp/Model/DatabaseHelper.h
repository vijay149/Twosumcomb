//
//  DatabaseManager.h
//  ManApp
//
//  Created by viet on 7/12/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SpecialZoneDTO.h"

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
@class Note;
@class ItemCategory;
@class Item;
@class ItemToAvatar;
@class Message;
@class MessageDTO;
@class PartnerInformationItem;
@interface DatabaseHelper : NSObject
{
    NSManagedObjectContext *managedObjectContext;
}

@property (retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

+(id) sharedHelper;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
// COMMENT: functions to work with partner table
-(BOOL) isPartnerWithSameNameExisted:(NSString *) name forUserId:(NSInteger) userId asideFromPartner:(Partner *)partner;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex forUserId:(NSInteger) userId;
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet forUserId:(NSInteger) userId;
- (BOOL)updateFirstTimeUserCycleStatus:(BOOL)status forPartner:(Partner *)partner;
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex;
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet;
-(BOOL) setLastUsedTimeWithCurrentDateForPartner:(NSInteger) partnerId;
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
- (BOOL)changeSkinColorForPartner:(Partner *)partner toColor:(UIColor *)color;
- (BOOL)changeEyeColorForPartner:(Partner *)partner toColor:(UIColor *)color;
- (BOOL)changeHairColorForPartner:(Partner *)partner toColor:(UIColor *)color;
- (BOOL)changeBeardColorForPartner:(Partner *)partner toColor:(UIColor *)color;

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
- (NSArray*) createBirthdayEventsForPartner:(Partner *) partner;
- (NSArray*) createFirstMeetEventsForPartner:(Partner *) partner;
- (NSArray *) createNewPartnerEventWithEventName:(NSString *)eventName andEventTime:(NSDate *)eventTime endDate:(NSDate*)endDate andNote: (NSString *)note andPartnerId:(NSInteger)partnerId andRecurrence: (NSString *)recurrence andReminder: (NSString *)reminder finishTime:(NSDate *)finishTime;
- (void) deletePartnerEventDataWithIndex: (NSInteger)index;
-(NSArray*) getAllEvent;
-(NSArray*) getAllEventForPartner:(NSInteger) partnerId;
-(NSArray*) getAllEventOccurAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;
- (NSArray*)getAllOccurEventFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId;
- (NSArray*)getAllListEventTimeOccurFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId;
- (NSArray*)getAllListEventOccurFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId;
- (NSArray *)getEventWithCorrectTimeValueForMonthView:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId;
- (NSArray*)getAllListEventOccurFromDateForMonthView:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId;
-(NSArray*) getAllEventOccurFromDate:(NSDate*)fromDate toDate:(NSDate *) toDate forPartner:(NSInteger) partnerId;
-(NSArray*) getAllEventCurrentDateToFutureForPartner:(NSInteger) partnerId;
-(NSArray*) getAllRecurringEventsAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;
-(BOOL) setMenstruationForPartner:(NSInteger)partnerId lastPeriod:(NSDate *)lastPeriod usingBirthControl:(BOOL)usingBirthControl;
//-(NSArray *) sortEventListByDate:(NSArray *)events;
-(BOOL)hasRecurringEventsAtDate:(NSDate*)date forPartner:(NSInteger) partnerId;

// COMMENT: funtions to work with partner menstration and fertle
-(BOOL) isPartner:(Partner *) partner haveFertileInDate:(NSDate *)date;
-(BOOL) isPartner:(Partner *) partner haveMenstrationInDate:(NSDate *)date;
-(BOOL) isPartner:(Partner *) partner haveSensitiveInDate:(NSDate *)date;

// COMMENT: functions to work with setup process
-(NSArray*) getAllSetupStep;
-(PartnerSetup*) getSetupStepByName:(NSString*) setupName;
-(PartnerSetup*) getSetupStepById:(NSInteger) setupId;
-(NSInteger) addSetupStepWithName:(NSString*) setupName withWeight:(float) setupWeight;
-(void) initSetupStepData;
-(BOOL)removeEventWithID:(NSString *)eventID;

// COMMENT: functions to work with ero zone
-(NSArray*) getAllEroZone;
-(NSArray*) getAllEroZoneForAvatarType:(NSInteger) type sex:(NSInteger)sex;
-(void) generateZoneWithZoneList:(NSArray *)zoneDTOs forAvatarType:(NSInteger) type sex:(NSInteger)sex;
-(ErogeneousZone*) getEroZoneById:(NSInteger) eroZoneId;
-(ErogeneousZone*) getEroZoneByTypeId:(NSInteger) eroZoneTypeId forPartner:(Partner *)partner avatarType:(NSInteger)type;
-(ErogeneousZone*) addEroZoneWithName:(NSString*) zoneName type:(NSInteger)type sex:(NSInteger) sex;
-(ErogeneousZone*) addEroZoneWithName:(NSString*) zoneName andId:(NSInteger) zoneId type:(NSInteger)type sex:(NSInteger) sex;
-(void) initEroZoneData;

// COMMENT: note
-(Note *) addNote:(NSString *) note forPartner:(Partner *) partner;
-(NSArray*) getNotesForPartner:(Partner *) partner;
-(Note *) editNote:(Note *)note withNewNote:(NSString *) noteString;
-(BOOL) removeNote:(Note *)note;

// COMMENT: functions to work with partner ero zone
-(NSArray*) getAllPartnerEroZone;
-(PartnerEroZone*) getPartnerEroZoneById:(NSInteger) partnerEroZoneId;
-(NSArray*) getPartnerEroZonesForPartner:(NSInteger) partnerId;
-(PartnerEroZone*) getPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId;
-(PartnerEroZone *) addPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value;
-(BOOL) editPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value;
- (BOOL) removeAllPartnereroZone:(NSArray*) specialZoneList;
//MA_451
-(PartnerEroZone*) addFreePartnerEroZone:(NSInteger) zoneId andValue:(NSString*) value;



// Functions working with tbl PartnerMood
- (NSArray*)getAllMoodForPartner:(Partner *) partner;
- (NSArray*)getAllSampleMoodForPartner:(Partner *) partner;
- (void)addSampleMoodsForPartner:(Partner *)partner fromDate:(NSDate *)date;
- (void)removeAllSampleMoodForPartner:(Partner *)partner;
- (PartnerMood *)partnerMoodWithId:(NSString *)moodId;
- (PartnerMood *)partnerMoodWithPartner:(Partner*)partner date:(NSDate *)date;
- (PartnerMood *)addMoodValue:(NSNumber *)moodValue forPartner:(Partner*)partner date:(NSDate *)date;
- (BOOL)removePartnerMoodWithPartner:(Partner*)partner date:(NSDate *)date;

// Functions working with tbl PartnerMeasurement
- (BOOL)initDefaultMeasurementDataForPartner:(Partner *)partner;
- (NSInteger) restoreDefaultMeasurementCategoryForPartner:(Partner *)partner;
- (BOOL)addNewMeasurementItemForPartnerMeasurement:(PartnerMeasurement *)partnerMeasurement name:(NSString *)name;
- (PartnerInformation *)addNewInformationCategoryForPartner:(Partner *)partner withName:(NSString *)name;
- (PartnerInformation *)addNewInformationCategoryForCategory:(PartnerInformation *)partnerInformation withName:(NSString*)name;
- (PartnerMeasurement *)addNewMeasurementCategoryForPartner:(Partner *)partner withName:(NSString *)name forSex:(NSInteger)sex;
- (PartnerMeasurementItem *)getPartnerMeasurementItem:(NSString *)itemID;
- (NSArray *)getPartnerMeasurementsWithName:(NSString *)name forPartner:(Partner *)partner;
- (NSMutableArray *)getAllPartnerMeasurementForPartner:(Partner *)partner;
- (NSArray *)getAllItemForPartnerMeasurement:(PartnerMeasurement *)pMeasurement;
- (NSArray *)getAllItemMeasurementForPartner:(Partner *)partner;
// Functions working with tbl PartnerInformation
- (BOOL) initDefaultInformationForPartner:(Partner *)partner;
- (PartnerInformationItem *)getItemPartnerInformationItem:(NSString *)itemID;
- (NSInteger) restoreDefaultInformationCategoryForPartner:(Partner *)partner;
- (NSArray *)getPartnerInformationsWithName:(NSString *)name forPartner:(Partner *)partner;
- (NSArray *)getAllPartnerInformationForPartner:(Partner *)partner;
- (NSArray *)getAllPartnerInformationAtLevel:(NSInteger) level ForPartner:(Partner *)partner parentCategory:(PartnerInformation*)parent;
- (NSArray *)getPartnerInformationAtLevel:(NSInteger) level withName:(NSString *) name forPartner:(Partner *)partner parentCategory:(PartnerInformation*)parent;
- (NSArray *)getAllItemForPartnerInformation:(PartnerInformation *)pInformation;
- (NSArray *)getAllItemInformationForPartner:(Partner *)partner;
// Functions working with tbl PartnerPreference
- (BOOL) initDefaultPreferenceForPartner:(Partner *)partner;
- (NSInteger) restoreDefaultPreferenceCategoryForPartner:(Partner *)partner;
- (PreferenceCategory *) addNewPreferenceCategoryForCategory:(PreferenceCategory *)pPreference withName:(NSString*)name;
- (BOOL) removePreferenceCategory:(PreferenceCategory *)pPreference;
- (NSArray *)getAllPartnerPreferenceForPartner:(Partner *)partner;
- (NSArray *)getAllPartnerPreferenceAtLevel:(NSInteger) level ForPartner:(Partner *)partner parentCategory:(PreferenceCategory*)parent;
- (NSArray *)getPartnerPreferenceAtLevel:(NSInteger) level withName:(NSString *) name forPartner:(Partner *)partner parentCategory:(PreferenceCategory*)parent;
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference;
- (NSArray *)getAllItemForPartnerPreferenceWithOrderByCategoryName:(PreferenceCategory *)pPreference;
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference isLike:(BOOL) isLike;
- (NSArray *)getAllItemForPartnerPreferenceWithOrderByCategoryName:(PreferenceCategory *)pPreference isLike:(BOOL) isLike;
- (NSArray *)getAllItemForPartner:(Partner *)partner isLike:(BOOL) isLike;
- (NSArray *)getAllItemPreferenceForPartner:(Partner *)partner;

#pragma mark - item category
- (void)initDefaultItem;

- (NSArray *)getAllItemCategory;
- (ItemCategory *)getCategoryWithName:(NSString *)name;
- (ItemCategory *)addNewItemCategoryWithName:(NSString *)name zIndex:(NSInteger)zIndex;

#pragma mark - items for avatar
- (NSArray *)getAllItem;
- (NSArray *)getAllItemForSex:(NSInteger)sex;
- (NSArray *)getAllItemByName:(NSString *)name;
- (NSArray *)getAllItemForCategory:(ItemCategory *)category;
- (NSArray *)getAllItemForCategory:(ItemCategory *)category sex:(NSInteger)sex;

- (Item *)addItemWithName:(NSString *)name imageURL:(NSString *)url order:(NSInteger) order sex:(NSInteger)sex category:(ItemCategory *)category icon:(NSString *)icon;

#pragma mark - item to partner
- (NSArray *)getItemsForPartner:(Partner *)partner;
- (ItemToAvatar *)getItemForPartner:(Partner *)partner ofCategory:(ItemCategory *)category;
- (BOOL)addItem:(Item *)item toPartner:(Partner *)partner;
- (BOOL)removeItem:(Item *)item fromPartner:(Partner *)partner;
- (BOOL)removeItemOfCategory:(ItemCategory *)category fromPartner:(Partner *)partner;

#pragma mark - message
- (Message*)messageFromId:(NSString *) messageID;
- (Message *)messageFromMessageDTO:(MessageDTO *)messageDTO;
- (Message*)getMessageForType:(NSString *) type;
- (NSArray *)getAllMessage;
- (Message *)getNewestMessage;
- (NSInteger)countAllMessage;
- (BOOL)removeMessage:(NSString *)messageID;
/*mood : -1 mean mood didn't set*/
- (Message*)getMessageForType:(NSString *) type partner:(Partner *)partner mood:(CGFloat)mood;
- (Message*)getEventMessageForPartner:(Partner *)partner;
- (NSString *)getContentForMessage:(Message *)message partner:(Partner *)partner;
- (void)renewMessagesForPartner:(Partner *)partner;
- (NSArray *)messagesForPartner:(Partner *)partner;

#pragma mark - data functions
- (BOOL)deleteManagedObject:(NSManagedObject *)obj;
- (NSManagedObject *)newManagedObjectForEntity:(NSString *)entity;

- (NSArray *)getAllItemLikePartnerPreferenceForPartner:(Partner *)partner;//
- (void)revertChanges;

#pragma mark - SpecialZone
- (NSMutableArray*) getAllSpecialZoneNonPartnerEroZoneBySpecialZoneList:(NSArray*) specialZoneList;
- (BOOL) checkSpecialZoneStoredSpecialZoneList:(NSArray*) specialZoneList;
- (NSInteger) checkSpecialZoneStoredSpecialZoneListIsEnough:(NSArray*) specialZoneList;
- (PreferenceItem *)getItemPreference:(NSString *)itemID;


//HUONGNT ADD
-(CGFloat) getTodayMoodOfPartner:(Partner*) partner;
@end
