//
//  Skin.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Color, PartnerAvatar;

@interface Skin : NSManagedObject

@property (nonatomic, retain) NSNumber * colorID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSNumber * skinID;
@property (nonatomic, retain) Color *fkSkinToColor;
@property (nonatomic, retain) NSSet *fkSkinToPartnerAvatar;
@end

@interface Skin (CoreDataGeneratedAccessors)

- (void)addFkSkinToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkSkinToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkSkinToPartnerAvatar:(NSSet *)values;
- (void)removeFkSkinToPartnerAvatar:(NSSet *)values;

@end
