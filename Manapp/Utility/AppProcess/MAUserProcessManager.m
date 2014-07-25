//
//  MAUserProcessManager.m
//  Manapp
//
//  Created by Demigod on 21/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MAUserProcessManager.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "UICustomProgressBar.h"

@implementation MAUserProcessManager

+(id) sharedInstance{
    static MAUserProcessManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MAUserProcessManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        //check if the setup step is in database or not, if not then initialize them
        [[DatabaseHelper sharedHelper] initSetupStepData];
    }
    return self;
}

#pragma mark - static function
-(CGFloat) getAppProcessForPartnerId:(NSInteger) partnerId{
    return [[DatabaseHelper sharedHelper] getSetupProgressForPartnerId:partnerId];
}

-(CGFloat) getAppProcessForPartner:(Partner*) partner{
    return [[DatabaseHelper sharedHelper] getSetupProgressForPartnerId:[partner.partnerID intValue]];
}

-(CGFloat) setProcessForPartnerId:(NSInteger) partnerId afterStep:(NSString*) stepName{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:partnerId byStepName:stepName];
    
    return [self getAppProcessForPartnerId:partnerId];
}

-(CGFloat) setProcessForPartner:(Partner*) partner afterStep:(NSString*) stepName{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:[partner.partnerID intValue] byStepName:stepName];
    
    return [self getAppProcessForPartner:partner];
}

-(CGFloat) setProcessForPartnerId:(NSInteger) partnerId afterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:partnerId byStepName:stepName];
    
    CGFloat newProcessValue = [self getAppProcessForPartnerId:partnerId];
    processBar.currentValue = newProcessValue;
    
    return newProcessValue;
}

-(CGFloat) setProcessForPartner:(Partner*) partner afterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:[partner.partnerID intValue] byStepName:stepName];
    
    CGFloat newProcessValue = [self getAppProcessForPartner:partner];
    processBar.currentValue = newProcessValue;
    
    return newProcessValue;
}

#pragma mark - get,set functions
// set the current user
-(void) setCurrentPartner:(NSInteger) currentPartner{
    _currentPartnerId = currentPartner;
}

//set the new value for the process after finish one step
-(CGFloat) setCurrentPartnerProcessAfterStep:(NSString*) stepName{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:_currentPartnerId byStepName:stepName];
    return [self getCurrentUserAppProcess];
}

//set the new value for the process after finish one step and change the process bar if need
-(CGFloat) setCurrentPartnerProcessAfterStep:(NSString*) stepName withProcessBar:(UICustomProgressBar*) processBar{
    [[DatabaseHelper sharedHelper] increaseSetupProfressForPartnerId:_currentPartnerId byStepName:stepName];
    
    CGFloat newProcessValue = [self getCurrentUserAppProcess];
    processBar.currentValue = newProcessValue;
    
    return newProcessValue;
}

//get the current process for this partner
-(CGFloat) getCurrentUserAppProcess{
    return [[DatabaseHelper sharedHelper] getSetupProgressForPartnerId:_currentPartnerId];
}

@end
