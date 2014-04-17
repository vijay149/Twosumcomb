//
//  CreatePartnerViewController.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "CreatePartnerViewController.h"
#import "UITextField+Additional.h"
#import "NSDate+Helper.h"
#import "UIView+Additions.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "MACheckBoxButton.h"
#import "MAUserProcessManager.h"
#import "UICustomProgressBar.h"
#import "AdditionalInformationViewController.h"
#import "MeasurementViewController.h"
#import "PreferenceViewController.h"
#import "MASession.h"
#import "HelpViewController.h"
#import "UILabel+Additions.h"
#import "SpecialZoneViewController.h"
#import "HomepageViewController.h"
#import "GCDispatch.h"
#import "AvatarHelper.h"
#import "MANetworkHelper.h"
#import "MessageDTO.h"
#import "AFJSONUtilities.h"

#define kAlertBirthDayTag 140
#define kAlertFirstMeetTag 141

@interface CreatePartnerViewController ()
- (void)loadUI;
- (void)loadDatePickers;
- (void)loadCheckBoxs;
- (void)loadProcessBar;
- (void)fillViewWithData;

- (void)autoCreateOrEditPartner;

- (void)backSetting:(id)sender;
- (void)doneSetting:(id)sender;
- (void)datePickerDateChanged:(UIDatePicker *)paramDatePicker;
- (void)checkboxesChecked:(id)sender;

- (void)resetAllFields;
- (void)setFieldsByPartnerData:(Partner *)partner;

- (void)deleteCurrentPartner;

- (BOOL)checkPartnerDataValidationWithMessage:(BOOL)showMessage;
- (void)removeDefaultValueMood;
@end

@implementation CreatePartnerViewController
@synthesize delegate;
@synthesize datePickerDateOfBirth = _datePickerDateOfBirth;
@synthesize datePickerFirstMeet = _datePickerFirstMeet;
@synthesize backgroundScrollView = _backgroundScrollView;
@synthesize txtPartnerName = _txtPartnerName;
@synthesize txtDateOfBirth = _txtDateOfBirth;
@synthesize txtFirstMeetDate = _txtFirstMeetDate;
@synthesize lblProcessValue = _lblProcessValue;
@synthesize lblCreatePartnerTitle = _lblCreatePartnerTitle;
@synthesize lblAdvice = _lblAdvice;
@synthesize lblPartnerName = _lblPartnerName;
@synthesize lblDateOfBirth = _lblDateOfBirth;
@synthesize lblFirstMeetDate = _lblFirstMeetDate;
@synthesize lblMale = _lblMale;
@synthesize datePickerView = _datePickerView;
@synthesize lblFemale = _lblFemale;
@synthesize checkBoxFemale = _checkBoxFemale;
@synthesize checkBoxMale = _checkBoxMale;
@synthesize viewProcessBar = _viewProcessBar;
@synthesize lblProcessBar = _lblProcessBar;
@synthesize processBar = _processBar;

- (void)dealloc {
	self.delegate = nil;
	[_txtPartnerName release];
	[_backgroundScrollView release];
	[_datePickerDateOfBirth release];
	[_datePickerFirstMeet release];
	[_txtDateOfBirth release];
	[_txtFirstMeetDate release];
	[_lblProcessValue release];
	[_lblCreatePartnerTitle release];
	[_lblAdvice release];
	[_lblPartnerName release];
	[_lblDateOfBirth release];
	[_lblFirstMeetDate release];
	[_lblMale release];
	[_lblFemale release];
	[_datePickerView release];
	[_checkBoxFemale release];
	[_checkBoxMale release];
	[_btnDeletePartner release];
	[_viewProcessBar release];
	[_lblProcessBar release];
	[_processBar release];
	[_btnHelp release];
	[_btnDateOfBirth release];
	[_btnFirstMet release];
	[_btnBackground release];
	[_lblGender release];
	[super dealloc];
}

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


	//prepare the UI
	[self loadUI];

	//date picker
	[self loadDatePickers];

	//check box
	[self loadCheckBoxs];

	//process bar
	[self loadProcessBar];

	//fill the view with partner data
	[self fillViewWithData];
