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
#import "MAMeasurementCell.h"
#import "MAUserProcessManager.h"
#import "UILabel+Additions.h"
#import "RATreeView.h"
#import "RADataObject.h"
@interface MeasurementViewController () <RATreeViewDelegate, RATreeViewDataSource>
-(void) initialize;

-(void) addItemClicked:(id)sender;

-(void) refreshMeasurementData;

-(void) goToAddMeasurementView:(PartnerMeasurementItem*) item;
- (void) goToViewAddMeasurement;
//Tree view
- (void) initializeTreeView;
@property (retain, nonatomic) RATreeView *treeView;
@property (retain, nonatomic) NSMutableArray *data;
@property (nonatomic, assign) BOOL firstTime;
@end

@implementation MeasurementViewController
@synthesize measurements = _measurements;
@synthesize measurementTableView = _measurementTableView;
@synthesize cachedDictionary = _cachedDictionary;


- (void)dealloc {
    [_measurementTableView release];
    [_measurements release];
    [_cachedDictionary release];
    [_processBar release];
    [_lblProcess release];
    [_data release];
    [_treeView release];
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
    //prepare the UI
    [self initialize];
    [self initializeTreeView];
    if (iOS7OrLater) {
        self.firstTime = YES;
    } else {
        [self goToViewAddMeasurement];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS7OrLater) {
        if (self.firstTime) {
            self.firstTime = NO;
            [self goToViewAddMeasurement];
        }
    }

}

