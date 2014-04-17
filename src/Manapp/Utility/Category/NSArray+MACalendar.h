//
//  NSArray+MACalendar.h
//  ManApp
//
//  Created by viet on 8/6/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MACalendar)

- (id) firstObject;

- (id) randomObject;

- (NSArray *) sortWithKey:(NSString *) key ascending:(BOOL) ascending;

@end
