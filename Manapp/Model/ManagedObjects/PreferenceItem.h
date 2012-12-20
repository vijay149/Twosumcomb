//
//  PreferenceItem.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PreferenceCategory;

@interface PreferenceItem : NSManagedObject

@property (nonatomic, retain) NSNumber * isLike;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) PreferenceCategory *category;

@end
