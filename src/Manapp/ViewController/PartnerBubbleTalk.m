//
//  PartnerBubbleTalk.m
//  TwoSum
//
//  Created by Duong Van Dinh on 8/19/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "PartnerBubbleTalk.h"

@implementation PartnerBubbleTalk

- (void) dealloc {
    [super dealloc];
}

- (id) init {
    if (self = [super init]) {
        self.arrayHeightBubbleTalk = [NSMutableArray array];
        self.arrayLabelBubbleTalk = [NSMutableArray array];
        self.arrayTextBubbleTalk = [NSMutableArray array];
        self.arrayIsLastBubbleTalk = [NSMutableArray array];
    }
    return self;
}

@end
