//
//  ItemToAvatar.h
//  TwoSum
//
//  Created by Demigod on 21/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Partner;

@interface ItemToAvatar : NSManagedObject

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) Partner *partner;
@property (nonatomic, retain) Item *item;

@end
