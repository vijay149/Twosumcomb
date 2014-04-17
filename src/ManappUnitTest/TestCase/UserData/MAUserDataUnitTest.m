//
//  MAUserDataUnitTest.m
//  Manapp
//
//  Created by Demigod on 25/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MAUserDataUnitTest.h"
#import "MACommon.h"
#import "MAAppDelegate.h"
#import "DatabaseHelper.h"
#import "ClothingViewController.h"
#import "MANetworkHelper.h"

@implementation MAUserDataUnitTest{
    NSManagedObjectContext *_managedObjectContext;
}

-(void) setUp{
    
}

-(void) testRememberMeUsernameDefault{
    NSString *rememberUsername = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_USERNAME];

    GHAssertNil(rememberUsername, @"Username can be nil in the first run");
}

-(void) testRememberMePassword{
    NSString *rememberPassword = [[NSUserDefaults standardUserDefaults] valueForKey:MANAPP_DEFAULT_KEY_REMEMBER_PASSWORD];

    GHAssertNil(rememberPassword, @"Password can be nil in the first run");
}

-(void) testGetPartnersForUserPass{
    //right pass
    NSString* userInput = @"Manapp";
    NSString* passInput = @"1234567";

    [[MANetworkHelper sharedHelper] loginWithUserName:userInput passWord:passInput success:^(NSDictionary* resultDictionary){
        //get suggest flag
        NSNumber *loginResult = [resultDictionary objectForKey:@"success"];
        GHAssertEquals([loginResult boolValue], YES, @"Result have to be true when login information is right");
        
        //wrong pass
        NSString* userInput = @"Manapp";
        NSString* passInput = @"12345678";
        
        [[MANetworkHelper sharedHelper] loginWithUserName:userInput passWord:passInput success:^(NSDictionary* resultDictionary){
            //get suggest flag
            NSNumber *loginResult = [resultDictionary objectForKey:@"success"];
            GHAssertEquals([loginResult boolValue], NO, @"Result have to be false when login information is right");
            
            
        }fail:^(NSError* error){
            GHAssertNotNil(error, @"Error will show up if there is any error in connection");
        }];
        

    }fail:^(NSError* error){
        GHAssertNotNil(error, @"Error will show up if there is any error in connection");
    }];
}

@end
