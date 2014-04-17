//
//  CustomPickerView.h
//  IKEA
//
//  Created by Demigod on 16/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomPickerView;

@protocol CustomPickerViewDelegate

@optional
-(NSInteger)numberOfComponentsInCustomPickerView:(CustomPickerView *)pickerView;
-(NSInteger)customPickerView:(CustomPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
-(NSString *)customPickerView:(CustomPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(UIView *)customPickerView:(CustomPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
-(CGFloat)customPickerView:(CustomPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

-(void)customPickerView:(CustomPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
-(void)didClickDoneInCustomPickerView:(CustomPickerView *)pickerView;
-(void)didClickCancelInCustomPickerView:(CustomPickerView *)pickerView;

@end

@interface CustomPickerView : UIView<UIPickerViewDataSource, UIPickerViewDelegate>{

}
@property (strong, nonatomic) id<CustomPickerViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDone;

- (IBAction)btnDone_touchUpInside:(id)sender;
- (IBAction)btnCancel_touchUpInside:(id)sender;

- (void) hideCancelButton;
- (void) showCancelButton;

- (void) reloadAllComponents;
-(void) selectRow:(NSInteger) row inComponent:(NSInteger) component animated:(BOOL) animated;
@end
