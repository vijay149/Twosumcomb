//
//  NoteListViewController.h
//  TwoSum
//
//  Created by Duong Van Dinh on 10/11/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#define MANAPP_SUMMARY_VIEW_HEADER_HEIGHT 28

@interface NoteListViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tableViewNoteList;
@property (nonatomic, retain) NSMutableArray *arrayNotes;

- (void)reloadData;
@end
