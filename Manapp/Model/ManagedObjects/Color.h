//
//  Color.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eye, Hair, Skin;

@interface Color : NSManagedObject

@property (nonatomic, retain) NSString * colorCode;
@property (nonatomic, retain) NSNumber * colorID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Eye *fkColorToEye;
@property (nonatomic, retain) NSSet *fkColorToHair;
@property (nonatomic, retain) Skin *fkColorToSkin;
@end

@interface Color (CoreDataGeneratedAccessors)

- (void)addFkColorToHairObject:(Hair *)value;
- (void)removeFkColorToHairObject:(Hair *)value;
- (void)addFkColorToHair:(NSSet *)values;
- (void)removeFkColorToHair:(NSSet *)values;

@end
