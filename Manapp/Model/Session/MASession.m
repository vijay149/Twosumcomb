//
//  MASession.m
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MASession.h"
#import "Partner.h"

@implementation MASession
@synthesize currentPartner = _currentPartner;
@synthesize userID = _userID;
@synthesize userToken = _userToken;

+(MASession *) sharedSession{
    static MASession *shareSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareSession = [[MASession alloc] init];
    });
    
    return shareSession;
}

-(void) clearSession{
    self.currentPartner = nil;
    self.userToken = nil;
}

-(void) dealloc{
    [super dealloc];
    
    self.currentPartner = nil;
    self.userToken = nil;
}

@end
