//
//  HomepageViewController.m
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "HomepageViewController.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "CreatePartnerViewController.h"
#import "NSArray+MACalendar.h"
#import "UIView+Additions.h"
#import "PartnerMood.h"
#import "MASession.h"
#import "MeasurementViewController.h"
#import "MonthlyCalendarViewController.h"

@interface HomepageViewController ()
-(void) initialize;
-(void) initializeSettingView;
-(void) initializeMoodBar;

-(void) backSetting:(id)sender;
-(void) doneSetting:(id)sender;

-(void) fillViewWithPartnerData:(Partner *) partner;

-(void) moodSliderValueDidEndEditing:(id)sender;
-(void) moodSliderValueChanged:(id)sender;
@end

@implementation HomepageViewController
@synthesize btnSetting = _btnSetting;
@synthesize pickerSetting = _pickerSetting;
@synthesize actionSheetSettingPicker = _actionSheetSettingPicker;
@synthesize settingItems = _settingItems;
@synthesize moodSlider = _moodSlider;
@synthesize btnCalendar = _btnCalendar;
@synthesize btnCurrentPartner = _btnCurrentPartner;
@synthesize btnMeasurement = _btnMeasurement;
@synthesize btnNotePage = _btnNotePage;
@synthesize btnPreference = _btnPreference;
@synthesize btnSpecialZone = _btnSpecialZone;
@synthesize lblMood = _lblMood;
@synthesize delegate;
@synthesize currentUserPartners = _currentUserPartners;

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
    
    //Setting picker
    [self initializeSettingView];
    
    //mood bar
    [self initializeMoodBar];
    
    // if the user don't have any partner yet, redirect them to the create partner page
    NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
    if (numberOfAvatar == 0) {
        [[MASession sharedSession] setCurrentPartner:nil];
        [self gotoCreatePartnerPage];
    }
    else{
        //if there is no partner, automatically pick one partner
        if([[MASession sharedSession] currentPartner] == NULL){
            self.currentUserPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
            [[MASession sharedSession] setCurrentPartner:[self.currentUserPartners lastObject]];
        }
    }
    
    //load user data to view
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    //hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [_btnSetting release];
    [_pickerSetting release];
    [_actionSheetSettingPicker release];
    [_settingItems release];
    [_btnCurrentPartner release];
    [_btnCalendar release];
    [_btnPreference release];
    [_btnMeasurement release];
    [_btnSpecialZone release];
    [_btnNotePage release];
    [_lblMood release];
    [_moodSlider release];
    [_currentUserPartners release];
    [super dealloc];
}

#pragma mark - private functions
//prepare the UI
-(void) initialize{
}

//UI for the mood bar
-(void) initializeMoodBar{
    if(!self.moodSlider){
        // Init slider
        self.moodSlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 370, 10)];
        CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI_2);
        self.moodSlider.transform = trans;
        [self.moodSlider addTarget:self action:@selector(moodSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.moodSlider addTarget:self action:@selector(moodSliderValueDidEndEditing:) forControlEvents:UIControlEventTouchUpInside];
        [self.moodSlider setOriginX:5];
        [self.moodSlider setOriginY:20];
        [self.moodSlider setThumbImage:[UIImage imageNamed:@"indicator"] forState:UIControlStateNormal];
        UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.moodSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [self.moodSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
        
        [self.view addSubview:self.moodSlider];
    }
}

//UI for the setting picker
-(void) initializeSettingView{
    //setting list data
    
    //init the settingItems list if it isn't existed
    if (!self.settingItems) {
        self.settingItems = [[NSMutableArray alloc] init];
    }
    [self.settingItems removeAllObjects];
    
    // add data to setting picker
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR];
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD];
    NSArray* partnerList = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
    for(int i=0; i<[partnerList count]; i++)
    {
        Partner* partner = [partnerList objectAtIndex:i];
        [self.settingItems addObject:[NSString stringWithFormat:MANAPP_SETTING_MENU_ITEM_PARTNER,partner.name]];
    }
    self.currentUserPartners = partnerList;
    if (self.currentUserPartners.count > 0) {
        [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_DELETE_CURRENT_PARTNER];
    }
    [self.settingItems addObject:MANAPP_SETTING_MENU_ITEM_LOGOUT];
    [self.pickerSetting reloadAllComponents];

    //setting UI
    // COMMENT: actionset for setting picker
    if(!self.actionSheetSettingPicker){
        self.actionSheetSettingPicker = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
        
        [self.actionSheetSettingPicker setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        // COMMENT: generate setting picker
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        self.pickerSetting = [[UIPickerView alloc] initWithFrame:pickerFrame];
        self.pickerSetting.showsSelectionIndicator = YES;
        self.pickerSetting.dataSource = self;
        self.pickerSetting.delegate = self;
        [self.actionSheetSettingPicker addSubview:self.pickerSetting];
        
        // COMMENT: add toolbar with done button to the picker (with two button at the bar)
        UIToolbar * pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
        pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[[NSMutableArray alloc] init] autorelease];
        UIBarButtonItem *backBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backSetting:)] autorelease];
        [barItems addObject:backBtn];
        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSetting:)] autorelease];
        [barItems addObject:doneBtn];
        [pickerToolbar setItems:barItems animated:YES];
        [self.actionSheetSettingPicker addSubview:pickerToolbar];
    }
}

