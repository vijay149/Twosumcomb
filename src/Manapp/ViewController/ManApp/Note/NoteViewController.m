//
//  NoteViewController.m
//  Manapp
//
//  Created by Demigod on 07/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "NoteViewController.h"
#import "UIView+Additions.h"
#import "Note.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "SummaryViewController.h"
#import "AddOrUpdateNoteViewController.h"


#define kTagLeaveNote 1111
@interface NoteViewController ()

- (void)addNewNoteClicked:(id)sender;
- (void)nextSummaryView;

/**
 *  Keyboard controls.
 */
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
- (void)createButtonDone;
@end

@implementation NoteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	[self loadData];
	[self loadUI];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[_textViewNote release];
	[_scrollview release];
	[_btnBackground release];
	[_viewNoteOverlay release];
	[_lblTitle release];
	[_btnDelete release];
	[_viewHeader release];
	[_keyboardControls release];
	[super dealloc];
}

- (void)viewDidUnload {
	[self setTextViewNote:nil];
	[self setScrollview:nil];
	[self setBtnBackground:nil];
	[self setViewNoteOverlay:nil];
	[self setLblTitle:nil];
	[self setBtnDelete:nil];
	[self setViewHeader:nil];
	[super viewDidUnload];
}

#pragma mark - data functions
- (void)loadData {
	/* check the current partner */
	if (![MASession sharedSession].currentPartner) {
		return;
	}
	NSArray *notes = [[DatabaseHelper sharedHelper] getNotesForPartner:[MASession sharedSession].currentPartner];
	if ([notes count] > 0) {
		self.note = [notes objectAtIndex:([notes count] - 1)];
	}
}

- (void)reloadData {
	/* check the current partner */
	if (![MASession sharedSession].currentPartner) {
		return;
	}
	NSArray *notes = [[DatabaseHelper sharedHelper] getNotesForPartner:[MASession sharedSession].currentPartner];
	if (notes.count > 0) {
		self.note = [notes objectAtIndex:(notes.count - 1)];
	}
}

#pragma mark - UI functions
- (void)loadUI {
	[self.navigationController setNavigationBarHidden:YES];
	//change the back button
	[self createBackNavigationWithTitle:@"Home" action:@selector(back)];
	[self createRightNavigationWithTitle:@"Save" action:@selector(btnSave_touchUpInside:)];
	[self createButtonByImageName:@"btnNoteSelected" frame:CGRectMake(71, 18, 75, 40) action:@selector(addNewNoteClicked:)];
	[self createButtonNavigationWithTitle:@"Summary" frame:CGRectMake(154, 27, 62, 23) action:@selector(nextSummaryView)];
//    [self createButtonNavigationWithTitle:@"Notes" frame:CGRectMake(75, 27, 60, 23) action:@selector(addNewNoteClicked:)];
//    [self createButtonNavigationWithTitle:@"Summary" frame:CGRectMake(152, 27, 80, 23) action:@selector(nextSummaryView)];
	[[self lblTitle] setFont:[UIFont fontWithName:kAppFont size:17]];
//    self.lblTitle.text = [MASession sharedSession].currentPartner.name;
	self.lblTitle.text = @"Notes";
	[self moveNavigationButtonsToView:self.scrollview];
	[self.scrollview addSubview:self.viewHeader];
	//add tap gesture for the view
	UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewDidTap:)] autorelease];
	tapGesture.numberOfTapsRequired = 1;
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
	// hidden border
//    [self.textViewNote makeBorderWithWidth:1.0f andColor:[UIColor lightGrayColor]];
//    [self.textViewNote makeRoundCorner:5.0f];
	self.textViewNote.placeholder = [NSString stringWithFormat:@"Enter notes here to help remember special thoughts, moments or information about %@", [MASession sharedSession].currentPartner.name];

	if (self.note && ![self.note.note isEqualToString:@""]) {
		self.textViewNote.text = self.note.note;
	}

	// createButtonDone when show keyboard
	[self createButtonDone];
}

// createButtonDone when show keyboard.
- (void)createButtonDone {
	//
	self.keyboardControls = [[BSKeyboardControls alloc] init];
	self.keyboardControls.delegate = self;
	self.keyboardControls.textFields = @[self.textViewNote];
	[self.keyboardControls hidePrevNextButtons:YES];
	// Add the keyboard control as accessory view for all of the text fields
	// Also set the delegate of all the text fields to self
	[self.keyboardControls reloadTextFields];
}

#pragma mark - private functions
- (IBAction)btnDelete_touchUpInside:(id)sender {
	self.textViewNote.text = @"";
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

#pragma mark - tab gesture
- (void)textViewDidTap:(UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateRecognized) {
		[self changeNoteEditableState:YES];
	}
}

#pragma mark - event handler
- (void)btnSave_touchUpInside:(id)sender {
	[self changeNoteEditableState:NO];
	[self.textViewNote resignFirstResponder];

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
	}
	else {
		if ([self.textViewNote.text isEqualToString:@""]) {
			[self showMessage:@"Please input some note first."];
		}
		else {
			self.note = [[DatabaseHelper sharedHelper] addNote:self.textViewNote.text forPartner:[MASession sharedSession].currentPartner];
			if (self.note) {
				[self showMessage:@"Saved note successfully."];
			}
			else {
				[self showMessage:@"Fail to save note."];
			}
		}
	}
}

#pragma mark - UITextViewDelegate

//-(void)keyboardWillShow:(NSNotification *)notification{
//    [super keyboardWillShow:notification];
//
//    [self resizeScrollView:self.scrollview withKeyboardState:TRUE willChangeOffset:NO];
//    [self.btnBackground setSize:self.scrollview.contentSize];
//}
//
//-(void)keyboardWillHide{
//    [super keyboardWillHide];
//
//    [self resizeScrollView:self.scrollview withKeyboardState:FALSE willChangeOffset:YES];
//    [self.btnBackground setSize:self.scrollview.contentSize];
//}

/**
 *  Show alert when go away this view
 */
- (void)back{
    if (![self.textViewNote.text isEqualToString:self.note.note]) {
        if (self.textViewNote.text.length == 0 && !self.note.note) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        UIAlertView *alertAway = [[UIAlertView alloc]initWithTitle:@"TwoSum" message:@"Save me now or lose me forever." delegate:self cancelButtonTitle:@"Stay" otherButtonTitles:@"Leave", nil];
        alertAway.tag = kTagLeaveNote;
        [alertAway show];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([self.keyboardControls.textFields containsObject:textField])
		self.keyboardControls.activeTextField = textField;
}

#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls {
	[controls.activeTextField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	self.scrollview.transform = CGAffineTransformTranslate(self.scrollview.transform, 0, -100);
	[UIView commitAnimations];

	if ([self.keyboardControls.textFields containsObject:textView])
		self.keyboardControls.activeTextField = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	self.scrollview.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
	//error on ios7
//	[textView resignFirstResponder];
//    [textView becomeFirstResponder];
}

- (BOOL)textViewsShouldReturn:(UITextView *)textField {
	[textField resignFirstResponder];
	return YES;
}

// next view add note
- (void)addNewNoteClicked:(id)sender {
	[self popToView:[NoteViewController class]];
//    AddOrUpdateNoteViewController *addNewNote = NEW_VC(AddOrUpdateNoteViewController);
//    [self nextTo:addNewNote];
}

- (void)nextSummaryView {
	SummaryViewController *sm = NEW_VC(SummaryViewController);
	[self nextTo:sm];
//    [self popToView:[SummaryViewController class]];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kTagLeaveNote) {
        if (buttonIndex == 0) {
            return;
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
