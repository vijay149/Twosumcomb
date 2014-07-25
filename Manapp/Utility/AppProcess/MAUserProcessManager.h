//
//  MAUserProcessManager.h
//  Manapp
//
//  Created by Demigod on 21/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Partner;
@class UICustomProgressBar;

@interface MAUserProcessManager : NSObject{
    NSInteger _currentPartnerId;
}

+(id) sharedInstance;

-(CGFloat) getAppProcessForPartnerId:(NSInteger) partnerId;
-(CGFloat) getAppProcessForPartner:(Partner*) partner;
-(CGFloat) setProcessForPartnerId:(NSInteger) partnerId afterStep:(NSString*) stepName;
-(CGFloat) setProcessForPartner:(Partner*) partner afterStep:(NSString*) stepName;
-(CGFloat) setProcessForPartnerId:(NSInteger) partnerId afterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar;
-(CGFloat) setProcessForPartner:(Partner*) partner afterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar;

-(void) setCurrentPartner:(NSInteger) currentPartner;
-(CGFloat) setCurrentPartnerProcessAfterStep:(NSString*) stepName;
-(CGFloat) setCurrentPartnerProcessAfterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar;
-(CGFloat) getCurrentUserAppProcess;

@end
