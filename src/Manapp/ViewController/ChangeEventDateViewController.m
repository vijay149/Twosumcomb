//
//  ChangeEventDateViewController.m
//  Manapp
//
//  Created by Demigod on 27/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "ChangeEventDateViewController.h"
#import "PPEditableTableViewCell.h"
#import "MADeviceUtil.h"
#import "EventUtil.h"


@interface ChangeEventDateViewController ()
- (void) loadUI;
- (void) reloadUI;
- (void) validateDateTimeInput;
- (void) setEventAllDay;
@end

@implementation ChangeEventDateViewController
@synthesize tableViewEventItem = _tableViewEventItem;
@synthesize datePickerEventTime = _datePickerEventTime;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize delegate = _delegate;

- (void)dealloc {
    _delegate = nil;
    [_tableViewEventItem release];
    [_datePickerEventTime release];
    [_startDate release];
    [_endDate release];
    [_checkBoxAllDay release];
    [_lblAllday release];
    [super dealloc];
}

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
    [self loadUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - init functions
- (void) loadUI{
    //set navigation bar button
    [self addLeftBarCancelButton];
    [self addRightBarDoneButton];
    
    /**
     *  Handle Frame of UITableView when load it into iOS 7
     */
    
    //background
//    UIImageView *bgImageView = [[[UIImageView alloc] initWithFrame:self.tableViewEventItem.frame] autorelease];
//    bgImageView.backgroundColor = [UIColor clearColor];
//    bgImageView.image = [UIImage imageNamed:@"backgroundNoIcon"];
//    if (iOS7OrLater) {
//         UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"backgroundNoIcon.png"]];
//         self.view.backgroundColor = backgroundColor;
//    }else{
//        [self.tableViewEventItem setBackgroundView:bgImageView];
//    }
    [self.tableViewEventItem setBackgroundColor:[UIColor clearColor]];
    /**
     *  Frame of TableView
     */
    self.tableViewEventItem.backgroundColor = [UIColor clearColor];
    if (iOS7OrLater) {
        self.tableViewEventItem.frame = CGRectMake(10, 0, 320, SCREEN_HEIGHT_PORTRAIT);
    }else{
        self.tableViewEventItem.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT_PORTRAIT);
    }

    
    //table header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableViewEventItem.frame.size.width, 60)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    //back button
    [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:@selector(touchLeftBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    //save button
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(touchRightBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    [self.tableViewEventItem setTableHeaderView:headerView];
    
    //add the checkbox button
    _checkBoxAllDay = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(150, 10, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
    [self.checkBoxAllDay addTarget:self action:@selector(changeAllDayState:) forControlEvents:UIControlEventTouchUpInside];
    self.checkBoxAllDay.isAllowToggle = YES;
    [self.checkBoxAllDay setCheckWithState:NO];
    
    //checkbox label
    _lblAllday = [[UILabel alloc] initWithFrame:CGRectMake(180, 10, 150, 25)];
    [self.lblAllday setBackgroundColor:[UIColor clearColor]];
    self.lblAllday.textColor = [UIColor whiteColor];
    if(_isAllDay){
        self.lblAllday.text = @"All Day Event";
    }
    else{
        self.lblAllday.text = @"All Day Event";
    }
    
    //set the state of the all day
    if ([EventUtil isAllDayEvent:self.startDate withEndDate:self.endDate]) {
        [self.checkBoxAllDay setCheckWithState:YES];
        [self changeAllDayState:nil];
        
    } else {
//        if (self.startDate) {
//            self.datePickerEventTime.date = self.startDate;
//        } else if(self.endDate){
//            self.datePickerEventTime.date = self.endDate;
//        }
    }
    if (self.startDate) {
        self.datePickerEventTime.date = self.startDate;
    } else if(self.endDate){
        self.datePickerEventTime.date = self.endDate;
    }
    /**
     *  Change Color background for Picker
     */
    [self.datePickerEventTime setBackgroundColor:COLORFORPICKERVIEW];

    [self.datePickerEventTime setLocale:[NSLocale currentLocale]];
}


#pragma mark - private function
- (void) setDefautPickerWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if(startDate){
        self.startDate = startDate;
    }
    
    if(endDate){
        self.endDate = endDate;
    }
    
    [self reloadUI];
}

-(void) reloadUI{
    if(self.startDate){
        self.startDate = self.startDate;
        NSLog(@"start date %@",self.startDate);
        [self.datePickerEventTime setDate:self.startDate animated:YES];
    }
    
    if(self.endDate){
        NSLog(@"end date %@",self.endDate);
        self.endDate = self.endDate;
        [self.datePickerEventTime setDate:self.startDate animated:YES];
    }
    
    [self.tableViewEventItem reloadData];
}

//make sure the endtime always after the start time
- (void) validateDateTimeInput{
    if(_selectedRow == 0){
        if([self.startDate isAfterDate:self.endDate]){
            self.endDate = [self.startDate dateByAddMinute:60];
        }
    }
    else{
        if([self.startDate isAfterDate:self.endDate]){
            self.startDate = [self.endDate dateByAddMinute:-60];
        }
    }
}

#pragma mark - event handler
- (IBAction)datePickerEventTime_dateDidChanged:(id)sender {
    if(!_isAllDay){
        if(_selectedRow == 0){
            self.startDate = [self.datePickerEventTime date];
        }
        else{
            self.endDate = [self.datePickerEventTime date];
        }
    }
    else{
        self.startDate = [[self.datePickerEventTime date] beginningAtMidnightOfDay];
        self.endDate = [self.startDate dateByAddDays:1];
    }
    
    [self validateDateTimeInput];
    [self.tableViewEventItem reloadData];
}

-(void)touchLeftBarButton:(id)sender{
    [self back];
}

-(void)touchRightBarButton:(id)sender{
    [self.delegate changeEventDateView:self didSaveWithStartDate:self.startDate endDate:self.endDate];
    [self back];
}

-(void)changeAllDayState:(id)sender{
    if(self.checkBoxAllDay.isChecked){
        _isAllDay = YES;
        [self setEventAllDay];
        [self.datePickerEventTime setDatePickerMode:UIDatePickerModeDate];
        self.lblAllday.text = @"All Day Event";
    }
    else{
        _isAllDay = NO;
        [self.datePickerEventTime setDatePickerMode:UIDatePickerModeDateAndTime];
        self.lblAllday.text = @"All Day event";
    }
    [self.tableViewEventItem reloadData];
}

// If check event all day will set Start date = current
// End date = tomorrow
- (void) setEventAllDay {
    NSLog(@"start date: %@",self.startDate);
    NSLog(@"tomorrow %@",[self.startDate dateByAddDays:1]);
    self.endDate =  [self.startDate dateByAddDays:1];
//    self.datePickerEventTime.date = self.startDate;
}


#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([tableView isEqual:self.tableViewEventItem])
    {
        return 1;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:self.tableViewEventItem])
    {
        //in case it is an allday event, we will only display a picker for the start date
        if(_isAllDay){
            return 2;
        }
        return 3;
    }
    
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row <= 1 && !_isAllDay) || (_isAllDay && indexPath.row < 1)){
        //the two row which display the start and the end time of the event
        CGFloat cellHeight = 44;

        cell.backgroundView = nil;
        UIView *backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableViewEventItem.frame.size.width - 20, cellHeight)] autorelease];
        backgroundView.backgroundColor = [UIColor clearColor];
        
        CGFloat paddingLeft = 5;
        CGFloat paddingTop = 0;
        UIView *textBackgroundView = [[[UIView alloc] initWithFrame:CGRectMake(paddingLeft, paddingTop, backgroundView.frame.size.width - paddingLeft*2, backgroundView.frame.size.height - paddingTop*2)] autorelease];
        textBackgroundView.backgroundColor = [UIColor whiteColor];
        textBackgroundView.layer.cornerRadius = 2;
        textBackgroundView.layer.borderWidth = 1;
        textBackgroundView.layer.borderColor = [[UIColor blackColor] CGColor];
        [backgroundView addSubview:textBackgroundView];
        
        cell.backgroundView = backgroundView;
    }
    else{
        cell.backgroundView = nil;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.tableViewEventItem])
    {
        if(_isAllDay){
            if(indexPath.row == 0){
                //the two row which display the start and the end time of the event
                static NSString *CellDateIdentify = @"CellDatePicker";
                
                PPEditableTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellDateIdentify];
                if (!cell) {
                    cell = [[[PPEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellDateIdentify showTitle:YES] autorelease];
                    
                }
                /**
                 *  Fix Background Cell
                 */
                if (iOS7OrLater) {
                    cell.backgroundColor = [UIColor clearColor];
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                }


                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:213.0f/255 green:221.0f/255  blue:232.0f/255  alpha:1.0];
                
                cell.txtField.text = [self.startDate toString];
                cell.txtField.placeholder = @"Start Time";
                cell.txtField.enabled = FALSE;
                cell.txtField.textAlignment = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSTextAlignmentRight:UITextAlignmentRight;
                cell.lblTitle.text = @"Start";
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            else{
                //row for the all day picker
                static NSString *CellAddDayIdentify = @"CellAllDayPicker";
                
                UITableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellAddDayIdentify];
                if (!cell) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddDayIdentify] autorelease];
                    cell.backgroundColor = [UIColor clearColor];
                    
                    [cell addSubview:self.checkBoxAllDay];
                    [cell addSubview:self.lblAllday];
                }
                /**
                 *  Fix Background Cell
                 */
                if (iOS7OrLater) {
                    cell.backgroundColor = [UIColor clearColor];
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                }

                
                return cell;
            }
        }
        else{
            if(indexPath.row <= 1){
                //the two row which display the start and the end time of the event
                static NSString *CellIdentify = @"CellTimePicker";
                
                PPEditableTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentify];
                if (!cell) {
                    cell = [[[PPEditableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentify showTitle:YES] autorelease];
                }
                /**
                 *  Fix Background Cell
                 */
                if (iOS7OrLater) {
                    cell.backgroundColor = [UIColor clearColor];
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:213.0f/255 green:221.0f/255  blue:232.0f/255  alpha:1.0];
                
                if(indexPath.row == 0)
                {
                    cell.txtField.text = [self.startDate toTimeString];
                    cell.txtField.placeholder = @"Start Time";
                    cell.txtField.enabled = FALSE;
                    cell.txtField.textAlignment = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSTextAlignmentRight:UITextAlignmentRight;
                    cell.lblTitle.text = @"Start";
                    
                }
                else if(indexPath.row == 1){
                    cell.txtField.text = [self.endDate toTimeString];
                    cell.txtField.placeholder = @"Finish Time";
                    cell.txtField.enabled = FALSE;
                    cell.txtField.textAlignment = ([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0)?NSTextAlignmentRight:UITextAlignmentRight;
                    cell.lblTitle.text = @"Finish";
                }
                else{
                    cell.txtField.placeholder = @"";
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            else{
                //row for the all day picker
                static NSString *CellAddDayIdentify = @"CellAllDayPicker";
                
                UITableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellAddDayIdentify];
                if (!cell) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellAddDayIdentify] autorelease];
                    cell.backgroundColor = [UIColor clearColor];
                    
                    [cell addSubview:self.checkBoxAllDay];
                    [cell addSubview:self.lblAllday];
                }
                
                return cell;
            }
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableViewEventItem deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.row == 0 || indexPath.row == 1){
        _selectedRow = indexPath.row;
        if(indexPath.row == 0)
        {
            if(self.startDate){
                [self.datePickerEventTime setDate:self.startDate animated:YES];
            }
        }
        else{
            if(self.endDate){
                [self.datePickerEventTime setDate:self.endDate animated:YES];
            }
        }
    }
    
}

#pragma mark - change UI For ios 7
/**
 *  Overide fuction in BaseView to fix on IOS 7
 *
 *  @param view <#view description#>
 */
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

@end
