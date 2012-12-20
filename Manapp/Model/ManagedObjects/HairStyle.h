//
//  HairStyle.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hair;

@interface HairStyle : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * hairStyleID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSSet *fkHairStyleToFHair;
@end

@interface HairStyle (CoreDataGeneratedAccessors)

- (void)addFkHairStyleToFHairObject:(Hair *)value;
- (void)removeFkHairStyleToFHairObject:(Hair *)value;
- (void)addFkHairStyleToFHair:(NSSet *)values;
- (void)removeFkHairStyleToFHair:(NSSet *)values;

@end
