//
//  MACustomViewUnitTest.m
//  Manapp
//
//  Created by Demigod on 17/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MACustomViewUnitTest.h"
#import "MACheckBoxButton.h"

@implementation MACustomViewUnitTest

-(void) testChechBoxButton{
    id checkBox = [OCMockObject mockForClass:[MACheckBoxButton class]];
    
    [[checkBox expect] setCheckWithState:YES];
    
    [[[checkBox stub] andReturn:NO] isChecked];
    
    [checkBox verify];
}

@end
