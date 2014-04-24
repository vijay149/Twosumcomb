//
//  DatabaseManager.m
//  ManApp
//
//  Created by viet on 7/12/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import "DatabaseHelper.h"
#import "CoreDataHelper.h"
#import "MAAppDelegate.h"
#import "Partner.h"
#import "PartnerInformation.h"
#import "Color.h"
#import "PartnerAvatar.h"
#import "Hair.h"
#import "Eye.h"
#import "Skin.h"
#import "Event.h"
#import "PartnerSetup.h"
#import "ErogeneousZone.h"
#import "PartnerEroZone.h"
#import "MACommon.h"
#import "PartnerMood.h"
#import "PartnerMeasurement.h"
#import "PartnerMeasurementItem.h"
#import "PreferenceCategory.h"
#import "NSString+Additional.h"
#import "NSDate+Helper.h"
#import "NSArray+MACalendar.h"
#import <TapkuLibrary/NSDate+TKCategory.h>
#import <TapkuLibrary/NSArray+TKCategory.h>
#import "Note.h"
#import "Item.h"
#import "ItemCategory.h"
#import "ItemToAvatar.h"
#import "UIColor-Expanded.h"
#import "Message.h"
#import "MessageDTO.h"
#import "PreferenceItem.h"
#import "MASession.h"
#import "PartnerMessages.h"
#import "MoodHelper.h"
#import "NSManagedObject+Clone.h"
#import "Global.h"

@implementation DatabaseHelper
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#define kRepeatYear 100

+(id) sharedHelper{
    static DatabaseHelper* databaseManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseManager = [[DatabaseHelper alloc] init];
    });
    
    return databaseManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        managedObjectContext = [self managedObjectContext];
    }
    return self;
}

