//
//  UserLoginDTO.m
//  TwoSum
//
//  Created by Duong Van Dinh on 9/20/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "UserLoginDTO.h"

@implementation UserLoginDTO

- (id) init {
    if([super init]) {
        self.userName = nil;
        self.password = nil;
    }
    return self;
}

- (void) dealloc {   
    [_userName release];
    [_password release];
    [super dealloc];
}
@end
