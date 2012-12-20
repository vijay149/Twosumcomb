//
//  NSArray+MACalendar.m
//  ManApp
//
//  Created by viet on 8/6/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import "NSArray+MACalendar.h"

@implementation NSArray (MACalendar)

- (id) firstObject{
	return [self objectAtIndex:0];
}

- (id) randomObject{
	return [self objectAtIndex:arc4random() % [self count]];
}

@end
