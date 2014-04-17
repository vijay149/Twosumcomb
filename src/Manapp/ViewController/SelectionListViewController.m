//
//  SelectionListViewController.m
//  Manapp
//
//  Created by Demigod on 25/12/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//



#import "SelectionListViewController.h"
#import "NSDate+Helper.h"


@interface SelectionListViewController ()
-(void) initialize;
-(NSInteger) getIndexOfItem:(NSString *)item;
@end

@implementation SelectionListViewController
@synthesize items = _items;
@synthesize delegate;
@synthesize btnChooseEndDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadUI];
    
    if (![self.title isEqualToString:@"Event Repeat"]) {
        [self setupViewControll];
        self.tableView.scrollEnabled = NO;
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    [_items release];
    [_tableView release];
    [_lblEndDate release];
    [super dealloc];
}

#pragma mark - init function
-(void) initialize{
    _items = [[NSArray alloc] init];
    _selectedItemIndex = -1;

}

#pragma mark - UI function
-(void) loadUI{
    //background
//    UIImageView *bgImageView = [[[UIImageView alloc] initWithFrame:self.tableView.frame] autorelease];
//    bgImageView.backgroundColor = [UIColor clearColor];
//    bgImageView.image = [UIImage imageNamed:@"backgroundNoIcon"];
//    [self.tableView setBackgroundView:nil];
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundNoIcon.png"]];

    
    //table header
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)] autorelease];
    headerView.backgroundColor = [UIColor clearColor];
    
    //back button
    [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:@selector(touchLeftBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    //save button
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(touchRightBarButton:)];
    [self moveNavigationButtonsToView:headerView];
    
    /**
     *  change frame UITableView
     */

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundView:nil];
    
    [self.view bringSubviewToFront:headerView];
    [self.view addSubview:headerView];
    CGRect frmTable = self.tableView.frame;
    
    if (IS_IPHONE_5) {
        frmTable.origin.y = +50;
        frmTable.size.height = SCREEN_HEIGHT_PORTRAIT - 44 - 50 - 44;
    }else{
        if (iOS7OrLater) {
            frmTable.origin.y = +50;
        }else{
            frmTable.origin.y = +70;
        }
    }
    
    self.tableView.frame = frmTable;

  
}

#pragma mark - list functions
-(void) reloadUIWithItems:(NSArray *) items andSelectedItem:(NSString *) selectedItem{
    self.items = items;
    _selectedItemIndex = [self getIndexOfItem:selectedItem];
    [self.tableView reloadData];
}

-(NSInteger) getIndexOfItem:(NSString *)item{
    if(!item || !self.items ){
        return -1;
    }
    
    //return the index if we can find it
    NSInteger numberOfItem = self.items.count;
    for(NSInteger i = 0; i < numberOfItem; i++){
        NSString *indexItem = [self.items objectAtIndex:i];
        if([indexItem isEqualToString:item]){
            return i;
        }
    }
    
    return -1;
}

#pragma mark - event handler
-(void) touchLeftBarButton:(id)sender{
//    [self back];
    [self backView:sender];
}

-(void) touchRightBarButton:(id)sender{
    if (![self.title isEqualToString:@"Event Repeat"]) {
        if (_selectedItemIndex != -1) {
            if (self.btnCheckForever.selected) {
                self.endDate =  [NSDate dateFromString:[NSString stringWithFormat:@"01-01-%d", kYearForever] withFormat:@"dd-MM-yyyy"];
            }else{
                
            }
           [self.delegate selectionList:self didSelectItem:_selectedItemIndex endDate:self.endDate];
        }
    }else{
         [self.delegate selectionList:self didSelectItem:_selectedItemIndex];
    }
    [self back];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.items objectAtIndex:indexPath.row];
    if (!IS_IPHONE_5) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    
    //if this is the selected row, show the indicator
    if(_selectedItemIndex == indexPath.row){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return 44;
    }
    return 30;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedItemIndex = indexPath.row;
    if (_selectedItemIndex != 0) {
        if (![self.title isEqualToString:@"Event Repeat"]) {
            if (![self.title isEqualToString:@"Event Repeat"]) {
                [self setupViewControll];
            }
            
            self.btnCheckForever.selected = YES;
            [self hideControls];
            if (self.viewControll.hidden) {
                [self showViewWithAnimation:self.viewControll withTimeInterval:1.0];
                
            }

        }

    }else{
        if (![self.title isEqualToString:@"Event Repeat"]) {
            self.btnCheckForever.selected = YES;
            [self hideControls];
            if (self.viewControll.hidden) {
                [self showViewWithAnimation:self.viewControll withTimeInterval:1.0];
                
            }
            
            self.btnCheckForever.selected = NO;
            self.endDate = nil;
            if (!self.viewControll.hidden) {
                [self hideViewWithAnimation:self.viewControll withTimeInterval:1.0];
            }

        }
        
    }
    [self.tableView reloadData];
}

#pragma mark - Handle View Controll

/**
 *  <#Description#>
 */
