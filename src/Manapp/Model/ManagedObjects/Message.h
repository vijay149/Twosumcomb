//
//  Message.h
//  TwoSum
//
//  Created by quoc viet on 8/5/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PartnerMessages;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * categoryA;
@property (nonatomic, retain) NSString * categoryB;
@property (nonatomic, retain) NSString * eventDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSNumber * moodHigher;
@property (nonatomic, retain) NSNumber * moodLower;
@property (nonatomic, retain) NSString * secondMessage;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSString * subCategoryA;
@property (nonatomic, retain) NSString * subCategoryB;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *partners;
@end

@interface Message (CoreDataGeneratedAccessors)

- (void)addPartnersObject:(PartnerMessages *)value;
- (void)removePartnersObject:(PartnerMessages *)value;
- (void)addPartners:(NSSet *)values;
- (void)removePartners:(NSSet *)values;

@end
