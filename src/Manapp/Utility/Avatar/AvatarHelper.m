//
//  AvatarHelper.m
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "AvatarHelper.h"
#import "SpecialZoneDTO.h"
#import "MASession.h"
#import "MoodHelper.h"
#import "DatabaseHelper.h"
#import "PartnerMood.h"

@implementation AvatarHelper

+(AvatarHelper *) sharedHelper{
    static AvatarHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[AvatarHelper alloc] init];
    });
    
    return sharedHelper;
}

#pragma mark - read ero zone from plist
+(NSArray *) eroZoneFromPlist:(NSString *) plistName{
    NSMutableArray *zones = [[[NSMutableArray alloc] init] autorelease];
    
    NSArray *partnerZonesData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"]];
    
    for(NSDictionary *partnerZoneData in partnerZonesData){
        if([MASession sharedSession].currentPartner.sex.integerValue == [[partnerZoneData objectForKey:@"Sex"] integerValue]){
            NSArray *zonesData = [partnerZoneData objectForKey:@"Zones"];
            for(NSDictionary *zoneData in zonesData){
                SpecialZoneDTO *zone = [[[SpecialZoneDTO alloc] init] autorelease];
                zone.zoneName = [zoneData objectForKey:@"ZoneName"];
                zone.zoneType = [[zoneData objectForKey:@"ZoneType"] intValue];
                zone.sex = [[partnerZoneData objectForKey:@"Sex"] integerValue];
                zone.type = [[partnerZoneData objectForKey:@"Type"] integerValue];
                
                NSString *imgPartFormat = [zoneData objectForKey:@"ZoneImageFormat"];
                if(imgPartFormat && ![imgPartFormat isEqualToString:@""]){
                    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:imgPartFormat,([MASession sharedSession].currentPartner.sex.integerValue == MANAPP_SEX_FEMALE)?2:1]];
                    zone.zoneImage = image;
                }
                
                NSMutableArray *bounds = [[[NSMutableArray alloc] init] autorelease];
                NSArray *boundsData = [zoneData objectForKey:@"ZoneBounds"];
                for(NSDictionary *boundData in boundsData){
                    CGFloat x = [[boundData objectForKey:@"x"] floatValue];
                    CGFloat y = [[boundData objectForKey:@"y"] floatValue];
                    CGFloat width = [[boundData objectForKey:@"width"] floatValue];
                    CGFloat height = [[boundData objectForKey:@"height"] floatValue];
                    ZoneBoundDTO *bound = [[[ZoneBoundDTO alloc] init] autorelease];
                    bound.bound = CGRectMake(x, y, width, height);
                    
                    [bounds addObject:bound];
                }
                
                zone.zoneBounds = [NSArray arrayWithArray:bounds];
                
                [zones addObject:zone];
            }
            return zones;
        }
        else{
            continue;
        }
    }
    
    return nil;
}

+ (NSString *)imageNameForPartner:(Partner *)partner{
    return [NSString stringWithFormat:@"Avatar-%@-%d-%d",partner.name,[MASession sharedSession].userID,partner.sex.boolValue];
}

+ (UIImage *)avatarImageForPartnerInDocument:(Partner *)partner{
    return [FileUtil imageInDocumentWithName:[AvatarHelper imageNameForPartner:partner]];
}

+ (UIImage *)avatarBodyForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
        if(mood < 20){
            return [UIImage imageNamed:@"avatarBody1"];
        }
        else if(mood < 40){
            return [UIImage imageNamed:@"avatarBody2"];
        }
        else if(mood < 60){
            return [UIImage imageNamed:@"avatarBody3"];
        }
        else if(mood < 80){
            return [UIImage imageNamed:@"avatarBody4"];
        }
        else{
            return [UIImage imageNamed:@"avatarBody5"];
        }
        
        return [UIImage imageNamed:@"avatarBody1"];
    }
    else{
        if(mood < 20){
            return [UIImage imageNamed:@"avatarFemale1"];
        }
        else if(mood < 40){
            return [UIImage imageNamed:@"avatarFemale2"];
        }
        else if(mood < 60){
            return [UIImage imageNamed:@"avatarFemale3"];
        }
        else if(mood < 80){
            return [UIImage imageNamed:@"avatarFemale4"];
        }
        else{
            return [UIImage imageNamed:@"avatarFemale5"];
        }
        
        return [UIImage imageNamed:@"avatarFemale1"];
    }
}

+ (UIImage *)underwareForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    if(mood < 20){
        return [UIImage imageNamed:@"underware1"];
    }
    else if(mood < 40){
        return [UIImage imageNamed:@"underware2"];
    }
    else if(mood < 60){
        return [UIImage imageNamed:@"underware3"];
    }
    else if(mood < 80){
        return [UIImage imageNamed:@"underware4"];
    }
    else{
        return [UIImage imageNamed:@"underware5"];
    }
    
    return [UIImage imageNamed:@"underware1"];
}

@end
