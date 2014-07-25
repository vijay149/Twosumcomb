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
#import <TapkuLibrary/NSDate+TKCategory.h>
#import "NSDate+Helper.h"

@implementation DatabaseHelper
@synthesize managedObjectContext;

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
        MAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
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

//add new event
- (BOOL) createNewPartnerEventWithEventName:(NSString *)eventName andEventTime:(NSDate *)eventTime andNote: (NSString *)note andPartnerId:(NSInteger)partnerId andRecurrence: (NSString *)recurrence andReminder: (NSString *)reminder{
    Partner *selectedPartner = [[DatabaseHelper sharedHelper] getPartnerById:partnerId];
    if(selectedPartner)
    {
        BOOL result = NO;
        if (recurrence.length > 0 && ![recurrence isEqualToString:MANAPP_EVENT_RECURRING_NEVER]) {
            NSDate *startTime = eventTime;
            NSDate *endTime = [startTime dateByAddingDays:1000];
            NSString *recurringID = [NSString generateGUID];
            NSInteger recurringDay = [startTime dateInformation].day;
            while (1) {
                if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_DAILY]) {
                    Event *partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                    if (partnerEvent == nil){
                        DLog(@"Failed to create the new PartnerEvent.");
                        return NO;
                    }
                    partnerEvent.eventID = [NSString generateGUID];
                    partnerEvent.eventName = eventName;
                    partnerEvent.eventTime = startTime;
                    partnerEvent.note = note;
                    //partnerEvent.userID = [NSNumber numberWithUnsignedInteger:userId];
                    partnerEvent.partner = selectedPartner;
                    partnerEvent.recurrence = recurrence;
                    partnerEvent.reminder = reminder;
                    partnerEvent.recurringID = recurringID;
                    startTime = [startTime dateByAddingDays:1];
                } else if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_WEEKLY]) {
                    Event *partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                    if (partnerEvent == nil){
                        DLog(@"Failed to create the new PartnerEvent.");
                        return NO;
                    }
                    partnerEvent.eventID = [NSString generateGUID];
                    partnerEvent.eventName = eventName;
                    partnerEvent.eventTime = startTime;
                    partnerEvent.note = note;
                    partnerEvent.partner = selectedPartner;
                    partnerEvent.recurrence = recurrence;
                    partnerEvent.reminder = reminder;
                    partnerEvent.recurringID = recurringID;                
                    startTime = [startTime dateByAddingDays:7];
                } else if ([recurrence isEqualToString:MANAPP_EVENT_RECURRING_MONTHLY]) {
                    TKDateInformation info = [startTime dateInformation];
                    if (info.day == recurringDay) {
                        Event *partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                        if (partnerEvent == nil){
                            DLog(@"Failed to create the new PartnerEvent.");
                            return NO;
                        }
                        partnerEvent.eventID = [NSString generateGUID];
                        partnerEvent.eventName = eventName;
                        partnerEvent.eventTime = startTime;
                        partnerEvent.note = note;
                        partnerEvent.partner = selectedPartner;
                        partnerEvent.recurrence = recurrence;
                        partnerEvent.reminder = reminder;
                        partnerEvent.recurringID = recurringID;
                    }
                    startTime = [startTime dateByAddingDays:1];
                }
                if ([startTime compare:endTime] == NSOrderedDescending) {
                    break;
                }
            }
        } else {
            Event *partnerEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
            if (partnerEvent == nil){
                DLog(@"Failed to create the new PartnerEvent.");
                return NO;
            }
            partnerEvent.eventID = [NSString generateGUID];
            partnerEvent.eventName = eventName;
            partnerEvent.eventTime = eventTime;
            partnerEvent.note = note;
            partnerEvent.partner = selectedPartner;
            partnerEvent.recurrence = recurrence;
            partnerEvent.reminder = reminder;
            partnerEvent.recurringID = @"";
        }
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){ 
            return YES;
        } else {
            DLog(@"Failed to save the new PartnerEvent. Error = %@", savingError); 
        }
        return result;
    }
    return NO;
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
                DLog(@"Successfully saved the context."); 
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
    NSLog(@"%@-------------------",date);
    // COMMENT: Get date only (remove hours)
    //unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //NSDateComponents *components = [calendar components:flags fromDate:date];
    //NSDate *dateLowerBound = [calendar dateFromComponents:components];
    NSDateComponents *minuteComponents = [[[NSDateComponents alloc] init] autorelease];
    minuteComponents.minute = -1;
    NSDate *dateLowerBound = [calendar dateByAddingComponents:minuteComponents toDate:date options:0];
    NSDateComponents *dayComponents = [[[NSDateComponents alloc] init] autorelease];
    dayComponents.day = 1;
    NSDate* dateHigherBound = [calendar dateByAddingComponents:dayComponents toDate:dateLowerBound options:0];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
    [request setEntity:description];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(partner.partnerID = %d) AND (eventTime >= %@) AND (eventTime < %@)", partnerId,dateLowerBound,dateHigherBound]; 
    [request setPredicate: pred];
    NSError *error;
    NSArray *eventList = [managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
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
    }
    return NO;
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
        [self.managedObjectContext deleteObject:[arr objectAtIndex:0]];
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

