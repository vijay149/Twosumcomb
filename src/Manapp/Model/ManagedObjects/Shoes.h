//
//  Shoes.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerAvatar;

@interface Shoes : NSManagedObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * shoesID;
@property (nonatomic, retain) NSSet *fkShoesToPartnerAvatar;
@end

@interface Shoes (CoreDataGeneratedAccessors)

- (void)addFkShoesToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)removeFkShoesToPartnerAvatarObject:(PartnerAvatar *)value;
- (void)addFkShoesToPartnerAvatar:(NSSet *)values;
- (void)removeFkShoesToPartnerAvatar:(NSSet *)values;

@end
