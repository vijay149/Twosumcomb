//
//  AddEventViewController.h
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

@class UIPlaceHolderTextView;
@class Event;

#define MANAPP_ADD_EVENT_VIEW_SECTION_TITLE 0
#define MANAPP_ADD_EVENT_VIEW_SECTION_TIME 1
#define MANAPP_ADD_EVENT_VIEW_SECTION_REMINDER 2
#define MANAPP_ADD_EVENT_VIEW_SECTION_RECUR 3

@interface AddEventViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>{
    BOOL _stateCreation;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewNote;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;

@property (retain, nonatomic) Event* selectedEvent;

@property (nonatomic, retain) NSArray *recurrenceItems;
@property (nonatomic, retain) NSArray *reminderItems;

- (IBAction)btnDelete_touchUpInside:(id)sender;

@end