//    [[Util sharedUtil] hideLoadingView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	//hide navigation bar
	[self.navigationController setNavigationBarHidden:YES];

	//incase there is any update, reload the process bar value
	[self loadProcessBar];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - private functions
//prepare the UI
- (void)loadUI {
	//change the back button
	[self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(btnBack_touchUpInside:)];
	[self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(btnSave_touchUpInside:)];

	[self moveNavigationButtonsToView:self.backgroundScrollView];

	//change textfield and label UI
//    [self.txtPartnerName paddingLeftByValue:15];
//    [self.txtFirstMeetDate paddingLeftByValue:5];
//    [self.txtDateOfBirth paddingLeftByValue:5];

	[self.txtPartnerName setFont:[UIFont fontWithName:kAppFont size:14]];
	[self.txtFirstMeetDate setFont:[UIFont fontWithName:kAppFont size:10]];
	[self.txtDateOfBirth setFont:[UIFont fontWithName:kAppFont size:10]];

	[self.lblCreatePartnerTitle setFont:[UIFont fontWithName:kAppFont size:24]];

	[self.lblAdvice setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblAdvice addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblPartnerName setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblPartnerName addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblDateOfBirth setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblDateOfBirth addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblFirstMeetDate setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblFirstMeetDate addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblGender setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblGender addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblFemale setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblFemale addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];

	[self.lblMale setFont:[UIFont fontWithName:kAppFont size:13]];
	[self.lblMale addShadowWithRadius:1 opacity:0.7 offset:CGSizeMake(0.0, 1.0) color:[UIColor blackColor]];
}

- (void)fillViewWithData {
	if ([[MASession sharedSession] currentPartner]) {
		self.btnDeletePartner.enabled = YES;
		//partner name
		self.txtPartnerName.text = [[MASession sharedSession] currentPartner].name;

		// date of birth's field
		self.txtDateOfBirth.text = ([[MASession sharedSession] currentPartner].dateOfBirth) ? [[[MASession sharedSession] currentPartner].dateOfBirth toString] : @"/     /";

		//first meet date's field
		self.txtFirstMeetDate.text = ([[MASession sharedSession] currentPartner].firstDate) ? [[[MASession sharedSession] currentPartner].firstDate toString] : @"/     /";
	}
	else {
		self.btnDeletePartner.enabled = NO;
	}
}