- (void) goToViewAddMeasurement {
    //if this partner don't have any data, push the add more item view
    // check if there is anydata, if not, then move to add information view (after alert)
    if([[MASession sharedSession] currentPartner]){
        NSArray *partnerMeasurementItems = [[DatabaseHelper sharedHelper] getAllItemMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        if([partnerMeasurementItems count] == 0){
            [self showMessage:[NSString stringWithFormat:@"Please select a category and start entering the measurements for %@.",[MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:nil tag:MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG];
            
            AddMeasurementItemController *addItemViewController = NEW_VC(AddMeasurementItemController);
            [self.navigationController pushViewController:addItemViewController animated:NO];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initialize];
    [self.treeView reloadData];
    [self loadProgressBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI functions
-(void) loadProgressBar{
    [self.processBar setMinValue:0];
	[self.processBar setMaxValue:100];
    NSInteger progressValue = (NSInteger)[[MAUserProcessManager sharedInstance] getProcessForCurrentPartner];
	[self.processBar setRealProgress:progressValue];
    
    self.lblProcess.text = [NSString stringWithFormat:@"%d%%",progressValue];
    [self.lblProcess setFont:[UIFont fontWithName:kAppFont size:11]];
}

#pragma mark - private functions
//prepare the UI and data
-(void) initialize {
    // Setup navigation bar ( with PLUS button to go to another page)
    [self.navigationController setNavigationBarHidden:YES];
    [self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(back)];
    [self createRightNavigationWithTitle:MA_ADD_BUTTON_TEXT action:@selector(addItemClicked:)];
    
    // page title
    self.title = @"Size and Measurements";
    
    //add gesture swipe to go back
    [self addSwipeBackGesture];
    
    //prepare the data
    self.data = [NSMutableArray array];
    NSMutableArray *listObject = [NSMutableArray array];
    //if this partner exited, get his information
    self.measurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
    // Check exisiting information
    if ([[MASession sharedSession] currentPartner].measurements.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultMeasurementDataForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    for (PartnerMeasurement *measurement in self.measurements) {
        NSArray *items = [self convertAbstractArrayToRADataObjectArray:kMeasurement arrayInput:[self getItemsInCategory:measurement]];
        if(items.count > 0){
            RADataObject *raDO = [RADataObject dataObjectWithName:measurement.name children:items isParent:NO isSubParent:YES isSubOfSubParent:NO isPreference:NO isLike:NO];
            [listObject addObject:raDO];
        }
    }
    
    if (listObject && listObject.count > 0) {
        RADataObject *mesurement = [RADataObject dataObjectWithName:@"Measurements" children:listObject isParent:YES isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];
        [self.data addObject:mesurement];
    }
}


- (void) initializeTreeView {
    RATreeView *treeView = [[[RATreeView alloc] initWithFrame:self.view.frame] autorelease];
    //    treeView.scrollEnabled = NO;
    if (IS_IPHONE_5) {
        treeView.frame = CGRectMake(treeView.frame.origin.x + 20, treeView.frame.origin.y + 70, treeView.frame.size.width - 40, treeView.frame.size.height + 30);
    } else {
        treeView.frame = CGRectMake(treeView.frame.origin.x + 20, treeView.frame.origin.y + 70, treeView.frame.size.width - 40, treeView.frame.size.height - 45);
    }
    NSLog(@"x: %f, y : %f",treeView.frame.origin.x,treeView.frame.origin.y);
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    [treeView reloadData];
    [treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    self.treeView = treeView;
    [self.view addSubview:treeView];
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *raDO =  (RADataObject *)item;
    if (raDO.isParent) {
        return 0;
    }
    return [self cellHeightForItem:raDO orTitle:nil];
}


- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    return YES;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    cell.backgroundColor = UIColorFromRGB(0xF7F7F7);
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    RADataObject *raDO =  (RADataObject *)item;
    static NSString *CellIdentifier = @"Cell";
    MAMeasurementCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = (MAMeasurementCell *)[Util getCell:[MAMeasurementCell class] owner:self];
    }
    [cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name ]];
    if (raDO.isParent || raDO.isSubParent) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    if (raDO.isLastItem) {
        cell.viewSeparate.hidden = YES;
    }
    cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
    DLogInfo(@"h1: %f",cell.frame.size.height);
    return cell;
}

- (UIView*) createUIViewHeader:(BOOL) isParent isSubParent: (BOOL) isSubParent isSubOfSubParent:(BOOL) isSubOfSubParent withTitle: (NSString *) title {
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.treeView.frame.size.width + 1, MANAPP_MEASUREMENT_VIEW_HEADER_HEIGHT)] autorelease];
    //background
    UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:headerView.frame] autorelease];
    [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    UILabel *lblTitle = [[[UILabel alloc] initWithFrame:headerView.frame] autorelease];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.font = [UIFont fontWithName:kAppFont size:18];
    lblTitle.textColor = [UIColor blackColor];
    if (!isParent) {
        if (isSubParent){
            backgroundView.image = [UIImage imageNamed:@"preferenceSectionBg"];
        } else {
            lblTitle.textAlignment = NSTextAlignmentLeft;
            lblTitle.frame = CGRectMake(lblTitle.frame.origin.x + 10, lblTitle.frame.origin.y, lblTitle.frame.size.width - 20, [self cellHeightForItem:nil orTitle:title]);
            //        lblTitle.lineBreakMode = NSLineBreakByCharWrapping;
            lblTitle.numberOfLines = 5;
        }
        DLogInfo(@"height image: %f",backgroundView.frame.size.height);
        [headerView addSubview:backgroundView];
        lblTitle.text = title;
        [headerView addSubview:lblTitle];
    }
    return headerView;
}


- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.data count];
    }
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    return [data.children objectAtIndex:index];
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
    RADataObject *data = item;
    DLogInfo(@"select row %@",data.name);
    PartnerMeasurementItem *itemMeasurement  = [[DatabaseHelper sharedHelper] getPartnerMeasurementItem:data.itemID];
    if (itemMeasurement) {
        [self goToAddMeasurementView:itemMeasurement];
    }
}


//go to add item page
-(void)goToAddMeasurementView:(PartnerMeasurementItem *)item{
    AddMeasurementItemController *addItemViewController = [self getViewControllerByName:@"AddMeasurementItemController"];
    addItemViewController.measurementItem = item;
    [self nextTo:addItemViewController];
}