-(void) dealloc{
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    [super dealloc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc != nil) {
        if ([moc hasChanges] && ![moc save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
    
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Manappv1" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Manappv1.sqlite"];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - partner

/**********************************************************
 @Function description: add new partner to core data table
 @Note:
***********************************************************/
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex {
    //COMMENT The new partner will have the highest id (load all the id and found the highest and then plus by one
    NSArray *partnerList = [self getAllPartner];
    NSInteger maxId = 0;
    if([partnerList count] > 0)
    {
        for(int i=0; i<[partnerList count]; i++){
            Partner* entity = [partnerList objectAtIndex:i];
            if([entity.partnerID intValue] > maxId){
                maxId = [entity.partnerID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    //COMMENT Add new partner
    
    Partner* partner = [NSEntityDescription insertNewObjectForEntityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    partner.partnerID = [NSNumber numberWithInt:(maxId + 1)];
    partner.name = name;
    partner.dateOfBirth = dob;
    partner.calendarType = [NSNumber numberWithInt:calendarType];
    partner.sex = [NSNumber numberWithInt:sex];
    partner.lastUsedTime = [NSDate date];
    partner.isNewForCycle = @(YES);
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert partner failed: %@",error);
        return FALSE;
    }
}

/**********************************************************
 @Function description: add new partner to core data table (with first meet date)
 @Note:
***********************************************************/
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet{
    //COMMENT The new partner will have the highest id (load all the id and found the highest and then plus by one
    NSArray *partnerList = [self getAllPartner];
    NSInteger maxId = 0;
    if([partnerList count] > 0)
    {
        for(int i=0; i<[partnerList count]; i++){
            Partner* entity = [partnerList objectAtIndex:i];
            if([entity.partnerID intValue] > maxId){
                maxId = [entity.partnerID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    //COMMENT Add new partner to database
    
    Partner* partner = [NSEntityDescription insertNewObjectForEntityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    partner.partnerID = [NSNumber numberWithInt:(maxId + 1)];
    partner.name = name;
    partner.dateOfBirth = dob;
    partner.calendarType = [NSNumber numberWithInt:calendarType];
    partner.sex = [NSNumber numberWithInt:sex];
    partner.firstDate = firstMeet;
    partner.lastUsedTime = [NSDate date];
    partner.isNewForCycle = @(YES);
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert partner failed: %@",error);
        return FALSE;
    }
}

/**********************************************************
 @Function description:add new partner for an user
 @Note:
***********************************************************/
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex forUserId:(NSInteger) userId{
    //COMMENT The new partner will have the highest id (load all the id and found the highest and then plus by one
    NSArray *partnerList = [self getAllPartner];
    NSInteger maxId = 0;
    if([partnerList count] > 0)
    {
        for(int i=0; i<[partnerList count]; i++){
            Partner* entity = [partnerList objectAtIndex:i];
            if([entity.partnerID intValue] > maxId){
                maxId = [entity.partnerID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    //COMMENT Add new partner
    
    Partner* partner = [NSEntityDescription insertNewObjectForEntityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    partner.partnerID = [NSNumber numberWithInt:(maxId + 1)];
    partner.name = name;
    partner.dateOfBirth = dob;
    partner.calendarType = [NSNumber numberWithInt:calendarType];
    partner.sex = [NSNumber numberWithInt:sex];
    partner.userID = [NSNumber numberWithInt:userId];
    partner.lastUsedTime = [NSDate date];
    partner.isNewForCycle = @(YES);
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert partner failed: %@",error);
        return FALSE;
    }
}

/**********************************************************
 @Function description:add new partner for an user
 @Note:
 ***********************************************************/
-(BOOL) createParnerWithName:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet forUserId:(NSInteger) userId{
    //COMMENT The new partner will have the highest id (load all the id and found the highest and then plus by one
    NSArray *partnerList = [self getAllPartner];
    NSInteger maxId = 0;
    if([partnerList count] > 0)
    {
        for(int i=0; i<[partnerList count]; i++){
            Partner* entity = [partnerList objectAtIndex:i];
            if([entity.partnerID intValue] > maxId){
                maxId = [entity.partnerID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    //COMMENT Add new partner
    
    Partner* partner = [NSEntityDescription insertNewObjectForEntityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    partner.partnerID = [NSNumber numberWithInt:(maxId + 1)];
    partner.name = name;
    partner.dateOfBirth = dob;
    partner.calendarType = [NSNumber numberWithInt:calendarType];
    partner.sex = [NSNumber numberWithInt:sex];
    partner.userID = [NSNumber numberWithInt:userId];
    partner.firstDate = firstMeet;
    partner.lastUsedTime = [NSDate date];
    partner.isNewForCycle = @(YES);
    partner.lastMessageUpdate = [NSDate date];
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert partner failed: %@",error);
        return FALSE;
    }
}

- (BOOL)updateFirstTimeUserCycleStatus:(BOOL)status forPartner:(Partner *)partner{
    if(partner){
        partner.isNewForCycle = @(status);
        
        NSError *error;
        if([managedObjectContext save:&error]){
            return YES;
        }
        else{
            DLog(@"update partner cycle status failed: %@",error);
            return NO;
        }
    }
    
    return NO;
}

/**********************************************************
 @Function description: edit partner who have the same id as the given id
 @Note:
***********************************************************/
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex{
    Partner* partner = [self getPartnerById:partnerId];
    if(partner == NULL){
        return FALSE;
    }
    else{
        partner.name = name;
        partner.dateOfBirth = dob;
        partner.calendarType = [NSNumber numberWithInt:calendarType];
        partner.sex = [NSNumber numberWithInt:sex];
        NSError *error;
        if([managedObjectContext save:&error]){
            return TRUE;
        }
        else{
            DLog(@"Edit partner failed: %@",error);
            return FALSE;
        }
    }
}

/**********************************************************
 @Function description: edit partner who have the same id as the given id (with first meet)
 @Note:
 ***********************************************************/
-(BOOL) editParnerWithId:(NSInteger) partnerId name:(NSString*) name dOB:(NSDate*) dob calendarType:(NSInteger) calendarType sex:(NSInteger) sex firstMeet:(NSDate*)firstMeet{
    Partner* partner = [self getPartnerById:partnerId];
    if(partner == NULL){
        return FALSE;
    }
    else{
        partner.name = name;
        partner.dateOfBirth = dob;
        partner.calendarType = [NSNumber numberWithInt:calendarType];
        partner.sex = [NSNumber numberWithInt:sex];
        partner.firstDate = firstMeet;
        NSError *error;
        if([managedObjectContext save:&error]){
            return TRUE;
        }
        else{
            DLog(@"Edit partner failed: %@",error);
            return FALSE;
        }
    }
}

/**********************************************************
 @Function description: Set last used timestamp of the selected partner with the current date
 @Note:
 ***********************************************************/
-(BOOL) setLastUsedTimeWithCurrentDateForPartner:(NSInteger) partnerId{
    Partner* partner = [self getPartnerById:partnerId];
    if(partner == NULL){
        return FALSE;
    }
    else{
        partner.lastUsedTime = [NSDate date];
        
        NSError *error;
        if([managedObjectContext save:&error]){
            DLog(@"Edit partner's time stamp successed");
            return TRUE;
        }
        else{
            DLog(@"Edit partner's time stamp failed: %@",error);
            return FALSE;
        }
    }
}

/**********************************************************
 @Function description: to see if there is any partner with the same name
 @Note: 
 ***********************************************************/
-(BOOL) isPartnerWithSameNameExisted:(NSString *) name forUserId:(NSInteger) userId asideFromPartner:(Partner *)partner{
    Partner *existedPartner = [self getPartnerByName:name forId:userId];
    if(partner == nil){
        if(existedPartner){
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        if(existedPartner && ![existedPartner isEqual:partner]){
            return YES;
        }
        else{
            return NO;
        }
    }
}

/**********************************************************
 @Function description: get all partner in database
 @Note: all partner in database (no user id invole)
 ***********************************************************/
-(NSArray*) getAllPartner{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return partnerList;
}

/**********************************************************
 @Function description: get all partner of a single user
 @Note:only his/her partner
 ***********************************************************/
-(NSArray*) getAllPartnerForUserId:(NSInteger) userId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(userID = %d)", userId];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"partnerID" ascending:YES]]];
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    partnerList = [partnerList sortWithKey:@"lastUsedTime" ascending:YES];
    
    return partnerList;
}

/**********************************************************
 @Function description: get a single partner
 @Note: the one with highest id
 ***********************************************************/
-(Partner*) getOnePartner{
    NSArray *partnerList = [self getAllPartner];
    if([partnerList count] > 0){
        return (Partner*)[partnerList objectAtIndex:([partnerList count] - 1)];
    }else{
        return NULL;
    }
}

/**********************************************************
 @Function description: get a single partner of the given user
 @Note: the one with highest id
 ***********************************************************/
-(Partner*) getOnePartnerForUserId:(NSInteger) userId{
    NSArray *partnerList = [self getAllPartnerForUserId:userId];
    if([partnerList count] > 0){
        return (Partner*)[partnerList objectAtIndex:([partnerList count] - 1)];
    }else{
        return NULL;
    }
}

/**********************************************************
 @Function description: get one partner by Name 
 @Note: if there are more than one partner, the last one will be selected
 ***********************************************************/
-(Partner*) getPartnerByName:(NSString *) name{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", name]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerList count]>0)
        return [partnerList objectAtIndex:([partnerList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get one partner by Name for the given user
 @Note: if there are more than one partner, the last one will be selected
 ***********************************************************/
-(Partner*) getPartnerByName:(NSString *) name forId:(NSInteger) userId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@) AND (userID = %d)", name, userId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerList count]>0)
        return [partnerList objectAtIndex:([partnerList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get one partner by id 
 @Note: if there are more than one partner, the last one will be selected
 ***********************************************************/
-(Partner*) getPartnerById:(NSInteger) partnerId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Partner" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerID = %d)", partnerId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerList count]>0)
        return [partnerList objectAtIndex:([partnerList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get number of partner the current user have
 @Note:
 ***********************************************************/
-(NSInteger) getNumberOfPartnerOfUser:(NSInteger) userId{
    NSArray *partnerList = [self getAllPartnerForUserId:userId];
    if(partnerList)
        return [partnerList count];
    else
        return 0;
}

/**********************************************************
 @Function description: get completation percentage of the setup progress
 @Note:
 ***********************************************************/
-(float) getSetupProgressForPartnerId:(NSInteger) userId{
    Partner *partner = [self getPartnerById:userId];
    if(partner){
        if(partner.setupProgress){
            // COMMENT: split the progressString to get all the id of the steps were done before. Go to each step entity and get it weight to calculate the current percentage
            float progressValue = 0;
            NSArray* setupProgressList = [partner.setupProgress componentsSeparatedByString: @","];
            NSInteger setupProgressListCount = [setupProgressList count];
            for( NSInteger i = 0; i < setupProgressListCount; i++){
                NSString* stepId = [setupProgressList objectAtIndex:i];
                PartnerSetup *step = [self getSetupStepById:[stepId intValue]];
                progressValue += [step.weight floatValue];
            }
            if(progressValue > 100)
                progressValue = 100;
            
            return progressValue;
        }
        else{
            DLog(@"partner setup progress not exist");
            return 0;
        }
    }
    else{
        DLog(@"partner not exist");
        return 0;
    }
}

/**********************************************************
 @Function description: increase setup process value by the given value
 @Note:
 ***********************************************************/
-(void) increaseSetupProfressForPartnerId:(NSInteger) userId byValue:(NSInteger) incrementValue{
    Partner *partner = [self getPartnerById:userId];
    if(partner){
        // COMMENT: if there is no step was done before, simply add new id to the progress string
        if(partner.setupProgress == NULL || [partner.setupProgress isEqualToString:@""]){
            partner.setupProgress = [NSString stringWithFormat:@"%d", incrementValue];
        }
        else{
            // COMMENT: if there are steps which were done before, check to see if this step is one of them. If true, leave without doing anything. If not, update ( remember to add "," character before the new step)
            
            NSArray* setupProgressList = [partner.setupProgress componentsSeparatedByString: @","];
            NSInteger setupProgressListCount = [setupProgressList count];
            for( NSInteger i = 0; i < setupProgressListCount; i++)
            {
                NSString *setupItem = [setupProgressList objectAtIndex:i];
                NSString *incrementValueString = [NSString stringWithFormat:@"%d",incrementValue];
                if([setupItem isEqualToString:incrementValueString])
                {
                    DLog(@"Setup step already done, no need to update process bar");
                    return;
                }
            }
            partner.setupProgress = [NSString stringWithFormat:@"%@,%d", partner.setupProgress, incrementValue];
        }
        
        // COMMENT: save the change
        NSError *error;
        if(![managedObjectContext save:&error]){
            DLog(@"change partner setup progress failed: %@",error);
        }

    }
    else{
        DLog(@"partner not exist, cannot increment setup progress");
    }
}

/**********************************************************
 @Function description: increase setup process value for the selected step
 @Note:
 ***********************************************************/
-(void) increaseSetupProfressForPartnerId:(NSInteger) userId byStepName:(NSString*) stepName{
    Partner *partner = [self getPartnerById:userId];
    if(partner){
        
        // COMMENT: get step id by name
        PartnerSetup *step = [self getSetupStepByName:stepName];
        if(!step){
            DLog(@"step is not exist, cannot increment setup progress");
            return;
        }
        
        // COMMENT: if there is no step was done before, simply add new id to the progress string
        if(partner.setupProgress == NULL || [partner.setupProgress isEqualToString:@""]){
            partner.setupProgress = [NSString stringWithFormat:@"%d", [step.partnerSetupID intValue]];
        }
        else{
            // COMMENT: if there are steps which were done before, check to see if this step is one of them. If true, leave without doing anything. If not, update ( remember to add "," character before the new step)
            
            NSArray* setupProgressList = [partner.setupProgress componentsSeparatedByString: @","];
            NSInteger setupProgressListCount = [setupProgressList count];
            for( NSInteger i = 0; i < setupProgressListCount; i++)
            {
                NSString *setupItem = [setupProgressList objectAtIndex:i];
                NSString *incrementValueString = [NSString stringWithFormat:@"%d",[step.partnerSetupID intValue]];
                if([setupItem isEqualToString:incrementValueString])
                {
                    DLog(@"Setup step already done, no need to update process bar");
                    return;
                }
            }
            partner.setupProgress = [NSString stringWithFormat:@"%@,%d", partner.setupProgress, [step.partnerSetupID intValue]];
        }
        
        // COMMENT: save the change
        NSError *error;
        if(![managedObjectContext save:&error]){
            DLog(@"change partner setup progress failed: %@",error);
        }
        
    }
    else{
        DLog(@"partner not exist, cannot increment setup progress");
    }
}

// Remove a specific partner
- (BOOL)removePartner:(Partner *)partner
{
    if (!partner) {
        return NO;
    }
    [self.managedObjectContext deleteObject:partner];
    [self saveContext];
    return YES;
}

- (BOOL)changeSkinColorForPartner:(Partner *)partner toColor:(UIColor *)color{
    if(color == nil){
        NSLog(@"The color is nil");
        return NO;
    }
    
    partner.skinColor = [color hexStringFromColor];
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"Edit partner skin color failed: %@",error);
        return FALSE;
    }
}

- (BOOL)changeEyeColorForPartner:(Partner *)partner toColor:(UIColor *)color{
    if(color == nil){
        NSLog(@"The color is nil");
        return NO;
    }
    
    partner.eyeColor = [color hexStringFromColor];
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"Edit partner eye color failed: %@",error);
        return FALSE;
    }
}



- (BOOL)changeHairColorForPartner:(Partner *)partner toColor:(UIColor *)color{
    if(color == nil){
        NSLog(@"The color is nil");
        return NO;
    }
    
    ItemCategory *shoeCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
    if(shoeCategory){
        ItemToAvatar *partnerHair = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:shoeCategory];
        if(partnerHair){
            partnerHair.color = [color hexStringFromColor];
        }
    }
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"Edit partner hair color failed: %@",error);
        return FALSE;
    }
}

- (BOOL)changeBeardColorForPartner:(Partner *)partner toColor:(UIColor *)color{
    if(color == nil){
        NSLog(@"The color is nil");
        return NO;
    }
    
    ItemCategory *beardCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
    if(beardCategory){
        ItemToAvatar *partnerHair = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:beardCategory];
        if(partnerHair){
            partnerHair.color = [color hexStringFromColor];
        }
    }
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"Edit partner hair color failed: %@",error);
        return FALSE;
    }
}


/**********************************************************
 @Function description: get all information of the selected partner
 @Note:
 ***********************************************************/
-(PartnerInformation*) getPartnerInformationByParnerId:(NSInteger) partnerId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerInformation" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerID = %d)", partnerId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerList count]>0)
        return [partnerList objectAtIndex:([partnerList count] - 1)];
    else
        return NULL;
}

#pragma mark - menstration and fertle
/**********************************************************
 @Function description: check if the current day is partner fertile day or not
 @Note:
 ***********************************************************/
-(BOOL) isPartner:(Partner *) partner haveFertileInDate:(NSDate *)date{
    if(!partner){
        return NO;
    }
    
    // cannot show icon at day before last period date
    if([partner.lastPeriod isAfterDate:date]){
        return NO;
    }
    
    // cannot show icon at day after last period date 4 months
    if([date isAfterDate:[partner.lastPeriod dateByAddMonth:4]]){
        return NO;
    }
    
    if (partner.lastPeriod) {
        //--------------------------------------old algorithm to calculate
//        // Details: http://www.americanpregnancy.org/gettingpregnant/ovulationcalendar.html
//        
//        NSInteger days = [partner.lastPeriod daysBetweenDate:date];
//        NSInteger period = partner.birthControl.boolValue?PERIOD_USING_BIRTH_CONTROL:PERIOD_WITHOUT_USING_BIRTH_CONTROL;
//        if ([date isSameDay:partner.lastPeriod]) {
//            return YES;
//        }
//        if (days >= period && days % period == 0) {
//            return YES;
//        }
        
        //-------------------------------------- new algorithm
        NSInteger days = [partner.lastPeriod daysBetweenDate:date];
        NSInteger daysInCycle = (days % 28);
        if(daysInCycle >= 13 && daysInCycle <= 18){
            return YES;
        }
        else{
            return NO;
        }
    }
    
    return NO;
}

/**********************************************************
 @Function description: check if the current day is partner menstration day or not
 @Note:
 ***********************************************************/
-(BOOL) isPartner:(Partner *) partner haveMenstrationInDate:(NSDate *)date{
    if(!partner){
        return NO;
    }
    
    // cannot show icon at day before last period date
    if([partner.lastPeriod isAfterDate:date]){
        return NO;
    }
    
    // cannot show icon at day after last period date 4 months
    if([date isAfterDate:[partner.lastPeriod dateByAddMonth:4]]){
        return NO;
    }
    
    if (partner.lastPeriod) {
        //--------------------------------------old algorithm to calculate
//        // Details: http://www.americanpregnancy.org/gettingpregnant/ovulationcalendar.html
//        NSDate *firstDayOfCurrentPeriod = date;
//        NSInteger period = partner.birthControl.boolValue?PERIOD_USING_BIRTH_CONTROL:PERIOD_WITHOUT_USING_BIRTH_CONTROL;
//        
//        while (YES) {
//            NSInteger days = [firstDayOfCurrentPeriod daysBetweenDate:partner.lastPeriod];
//            if (days % period == 0) {
//                break;
//            }
//            firstDayOfCurrentPeriod = [firstDayOfCurrentPeriod dateByAddingDays:-1];
//        }
//        NSInteger offset = [firstDayOfCurrentPeriod daysBetweenDate:date];
//        int distance = partner.birthControl.boolValue?12:10;
//        if (offset >= distance && offset <= distance + 10) {
//            return YES;
//        }
        
        //-------------------------------------- new algorithm
        NSInteger days = [partner.lastPeriod daysBetweenDate:date];
        NSInteger daysInCycle = (days % 28);
        if(daysInCycle >= 0 && daysInCycle <= 4){
            return YES;
        }
        else{
            return NO;
        }
    }
    
    return NO;
}

-(BOOL) isPartner:(Partner *) partner haveSensitiveInDate:(NSDate *)date{
    if(!partner){
        return NO;
    }
    
    // cannot show icon at day before last period date
    if([partner.lastPeriod isAfterDate:date]){
        return NO;
    }
    
    // cannot show icon at day after last period date 4 months
    if([date isAfterDate:[partner.lastPeriod dateByAddMonth:4]]){
        return NO;
    }
    
    if (partner.lastPeriod) {
        NSInteger days = [partner.lastPeriod daysBetweenDate:date];
        NSInteger daysInCycle = (days % 28);
        if(daysInCycle >= 22 && daysInCycle <= 27){
            return YES;
        }
        else{
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - color
/**********************************************************
 @Function description:generate color item when the application run for the first time
 @Note:
 ***********************************************************/
-(void) initColorData{
    NSArray *allColor = [self getAllColor];
    if([allColor count] <= 0)
    {
        //COMMENT: Hair color
        [self addColorWithHexString:@"#0090fd" andName:@"Blue"];
        [self addColorWithHexString:@"#ffed71" andName:@"Yellow"];
        [self addColorWithHexString:@"#978f62" andName:@"Yellow Gray"];
        [self addColorWithHexString:@"#942017" andName:@"Red Darken"];
        
        //COMMENT: Eye color
        [self addColorWithHexString:@"#65330c" andName:@"Orange Darken"];
        [self addColorWithHexString:@"#255b01" andName:@"Green Draken"];
        [self addColorWithHexString:@"#003e63" andName:@"Blue Draken"];
        [self addColorWithHexString:@"#0074fc" andName:@"Blue"];
        [self addColorWithHexString:@"#8396fc" andName:@"Light Blue"];
        
        //COMMENT: Skin color
        [self addColorWithHexString:@"#973916" andName:@"Red Darken"];
        [self addColorWithHexString:@"#64320b" andName:@"Chocolate"];
        [self addColorWithHexString:@"#ffc36e" andName:@"Orange"];
        [self addColorWithHexString:@"#fad0ce" andName:@"Pink"];
        [self addColorWithHexString:@"#ffffff" andName:@"White"];
    }
}

/**********************************************************
 @Function description:add new color to database
 @Note:color is saved with hex format
 ***********************************************************/
-(BOOL) addColorWithHexString:(NSString*) hexString andName:(NSString*) name{
    // COMMENT: get the highest id and plus one to give to the new entity
    NSArray *colorList = [self getAllColor];
    NSInteger maxId = 0;
    if([colorList count] > 0)
    {
        for(int i=0; i<[colorList count]; i++){
            Color* entity = [colorList objectAtIndex:i];
            if([entity.colorID intValue] > maxId){
                maxId = [entity.colorID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    // COMMENT: add new entity
    Color* color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:managedObjectContext];
    color.colorID = [NSNumber numberWithInt:(maxId + 1)];
    color.name = name;
    color.colorCode = hexString;
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert color failed: %@",error);
        return FALSE;
    }

}

/**********************************************************
 @Function description: get all color in the database
 @Note:
***********************************************************/
-(NSArray*) getAllColor{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return colorList;
}

/**********************************************************
 @Function description: get all color for hair in the database (from index 0 to 3)
 @Note:
 ***********************************************************/
-(NSArray*) getAllColorForHair{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    [request setFetchLimit:4];
    [request setFetchOffset:0];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return colorList;
}

/**********************************************************
 @Function description: get all color for eye in the database (from index 4 to 9)
 @Note:
 ***********************************************************/
-(NSArray*) getAllColorForEye{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    [request setFetchLimit:5];
    [request setFetchOffset:4];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return colorList;
}

/**********************************************************
 @Function description: get all color for skin in the database (from index 10 to 14)
 @Note:
 ***********************************************************/
-(NSArray*) getAllColorForSkin{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    [request setFetchLimit:5];
    [request setFetchOffset:9];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return colorList;
}

/**********************************************************
 @Function description: get color by id
 @Note:
 ***********************************************************/
-(Color*) getColorWithId:(NSInteger)colorId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(colorID = %d)", colorId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([colorList count]>0)
        return [colorList objectAtIndex:([colorList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get color whose code is match with the given string
 @Note:
 ***********************************************************/
-(Color*) getColorWithCode:(NSString*)colorCode{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Color" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(colorCode = %@)", colorCode]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *colorList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([colorList count]>0)
        return [colorList objectAtIndex:([colorList count] - 1)];
    else
        return NULL;
}

#pragma mark - add partner avatar
/**********************************************************
 @Function description: add avatar for a partner
 @Note:
 ***********************************************************/
-(BOOL) addPartnerAvatarForPartnerId:(NSInteger) partnerId{
    // COMMENT: check if partner is exist or not
    Partner *partner = [self getPartnerById:partnerId];
    if(partner){
        // COMMENT: get the highest id
        NSArray *avatarList = [self getAllAvatar];
        NSInteger maxId = 0;
        if([avatarList count] > 0)
        {
            for(int i=0; i<[avatarList count]; i++){
                PartnerAvatar* entity = [avatarList objectAtIndex:i];
                if([entity.partnerAvatarID intValue] > maxId){
                    maxId = [entity.partnerAvatarID intValue];
                }
            }
        }
        else{
            maxId = 0;
        }
        
        // COMMENT: add new avatar and asign for this partner
        PartnerAvatar* avatar = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerAvatar" inManagedObjectContext:managedObjectContext];
        avatar.partnerAvatarID = [NSNumber numberWithInt:(maxId + 1)];
        avatar.partnerID = [NSNumber numberWithInt:partnerId];
        NSError *error;
        if([managedObjectContext save:&error]){
            return TRUE;
        }
        else{
            DLog(@"insert partner avatar failed: %@",error);
            return FALSE;
        }

    }
    else{
        DLog(@"Partner not exist! Cannot add avatar");
        return false;
    }
}

/**********************************************************
 @Function description: get all avatar in database
 @Note:
***********************************************************/
-(NSArray*) getAllAvatar{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerAvatar" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *avatarList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return avatarList;
}

/**********************************************************
 @Function description: get avatar of the selected partner
 @Note:
***********************************************************/
-(PartnerAvatar*) getPartnerAvatarByPartnerId:(NSInteger) partnerId addIfNotExist:(BOOL) flag{
    // COMMENT: check if partner is existed or not
    Partner *partner = [self getPartnerById:partnerId];
    if(partner){
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerAvatar" inManagedObjectContext:managedObjectContext];
        [request setEntity:description];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerID = %d)", partnerId]; 
        [request setPredicate: pred];
        NSError *error;
        NSArray *avatarList = [managedObjectContext executeFetchRequest:request error:&error];
        
        [request release];
        
        // COMMENT: check if avatar for that partner is existed or not, if not, create a new one and then assign to that partner
        if([avatarList count]>0)
        {
            PartnerAvatar* avatar = (PartnerAvatar* )[avatarList objectAtIndex:([avatarList count] - 1)];
            return avatar;
        }
        else{
            if(flag)
            {
                [self addPartnerAvatarForPartnerId:partnerId];
                return [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:!flag];
            }
            else{
                DLog(@"Partner avatar not exist! flag set to false");
                return NULL;
            }
        }
    }
    else{
        DLog(@"Partner not exist! Cannot get avatar");
        return NULL;
    }
}
/**********************************************************
 @Function description: update hair color for an avatar
 @Note:if the avatar's hair is existed yet, create new one and then add new color to it
***********************************************************/
-(BOOL) updateAvatarHairWithColor:(Color*) color forPartnerId:(NSInteger) partnerId{
    // COMMENT: check if avatar is existed or not
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:YES];
    if(avatar){
        // COMMENT: check if the current avatar has a hair attached to it or not (create new hair entity for this avatar if not)
        if(avatar.hairID != NULL && [avatar.hairID intValue] > 0){
            BOOL editResult = [self editHairWithId:[avatar.hairID intValue] WithColor:color];
            if(editResult){
                DLog(@"Edit hair color success!");
                return TRUE;
            }
            else{
                DLog(@"Edit hair color failed!");
                return FALSE;
            }
        }
        else{
            NSInteger hairId = [self addHairWithColor:color];
            avatar.hairID = [NSNumber numberWithInt:hairId];
            NSError *error;
            if([managedObjectContext save:&error]){
                DLog(@"Edit(add) hair color success!");
                return TRUE;
            }
            else{
                DLog(@"edit hair color failed: %@",error);
                return FALSE;
            }
        }
    }
    else{
        DLog(@"Avatar not exist. Cannot edit hair");
        return FALSE;
    }
}

/**********************************************************
 @Function description: get hair color for an avatar (using partner id)
 @Note:if the avatar's hair is existed yet, create new one and then add new color to it
 ***********************************************************/
-(NSString*) getAvatarHairColorForPartnerId:(NSInteger) partnerId{
    // COMMENT: check if avatar is existed or not
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:NO];
    if(avatar){
        // COMMENT: check if avatar's hair is existed or not (return null if not)
        Hair* hair = [self getHairWithId:[avatar.hairID intValue]];
        if(hair){
            Color* color = [self getColorWithId:[hair.colorID intValue]];
            if(color){
                DLog(@"Successfully get hair color!");
                return color.colorCode;
            }
            else{
                DLog(@"partner hair color not exist! cannot get hair color!");
                return NULL;
            }
        }
        else{
            DLog(@"partner hair not exist! cannot get hair color!");
            return NULL;
        }
    }
    else {
        DLog(@"partner avatar not exist! cannot get hair color!");
        return NULL;
    }
}

-(BOOL) updateAvatarEyeWithColor:(Color*) color forPartnerId:(NSInteger) partnerId{
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:YES];
    if(avatar){
        if(avatar.eyeID != NULL && [avatar.eyeID intValue] > 0){
            BOOL editResult = [self editEyeWithId:[avatar.eyeID intValue] WithColor:color];
            if(editResult){
                DLog(@"Edit eye color success!");
                return TRUE;
            }
            else{
                DLog(@"Edit eye color failed!");
                return FALSE;
            }
        }
        else{
            NSInteger eyeId = [self addEyeWithColor:color];
            avatar.eyeID = [NSNumber numberWithInt:eyeId];
            NSError *error;
            if([managedObjectContext save:&error]){
                DLog(@"Edit(add) eye color success!");
                return TRUE;
            }
            else{
                DLog(@"edit eye color failed: %@",error);
                return FALSE;
            }
        }
    }
    else{
        DLog(@"Avatar not exist. Cannot edit eye");
        return FALSE;
    }
}

/**********************************************************
 @Function description: update eye color for an avatar
 @Note:if the avatar's eye is existed yet, create new one and then add new color to it
 ***********************************************************/
-(NSString*) getAvatarEyeColorForPartnerId:(NSInteger) partnerId{
    // COMMENT: check if avatar is existed or not
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:NO];
    if(avatar){
        Eye* eye = [self getEyeWithId:[avatar.eyeID intValue]];
        // COMMENT: check if avatar's eye is existed or not
        if(eye){
            Color* color = [self getColorWithId:[eye.colorID intValue]];
            if(color){
                DLog(@"Successfully get eye color!");
                return color.colorCode;
            }
            else{
                DLog(@"partner eye color not exist! cannot get eye color!");
                return NULL;
            }
        }
        else{
            DLog(@"partner eye not exist! cannot get eye color!");
            return NULL;
        }
    }
    else {
        DLog(@"Partner avatar not exist! cannot get eye color!");
        return NULL;
    }
}

/**********************************************************
 @Function description: update skin color for an avatar
 @Note:if the avatar's skin is existed yet, create new one and then add new color to it
 ***********************************************************/
-(BOOL) updateAvatarSkinWithColor:(Color*) color forPartnerId:(NSInteger) partnerId{
    // COMMENT: check if avatar is existed or not
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:YES];
    if(avatar){
        // COMMENT: check if avatar's eye is existed or not
        if(avatar.skinID != NULL && [avatar.skinID intValue] > 0){
            BOOL editResult = [self editSkinWithId:[avatar.skinID intValue] WithColor:color];
            if(editResult){
                DLog(@"Edit skin color success!");
                return TRUE;
            }
            else{
                DLog(@"Edit skin color failed!");
                return FALSE;
            }
        }
        else{
            NSInteger skinId = [self addSkinWithColor:color];
            avatar.skinID = [NSNumber numberWithInt:skinId];
            NSError *error;
            if([managedObjectContext save:&error]){
                DLog(@"Edit(add) skin color success!");
                return TRUE;
            }
            else{
                DLog(@"Edit skin color failed: %@",error);
                return FALSE;
            }
        }
    }
    else{
        DLog(@"Avatar not exist. Cannot edit eye");
        return FALSE;
    }
}

/**********************************************************
 @Function description: get skin color of the selected avatar
 @Note:
***********************************************************/
-(NSString*) getAvatarSkinColorForPartnerId:(NSInteger) partnerId{
    // COMMENT: check if avatar is existed or not
    PartnerAvatar* avatar = [self getPartnerAvatarByPartnerId:partnerId addIfNotExist:NO];
    if(avatar){
        // COMMENT: check if skin is existed or not
        Skin* skin = [self getSkinWithId:[avatar.skinID intValue]];
        if(skin){
            Color* color = [self getColorWithId:[skin.colorID intValue]];
            if(color){
                DLog(@"Successfully get skin color!");
                return color.colorCode;
            }
            else{
                DLog(@"partner skin color not exist! cannot get skin color!");
                return NULL;
            }
        }
        else{
            DLog(@"partner skin not exist! cannot get skin color!");
            return NULL;
        }
    }
    else {
        DLog(@"partner avatar not exist! cannot get skin color!");
        return NULL;
    }
}

#pragma mark - hair
/**********************************************************
 @Function description: create new hair with color
 @Note:
 ***********************************************************/
-(NSInteger) addHairWithColor:(Color*) color{
    // COMMENT: get the highest id
    NSArray *hairList = [self getAllHair];
    NSInteger maxId = 0;
    if([hairList count] > 0)
    {
        for(int i=0; i<[hairList count]; i++){
            Hair* entity = [hairList objectAtIndex:i];
            if([entity.hairID intValue] > maxId){
                maxId = [entity.hairID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    // COMMENT: add new entity
    Hair* hair = [NSEntityDescription insertNewObjectForEntityForName:@"Hair" inManagedObjectContext:managedObjectContext];
    hair.hairID = [NSNumber numberWithInt:(maxId + 1)];
    hair.colorID = color.colorID;
    NSError *error;
    if([managedObjectContext save:&error]){
        return [hair.hairID intValue];
    }
    else{
        DLog(@"insert hair failed: %@",error);
        return 0;
    }
}

/**********************************************************
 @Function description: change color of an entity in the hair table
 @Note:
 ***********************************************************/
-(BOOL) editHairWithId:(NSInteger)hairId WithColor:(Color*) color{
    Hair* hair = [self getHairWithId:hairId];
    if(hair){
        hair.colorID = color.colorID;
        NSError *error;
        if([managedObjectContext save:&error]){
            return YES;
        }
        else{
            DLog(@"edit hair failed: %@",error);
            return 0;
        }
    }
    else{
        DLog(@"Hair for this id not exist, cannot edit hair");
        return FALSE;
    }
}

/**********************************************************
 @Function description: get hair by its id
 @Note:
 ***********************************************************/
-(Hair*) getHairWithId:(NSInteger)hairId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Hair" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(hairID = %d)", hairId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *hairList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([hairList count]>0)
        return [hairList objectAtIndex:([hairList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get all hair in the hair table
 @Note:
 ***********************************************************/
-(NSArray*) getAllHair{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Hair" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *avatarList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return avatarList;
}

#pragma mark - eye
/**********************************************************
 @Function description: add new eye with color
 @Note:
 ***********************************************************/
-(NSInteger) addEyeWithColor:(Color*) color{
    // COMMENT: get the highest id
    NSArray *eyeList = [self getAllEye];
    NSInteger maxId = 0;
    if([eyeList count] > 0)
    {
        for(int i=0; i<[eyeList count]; i++){
            Eye* entity = [eyeList objectAtIndex:i];
            if([entity.eyeID intValue] > maxId){
                maxId = [entity.eyeID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    // COMMENT: add new entity
    Eye* eye = [NSEntityDescription insertNewObjectForEntityForName:@"Eye" inManagedObjectContext:managedObjectContext];
    eye.eyeID = [NSNumber numberWithInt:(maxId + 1)];
    eye.colorID = color.colorID;
    NSError *error;
    if([managedObjectContext save:&error]){
        return [eye.eyeID intValue];
    }
    else{
        DLog(@"insert eye failed: %@",error);
        return 0;
    }
}

/**********************************************************
 @Function description: change color of partner's eye
 @Note:
***********************************************************/
-(BOOL) editEyeWithId:(NSInteger)eyeId WithColor:(Color*) color{
    Eye* eye = [self getEyeWithId:eyeId];
    if(eye){
        eye.colorID = color.colorID;
        NSError *error;
        if([managedObjectContext save:&error]){
            return YES;
        }
        else{
            DLog(@"edit eye failed: %@",error);
            return 0;
        }
    }
    else{
        DLog(@"Eye for this id not exist, cannot edit eye");
        return FALSE;
    }

}

/**********************************************************
 @Function description: get eye by id
 @Note:
 ***********************************************************/
-(Eye*) getEyeWithId:(NSInteger)eyeId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Eye" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(eyeID = %d)", eyeId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *eyeList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([eyeList count]>0)
        return [eyeList objectAtIndex:([eyeList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get all eye in the table (don't have to belong to a specific avatar)
 @Note:
 ***********************************************************/
-(NSArray*) getAllEye{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Eye" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *eyeList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return eyeList;
}

#pragma mark - skin
/**********************************************************
 @Function description: add skin with a given color
 @Note:
 ***********************************************************/
-(NSInteger) addSkinWithColor:(Color*) color{
    NSArray *skinList = [self getAllSkin];
    NSInteger maxId = 0;
    if([skinList count] > 0)
    {
        for(int i=0; i<[skinList count]; i++){
            Skin* entity = [skinList objectAtIndex:i];
            if([entity.skinID intValue] > maxId){
                maxId = [entity.skinID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    Skin* skin = [NSEntityDescription insertNewObjectForEntityForName:@"Skin" inManagedObjectContext:managedObjectContext];
    skin.skinID = [NSNumber numberWithInt:(maxId + 1)];
    skin.colorID = color.colorID;
    NSError *error;
    if([managedObjectContext save:&error]){
        return [skin.skinID intValue];
    }
    else{
        DLog(@"insert skin failed: %@",error);
        return 0;
    }
}

/**********************************************************
 @Function description: change color of a partner's skin
 @Note:
 ***********************************************************/
-(BOOL) editSkinWithId:(NSInteger)skinId WithColor:(Color*) color{
    Skin* skin = [self getSkinWithId:skinId];
    if(skin){
        skin.colorID = color.colorID;
        NSError *error;
        if([managedObjectContext save:&error]){
            return YES;
        }
        else{
            DLog(@"edit skin failed: %@",error);
            return 0;
        }
    }
    else{
        DLog(@"Skin for this id not exist, cannot edit eye");
        return FALSE;
    }

}

/**********************************************************
 @Function description: get skin by its id
 @Note:
 ***********************************************************/
-(Skin*) getSkinWithId:(NSInteger)skinId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Skin" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(skinID = %d)", skinId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *skinList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([skinList count]>0)
        return [skinList objectAtIndex:([skinList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get all entity in the skin's table
 @Note:
 ***********************************************************/
-(NSArray*) getAllSkin{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Skin" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *skinList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return skinList;
}

#pragma mark - partner event
- (NSArray*) createBirthdayEventsForPartner:(Partner *) partner{
    [self deleteEventsWithType:MANAPP_EVENT_TYPE_BIRTHDAY forPartner:partner];
    
    if(partner.dateOfBirth && partner != nil){
        NSMutableArray *events = [[[NSMutableArray alloc] init] autorelease];
        
        NSDate *startTime = partner.dateOfBirth;
        NSDate *endTime = [partner.dateOfBirth dateByAddingYears:kRepeatYear];
        
        while ([startTime compare:endTime] != NSOrderedDescending) {
            Event* partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            if (partnerEvent == nil){
                DLog(@"Failed to create the new PartnerEvent.");
                return events;
            }
            partnerEvent.eventID = [NSString generateGUID];
            partnerEvent.eventName = [NSString stringWithFormat:@"Happy birthday %@",partner.name];
            partnerEvent.eventTime = startTime;
            partnerEvent.eventEndTime = [startTime dateByAddDays:1];
            partnerEvent.finishTime = [startTime dateByAddDays:1];
            partnerEvent.note = [NSString stringWithFormat:@"Happy birthday %@",partner.name];;
            partnerEvent.partner = partner;
            partnerEvent.recurrence = nil;
            partnerEvent.reminder = nil;
            partnerEvent.recurringID = @"";
            partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_BIRTHDAY];
            startTime = [startTime dateByAddingYears:1];
            
            NSError *savingError = nil;
            if ([self.managedObjectContext save:&savingError]){
                [events addObject:partnerEvent];
            } else {
                DLog(@"Failed to save the new Partner First Meet event. Error = %@", savingError);
            }
        }
        
        return events;
    }
    
    return nil;
}

- (NSArray*) createFirstMeetEventsForPartner:(Partner *) partner{
    [self deleteEventsWithType:MANAPP_EVENT_TYPE_FIRSTMEET forPartner:partner];
    
    if(partner.firstDate && partner != nil){
        NSMutableArray *events = [[[NSMutableArray alloc] init] autorelease];
        
        NSDate *startTime = partner.firstDate;
        NSDate *endTime = [partner.firstDate dateByAddingYears:kRepeatYear];
        
        while ([startTime compare:endTime] != NSOrderedDescending) {
            Event* partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            if (partnerEvent == nil){
                DLog(@"Failed to create the new PartnerEvent.");
                return events;
            }
            partnerEvent.eventID = [NSString generateGUID];
            partnerEvent.eventName = [NSString stringWithFormat:@"First date commemorated %@",partner.name];
            partnerEvent.eventTime = startTime;
            partnerEvent.eventEndTime = [startTime dateByAddDays:1];
            partnerEvent.finishTime = [startTime dateByAddDays:1];
            partnerEvent.note = [NSString stringWithFormat:@"First date commemorated %@",partner.name];;
            partnerEvent.partner = partner;
            partnerEvent.recurrence = nil;
            partnerEvent.reminder = nil;
            partnerEvent.recurringID = @"";
            partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_FIRSTMEET];
            startTime = [startTime dateByAddingYears:1];
            
            NSError *savingError = nil;
            if ([self.managedObjectContext save:&savingError]){
                [events addObject:partnerEvent];
            } else {
                DLog(@"Failed to save the new Partner birthday event. Error = %@", savingError);
            }
        }
        
        return events;
    }
    
    return nil;
}


//add new event
- (NSArray*) createNewPartnerEventWithEventName:(NSString *)eventName andEventTime:(NSDate *)eventTime endDate:(NSDate*)endDate andNote: (NSString *)note andPartnerId:(NSInteger)partnerId andRecurrence: (NSString *)recurrence andReminder: (NSString *)reminder finishTime:(NSDate *)finishTime
{
    if (!endDate) {
        endDate = finishTime;
    }
    NSMutableArray *events = [[[NSMutableArray alloc] init] autorelease];
    Partner *selectedPartner = [[DatabaseHelper sharedHelper] getPartnerById:partnerId];
    if(selectedPartner)
    {
        Event* partnerEvent = nil;
        if (recurrence.length > 0 && ![recurrence isEqualToString:MANAPP_EVENT_RECURRING_NEVER]) {
            NSDate *startTime = eventTime;
            // edit by repeat events
//            NSDate *endTime = endDate;
            NSString *recurringID = [NSString generateGUID];
            NSInteger recurringDay = [startTime dateInformation].day;
            // edit by repeat events
//            while (1) {
                if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                    partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                    if (partnerEvent == nil){
                        DLog(@"Failed to create the new PartnerEvent.");
                        return Nil;
                    }
                    partnerEvent.eventID = [NSString generateGUID];
                    partnerEvent.eventName = eventName;
                    partnerEvent.eventTime = startTime;
                    partnerEvent.eventEndTime = endDate;
                    partnerEvent.finishTime = finishTime;
                    partnerEvent.note = note;
                    //partnerEvent.userID = [NSNumber numberWithUnsignedInteger:userId];
                    partnerEvent.partner = selectedPartner;
                    partnerEvent.recurrence = recurrence;
                    partnerEvent.reminder = reminder;
                    partnerEvent.recurringID = recurringID;
                    partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
                    startTime = [startTime dateByAddingDays:1];
                    [events addObject:partnerEvent];
                } else if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                    partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                    if (partnerEvent == nil){
                        DLog(@"Failed to create the new PartnerEvent.");
                        return Nil;
                    }
                    partnerEvent.eventID = [NSString generateGUID];
                    partnerEvent.eventName = eventName;
                    partnerEvent.eventTime = startTime;
                    partnerEvent.eventEndTime = endDate;
                    partnerEvent.finishTime = finishTime;
                    partnerEvent.note = note;
                    partnerEvent.partner = selectedPartner;
                    partnerEvent.recurrence = recurrence;
                    partnerEvent.reminder = reminder;
                    partnerEvent.recurringID = recurringID;
                    partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
                    startTime = [startTime dateByAddingDays:7];
                    [events addObject:partnerEvent];
                } else if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                    TKDateInformation info = [startTime dateInformation];
                    if (info.day == recurringDay) {
                        partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                        if (partnerEvent == nil){
                            DLog(@"Failed to create the new PartnerEvent.");
                            return Nil;
                        }
                        partnerEvent.eventID = [NSString generateGUID];
                        partnerEvent.eventName = eventName;
                        partnerEvent.eventEndTime = endDate;
                        partnerEvent.finishTime = finishTime;
                        partnerEvent.eventTime = startTime;
                        partnerEvent.note = note;
                        partnerEvent.partner = selectedPartner;
                        partnerEvent.recurrence = recurrence;
                        partnerEvent.reminder = reminder;
                        partnerEvent.recurringID = recurringID;
                        partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
                        [events addObject:partnerEvent];
                    }
                    startTime = [startTime dateByAddingDays:1];
                }
                else if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                    TKDateInformation info = [startTime dateInformation];
                    if (info.day == recurringDay) {
                        partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                        if (partnerEvent == nil){
                            DLog(@"Failed to create the new PartnerEvent.");
                            return Nil;
                        }
                        partnerEvent.eventID = [NSString generateGUID];
                        partnerEvent.eventName = eventName;
                        partnerEvent.eventEndTime = endDate;
                        partnerEvent.finishTime = finishTime;
                        partnerEvent.eventTime = startTime;
                        partnerEvent.note = note;
                        partnerEvent.partner = selectedPartner;
                        partnerEvent.recurrence = recurrence;
                        partnerEvent.reminder = reminder;
                        partnerEvent.recurringID = recurringID;
                        partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
                        [events addObject:partnerEvent];
                    }
                    startTime = [startTime dateByAddingYears:1];
                }
            // edit by repeat events
//                if ([startTime compare:endTime] == NSOrderedDescending) {
//                    break;
//                }
//            }//end while
        } else {
            partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            if (partnerEvent == nil){
                DLog(@"Failed to create the new PartnerEvent.");
                return nil;
            }
            partnerEvent.eventID = [NSString generateGUID];
            partnerEvent.eventName = eventName;
            partnerEvent.eventTime = eventTime;
            partnerEvent.eventEndTime = endDate;
            partnerEvent.finishTime = finishTime;
            partnerEvent.note = note;
            partnerEvent.partner = selectedPartner;
            partnerEvent.recurrence = recurrence;
            partnerEvent.reminder = reminder;
            partnerEvent.recurringID = @"";
            partnerEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
            [events addObject:partnerEvent];
        }
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){ 
            return events;
        } else {
            DLog(@"Failed to save the new PartnerEvent. Error = %@", savingError); 
        }
        return nil;
    }
    return nil;
}

-(void) deleteEventsWithType:(NSInteger) type forPartner:(Partner *) partner{
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:@"Event" withPredicate:[NSPredicate predicateWithFormat:@"(type = %d) and (partner.partnerID = %d)", type,partner.partnerID.integerValue] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    for (Event *event in arr) {
        [self.managedObjectContext deleteObject:event];
        [self saveContext];
    }
}

- (void) deletePartnerEventDataWithIndex: (NSInteger)index{
    NSArray *arr = [[[NSArray alloc] initWithArray:[self getAllEvent]] autorelease];
    DLog(@"array = %@", arr);
    // COMMENT:  Make sure we get the array
    if ([arr count] > 0){
        
        // COMMENT:  Delete the person in the array
        Event *event = [arr objectAtIndex:index];
        [self.managedObjectContext deleteObject:event];
        if ([event isDeleted]){
            DLog(@"Successfully deleted the event...");
            NSError *savingError = nil;
            if ([self.managedObjectContext save:&savingError]){
                DLog(@"Successfully Saved!"); 
            } else {
                DLog(@"Failed to save the context."); 
            }
            [savingError release];
        } else {
            DLog(@"Failed to delete the event.");
        }
    } 
}

/**********************************************************
 @Function description: get all event entity
 @Note:
***********************************************************/
-(NSArray*) getAllEvent{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return eventList;
}

/**********************************************************
 @Function description: get all event for a partner
 @Note:
***********************************************************/
-(NSArray*) getAllEventForPartner:(NSInteger)partnerId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"eventTime" ascending:YES]]];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d)", partnerId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return eventList;
}

/**********************************************************
 @Function description: get event happen at a specific date and for a selected partner
 @Note:
 ***********************************************************/
-(NSArray*) getAllEventOccurAtDate:(NSDate*)date forPartner:(NSInteger) partnerId{
    NSDate *startDate = date;
    NSDate *endDate = [startDate dateByAddDays:1];
    endDate = [endDate dateByAddSecond:-1];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (eventTime >= %@) AND (eventTime <= %@)", partnerId,startDate,endDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    eventList = [eventList sortWithKey:@"eventTime" ascending:YES];
    
    return eventList;
}

- (NSArray*)getAllOccurEventFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId {
    toDate = [[toDate dateByAddingDays:1] dateByAddSecond:-1];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)))", partnerId, fromDate, toDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *nonRepeatArr = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    DLogInfo(@"count = %d", nonRepeatArr.count);
    
    NSMutableArray *retVal = [NSMutableArray array];
    NSDate *dateStart = fromDate;
        while(YES){
            NSInteger numberOfEvents = 0;
            
            for (Event *eventObj in nonRepeatArr) {
                DLogInfo(@"eventObj = %@", eventObj);
                if ([dateStart isSameDay:eventObj.eventTime]) {
                    DLogWarning(@"date = %@ - event = %@", dateStart, eventObj);
                    numberOfEvents++;
                }
                if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                    if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && ![dateStart isAfterDate:eventObj.eventEndTime]) {
                        DLogInfo(@"date = %@ - event = %@", dateStart, eventObj);
                        numberOfEvents ++;
                    }
                }
                else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                    if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && [dateStart daysBetweenDate:eventObj.eventTime] % 7 == 0  && ![dateStart isAfterDate:eventObj.eventEndTime]){
                        DLogInfo(@"date = %@ - event = %@", dateStart, eventObj);
                        numberOfEvents ++;
                    }
                }
                else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                    if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                        [dateStart getDay] == [eventObj.eventTime getDay]  &&
                        ![dateStart isAfterDate:eventObj.eventEndTime]) {
                        DLogInfo(@"date = %@ - event = %@", dateStart, eventObj);
                        numberOfEvents ++;
                    }
                }
                else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                    if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                        [dateStart getDay] == [eventObj.eventTime getDay]  &&
                        [dateStart getMonth] == [eventObj.eventTime getMonth]  &&
                        ![dateStart isAfterDate:eventObj.eventEndTime]) {
                        DLogInfo(@"date = %@ - event = %@", dateStart, eventObj);
                        numberOfEvents ++;
                    }
                }
                
            }
            
            [retVal addObject:[NSNumber numberWithInt:numberOfEvents]];
            TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
            info.day++;
            dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
            
            // COMMENT: if the current day is the last date, break from the loop
            if([dateStart compare:toDate]==NSOrderedDescending) break;
        }
    return retVal;
}

- (NSArray*)getAllListEventTimeOccurFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId {
    toDate = [[toDate dateByAddingDays:1] dateByAddSecond:-1];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)))", partnerId, fromDate, toDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *nonRepeatArr = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    DLogInfo(@"nonRepeatArr count = %d", nonRepeatArr.count);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    NSDate *dateStart = fromDate;
    while(YES){
        NSMutableArray *eventOnDay = [NSMutableArray array];
        for (Event *eventObj in nonRepeatArr) {
            Event *repeatEvent = eventObj;
            if ([dateStart isSameDay:eventObj.eventTime]) {
                repeatEvent.eventOccurTime = dateStart;
                [eventOnDay addObject:dateStart];
            }
            
            
            if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && [dateStart daysBetweenDate:eventObj.eventTime] % 7 == 0  && ![dateStart isAfterDate:eventObj.eventEndTime]){
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay]  &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay]  &&
                    [dateStart getMonth] == [eventObj.eventTime getMonth]  &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:dateStart];
                }
            }
        }
        [retVal addObjectsFromArray:eventOnDay];
        
        TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
        info.day++;
        dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
        
        // COMMENT: if the current day is the last date, break from the loop
        if([dateStart compare:toDate]==NSOrderedDescending) break;
    }
    return retVal;
}

- (NSArray*)getAllListEventOccurFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId {
    toDate = [[toDate dateByAddingDays:1] dateByAddSecond:-1];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)))", partnerId, fromDate, toDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *nonRepeatArr = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    DLogInfo(@"nonRepeatArr count = %d", nonRepeatArr.count);
    
    NSMutableArray *retVal = [NSMutableArray array];

    NSDate *dateStart = fromDate;
    while(YES){
        NSMutableArray *eventOnDay = [NSMutableArray array];
        for (Event *eventObj in nonRepeatArr) {
            Event *repeatEvent = eventObj;
            if ([dateStart isSameDay:eventObj.eventTime]) {
                repeatEvent.eventOccurTime = dateStart;
                [eventOnDay addObject:repeatEvent];
            }
            
            
            if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:repeatEvent];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                int days = [dateStart daysBetweenDate:eventObj.eventTime];
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && days % 7 == 0  && ![dateStart isAfterDate:eventObj.eventEndTime]){
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:repeatEvent];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay]  &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:repeatEvent];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay]  &&
                    [dateStart getMonth] == [eventObj.eventTime getMonth]  &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    repeatEvent.eventOccurTime = dateStart;
                    [eventOnDay addObject:repeatEvent];
                }
            }
        }
        [retVal addObjectsFromArray:eventOnDay];
        
        TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
        info.day++;
        dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
        
        // COMMENT: if the current day is the last date, break from the loop
        if([dateStart compare:toDate]==NSOrderedDescending) break;
    }
    return retVal;
}

