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
#import "Partner.h"
#import "DatabaseHelper.h"
#import "MACheckBoxButton.h"
#import "MAUserProcessManager.h"
#import "UICustomProgressBar.h"
#import "AdditionalInformationViewController.h"
#import "MeasurementViewController.h"
#import "PreferenceViewController.h"
#import "MASession.h"

@interface CreatePartnerViewController ()
-(void) initialize;
-(void) initializeDatePickers;
-(void) initializeCheckBoxs;
-(void) initializeProcessBar;

-(void) resignAllTextfields;

-(void) autoCreateOrEditPartner;

-(void) backSetting:(id)sender;
-(void) doneSetting:(id)sender;
-(void) datePickerDateChanged:(UIDatePicker *)paramDatePicker;
-(void) checkboxesChecked:(id)sender;

-(void) resetAllFields;
-(void) setFieldsByPartnerData:(Partner *)partner;

-(BOOL) checkPartnerDataValidationWithMessage:(BOOL) showMessage;
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
@synthesize lblCalendarType = _lblCalendarType;
@synthesize lblUSCalendar = _lblUSCalendar;
@synthesize lblInternationalCalendar = _lblInternationalCalendar;
@synthesize lblMale = _lblMale;
@synthesize datePickerView = _datePickerView;
@synthesize lblFemale = _lblFemale;
@synthesize checkBoxFemale = _checkBoxFemale;
@synthesize checkBoxIntCalendar = _checkBoxIntCalendar;
@synthesize checkBoxMale = _checkBoxMale;
@synthesize checkBoxUSCalendar = _checkBoxUSCalendar;
@synthesize btnBack = _btnBack;
@synthesize viewProcessBar = _viewProcessBar;
@synthesize lblProcessBar = _lblProcessBar;
@synthesize processBar = _processBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //prepare the UI
    [self initialize];
    
    //date picker
    [self initializeDatePickers];
    
    //check box
    [self initializeCheckBoxs];
    
    //process bar
    [self initializeProcessBar];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    
    //incase there is any update, reload the process bar value
    [self initializeProcessBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    [_lblCalendarType release];
    [_lblUSCalendar release];
    [_lblInternationalCalendar release];
    [_lblMale release];
    [_lblFemale release];
    [_datePickerView release];
    [_checkBoxUSCalendar release];
    [_checkBoxIntCalendar release];
    [_checkBoxFemale release];
    [_checkBoxMale release];
    [_btnBack release];
    [_btnSave release];
    [_btnDeletePartner release];
    [_viewProcessBar release];
    [_lblProcessBar release];
    [_processBar release];
    [_btnCreateAvatar release];
    [_btnPreference release];
    [_btnMeasurement release];
    [_btnAdditionalInformation release];
    [super dealloc];
}

