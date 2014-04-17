//
//  MADateSelectTextField.h
//  Manapp
//
//  Created by Demigod on 26/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MADateSelectTextField;

@interface MADateSelectTextField : UITextField{
    
}

@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) UIDatePicker *datePicker;

-(void)datePickerValueChanged:(id)sender;
-(void)doneTapped:(id)sender;
-(void)cancelTapped:(id)sender;
@end
