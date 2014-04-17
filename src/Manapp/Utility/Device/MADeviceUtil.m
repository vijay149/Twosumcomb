//
//  MADeviceUtil.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MADeviceUtil.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <sys/time.h>
#import <netinet/in.h>
#import <net/if_dl.h>
#import <netdb.h>
#import <errno.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <ifaddrs.h>

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

+ (BOOL)checkConnection:(SCNetworkReachabilityFlags*)flags
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, flags);
	CFRelease(defaultRouteReachability);
	
	if(!didRetrieveFlags)
		return NO;
	return YES;
}

+ (BOOL)connectedToNetwork
{
	SCNetworkReachabilityFlags flags;
	if(![MADeviceUtil checkConnection:&flags])
		return NO;
	
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkReachabilityFlagsConnectionRequired;
	
	return (isReachable && !needsConnection) ? YES : NO;
}

+ (BOOL)connectedToWiFi
{
	SCNetworkReachabilityFlags flags;
	if(![MADeviceUtil checkConnection:&flags])
		return NO;
	
	BOOL isReachable = flags & kSCNetworkReachabilityFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkReachabilityFlagsConnectionRequired;
	BOOL cellConnected = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	return (isReachable && !needsConnection && !cellConnected) ? YES : NO;
}

@end