-(NSInteger) addEroZoneWithName:(NSString*) zoneName{
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
    ErogeneousZone* eroZone = [NSEntityDescription insertNewObjectForEntityForName:@"ErogeneousZone" inManagedObjectContext:managedObjectContext];
    eroZone.erogeneousZoneID = [NSNumber numberWithInt:(maxId + 1)];
    eroZone.name = zoneName;
    NSError *error;
    if([managedObjectContext save:&error]){
        DLog(@"insert ero zone success: %@",error);
        return TRUE;
    }
    else{
        DLog(@"insert ero zone failed: %@",error);
        return FALSE;
    }

}
/**********************************************************
 @Function description: generate new data when the application first lauch
 @Note:
 ***********************************************************/
-(void) initEroZoneData{
    NSArray *zoneList = [self getAllEroZone];
    if([zoneList count] == 0){
        [self addEroZoneWithName:@"Feet"];
        [self addEroZoneWithName:@"Lower Leg"];
        [self addEroZoneWithName:@"Upper Leg"];
        [self addEroZoneWithName:@"Pelvic Area"];
        [self addEroZoneWithName:@"Abdomen"];
        [self addEroZoneWithName:@"Chest"];
        [self addEroZoneWithName:@"Neck"];
        [self addEroZoneWithName:@"Arm"];
        [self addEroZoneWithName:@"Hand"];
        [self addEroZoneWithName:@"Head"];
    }
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
/*********************************************************************************
 @Function description: add new partner zone
 @Note: only add if there isn't any data for this partner and zone
*********************************************************************************/
-(NSInteger) addPartnerEroZoneForPartner:(NSInteger) partnerId andZone:(NSInteger) zoneId withValue:(NSString*) value{
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
            return TRUE;
        }
        else{
            DLog(@"insert partner ero zone failed: %@",error);
            return FALSE;
        }

    }
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

// Get PartnerMood by Id
- (PartnerMood *)partnerMoodWithId:(NSString *)moodId
{
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"moodId = %@", moodId] andSortKey:@"addedTime" andSortAscending:NO andContext:self.managedObjectContext];
    if (arr.count > 0) {
        return [arr lastObject];
    }
    return nil;
}

// Get PartnerMood with PartnerId and Date
- (PartnerMood *)partnerMoodWithPartnerId:(NSInteger)partnerId date:(NSDate *)date
{
    NSArray *arr = [CoreDataHelper searchObjectsForEntity:kEntityPartnerMood withPredicate:[NSPredicate predicateWithFormat:@"partner.partnerID = %@ AND addedTime = %@", [NSNumber numberWithInt:partnerId], [date dateOnly]] andSortKey:@"addedTime" andSortAscending:NO andContext:self.managedObjectContext];
    if (arr.count > 0) {
        return [arr lastObject];
    }
    return nil;
}

// Add/Update Mood Value with PartnerId and Date
- (void)addMoodValue:(NSNumber *)moodValue forPartnerWithId:(NSInteger)partnerId date:(NSDate *)date
{
    PartnerMood *partnerMood = [self partnerMoodWithPartnerId:partnerId date:date];
    if (!partnerMood) {
        partnerMood = [NSEntityDescription insertNewObjectForEntityForName:kEntityPartnerMood inManagedObjectContext:self.managedObjectContext];
        partnerMood.moodID = [NSString generateGUID];
    }
    partnerMood.moodValue = moodValue;
    partnerMood.addedTime = [date dateOnly];
    partnerMood.partner = [self getPartnerById:partnerId];
    [self saveContext];
}