#pragma mark - private functions
//prepare the UI
-(void) initialize{
    //change textfield and label UI
    [self.txtPartnerName paddingLeftByValue:15];
    [self.txtFirstMeetDate paddingLeftByValue:5];
    [self.txtDateOfBirth paddingLeftByValue:5];
    
    [self.txtPartnerName setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtFirstMeetDate setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.txtDateOfBirth setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    
    [self.lblCreatePartnerTitle setFont:[UIFont fontWithName:@"BankGothic Md BT" size:18]];
    [self.lblAdvice setFont:[UIFont fontWithName:@"BankGothic Md BT" size:9]];
    [self.lblPartnerName setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblDateOfBirth setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblCalendarType setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblUSCalendar setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblInternationalCalendar setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblFemale setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblMale setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    [self.lblFirstMeetDate setFont:[UIFont fontWithName:@"BankGothic Md BT" size:13]];
    
    if([[MASession sharedSession] currentPartner]){
        //partner name
        self.txtPartnerName.text = [[MASession sharedSession] currentPartner].name;

        // date of birth's field
        self.txtDateOfBirth.text = ([[MASession sharedSession] currentPartner].dateOfBirth)?[NSDate stringFromDate:[[MASession sharedSession] currentPartner].dateOfBirth withFormat:@"yyyy/MM/dd"]:@"/     /";
        
        //first meet date's field        
        self.txtFirstMeetDate.text = ([[MASession sharedSession] currentPartner].firstDate)?[NSDate stringFromDate:[[MASession sharedSession] currentPartner].firstDate withFormat:@"yyyy/MM/dd"]:@"/     /";
        
        //change the button image to match the current state
        [self.btnCreateAvatar setBackgroundImage:[UIImage imageNamed:@"btnEditAvatar"] forState:UIControlStateNormal];
        
        [self.btnAdditionalInformation setBackgroundImage:[UIImage imageNamed:@"btnEditAdditionalInformation"] forState:UIControlStateNormal];
        
        [self.btnMeasurement setBackgroundImage:[UIImage imageNamed:@"btnEditMeasurements"] forState:UIControlStateNormal];
        
        [self.btnPreference setBackgroundImage:[UIImage imageNamed:@"btnEditLikeAndDislike"] forState:UIControlStateNormal];
    }
    
}

//init the date picker
-(void) initializeDatePickers{
    int datePickerViewHeight = 256;
    if(!self.datePickerView){
        //create the background view for picker
        self.datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - datePickerViewHeight, self.view.frame.size.width, datePickerViewHeight)];
        self.datePickerView.hidden = TRUE;
        self.datePickerView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:self.datePickerView];
        [self.view bringSubviewToFront:self.datePickerView];
        
        //generate the date pickers
        //date of birth picker
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        self.datePickerDateOfBirth = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.datePickerDateOfBirth.hidden = TRUE;
        self.datePickerDateOfBirth.datePickerMode = UIDatePickerModeDate;
        [self.datePickerDateOfBirth addTarget:self
                          action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.datePickerView addSubview:self.datePickerDateOfBirth];
        
        //first meet date picker (make sure this picker cannot select the date time which is less than DOB
        self.datePickerFirstMeet = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        self.datePickerFirstMeet.hidden = TRUE;
        self.datePickerFirstMeet.datePickerMode = UIDatePickerModeDate;
        [self.datePickerFirstMeet addTarget:self
                                       action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
        [self.datePickerView addSubview:self.datePickerFirstMeet];
        
        NSDate *currentDate = [NSDate date];
        [self.datePickerDateOfBirth setMaximumDate:currentDate];
        [self.datePickerFirstMeet setMaximumDate:currentDate];
        
        // COMMENT: add toolbar with done button to the picker (with two button at the bar)
        UIToolbar * pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetting:)] autorelease];
        [barItems addObject:doneBtn];
        [pickerToolbar setItems:barItems animated:YES];
        [self.datePickerView addSubview:pickerToolbar];
    }

    //set the date time picker incase the selected user is existed
    if([[MASession sharedSession] currentPartner]){
        if([[MASession sharedSession] currentPartner].dateOfBirth){
            [self.datePickerDateOfBirth setDate:[[MASession sharedSession] currentPartner].dateOfBirth animated:YES];
        }
        
        if([[MASession sharedSession] currentPartner].firstDate){
            [self.datePickerFirstMeet setDate:[[MASession sharedSession] currentPartner].firstDate animated:YES];
        }
    }
}

