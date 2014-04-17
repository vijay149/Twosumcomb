//
//  Item.h
//  TwoSum
//
//  Created by Demigod on 24/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemCategory, ItemToAvatar;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * imageURLFormat;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) ItemCategory *itemCategory;
@property (nonatomic, retain) NSSet *itemToAvatar;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addItemToAvatarObject:(ItemToAvatar *)value;
- (void)removeItemToAvatarObject:(ItemToAvatar *)value;
- (void)addItemToAvatar:(NSSet *)values;
- (void)removeItemToAvatar:(NSSet *)values;

@end
