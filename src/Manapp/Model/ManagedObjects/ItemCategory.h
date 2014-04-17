//
//  ItemCategory.h
//  TwoSum
//
//  Created by Demigod on 21/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface ItemCategory : NSManagedObject

@property (nonatomic, retain) NSString * categoryID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * zIndex;
@property (nonatomic, retain) NSSet *items;
@end

@interface ItemCategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
