//
//  AddEventViewController.h
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChangeEventDateViewController.h"
#import "SelectionListViewController.h"
#import "BaseViewController.h"
#import "MACommon.h"

@class UIPlaceHolderTextView;
@class Event;
@class AddEventViewController;

#define MANAPP_ADD_EVENT_VIEW_SECTION_TITLE 0
#define MANAPP_ADD_EVENT_VIEW_SECTION_TIME 1
#define MANAPP_ADD_EVENT_VIEW_SECTION_REMINDER 2
#define MANAPP_ADD_EVENT_VIEW_SECTION_RECUR 3

#define MANAPP_ADD_EVENT_VIEW_SUCCESS_ADD_EVENT_ALERT_TAG 100
#define MANAPP_ADD_EVENT_VIEW_SUCCESS_DELETE_EVENT_ALERT_TAG 101
#define MANAPP_ADD_EVENT_VIEW_DELETE_ALL_NOTIFICATION 102

@protocol AddEventViewControllerDelegate

@optional
- (void) addEventViewControllerDidSaveEvent:(AddEventViewController*) view;
- (void) addEventViewControllerDidDeleteEvent:(AddEventViewController*) view;
@end

@interface AddEventViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate, ChangeEventDateViewControllerDelegate, SelectionListViewControllerDelegate>{
    BOOL _isEditMode;
}

@property (retain, nonatomic) id<AddEventViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewNote;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;

@property (retain, nonatomic) NSDate* selectedDate;
@property (retain, nonatomic) Event* selectedEvent;

@property (nonatomic, retain) NSArray *recurrenceItems;
@property (nonatomic, retain) NSArray *reminderItems;

@property (nonatomic, strong) IBOutlet UIView *infoView;

- (void) changeUIToEditModeWithEvent:(Event *) event;
- (IBAction)btnDelete_touchUpInside:(id)sender;

@end
