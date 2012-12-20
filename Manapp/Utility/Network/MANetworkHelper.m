//
//  MANetworkHelper.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MANetworkHelper.h"
#import "AFJSONUtilities.h"

@implementation MANetworkHelper

+(id) sharedHelper{
    static MANetworkHelper* sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[MANetworkHelper alloc] initWithDefaultUrl];
    });
    
    return sharedHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

//by using this initilation, the class will use the fixed url as the server's url
-(id) initWithDefaultUrl{
    NSString* serverUrlString = [NSString stringWithFormat:@"%@",MANAPP_SERVER_URL ];
    NSURL* serverAPIUrl = [NSURL URLWithString:serverUrlString];
    self = [super initWithBaseURL:serverAPIUrl];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - function to login
//login into the application using username and password
- (void)loginWithUserName:(NSString *)username passWord:(NSString *)password success:(void (^)(NSDictionary *))blockSuccess fail:(void (^)(NSError *))blockFail{
    //COMMENT: pass the username and password to a dictionary
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password",nil];
    NSString* path = MANAPP_LOGIN_API_PATH;
    
    //COMMENT: using post method to send the parameter to the server
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(![operation.responseString isEqualToString:@""]){
            NSDictionary* responseDict = AFJSONDecode(operation.responseData, nil);
            if (blockSuccess) {
                blockSuccess(responseDict);
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (blockFail) {
            blockFail(error);
        }
    }];
}

#pragma mark - fucntion to request new password
- (void)requestNewPasswordAtMail:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail{
    //COMMENT: pass the username and password to a dictionary
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:email,@"login_or_email",nil];
    NSString* path = MANAPP_FORGOT_PASSWORD_API_PATH;
    
    //COMMENT: using post method to send the parameter to the server
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(![operation.responseString isEqualToString:@""]){
            NSDictionary* responseDict = AFJSONDecode(operation.responseData, nil);
            if (blockSuccess) {
                blockSuccess(responseDict);
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (blockFail) {
            blockFail(error);
        }
    }];
}

#pragma mark - function to create new account
- (void)signUpWithUsername:(NSString *)username password:(NSString*)password email:(NSString*)email success:(void(^)(NSDictionary*))blockSuccess fail:(void(^)(NSError*))blockFail{
    //COMMENT: pass the username and password to a dictionary
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:username,@"username",password,@"password",password,@"verifyPassword",email,@"email",nil];
    NSString* path = MANAPP_SIGNUP_API_PATH;
    
    //COMMENT: using post method to send the parameter to the server
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        if(![operation.responseString isEqualToString:@""]){
            NSDictionary* responseDict = AFJSONDecode(operation.responseData, nil);
            if (blockSuccess) {
                blockSuccess(responseDict);
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (blockFail) {
            blockFail(error);
        }
    }];
}

@end
