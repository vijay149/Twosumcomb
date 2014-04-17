//
//  SelectionListViewController.h
//  Manapp
//
//  Created by Demigod on 25/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#define kHeightOfViewControl 250



#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Global.h"

@class SelectionListViewController;

@protocol SelectionListViewControllerDelegate

@optional
- (void) selectionList:(SelectionListViewController *) view didSelectItem:(NSInteger) index endDate:(NSDate *)endDate;
- (void) selectionList:(SelectionListViewController *) view didSelectItem:(NSInteger) index;
@end

@interface SelectionListViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    NSInteger _selectedItemIndex;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) id<SelectionListViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *viewControll;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckForever;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelForever;
@property (retain, nonatomic) IBOutlet UILabel *lblEndDate;
@property (strong, nonatomic) IBOutlet UIButton *btnChooseEndDate;
@property (strong, nonatomic) IBOutlet UIView *viewPicker;

@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic) MODE_VIEW *modeView;

-(void) reloadUIWithItems:(NSArray *) items andSelectedItem:(NSString *) selectedItem;

- (IBAction)btnCheckForeverClicked:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;
- (IBAction)btnChooseEndDateClicked:(id)sender;
- (IBAction)btnSelectDateClicked:(id)sender;

@end