- (NSArray*) getItemsInCategory:(PartnerMeasurement*) measurement{
    return [[DatabaseHelper sharedHelper] getAllItemForPartnerMeasurement:measurement];
}

#pragma mark - data function
//reload the table view to show new update information
- (void)refreshMeasurementData
{
    if([[MASession sharedSession] currentPartner]){
        self.measurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
        [self.cachedDictionary removeAllObjects];
        [self.measurementTableView reloadData];
        
        self.nonEmptyMeasurements = [NSMutableArray array];
        for(PartnerMeasurement *measurement in self.measurements){
            NSArray *items = [self getItemsInCategory:measurement];
            if(items.count > 0){
                [self.nonEmptyMeasurements addObject:measurement];
            }
        }
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
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return self.measurements.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    PartnerMeasurement *measurement = [self.measurements objectAtIndex:section];
//    
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsInCategory:measurement];
//    return [items count];
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    //check the number of item, only show view if number of item is more than 0
//    PartnerMeasurement *measurement = [self.measurements objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsInCategory:measurement];
//    if(items.count > 0){
//        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, MANAPP_MEASUREMENT_VIEW_HEADER_HEIGHT)] autorelease];
//        
//        //background
//        UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:headerView.frame] autorelease];
//        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
//        backgroundView.image = [UIImage imageNamed:@"preferenceSectionBg"];
//        [headerView addSubview:backgroundView];
//        
//        //text
//        UILabel *lblTitle = [[[UILabel alloc] initWithFrame:headerView.frame] autorelease];
//        lblTitle.textAlignment = NSTextAlignmentCenter;
//        lblTitle.backgroundColor = [UIColor clearColor];
//        [lblTitle setFont:[UIFont fontWithName:kAppFont size:18]];
//        [lblTitle setTextColor:[UIColor blackColor]];
//        [headerView addSubview:lblTitle];
//        
//        lblTitle.text = measurement.name;
//        
//        return headerView;
//    }
//    else{
//        return nil;
//    }
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    PartnerMeasurement *measurement = [self.measurements objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsInCategory:measurement];
//    if(items.count > 0){
//        return MANAPP_MEASUREMENT_VIEW_HEADER_HEIGHT;
//    }
//    else{
//        return 0;
//    }
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    PartnerMeasurement *measurement = [self.measurements objectAtIndex:indexPath.section];
//    
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsInCategory:measurement];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    
//    PartnerMeasurementItem *item = [items objectAtIndex:indexPath.row];
//    
//    return [MAMeasurementCell cellHeightForItem:item];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"MAMeasurementCell";
//    MAMeasurementCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = (MAMeasurementCell *)[Util getCell:[MAMeasurementCell class] owner:self];
//    }
//    
//    // Configure the cell...
//    PartnerMeasurement *measurement = [self.measurements objectAtIndex:indexPath.section];
//    
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsInCategory:measurement];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    
//    PartnerMeasurementItem *item = [items objectAtIndex:indexPath.row];
//    cell.lblTitle.text = item.name;
//    [cell.lblTitle enlargeHeightToKeepFontSize];
//    if(indexPath.row == items.count - 1){
//        cell.viewSeparate.hidden = YES;
//        
//        if([measurement isEqual:self.nonEmptyMeasurements[self.nonEmptyMeasurements.count - 1]]){
//            cell.viewSeparate.hidden = NO;
//        }
//    }
//    else{
//        cell.viewSeparate.hidden = NO;
//    }
//    
//    return cell;
//}
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PartnerMeasurement *pMeasurement = [self.measurements objectAtIndex:indexPath.section];
//    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerMeasurement:pMeasurement];
//    PartnerMeasurementItem *item = [items objectAtIndex:indexPath.row];
//    [self goToAddMeasurementView:item];
//}

#pragma mark - KOAprocessbar delegate
-(void)didTouchKOAProgressBar:(KOAProgressBar *)processBar{
    [self showMessage:[[MAUserProcessManager sharedInstance] hintToGetOneHundred]];
}
@end