- (NSArray *)getEventWithCorrectTimeValueForMonthView:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId {
    if (!fromDate || !toDate) {
        return nil;
    }
    toDate = [[toDate dateByAddingDays:1] dateByAddSecond:-1];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)))", partnerId, fromDate, toDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *nonRepeatArr = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    DLogInfo(@"nonRepeatArr count = %d", nonRepeatArr.count);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    NSDate *dateStart = fromDate;
    while(YES){
        NSMutableArray *eventOnDay = [NSMutableArray array];
        for (Event *eventObj in nonRepeatArr) {
            
            if ([dateStart isSameDay:eventObj.eventTime]) {
                [eventOnDay addObject:dateStart];
            }
            if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && [dateStart daysBetweenDate:eventObj.eventTime] % 7 == 0  && ![dateStart isAfterDate:eventObj.eventEndTime]){
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay] &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:dateStart];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay] &&
                    [dateStart getMonth] == [eventObj.eventTime getMonth] &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:dateStart];
                }
            }
        }
        [retVal addObjectsFromArray:eventOnDay];
        
        TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
        info.day++;
        dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
        
        // COMMENT: if the current day is the last date, break from the loop
        if([dateStart compare:toDate]==NSOrderedDescending) break;
    }
    return retVal;
}