//init the date picker
- (void)loadDatePickers {
	int datePickerViewHeight = 256;
	if (!self.datePickerView) {
		//create the background view for picker
		_datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - datePickerViewHeight, self.view.frame.size.width, datePickerViewHeight)];
		self.datePickerView.hidden = TRUE;
		self.datePickerView.backgroundColor = [UIColor clearColor];

		[self.view addSubview:self.datePickerView];
		[self.view bringSubviewToFront:self.datePickerView];

		//generate the date pickers
		//date of birth picker
		CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
		_datePickerDateOfBirth = [[UIDatePicker alloc] initWithFrame:pickerFrame];
		self.datePickerDateOfBirth.hidden = TRUE;
		self.datePickerDateOfBirth.datePickerMode = UIDatePickerModeDate;
		[self.datePickerDateOfBirth addTarget:self
		                               action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
		[self.datePickerDateOfBirth setBackgroundColor:COLORFORPICKERVIEW];
		[self.datePickerView addSubview:self.datePickerDateOfBirth];

		//first meet date picker (make sure this picker cannot select the date time which is less than DOB
		_datePickerFirstMeet = [[UIDatePicker alloc] initWithFrame:pickerFrame];
		self.datePickerFirstMeet.hidden = TRUE;
		self.datePickerFirstMeet.datePickerMode = UIDatePickerModeDate;
		[self.datePickerFirstMeet addTarget:self
		                             action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
		[self.datePickerFirstMeet setBackgroundColor:COLORFORPICKERVIEW];
		[self.datePickerView addSubview:self.datePickerFirstMeet];

//       0 NSDate *currentDate = [NSDate date];
//        [self.datePickerDateOfBirth setMaximumDate:currentDate];
//        [self.datePickerFirstMeet setMaximumDate:currentDate];

		// COMMENT: add toolbar with done button to the picker (with two button at the bar)
		UIToolbar *pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
		pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
		[pickerToolbar sizeToFit];

		NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        // Cuongnt Create Cancel button
        
        UIBarButtonItem *btnCanel = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelEditing:)] autorelease];
        [barItems addObject:btnCanel];

		UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
		[barItems addObject:flexSpace];
		UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleDone target:self action:@selector(doneSetting:)] autorelease];
		[barItems addObject:doneBtn];
		[pickerToolbar setItems:barItems animated:YES];
		[self.datePickerView addSubview:pickerToolbar];
	}

	//set the date time picker incase the selected user is existed
	if ([[MASession sharedSession] currentPartner]) {
		if ([[MASession sharedSession] currentPartner].dateOfBirth) {
			[self.datePickerDateOfBirth setDate:[[MASession sharedSession] currentPartner].dateOfBirth animated:YES];
		}

		if ([[MASession sharedSession] currentPartner].firstDate) {
			[self.datePickerFirstMeet setDate:[[MASession sharedSession] currentPartner].firstDate animated:YES];
		}
	}
	else {
		[self.datePickerDateOfBirth setDate:[[NSDate date] dateByAddDays:-1] animated:YES];
		[self.datePickerFirstMeet setDate:[NSDate date] animated:YES];

		self.txtDateOfBirth.text = [NSString stringWithFormat:@"%@", [self.datePickerDateOfBirth.date toString]];
		self.txtFirstMeetDate.text = [NSString stringWithFormat:@"%@", [self.datePickerDateOfBirth.date toString]];
	}
}

