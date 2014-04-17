//
//  AddOrUpdateNoteViewController.m
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "AddOrUpdateNoteViewController.h"
#import "UIView+Additions.h"
#import "Note.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "HomepageViewController.h"
#import "NoteListViewController.h"
@interface AddOrUpdateNoteViewController ()

- (void)loadData;
- (void)loadUI;
- (IBAction)backToHome:(id)sender;
- (void)nextNoteListView;
@end

@implementation AddOrUpdateNoteViewController

- (void)dealloc {
	[_textViewNote release];
	[_scrollview release];
	[_btnBackground release];
	[_viewNoteOverlay release];
	[_lblTitle release];
	[_btnDelete release];
	[_note release];
	[_imageViewBackGroundNotes release];
	[super dealloc];
}

- (void)viewDidUnload {
	[self setTextViewNote:nil];
	[self setScrollview:nil];
	[self setBtnBackground:nil];
	[self setViewNoteOverlay:nil];
	[self setLblTitle:nil];
	[self setBtnDelete:nil];
	[self setNote:nil];
	[self setImageViewBackGroundNotes:nil];
	[super viewDidUnload];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self loadData];
	[self loadUI];
}

- (void)loadData {
}

#pragma mark - UI functions
- (void)loadUI {
	//change the back button
	[self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT frame:CGRectMake(4, 17, 54, 23) action:@selector(back)];
	[self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT frame:CGRectMake(251, 17, 55, 23) action:@selector(btnSave_touchUpInside:)];
//    [self createRightNavigationWithTitle:@"Save" action:@selector(btnSave_touchUpInside:)];
//    [self createButtonByImageName:@"btnNoteSelected" frame:CGRectMake(71, 20, 72, 38) action:@selector(addNewNoteClicked:)];
//    [self createButtonNavigationWithTitle:@"Summary" frame:CGRectMake(154, 27, 62, 23) action:@selector(nextSummaryView)];
	[[self lblTitle] setFont:[UIFont fontWithName:kAppFont size:17]];
	self.lblTitle.text = [MASession sharedSession].currentPartner.name;

	[self moveNavigationButtonsToView:self.scrollview];

	//add tap gesture for the view
	UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewDidTap:)] autorelease];
	tapGesture.numberOfTapsRequired = 2;
	[self.viewNoteOverlay addGestureRecognizer:tapGesture];

	//set the default editable state to NO
	[self changeNoteEditableState:NO];
	//hide the save button
	ButtonControl *btnSave = (ButtonControl *)[self.scrollview viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
	if (btnSave) {
		[btnSave setHidden:YES];
	}

	//change the textview's UI
	[self.textViewNote setFont:[UIFont fontWithName:kAppFont size:13]];

	//set the text view graphics
	[self.textViewNote makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
	[self.textViewNote makeRoundCorner:5.0f];
	self.textViewNote.placeholder = [NSString stringWithFormat:@"Enter notes here to help remember special thoughts, moments or information about %@", [MASession sharedSession].currentPartner.name];

	if (self.note && ![self.note.note isEqualToString:@""]) {
		self.textViewNote.text = self.note.note;
	}
}

#pragma mark - private functions
- (IBAction)btnDelete_touchUpInside:(id)sender {
	self.textViewNote.text = @"";
	//show the save button
	ButtonControl *btnSave = (ButtonControl *)[self.scrollview viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
	if (btnSave) {
		[btnSave setHidden:NO];
	}
}

#pragma mark - private function
//change note view state
- (void)changeNoteEditableState:(BOOL)isEditable {
	if (isEditable) {
		if (self.textViewNote.isEditable == NO) {
			//send the textViewNote to the front so it can be edit by user gesture, send the double tab detect view to the back
			[[self.textViewNote superview] bringSubviewToFront:self.textViewNote];

			[self.textViewNote setEditable:YES];
			[self.textViewNote becomeFirstResponder];

			//show the save button
			ButtonControl *btnSave = (ButtonControl *)[self.scrollview viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
			if (btnSave) {
				[btnSave setHidden:NO];
			}
		}
	}
	else {
		if (self.textViewNote.isEditable == YES) {
			//send the textViewNote to the back so user can use double tap gesture
			[[self.textViewNote superview] sendSubviewToBack:self.textViewNote];

			[self.textViewNote setEditable:NO];

			//hide the save button
			ButtonControl *btnSave = (ButtonControl *)[self.scrollview viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
			if (btnSave) {
				[btnSave setHidden:YES];
			}
		}
	}
}

- (void)resignAllTextField {
	[super resignAllTextField];
	[self.textViewNote resignFirstResponder];
}

#pragma mark - tab gesture
- (void)textViewDidTap:(UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateRecognized) {
		[self changeNoteEditableState:YES];
	}
}

#pragma mark - event handler
- (void)btnSave_touchUpInside:(id)sender {
	[self changeNoteEditableState:NO];
	[self resignAllTextField];

	//save
	if (self.note) {
		if ([self.textViewNote.text isEqualToString:@""]) {
			[[DatabaseHelper sharedHelper] removeNote:self.note];
			self.note = nil;
		}
		else {
			self.note = [[DatabaseHelper sharedHelper] editNote:self.note withNewNote:self.textViewNote.text];
			if (self.note) {
				[self showMessage:@"Successfully Saved."];
			}
			else {
				[self showMessage:@"Fail to save note."];
			}
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:kSaveNoteDidFinish object:nil];
		[self nextNoteListView];
	}
	else {
		if ([self.textViewNote.text isEqualToString:@""]) {
			[self showMessage:@"Please input some note first."];
		}
		else {
			self.note = [[DatabaseHelper sharedHelper] addNote:self.textViewNote.text forPartner:[MASession sharedSession].currentPartner];
			if (self.note) {
				[[NSNotificationCenter defaultCenter] postNotificationName:kSaveNoteDidFinish object:nil];
				[self showMessage:@"Save note successfully."];
				[self nextNoteListView];
			}
			else {
				[self showMessage:@"Fail to save note."];
			}
		}
	}
}

#pragma mark - UITextViewDelegate

- (void)keyboardWillShow:(NSNotification *)notification {
	[super keyboardWillShow:notification];

	[self resizeScrollView:self.scrollview withKeyboardState:TRUE willChangeOffset:NO];
	[self.btnBackground setSize:self.scrollview.contentSize];
}

- (void)keyboardWillHide {
	[super keyboardWillHide];

	[self resizeScrollView:self.scrollview withKeyboardState:FALSE willChangeOffset:YES];
	[self.btnBackground setSize:self.scrollview.contentSize];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
}

// next view add note
- (void)addNewNoteClicked:(id)sender {
	[self popToView:[self class]];
}

- (void)nextNoteListView {
	[self popToView:[NoteListViewController class]];
}

- (IBAction)backToHome:(id)sender {
	[self popToView:[HomepageViewController class]];
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

@end
