//
//  TKEvent.h
//  TapkuLibrary
//
//  Created by Viet Tran on 10/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKEvent : NSObject

@property (nonatomic, retain) NSString *eventTitle;
@property (nonatomic, retain) NSDate *eventTime;
@property (nonatomic, retain) NSDate * eventEndTime;
@property (nonatomic, retain) NSDate * eventOccurTime;
@property (nonatomic, retain) NSString *recurrence;
@property (nonatomic, retain) NSString * eventName;
@end
