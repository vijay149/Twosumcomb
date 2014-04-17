//
//  Hair.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Color, HairStyle, PartnerAvatar;

@interface Hair : NSManagedObject

@property (nonatomic, retain) NSNumber * colorID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * hairID;
@property (nonatomic, retain) NSNumber * hairStyleID;
@property (nonatomic, retain) Color *fkHairToColor;
@property (nonatomic, retain) HairStyle *fkHairToHairStyle;
@property (nonatomic, retain) PartnerAvatar *fkHairToPartnerAvatar;

@end
