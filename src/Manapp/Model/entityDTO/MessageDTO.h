//
//  MessageDTO.h
//  TwoSum
//
//  Created by quoc viet on 7/25/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDTO : NSObject

@property (nonatomic, assign) CGFloat moodHigher;
@property (nonatomic, retain) NSString * categoryA;
@property (nonatomic, retain) NSString * categoryB;
@property (nonatomic, retain) NSString * eventDate;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, assign) CGFloat moodLower;
@property (nonatomic, retain) NSString * secondMessage;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, retain) NSString * subCategoryA;
@property (nonatomic, retain) NSString * subCategoryB;

- (id) initWithJsonDict:(NSDictionary *)jsonDict;

@end
