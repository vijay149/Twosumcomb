//
//  MASession.h
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserLoginDTO.h"
@class Partner;

@interface MASession : NSObject

@property NSInteger userID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
@property NSInteger maximumPartnerAllow;
@property (nonatomic, retain) NSString *userToken;
@property (nonatomic, retain) Partner *currentPartner;
@property (nonatomic, retain) UserLoginDTO *currentUserLogin;
@property BOOL rememberMe;

+(MASession *) sharedSession;

-(void) reloadPartner;

-(void) clearSession;

-(void) logout;

-(void) save;
-(void) load;

@end
