//
//  AvatarHelper.h
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Partner.h"
#import "FileUtil.h"

@interface AvatarHelper : NSObject

+ (AvatarHelper *)sharedHelper;

+ (NSArray *)eroZoneFromPlist:(NSString *) plistName;

+ (NSString *)imageNameForPartner:(Partner *)partner;

+ (UIImage *)avatarImageForPartnerInDocument:(Partner *)partner;

+ (UIImage *)avatarBodyForPartner:(Partner *)partner;
+ (UIImage *)underwareForPartner:(Partner *)partner;

@end
