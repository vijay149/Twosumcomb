//
//  MAUserProcessManager.m
//  Manapp
//
//  Created by Demigod on 21/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MAUserProcessManager.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "UICustomProgressBar.h"
#import "MASession.h"
#import "AvatarHelper.h"
@implementation MAUserProcessManager

+(id) sharedInstance{
    static MAUserProcessManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MAUserProcessManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _isLikeEnough = FALSE;
        _isDislikeEnough = FALSE;
        _isInformationEnough = FALSE;
        _isMeasurementEnough = FALSE;
        _isSpecialZoneEnough = FALSE;
        //check if the setup step is in database or not, if not then initialize them
        [[DatabaseHelper sharedHelper] initSetupStepData];
    }
    return self;
}

#pragma mark - process functions
-(CGFloat) getProcessForCurrentPartner{
    
    if(![MASession sharedSession].currentPartner){
        return 0;
    }
    
    [self numberOfPreferenceLeft:YES];
    [self numberOfPreferenceLeft:NO];
    [self numberOfInformationLeft];
    [self numberOfMeasurementLeft];
    [self numberOfSpecialZoneLeft];
    
//    CGFloat process = 0;
//    if(_isLikeEnough){
//        process += 1;
//    }
//    
//    if(_isDislikeEnough) {
//        process += 1;
//    }
//    
//    if(_isInformationEnough) {
//        process += 1;
//    }
//    
//    if(_isMeasurementEnough) {
//        process += 1;
//    }
//    
//    if(_isSpecialZoneEnough) {
//        process += 1;
//    }
    NSInteger percentTotal = [self percentOfPreference:YES] + [self percentOfPreference:NO] + [self percentOfInformation] + [self percentOfMeasurement] + [self percentOfSpecialZone];
//
//    
//    if(_isLikeEnough && _isDislikeEnough && _isInformationEnough && _isMeasurementEnough && _isSpecialZoneEnough){
//        percentTotal = 92;
//    }
    // change to same require of customer https://setaintl2008.atlassian.net/browse/MA-318
    if (percentTotal > 92) {
        percentTotal = 92;
    }
    return percentTotal;
//    return (CGFloat)(process/5) * 100;
}

-(NSString *) hintToGetOneHundred{
    if(![MASession sharedSession].currentPartner){
        return @"No partner was selected!";
    }
    
//    NSInteger likeLeft = [self numberOfPreferenceLeft:YES];
//    NSInteger disLikeLeft = [self numberOfPreferenceLeft:NO];
//    NSInteger informationLeft = [self numberOfInformationLeft];
//    NSInteger measurementLeft = [self numberOfMeasurementLeft];
//    NSInteger zoneLeft = [self numberOfSpecialZoneLeft];
    
    [self percentOfPreference:YES];
    [self percentOfPreference:NO];
    [self percentOfInformation];
    [self percentOfMeasurement];
    [self percentOfSpecialZone];
    
    NSString *message = @"";
    
    if(_isLikeEnough && _isDislikeEnough && _isInformationEnough && _isMeasurementEnough && _isSpecialZoneEnough){
        message = @"You'll never know everything, but every little bit helps your TwoSum";
        return message;
    }
    
    message = @"If ya want to achieve the minimal passing grade in your partners world, ya need to at least enter the following:";
    if(!_isLikeEnough){
        message = [message stringByAppendingString:@"\nA six pack of likes"];
    }
    
    if(!_isDislikeEnough){
        message = [message stringByAppendingString:@"\nA threesum of dislikes"];
    }
    
    if(!_isInformationEnough){
        message = [message stringByAppendingString:@"\nA foursum of information notes"];
    }
    
    if(!_isMeasurementEnough){
        message = [message stringByAppendingString:@"\nSome serious sizes to help ya buy me nice prizes"];
    }
    
    if(!_isSpecialZoneEnough){
        message = [message stringByAppendingString:@"\nAt least one thing about my body that moves you"];
    }
    
    return message;
}

#pragma mark - data check functions
-(NSInteger) numberOfPreferenceLeft:(BOOL) isLike{
    NSInteger numberRequire = isLike ? MA_USER_PROCESS_LIKE_REQUIRE : MA_USER_PROCESS_DISLIKE_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *preferenceItems = [[DatabaseHelper sharedHelper] getAllItemForPartner:[MASession sharedSession].currentPartner isLike:isLike];
    
    NSInteger itemLeft = numberRequire - preferenceItems.count;
//    
//    if(isLike) {
//        if(itemLeft <= 0){
//            _isLikeEnough = TRUE;
//        }
//        else{
//            _isLikeEnough = FALSE;
//        }
//    }
//    else{
//        if(itemLeft <= 0){
//            _isDislikeEnough = TRUE;
//        }
//        else{
//            _isDislikeEnough = FALSE;
//        }
//    }
    
    return itemLeft;
}

-(NSInteger) percentOfPreference:(BOOL) isLike {
    NSInteger percent = 0;
    NSInteger numberRequire = isLike ? MA_USER_PROCESS_LIKE_REQUIRE : MA_USER_PROCESS_DISLIKE_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *preferenceItems = [[DatabaseHelper sharedHelper] getAllItemForPartner:[MASession sharedSession].currentPartner isLike:isLike];
    
    NSInteger items = preferenceItems.count;
    
    if(isLike) {
        if (items > 0) {
            if (items >= numberRequire) {
                percent = numberRequire * 4;
                _isLikeEnough = TRUE;
            } else {
                percent = items * 4;
                _isLikeEnough = FALSE;
            }
        }

    }
    else{
        if (items > 0) {
            if (items >= numberRequire) {
                percent = numberRequire * 7;
                percent = percent - 1;// tru 1 la vi 3*7 = 21 (toi ta chi la 20);
                _isDislikeEnough = TRUE;
            } else {
                percent = items * 7;
                _isDislikeEnough = FALSE;
            }
        }

    }
    DLog(@"%d",percent);
    return percent;
}

