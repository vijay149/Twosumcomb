//
//  NoteListViewController.m
//  TwoSum
//
//  Created by Duong Van Dinh on 10/11/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "NoteListViewController.h"
#import "SummaryViewController.h"
#import "UILabel+Additions.h"
#import "MANotesCell.h"
#import "AddOrUpdateNoteViewController.h"
#import "Util.h"
#import "Note.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "HomepageViewController.h"

@interface NoteListViewController ()

- (void)initializeUI;
- (void)loadData;
- (void)addNewNoteClicked:(id)sender;
- (IBAction)backToHome:(id)sender;
- (void)nextSummaryView;
@end

@implementation NoteListViewController

- (void)dealloc {
	[_tableViewNoteList release];
	[_arrayNotes release];
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeUI];
	[self loadData];
}

#pragma mark - init functions
- (void)initializeUI {
	[self.navigationController setNavigationBarHidden:YES];
	[self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(backToHome:)];
	[self createButtonByImageName:@"btnNoteSelected" frame:CGRectMake(74, 20, 72, 38) action:@selector(loadData)];
	[self createButtonNavigationWithTitle:@"Summary" frame:CGRectMake(159, 27, 62, 23) action:@selector(nextSummaryView)];
	[self createRightNavigationWithTitle:MA_ADD_BUTTON_TEXT action:@selector(addNewNoteClicked:)];
	//gesture
	[self addSwipeBackGesture];
}

#pragma mark - data functions
- (void)loadData {
	/* check the current partner */
	if (![MASession sharedSession].currentPartner) {
		return;
	}
	NSArray *notes = [[DatabaseHelper sharedHelper] getNotesForPartner:[MASession sharedSession].currentPartner];
	if ([notes count] > 0) {
		self.arrayNotes = [NSMutableArray arrayWithArray:notes];
	}
	else {
		self.arrayNotes = [NSMutableArray array];
	}
	[self.tableViewNoteList reloadData];
}

- (void)reloadData {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kSaveNoteDidFinish object:nil];
	[self loadData];
}

// next view add note
- (void)addNewNoteClicked:(id)sender {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kSaveNoteDidFinish object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kSaveNoteDidFinish object:nil];
	[self popToView:[AddOrUpdateNoteViewController class]];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.arrayNotes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (self.arrayNotes && self.arrayNotes.count > 0) {
		UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, MANAPP_SUMMARY_VIEW_HEADER_HEIGHT)] autorelease];

		//background
		UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:headerView.frame] autorelease];
		[backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
		backgroundView.image = [UIImage imageNamed:@"preferenceSectionBg"];
		[headerView addSubview:backgroundView];

		//text
		UILabel *lblTitle = [[[UILabel alloc] initWithFrame:headerView.frame] autorelease];
		lblTitle.textAlignment = NSTextAlignmentCenter;
		lblTitle.backgroundColor = [UIColor clearColor];
		[lblTitle setFont:[UIFont fontWithName:kAppFont size:18]];
		[lblTitle setTextColor:[UIColor whiteColor]];
		[headerView addSubview:lblTitle];
		lblTitle.text = @"Notes";
		return headerView;
	}
	else {
		return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	MANotesCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = (MANotesCell *)[Util getCell:[MANotesCell class] owner:self];
	}

	if (self.arrayNotes && self.arrayNotes.count > 0) {
		Note *noteItem = (Note *)self.arrayNotes[indexPath.row];
		if (noteItem && noteItem.note) {
			cell.lblTitle.text = noteItem.note;
			[cell.lblTitle enlargeHeightToKeepFontSize];
		}
		if (indexPath.row == self.arrayNotes.count - 1) {
			cell.viewSeparate.hidden = YES;
			if ([noteItem isEqual:self.arrayNotes[self.arrayNotes.count - 1]]) {
				cell.viewSeparate.hidden = NO;
			}
		}
		else {
			cell.viewSeparate.hidden = NO;
		}
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (self.arrayNotes && self.arrayNotes.count > 0) {
		return MANAPP_SUMMARY_VIEW_HEADER_HEIGHT;
	}
	else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Note *note = [self.arrayNotes objectAtIndex:indexPath.row];
	return [MANotesCell cellHeightForItem:note];
}

// view detail to edit or delete.
// dont use
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Note *noteItem = [self.arrayNotes objectAtIndex:indexPath.row];
	AddOrUpdateNoteViewController *addOrUpdateView = nil;
	if (noteItem) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:kSaveNoteDidFinish object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kSaveNoteDidFinish object:nil];
		BOOL isFound = NO;
		NSArray *viewControllers = self.navigationController.viewControllers;
		if (viewControllers && viewControllers.count > 0) {
			for (UIViewController *view in viewControllers) {
				if ([view isKindOfClass:[AddOrUpdateNoteViewController class]]) {
					addOrUpdateView = (AddOrUpdateNoteViewController *)view;
					addOrUpdateView.note = noteItem;
					isFound = YES;
					[self.navigationController popToViewController:view animated:YES];
					break;
				}
			}
			if (!isFound) {
				addOrUpdateView = [self getViewControllerByName:@"AddOrUpdateNoteViewController"];
				addOrUpdateView.note = noteItem;
				[self nextTo:addOrUpdateView];
			}
		}
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setTableViewNoteList:nil];
	[super viewDidUnload];
}

- (IBAction)backToHome:(id)sender {
	[self popToView:[HomepageViewController class]];
}

- (void)nextSummaryView {
	SummaryViewController *sm = NEW_VC(SummaryViewController);
	[self nextTo:sm];
	//    [self popToView:[SummaryViewController class]];
}

@end
