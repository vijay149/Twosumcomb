//
//  MASession.h
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Partner;

@interface MASession : NSObject

@property NSInteger userID;
@property (nonatomic, retain) NSString *userToken;
@property (nonatomic, retain) Partner *currentPartner;

+(MASession *) sharedSession;

-(void) clearSession;

@end