- (void)loadCheckBoxs {
	if (!self.checkBoxMale) {
		_checkBoxMale = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(275, 340, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
		[self.checkBoxMale addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
		self.checkBoxMale.isAllowToggle = NO;
		[self.backgroundScrollView addSubview:self.checkBoxMale];
	}

	if (!self.checkBoxFemale) {
		_checkBoxFemale = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(163, 340, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
		[self.checkBoxFemale addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
		self.checkBoxFemale.isAllowToggle = NO;
		[self.backgroundScrollView addSubview:self.checkBoxFemale];
	}

	//if the partner existed, check the correct checkbox
	if ([[MASession sharedSession] currentPartner]) {
		if ([[[MASession sharedSession] currentPartner].sex intValue] == 1) {
			[self.checkBoxMale setCheckWithState:YES];
		}
		else {
			[self.checkBoxFemale setCheckWithState:YES];
		}
	}
	else {
		[self checkboxesChecked:self.checkBoxFemale];
	}
}

- (void)loadProcessBar {
	// COMMENT: generate progress bar and set its value
	if (!self.processBar) {
		_processBar = [[UICustomProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progressbar-bg"]  progressImage:[UIImage imageNamed:@"progressbar"] progressMask:[UIImage imageNamed:@"progressbar-mask"] insets:CGSizeMake(3, 2) barWidth:120];

		[self.viewProcessBar addSubview:self.processBar];
		[self.processBar setOrigin:CGPointMake(0, 0)];
		self.processBar.maxValue = 100.0f;
	}

	// if the current partner is existed, get his process value. If not, set the process bar by 0
	if ([[MASession sharedSession] currentPartner]) {
		self.processBar.currentValue = (NSInteger)[[MAUserProcessManager sharedInstance] getProcessForCurrentPartner];
	}
	else {
		self.processBar.currentValue = 0;
	}

	//change the label value
	self.lblProcessBar.text = [NSString stringWithFormat:@"%d%%", (NSInteger)self.processBar.currentValue];
}

#pragma mark - private function
//when there is any change, automatically update (or create if need) avatar information
- (void)autoCreateOrEditPartner {
	//only call this function if the username field was filled
	NSString *stringWithoutSpace = [self.txtPartnerName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	if (!(self.txtPartnerName.text == NULL) && ![stringWithoutSpace isEqualToString:@""]) {
		//check if partner is existed or not, if not then create new one before edit.
		if ([[MASession sharedSession] currentPartner] == NULL) {
			// the avatar isn't existed, create the new one

			if ([[DatabaseHelper sharedHelper] isPartnerWithSameNameExisted:self.txtPartnerName.text forUserId:[MASession sharedSession].userID asideFromPartner:nil]) {
				if (!_isDuplicateNameMessageVisible) {
					[self showMessage:LSSTRING(@"There is a partner with the same name.Please change this partner name") title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_DUPLICATE_PARTNER_NAME];
					_isDuplicateNameMessageVisible = TRUE;
				}
				self.txtPartnerName.text = @"";
				return;
			}

			BOOL addResult = [[DatabaseHelper sharedHelper] createParnerWithName:[self.txtPartnerName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] dOB:[NSDate fromString:self.txtDateOfBirth.text] calendarType:YES sex:self.checkBoxMale.isChecked firstMeet:[NSDate fromString:self.txtFirstMeetDate.text] forUserId:[[MASession sharedSession] userID]];
			//create success
			if (addResult) {
				//get the newest partner
				Partner *newPartner = [[DatabaseHelper sharedHelper] getPartnerByName:self.txtPartnerName.text];
				[[MASession sharedSession] setCurrentPartner:newPartner];

				//end set default value for new partner.
				//add the sample mood for this partner
				[[DatabaseHelper sharedHelper] addSampleMoodsForPartner:newPartner fromDate:[NSDate date]];

				//inform the homepage that we just add new partner
				if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didAddPartner:)]) {
					[self.delegate createPartnerViewController:self didAddPartner:[newPartner.partnerID intValue]];
				}

				//update the homepage with new user
				if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didUpdateForPartner:)]) {
					[self.delegate createPartnerViewController:self didUpdateForPartner:[newPartner.partnerID intValue]];
				}

				//update the birthdate events
				[[DatabaseHelper sharedHelper] createBirthdayEventsForPartner:newPartner];
                //Update the FirstMeet Events
                [[DatabaseHelper sharedHelper] createFirstMeetEventsForPartner:[MASession sharedSession].currentPartner];

				//update message
				[[DatabaseHelper sharedHelper] renewMessagesForPartner:newPartner];
				//begin set default value for new partner
				NSInteger partnerID = [MASession sharedSession].currentPartner.partnerID.integerValue;
				NSString *key = [NSString stringWithFormat:@"%@%d", kValueMoodSelected, partnerID];
				[UserDefault setValue:[NSNumber numberWithInt:MA_DEFAULT_MOOD_VALUE] forKey:key];
				[UserDefault synchronize];
			}
			else {
				DLog(@"Automatic add failed");
			}
		}
		else {
			if ([[DatabaseHelper sharedHelper] isPartnerWithSameNameExisted:self.txtPartnerName.text forUserId:[MASession sharedSession].userID asideFromPartner:[[MASession sharedSession] currentPartner]]) {
				if (!_isDuplicateNameMessageVisible) {
					[self showMessage:LSSTRING(@"There is a partner with the same name.Please change this partner name") title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_DUPLICATE_PARTNER_NAME];
					_isDuplicateNameMessageVisible = TRUE;
				}
				self.txtPartnerName.text = [[MASession sharedSession] currentPartner].name;
				return;
			}
			// edit to the current partner
			if ([[[MASession sharedSession] currentPartner] isKindOfClass:[Partner class]] && [[MASession sharedSession] currentPartner] != nil) {
				BOOL editResult = [[DatabaseHelper sharedHelper] editParnerWithId:[[[MASession sharedSession] currentPartner].partnerID intValue] name:self.txtPartnerName.text dOB:[NSDate fromString:self.txtDateOfBirth.text] calendarType:YES sex:self.checkBoxMale.isChecked firstMeet:[NSDate fromString:self.txtFirstMeetDate.text]];

				//update the birthdate events
				[[DatabaseHelper sharedHelper] createBirthdayEventsForPartner:[[MASession sharedSession] currentPartner]];
                //Update the FirstMeet Events
                [[DatabaseHelper sharedHelper] createFirstMeetEventsForPartner:[MASession sharedSession].currentPartner];

				//report back to home page
				if (editResult) {
					[[MASession sharedSession] setCurrentPartner:[[DatabaseHelper sharedHelper] getPartnerById:[[[MASession sharedSession] currentPartner].partnerID intValue]]];
					if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didUpdateForPartner:)]) {
						[self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
						/**
						 *  renew message
						 */
						[[DatabaseHelper sharedHelper] renewMessagesForPartner:[MASession sharedSession].currentPartner];
					}

					self.btnDeletePartner.enabled = YES;
					DLog(@"Automatic edit successfully");
				}
				else
					self.btnDeletePartner.enabled = NO;
				DLog(@"Automatic edit failed");
			}
		}
	}
}

