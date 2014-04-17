//
//  NSArray+Additions.m
//  IKEA
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)
- (id) firstObject{
	return [self objectAtIndex:0];
}

- (id) randomObject{
	return [self objectAtIndex:arc4random() % [self count]];
}

- (NSArray *) sortWithKey:(NSString *) key ascending:(BOOL) ascending{
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]]];
}
@end
