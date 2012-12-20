//
//  Accessories.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerAvatar;

@interface Accessories : NSManagedObject

@property (nonatomic, retain) NSNumber * accessoriesID;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *fkAccessoriesToPartnerAvatar;
@end

@interface Accessories (CoreDataGeneratedAccessors)

- (void)addFkAccessoriesToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkAccessoriesToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkAccessoriesToPartnerAvatar:(NSSet *)values;
- (void)removeFkAccessoriesToPartnerAvatar:(NSSet *)values;

@end