- (NSArray*)getAllListEventOccurFromDateForMonthView:(NSDate*)fromDate toDate:(NSDate*)toDate forPartner:(NSInteger)partnerId {
    if (!fromDate || !toDate) {
        return nil;
    }
    toDate = [[toDate dateByAddingDays:1] dateByAddSecond:-1];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)))", partnerId, fromDate, toDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *nonRepeatArr = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    DLogInfo(@"nonRepeatArr count = %d", nonRepeatArr.count);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    NSDate *dateStart = fromDate;
    while(YES){
        NSMutableArray *eventOnDay = [NSMutableArray array];
        for (Event *eventObj in nonRepeatArr) {
            
            if ([dateStart isSameDay:eventObj.eventTime]) {
                [eventOnDay addObject:eventObj];
            }
            if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:eventObj];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                int days = [dateStart daysBetweenDate:eventObj.eventTime];
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] && days % 7 == 0  && ![dateStart isAfterDate:eventObj.eventEndTime]){
                    [eventOnDay addObject:eventObj];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay] &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:eventObj];
                }
            }
            else if ([eventObj.recurrence isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
                if ([dateStart isBetweenDate:eventObj.eventTime end:toDate] &&
                    [dateStart getDay] == [eventObj.eventTime getDay] &&
                    [dateStart getMonth] == [eventObj.eventTime getMonth] &&
                    ![dateStart isAfterDate:eventObj.eventEndTime]) {
                    [eventOnDay addObject:eventObj];
                }
            }
        }
        [retVal addObjectsFromArray:eventOnDay];
        
        TKDateInformation info = [dateStart dateInformationWithTimeZone:[NSTimeZone systemTimeZone]];
        info.day++;
        dateStart = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone systemTimeZone]];
        
        // COMMENT: if the current day is the last date, break from the loop
        if([dateStart compare:toDate]==NSOrderedDescending) break;
    }
    return retVal;
}


// tem
- (NSInteger) countEventAtDate:(NSDate*) date forPartner:(NSInteger) partnerId {
    NSDate *startDate = date;
    NSDate *endDate = [startDate dateByAddDays:1];
    endDate = [endDate dateByAddSecond:-1];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (not ((eventEndTime <= %@) OR (eventTime >= %@)) AND (((%@ - eventTime)/(24*60*60)) %   ) ", partnerId,startDate,endDate,startDate];
    [request setPredicate: pred];
    NSError *error;
    NSInteger count =  [managedObjectContext countForFetchRequest:request error:&error];
    [request release];
    
    return count;
}

-(NSArray*) getAllEventOccurAtDateForCalendar:(NSDate*)date forPartner:(NSInteger) partnerId{
    NSDate *startDate = date;
    NSDate *endDate = [startDate dateByAddDays:1];
    endDate = [endDate dateByAddSecond:-1];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (eventTime >= %@) AND (eventTime <= %@)", partnerId,startDate,endDate];
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    eventList = [eventList sortWithKey:@"eventTime" ascending:YES];
    
    return eventList;
}


/**********************************************************
 @Function description: get event happen at current date and future (not past)  and for a selected partner
 @Note:
 ***********************************************************/
- (NSArray*) getAllEventCurrentDateToFutureForPartner:(NSInteger) partnerId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (eventTime >= %@)", partnerId,[NSDate date]];
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    eventList = [eventList sortWithKey:@"eventTime" ascending:YES];
    
    return eventList;
}

/**********************************************************
 @Function description: get event happen at a specific date rane and for a selected partner
 @Note:
 ***********************************************************/
-(NSArray*) getAllEventOccurFromDate:(NSDate*)fromDate toDate:(NSDate *) toDate forPartner:(NSInteger) partnerId{
    // COMMENT: Get date only (remove hours)
    NSDate *fromDateOnly = [fromDate dateOnly];
    NSDate *toDateOnly = [toDate dateOnly];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (eventTime >= %@) AND (eventTime <= %@)", partnerId,fromDateOnly,toDateOnly];
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    eventList = [eventList sortWithKey:@"eventTime" ascending:YES];
    
    return eventList;
}

/*
 Description:   Get all recurring events at a specific date
 Params:        date, userId
 Notes:         N/A
 */
-(NSArray*) getAllRecurringEventsAtDate:(NSDate*)date forPartner:(NSInteger) partnerId
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (recurrence != %@)", partnerId, @""];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *recurringEvents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *results = [NSMutableArray array];
    for (Event *event in recurringEvents) {
        NSDate *eventTime = event.eventTime;
        NSString *recurType = event.recurrence;
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
            [results addObject:event];
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
            NSInteger days = [[eventTime beginningOfDay] daysBetweenDate:[date beginningOfDay]];
            if (days % 7 == 0) {
                [results addObject:event];
            }
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
            TKDateInformation info1 = [date dateInformation];
            TKDateInformation info2 = [eventTime dateInformation];
            if (info1.day == info2.day) {
                [results addObject:event];
            }
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
            TKDateInformation info1 = [date dateInformation];
            TKDateInformation info2 = [eventTime dateInformation];
            if (info1.day == info2.day && info1.month == info2.month) {
                [results addObject:event];
            }
        }
    }
    return results;
}

/*
 Description:   Check if has any recurring events occurs at a specific date
 Params:        date, userId
 Notes:         N/A
 */
- (BOOL)hasRecurringEventsAtDate:(NSDate *)date forPartner:(NSInteger)partnerId
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(partner.partnerID  = %d) AND (recurrence != %@)", partnerId, @""];
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *recurringEvents = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Event *event in recurringEvents) {
        NSDate *eventTime = event.eventTime;
        NSString *recurType = event.recurrence;
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
            return YES;
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
            NSInteger days = [[eventTime beginningOfDay] daysBetweenDate:[date beginningOfDay]];
            if (days % 7 == 0) {
                return YES;
            }
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
            TKDateInformation info1 = [date dateInformation];
            TKDateInformation info2 = [eventTime dateInformation];
            if (info1.day == info2.day) {
                return YES;
            }
        }
        if ([recurType isEqualToString:MANAPP_EVENT_RECURRING_YEARLY]) {
            TKDateInformation info1 = [date dateInformation];
            TKDateInformation info2 = [eventTime dateInformation];
            if (info1.day == info2.day && info1.month == info2.month) {
                return YES;
            }
        }
        
    }
    return NO;
}

-(BOOL) setMenstruationForPartner:(NSInteger)partnerId lastPeriod:(NSDate *)lastPeriod usingBirthControl:(BOOL)usingBirthControl{
    Partner *partner = [self getPartnerById:partnerId];
    if(partner){
        partner.lastPeriod = lastPeriod;
        partner.birthControl = [NSNumber numberWithBool:usingBirthControl];
        
        NSError *error;
        if([self.managedObjectContext save:&error]){
            return YES;
        }
        else{
            DLog(@"edit partner ero zone failed: %@",error);
            return NO;
        }
    }
    
    return FALSE;
}

#pragma mark - function to handle setup progress table
/**********************************************************
 @Function description: get all setup step entity
 @Note:
 ***********************************************************/
-(NSArray*) getAllSetupStep{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerSetup" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *partnerSetupList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return partnerSetupList;
}

/**********************************************************
 @Function description: get setup by name
 @Note:
 ***********************************************************/
