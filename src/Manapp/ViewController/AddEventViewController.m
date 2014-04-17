//
//  AddEventViewController.m
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Additions.h"
#import "PPEditableTableViewCell.h"
#import "MADeviceUtil.h"
#import "NSDate+Helper.h"
#import "MANotificationManager.h"
#import "MASession.h"
#import "UIButton+Additions.h"
#import "EventUtil.h"

@interface AddEventViewController ()
- (void) loadUI;
- (void) initializeData;

- (void) fillViewWithEventData:(Event *) event;

- (NSString *) getTitleString;
- (PPEditableTableViewCell *) getTitleCell;

-(void) resignAllTextFields;
@end

@implementation AddEventViewController
@synthesize tableView = _tableView;
@synthesize textViewNote = _textViewNote;
@synthesize btnDelete = _btnDelete;
@synthesize selectedEvent = _selectedEvent;
@synthesize recurrenceItems = _recurrenceItems;
@synthesize reminderItems = _reminderItems;
@synthesize delegate = _delegate;


- (void)dealloc {
    [_tableView release];
    [_textViewNote release];
    [_btnDelete release];
    [_selectedEvent release];
    [_recurrenceItems release];
    [_reminderItems release];
    self.delegate = nil;
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if(self.selectedDate){
            self.selectedDate = [NSDate date];
            DLogInfo(@"init date %@",self.selectedDate);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    //prepare UI
    [self loadUI];
    
    //Prepare data
    [self initializeData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - init functions
-(void)loadUI{
    //page title
    if(self.selectedEvent)
    {
        self.title = @"Partner's Event";
        [self.btnDelete changeTitle:@"Delete Event"];
        self.btnDelete.hidden = NO;
        _isEditMode = TRUE;
    }
    else{
        self.title = @"Add Event";
        [self.btnDelete changeTitle:@"Reset Notifications"];
        self.btnDelete.hidden = NO;
        _isEditMode = FALSE;
    }
    
    [self.btnDelete.titleLabel setFont:[UIFont fontWithName:kAppFont size:18]];
    [self.textViewNote setFont:[UIFont fontWithName:kAppFont size:14]];
    
    //show navigation bar
    [self setNavigationBarHidden:NO animated:NO];
    [self.textViewNote makeRoundCorner:8];
    [self.textViewNote makeBorderWithWidth:1 andColor:[UIColor lightGrayColor]];
    self.textViewNote.placeholder = @"Notes";
    
    //navigator button (edit form don't have save button)
    [self addLeftBarCancelButton];
    [self addRightBarSaveButton];
    
    /**
     *  fix BackGround image
     *
     *  @param iOS7OrLater <#iOS7OrLater description#>
     *
     *  @return <#return value description#>
     */
//    if (iOS7OrLater) {
//        
//        UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"backgroundNoIcon.png"]];
//        self.view.backgroundColor = backgroundColor;
//    }else{
//        UIImageView *bgImageView = [[[UIImageView alloc] initWithFrame:self.tableView.frame] autorelease];
//        bgImageView.backgroundColor = [UIColor clearColor];
//        bgImageView.image = [UIImage imageNamed:@"backgroundNoIcon"];
//        [self.tableView setBackgroundView:bgImageView];
//    }
   
    
    
    // TableView
    self.tableView.backgroundColor = [UIColor clearColor];
    if (iOS7OrLater) {
        self.tableView.frame = CGRectMake(10, 0, 320, SCREEN_HEIGHT_PORTRAIT);
    }else{
        self.tableView.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT_PORTRAIT);
    }
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];
    
    // Info View
   
    if (iOS7OrLater) {
        if (IS_IPHONE_5) {
             self.infoView.frame = CGRectMake(-10, SCREEN_HEIGHT_PORTRAIT - 44- 44 - self.infoView.frame.size.height, self.infoView.frame.size.width, self.infoView.frame.size.height);
        }else{
            self.infoView.frame = CGRectMake(-10, SCREEN_HEIGHT_PORTRAIT - self.infoView.frame.size.height, self.infoView.frame.size.width - 0, self.infoView.frame.size.height);
        }
        
    }else{
        if (IS_IPHONE_5) {
             self.infoView.frame = CGRectMake(0, SCREEN_HEIGHT_PORTRAIT - 44- 44 - self.infoView.frame.size.height, self.infoView.frame.size.width, self.infoView.frame.size.height);
        }else{
             self.infoView.frame = CGRectMake(0, SCREEN_HEIGHT_PORTRAIT  - self.infoView.frame.size.height, self.infoView.frame.size.width, self.infoView.frame.size.height);
        }
    }
    
    [self.tableView addSubview:self.infoView];
    
    
  
    //text view
    self.textViewNote.layer.borderWidth = 1;
    self.textViewNote.layer.borderColor = [[UIColor blackColor] CGColor];
    self.textViewNote.layer.cornerRadius = 3;
    self.textViewNote.frame = CGRectMake(14, 0, self.textViewNote.frame.size.width - 10, self.textViewNote.frame.size.height);
    if (iOS7OrLater) {
        self.textViewNote.tintColor = [UIColor blueColor];

    }
    
    self.btnDelete.layer.cornerRadius = 6;
    self.btnDelete.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.btnDelete.layer.borderWidth = 3;
    self.btnDelete.frame = CGRectMake(14, self.btnDelete.frame.origin.y, self.btnDelete.frame.size.width - 10, self.btnDelete.frame.size.height);
    
    //table header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    //title
    UILabel *lblTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 27, self.tableView.frame.size.width, 20)] autorelease];
    lblTitle.font = [UIFont boldSystemFontOfSize:20];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    if(self.selectedEvent)
    {
        lblTitle.text = @"Edit Event";
    }
    else{
        lblTitle.text = @"Add Event";
    }
    [headerView addSubview:lblTitle];
    
    //back button
    [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:@selector(touchLeftBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    //save button
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(touchRightBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    [self.tableView setTableHeaderView:headerView];

    // Hiden reset button All Notification
    if (_isEditMode) {
        [self.btnDelete setHidden:NO];
    }else{
        [self.btnDelete setHidden:YES];
    }
}

//prepare data
-(void)initializeData{
    //fill data
    [self fillViewWithEventData:self.selectedEvent];
    
    //create the list for recurrence and reminer
    _reminderItems = [[NSArray alloc] initWithObjects:
                      MANAPP_EVENT_REMINDER_ITEM_NONE ,
                      MANAPP_EVENT_REMINDER_ITEM_AT_EVENT ,
                      MANAPP_EVENT_REMINDER_ITEM_15_MINUTES,
                      MANAPP_EVENT_REMINDER_ITEM_30_MINUTES,
                      MANAPP_EVENT_REMINDER_ITEM_1_HOUR ,
                      MANAPP_EVENT_REMINDER_ITEM_2_HOUR,
                      MANAPP_EVENT_REMINDER_ITEM_4_HOUR,
                      MANAPP_EVENT_REMINDER_ITEM_1_DAY,
                      MANAPP_EVENT_REMINDER_ITEM_2_DAY,
                      MANAPP_EVENT_REMINDER_ITEM_1_WEEK,
                      MANAPP_EVENT_REMINDER_ITEM_2_WEEK,
                      MANAPP_EVENT_REMINDER_ITEM_1_MONTH,
                      nil];
    
    _recurrenceItems = [[NSArray alloc] initWithObjects:
                          MANAPP_EVENT_RECURRING_NEVER,
                          MANAPP_EVENT_RECURRING_DAILY ,
                          MANAPP_EVENT_RECURRING_WEEKLY ,
                          MANAPP_EVENT_RECURRING_MONTHLY ,
                          MANAPP_EVENT_RECURRING_YEARLY ,
                          nil];
}

#pragma mark - functions
- (void) changeUIToEditModeWithEvent:(Event *) event{
    self.title = @"Partner's Event";
    _isEditMode = TRUE;
    self.selectedEvent = event;
    
    [self fillViewWithEventData:self.selectedEvent];
}

-(NSString *) getTitleString{
    NSIndexPath *eventTitleIndexPath = [NSIndexPath indexPathForRow:0 inSection:MANAPP_ADD_EVENT_VIEW_SECTION_TITLE];
    PPEditableTableViewCell *cell = (PPEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:eventTitleIndexPath];
    if(cell)
    {
        return cell.txtField.text;
    }
    
    return nil;
}

- (PPEditableTableViewCell *) getTitleCell{
    NSIndexPath *eventTitleIndexPath = [NSIndexPath indexPathForRow:0 inSection:MANAPP_ADD_EVENT_VIEW_SECTION_TITLE];
    PPEditableTableViewCell *cell = (PPEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:eventTitleIndexPath];
    
    return cell;
}

- (void) resignAllTextFields{
    [self.textViewNote resignFirstResponder];
}

#pragma mark - data handler
// fill the view with data
- (void) fillViewWithEventData:(Event *) event{
    if(event){
        self.selectedEvent = event;
//        event.eventEndTime;
        self.textViewNote.text = event.note;
    }
    //if the event is nil, load the field with default data
    else{
        self.selectedEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[[DatabaseHelper sharedHelper] managedObjectContext]];
        self.selectedEvent.eventName = @"";
        if(!self.selectedDate){
            self.selectedDate = [NSDate date];
        }
        self.selectedEvent.eventTime = self.selectedDate;
        self.selectedEvent.recurrence = @"";
        self.selectedEvent.reminder = MANAPP_EVENT_REMINDER_ITEM_NONE;
        self.textViewNote.text = @"";
        if(self.selectedEvent.eventEndTime == nil){
//            self.selectedEvent.eventEndTime = [self.selectedEvent.eventTime dateByAddMinute:60];
        }
        
        if(self.selectedEvent.finishTime == nil){
            self.selectedEvent.finishTime = [self.selectedEvent.eventTime dateByAddMinute:60];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
    if(_isEditMode){
        if(self.selectedEvent){
            if ([[DatabaseHelper sharedHelper] removeEventWithID:self.selectedEvent.eventID]) {
                [self showMessage:@"Event Deleted Successfully" title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_ADD_EVENT_VIEW_SUCCESS_DELETE_EVENT_ALERT_TAG];
                if (self.delegate && [(NSObject*) self.delegate respondsToSelector:@selector(addEventViewControllerDidDeleteEvent:)]) {
                    NSDate *fireDate = [self getFireDateOfUILocalNotificationFrom:self.selectedEvent];
                    if (fireDate) {
                        [[MANotificationManager sharedInstance] removeMoodNotificationOfPartner:[MASession sharedSession].currentPartner atDate:fireDate];
                    }

                    [self.delegate addEventViewControllerDidDeleteEvent:self];
                }
            } else {
                [self showErrorMessage:@"Could not delete this event"];
            }
        }
    }
    else{
        [self showMessage:@"You will deleted all the reminders and notifications? Are you sure about this?" title:kAppName cancelButtonTitle:@"YES" otherButtonTitle:@"NO" delegate:self tag:MANAPP_ADD_EVENT_VIEW_DELETE_ALL_NOTIFICATION];
    }
}

//leave the view
-(void) touchLeftBarButton:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

//save event
-(void) touchRightBarButton:(id)sender{

    NSString *eventTitle = self.selectedEvent.eventName;
    
    if(eventTitle == nil || [eventTitle isEqualToString:@""]){
        [self showMessage:@"Please give this event a title!"];
        return;
    }
    
    //if no partner then display an alert
    if(![[MASession sharedSession] currentPartner]){
        [self showMessage:@"You didn't select a partner. Please select one first!"];
        return;
    }
    
    //save event (only if this is an add form)
    if(!_isEditMode){
        NSArray *newEvents = [[DatabaseHelper sharedHelper] createNewPartnerEventWithEventName:eventTitle
                                                                                  andEventTime:self.selectedEvent.eventTime
                                                                                       endDate:self.selectedEvent.eventEndTime
                                                                                       andNote:self.textViewNote.text
                                                                                  andPartnerId:[[[MASession sharedSession] currentPartner].partnerID intValue]
                                                                                 andRecurrence:self.selectedEvent.recurrence
                                                                                   andReminder:self.selectedEvent.reminder
                                                                                    finishTime:self.selectedEvent.finishTime];
        if(newEvents && newEvents.count > 0)
        {
            [self showMessage:[NSString stringWithFormat:@"%@ created for %@", eventTitle , [MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_ADD_EVENT_VIEW_SUCCESS_ADD_EVENT_ALERT_TAG];
            
            if([((NSObject *)self.delegate) respondsToSelector:@selector(addEventViewControllerDidSaveEvent:)]){
                [self.delegate addEventViewControllerDidSaveEvent:self];
            }
            
            //set notification
            [[MANotificationManager sharedInstance] setNotificationForEvent:[newEvents objectAtIndex:0]];
        }
        else{
            [self showMessage:@"Cannot add event for this partner!"];
        }
    }
    else{
        if(self.selectedEvent){
            NSDate *fireDate = [self getFireDateOfUILocalNotificationFrom:self.selectedEvent];
            if (fireDate) {
                [[MANotificationManager sharedInstance] removeMoodNotificationOfPartner:[MASession sharedSession].currentPartner atDate:fireDate];
            }
            
            self.selectedEvent.eventName = eventTitle;
            self.selectedEvent.eventTime = self.selectedEvent.eventTime;
            self.selectedEvent.eventEndTime = self.selectedEvent.eventEndTime;
            self.selectedEvent.note = self.textViewNote.text;
            self.selectedEvent.reminder = self.selectedEvent.reminder;
            self.selectedEvent.type = [NSNumber numberWithInt:MANAPP_EVENT_TYPE_EVENT];
            [[MANotificationManager sharedInstance] setNotificationForEvent:self.selectedEvent];
            
            if([((NSObject *)self.delegate) respondsToSelector:@selector(addEventViewControllerDidSaveEvent:)]){
                [self.delegate addEventViewControllerDidSaveEvent:self];
            }
            
            [self showMessage:[NSString stringWithFormat:@"%@ successfully saved for %@", eventTitle , [MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" delegate:self tag:MANAPP_ADD_EVENT_VIEW_SUCCESS_ADD_EVENT_ALERT_TAG];
        }
    }
}

-(void) resignAllTextField{
    [super resignAllTextField];
    [self.textViewNote resignFirstResponder];
    
    PPEditableTableViewCell *cell = (PPEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.txtField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 44;
    if (indexPath.row == MANAPP_ADD_EVENT_VIEW_SECTION_TIME){
        cellHeight = 66;
    }
    cell.backgroundView = nil;
    UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width - 20, cellHeight)] autorelease];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    CGFloat paddingLeft = 5;
    CGFloat paddingTop = 3;
    UIView *textBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(paddingLeft, paddingTop, backgroundView.frame.size.width - paddingLeft*2, backgroundView.frame.size.height - paddingTop*2)] autorelease];
    textBackgroundView.backgroundColor = [UIColor whiteColor];
    textBackgroundView.layer.cornerRadius = 2;
    textBackgroundView.layer.borderWidth = 1;
    textBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
    [backgroundView addSubview:textBackgroundView];
    
    cell.backgroundView = backgroundView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell0 = @"Cell0";
    if (indexPath.row == MANAPP_ADD_EVENT_VIEW_SECTION_TITLE) {
        PPEditableTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:Cell0];
        if (!cell) {
            cell = [[[PPEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell0] autorelease];
            cell.txtField.delegate = self;
            
        }
        /**
         *  Fix Background Cell
         */
        if (iOS7OrLater) {
            [cell.txtField setTintColor:[UIColor blueColor]];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        }

        cell.txtField.placeholder = @"Title";
        cell.txtField.text = self.selectedEvent.eventName;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    /**
     *  Fix Background Cell
     */
    if (iOS7OrLater) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }

    cell.textLabel.text = @"";
    [cell.textLabel setFont:[UIFont fontWithName:kAppFont size:16]];
    cell.textLabel.lineBreakMode = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSLineBreakByWordWrapping:UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = @"";
    [cell.detailTextLabel setFont:[UIFont fontWithName:kAppFont size:13]];
    cell.detailTextLabel.lineBreakMode = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSLineBreakByWordWrapping:UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 2;
    
    switch (indexPath.row) {
        case MANAPP_ADD_EVENT_VIEW_SECTION_TIME:
        {
            
            if ([EventUtil isAllDayEvent2:self.selectedEvent.eventTime withEndDate:self.selectedEvent.finishTime]) {
                cell.textLabel.text = @"Starts";
                cell.detailTextLabel.text = [self.selectedEvent.eventTime toString];
            } else {
                cell.textLabel.text = @"Starts\nFinishes";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",[self.selectedEvent.eventTime toTimeString], [self.selectedEvent.finishTime toTimeString]];
            }
        }
            break;
        case MANAPP_ADD_EVENT_VIEW_SECTION_REMINDER:
            cell.textLabel.text = @"Reminder";
            cell.detailTextLabel.text = self.selectedEvent.reminder;
            break;
        case MANAPP_ADD_EVENT_VIEW_SECTION_RECUR:
            cell.textLabel.text = @"Repeat";
            cell.detailTextLabel.text = self.selectedEvent.recurrence;
            break;
            
        default:
            break;
    }
    cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left-arrow"]] autorelease];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        return 66;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row != MANAPP_ADD_EVENT_VIEW_SECTION_TITLE) {
        [self resignAllTextField];
        [self keyboardWillHide];
    }
    //go to the date time picker view if user click on the correspond section
    if(indexPath.row == MANAPP_ADD_EVENT_VIEW_SECTION_TIME){
      
        ChangeEventDateViewController* changeEventDateViewController = [self getViewControllerByName:@"ChangeEventDateViewController"];
        changeEventDateViewController.delegate = self;
        if(self.selectedEvent){
            [changeEventDateViewController setDefautPickerWithStartDate:self.selectedEvent.eventTime endDate:self.selectedEvent.finishTime];
        }
        [self nextTo:changeEventDateViewController];
    }
    else if(indexPath.row == MANAPP_ADD_EVENT_VIEW_SECTION_REMINDER){
        
        //generate selection list
        SelectionListViewController *selectionListViewController = [self getViewControllerByName:@"SelectionListViewController"];
        selectionListViewController.delegate = self;
        [selectionListViewController reloadUIWithItems:self.reminderItems andSelectedItem:self.selectedEvent.reminder];
        selectionListViewController.title = @"Event Repeat";
        
//        selectionListViewController.endDate = self.selectedEvent.eventEndTime;

        [self nextTo:selectionListViewController];
    }
    else if(indexPath.row == MANAPP_ADD_EVENT_VIEW_SECTION_RECUR){
       
        //generate selection list
        SelectionListViewController *selectionListViewController = [self getViewControllerByName:@"SelectionListViewController"];
        selectionListViewController.delegate = self;
        [selectionListViewController reloadUIWithItems:self.recurrenceItems andSelectedItem:self.selectedEvent.recurrence];
        selectionListViewController.title = @"Event Recurive";
        selectionListViewController.endDate = self.selectedEvent.eventEndTime;
        [self nextTo:selectionListViewController];
    }
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    if([self.textViewNote isFirstResponder]){
        [self resizeTableView:self.tableView withKeyboardState:YES willChangeOffset:YES];
    }
    else{
        [self resizeTableView:self.tableView withKeyboardState:YES willChangeOffset:NO];
    }
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    [self resizeTableView:self.tableView withKeyboardState:NO willChangeOffset:NO];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return TRUE;
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.selectedEvent.eventName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

#pragma mark - ChangeEventDateViewControllerDelegate
-(void) changeEventDateView:(ChangeEventDateViewController *)view didSaveWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if(self.selectedEvent){
        NSLog(@"start date %@",startDate);
        NSLog(@"end date %@",endDate);
        self.selectedEvent.eventTime = startDate;
        self.selectedEvent.finishTime = endDate;
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIAlertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == MANAPP_ADD_EVENT_VIEW_SUCCESS_ADD_EVENT_ALERT_TAG){
        [self.delegate addEventViewControllerDidSaveEvent:self];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else if(alertView.tag == MANAPP_ADD_EVENT_VIEW_SUCCESS_DELETE_EVENT_ALERT_TAG){
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else if(alertView.tag == MANAPP_ADD_EVENT_VIEW_DELETE_ALL_NOTIFICATION){
        if(buttonIndex == 0){
            [[MANotificationManager sharedInstance] removeAllNotificationWithType:MANotificationTypeEventReminder];
            [self showMessage:@"All reminder were deleted!"];
        }
    }
}

#pragma mark - SelectionListViewController
-(void)selectionList:(SelectionListViewController *)view didSelectItem:(NSInteger)index endDate:(NSDate *)endDate{
    //check the type of the view to see which list it is working on
    if([view.items isEqual:self.reminderItems]){
        self.selectedEvent.reminder = [self.reminderItems objectAtIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if([view.items isEqual:self.recurrenceItems]){
        self.selectedEvent.recurrence = [self.recurrenceItems objectAtIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    self.selectedEvent.eventEndTime = endDate;
}
- (void) selectionList:(SelectionListViewController *) view didSelectItem:(NSInteger) index{
    if([view.items isEqual:self.reminderItems]){
        self.selectedEvent.reminder = [self.reminderItems objectAtIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if([view.items isEqual:self.recurrenceItems]){
        self.selectedEvent.recurrence = [self.recurrenceItems objectAtIndex:index];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - change UI For ios 7
- (void) moveNavigationButtonsToView:(UIView *)view{
    UIButton * leftButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_LEFT_BUTTON_TAG];
    if(leftButton){
        [leftButton removeFromSuperview];
        [view addSubview:leftButton];
    }
    
    UIButton * rightButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
    if(rightButton){
        [rightButton removeFromSuperview];
        if (iOS7OrLater) {
            CGRect frame = rightButton.frame;
            frame.origin.x = frame.origin.x - 10;
            rightButton.frame = frame;
        }
        [view addSubview:rightButton];
    }
    
    UIButton * noteButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_NOTE_BUTTON_TAG];
    if(noteButton){
        [noteButton removeFromSuperview];
        [view addSubview:noteButton];
    }
    
    UIButton * summaryButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_SUMMARY_BUTTON_TAG];
    if(summaryButton){
        [summaryButton removeFromSuperview];
        [view addSubview:summaryButton];
    }
}

/**
 *  Get fireDate from event (by eventTime)
 */

- (NSDate *)getFireDateOfUILocalNotificationFrom:(Event *)event{
    NSInteger reminderSecond = 0;
    NSDate *notificationTime = nil;
    if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_NONE]){
        return notificationTime;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_AT_EVENT]){
        reminderSecond = 0;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_15_MINUTES]){
        reminderSecond = 15 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_30_MINUTES]){
        reminderSecond = 30 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_HOUR]){
        reminderSecond = 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_HOUR]){
        reminderSecond = 2 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_4_HOUR]){
        reminderSecond = 4 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_DAY]){
        reminderSecond = 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_DAY]){
        reminderSecond = 2 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_WEEK]){
        reminderSecond = 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_2_WEEK]){
        reminderSecond = 2 * 7 * 24 * 60 * 60;
    }
    else if([event.reminder isEqualToString:MANAPP_EVENT_REMINDER_ITEM_1_MONTH]){
        reminderSecond = 30 * 24 * 60 * 60;
    }
    
    //set the event to the notification
    notificationTime = [event.eventTime dateByAddSecond:(reminderSecond)];
    return notificationTime;
}


@end
