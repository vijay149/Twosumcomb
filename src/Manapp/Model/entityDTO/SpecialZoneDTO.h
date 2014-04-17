//
//  SpecialZoneDTO.h
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZoneBoundDTO.h"

@interface SpecialZoneDTO : NSObject{
    
}

@property (nonatomic, assign) MAEroZone zoneType;
@property (nonatomic, strong) NSString *zoneName;
@property NSInteger sex;
@property NSInteger type;
@property (nonatomic, strong) NSArray *zoneBounds;
@property (nonatomic, strong) UIImage *zoneImage;

@end
