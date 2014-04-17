//
//  CustomPickerView.m
//  IKEA
//
//  Created by Demigod on 16/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import "CustomPickerView.h"

@implementation CustomPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.pickerView setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}

- (void)awakeFromNib
{
    [self.btnDone setAction:@selector(btnDone_touchUpInside:)];
    [self.btnDone setTarget:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.pickerView setBackgroundColor:COLORFORPICKERVIEW];
}

-(void) selectRow:(NSInteger) row inComponent:(NSInteger) component animated:(BOOL) animated{
    [self.pickerView selectRow:row inComponent:component animated:animated];
}

- (void) reloadAllComponents{
    [[self pickerView] reloadAllComponents];
}

#pragma mark - UI functions
- (void) hideCancelButton{
    if([self.toolbar.items containsObject:self.btnCancel]){
        NSMutableArray *newItems = [[[NSMutableArray alloc] init] autorelease];
        for(UIBarButtonItem *item in self.toolbar.items){
            if(![item isEqual:self.btnCancel]){
                [newItems addObject:item];
            }
        }
        self.toolbar.items = newItems;
    }
}

- (void) showCancelButton{
    if(![self.toolbar.items containsObject:self.btnCancel]){
        NSMutableArray *newItems = [[[NSMutableArray alloc] init] autorelease];
        [newItems addObject:self.btnCancel];
        for(UIBarButtonItem *item in self.toolbar.items){
            if(![item isEqual:self.btnCancel]){
                [newItems addObject:item];
            }
        }
        self.toolbar.items = newItems;
    }
}

#pragma mark - event handler

- (IBAction)btnDone_touchUpInside:(id)sender {
    [self.delegate didClickDoneInCustomPickerView:self];
}

- (IBAction)btnCancel_touchUpInside:(id)sender {
    [self.delegate didClickCancelInCustomPickerView:self];
}

#pragma mark - picker view datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return [self.delegate numberOfComponentsInCustomPickerView:self];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.delegate customPickerView:self numberOfRowsInComponent:component];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.delegate customPickerView:self titleForRow:row forComponent:component];
}

#pragma mark - picker view delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self.delegate customPickerView:self didSelectRow:row inComponent:component];
}
@end
