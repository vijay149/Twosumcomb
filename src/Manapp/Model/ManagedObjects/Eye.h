//
//  Eye.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Color, PartnerAvatar;

@interface Eye : NSManagedObject

@property (nonatomic, retain) NSNumber * colorID;
@property (nonatomic, retain) NSNumber * eyeID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) Color *fkEyeToColor;
@property (nonatomic, retain) NSSet *fkEyeToPartnerAvatar;
@end

@interface Eye (CoreDataGeneratedAccessors)

- (void)addFkEyeToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkEyeToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkEyeToPartnerAvatar:(NSSet *)values;
- (void)removeFkEyeToPartnerAvatar:(NSSet *)values;

@end