-(PartnerSetup*) getSetupStepByName:(NSString*) setupName{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerSetup" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", setupName]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *stepList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([stepList count]>0)
        return [stepList objectAtIndex:([stepList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: get setup by id
 @Note:
 ***********************************************************/
-(PartnerSetup*) getSetupStepById:(NSInteger) setupId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerSetup" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerSetupID = %d)", setupId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *stepList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([stepList count]>0)
        return [stepList objectAtIndex:([stepList count] - 1)];
    else
        return NULL;
}

/**********************************************************
 @Function description: add new step to database
 @Note:
 ***********************************************************/
-(NSInteger) addSetupStepWithName:(NSString*) setupName withWeight:(float) setupWeight{
    // COMMENT: get the highest id and plus one to give to the new entity
    NSArray *stepList = [self getAllSetupStep];
    NSInteger maxId = 0;
    if([stepList count] > 0)
    {
        for(int i=0; i<[stepList count]; i++){
            PartnerSetup* entity = [stepList objectAtIndex:i];
            if([entity.partnerSetupID intValue] > maxId){
                maxId = [entity.partnerSetupID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    // COMMENT: add new entity
    PartnerSetup* partnerSetup = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerSetup" inManagedObjectContext:managedObjectContext];
    partnerSetup.partnerSetupID = [NSNumber numberWithInt:(maxId + 1)];
    partnerSetup.name = setupName;
    partnerSetup.weight = [NSNumber numberWithFloat:setupWeight];
    NSError *error;
    if([managedObjectContext save:&error]){
        return TRUE;
    }
    else{
        DLog(@"insert setup step failed: %@",error);
        return FALSE;
    }
}

/**********************************************************
 @Function description: generate new data when the application first lauch
 @Note:
 ***********************************************************/
-(void) initSetupStepData{
    NSArray *stepList = [self getAllSetupStep];
    if([stepList count] == 0){
        [self addSetupStepWithName:MANAPP_PARTNER_MANAGER_PROCESS_STEP_CREATION withWeight:20];
        [self addSetupStepWithName:MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_ADDITIONAL_INFORMATION withWeight:20];
        [self addSetupStepWithName:MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_SIZE withWeight:20];
        [self addSetupStepWithName:MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_LIKE withWeight:20];
        [self addSetupStepWithName:MANAPP_PARTNER_MANAGER_PROCESS_STEP_INPUT_PREFERENCE_DISLIKE withWeight:20];
    }
}

// Remove event by Id
- (BOOL)removeEventWithID:(NSString *)eventID
{
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:@"Event" withPredicate:[NSPredicate predicateWithFormat:@"eventID = %@", eventID] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    if (arr.count > 0) {
        for (Event *eventItem in arr) {
            [self.managedObjectContext deleteObject:eventItem];
        }
        [self saveContext];
        return YES;
    }
    return NO;
}

#pragma mark - function to handle ero zone table
/*********************************************************************************
 @Function description: get all object in the ero zone table
 @Note:
*********************************************************************************/
-(NSArray*) getAllEroZone{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *eroZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return eroZoneList;
}

-(NSArray*) getAllEroZoneForAvatarType:(NSInteger) type sex:(NSInteger)sex{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(sex = %d and type = %d)", sex, type];
    [request setPredicate: pred];
    NSError *error;
    NSArray *eroZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return eroZoneList;
}

-(void) generateZoneWithZoneList:(NSArray *)zoneDTOs forAvatarType:(NSInteger) type sex:(NSInteger)sex{
    NSArray *zones = [self getAllEroZoneForAvatarType:type sex:sex];
    if(zones.count == 0){
        for(SpecialZoneDTO *zoneDTO in zoneDTOs){
            [self addEroZoneWithName:zoneDTO.zoneName andId:(zoneDTO.zoneType + 100 * type + 1000 * sex) type:type sex:sex];
        }
    }
}
/*********************************************************************************
 @Function description: get zone by id
 @Note:
*********************************************************************************/
-(ErogeneousZone*) getEroZoneById:(NSInteger) eroZoneId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(erogeneousZoneID = %d)", eroZoneId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *zoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([zoneList count]>0)
        return [zoneList objectAtIndex:([zoneList count] - 1)];
    else
        return NULL;
}

-(ErogeneousZone*) getEroZoneByTypeId:(NSInteger) eroZoneTypeId forPartner:(Partner *)partner avatarType:(NSInteger)type{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(erogeneousZoneID = %d)", (eroZoneTypeId + 100 * type + 1000 * partner.sex.integerValue)];
    [request setPredicate: pred];
    NSError *error;
    NSArray *zoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([zoneList count] > 0)
        return [zoneList objectAtIndex:([zoneList count] - 1)];
    else
        return NULL;
}

// Get all SpecialZone.
- (NSMutableArray*) getAllSpecialZoneNonPartnerEroZoneBySpecialZoneList:(NSArray*) specialZoneList  {
    NSMutableArray *listSpecialZone = [NSMutableArray array];
    if (specialZoneList) {
        for (SpecialZoneDTO *specialZoneDTO in specialZoneList) {
            ErogeneousZone *selectedZone = [self getEroZoneByTypeId:specialZoneDTO.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
            if (selectedZone) {
                PartnerEroZone *partnerEroZone = [self getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:selectedZone.erogeneousZoneID.integerValue];
                if(!partnerEroZone){
                    [listSpecialZone addObject:specialZoneDTO];
                }
            }
        }
    }
    return listSpecialZone;
}

- (BOOL) checkSpecialZoneStoredSpecialZoneList:(NSArray*) specialZoneList  {
    BOOL isExist = NO;
    if (specialZoneList) {
        for (SpecialZoneDTO *specialZoneDTO in specialZoneList) {
            ErogeneousZone *selectedZone = [self getEroZoneByTypeId:specialZoneDTO.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
            if (selectedZone) {
                PartnerEroZone *partnerEroZone = [self getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:selectedZone.erogeneousZoneID.integerValue];
                if(partnerEroZone){
                    isExist = YES;
                    break;
                }
            }
        }
    }
    return isExist;
}

// Enough are 2;
- (NSInteger) checkSpecialZoneStoredSpecialZoneListIsEnough:(NSArray*) specialZoneList  {
    NSMutableArray *listSpecialZone = [NSMutableArray array];
//    BOOL isEnough = NO;
    if (specialZoneList) {
        for (SpecialZoneDTO *specialZoneDTO in specialZoneList) {
            ErogeneousZone *selectedZone = [self getEroZoneByTypeId:specialZoneDTO.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
            if (selectedZone) {
                PartnerEroZone *partnerEroZone = [self getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:selectedZone.erogeneousZoneID.integerValue];
                if(partnerEroZone){
                    if (listSpecialZone.count == 2) {
//                        isEnough = YES;
                        break;
                    } else {
                        [listSpecialZone addObject:specialZoneDTO];
                    }
                }
            }
        }
    }
    return listSpecialZone.count;
}

-(ErogeneousZone *) addEroZoneWithName:(NSString*) zoneName type:(NSInteger)type sex:(NSInteger) sex{
    // COMMENT: get the highest id and plus one to give to the new entity
    NSArray *zoneList = [self getAllEroZone];
    NSInteger maxId = 0;
    NSInteger numberOfZone = [zoneList count];
    if(numberOfZone > 0)
    {
        for(int i=0; i<numberOfZone; i++){
            ErogeneousZone* entity = [zoneList objectAtIndex:i];
            if([entity.erogeneousZoneID intValue] > maxId){
                maxId = [entity.erogeneousZoneID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    // COMMENT: add new entity
    ErogeneousZone* eroZone = [self addEroZoneWithName:zoneName andId:(maxId + 1) type:type sex:sex];
    
    return eroZone;
}

-(ErogeneousZone *) addEroZoneWithName:(NSString*) zoneName andId:(NSInteger) zoneId type:(NSInteger)type sex:(NSInteger) sex{
    ErogeneousZone* eroZone = [NSEntityDescription insertNewObjectForEntityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    eroZone.erogeneousZoneID = [NSNumber numberWithInt:zoneId];
    eroZone.name = zoneName;
    eroZone.type = [NSNumber numberWithInt:type];
    eroZone.sex = [NSNumber numberWithInt:sex];
    NSError *error;
    if([managedObjectContext save:&error]){
        return eroZone;
    }
    else{
        DLog(@"insert ero zone failed: %@",error);
        return nil;
    }
}
/**********************************************************
 @Function description: generate new data when the application first lauch
 @Note:
 ***********************************************************/
-(void) initEroZoneData{
    NSArray *zoneList = [self getAllEroZone];
    if([zoneList count] == 0){
        [self addEroZoneWithName:@"Feet" type:1 sex:1];
        [self addEroZoneWithName:@"Lower Leg" type:1 sex:1];
        [self addEroZoneWithName:@"Upper Leg" type:1 sex:1];
        [self addEroZoneWithName:@"Pelvic Area" type:1 sex:1];
        [self addEroZoneWithName:@"Abdomen" type:1 sex:1];
        [self addEroZoneWithName:@"Chest" type:1 sex:1];
        [self addEroZoneWithName:@"Neck" type:1 sex:1];
        [self addEroZoneWithName:@"Arm" type:1 sex:1];
        [self addEroZoneWithName:@"Hand" type:1 sex:1];
        [self addEroZoneWithName:@"Head" type:1 sex:1];
    }
}

#pragma mark - function to handle partner's note
-(Note *) addNote:(NSString *) note forPartner:(Partner *) partner{
    Note* newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    newNote.noteID = [NSString generateGUID];
    newNote.note = note;
    newNote.partner = partner;
    NSError *error;
    if([managedObjectContext save:&error]){
        return newNote;
    }
    else{
        DLog(@"insert newNote zone failed: %@",error);
        return nil;
    }
}

-(NSArray*) getNotesForPartner:(Partner *) partner{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner = %@)", partner];
    [request setPredicate: pred];
    NSError *error;
    NSArray *notes = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return notes;
}


-(Note *) editNote:(Note *)note withNewNote:(NSString *) noteString{
    if(!note){
        DLog(@"This note don't exist");
        return 0;
    }
    else{
        note.note = noteString;
        NSError *error;
        if([managedObjectContext save:&error]){
            return note;
        }
        else{
            DLog(@"edit note failed: %@",error);
            return FALSE;
        }
    }
}

-(BOOL)removeNote:(Note *)note{
    if (note) {
        [self.managedObjectContext deleteObject:note];
        [self saveContext];
        return YES;
    }
    return NO;
}

#pragma mark - function to handle partner's erozone table
/*********************************************************************************
 @Function description: get all object in the partner's ero zone table
 @Note: for all partner, all zone
 *********************************************************************************/
-(NSArray*) getAllPartnerEroZone{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *partnerEroZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return partnerEroZoneList;
}
/*********************************************************************************
 @Function description: get partner zone by id
 @Note:
*********************************************************************************/
-(PartnerEroZone*) getPartnerEroZoneById:(NSInteger) partnerEroZoneId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerEroZoneID = %d)", partnerEroZoneId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerZoneList count]>0)
        return [partnerZoneList objectAtIndex:([partnerZoneList count] - 1)];
    else
        return NULL;
}

/*********************************************************************************
 @Function description: get partner zones by partner
 @Note:
 *********************************************************************************/
-(NSArray*) getPartnerEroZonesForPartner:(NSInteger) partnerId{
    Partner *partner = [self getPartnerById:partnerId];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerID = %d and fkPartnerEroZoneToEroZone.sex = %d)", partnerId, partner.sex.integerValue];
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return partnerZoneList;
}
/*********************************************************************************
 @Function description: get partner zone by partner and zone's id
 @Note:use to get value for the selected zone
*********************************************************************************/
-(PartnerEroZone*) getPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partnerID = %d) AND (eroZoneID = %d)", partnerId,zoneId]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerZoneList count]>0)
        return [partnerZoneList objectAtIndex:([partnerZoneList count] - 1)];
    else
        return NULL;
}

- (BOOL) removeAllPartnereroZone:(NSArray*) specialZoneList {
    if (specialZoneList) {
        for (SpecialZoneDTO *specialZoneDTO in specialZoneList) {
            ErogeneousZone *selectedZone = [self getEroZoneByTypeId:specialZoneDTO.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
            if (selectedZone) {
                PartnerEroZone *partnerEroZone = [self getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:selectedZone.erogeneousZoneID.integerValue];
                if(partnerEroZone){
                    [self.managedObjectContext deleteObject:partnerEroZone];
                    [self saveContext];
                }
            }
        }
    }
    return YES;
}
/*********************************************************************************
 @Function description: add new partner zone
 @Note: only add if there isn't any data for this partner and zone
*********************************************************************************/
-(PartnerEroZone *) addPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value{
    // COMMENT: check if this partner is existed or not, if true, then return 0 since we can't have two data for a same zone of a same partner
    PartnerEroZone *existedPartnerZone = [self getPartnerEroZoneForPartner:partnerId andZone:zoneId];
    if(existedPartnerZone){
        DLog(@"ero zone data for this partner and this zone already existed, can't add new data");
        return 0;
    }
    else{
        // COMMENT: get the highest id and plus one to give to the new entity
        NSArray *partnerZoneList = [self getAllPartnerEroZone];
        NSInteger maxId = 0;
        if([partnerZoneList count] > 0)
        {
            for(int i=0; i<[partnerZoneList count]; i++){
                PartnerEroZone* entity = [partnerZoneList objectAtIndex:i];
                if([entity.partnerEroZoneID intValue] > maxId){
                    maxId = [entity.partnerEroZoneID intValue];
                }
            }
        }
        else{
            maxId = 0;
        }
        // COMMENT: add new entity
        PartnerEroZone* partnerEroZone = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
        partnerEroZone.partnerEroZoneID = [NSNumber numberWithInt:(maxId + 1)];
        partnerEroZone.partnerID = [NSNumber numberWithInt:partnerId];
        partnerEroZone.eroZoneID = [NSNumber numberWithInt:zoneId];
        partnerEroZone.value = value;
        NSError *error;
        if([managedObjectContext save:&error]){
            return partnerEroZone;
        }
        else{
            DLog(@"insert partner ero zone failed: %@",error);
            return nil;
        }

    }
    
    
}

/*********************************************************************************
 @Function description: add new partner zone - This zone will not belong to any partner until user save.
 @Note: It is to temporarily store partner zone
 *********************************************************************************/

-(PartnerEroZone*) addFreePartnerEroZone:(NSInteger) zoneId andValue:(NSString*) value
{
   //Get max id
    NSArray *partnerZoneList = [self getAllPartnerEroZone];
    NSInteger maxId = 0;
    if([partnerZoneList count] > 0)
    {
        for(int i=0; i<[partnerZoneList count]; i++){
            PartnerEroZone* entity = [partnerZoneList objectAtIndex:i];
            if([entity.partnerEroZoneID intValue] > maxId){
                maxId = [entity.partnerEroZoneID intValue];
            }
        }
    }
    else{
        maxId = 0;
    }
    
    //Create partner ero zone
    PartnerEroZone* partnerEroZone = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerEroZone" inManagedObjectContext:managedObjectContext];
    partnerEroZone.partnerEroZoneID = [NSNumber numberWithInt:(maxId + 1)];
    partnerEroZone.eroZoneID = [NSNumber numberWithInt:zoneId];
    partnerEroZone.value = value;
    return partnerEroZone;
    
}

/*********************************************************************************
 @Function description: edit exited zone's value
 @Note:
*********************************************************************************/
-(BOOL) editPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value{
    // COMMENT: check if this partner is existed or not, if not, then return false since we can't edit an non-existed object
    PartnerEroZone *existedPartnerZone = [self getPartnerEroZoneForPartner:partnerId andZone:zoneId];
    if(!existedPartnerZone){
        DLog(@"partner ero zone data for this partner and this zone isn't existed, can't edit partner ero zone data");
        return 0;
    }
    else{
        existedPartnerZone.value = value;
        NSError *error;
        if([managedObjectContext save:&error]){
            return TRUE;
        }
        else{
            DLog(@"edit partner ero zone failed: %@",error);
            return FALSE;
        }
    }
}

#pragma mark - partner mood
//get all mood for partner, if there is a sample mood available, return only sample mood. If not, then return only non-sample mood
- (NSArray*)getAllMoodForPartner:(Partner *) partner{
    NSArray *sampleMoods = [self getAllSampleMoodForPartner:partner];
    
    //if we only have sample mood
    if(sampleMoods.count > 0){
        return sampleMoods;
    }
    else{
        NSArray *moods = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ AND isSample = 0", partner] andSortKey:@"addedTime" andSortAscending:YES andContext:self.managedObjectContext];
        return moods;
    }
}

//get all sample mood for partner
- (NSArray*)getAllSampleMoodForPartner:(Partner *) partner{
    NSArray *moods = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ AND isSample = 1", partner] andSortKey:@"addedTime" andSortAscending:YES andContext:self.managedObjectContext];
    
    return moods;
}

//add the sample mood for partner in 30 days-cycle
- (void)addSampleMoodsForPartner:(Partner *)partner fromDate:(NSDate *)date{
    //make sure all the sample mood was deleted
    [self removeAllSampleMoodForPartner:partner];
    
    for(NSInteger i = 0; i < 10; i++){
        NSDate *currentDate = [date dateByAddDays:i * MA_MOOD_CYCLE_STEP];
        PartnerMood *partnerMood = [self partnerMoodWithPartner:partner date:currentDate];
        if (!partnerMood) {
            partnerMood = [NSEntityDescription insertNewObjectForEntityForName:kEntityPartnerMood inManagedObjectContext:self.managedObjectContext];
            partnerMood.moodID = [NSString generateGUID];
        }
        partnerMood.moodValue = [NSNumber numberWithInt:MA_DEFAULT_MOOD_VALUE];
        partnerMood.addedTime = currentDate;
        partnerMood.partner = partner;
        partnerMood.isSample = [NSNumber numberWithBool:YES];
        [self saveContext];
    }
}

//remove all sample mood
- (void)removeAllSampleMoodForPartner:(Partner *)partner{
    NSArray *moods = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ AND isSample = 1", partner] andSortKey:@"addedTime" andSortAscending:NO andContext:self.managedObjectContext];
    for(PartnerMood *mood in moods){
        [self.managedObjectContext deleteObject:mood];
        [self saveContext];
    }
}

// Get PartnerMood by Id
- (PartnerMood *)partnerMoodWithId:(NSString *)moodId
{
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"moodID = %@", moodId] andSortKey:@"addedTime" andSortAscending:NO andContext:self.managedObjectContext];
    if (arr.count > 0) {
        return [arr lastObject];
    }
    return nil;
}

// Get PartnerMood with PartnerId and Date
- (PartnerMood *)partnerMoodWithPartner:(Partner *)partner date:(NSDate *)date
{
    NSDate *startDate = [date beginningAtMidnightOfDay];
    NSDate *endDate = [startDate dateByAddDays:1];
    endDate = [endDate dateByAddSecond:-1];
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ AND (addedTime >= %@) AND (addedTime < %@)", partner, startDate, endDate] andSortKey:@"addedTime" andSortAscending:NO andContext:self.managedObjectContext];
    if (arr.count > 0) {
        return [arr lastObject];
    }
    return nil;
}

- (CGFloat) getTodayMoodOfPartner:(Partner*) partner
{
    PartnerMood *todayMood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]];
    CGFloat mood;
    if (todayMood) {
        mood = [todayMood.moodValue floatValue];
        if (mood == MA_MOOD_UNAVAILABLE_VALUE) {
            mood = 50;
        }
    }
    else
    {
        mood = 50;
    }
    return mood;
}
// Add/Update Mood Value with PartnerId and Date
- (PartnerMood *)addMoodValue:(NSNumber *)moodValue forPartner:(Partner*)partner date:(NSDate *)date
{
    //check if there is any mood in the given day
    PartnerMood *existedMood = [self partnerMoodWithPartner:partner date:date];
    //if there is, edit it
    if(existedMood && existedMood.isSample.boolValue == NO){
        existedMood.moodValue = moodValue;
        [self saveContext];
        
        return existedMood;
    }
    //if not, create new one
    else{
        //remove all sample mood before add a new one
        [self removeAllSampleMoodForPartner:partner];
        
        //add non-sample mood
        PartnerMood *partnerMood = [self partnerMoodWithPartner:partner date:date];
        if (!partnerMood) {
            partnerMood = [NSEntityDescription insertNewObjectForEntityForName:kEntityPartnerMood inManagedObjectContext:self.managedObjectContext];
            partnerMood.moodID = [NSString generateGUID];
        }
        partnerMood.moodValue = moodValue;
        partnerMood.addedTime = [date dateOnly];
        partnerMood.partner = partner;
        partnerMood.isSample = [NSNumber numberWithBool:NO];
        [self saveContext];
        
        return partnerMood;
    }
}

// Remove PartnerMood at a specific Date
- (BOOL)removePartnerMoodWithPartner:(Partner*)partner date:(NSDate *)date
{
    PartnerMood *mood = [self partnerMoodWithPartner:partner date:date];
    if (mood) {
        [self.managedObjectContext deleteObject:mood];
        [self saveContext];
        return YES;
    }
    return NO;
}

// Init default measurement data for a specific partner
- (BOOL)initDefaultMeasurementDataForPartner:(Partner *)partner
{
    if (!partner) {
        return NO;
    }
    if (partner.measurements.count > 0) {
        return NO;
    }
    NSArray *measurementArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MeasurementInformation" ofType:@"plist"]];
    for (NSDictionary *measurementData in measurementArr) {
        PartnerMeasurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMeasurement" inManagedObjectContext:self.managedObjectContext];
        measurement.name = [measurementData objectForKey:MANAPP_MEASUREMENT_NAME_KEY];
        measurement.sex = [NSNumber numberWithInt:[[measurementData objectForKey:MANAPP_MEASUREMENT_SEX_KEY] integerValue]];
        measurement.measurementID = [NSString generateGUID];
        measurement.timestamp = [NSDate date];
        measurement.partner = partner;
    }
    [self saveContext];
    return YES;
}

//restore any missing category
- (NSInteger) restoreDefaultMeasurementCategoryForPartner:(Partner *)partner{
    if (!partner) {
        return 0;
    }
    
    NSInteger counter = 0;
    
    NSArray *measurementArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MeasurementInformation" ofType:@"plist"]];
    for (NSDictionary *measurementData in measurementArr){
        NSString *name = [measurementData objectForKey:MANAPP_MEASUREMENT_NAME_KEY];
        NSNumber *sex = [measurementData objectForKey:MANAPP_MEASUREMENT_SEX_KEY];
        NSArray *duplicatedCategory = [self getPartnerMeasurementsWithName:name forPartner:partner];
        if(!duplicatedCategory || duplicatedCategory.count <= 0){
            PartnerMeasurement *category = [self addNewMeasurementCategoryForPartner:partner withName:name forSex:sex.integerValue];
            if(category){
                counter++;
            }
        }
    }
    
    return counter;
}

// Init default information for a specific partner
- (BOOL) initDefaultInformationForPartner:(Partner *)partner{
    if (!partner){
        return NO;
    }
    if (partner.information.count > 0){
        return NO;
    }
    NSArray *informationArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AdditionalInformation" ofType:@"plist"]];
    for (NSDictionary *infoDict in informationArr){
        PartnerInformation *partnerInformation = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
        partnerInformation.name = [infoDict objectForKey:@"name"];
        partnerInformation.infoID = [NSString generateGUID];
        partnerInformation.timestamp = [NSDate date];
        partnerInformation.partner = partner;
        partnerInformation.level = [NSNumber numberWithInt:1];
        
        //level 2
        NSArray *subCategories = [infoDict objectForKey:@"categories"];
        for (NSString *subCategory in subCategories){
            PartnerInformation *subInformation = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
            subInformation.name = subCategory;
            subInformation.infoID = [NSString generateGUID];
            subInformation.timestamp = [NSDate date];
            subInformation.partner = partner;
            subInformation.level = [NSNumber numberWithInt:partnerInformation.level.integerValue + 1];
            subInformation.parentCategory = partnerInformation;
        }
    }
    [self saveContext];
    return YES;
}

//restore the missing default categories
- (NSInteger) restoreDefaultInformationCategoryForPartner:(Partner *)partner{
    
    if (!partner){
        return 0;
    }
    
    NSInteger counter = 0;
    
    NSArray *informations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AdditionalInformation" ofType:@"plist"]];
    for (NSDictionary *inforDict in informations){
        NSString *parentCategoryName = [inforDict objectForKey:@"name"];
        NSArray *parentCategories = [self getPartnerInformationAtLevel:1 withName:parentCategoryName forPartner:partner parentCategory:nil];
        if(parentCategories.count <= 0){
            continue;
        }
        else{
            PartnerInformation *parentCategory = [parentCategories firstObject];
            
            //level 2
            NSArray *subCategories = [inforDict objectForKey:@"categories"];
            for (NSString *subCategory in subCategories){
                NSArray *duplicatedCategory = [self getPartnerInformationAtLevel:2 withName:subCategory forPartner:partner parentCategory:parentCategory];
                if(!duplicatedCategory || duplicatedCategory.count <= 0){
                    PartnerInformation *category = [self addNewInformationCategoryForCategory:parentCategory withName:subCategory];
                    if(category){
                        counter++;
                    }
                }
            }
        }
    }
    
    return counter;
}

// Init default preference for a specific partner
- (BOOL) initDefaultPreferenceForPartner:(Partner *)partner{
    if (!partner){
        return NO;
    }
    if (partner.preferences.count > 0){
        return NO;
    }
    NSArray *preferenceArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]];
    for (NSDictionary *preDict in preferenceArr){
        PreferenceCategory *preference = [NSEntityDescription insertNewObjectForEntityForName:@"PreferenceCategory" inManagedObjectContext:self.managedObjectContext];
        preference.name = [preDict objectForKey:@"name"];
        preference.preferenceID = [NSString generateGUID];
        preference.timestamp = [NSDate date];
        preference.partner = partner;
        preference.level = [NSNumber numberWithInt:1];
        
        //level 2
        NSArray *subCategories = [preDict objectForKey:@"categories"];
        for (NSString *subCategory in subCategories){
            PreferenceCategory *subPreference = [NSEntityDescription insertNewObjectForEntityForName:@"PreferenceCategory" inManagedObjectContext:self.managedObjectContext];
            subPreference.name = subCategory;
            subPreference.preferenceID = [NSString generateGUID];
            subPreference.timestamp = [NSDate date];
            subPreference.partner = partner;
            subPreference.level = [NSNumber numberWithInt:2];
            subPreference.parentCategory = preference;
        }
    }
    [self saveContext];
    return YES;
}

- (NSInteger) restoreDefaultPreferenceCategoryForPartner:(Partner *)partner{
    if (!partner){
        return 0;
    }
    
    NSInteger counter = 0;

    NSArray *preferenceArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]];
    for (NSDictionary *preDict in preferenceArr){
        NSString *parentCategoryName = [preDict objectForKey:@"name"];
        NSArray *parentCategories = [self getPartnerPreferenceAtLevel:1 withName:parentCategoryName forPartner:partner parentCategory:nil];
        if(parentCategories.count <= 0){
            continue;
        }
        else{
            PreferenceCategory *parentCategory = [parentCategories firstObject];
            
            //level 2
            NSArray *subCategories = [preDict objectForKey:@"categories"];
            for (NSString *subCategory in subCategories){
                NSArray *duplicatedCategory = [self getPartnerPreferenceAtLevel:2 withName:subCategory forPartner:partner parentCategory:parentCategory];
                if(!duplicatedCategory || duplicatedCategory.count <= 0){
                    PreferenceCategory *category = [self addNewPreferenceCategoryForCategory:parentCategory withName:subCategory];
                    if(category){
                        counter++;
                    }
                }
            }
        }
    }

    return counter;
}

