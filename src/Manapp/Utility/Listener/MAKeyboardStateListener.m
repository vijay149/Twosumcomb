//
//  MAKeyboardStateListener.m
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MAKeyboardStateListener.h"

@implementation MAKeyboardStateListener
@synthesize keyboardHeight = _keyboardHeight;

+ (MAKeyboardStateListener *)sharedInstance
{
    static MAKeyboardStateListener *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MAKeyboardStateListener alloc] init];
    });
    
    return sharedInstance;
}

+ (void)load
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [MAKeyboardStateListener sharedInstance];
    [pool release];
}

- (BOOL)isVisible
{
    return _isVisible;
}

- (void)didShow:(NSNotification*)notification
{
    _isVisible = YES;
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
}

- (void)willShow:(NSNotification*)notification
{
    _isVisible = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
}

- (void)didHide
{
    _isVisible = NO;
}

- (id)init
{
    if ((self = [super init])) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShow:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

@end