//clear the fields
- (void)resetAllFields {
	self.txtPartnerName.text = @"";
	self.txtDateOfBirth.text = @"/     /";
	self.txtFirstMeetDate.text = @"/     /";
	self.btnDeletePartner.enabled = NO;
}

- (void)setFieldsByPartnerData:(Partner *)partner {
	//partner name
	self.txtPartnerName.text = partner.name;

	// date of birth's field
	self.txtDateOfBirth.text = (partner.dateOfBirth) ? [partner.dateOfBirth toString] : @"/     /";

	//first meet date's field
	self.txtFirstMeetDate.text = (partner.firstDate) ? [partner.firstDate toString] : @"/     /";

	//date time
	if (partner.dateOfBirth) {
		[self.datePickerDateOfBirth setDate:partner.dateOfBirth animated:YES];
	}

	if (partner.firstDate) {
		[self.datePickerFirstMeet setDate:partner.firstDate animated:YES];
	}

	//checkboxs
	if ([partner.sex intValue] == 1) {
		[self checkboxesChecked:self.checkBoxMale];
	}
	else {
		[self checkboxesChecked:self.checkBoxFemale];
	}
}

//check the validation of the current partner
- (BOOL)checkPartnerDataValidationWithMessage:(BOOL)showMessage {
	NSString *partnerName = self.txtPartnerName.text;

	// COMMENT: cannot create avatar with blank name
	if (partnerName == NULL || [partnerName isEqualToString:@""]) {
		if (showMessage) {
			[self showMessage:LSSTRING(@"Partner name was left blank!") title:kAppName cancelButtonTitle:@"OK"];
			return FALSE;
		}
		else {
			return FALSE;
		}
	}
	else {
		return TRUE;
	}
}

- (void)resignAllTextField {
	[self.txtPartnerName resignFirstResponder];
	[self.txtFirstMeetDate resignFirstResponder];
	[self.txtDateOfBirth resignFirstResponder];
}

#pragma mark - partner function
- (void)deleteCurrentPartner {
	if (![[MASession sharedSession] currentPartner]) {
		// COMMENT: remove all fields to blank if there is no currrent partner selected
		[self resetAllFields];
	}
	else {
		//delele the current partner
		NSString *partnerName = [[[MASession sharedSession] currentPartner].name copy];
		// remove all ero zone if exist.
		NSArray *zones = [AvatarHelper eroZoneFromPlist:@"SpecialZone"];
		BOOL result = [[DatabaseHelper sharedHelper] removeAllPartnereroZone:zones];
		if (result) {
			DLogInfo(@"delete all ero zone.");
		}
		if ([[DatabaseHelper sharedHelper] removePartner:[[MASession sharedSession] currentPartner]]) {
			DLogInfo(@"partnerName: %@", partnerName);
			[self showMessage:[NSString stringWithFormat:@"%@ deleted", partnerName]];
			[self.delegate createPartnerViewControllerDidDeletePartner:self];
			//if delete success, check the remain partner of this user
			NSArray *remainPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];

			//if no partner left
			if (remainPartners.count <= 0) {
				//clear the partner key
				[[MASession sharedSession] setCurrentPartner:nil];

				//reload the field to blank
				[self resetAllFields];

				//reset the process bar
				self.processBar.currentValue = 0;
				self.lblProcessValue.text = @"0%";
//                [self removeDefaultValueMood];
				[Util setValue:[NSNumber numberWithBool:YES] forKey:kMoodDefaultFirstStart];
//                [UserDefault setValue:0 forKey:kValueMoodSelected];
//                NSInteger partnerID = [MASession sharedSession].currentPartner.partnerID.integerValue;
//                NSString *key = [NSString stringWithFormat:@"%@%d",kValueMoodSelected,partnerID];
				[UserDefault setValue:[NSNumber numberWithInt:MA_DEFAULT_MOOD_VALUE] forKey:kValueMoodSelected];
				[UserDefault synchronize];
				[[MAUserProcessManager sharedInstance] resetCheckAlert];
			}
			else {
				//get the last object
				[[MASession sharedSession] setCurrentPartner:[remainPartners lastObject]];

				//call the delegate to make the homepage load the new partner
				if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didUpdateForPartner:)]) {
					[self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
				}

				//when back to the homepage
				[self back];
			}
		}
		else {
			[self showMessage:LSSTRING(@"Could not delete the current partner")];
		}
	}
}

