//
//  PartnerMessages.h
//  TwoSum
//
//  Created by quoc viet on 8/5/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message, Partner;

@interface PartnerMessages : NSManagedObject

@property (nonatomic, retain) NSString * partnerMessageId;
@property (nonatomic, retain) Partner *partner;
@property (nonatomic, retain) Message *message;

@end
