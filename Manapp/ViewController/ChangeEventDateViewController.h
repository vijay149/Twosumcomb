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

@interface ChangeEventDateViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>{
    NSInteger _selectedRow;                             //to know which datetime field is currently focused
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewEventItem;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePickerEventTime;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

- (IBAction)datePickerEventTime_dateDidChanged:(id)sender;

@end
