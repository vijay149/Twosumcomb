//
//  MAAppDelegate.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MAAppDelegate.h"
#import "LoginViewController.h"
#import "DatabaseHelper.h"
#import "MASession.h"
#import "MANotificationManager.h"
#import "LocalNotificationHelper.h"
#import "NSDate+Helper.h"
#import "Util.h"
@implementation MAAppDelegate
@synthesize manappNavigationController = _manappNavigationController;
@synthesize indexImageShow;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    DLogError(@"This is error");
    DLogWarning(@"This is warning");
    DLogInfo(@"This is info");
    [application setStatusBarHidden:YES];
    
    //setting the app for the firsttime
    [self firstTimeRunAppHandler];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[MASession sharedSession] load];
    [[DatabaseHelper sharedHelper] initDefaultItem];
    
    //lauch the login view
    LoginViewController *loginViewController = NEW_VC(LoginViewController);
    self.manappNavigationController = [[[UINavigationController alloc] initWithRootViewController:loginViewController] autorelease];
    
//    [self.window addSubview:self.manappNavigationController.view];
    [self.window setRootViewController:self.manappNavigationController];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    DLogInfo(@"applicationDidEnterBackground");
}


- (void) testCallWhenAppDidEnterBackground {
    DLogInfo(@"run test");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[DatabaseHelper sharedHelper] saveContext];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    [[MANotificationManager sharedInstance] moodNotificationHandler:notification];
    [[MANotificationManager sharedInstance] eventNotificationHandler:notification];
}


-(void) firstTimeRunAppHandler{
    NSNumber* isFirstTime = [[NSUserDefaults standardUserDefaults] valueForKey:kAppFirstRunTime];
    if(!isFirstTime || isFirstTime.boolValue == YES){
        [Util setValue:[NSNumber numberWithBool:YES] forKey:kMoodDefaultFirstStart];
//        [UserDefault setValue:[NSNumber numberWithInt:0] forKey:kSpecialZoneEnough];
        [UserDefault synchronize];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kAppFirstRunTime];
        [[MANotificationManager sharedInstance] removeAllNotification];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/**
 *  Only Portrait view
 */

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
