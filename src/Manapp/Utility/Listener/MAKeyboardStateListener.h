//
//  MAKeyboardStateListener.h
//  Manapp
//
//  Created by Demigod on 16/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAKeyboardStateListener : NSObject
{
    BOOL _isVisible;
    CGFloat _keyboardHeight;
}

+ (MAKeyboardStateListener *)sharedInstance;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property CGFloat keyboardHeight;

@end