//go to create partner page
- (void)gotoCreatePartnerPage
{
    CreatePartnerViewController* createPartnerViewController = [self getViewControllerByName:@"CreatePartnerViewController"];
    createPartnerViewController.delegate = self;
    [self.navigationController pushViewController:createPartnerViewController animated:YES];
}

//fill view with partner data
-(void) fillViewWithPartnerData:(Partner *) partner{
    //if there is a partner, fill its data to view, if not, reset all the view
    if(partner){
        //current user button
        [self.btnCurrentPartner setTitle:partner.name forState:UIControlStateNormal];
        [self.btnCurrentPartner setTitle:partner.name forState:UIControlStateHighlighted];
        
        //mood bar
        PartnerMood *partnerMood = [[DatabaseHelper sharedHelper] partnerMoodWithPartnerId:[partner.partnerID intValue] date:[NSDate date]];
        self.moodSlider.value = (CGFloat)(100 - [partnerMood.moodValue intValue])/100;
        self.lblMood.text = [NSString stringWithFormat:@"%.0f%@", 100 - self.moodSlider.value * 100, @"%"];
    }
    else{
        //current user button
        [self.btnCurrentPartner setTitle:@"" forState:UIControlStateNormal];
        [self.btnCurrentPartner setTitle:@"" forState:UIControlStateHighlighted];
        
        //mood bar
        self.moodSlider.value = 0;
        self.lblMood.text = [NSString stringWithFormat:@"%.0f%@", 0.0f, @"%"];
    }
}

#pragma mark - event handler
//click the setting button will show the setting scroll view
- (IBAction)btnSetting_touchUpInside:(id)sender {
    [self.actionSheetSettingPicker showInView:[[UIApplication sharedApplication] keyWindow]];
    
    [self.actionSheetSettingPicker setBounds:CGRectMake(0, 0, 320, 485)];
    [self.pickerSetting reloadComponent:0];
}

- (IBAction)btnCurrentPartner_touchUpInside:(id)sender {
    [self gotoCreatePartnerPage];
}

- (IBAction)btnCalendar_touchUpInside:(id)sender {
    [self pushViewControllerByName:@"MonthlyCalendarViewController"];
}

- (IBAction)btnPreference_touchUpInside:(id)sender {
    if(![[MASession sharedSession] currentPartner])
    {
        [self showErrorMessage:@"Please select a partner first!"];
    }
    else{
        [self pushViewControllerByName:@"PreferenceViewController"];
    }
}

- (IBAction)btnMeasurement_touchUpInside:(id)sender {
    // COMMENT: go to measurement view (alert show up if not partner was selected)
    if(![[MASession sharedSession] currentPartner])
    {
        [self showErrorMessage:@"Please select a partner first!"];
    }
    else{
        [self pushViewControllerByName:@"MeasurementViewController"];
    }
}

- (IBAction)btnSpecialZone_touchUpInside:(id)sender {
}

- (IBAction)btnNotePage_touchUpInside:(id)sender {
}

//click the back button on top of the setting picker
-(void) backSetting:(id)sender{
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
}