// Add new subcategory
- (PreferenceCategory *) addNewPreferenceCategoryForCategory:(PreferenceCategory *)pPreference withName:(NSString*)name{
    if (!pPreference){
        return nil;
    }
    if (!pPreference.partner){
        return nil;
    }
    
    PreferenceCategory *subPreference = [NSEntityDescription insertNewObjectForEntityForName:@"PreferenceCategory" inManagedObjectContext:self.managedObjectContext];
    subPreference.name = name;
    subPreference.preferenceID = [NSString generateGUID];
    subPreference.timestamp = [NSDate date];
    subPreference.partner = pPreference.partner;
    subPreference.level = [NSNumber numberWithInt:2];
    subPreference.parentCategory = pPreference;
    
    [self saveContext];
    return subPreference;
}

- (PartnerMeasurementItem *)getPartnerMeasurementItem:(NSString *)itemID {
    if (!itemID){
        return nil;
    }
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"itemID = %@", itemID] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    
    if(items.count == 0){
        return nil;
    }
    else {
        return [items firstObject];
    }
}


- (PartnerMeasurement *)addNewMeasurementCategoryForPartner:(Partner *)partner withName:(NSString *)name forSex:(NSInteger)sex{
    if (!partner) {
        return NO;
    }

    PartnerMeasurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMeasurement" inManagedObjectContext:self.managedObjectContext];
    measurement.name = name;
    measurement.measurementID = [NSString generateGUID];
    measurement.timestamp = [NSDate date];
    measurement.partner = partner;
    measurement.sex = [NSNumber numberWithInt:sex];
    [self saveContext];
    return measurement;
}

// add new information category
- (PartnerInformation *)addNewInformationCategoryForPartner:(Partner *)partner withName:(NSString *)name{
    if (!partner){
        return NO;
    }

    PartnerInformation *information = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
    information.name = name;
    information.infoID = [NSString generateGUID];
    information.timestamp = [NSDate date];
    information.partner = partner;
    information.level = [NSNumber numberWithInt:1];
    
    [self saveContext];
    return information;
}

// Add new subcategory
- (PartnerInformation *) addNewInformationCategoryForCategory:(PartnerInformation *)partnerInformation withName:(NSString*)name{
    if (!partnerInformation){
        return nil;
    }
    if (!partnerInformation.partner){
        return nil;
    }
    
    PartnerInformation *subInformation = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
    subInformation.name = name;
    subInformation.infoID = [NSString generateGUID];
    subInformation.timestamp = [NSDate date];
    subInformation.partner = partnerInformation.partner;
    subInformation.level = [NSNumber numberWithInt:partnerInformation.level.integerValue + 1];
    subInformation.parentCategory = partnerInformation;
    
    [self saveContext];
    return subInformation;
}

// Add new measurement item
- (BOOL)addNewMeasurementItemForPartnerMeasurement:(PartnerMeasurement *)partnerMeasurement name:(NSString *)name
{
    if (!partnerMeasurement) {
        return NO;
    }
    PartnerMeasurementItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMeasurementItem" inManagedObjectContext:self.managedObjectContext];
    item.name = name;
    item.itemID = [NSString generateGUID];
    item.timestamp = [NSDate date];
    item.measurement = partnerMeasurement;
    [self saveContext];
    return YES;
}

//remove preference category and its child
- (BOOL) removePreferenceCategory:(PreferenceCategory *)pPreference{
    if (!pPreference) {
        return NO;
    }
    [self.managedObjectContext deleteObject:pPreference];
    [self saveContext];
    return YES;
}

- (NSArray *)getPartnerMeasurementsWithName:(NSString *)name forPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurement" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and (name like[c] %@) and (sex = %d || sex = %d)", partner,name,partner.sex.integerValue,MANAPP_MEASUREMENT_SEX_BOTH] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (PartnerMeasurement *)getPartnerMeasurementWithName:(NSString *)name forPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    NSArray *measurements = [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurement" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and (name like[c] %@) and (sex = %d || sex = %d)", partner,name,partner.sex.integerValue,MANAPP_MEASUREMENT_SEX_BOTH] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    
    if(measurements.count > 0){
        return [measurements firstObject];
    }
    else{
        return nil;
    }
}

