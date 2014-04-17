//
//  ChangeEventDateViewController.h
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "MACheckBoxButton.h"
#import "NSDate+Helper.h"

@class ChangeEventDateViewController;

@protocol ChangeEventDateViewControllerDelegate

@optional
-(void) changeEventDateView:(ChangeEventDateViewController*) view didSaveWithStartDate:(NSDate*) startDate endDate:(NSDate*) endDate;

@end

@interface ChangeEventDateViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>{
    NSInteger _selectedRow;                             //to know which datetime field is currently focused
    BOOL _isAllDay;
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewEventItem;
@property (retain, nonatomic) MACheckBoxButton *checkBoxAllDay;
@property (retain, nonatomic) UILabel *lblAllday;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePickerEventTime;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) id<ChangeEventDateViewControllerDelegate> delegate;

- (IBAction)datePickerEventTime_dateDidChanged:(id)sender;
- (void) setDefautPickerWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