-(NSInteger) numberOfInformationLeft {
    NSInteger numberRequire = MA_USER_PROCESS_INFORMATION_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *informationItems = [[DatabaseHelper sharedHelper] getAllItemInformationForPartner:[MASession sharedSession].currentPartner];
    
    NSInteger itemLeft = numberRequire - informationItems.count;
    
//    if(itemLeft <= 0){
//        _isInformationEnough = TRUE;
//    }
//    else{
//        _isInformationEnough = FALSE;
//    }
    
    return itemLeft;
}

-(NSInteger) percentOfInformation {
    NSInteger numberRequire = MA_USER_PROCESS_INFORMATION_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *informationItems = [[DatabaseHelper sharedHelper] getAllItemInformationForPartner:[MASession sharedSession].currentPartner];
    NSInteger percent = 0;
    if (informationItems.count > 0) {
        if (informationItems.count >= MA_USER_PROCESS_INFORMATION_REQUIRE) {
            percent = MA_USER_PROCESS_INFORMATION_REQUIRE * 10;
            _isInformationEnough = TRUE;
        } else {
            percent = informationItems.count * 10;
            _isInformationEnough = FALSE;
        }
    }
    DLog(@"%d",percent);
    return percent;
}

-(NSInteger) numberOfMeasurementLeft{
    NSInteger numberRequire = MA_USER_PROCESS_MEASUREMENT_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *measurementItems = [[DatabaseHelper sharedHelper] getAllItemMeasurementForPartner:[MASession sharedSession].currentPartner];
    
    NSInteger itemLeft = numberRequire - measurementItems.count;
    
//    if(itemLeft <= 0){
//        _isMeasurementEnough = TRUE;
//    }
//    else{
//        _isMeasurementEnough = FALSE;
//    }
    
    return itemLeft;
}

-(NSInteger) percentOfMeasurement {
    NSInteger percent = 0;
    NSInteger numberRequire = MA_USER_PROCESS_MEASUREMENT_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *measurementItems = [[DatabaseHelper sharedHelper] getAllItemMeasurementForPartner:[MASession sharedSession].currentPartner];
    
    NSInteger items = measurementItems.count;
    if (items > 0) {
        if (items >= 1) {
            percent =  MA_USER_PROCESS_MEASUREMENT_REQUIRE * 20;
            _isMeasurementEnough = TRUE;
        } else {
            percent = items * 10;
            _isMeasurementEnough = FALSE;
        }
    }
    DLog(@"%d",percent);
    return percent;
}

-(NSInteger)numberOfSpecialZoneLeft {
    NSInteger numberRequire = MA_USER_PROCESS_SPECIAL_ZONE_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *specialZone = [AvatarHelper eroZoneFromPlist:@"SpecialZone"];
    NSInteger number = 0;
    if (specialZone) {
        number = [[DatabaseHelper sharedHelper] checkSpecialZoneStoredSpecialZoneListIsEnough:specialZone];
        if (number > 0) {
            if (number == 2) {
                _isSpecialZoneEnough = TRUE;
            }else {
                _isSpecialZoneEnough = FALSE;
            }
        }
    }
    
//    NSInteger number =  [[UserDefault objectForKey:kSpecialZoneEnough] integerValue];


//    NSArray *specialZoneItems = [[DatabaseHelper sharedHelper] getPartnerEroZonesForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue];
//    
//    NSInteger itemLeft = numberRequire - specialZoneItems.count;
//    
//
//    
    return number;
}

- (NSInteger)percentOfSpecialZone {
    NSInteger percent = 0;
    NSInteger numberRequire = MA_USER_PROCESS_SPECIAL_ZONE_REQUIRE;
    if(![MASession sharedSession].currentPartner){
        return numberRequire;
    }
    NSArray *specialZone = [AvatarHelper eroZoneFromPlist:@"SpecialZone"];
    if (specialZone) {
        NSInteger number = [[DatabaseHelper sharedHelper] checkSpecialZoneStoredSpecialZoneListIsEnough:specialZone];
//        NSInteger number =  [[UserDefault objectForKey:kSpecialZoneEnough] integerValue];
        if (number > 0) {
            if (number == 2) {
                percent = number * 10;
                _isSpecialZoneEnough = TRUE;
            } else {
                percent = number * 10;
                _isSpecialZoneEnough = FALSE;
            }
        }
    }


    DLog(@"%d",percent);
//    NSArray *specialZoneItems = [[DatabaseHelper sharedHelper] getPartnerEroZonesForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue];
//    
//    NSInteger items = specialZoneItems.count;
//    if (items > 0) {
//        if (items >= 1) {
//            percent = numberRequire * 10;
//        }
//    }
    return percent;
}

- (void)resetCheckAlert{
    _isDislikeEnough = NO;
    _isInformationEnough = NO;
    _isLikeEnough = NO;
    _isMeasurementEnough = NO;
    _isSpecialZoneEnough = NO;
}
@end