// Get all partner measurement for a specific partner
- (NSMutableArray *)getAllPartnerMeasurementForPartner:(Partner *)partner
{
    if (!partner) {
        return nil;
    }
    
    NSPredicate *predicate = nil;
    //filter to make sure some female field won't appeal in the measurement item list
    predicate = [NSPredicate predicateWithFormat:@"partner = %@ and (sex = %d or sex = %d)", partner,partner.sex.integerValue, MANAPP_MEASUREMENT_SEX_BOTH];
    
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurement" withPredicate:predicate andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getPartnerInformationsWithName:(NSString *)name forPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and (name like[c] %@)", partner,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

// Get all partner information for a specific partner
- (NSArray *)getAllPartnerInformationForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (PartnerInformationItem *)getItemPartnerInformationItem:(NSString *)itemID {
    if (!itemID){
        return nil;
    }
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"PartnerInformationItem" withPredicate:[NSPredicate predicateWithFormat:@"itemID = %@", itemID] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    
    if(items.count == 0){
        return nil;
    }
    else {
        return [items firstObject];
    }
}

- (NSArray *)getAllPartnerInformationAtLevel:(NSInteger) level ForPartner:(Partner *)partner parentCategory:(PartnerInformation*)parent{
    if (!partner){
        return nil;
    }
    if(level == 1)
    {
        return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 1", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    else{
        return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 2 and parentCategory=%@", partner,parent] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
}

- (NSArray *)getPartnerInformationAtLevel:(NSInteger) level withName:(NSString *) name forPartner:(Partner *)partner parentCategory:(PartnerInformation*)parent{
    if (!partner){
        return nil;
    }
    if(level == 1)
    {
        return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 1 and (name like[c] %@)", partner,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    else{
        return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 2 and parentCategory=%@ and (name like[c] %@)", partner,parent,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
}

//Get all partner preference for a specific partner
- (NSArray *)getAllPartnerPreferenceForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

//Get all partner preference for a specific partner
- (NSArray *)getAllItemLikePartnerPreferenceForPartner:(Partner *)partner {
    if (!partner){
        return nil;
    }
    NSMutableArray *nonPreferences = [NSMutableArray array];
    //getAllItemForPartnerPreference
    NSArray *preferences = [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    if (preferences && preferences.count > 0) {
        for(PreferenceCategory *preference in preferences){
            NSArray *items = [self getAllItemForPartnerPreference:preference isLike:YES];
            if(items.count > 0){
                [nonPreferences addObject:preference];
            }
        }
        
    }
    return nonPreferences;
}

- (PreferenceCategory *)getPartnerPreferencesWithName:(NSString *)name forPartner:(Partner *)partner atLevel:(NSInteger) level parentCategory:(PreferenceCategory*)parent{
    if (!partner){
        return nil;
    }
    
    NSArray *categories = nil;
    
    if(level == 1){
        categories = [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and (name like[c] %@ and level = 1)", partner,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    else{
        categories = [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and (name like[c] %@ and level = 2 and parentCategory = %@)", partner, name, parent] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    
    if(categories.count == 0){
        return nil;
    }
    else{
        return [categories firstObject];
    }
}

- (PreferenceItem *)getRandomItemForPartnerPreference:(PreferenceCategory *)pPreference {
    if (!pPreference){
        return nil;
    }
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@", pPreference] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    
    if(items.count == 0){
        return nil;
    }
    else{
        return [items randomObject];
    }
}

- (PreferenceItem *)getItemPreference:(NSString *)itemID {
    if (!itemID){
        return nil;
    }
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"itemID = %@", itemID] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    
    if(items.count == 0){
        return nil;
    }
    else {
        return [items firstObject];
    }
}

- (PreferenceItem *)getRandomItemForSubPreferenceCategory:(NSString *)subCategory parentCategory:(NSString *)parentCategory forPartner:(Partner *)partner{
    if([NSString isEmpty:subCategory] || [NSString isEmpty:parentCategory]){
        return nil;
    }
    
    PreferenceCategory *parent = [self getPartnerPreferencesWithName:parentCategory forPartner:partner atLevel:1 parentCategory:nil];
    if(!parent){
        return nil;
    }
    
    PreferenceCategory *sub = [self getPartnerPreferencesWithName:subCategory forPartner:partner atLevel:2 parentCategory:parent];
    if(!subCategory){
        return nil;
    }
    
    return [self getRandomItemForPartnerPreference:sub];
}

- (NSArray *)getRandomItemForParentCategory:(NSString *)parentCategory isLike:(BOOL)isLike forPartner:(Partner *)partner numberOfItem:(NSInteger)numberOfItem {
    if (!partner) {
        return nil;
    }
    NSArray *items = [self getAllItemLikePartnerPreferenceForPartner:partner];
    if(items){
        if(numberOfItem <= items.count) {
            NSMutableArray *newItems = [NSMutableArray array];
            for(NSInteger i = numberOfItem - 1 ; i >= 0; i --){
                [newItems addObject:items[i]];
            }
            return newItems;
        }
        else{
            return items;
        }
    }
    return nil;
}

// 
//- (NSArray *)getRandomItemForParentCategory:(NSString *)parentCategory isLike:(BOOL)isLike forPartner:(Partner *)partner numberOfItem:(NSInteger)numberOfItem{
//    if([NSString isEmpty:parentCategory]){
//        return nil;
//    }
//    
//    PreferenceCategory *parent = [self getPartnerPreferencesWithName:parentCategory forPartner:partner atLevel:1 parentCategory:nil];
//    if(!parent){
//        return nil;
//    }
//    
//    NSArray *items = [self getAllItemForParentPartnerPreference:parent isLike:isLike];
//    
//    if(items){
//        if(numberOfItem <= items.count){
//            NSMutableArray *newItems = [NSMutableArray array];
//            for(NSInteger i = numberOfItem - 1 ; i >= 0; i --){
//                [newItems addObject:items[i]];
//            }
//            return newItems;
//        }
//        else{
//            return items;
//        }
//    }
//    
//    return nil;
//}

- (NSArray *)getAllPartnerPreferenceAtLevel:(NSInteger) level ForPartner:(Partner *)partner parentCategory:(PreferenceCategory*)parent{
    if (!partner){
        return nil;
    }
    if(level == 1)
    {
        return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 1", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    else{
        return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 2 and parentCategory=%@", partner,parent] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
}


- (NSArray *)getPartnerPreferenceAtLevel:(NSInteger) level withName:(NSString *) name forPartner:(Partner *)partner parentCategory:(PreferenceCategory*)parent{
    if (!partner){
        return nil;
    }
    if(level == 1)
    {
        return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 1 and (name like[c] %@)", partner,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
    else{
        return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@ and level = 2 and parentCategory=%@ and (name like[c] %@)", partner,parent,name] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    }
}

// Get all measurement items
- (NSArray *)getAllItemForPartnerMeasurement:(PartnerMeasurement *)pMeasurement
{
    if (!pMeasurement) {
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"measurement = %@", pMeasurement] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (PartnerMeasurementItem *)getRandomItemForPartnerMeasurement:(PartnerMeasurement *)pMeasurement{
    if (!pMeasurement){
        return nil;
    }
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"measurement = %@", pMeasurement] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
    
    if(items.count == 0){
        return nil;
    }
    else{
        return [items randomObject];
    }
}

- (PartnerMeasurementItem *)getRandomItemForPartnerMeasurement:(NSString *)category forPartner:(Partner *)partner{
    if([NSString isEmpty:category]){
        return nil;
    }
    
    PartnerMeasurement *measurement = [self getPartnerMeasurementWithName:category forPartner:partner];
    if(!measurement){
        return nil;
    }
    
    return [self getRandomItemForPartnerMeasurement:measurement];
}

- (NSArray *)getAllItemMeasurementForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"measurement.partner = %@ and (measurement.sex = %d or measurement.sex = %d)", partner, partner.sex.integerValue, MANAPP_MEASUREMENT_SEX_BOTH] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

// Get all information items
- (NSArray *)getAllItemForPartnerInformation:(PartnerInformation *)pInformation{
    if (!pInformation){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformationItem" withPredicate:[NSPredicate predicateWithFormat:@"information = %@", pInformation] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemInformationForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformationItem" withPredicate:[NSPredicate predicateWithFormat:@"information.partner = %@", partner] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

// Get all preference items
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference{
    if (!pPreference){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@", pPreference] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemForPartnerPreferenceWithOrderByCategoryName:(PreferenceCategory *)pPreference {
    if (!pPreference){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@", pPreference] andSortKey:@"category.name" andSortAscending:YES andContext:self.managedObjectContext];
}

// Get all preference items
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference isLike:(BOOL) isLike{
    if (!pPreference){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@ and isLike = %d", pPreference, isLike] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemForPartnerPreferenceWithOrderByCategoryName:(PreferenceCategory *)pPreference isLike:(BOOL) isLike{
    if (!pPreference){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@ and isLike = %d", pPreference, isLike] andSortKey:@"category.name" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemForParentPartnerPreference:(PreferenceCategory *)pPreference isLike:(BOOL) isLike{
    if (!pPreference){
        return nil;
    }
    NSLog(@"name: %@",pPreference.name);
    NSLog(@"preferenceID: %@",pPreference.preferenceID);
    NSLog(@"level: %@",pPreference.level);
    NSLog(@"parentCategory: %@",pPreference.parentCategory);
    NSLog(@"partner: %@",pPreference.partner);
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category.parentCategory = %@ and isLike = %d", pPreference, isLike] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemForPartner:(Partner *)partner isLike:(BOOL) isLike{
    if (!partner){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category.partner = %@ and isLike = %d", partner, isLike] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemPreferenceForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category.partner = %@", partner] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

#pragma mark - item category
- (void)initDefaultItem{
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_HAIR zIndex:AVATAR_CATEGORY_HAIR_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_SHOE zIndex:AVATAR_CATEGORY_SHOE_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_SHIRT zIndex:AVATAR_CATEGORY_SHIRT_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_PANT zIndex:AVATAR_CATEGORY_PANT_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_GLASS zIndex:AVATAR_CATEGORY_GLASS_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_BEARD zIndex:AVATAR_CATEGORY_BEARD_ZINDEX];
    [self addNewItemCategoryWithName:AVATAR_CATEGORY_ACCESSORY zIndex:AVATAR_CATEGORY_ACCESSORY_ZINDEX];
    
    ItemCategory *beardCategory = [self getCategoryWithName:AVATAR_CATEGORY_BEARD];
    if(beardCategory){
        [self addItemWithName:@"Short Beard" imageURL:@"beard_short_male_%d" order:1 sex:MANAPP_SEX_MALE category:beardCategory icon:@"beard_short_male_icon"];
    }
    
    ItemCategory *hairCategory = [self getCategoryWithName:AVATAR_CATEGORY_HAIR];
    if(hairCategory){
        [self addItemWithName:@"Fro hair" imageURL:@"hair_fro_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:hairCategory icon:@"hair_fro_female_icon"];
        [self addItemWithName:@"Long hair" imageURL:@"hair_long_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:hairCategory icon:@"hair_long_female_icon"];
        [self addItemWithName:@"Medium hair" imageURL:@"hair_medium_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:hairCategory icon:@"hair_medium_female_icon"];
        [self addItemWithName:@"Short hair" imageURL:@"hair_shorthair_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:hairCategory icon:@"hair_shorthair_female_icon"];
        [self addItemWithName:@"Punk hair" imageURL:@"hair_punk_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:hairCategory icon:@"hair_punk_female_icon"];

        //male
        [self addItemWithName:@"Fro hair" imageURL:@"hair_fro_male_%d" order:1 sex:MANAPP_SEX_MALE category:hairCategory icon:@"hair_fro_male_icon"];
        [self addItemWithName:@"Medium hair" imageURL:@"hair_medium_male_%d" order:1 sex:MANAPP_SEX_MALE category:hairCategory icon:@"hair_medium_male_icon"];
        [self addItemWithName:@"Punk hair" imageURL:@"hair_punk_male_%d" order:1 sex:MANAPP_SEX_MALE category:hairCategory icon:@"hair_punk_male_icon"];
//        [self addItemWithName:@"Short hair" imageURL:@"hair_shorthair_male_%d" order:1 sex:MANAPP_SEX_MALE category:hairCategory icon:@"hair_shorthair_male_icon"];
        [self addItemWithName:@"Short hair 2" imageURL:@"hair_shorthair2_male_%d" order:1 sex:MANAPP_SEX_MALE category:hairCategory icon:@"hair_shorthair2_male_icon"];
    }
    
    ItemCategory *glassCategory = [self getCategoryWithName:AVATAR_CATEGORY_GLASS];
    if(glassCategory){
        [self addItemWithName:@"Square glass" imageURL:@"glass_square_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:glassCategory icon:@"glass_square_female_icon"];
        [self addItemWithName:@"Round glass" imageURL:@"glass_round_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:glassCategory icon:@"glass_round_female_icon"];
        [self addItemWithName:@"Round 2 glass" imageURL:@"glass_round2_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:glassCategory icon:@"glass_round2_female_icon"];        
        [self addItemWithName:@"Idiot glass" imageURL:@"glass_idiot_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:glassCategory icon:@"glass_idiot_female_icon"];
        [self addItemWithName:@"Snorkle glass" imageURL:@"glass_snorkle_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:glassCategory icon:@"glass_snorkle_female_icon"];

        
        //male
        [self addItemWithName:@"Square glass" imageURL:@"glass_square_male_%d" order:1 sex:MANAPP_SEX_MALE category:glassCategory icon:@"glass_square_male_icon"];
        [self addItemWithName:@"Round glass" imageURL:@"glass_round_male_%d" order:1 sex:MANAPP_SEX_MALE category:glassCategory icon:@"glass_round_male_icon"];
        [self addItemWithName:@"Round 2 glass" imageURL:@"glass_round2_male_%d" order:1 sex:MANAPP_SEX_MALE category:glassCategory icon:@"glass_round2_male_icon"];         
        [self addItemWithName:@"Idiot glass" imageURL:@"glass_idiot_male_%d" order:1 sex:MANAPP_SEX_MALE category:glassCategory icon:@"glass_idiot_male_icon"];
        [self addItemWithName:@"Snorkle glass" imageURL:@"glass_snorkle_male_%d" order:1 sex:MANAPP_SEX_MALE category:glassCategory icon:@"glass_snorkle_male_icon"];

    }
    
    ItemCategory *shoeCategory = [self getCategoryWithName:AVATAR_CATEGORY_SHOE];
    if(shoeCategory){
        [self addItemWithName:@"Blackpumps" imageURL:@"shoe_blackpumps_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_blackpumps_female_icon"];
        [self addItemWithName:@"Boots" imageURL:@"shoe_boot_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_boot_female_icon"];
        [self addItemWithName:@"High boots" imageURL:@"shoe_high_boot_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_high_boot_female_icon"];
        [self addItemWithName:@"Sandal" imageURL:@"shoe_sandal_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_sandal_female_icon"];
        [self addItemWithName:@"Leather" imageURL:@"shoe_leather_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_leather_female_icon"];
        [self addItemWithName:@"Sport Shoe" imageURL:@"shoe_sport_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shoeCategory icon:@"shoe_sport_female_icon"];        
        
        //male
        [self addItemWithName:@"Boot" imageURL:@"shoe_boot_male_%d" order:1 sex:MANAPP_SEX_MALE category:shoeCategory icon:@"shoe_boot_male_icon"];
        [self addItemWithName:@"Cowboy Shoe 2" imageURL:@"shoe_cowboy2_male_%d" order:1 sex:MANAPP_SEX_MALE category:shoeCategory icon:@"shoe_cowboy2_male_icon"];        
        [self addItemWithName:@"Leather Shoe" imageURL:@"shoe_leather_male_%d" order:1 sex:MANAPP_SEX_MALE category:shoeCategory icon:@"shoe_leather_male_icon"];
        [self addItemWithName:@"Sport Shoe" imageURL:@"shoe_sport_male_%d" order:1 sex:MANAPP_SEX_MALE category:shoeCategory icon:@"shoe_sport_male_icon"];
        [self addItemWithName:@"Cowboy Shoe" imageURL:@"shoe_cowboy_male_%d" order:1 sex:MANAPP_SEX_MALE category:shoeCategory icon:@"shoe_cowboy_male_icon"];
        
        
    }
    
    ItemCategory *shirtCategory = [self getCategoryWithName:AVATAR_CATEGORY_SHIRT];
    if(shirtCategory){
        [self addItemWithName:@"Blouse" imageURL:@"shirt_blouse_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shirtCategory icon:@"shirt_blouse_female_icon"];
        [self addItemWithName:@"Dress" imageURL:@"shirt_dress_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shirtCategory icon:@"shirt_dress_female_icon"];
        [self addItemWithName:@"Suit" imageURL:@"shirt_suit_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shirtCategory icon:@"shirt_suit_female_icon"];
        [self addItemWithName:@"Tee" imageURL:@"shirt_tee_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:shirtCategory icon:@"shirt_tee_female_icon"];
        
        //male
        [self addItemWithName:@"Jacket" imageURL:@"shirt_jacket_male_%d" order:1 sex:MANAPP_SEX_MALE category:shirtCategory icon:@"shirt_jacket_male_icon"];
        [self addItemWithName:@"Short" imageURL:@"shirt_short_male_%d" order:1 sex:MANAPP_SEX_MALE category:shirtCategory icon:@"shirt_short_male_icon"];
        [self addItemWithName:@"Shirt" imageURL:@"shirt_skirt_male_%d" order:1 sex:MANAPP_SEX_MALE category:shirtCategory icon:@"shirt_skirt_male_icon"];
        [self addItemWithName:@"Comple" imageURL:@"shirt_comple_male_%d" order:1 sex:MANAPP_SEX_MALE category:shirtCategory icon:@"shirt_comple_male_icon"];
    }
    
    ItemCategory *pantCategory = [self getCategoryWithName:AVATAR_CATEGORY_PANT];
    if(pantCategory){
        [self addItemWithName:@"Short Jean" imageURL:@"pant_short_jean_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:pantCategory icon:@"pant_short_jean_female_icon"];
        [self addItemWithName:@"Skirt" imageURL:@"pant_skirt_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:pantCategory icon:@"pant_skirt_female_icon"];
        [self addItemWithName:@"Tennis Skirt" imageURL:@"pant_skirt_tennis_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:pantCategory icon:@"pant_skirt_tennis_female_icon"];
        [self addItemWithName:@"Long Suit" imageURL:@"pant_suit_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:pantCategory icon:@"pant_suit_female_icon"];
        [self addItemWithName:@"tutu" imageURL:@"pant_tutu_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:pantCategory icon:@"pant_tutu_female_icon"];
        //
        //male
        [self addItemWithName:@"Short Pant" imageURL:@"pant_short_male_%d" order:1 sex:MANAPP_SEX_MALE category:pantCategory icon:@"pant_short_male_icon"];
        [self addItemWithName:@"Cargo Pant" imageURL:@"pant_cargo_male_%d" order:1 sex:MANAPP_SEX_MALE category:pantCategory icon:@"pant_cargo_male_icon"];
        [self addItemWithName:@"Comple Pant" imageURL:@"pant_comple_male_%d" order:1 sex:MANAPP_SEX_MALE category:pantCategory icon:@"pant_comple_male_icon"];
        [self addItemWithName:@"Jean Pant" imageURL:@"pant_jean_male_%d" order:1 sex:MANAPP_SEX_MALE category:pantCategory icon:@"pant_jean_male_icon"];
        [self addItemWithName:@"Tutu Pant" imageURL:@"pant_tutu_male_%d" order:1 sex:MANAPP_SEX_MALE category:pantCategory icon:@"pant_tutu_male_icon"];        
    }
    
    ItemCategory *accessoryCategory = [self getCategoryWithName:AVATAR_CATEGORY_ACCESSORY];
    if(accessoryCategory){
        [self addItemWithName:@"Tie" imageURL:@"accessory_tie_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:accessoryCategory icon:@"accessory_tie_female_icon"];
        [self addItemWithName:@"Feather" imageURL:@"accessory_feather_female_%d" order:1 sex:MANAPP_SEX_FEMALE category:accessoryCategory icon:@"accessory_feather_female_icon"];
        
        [self addItemWithName:@"Tie" imageURL:@"tie_male_%d" order:1 sex:MANAPP_SEX_MALE category:accessoryCategory icon:@"tie_male_icon"];
    }
}

- (NSArray *)getAllItemCategory{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ItemCategory" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *categories = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return categories;
}

- (ItemCategory *)getCategoryWithName:(NSString *)name{
    NSArray *categories = [CoreDataHelper searchObjectsForEntity:@"ItemCategory" withPredicate:[NSPredicate predicateWithFormat:@"name = %@", name] andSortKey:@"name" andSortAscending:NO andContext:self.managedObjectContext];
    
    if(categories.count <= 0){
        return nil;
    }
    else{
        return [categories firstObject];
    }
}

- (ItemCategory *)addNewItemCategoryWithName:(NSString *)name zIndex:(NSInteger)zIndex{
    //make sure we don't have dplicate category
    ItemCategory *existedCategory = [self getCategoryWithName:name];
    if(existedCategory){
        return nil;
    }
    
    ItemCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCategory" inManagedObjectContext:managedObjectContext];
    category.categoryID = [NSString generateGUID];
    category.name = name;
    category.zIndex = [NSNumber numberWithInt:zIndex];
    NSError *error;
    if([managedObjectContext save:&error]){
        return category;
    }
    else{
        DLog(@"insert item category failed: %@",error);
        return nil;
    }
}

#pragma mark - items for avatar
- (NSArray *)getAllItem{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return items;
}

- (NSArray *)getAllItemForSex:(NSInteger)sex{
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"Item" withPredicate:[NSPredicate predicateWithFormat:@"sex = %d", sex] andSortKey:@"order" andSortAscending:NO andContext:self.managedObjectContext];
    
    return items;
}

- (NSArray *)getAllItemByName:(NSString *)name{
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"Item" withPredicate:[NSPredicate predicateWithFormat:@"name = %@", name] andSortKey:@"order" andSortAscending:NO andContext:self.managedObjectContext];
    
    return items;
}

- (NSArray *)getAllItemByName:(NSString *)name andSex:(BOOL)sex{
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"Item" withPredicate:[NSPredicate predicateWithFormat:@"name = %@ AND sex = %d", name, sex] andSortKey:@"order" andSortAscending:NO andContext:self.managedObjectContext];
    
    return items;
}

- (NSArray *)getAllItemForCategory:(ItemCategory *)category{
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"Item" withPredicate:[NSPredicate predicateWithFormat:@"itemCategory = %@", category] andSortKey:@"order" andSortAscending:NO andContext:self.managedObjectContext];
    
    return items;
}

- (NSArray *)getAllItemForCategory:(ItemCategory *)category sex:(NSInteger)sex{
    NSArray *items = [CoreDataHelper searchObjectsForEntity:@"Item" withPredicate:[NSPredicate predicateWithFormat:@"itemCategory = %@ AND sex = %d", category, sex] andSortKey:@"order" andSortAscending:NO andContext:self.managedObjectContext];
    
    return items;
}

- (Item *)addItemWithName:(NSString *)name imageURL:(NSString *)url order:(NSInteger) order sex:(NSInteger)sex category:(ItemCategory *)category icon:(NSString *)icon{
    NSArray *existedItem = [self getAllItemByName:name andSex:sex];
    if(existedItem.count > 0){
        DLog(@"item exited, cannot add new item with same name");
        return nil;
    }
    
    Item* item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:managedObjectContext];
    item.itemID = [NSString generateGUID];
    item.name = name;
    item.imageURLFormat = url;
    item.order = [NSNumber numberWithInt:order];
    item.sex = [NSNumber numberWithInt:sex];
    item.isDefault = [NSNumber numberWithBool:YES];
    item.itemCategory = category;
    item.icon = icon;
    NSError *error;
    if([managedObjectContext save:&error]){
        return item;
    }
    else{
        DLog(@"insert item failed: %@",error);
        return nil;
    }
}

#pragma mark - item to partner
- (NSArray *)getItemsForPartner:(Partner *)partner{
    NSArray *partnerItems = partner.avatarToItem.allObjects;
    NSMutableArray *itemsForPartner = [NSMutableArray array];
    for(ItemToAvatar *partnerItem in partnerItems){
        if(partnerItem.item.sex.intValue == partner.sex.intValue){
            [itemsForPartner addObject:partnerItem];
        }
    }
    
    return itemsForPartner;
}

- (ItemToAvatar *)getItemForPartner:(Partner *)partner ofCategory:(ItemCategory *)category{
    NSArray *partnerItems = partner.avatarToItem.allObjects;
    NSMutableArray *itemsForPartner = [NSMutableArray array];
    for(ItemToAvatar *partnerItem in partnerItems){
        if(partnerItem.item.sex.intValue == partner.sex.intValue && [partnerItem.item.itemCategory isEqual:category]){
            [itemsForPartner addObject:partnerItem];
        }
    }
    
    if(itemsForPartner.count > 0){
        return itemsForPartner[0];
    }
    else{
        return nil;
    }
}

- (BOOL)addItem:(Item *)item toPartner:(Partner *)partner{
    //make sure we don't have duplicate item in a same category
    NSArray *itemAvatars = [CoreDataHelper searchObjectsForEntity:@"ItemToAvatar" withPredicate:[NSPredicate predicateWithFormat:@"item.itemCategory = %@ AND partner = %@", item.itemCategory, partner] andSortKey:@"partner" andSortAscending:NO andContext:self.managedObjectContext];
    if(itemAvatars.count > 0){
        DLog(@"This item is already assign to this partner");
        
        for(ItemToAvatar *itemAvatar in itemAvatars){
            [self removeItem:itemAvatar.item fromPartner:itemAvatar.partner];
        }
    }

    ItemToAvatar* itemToAvatar = [NSEntityDescription insertNewObjectForEntityForName:@"ItemToAvatar" inManagedObjectContext:managedObjectContext];
    itemToAvatar.item = item;
    itemToAvatar.partner = partner;

    NSError *error;
    if([managedObjectContext save:&error]){
        return YES;
    }
    else{
        DLog(@"add item to partner failed: %@",error);
        return NO;
    }
}

- (BOOL)removeItemOfCategory:(ItemCategory *)category fromPartner:(Partner *)partner{
    NSArray *itemAvatars = [CoreDataHelper searchObjectsForEntity:@"ItemToAvatar" withPredicate:[NSPredicate predicateWithFormat:@"item.itemCategory = %@ AND partner = %@", category, partner] andSortKey:@"partner" andSortAscending:NO andContext:self.managedObjectContext];
    if(itemAvatars.count > 0){
        for(ItemToAvatar *itemAvatar in itemAvatars){
            [self removeItem:itemAvatar.item fromPartner:itemAvatar.partner];
        }
    }
    
    NSError *error;
    if([managedObjectContext save:&error]){
        return YES;
    }
    else{
        DLog(@"remove item of category from partner failed: %@",error);
        return NO;
    }
}

- (BOOL)removeItem:(Item *)item fromPartner:(Partner *)partner{
    NSArray *itemAvatars = [CoreDataHelper searchObjectsForEntity:@"ItemToAvatar" withPredicate:[NSPredicate predicateWithFormat:@"item = %@ AND partner = %@", item, partner] andSortKey:@"partner" andSortAscending:NO andContext:self.managedObjectContext];
    if(itemAvatars.count > 0){
        for(ItemToAvatar *itemToAvatar in itemAvatars){
            [partner removeAvatarToItemObject:itemToAvatar];
            [self deleteManagedObject:itemToAvatar];
        }
        
        return YES;
    }
    else{
        DLog(@"This partner don't have any item");
        return NO;
    }
}

#pragma mark - message
- (NSArray *)getAllMessage{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    return items;
}

- (NSInteger)countAllMessage {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSInteger count = [managedObjectContext countForFetchRequest:request error:&error];
    [request release];
    return count;
}

- (BOOL)removeMessage:(NSString *)messageID {
    if (!messageID) {
        return NO;
    }
    NSArray *messages = [CoreDataHelper searchObjectsForEntity:@"Message" withPredicate:[NSPredicate predicateWithFormat:@"messageID = %@", messageID] andSortKey:nil andSortAscending:NO andContext:self.managedObjectContext];
    if(messages.count > 0){
        [self deleteManagedObject:messages.firstObject];
        return YES;
    }
    else {
        DLogInfo(@"This messageID: %@ don't have any item",messageID);
        return NO;
    }
}

- (Message *)getNewestMessage {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    return items.lastObject;
}

- (Message*) messageFromId:(NSString *) messageID{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(messageID = %@)", messageID];
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerZoneList count]>0)
        return [partnerZoneList objectAtIndex:([partnerZoneList count] - 1)];
    else
        return NULL;
}

- (Message *)messageFromMessageDTO:(MessageDTO *)messageDTO{
    Message *message = [self messageFromId:messageDTO.messageID];
    
    if(!message){
        message = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
        message.messageID = messageDTO.messageID;
    }
    
    message.message = messageDTO.message;
    message.secondMessage = messageDTO.secondMessage;
    message.sex = @(messageDTO.sex);
    message.moodLower = @(messageDTO.moodLower);
    message.moodHigher = @(messageDTO.moodHigher);
    message.categoryA = messageDTO.categoryA;
    message.categoryB = messageDTO.categoryB;
    message.subCategoryA = messageDTO.subCategoryA;
    message.subCategoryB = messageDTO.subCategoryB;
    message.eventDate = messageDTO.eventDate;
    message.type = messageDTO.type;
    
    NSError *savingError = nil;
    if ([self.managedObjectContext save:&savingError]){
        return message;
    } else {
        DLog(@"Failed to save the new Partner birthday event. Error = %@", savingError);
        return nil;
    }
}

- (Message*)getMessageForType:(NSString *) type{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@", type];
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerZoneList count]>0){
        return [partnerZoneList randomObject];
    }
    else
        return NULL;
}

- (PartnerMessages *)getMessage:(Message *) message ofPartner:(Partner *)partner{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerMessages" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner = %@ AND message = %@)", partner, message];
    [request setPredicate: pred];
    NSError *error;
    NSArray *messages = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([messages count]>0)
        return [messages objectAtIndex:([messages count] - 1)];
    else
        return NULL;
}

- (NSArray *)partnerMessagesForPartner:(Partner *)partner{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerMessages" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner = %@)", partner];
    [request setPredicate: pred];
    NSError *error;
    NSArray *messages = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    return messages;
}

- (NSArray *)messagesForPartner:(Partner *)partner{
    
    NSLog(@"------Partner: %@", partner);
    NSMutableArray *messages;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"PartnerMessages" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner == %@)", partner];
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerMessages = [self.managedObjectContext executeFetchRequest:request error:&error];
//     NSMutableArray *partnerMessages = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    [request release];
    if (!partnerMessages) {
        NSLog(@"-------Error: %@", error);
        messages = nil;
    }
    NSLog(@"-------partnerMessages: %@", partnerMessages);
    
    messages = [NSMutableArray array];
    for(PartnerMessages *partnerMessage in partnerMessages){
        if (partnerMessage && partnerMessage.message) {
            [messages addObject:partnerMessage.message];
            NSLog(@"-------sexxxxx : %@", partnerMessage.message.sex);
        }
    }
    NSLog(@"-------Message: %@", messages);
    return messages;
}

- (BOOL)addMessage:(Message *) message toPartner:(Partner *)partner{
    PartnerMessages *partnerMessage = [self getMessage:message ofPartner:partner];
    
    if(!partnerMessage){
        partnerMessage = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMessages" inManagedObjectContext:self.managedObjectContext];
        partnerMessage.partnerMessageId = [NSString generateGUID];
        partnerMessage.message = message;
        partnerMessage.partner = partner;
        [self.managedObjectContext save:nil];        
        return YES;
    }
    
    return NO;
}

- (void)renewMessagesForPartner:(Partner *)partner{
    NSArray *partnerMessages = [self partnerMessagesForPartner:partner];
    for (PartnerMessages *partnerMessage in partnerMessages) {
        [self.managedObjectContext deleteObject:partnerMessage];
    }
    [self saveContext];
    //Cuongnt comment -- Get mood Value Today
    // get PartnerMood for partner today:
    PartnerMood *partnerMood = [[DatabaseHelper sharedHelper]partnerMoodWithPartner:partner date:[NSDate date]];
    
//    CGFloat moodValue = [MoodHelper calculateMoodAtDate:[NSDate date] forPartner:partner]; //return wrong mood value
//    if(moodValue == MA_MOOD_UNAVAILABLE_VALUE){
//        moodValue = 0;
//    }
    
    // Cuongnt Add More

    CGFloat moodValue = [partnerMood.moodValue floatValue];
    if (!moodValue || moodValue == MA_MOOD_UNAVAILABLE_VALUE) {
         moodValue = 0;
    }
    //--------------- end -------------------
    ///----------------- remove after test successful ---------------------
//    //1 mood message -->> create 10 Mood Message
//    for (int i =0 ; i< 15; i++) {
//        Message *moodTodayMsg = [self getMessageForType:MANAPP_MESSAGE_TYPE_MOOD partner:partner mood:moodValue];
//        if (moodTodayMsg) {
//            [self addMessage:moodTodayMsg toPartner:partner];
//        }
//        
//    }
    //1 mood message
    Message *messageMood = [self getMessageForType:MANAPP_MESSAGE_TYPE_MOOD partner:partner mood:moodValue];
    [self addMessage:messageMood toPartner:partner];

    //1 mood message Future
    Message *messageMoodFuture = [self getMessageForType:MANAPP_MESSAGE_TYPE_MOOD_FUTURE partner:partner mood:moodValue];
    [self addMessage:messageMoodFuture toPartner:partner];
    
    //10 gen message
    NSInteger successCount = 0;
    for(NSInteger i = 0; i < 15; i ++){
        Message *messageGen = [[DatabaseHelper sharedHelper] getMessageForType:MANAPP_MESSAGE_TYPE_GEN partner:partner mood:-1];
        if([self addMessage:messageGen toPartner:partner]){
            successCount++;
        }
        
        if(successCount >= 10){
            break;
        }
    }
    
    //10 gen other
    successCount = 0;
    for(NSInteger i = 0; i < 15; i ++){
        //random type
        int type = arc4random()%3;
        switch (type) {
            case 0:
            {
                Message *messageSize = [[DatabaseHelper sharedHelper] getMessageForType:MANAPP_MESSAGE_TYPE_SIZE partner:partner mood:-1];
                if([self addMessage:messageSize toPartner:partner]){
                    successCount++;
                }
            }
                break;
            case 1:
            {
                Message *messageLike = [[DatabaseHelper sharedHelper] getMessageForType:MANAPP_MESSAGE_TYPE_LIKES partner:partner mood:-1];
                if([self addMessage:messageLike toPartner:partner]){
                    successCount++;
                }
            }
                break;
            case 2:
            {
                Message *messageInfo = [[DatabaseHelper sharedHelper] getMessageForType:MANAPP_MESSAGE_TYPE_INFO partner:partner mood:-1];
                if([self addMessage:messageInfo toPartner:partner]){
                    successCount++;
                }
            }
                break;
            default:
                break;
        }
        
        if(successCount >= 10){
            break;
        }
    }
}

/*mood : -1 mean mood didn't set*/
- (Message*)getMessageForType:(NSString *) type partner:(Partner *)partner mood:(CGFloat)mood{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = nil;
    if(mood >= 0){
        pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND moodLower <= %f AND moodHigher >= %f ", type, partner.sex.integerValue, mood, mood];
    }
    else{
        pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d ", type, partner.sex.integerValue];
    }
    [request setPredicate: pred];
    NSError *error;
    NSArray *partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    
    [request release];
    
    if([partnerZoneList count]>0){
        return [partnerZoneList randomObject];
    }
    else
        return NULL;
}

// show message when day util 7,14,31 (one week, two week, one month)
- (Message*)getEventMessageForPartner:(Partner *)partner{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = nil;
    
    if(partner.dateOfBirth){
        NSLog(@"dateOfBirth: %d - %@",[NSDate dayUntilBirthDate:partner.dateOfBirth], partner.dateOfBirth);
        // if Birthday >  current date then show.
        NSLog(@"****** %d", [NSDate dayUntilBirthDate:partner.dateOfBirth]);
        if ([NSDate dayUntilBirthDate:partner.dateOfBirth] > 0) {
            //one month from the birthdate celebration
            if(([NSDate dayUntilBirthDate:partner.dateOfBirth] <= 7)){
                pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND eventDate LIKE[c] %@ ", MANAPP_MESSAGE_TYPE_EVENT, partner.sex.integerValue, MANAPP_MESSAGE_EVENT_TIME_ONE_WEEK];
            }
            else if(([NSDate dayUntilBirthDate:partner.dateOfBirth] <= 14)){
                pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND eventDate LIKE[c] %@ ", MANAPP_MESSAGE_TYPE_EVENT, partner.sex.integerValue, MANAPP_MESSAGE_EVENT_TIME_TWO_WEEK];
            }
            //else if(([NSDate dayUntilBirthDate:partner.dateOfBirth] <= 31)
            else if(([NSDate dayUntilBirthDate:partner.firstDate] <= 31)){// will change to firstDate
                pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND eventDate LIKE[c] %@ ", MANAPP_MESSAGE_TYPE_EVENT, partner.sex.integerValue, MANAPP_MESSAGE_EVENT_TIME_ONE_MONTH];
            }
            else{
                BOOL isFertile = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveFertileInDate:[NSDate date]];
                if(isFertile){
                    pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND eventDate LIKE[c] %@ ", MANAPP_MESSAGE_TYPE_EVENT, partner.sex.integerValue, MANAPP_MESSAGE_EVENT_TIME_SPERM];
                }
                else {
                    BOOL isMenstrate = [[DatabaseHelper sharedHelper] isPartner:[MASession sharedSession].currentPartner haveMenstrationInDate:[NSDate date]];
                    if(isMenstrate){
                        pred = [NSPredicate predicateWithFormat:@"type LIKE[c] %@ AND sex = %d AND eventDate LIKE[c] %@ ", MANAPP_MESSAGE_TYPE_EVENT, partner.sex.integerValue, MANAPP_MESSAGE_EVENT_TIME_RED_CIRCLE];
                    }
                }
            }
        } else {// end if ([NSDate dayUntilBirthDate:partner.dateOfBirth] > 0) {
            NSLog(@"Birthday < current date");
        }

    }
    else{
        
    }
    NSArray *partnerZoneList = nil;
    if(pred){
        [request setPredicate: pred];
        NSError *error;
        partnerZoneList = [managedObjectContext executeFetchRequest:request error:&error];
    }
    if([partnerZoneList count] > 0){
        return [partnerZoneList randomObject];
    } else {
        return NULL;
    }
}

- (NSString *)getContentForMessage:(Message *)message partner:(Partner *)partner{
    NSString *content = nil;
    if(message && partner){
        DLogInfo(@"Mood type: %@",message.type);
        if([message.type isEqualToString:MANAPP_MESSAGE_TYPE_MOOD] || [message.type isEqualToString:MANAPP_MESSAGE_TYPE_MOOD_FUTURE] || [message.type isEqualToString:MANAPP_MESSAGE_TYPE_GEN] || [message.type isEqualToString:MANAPP_MESSAGE_TYPE_LIKES] || [message.type isEqualToString:MANAPP_MESSAGE_TYPE_DISLIKE]){
            BOOL isACategoryRequire = [message.message isContainSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A];
            BOOL isBCategoryRequire = [message.message isContainSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_B];
            
            if(!isACategoryRequire && !isBCategoryRequire){
                content = message.message;
            }
            else if(isACategoryRequire && !isBCategoryRequire){
                // fixed leak
//                content = message.message;
                
                PreferenceItem *preferenceItem = [self getRandomItemForSubPreferenceCategory:message.subCategoryA parentCategory:message.categoryA forPartner:partner];
                if(preferenceItem){
                    content = message.message;
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A byString:preferenceItem.name];
                }
                else{
                    if([NSString isEmpty:message.secondMessage]){
                        content = message.message;
                    }
                    else{
                        content = message.secondMessage;
                    }
                }
            }
            else if(!isACategoryRequire && isBCategoryRequire){
                  // fixed leak
//                content = message.message;
                
                PreferenceItem *preferenceItem = [self getRandomItemForSubPreferenceCategory:message.subCategoryB parentCategory:message.categoryB forPartner:partner];
                if(preferenceItem){
                    content = message.message;
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_B byString:preferenceItem.name];
                }
                else{
                    if([NSString isEmpty:message.secondMessage]){
                        content = message.message;
                    }
                    else{
                        content = message.secondMessage;
                    }
                }
            }
            else if(isACategoryRequire && isBCategoryRequire){
                  // fixed leak
//                content = message.message;
                
                PreferenceItem *preferenceItemA = [self getRandomItemForSubPreferenceCategory:message.subCategoryA parentCategory:message.categoryA forPartner:partner];
                
                PreferenceItem *preferenceItemB = [self getRandomItemForSubPreferenceCategory:message.subCategoryB parentCategory:message.categoryB forPartner:partner];
                
                if(preferenceItemA && preferenceItemB){
                    content = message.message;
                    
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A byString:preferenceItemA.name];
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_B byString:preferenceItemB.name];
                }
                else{
                    content = message.secondMessage;
                }
            }
        }
        else if([message.type isEqualToString:MANAPP_MESSAGE_TYPE_SIZE]){
            BOOL isACategoryRequire = [message.message isContainSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A];
            if(!isACategoryRequire){
                content = message.message;
            }
            else if(isACategoryRequire){
                // fixed leak
//                content = message.message;
                
                PartnerMeasurementItem *measurementItem = [self getRandomItemForPartnerMeasurement:message.subCategoryA forPartner:partner];
                if(measurementItem){
                    content = message.message;
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A byString:measurementItem.name];
                }
                else{
                    if([NSString isEmpty:message.secondMessage]){
                        content = message.message;
                    }
                    else{
                        content = message.secondMessage;
                    }
                }
            }
        }
        else if([message.type isEqualToString:MANAPP_MESSAGE_TYPE_INFO]){
            content = message.message;
        }
        else if([message.type isEqualToString:MANAPP_MESSAGE_TYPE_EVENT]){
            content = message.message;
            
            BOOL isACategoryRequire = [message.message isContainSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A];
            if(!isACategoryRequire){
                content = message.message;
            }
            else if(isACategoryRequire){
                  // fixed leak
//                content = message.message;
                
                NSArray *preferenceItems = [self getRandomItemForParentCategory:message.categoryA isLike:YES forPartner:partner numberOfItem:3];
                if(preferenceItems && preferenceItems.count > 0){
                    NSString *name = @"";
                    NSInteger count = 0;
                    for(PreferenceItem *item in preferenceItems){
                        count++;
                        if(count == preferenceItems.count){
                            name = [name stringByAppendingFormat:@"%@", item.name];
                        }
                        else{
                            name = [name stringByAppendingFormat:@"%@, ", item.name];
                        }
                    }
                    content = message.message;
                    content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_CATEGORY_A byString:name];
                }
                else{
                    if([NSString isEmpty:message.secondMessage]){
                        content = message.message;
                    }
                    else{
                        content = message.secondMessage;
                    }
                }
            }
        }
        
        if(content){
            content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_NAME byString:partner.name];
            if(partner.dateOfBirth){
                content = [content replaceSubString:MANAPP_MESSAGE_PLACEHOLDER_DOB byString:[partner.dateOfBirth toString]];
            }
            
            content = [content removeNewLineCharacter];
        }
    }
    
    return content;
}

#pragma mark - data functions
// Delete a managed object
- (BOOL)deleteManagedObject:(NSManagedObject *)obj
{
    if (!obj) {
        return NO;
    }
    [self.managedObjectContext deleteObject:obj];
    [self saveContext];
    return YES;
    
}

// Create new managed object
- (NSManagedObject *)newManagedObjectForEntity:(NSString *)entity
{
    return [[NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self.managedObjectContext] retain];
}
//Revert change
- (void)revertChanges
{
    if (self.managedObjectContext.undoManager.canUndo) {
        [self.managedObjectContext.undoManager endUndoGrouping];
        [self.managedObjectContext.undoManager undo];
    }
}
@end
