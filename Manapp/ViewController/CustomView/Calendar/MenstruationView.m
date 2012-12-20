//
//  MenstruationView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MenstruationView.h"

@implementation MenstruationView
@synthesize txtFirstPeriod = _txtFirstPeriod;
@synthesize btnSave = _btnSave;
@synthesize btnBack = _btnBack;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_txtFirstPeriod release];
    [_btnSave release];
    [_btnBack release];
    [super dealloc];
}

#pragma mark - event handler
- (IBAction)btnSave_touchUpInside:(id)sender {
}

- (IBAction)btnBack_touchUpInside:(id)sender {
}
@end