- (void)setupViewControll
{
    /**
     *  Prepare Picker View
     */
    
    self.viewPicker.frame = CGRectMake(0, self.viewControll.frame.size.height, SCREEN_WIDTH_PORTRAIT, 206);
    [self.viewControll addSubview:self.viewPicker];
    
    
    
    
    /**
     *  Logic show/hide view
     */
    
    [self hideControls];
    if (_selectedItemIndex == 0 || _selectedItemIndex == -1) {
        [self.viewControll setHidden:YES];
        [self hideControls];
    }
    if (!self.endDate) {
        [self.viewControll setHidden:YES];
        [self hideControls];
    }else{
        NSLog(@"****: %d", [self getYearOfDate:self.endDate]);
        if ([self getYearOfDate:self.endDate] == kYearForever) {
            [self.viewControll setHidden:NO];
            [self hideControls];
            [self.btnCheckForever setSelected:YES];
        }else{
            [self showControls];
            self.labelDate.text = [self.endDate toString];
            [self.btnChooseEndDate setTitle:[self.endDate toString] forState:UIControlStateNormal];
            self.btnChooseEndDate.titleLabel.text = [self.endDate toString];
            self.datePicker.date = self.endDate;
        }
    }
    
    
    
    CGRect frameViewControll = self.viewControll.frame;
    frameViewControll.origin.x = 0;
    frameViewControll.origin.y = SCREEN_HEIGHT_PORTRAIT - frameViewControll.size.height;
    self.viewControll.frame = frameViewControll;
    self.datePicker.backgroundColor = COLORFORPICKERVIEW;
    [self.view addSubview:self.viewControll];
    /**
     *  hiden view at first load
     */
//    [self.viewControll setHidden:YES];
  
}

/**
 *  Animation Hiden View
 */

- (void)hideViewWithAnimation:(id)view withTimeInterval:(CGFloat)time{
    [UIView animateWithDuration:time
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^ {
                         [view setHidden:YES];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)showViewWithAnimation:(id)view withTimeInterval:(NSInteger)time{
    [UIView animateWithDuration:time
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^ {
                         [view setHidden:NO];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Action Change

- (IBAction)btnSelectDateClicked:(id)sender{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^ {
                         CGRect tempFrame = self.viewPicker.frame;
                         tempFrame.origin.y = self.viewControll.frame.size.height;
                         self.viewPicker.frame = tempFrame;
                     }
                     completion:^(BOOL finished) {
                         NSDate *theDate = self.datePicker.date;
                         self.labelDate.text = [theDate toString];
                         self.endDate = theDate;
                     }];

}

- (IBAction)btnCheckForeverClicked:(id)sender{
    self.btnCheckForever.selected = !self.btnCheckForever.selected;
    NSDate *foreverDate = [NSDate dateFromString:[NSString stringWithFormat:@"01-01-%d", kYearForever] withFormat:@"dd-MM-yyyy"];
    DLog(@"%@", foreverDate);
    if (!self.btnCheckForever.selected) {
        [self showControls];
        NSDate *theDate = [NSDate date];
        self.labelDate.text = [theDate toString];
        self.endDate = theDate;
        [self.btnChooseEndDate setTitle:[[NSDate date] toString] forState:UIControlStateNormal];
        
        
    }else{
        [self hideControls];
        self.endDate = foreverDate;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^ {
                             CGRect tempFrame = self.viewPicker.frame;
                             tempFrame.origin.y = self.viewControll.frame.size.height;
                             self.viewPicker.frame = tempFrame;
                         }
                         completion:^(BOOL finished) {
                             NSDate *theDate = [NSDate date];
                             self.labelDate.text = [theDate toString];
                             self.endDate = theDate;
                             self.datePicker.date = self.endDate;
                         }];

    }
    
    
}

- (IBAction)datePickerValueChanged:(id)sender{
    NSDate *theDate = self.datePicker.date;
    self.labelDate.text = [theDate toString];
    self.endDate = theDate;
    
    [self.btnChooseEndDate setTitle:[theDate toString] forState:UIControlStateNormal];
}

- (IBAction)btnChooseEndDateClicked:(id)sender{

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationCurveEaseIn
                     animations:^ {
                         CGRect tempFrame = self.viewPicker.frame;
                         tempFrame.origin.y = self.viewControll.frame.size.height - self.viewPicker.frame.size.height;
                         self.viewPicker.frame = tempFrame;
                     }
                     completion:^(BOOL finished) {
                         
                     }];

}

- (void)hideControls{
    [self.lblEndDate setHidden:YES];
    [self.labelDate setHidden:YES];
//    [self.datePicker setHidden:YES];
    [self.btnChooseEndDate setHidden:YES];
}

- (void)showControls{
    [self.lblEndDate setHidden:NO];
    [self.labelDate setHidden:NO];
    [self.btnChooseEndDate setHidden:NO];
//    [self.datePicker setHidden:NO];
}


- (void)viewDidUnload {
    [self setLblEndDate:nil];
    [super viewDidUnload];
}

- (int)getYearOfDate:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    return year;
}

/**
 *  Overide function back
 */

- (void)backView:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