//click the done button on the setting picker view to select the current item
-(void) doneSetting:(id)sender{
    _selectedSettingItem = [self.settingItems objectAtIndex:[self.pickerSetting selectedRowInComponent:0]];
    if([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_CREATE_AVATAR])
    {
        //check to see if this account have more than the avatars allowed or not, if true, denied access to this function
        NSInteger numberOfAvatar = [[DatabaseHelper sharedHelper] getNumberOfPartnerOfUser:[[MASession sharedSession] userID]];
        if(numberOfAvatar < MANAPP_MAXIMUM_NUMBER_OF_AVATAR){
            [[MASession sharedSession] setCurrentPartner:nil];
            [self gotoCreatePartnerPage];
        }
        else{
            [self showMessage:[NSString stringWithFormat:@"Partner limit (%d) reached.",MANAPP_MAXIMUM_NUMBER_OF_AVATAR] title:@"MANAPP" cancelButtonTitle:@"OK"];
        }
    }
    else if([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_CHANGE_PASSWORD])
    {
        return;
    }
    else if ([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_DELETE_CURRENT_PARTNER]) {
        [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];

        if ([[DatabaseHelper sharedHelper] removePartner:[[MASession sharedSession] currentPartner]]) {
            [self showMessage:@"Partner deleted"];
            
            [[MASession sharedSession] setCurrentPartner:nil];
            
            //reload the partner list
            self.currentUserPartners = [[DatabaseHelper sharedHelper] getAllPartnerForUserId:[[MASession sharedSession] userID]];
        } else {
            [self showMessage:@"Could not delete current partner"];
        }
        
        //if there isn't any partner left
        if (self.currentUserPartners.count <= 0) {
            [self.btnCurrentPartner setTitle:@"Create new partner" forState:UIControlStateNormal];
        }
        //if not, pick lastest partner
        else {
            [[MASession sharedSession] setCurrentPartner:[self.currentUserPartners firstObject]];
            [self.btnCurrentPartner setTitle:[[MASession sharedSession] currentPartner].name forState:UIControlStateNormal];
        }
        
        // Reload view with changes
        [self initializeSettingView];
        return;
    }
    else if ([_selectedSettingItem isEqualToString:MANAPP_SETTING_MENU_ITEM_LOGOUT]) {
        if ([self.delegate respondsToSelector:@selector(userDidLogout:)]) {
            [self.delegate userDidLogout:self];
        }
        [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    else
    {
        // COMMENT: first we have to get the username from the item string (remove "Profile" text)
        NSString* selectedPartnerName = [[_selectedSettingItem componentsSeparatedByString:@":"] lastObject];
        selectedPartnerName = [selectedPartnerName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        // COMMENT: get partner id from name and save to the globar variable
        Partner* selectedPartner = [[DatabaseHelper sharedHelper] getPartnerByName:selectedPartnerName];
        
        [[MASession sharedSession] setCurrentPartner:selectedPartner];
        [self gotoCreatePartnerPage];
    }
    [self.actionSheetSettingPicker dismissWithClickedButtonIndex:0 animated:YES];

}

// mood bar stop after get changed
- (void) moodSliderValueDidEndEditing:(id)sender{
    if([[MASession sharedSession] currentPartner])
    {
        NSNumber *moodValue = [NSNumber numberWithFloat:100 - self.moodSlider.value * 100];
        [[DatabaseHelper sharedHelper] addMoodValue:moodValue forPartnerWithId:[[[MASession sharedSession] currentPartner].partnerID intValue] date:[NSDate date]];
    }
}

// mood bar being changed
- (void) moodSliderValueChanged:(id)sender
{
    self.lblMood.text = [NSString stringWithFormat:@"%.0f%@", 100 - self.moodSlider.value * 100, @"%"];
}

#pragma mark - setting picker view datasource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.settingItems count];
}

#pragma mark - setting picker view delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.settingItems objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _selectedSettingItem = [self.settingItems objectAtIndex:row];
}

#pragma mark - create partner view delegate
-(void)createPartnerViewController:(CreatePartnerViewController *)view didUpdateForPartner:(NSInteger)partnerId{
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

-(void)createPartnerViewController:(CreatePartnerViewController *)view didAddPartner:(NSInteger)partnerId{
    //reload the setting picker
    [self initializeSettingView];
    [self.pickerSetting reloadAllComponents];
    
    //fill the view with new user
    [self fillViewWithPartnerData:[[MASession sharedSession] currentPartner]];
}

-(void)createPartnerViewControllerDidDeletePartner:(CreatePartnerViewController *)view{
    //reload the setting picker
    [self initializeSettingView];
    [self.pickerSetting reloadAllComponents];
}

@end