// Remove PartnerMood at a specific Date
- (BOOL)removePartnerMoodWithPartnerWithId:(NSInteger)partnerId date:(NSDate *)date
{
    PartnerMood *mood = [self partnerMoodWithPartnerId:partnerId date:date];
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
    for (NSString *name in measurementArr) {
        PartnerMeasurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMeasurement" inManagedObjectContext:self.managedObjectContext];
        measurement.name = name;
        measurement.measurementID = [NSString generateGUID];
        measurement.timestamp = [NSDate date];
        measurement.partner = partner;
    }
    [self saveContext];
    return YES;
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
    for (NSString *name in informationArr){
        PartnerInformation *information = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
        information.name = name;
        information.infoID = [NSString generateGUID];
        information.timestamp = [NSDate date];
        information.partner = partner;
    }
    [self saveContext];
    return YES;
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

// Add new subcategory
- (BOOL) addNewPreferenceCategoryForCategory:(PreferenceCategory *)pPreference withName:(NSString*)name{
    if (!pPreference){
        return NO;
    }
    if (!pPreference.partner){
        return NO;
    }
    
    PreferenceCategory *subPreference = [NSEntityDescription insertNewObjectForEntityForName:@"PreferenceCategory" inManagedObjectContext:self.managedObjectContext];
    subPreference.name = name;
    subPreference.preferenceID = [NSString generateGUID];
    subPreference.timestamp = [NSDate date];
    subPreference.partner = pPreference.partner;
    subPreference.level = [NSNumber numberWithInt:2];
    subPreference.parentCategory = pPreference;
    
    [self saveContext];
    return YES;
}

- (BOOL)addNewMeasurementCategoryForPartner:(Partner *)partner withName:(NSString *)name{
    if (!partner) {
        return NO;
    }

    PartnerMeasurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerMeasurement" inManagedObjectContext:self.managedObjectContext];
    measurement.name = name;
    measurement.measurementID = [NSString generateGUID];
    measurement.timestamp = [NSDate date];
    measurement.partner = partner;
    [self saveContext];
    return YES;
}

// add new information category
- (BOOL)addNewInformationCategoryForPartner:(Partner *)partner withName:(NSString *)name{
    if (!partner){
        return NO;
    }

    PartnerInformation *information = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerInformation" inManagedObjectContext:self.managedObjectContext];
    information.name = name;
    information.infoID = [NSString generateGUID];
    information.timestamp = [NSDate date];
    information.partner = partner;
    
    [self saveContext];
    return YES;
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

// Get all partner measurement for a specific partner
- (NSArray *)getAllPartnerMeasurementForPartner:(Partner *)partner
{
    if (!partner) {
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurement" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}
// Get all partner information for a specific partner
- (NSArray *)getAllPartnerInformationForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformation" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}
//Get all partner preference for a specific partner
- (NSArray *)getAllPartnerPreferenceForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceCategory" withPredicate:[NSPredicate predicateWithFormat:@"partner = %@", partner] andSortKey:@"timestamp" andSortAscending:YES andContext:self.managedObjectContext];
}

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

// Get all measurement items
- (NSArray *)getAllItemForPartnerMeasurement:(PartnerMeasurement *)pMeasurement
{
    if (!pMeasurement) {
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"measurement = %@", pMeasurement] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemMeasurementForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PartnerMeasurementItem" withPredicate:[NSPredicate predicateWithFormat:@"measurement.partner = %@", partner] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

// Get all information items
- (NSArray *)getAllItemForPartnerInformation:(PartnerInformation *)pInformation{
    if (!pInformation){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PartnerInformationItem" withPredicate:[NSPredicate predicateWithFormat:@"information = %@", pInformation] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
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
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@", pPreference] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

// Get all preference items
- (NSArray *)getAllItemForPartnerPreference:(PreferenceCategory *)pPreference isLike:(BOOL) isLike{
    if (!pPreference){
        return nil;
    }
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category = %@ and isLike = %d", pPreference, isLike] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

- (NSArray *)getAllItemPreferenceForPartner:(Partner *)partner{
    if (!partner){
        return nil;
    }
    
    return [CoreDataHelper searchObjectsForEntity:@"PreferenceItem" withPredicate:[NSPredicate predicateWithFormat:@"category.partner = %@", partner] andSortKey:@"timestamp" andSortAscending:NO andContext:self.managedObjectContext];
}

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
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self.managedObjectContext];
}
@end