-(void)initializeCheckBoxs{
    if(!self.checkBoxUSCalendar){
        self.checkBoxUSCalendar = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(166, 277, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
        [self.checkBoxUSCalendar addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
        self.checkBoxUSCalendar.isAllowToggle = NO;
        [self.backgroundScrollView addSubview:self.checkBoxUSCalendar];
    }
    
    if(!self.checkBoxIntCalendar){
        self.checkBoxIntCalendar = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(241, 277, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
        [self.checkBoxIntCalendar addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
        self.checkBoxIntCalendar.isAllowToggle = NO;
        [self.backgroundScrollView addSubview:self.checkBoxIntCalendar];
    }
    
    if(!self.checkBoxMale){
        self.checkBoxMale = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(241, 311, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
        [self.checkBoxMale addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
        self.checkBoxMale.isAllowToggle = NO;
        [self.backgroundScrollView addSubview:self.checkBoxMale];
    }
    
    if(!self.checkBoxFemale){
        self.checkBoxFemale = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(166, 311, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
        [self.checkBoxFemale addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
        self.checkBoxFemale.isAllowToggle = NO;
        [self.backgroundScrollView addSubview:self.checkBoxFemale];
    }
    
    //if the partner existed, check the correct checkbox
    if([[MASession sharedSession] currentPartner]){
        if([[[MASession sharedSession] currentPartner].sex intValue] == 1){
            [self.checkBoxMale setCheckWithState:YES];
        }
        else{
            [self.checkBoxFemale setCheckWithState:YES];
        }
        
        if([[[MASession sharedSession] currentPartner].calendarType intValue] == 1){
            [self.checkBoxUSCalendar setCheckWithState:YES];
        }
        else{
            [self.checkBoxIntCalendar setCheckWithState:YES];
        }
    }
    else{
        [self.checkBoxFemale setCheckWithState:YES];
        [self.checkBoxUSCalendar setCheckWithState:YES];
    }
}

-(void) initializeProcessBar{
    
    // COMMENT: generate progress bar and set its value
    if(!self.processBar){
        self.processBar = [[UICustomProgressBar alloc] initWithBackgroundImage:[UIImage imageNamed:@"progressbar-bg"]  progressImage:[UIImage imageNamed:@"progressbar"] progressMask:[UIImage imageNamed:@"progressbar-mask"] insets:CGSizeMake(3, 2)];
        
        [self.viewProcessBar addSubview:self.processBar];
        self.processBar.center = CGPointMake(135, 12);
        self.processBar.maxValue = 100.0f;
    }
    
    // if the current partner is existed, get his process value. If not, set the process bar by 0
    if([[MASession sharedSession] currentPartner]){
        self.processBar.currentValue = (NSInteger)[[MAUserProcessManager sharedInstance] getAppProcessForPartner:[[MASession sharedSession] currentPartner]];
    }
    else{
        self.processBar.currentValue = 0;
    }
    
    //change the label value
    self.lblProcessBar.text = [NSString stringWithFormat:@"%d%%",(NSInteger)self.processBar.currentValue];
}

#pragma mark - private function
//when there is any change, automatically update (or create if need) avatar information
-(void) autoCreateOrEditPartner{
    //only call this function if the username field was filled
    if(!(self.txtPartnerName.text == NULL) && ![self.txtPartnerName.text isEqualToString:@""]){
        
        //check if partner is existed or not, if not then create new one before edit.
        if([[MASession sharedSession] currentPartner] == NULL){
            if([[MASession sharedSession] currentPartner]){
                //COMMENT: edit avatar
                BOOL editResult = [[DatabaseHelper sharedHelper] editParnerWithId:[[[MASession sharedSession] currentPartner].partnerID intValue] name:[self.txtPartnerName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] dOB:[NSDate dateFromString:self.txtDateOfBirth.text withFormat:@"yyyy/MM/dd"] calendarType:self.checkBoxUSCalendar.isChecked sex:self.checkBoxMale.isChecked firstMeet:[NSDate dateFromString:self.txtFirstMeetDate.text withFormat:@"yyyy/MM/dd"]];
                if(editResult){
                    [self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
                    DLog(@"Automatic edit successfully");
                }
                else
                    DLog(@"Automatic edit failed");
            }
            else{
                // the avatar isn't existed, create the new one
                BOOL addResult = [[DatabaseHelper sharedHelper] createParnerWithName:[self.txtPartnerName.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] dOB:[NSDate dateFromString:self.txtDateOfBirth.text withFormat:@"yyyy/MM/dd"] calendarType:self.checkBoxUSCalendar.isChecked sex:self.checkBoxMale.isChecked firstMeet:[NSDate dateFromString:self.txtFirstMeetDate.text withFormat:@"yyyy/MM/dd"] forUserId:[[MASession sharedSession] userID]];
                //create success
                if(addResult){
                    DLog(@"Automatic add successfully");
                    
                    //get the newest partner
                    Partner* newPartner = [[DatabaseHelper sharedHelper] getPartnerByName:self.txtPartnerName.text];
                    [[MASession sharedSession] setCurrentPartner:newPartner];
                    
                    //inform the homepage that we just add new partner
                    [self.delegate createPartnerViewController:self didAddPartner:[newPartner.partnerID intValue]];
                    
                    //update the homepage with new user
                    [self.delegate createPartnerViewController:self didUpdateForPartner:[newPartner.partnerID intValue]];
                    
                    //change the progress bar
                    [[MAUserProcessManager sharedInstance] setProcessForPartner:[[MASession sharedSession] currentPartner] afterStep:MANAPP_PARTNER_MANAGER_PROCESS_STEP_CREATION withProcessBar:self.processBar];
                    self.lblProcessBar.text = [NSString stringWithFormat:@"%d%%",(NSInteger)[[MAUserProcessManager sharedInstance] getAppProcessForPartner:[[MASession sharedSession] currentPartner]]];
                }
                else
                    DLog(@"Automatic add failed");
            }
        }
        else{
            // edit to the current partner
            if([[[MASession sharedSession] currentPartner] isKindOfClass:[Partner class]] && [[MASession sharedSession] currentPartner] != nil){
                BOOL editResult = [[DatabaseHelper sharedHelper] editParnerWithId:[[[MASession sharedSession] currentPartner].partnerID intValue] name:self.txtPartnerName.text dOB:[NSDate dateFromString:self.txtDateOfBirth.text withFormat:@"yyyy/MM/dd"] calendarType:self.checkBoxUSCalendar.isChecked sex:self.checkBoxMale.isChecked firstMeet:[NSDate dateFromString:self.txtFirstMeetDate.text withFormat:@"yyyy/MM/dd"]];
                
                //report back to home page
                if(editResult){
                    [[MASession sharedSession] setCurrentPartner:[[DatabaseHelper sharedHelper] getPartnerById:[[[MASession sharedSession] currentPartner].partnerID intValue]]];
                    [self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
                    DLog(@"Automatic edit successfully");
                }
                else
                    DLog(@"Automatic edit failed");
                }
        }
    }
}

//clear the fields
-(void) resetAllFields{
    self.txtPartnerName.text = @"";
    self.txtDateOfBirth.text = @"/     /";
    self.txtFirstMeetDate.text = @"/     /";
}

-(void) setFieldsByPartnerData:(Partner *)partner{
    //partner name
    self.txtPartnerName.text = partner.name;
    
    // date of birth's field
    self.txtDateOfBirth.text = (partner.dateOfBirth)?[NSDate stringFromDate:partner.dateOfBirth withFormat:@"yyyy/MM/dd"]:@"/     /";
    
    //first meet date's field
    self.txtFirstMeetDate.text = (partner.firstDate)?[NSDate stringFromDate:partner.firstDate withFormat:@"yyyy/MM/dd"]:@"/     /";
    
    //date time
    if(partner.dateOfBirth){
        [self.datePickerDateOfBirth setDate:partner.dateOfBirth animated:YES];
    }
    
    if(partner.firstDate){
        [self.datePickerFirstMeet setDate:partner.firstDate animated:YES];
    }
    
    //checkboxs
    if([partner.sex intValue] == 1){
        [self checkboxesChecked:self.checkBoxMale];
    }
    else{
        [self checkboxesChecked:self.checkBoxFemale];
    }
    
    if([partner.calendarType intValue] == 1){
        [self checkboxesChecked:self.checkBoxUSCalendar];
    }
    else{
        [self checkboxesChecked:self.checkBoxIntCalendar];
    }
}

//check the validation of the current partner
-(BOOL) checkPartnerDataValidationWithMessage:(BOOL)showMessage{
    NSString* partnerName = self.txtPartnerName.text;
    
    // COMMENT: cannot create avatar with blank name
    if(partnerName == NULL || [partnerName isEqualToString:@""]){
        if(showMessage){
            [self showMessage:@"Partner name was left blank!" title:@"MANAPP" cancelButtonTitle:@"OK"];
            return FALSE;
        }
        else{
            return FALSE;
        }
    }
    else{
        return TRUE;
    }
}

-(void) resignAllTextfields{
    [self.txtPartnerName resignFirstResponder];
    [self.txtFirstMeetDate resignFirstResponder];
    [self.txtDateOfBirth resignFirstResponder];
}

#pragma mark - event handler
//click back button at the top of the date time picker (close the picker and don't do anything)
-(void) backSetting:(id)sender{
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
    [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
}

//click done button at the top of the date time picker
-(void) doneSetting:(id)sender{
    if(!self.datePickerDateOfBirth.hidden){
        self.txtDateOfBirth.text = [NSDate stringFromDate:self.datePickerDateOfBirth.date withFormat:@"yyyy/MM/dd"];
    }
    
    if(!self.datePickerFirstMeet.hidden){
        self.txtFirstMeetDate.text = [NSDate stringFromDate:self.datePickerFirstMeet.date withFormat:@"yyyy/MM/dd"];
    }
    
    //auto save
    [self autoCreateOrEditPartner];
    
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
    [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
}

//picker change
-(void) datePickerDateChanged:(UIDatePicker *)paramDatePicker{
    // conditions for Date of Birth
    //get the firstmeetdate and set the maximum of the date of birth to this day
    NSDate *firstMeetDate = [NSDate dateFromString:self.txtFirstMeetDate.text withFormat:@"yyyy/MM/dd"];

    //if the firstmeeddate was selected, then substract it by one. if not, substract the current day
    if (firstMeetDate != nil){
        [self.datePickerDateOfBirth setMaximumDate:[firstMeetDate dateByAddDays:-1]];
    } else {
        [self.datePickerDateOfBirth setMaximumDate:[[NSDate date] dateByAddDays:-1]];
    }
    
    // conditions for First Meet Date
    //the first meet date minimum always later than the DOB
    NSDate *dateOfBirth = [NSDate dateFromString:self.txtDateOfBirth.text withFormat:@"yyyy/MM/dd"];
    if (dateOfBirth != nil){
        dateOfBirth = [dateOfBirth dateByAddDays:1];
    }
    [self.datePickerFirstMeet setMinimumDate:dateOfBirth];
    [self.datePickerFirstMeet setMaximumDate:[NSDate date]];
    
    if ([paramDatePicker isEqual:self.datePickerDateOfBirth]){
        NSString *dateStr = [NSString stringWithFormat:@"%@", [paramDatePicker.date stringWithFormat:@"yyyy/MM/dd"]];
        self.txtDateOfBirth.text = dateStr;
        [self autoCreateOrEditPartner];
    }
    else if ([paramDatePicker isEqual:self.datePickerFirstMeet]){
        [self.datePickerDateOfBirth setMaximumDate:[paramDatePicker.date dateByAddDays:-1]];
        NSString *dateStr = [NSString stringWithFormat:@"%@",[paramDatePicker.date stringWithFormat:@"yyyy/MM/dd"]];
        self.txtFirstMeetDate.text = dateStr;
        [self autoCreateOrEditPartner];
    }
}

// touch the background
- (IBAction)backgroundView_touchUpInside:(id)sender {
    [self.txtPartnerName resignFirstResponder];
    
    [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
}

- (IBAction)btnBack_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    //get the number of avatar for this partner
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    
    //if this user don't have any avatar, don't let them click back
    if (numberOfAvatar == 0) {
        // this is the case when we go to this page from login view
        [self showMessage:@"Please create a partner before go to homescreen!"];
    }
    else{
        //if this user have one or more avatars
        // this is the case when we go to this page from home view's setting menu with selection of creating new partner
        if(![[MASession sharedSession] currentPartner]){
            [self showMessage:@"Do you want to cancel creating a new partner or Save this new partner?" title:@"MANAPP" cancelButtonTitle:@"Cancel and Leave" otherButtonTitle:@"Save Partner" delegate:self tag:MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG];
        }
        else{
            // this is the case when we go to this page from home view with selection of editing existed partner
            [self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

- (IBAction)btnSave_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    // COMMENT: save partner data (blank name is not allowed)
    if([[MASession sharedSession] currentPartner] == NULL || [self.txtPartnerName.text isEqualToString:@""])
    {
        [self showMessage:@"Please give your partner a name!" title:@"MANAPP" cancelButtonTitle:@"OK"];
    }
    else
    {
        [self showMessage:@"Save successfully!" title:@"MANAPP" cancelButtonTitle:@"OK"];
    }
}

- (IBAction)btnDeletePartner_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    if(![[MASession sharedSession] currentPartner]){
        // COMMENT: remove all fields to blank if there is no currrent partner selected
        [self resetAllFields];
    }
    else{
        //delele the current partner
        if ([[DatabaseHelper sharedHelper] removePartner:[[MASession sharedSession] currentPartner]]) {
            [self showMessage:@"Partner deleted"];
            [self.delegate createPartnerViewControllerDidDeletePartner:self];
            
            //if delete success, check the remain partner of this user
            NSArray *remainPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
            
            //if no partner left
            if(remainPartners.count <= 0){
                //clear the partner key
                [[MASession sharedSession] setCurrentPartner:nil];
                
                //reload the field to blank
                [self resetAllFields];
                
                //reset the process bar
                self.processBar.currentValue = 0;
                self.lblProcessValue.text = @"0%";
            }
            else{
                //get the last object
                [[MASession sharedSession] setCurrentPartner:[remainPartners lastObject]];
                
                //call the delegate to make the homepage load the new partner
                [self.delegate createPartnerViewController:self didUpdateForPartner:[[[MASession sharedSession] currentPartner].partnerID intValue]];
                
                //when back to the homepage
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self showMessage:@"Could not delete the current partner"];
        }
    }
}

- (IBAction)btnCreateAvatar_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    //only allow to go the create avatar after we have one partner
    if([self checkPartnerDataValidationWithMessage:YES]){
        
    }
}

- (IBAction)btnPreference_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    if(![[MASession sharedSession] currentPartner] || [self.txtPartnerName.text isEqualToString:@""])
    {
        [self showErrorMessage:@"Please give your partner a name!"];
    }
    else{
        [self pushViewControllerByName:@"PreferenceViewController"];
    }
}

- (IBAction)btnMeasurement_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    // COMMENT: go to measurement view (alert show up if not partner was selected)
    if(![[MASession sharedSession] currentPartner] || [self.txtPartnerName.text isEqualToString:@""])
    {
        [self showErrorMessage:@"Please give your partner a name!"];
    }
    else{
        [self pushViewControllerByName:@"MeasurementViewController"];
    }
}

- (IBAction)btnAdditionalInformation_touchUpInside:(id)sender {
    [self resignAllTextfields];
    
    // COMMENT: go to addition view (alert show up if not partner was selected)
    if(![[MASession sharedSession] currentPartner] || [self.txtPartnerName.text isEqualToString:@""])
    {
        [self showErrorMessage:@"Please give your partner a name!"];
    }
    else{
        [self pushViewControllerByName:@"AdditionalInformationViewController"];
    }
}

//check boxes checked
-(void) checkboxesChecked:(id)sender{
    if([sender isEqual:self.checkBoxFemale]){
        if(self.checkBoxFemale.isChecked){
            [self.checkBoxMale setCheckWithState:NO];
        }
        else{
            [self.checkBoxMale setCheckWithState:YES];
        }
    }
    else if([sender isEqual:self.checkBoxMale]){
        if(self.checkBoxMale.isChecked){
            [self.checkBoxFemale setCheckWithState:NO];
        }
        else{
            [self.checkBoxFemale setCheckWithState:YES];
        }
    }
    else if([sender isEqual:self.checkBoxIntCalendar]){
        if(self.checkBoxIntCalendar.isChecked){
            [self.checkBoxUSCalendar setCheckWithState:NO];
        }
        else{
            [self.checkBoxUSCalendar setCheckWithState:YES];
        }
    }
    else if([sender isEqual:self.checkBoxUSCalendar]){
        if(self.checkBoxUSCalendar.isChecked){
            [self.checkBoxIntCalendar setCheckWithState:NO];
        }
        else{
            [self.checkBoxIntCalendar setCheckWithState:YES];
        }
    }
    
    //autosave
    if([[MASession sharedSession] currentPartner]){
        [self autoCreateOrEditPartner];
    }
}

#pragma mark - text field delegate + keyboard notification
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //hide the picker first
    [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:NO];
    [self hideModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
    
    //if it is the two date time text field, show the action sheet instead of keyboard
    if([textField isEqual:self.txtDateOfBirth]){
        [self.txtPartnerName resignFirstResponder];
        [self.datePickerDateOfBirth setHidden:NO];
        [self.datePickerFirstMeet setHidden:YES];
        
        [self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
        [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
        return FALSE;
    }
    else if([textField isEqual:self.txtFirstMeetDate]){
        [self.txtPartnerName resignFirstResponder];
        [self.datePickerFirstMeet setHidden:NO];
        [self.datePickerDateOfBirth setHidden:YES];
        
        [self showModalView:self.datePickerView direction:MAModalViewDirectionBottom autoAddSubView:NO];
        [self resizeScrollView:self.backgroundScrollView withDatePicker:self.datePickerDateOfBirth pickerState:YES];
        return FALSE;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //edit the partner whenever there is any change
    if([textField isEqual:self.txtPartnerName]){
        [self autoCreateOrEditPartner];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //edit the partner whenever there is any change
    if([textField isEqual:self.txtPartnerName]){
        [self autoCreateOrEditPartner];
    }
}

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:TRUE willChangeOffset:NO];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    
    [self resizeScrollView:self.backgroundScrollView withKeyboardState:FALSE willChangeOffset:NO];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //if user selected ok when ask to stop the creation task(click back button), leave the current view
    if(alertView.tag == MANAPP_CREATE_PARTNER_VIEW_LEAVE_CREATE_NEW_ALERT_TAG){
        if(buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
@end
