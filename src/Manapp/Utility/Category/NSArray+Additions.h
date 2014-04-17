//
//  NSArray+Additions.h
//  IKEA
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)
- (id) firstObject;
- (id) randomObject;
- (NSArray *) sortWithKey:(NSString *) key ascending:(BOOL) ascending;
@end
