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

+ (BOOL) isEmpty:(NSString *)string{
    if(string && ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        return NO;
    }
    else{
        return YES;
    }
}

- (BOOL) isContainSubString:(NSString *)subString{
    NSRange range = [self rangeOfString:subString];
    if(range.location == NSNotFound){
        return NO;
    }
    else{
        return YES;
    }
}

- (NSString *) replaceSubString:(NSString *)subString byString:(NSString *)newString{
    if(!subString || !newString){
        return self;
    }
    return [self stringByReplacingOccurrencesOfString:subString withString:newString];

}

- (NSString *)removeNewLineCharacter{
    NSString *newString = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    return newString;
}

@end
