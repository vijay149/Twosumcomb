//
//  MADateSelectTextField.m
//  Manapp
//
//  Created by Demigod on 26/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MADateSelectTextField.h"
#import "NSDate+Helper.h"

@implementation MADateSelectTextField
@synthesize toolBar = _toolBar;
@synthesize datePicker = _datePicker;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews{
    if(!self.datePicker){
        _datePicker = [[UIDatePicker alloc] init];
        [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        self.inputView = self.datePicker;
    }
    
    if(!self.toolBar){
        //accessory view
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.toolBar.barStyle = UIBarStyleBlackTranslucent;
//        UIBarButtonItem *cancel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)] autorelease];
        UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *done = [[[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(doneTapped:)] autorelease];
        self.toolBar.items = [NSArray arrayWithObjects:space,done, nil];
        
        
        self.inputAccessoryView = self.toolBar;
    }
    
    [super layoutSubviews];
}

-(void)dealloc{
    [_toolBar release];
    [_datePicker release];
    
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - event handler
-(void)datePickerValueChanged:(id)sender{
    self.text = [self.datePicker.date stringWithStyle:MANAPP_DATETIME_DEFAULT_TYPE];
}

-(void)doneTapped:(id)sender{
    self.text = [self.datePicker.date stringWithStyle:MANAPP_DATETIME_DEFAULT_TYPE];
    [self resignFirstResponder];
}

-(void)cancelTapped:(id)sender{
    [self resignFirstResponder];
}

@end
