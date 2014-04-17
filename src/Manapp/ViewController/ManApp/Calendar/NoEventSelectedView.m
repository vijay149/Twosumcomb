//
//  NoEventSelectedView.m
//  TwoSum
//
//  Created by Duong Van Dinh on 10/3/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "NoEventSelectedView.h"

@interface NoEventSelectedView ()

@end

@implementation NoEventSelectedView

- (void)dealloc {
    [_lblDateSelected release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSelectedDate)]) {
        NSDate *date =  [self.delegate getSelectedDate];
        if (date) {
            self.lblDateSelected.text = [NSString stringWithFormat:@"%@",date];
        }
    }
    // Do any additional setup after loading the view from its nib.
}


@end
