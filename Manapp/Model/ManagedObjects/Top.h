//
//  Top.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerAvatar;

@interface Top : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * topID;
@property (nonatomic, retain) NSSet *fkTopToPartnerAvatar;
@end

@interface Top (CoreDataGeneratedAccessors)

- (void)addFkTopToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkTopToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkTopToPartnerAvatar:(NSSet *)values;
- (void)removeFkTopToPartnerAvatar:(NSSet *)values;

@end
