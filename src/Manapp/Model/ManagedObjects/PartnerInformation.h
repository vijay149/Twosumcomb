//
//  PartnerInformation.h
//  TwoSum
//
//  Created by Demigod on 19/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner, PartnerInformation, PartnerInformationItem;

@interface PartnerInformation : NSManagedObject

@property (nonatomic, retain) NSString * infoID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Partner *partner;
@property (nonatomic, retain) PartnerInformation *parentCategory;
@property (nonatomic, retain) NSSet *subCategories;
@end

@interface PartnerInformation (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PartnerInformationItem *)value;
- (void)removeItemsObject:(PartnerInformationItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addSubCategoriesObject:(PartnerInformation *)value;
- (void)removeSubCategoriesObject:(PartnerInformation *)value;
- (void)addSubCategories:(NSSet *)values;
- (void)removeSubCategories:(NSSet *)values;

@end
