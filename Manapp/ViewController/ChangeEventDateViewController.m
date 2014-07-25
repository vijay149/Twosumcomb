//
//  ChangeEventDateViewController.m
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "ChangeEventDateViewController.h"

@interface ChangeEventDateViewController ()
- (void) initialize;
@end

@implementation ChangeEventDateViewController
@synthesize tableViewEventItem = _tableViewEventItem;
@synthesize datePickerEventTime = _datePickerEventTime;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;

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
    // Do any additional setup after loading the view from its nib.
    //prepare UI
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableViewEventItem release];
    [_datePickerEventTime release];
    [_startDate release];
    [_endDate release];
    [super dealloc];
}

#pragma mark - init functions
- (void) initialize{
    
}

#pragma mark - event handler
- (IBAction)datePickerEventTime_dateDidChanged:(id)sender {
}
@end
