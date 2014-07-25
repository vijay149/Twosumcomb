//
//  AddEventViewController.m
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AddEventViewController.h"
#import "Event.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+Additions.h"
#import "PPEditableTableViewCell.h"
#import "MADeviceUtil.h"
#import "NSDate+Helper.h"

@interface AddEventViewController ()
- (void) initialize;
- (void) initializeData;

- (void)cancel:(id)sender;
- (void)save:(id)sender;

- (void) fillViewWithEventData:(Event *) event;
@end

@implementation AddEventViewController
@synthesize tableView = _tableView;
@synthesize textViewNote = _textViewNote;
@synthesize btnDelete = _btnDelete;
@synthesize selectedEvent = _selectedEvent;
@synthesize recurrenceItems = _recurrenceItems;
@synthesize reminderItems = _reminderItems;

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
    
    //prepare UI
    [self initialize];
    
    //Prepare data
    [self initializeData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableView release];
    [_textViewNote release];
    [_btnDelete release];
    [_selectedEvent release];
    [_recurrenceItems release];
    [_reminderItems release];
    [super dealloc];
}

#pragma mark - init functions
-(void)initialize{
    //page title
    if(self.selectedEvent)
    {
        self.title = @"Partner's Event";
        _stateCreation = FALSE;
    }
    else{
        self.title = @"Add Event";
        _stateCreation = TRUE;
    }
    
    //show navigation bar
    [self setNavigationBarHidden:NO animated:NO];
    [self.textViewNote makeRoundCorner:8];
    [self.textViewNote makeBorderWithWidth:1 andColor:[UIColor lightGrayColor]];
    self.textViewNote.placeholder = @"Notes";
    
    //navigator button (edit form don't have save button)
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
}

//prepare data
-(void)initializeData{
    //fill data
    [self fillViewWithEventData:self.selectedEvent];
    
    //create the list for recurrence and reminer
    self.reminderItems = [[NSArray alloc] initWithObjects:
                           MANAPP_EVENT_REMINDER_ITEM_1 ,
                           MANAPP_EVENT_REMINDER_ITEM_2 ,
                           MANAPP_EVENT_REMINDER_ITEM_3 ,
                           MANAPP_EVENT_REMINDER_ITEM_4,
                           nil];
    
    self.recurrenceItems = [[NSArray alloc] initWithObjects:
                          MANAPP_EVENT_RECURRING_NEVER,
                          MANAPP_EVENT_RECURRING_DAILY ,
                          MANAPP_EVENT_RECURRING_WEEKLY ,
                          MANAPP_EVENT_RECURRING_MONTHLY ,
                          nil];
}

#pragma mark - data handler
// fill the view with data
- (void) fillViewWithEventData:(Event *) event{
    if(event){
        self.selectedEvent = event;
        self.textViewNote.text = event.note;
    }
    //if the event is nil, load the field with default data
    else{
        self.selectedEvent.eventName = @"";
        self.selectedEvent.eventTime = [NSDate date];
        self.selectedEvent.recurrence = @"";
        self.selectedEvent.reminder = @"";
        self.textViewNote.text = @"";
    }
}

#pragma mark - event handler
- (IBAction)btnDelete_touchUpInside:(id)sender {
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

//save the selected data
- (void)save:(id)sender
{
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell0 = @"Cell0";
    if (indexPath.section == MANAPP_ADD_EVENT_VIEW_SECTION_TITLE) {
        PPEditableTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:Cell0];
        if (!cell) {
            cell = [[[PPEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell0] autorelease];
            cell.txtField.delegate = self;
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
    cell.textLabel.text = @"";
    cell.textLabel.lineBreakMode = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSLineBreakByWordWrapping:UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 2;
    cell.detailTextLabel.text = @"";
    cell.detailTextLabel.lineBreakMode = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSLineBreakByWordWrapping:UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 2;
    
    switch (indexPath.section) {
        case MANAPP_ADD_EVENT_VIEW_SECTION_TIME:
        {
            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
            dateFormatter.dateFormat = @"EEE, MMM dd hh:mm";
            
            cell.textLabel.text = @"Starts\nEnds";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@",[NSDate stringFromDate:self.selectedEvent.eventTime withFormat:@"EEE, MMM dd hh:mm"], [NSDate stringFromDate:[self.selectedEvent.eventTime dateByAddDays:1] withFormat:@"EEE, MMM dd hh:mm"]];
        }
            break;
        case MANAPP_ADD_EVENT_VIEW_SECTION_REMINDER:
            cell.textLabel.text = @"Remindner";
            cell.detailTextLabel.text = self.selectedEvent.reminder;
            break;
        case MANAPP_ADD_EVENT_VIEW_SECTION_RECUR:
            cell.textLabel.text = @"Recurrence";
            cell.detailTextLabel.text = self.selectedEvent.recurrence;
            break;
            
        default:
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 66;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITextViewDelegate

-(void)keyboardWillShow:(NSNotification *)notification{
    [super keyboardWillShow:notification];
    [self resizeTableView:self.tableView withKeyboardState:YES willChangeOffset:YES];
}

-(void)keyboardWillHide{
    [super keyboardWillHide];
    [self resizeTableView:self.tableView withKeyboardState:NO willChangeOffset:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSIndexPath *eventTitleIndexPath = [NSIndexPath indexPathForRow:0 inSection:MANAPP_ADD_EVENT_VIEW_SECTION_TITLE];
    PPEditableTableViewCell *cell = (PPEditableTableViewCell *)[self.tableView cellForRowAtIndexPath:eventTitleIndexPath];
    if(cell)
    {
        self.selectedEvent.eventName = [cell.txtField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return YES;
}

@end