#pragma mark - event handler
//click back button at the top of the date time picker (close the picker and don't do anything)
- (void)backSetting:(id)sender {
	[self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
	[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
}

//click done button at the top of the date time picker
- (void)doneSetting:(id)sender {
	if (!self.datePickerDateOfBirth.hidden) {
		/**
		 *  change to following 401 #2 : other validate rules
		 */
		NSDate *selectedDate = self.datePickerDateOfBirth.date;
        NSDate *dateOfBirth = self.datePickerDateOfBirth.date;
		NSDate *dateOfFirstMeet = [NSDate fromString:self.txtFirstMeetDate.text];

		if ([selectedDate isAfterDate:[NSDate date]]) {
			[self showErrorMessage:@"Way to young, your partner has to be born first."];
			return;
		}
        
        if ([dateOfBirth isLaterThan:dateOfFirstMeet]) {
			[self showErrorMessage:@"Did you really know your partner was coming? You can't meet your partner before they were born."];
			return;
		}
		else {
			self.txtDateOfBirth.text = [selectedDate toString];
		}
	}

	if (!self.datePickerFirstMeet.hidden) {
		/**
		 *  change to following 401 #2 : other validate rules
		 */

		NSDate *dateOfBirth = [NSDate fromString:self.txtDateOfBirth.text];
		NSDate *dateOfFirstMeet = self.datePickerFirstMeet.date;
		if ([dateOfBirth isLaterThan:dateOfFirstMeet]) {
			[self showErrorMessage:@"Did you really know your partner was coming? You can't meet your partner before they were born."];
			return;
		}
		else if ([dateOfFirstMeet isAfterDate:[NSDate date]]) {
			[self showErrorMessage:@"Unless you have a crystal ball, the first met date can't be in the future."];
			return;
		}
		else {
			//set the date string
			self.txtFirstMeetDate.text = [self.datePickerFirstMeet.date toString];
		}
	}
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
    [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];

    [[Util sharedUtil] showLoadingView];
    [GCDispatch performBlockInBackgroundQueue: ^{
        [self autoCreateOrEditPartner];
    } completion: ^{
        [[Util sharedUtil] hideLoadingView];
    }];
    
}

/**
 *  cancel editing Date
 *
 *  @param sender <#sender description#>
 */
- (void)cancelEditing:(id)sender{
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
    if (!self.datePickerDateOfBirth.hidden) {
        [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
    }
    if (!self.datePickerFirstMeet.hidden) {
        [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerFirstMeet pickerState:NO];
    }
}



//picker change
- (void)datePickerDateChanged:(UIDatePicker *)paramDatePicker {
}

- (IBAction)btnBack_touchUpInside:(id)sender {
	[self resignAllTextField];
	if (!_isDuplicateNameMessageVisible) {
		//get the number of avatar for this partner
		NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
		//if this user don't have any avatar, don't let them click back
		if (numberOfAvatar == 0) {
			// this is the case when we go to this page from login view
			[self showMessage:LSSTRING(@"You must create a partner before going to the home screen!")];
		}
		else {
			//if this user have one or more avatars
			// this is the case when we go to this page from home view's setting menu with selection of creating new partner
			if (![[MASession sharedSession] currentPartner]) {
				[self showMessage:@"Do you want to cancel creating a new partner or Save this new partner?" title:kAppName cancelButtonTitle:@"Cancel" otherButtonTitle:@"Save" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG];
			}
			else {
				// this is the case when we go to this page from home view with selection of editing existed partner
				if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didUpdateForPartner:)]) {
					[self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
				}

				[self back];
			}
		}
	}
}

- (IBAction)btnSave_touchUpInside:(id)sender {
    
	if (!_isDuplicateNameMessageVisible) {
		// COMMENT: save partner data (blank name is not allowed)
		if ([[MASession sharedSession] currentPartner] == NULL) {
			if ([Util isNullOrNilObject:self.txtPartnerName.text] || [self.txtPartnerName.text isEqualToString:@""]) {
				[self showMessage:LSSTRING(@"Please create your partner!") title:kAppName cancelButtonTitle:@"OK"];
			}
			else {
				self.btnDeletePartner.enabled = YES;
				[self showMessage:[NSString stringWithFormat:LSSTRING(@"Successfully saved %@."), self.txtPartnerName.text] title:kAppName cancelButtonTitle:@"OK"];
                
               [Util setValue:@"YES" forKey:kIsCreatedPartner];
			}
		}
		else {
			if ([self.txtPartnerName.text isEqualToString:@""]) {
				[self showMessage:LSSTRING(@"Please give your partner a name!") title:kAppName cancelButtonTitle:@"OK"];
          
			}
			else {
				self.btnDeletePartner.enabled = YES;
				[self showMessage:[NSString stringWithFormat:LSSTRING(@"Successfully saved %@."), self.txtPartnerName.text] title:kAppName cancelButtonTitle:@"OK"];
                [Util setValue:@"YES" forKey:kIsCreatedPartner];
				//            [self.view makeToast:[NSString stringWithFormat:LSSTRING(@"Successfully saved %@."),self.txtPartnerName.text]
				//                        duration:3.0
				//                        position:@"center"
				//                           title:kAppName];

				//            [self showMessage:[NSString stringWithFormat:LSSTRING(@"Successfully saved %@."),self.txtPartnerName.text] title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_SAVE_SUCCESS_ALERT_TAG];
			}
		}
	}
}

- (IBAction)btnDeletePartner_touchUpInside:(id)sender {
	[self resignAllTextField];
	if ([MASession sharedSession].currentPartner) {
		self.btnDeletePartner.enabled = YES;
		[self showMessage:[NSString stringWithFormat:LSSTRING(@"Do you want to delete %@?"), [MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:@"Cancel" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_CONFIRM_DELETE_PARTNER];
	}
	else {
		self.btnDeletePartner.enabled = NO;
	}
}

- (IBAction)btnHelp_touchUpInside:(id)sender {
    
    MAAppDelegate *appdelegate = (MAAppDelegate*)[[UIApplication sharedApplication] delegate];
    appdelegate.indexImageShow = 0;
	HelpViewController *vc = NEW_VC(HelpViewController);
	[self nextTo:vc];
}

- (IBAction)btnDateOfBirth_touchUpInside:(id)sender {
	[self.txtPartnerName resignFirstResponder];
	[self.datePickerDateOfBirth setHidden:NO];
	[self.datePickerFirstMeet setHidden:YES];

	[self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
	[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
}

- (IBAction)btnFirstMet_touchUpInside:(id)sender {
	[self.txtPartnerName resignFirstResponder];
	[self.datePickerFirstMeet setHidden:NO];
	[self.datePickerDateOfBirth setHidden:YES];

	[self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
	[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
}

//check boxes checked
- (void)checkboxesChecked:(id)sender {
	if ([sender isEqual:self.checkBoxFemale]) {
		if (self.checkBoxFemale.isChecked) {
			[self.checkBoxMale setCheckWithState:NO];
		}
		else {
			[self.checkBoxMale setCheckWithState:YES];
		}
	}
	else if ([sender isEqual:self.checkBoxMale]) {
		if (self.checkBoxMale.isChecked) {
			[self.checkBoxFemale setCheckWithState:NO];
		}
		else {
			[self.checkBoxFemale setCheckWithState:YES];
		}
	}
	CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
	DLog(@"start :%f", start);
	//autosave
	if ([[MASession sharedSession] currentPartner]) {
		[GCDispatch performBlock: ^{
		    [self autoCreateOrEditPartner];
		} inMainQueueAfterDelay:0.0f];
		CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
		DLog(@"end: in %f", end - start);
	}
}

#pragma mark - text field delegate + keyboard notification
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	//hide the picker first

	//if it is the two date time text field, show the action sheet instead of keyboard
	if ([textField isEqual:self.txtDateOfBirth]) {
		[self.txtPartnerName resignFirstResponder];
		[self.datePickerDateOfBirth setHidden:NO];
		[self.datePickerFirstMeet setHidden:YES];

		[self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
		[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
		[self.btnBackground setSize:self.backgroundScrollView.contentSize];
		return FALSE;
	}
	else if ([textField isEqual:self.txtFirstMeetDate]) {
		[self.txtPartnerName resignFirstResponder];
		[self.datePickerFirstMeet setHidden:NO];
		[self.datePickerDateOfBirth setHidden:YES];

		[self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
		[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
		[self.btnBackground setSize:self.backgroundScrollView.contentSize];
		return FALSE;
	}
	else {
		[self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
		[self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
		[self.btnBackground setSize:self.backgroundScrollView.contentSize];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];

	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [textField resignFirstResponder];
	//edit the partner whenever there is any change
	if ([textField isEqual:self.txtPartnerName]) {
		[self autoCreateOrEditPartner];
	}
}

- (void)keyboardWillShow:(NSNotification *)notification {
	[super keyboardWillShow:notification];

	[self.btnBackground setSize:self.backgroundScrollView.frame.size];
	[self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:NO];
}

- (void)keyboardWillHide {
	[super keyboardWillHide];

	[self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:NO];
	[self.btnBackground setSize:self.backgroundScrollView.frame.size];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//if user selected ok when ask to stop the creation task(click back button), leave the current view
	if (alertView.tag == MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG) {
		if (buttonIndex == 0) {
			//set selected partner by the last used partner
			NSArray *partners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
			[[MASession sharedSession] setCurrentPartner:[partners lastObject]];
			[self.delegate createPartnerViewController:self didChangeToPartner:[MASession sharedSession].currentPartner];
			[self back];
		}
	}
	else if (alertView.tag == MANAPP_CREATE_PARTNER_VIEW_CONFIRM_DELETE_PARTNER) {
		if (buttonIndex == 0) {
			[self deleteCurrentPartner];
		}
	}
	else if (alertView.tag == MANAPP_CREATE_PARTNER_VIEW_DUPLICATE_PARTNER_NAME) {
		_isDuplicateNameMessageVisible = FALSE;
	}
	else if (alertView.tag == MANAPP_CREATE_PARTNER_VIEW_SAVE_SUCCESS_ALERT_TAG) {
		if (buttonIndex == 0) {
			UIViewController *vcHomePage = nil;
			for (UIViewController *vc in self.navigationController.viewControllers) {
				if ([vc isKindOfClass:[HomepageViewController class]]) {
					vcHomePage = vc;
					break;
				}
			}
			if (vcHomePage) {
				// this is the case when we go to this page from home view with selection of editing existed partner
				if (self.delegate && [(NSObject *)self.delegate respondsToSelector : @selector(createPartnerViewController:didUpdateForPartner:)]) {
					[self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
				}

				[self back];
			}
		}
	}
}

- (void)removeDefaultValueMood {
	if ([UserDefault objectForKey:kValueMoodSelected]) {
		[UserDefault removeObjectForKey:kValueMoodSelected];
		[UserDefault synchronize];
	}
}




@end
