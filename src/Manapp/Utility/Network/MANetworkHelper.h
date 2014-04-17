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
#import "Message.h"
@interface MANetworkHelper : AFHTTPClient{
    
}

+(id) sharedHelper;
-(id) initWithDefaultUrl;

// COMMENT: handle login action
- (void)loginWithUserName:(NSString*)username passWord:(NSString*)password success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)requestNewPasswordAtMail:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)requestNewUsernameAtMail:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)signUpWithUsername:(NSString *)username password:(NSString*)password email:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;

- (void)requestVerifyEmailForUserId:(NSString *) userId success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (NSString *)parseRequestVerifyEmailResult:(NSDictionary *) result;

- (void)changeEmail:(NSString*) email forUser:(NSString *) userId success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;

- (void)changePassword:(NSString*) password forUser:(NSString *) userId success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)checkActive:(NSString*) userId success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)getMessageListWithsuccess:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (void)getMessageExceptionListWithLatestDate:(double) latestDate withsuccess:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail;
- (NSString *)parseChangeEmailResult:(NSDictionary *) result;
@end
