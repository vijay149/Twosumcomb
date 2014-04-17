//
//  MASession.m
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MASession.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "MACommon.h"


@implementation MASession
@synthesize currentPartner = _currentPartner;
@synthesize userID = _userID;
@synthesize userToken = _userToken;
@synthesize maximumPartnerAllow = _maximumPartnerAllow;
@synthesize username = _username;
@synthesize password = _password;
@synthesize currentUserLogin = _currentUserLogin;

+(MASession *) sharedSession{
    static MASession *shareSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSession = [[MASession alloc] init];
    });
    
    return shareSession;
}

-(id)init{
    self = [super init];
    if(self){
        self.maximumPartnerAllow = MANAPP_MAXIMUM_NUMBER_OF_AVATAR_DEFAULT_NOT_ACTIVE;
        self.rememberMe = FALSE;
        self.currentUserLogin = [[UserLoginDTO alloc] init];
    }
    return self;
}

-(void) dealloc{
    [super dealloc];
    self.currentUserLogin = nil;
    self.currentPartner = nil;
    self.userToken = nil;
}

#pragma mark - session functions

-(void) clearSession{
    self.currentUserLogin = nil;
    self.currentPartner = nil;
    self.userToken = nil;
}

-(void)reloadPartner{
    if(self.currentPartner){
        self.currentPartner = [[DatabaseHelper sharedHelper] getPartnerById:[self.currentPartner.partnerID intValue]];
    }
}

-(void) save{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:self.rememberMe] forKey:MANAPP_DEFAULT_KEY_REMEMBER_ME];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:self.userID] forKey:MANAPP_DEFAULT_KEY_USER_ID];
    [[NSUserDefaults standardUserDefaults] setValue:self.userToken forKey:MANAPP_DEFAULT_KEY_USER_TOKEN];
    [[NSUserDefaults standardUserDefaults] setValue:self.username forKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
    [[NSUserDefaults standardUserDefaults] setValue:self.password forKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) load{
    self.rememberMe = [[[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_ME] boolValue];
    self.userID = [[[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_USER_ID] integerValue];
    self.userToken = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_USER_TOKEN];
    self.username = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
    self.password = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
}

-(void)logout{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:MANAPP_DEFAULT_KEY_REMEMBER_ME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MANAPP_DEFAULT_KEY_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MANAPP_DEFAULT_KEY_USER_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];
    self.currentPartner = nil;
    
    [self load];
}

@end
