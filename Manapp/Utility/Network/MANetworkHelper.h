//
//  MANetworkHelper.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "MACommon.h"

@interface MANetworkHelper : AFHTTPClient{
    
}

+(id) sharedHelper;
-(id) initWithDefaultUrl;

// COMMENT: handle login action
- (void)loginWithUserName:(NSString*)username passWord:(NSString*)password success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)requestNewPasswordAtMail:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)signUpWithUsername:(NSString *)username password:(NSString*)password email:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
@end
