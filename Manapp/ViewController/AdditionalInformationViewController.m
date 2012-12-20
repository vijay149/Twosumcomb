//
//  AdditionalInformationViewController.m
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AdditionalInformationViewController.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "PartnerInformation.h"
#import "PartnerInformationItem.h"
#import "AddAdditionalItemViewController.h"
#import "MASession.h"

@interface AdditionalInformationViewController ()
-(void) initialize;

-(void) addItemClicked:(id)sender;

-(void) refreshInformationData;

-(void) goToAddInformationView:(PartnerInformationItem*) item;
@end

@implementation AdditionalInformationViewController
@synthesize cachedDictionary = _cachedDictionary;
@synthesize partnerInformation = _partnerInformation;
@synthesize informationTableView = _informationTableView;

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
        NSArray *partnerInformationItems = [[DatabaseHelper sharedHelper] getAllItemInformationForPartner:[[MASession sharedSession] currentPartner]];
        if([partnerInformationItems count] == 0){
            [self showMessage:@"You don't have any data yet, please input some data first." title:@"MANAPP" cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshInformationData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_informationTableView release];
    [_partnerInformation release];
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
    self.title = @"Additional Information";
    
    //add gesture swipe to go back
    [self addSwipeBackGesture];

    //prepare the data
    
    //if this partner exited, get his information
    self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
    
    // Check exisiting information
    if ([[MASession sharedSession] currentPartner].information.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultInformationForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    // Others
    self.cachedDictionary = [NSMutableDictionary dictionary];
}

//go to add item page
-(void) goToAddInformationView:(PartnerInformationItem*) item{
    AddAdditionalItemViewController *addItemViewController = [self getViewControllerByName:@"AddAdditionalItemViewController"];
    addItemViewController.informationItem = item;
    [self.navigationController pushViewController:addItemViewController animated:YES];
}

#pragma mark - data function
//reload the table view to show new update information
- (void)refreshInformationData
{
    if([[MASession sharedSession] currentPartner]){
        self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
        [self.cachedDictionary removeAllObjects];
        [self.informationTableView reloadData];
    }
}

#pragma mark - event handler
//go to the add more item page
-(void)addItemClicked:(id)sender{
    [self goToAddInformationView:nil];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // go to add preference view if user didn't add any data for the preference table yet
    if(alertView.tag == MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG){
        [self goToAddInformationView:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.partnerInformation.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    PartnerInformation *information = [self.partnerInformation objectAtIndex:section];
    return information.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PartnerInformation *information = [self.partnerInformation objectAtIndex:section];
    if (information.items.count > 0) {
        return information.name;
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
    PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:indexPath.section];
    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
    NSArray *items = [self.cachedDictionary objectForKey:key];
    if (!items) {
        items = [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:pInformation];
        [self.cachedDictionary setObject:items forKey:key];
    }
    
    PartnerInformationItem *item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:indexPath.section];
    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:pInformation];
    PartnerInformationItem *item = [items objectAtIndex:indexPath.row];
    [self goToAddInformationView:item];
}
@end
