//
//  MADeviceUtil.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MADeviceUtil.h"

@implementation MADeviceUtil

+(id)sharedInstance{
    static MADeviceUtil* deviceUtilInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceUtilInstance = [[MADeviceUtil alloc] init];
    });
    
    return deviceUtilInstance;
}

//get device ios version
+(NSString *) getDeviceIOSVersion{
    return [[UIDevice currentDevice] systemVersion];
}

//get the ios version in float
+(CGFloat) getDeviceIOSVersionNumber{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

//get the device type
+(IOSDeviceType) getDeviceType{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return IOSDeviceTypeIpad;
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return IOSDeviceTypeIphone;
    }
    
    return IOSDeviceTypeIphone;
}

//get the current orientation
+(UIInterfaceOrientation) getDeviceOrientation{
    return [[UIDevice currentDevice] orientation];
}

@end
