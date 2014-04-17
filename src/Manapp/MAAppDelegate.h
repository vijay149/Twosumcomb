//
//  MAAppDelegate.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController *manappNavigationController;
@property (assign, nonatomic) NSInteger indexImageShow;


-(void) firstTimeRunAppHandler;

@end
