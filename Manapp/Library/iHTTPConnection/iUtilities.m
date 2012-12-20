//
//  iUtilities.m
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 2/13/12.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import "iUtilities.h"

@implementation iUtilities

+ (NSString *)generateGUID{
    CFUUIDRef __uuid = CFUUIDCreate(nil);
    NSString *__guid = (NSString *)CFUUIDCreateString(nil, __uuid);
    
    CFRelease(__uuid);
    
    return [__guid autorelease];
}

+ (NSDate *)jsonStringToNSDate:(NSString *)string{
    
	// Extract the numeric part of the date.  Dates should be in the format
	// "/Date(x)/", where x is a number.  This format is supplied automatically
	// by JSON serialisers in .NET.
	NSRange range = NSMakeRange(6, [string length] - 13);
	NSString* substring = [string substringWithRange:range];
    
	// Have to use a number formatter to extract the value from the string into
	// a long long as the longLongValue method of the string doesn't seem to
	// return anything useful - it is always grossly incorrect.
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	NSNumber* milliseconds = [formatter numberFromString:substring];
    
	[formatter release];
    
	// NSTimeInterval is specified in seconds.  The value we get back from the
	// web service is specified in milliseconds.  Both values are since 1st Jan
	// 1970 (epoch).
	NSTimeInterval seconds = [milliseconds longLongValue] / 1000;
    
	return [NSDate dateWithTimeIntervalSince1970:seconds];
}

@end
