//
//  iUtilities.h
//  iCore for iOS
//
//  Created by Quan Dang Dinh on 2/13/12.
//  Copyright © 2012 Lumos Technology Ltd.,. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iUtilities : NSObject {
    @private
}

+ (NSString *)generateGUID;

+ (NSDate *)jsonStringToNSDate:(NSString *)string;

@end
