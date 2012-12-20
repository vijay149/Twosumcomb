//
//  NSString+Additional.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "NSString+Additional.h"

@implementation NSString (Additional)

//generate random string
+ (NSString *)generateGUID{
    CFUUIDRef __uuid = CFUUIDCreate(nil);
    NSString *__guid = (NSString *)CFUUIDCreateString(nil, __uuid);
    
    CFRelease(__uuid);
    
    return [__guid autorelease];
}

@end
