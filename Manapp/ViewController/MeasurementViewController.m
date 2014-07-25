//
//  MeasurementViewController.m
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MeasurementViewController.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "PartnerMeasurement.h"
#import "PartnerMeasurementItem.h"
#import "AddMeasurementItemController.h"
#import "MASession.h"

@interface MeasurementViewController ()
-(void) initialize;

-(void) addItemClicked:(id)sender;

-(void) refreshMeasurementData;

-(void) goToAddMeasurementView:(PartnerMeasurementItem*) item;
@end

@implementation MeasurementViewController
@synthesize measurements = _measurements;
@synthesize measurementTableView = _measurementTableView;
@synthesize cachedDictionary = _cachedDictionary;

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
    
    //if this partner don't have any data, push the add more item view
    // check if there is anydata, if not, then move to add information view (after alert)
    if([[MASession sharedSession] currentPartner]){
        NSArray *partnerMeasurementItems = [[DatabaseHelper sharedHelper] getAllItemMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        if([partnerMeasurementItems count] == 0){
            [self showMessage:@"You don't have any data yet, please input some data first." title:@"MANAPP" cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshMeasurementData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_measurementTableView release];
    [_measurements release];
    [_cachedDictionary release];
    [super dealloc];
}

#pragma mark - private functions
//prepare the UI and data
-(void) initialize{
    // Setup navigation bar ( with PLUS button to go to another page)
    [self setNavigationBarHidden:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked:)];
    
    // page title
    self.title = @"Size and Measurements";
    
    //add gesture swipe to go back
    [self addSwipeBackGesture];
    
    //prepare the data
    
    //if this partner exited, get his information
    self.measurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
    // Check exisiting information
    if ([[MASession sharedSession] currentPartner].measurements.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultMeasurementDataForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    // Others
    self.cachedDictionary = [NSMutableDictionary dictionary];
}

//go to add item page
-(void)goToAddMeasurementView:(PartnerMeasurementItem *)item{
    AddMeasurementItemController *addItemViewController = [self getViewControllerByName:@"AddMeasurementItemController"];
    addItemViewController.measurementItem = item;
    [self.navigationController pushViewController:addItemViewController animated:YES];
}

#pragma mark - data function
//reload the table view to show new update information
- (void)refreshMeasurementData
{
    if([[MASession sharedSession] currentPartner]){
        self.measurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        [self.cachedDictionary removeAllObjects];
        [self.measurementTableView reloadData];
    }
}

#pragma mark - event handler
//go to the add more item page
-(void)addItemClicked:(id)sender{
    [self goToAddMeasurementView:nil];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // go to add preference view if user didn't add any data for the preference table yet
    if(alertView.tag == MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG){
        [self goToAddMeasurementView:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.measurements.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    PartnerMeasurement *measurement = [self.measurements objectAtIndex:section];
    return measurement.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PartnerMeasurement *measurement = [self.measurements objectAtIndex:section];
    if (measurement.items.count > 0) {
        return measurement.name;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    PartnerMeasurement *pMeasurement = [self.measurements objectAtIndex:indexPath.section];
    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
    NSArray *items = [self.cachedDictionary objectForKey:key];
    if (!items) {
        items = [[DatabaseHelper sharedHelper] getAllItemForPartnerMeasurement:pMeasurement];
        [self.cachedDictionary setObject:items forKey:key];
    }
    
    PartnerMeasurementItem *item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PartnerMeasurement *pMeasurement = [self.measurements objectAtIndex:indexPath.section];
    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerMeasurement:pMeasurement];
    PartnerMeasurementItem *item = [items objectAtIndex:indexPath.row];
    [self goToAddMeasurementView:item];
}

@end
