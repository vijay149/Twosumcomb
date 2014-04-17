//
//  ZoneBoundDTO.m
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "ZoneBoundDTO.h"

@implementation ZoneBoundDTO

+(ZoneBoundDTO *) boundWithRect:(CGRect) rect{
    ZoneBoundDTO *bound = [[[ZoneBoundDTO alloc] init] autorelease];
    bound.bound = rect;
    return bound;
}

@end
