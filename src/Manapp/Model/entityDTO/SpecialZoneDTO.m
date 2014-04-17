//
//  SpecialZoneDTO.m
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "SpecialZoneDTO.h"

@implementation SpecialZoneDTO

- (void)dealloc{
    [super dealloc];
    [_zoneName release];
    [_zoneBounds release];
    [_zoneImage release];
}

@end
