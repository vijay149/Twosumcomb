//
//  NSString+Additional.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additional)

+ (NSString *)generateGUID;

- (BOOL) isContainSubString:(NSString *)subString;

- (NSString *) replaceSubString:(NSString *)subString byString:(NSString *)newString;

+ (BOOL) isEmpty:(NSString *)string;

- (NSString *)removeNewLineCharacter;
@end
