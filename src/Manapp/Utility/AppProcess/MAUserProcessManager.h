//
//  MAUserProcessManager.h
//  Manapp
//
//  Created by Demigod on 21/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Partner;
@class UICustomProgressBar;

#define MA_USER_PROCESS_LIKE_REQUIRE 5
#define MA_USER_PROCESS_DISLIKE_REQUIRE 3
#define MA_USER_PROCESS_INFORMATION_REQUIRE 2
#define MA_USER_PROCESS_MEASUREMENT_REQUIRE 1
#define MA_USER_PROCESS_SPECIAL_ZONE_REQUIRE 1

@interface MAUserProcessManager : NSObject{
    NSInteger _currentPartnerId;
    BOOL _isLikeEnough;
    BOOL _isDislikeEnough;
    BOOL _isInformationEnough;
    BOOL _isMeasurementEnough;
    BOOL _isSpecialZoneEnough;
}

+(id) sharedInstance;

-(CGFloat) getProcessForCurrentPartner;
-(NSString *) hintToGetOneHundred;
-(NSInteger) numberOfPreferenceLeft:(BOOL) isLike;
-(NSInteger) numberOfInformationLeft;
-(NSInteger) numberOfMeasurementLeft;
-(NSInteger) numberOfSpecialZoneLeft;
- (NSInteger)percentOfSpecialZone;
-(NSInteger) percentOfMeasurement;
-(NSInteger) percentOfInformation;
-(NSInteger) percentOfPreference:(BOOL) isLike;
- (void)resetCheckAlert;
@end
