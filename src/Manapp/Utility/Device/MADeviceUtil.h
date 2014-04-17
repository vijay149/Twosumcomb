//
//  MADeviceUtil.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SCNetworkReachability.h>

typedef enum {
    IOSDeviceTypeIphone          = 1,
    IOSDeviceTypeIpad            = 2,
    IOSDeviceTypeIpodTouch       = 3,
} IOSDeviceType;

@interface MADeviceUtil : NSObject{
    
}

+(id) sharedInstance;

+(NSString *) getDeviceIOSVersion;
+(CGFloat) getDeviceIOSVersionNumber;
+(IOSDeviceType) getDeviceType;
+(UIInterfaceOrientation) getDeviceOrientation;

+ (BOOL)checkConnection:(SCNetworkReachabilityFlags*)flags;
+ (BOOL)connectedToNetwork;
+ (BOOL)connectedToWiFi;

@end
