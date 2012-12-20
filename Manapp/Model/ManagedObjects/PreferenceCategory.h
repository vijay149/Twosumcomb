//
//  PreferenceCategory.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Partner, PreferenceCategory, PreferenceItem;

@interface PreferenceCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * preferenceID;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) PreferenceCategory *parentCategory;
@property (nonatomic, retain) Partner *partner;
@property (nonatomic, retain) NSSet *subCategories;
@end

@interface PreferenceCategory (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PreferenceItem *)value;
- (void)removeItemsObject:(PreferenceItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addSubCategoriesObject:(PreferenceCategory *)value;
- (void)removeSubCategoriesObject:(PreferenceCategory *)value;
- (void)addSubCategories:(NSSet *)values;
- (void)removeSubCategories:(NSSet *)values;

@end
