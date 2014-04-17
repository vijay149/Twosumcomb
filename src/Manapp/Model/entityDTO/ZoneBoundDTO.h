//
//  ZoneBoundDTO.h
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZoneBoundDTO : NSObject{
    
}

@property (nonatomic, assign) CGRect bound;

+(ZoneBoundDTO *) boundWithRect:(CGRect) rect;

@end
