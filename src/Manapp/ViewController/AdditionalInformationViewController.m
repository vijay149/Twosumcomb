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
#import "MAUserProcessManager.h"
#import "MAInformationCell.h"
#import "UILabel+Additions.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "LinkedHashMap.h"

@interface AdditionalInformationViewController ()<RATreeViewDelegate, RATreeViewDataSource>
-(void) initializeUI;

-(void) addItemClicked:(id)sender;

-(void) refreshInformationData;

-(void) goToAddInformationView:(PartnerInformationItem*) item;
- (void) goViewAddAdditionalItem;
//Tree view
- (void) initializeTreeView;
- (LinkedHashMap*) filterPartnerInformation: (NSMutableArray*) allData;
- (NSMutableArray*) filterPartnerInformationItem: (LinkedHashMap*) linkedHashMapParent;
@property (retain, nonatomic) RATreeView *treeView;
@property (retain, nonatomic) NSMutableArray *data;
@property (nonatomic, assign) BOOL firstTime;
@end

@implementation AdditionalInformationViewController
@synthesize cachedDictionary = _cachedDictionary;
@synthesize partnerInformation = _partnerInformation;
@synthesize informationTableView = _informationTableView;



- (void)dealloc {
    [_informationTableView release];
    [_partnerInformation release];
    [_cachedDictionary release];
    [_processBar release];
    [_lblProcess release];
    [_treeView release];
    [_data release];
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
    [self initializeUI];
    
    [self initializeData];
    [self initializeTreeView];
    if (iOS7OrLater) {
        self.firstTime = YES;
    } else {
        [self goViewAddAdditionalItem];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS7OrLater) {
        if (self.firstTime) {
            self.firstTime = NO;
            [self goViewAddAdditionalItem];
        }
    }

}

- (void) goViewAddAdditionalItem {
    //if this partner don't have any data, push the add more item view
    // check if there is anydata, if not, then move to add information view (after alert)
    if([[MASession sharedSession] currentPartner]){
        NSArray *partnerInformationItems = [[DatabaseHelper sharedHelper] getAllItemInformationForPartner:[[MASession sharedSession] currentPartner]];
        if([partnerInformationItems count] == 0){
            [self showMessage:[NSString stringWithFormat:LSSTRING(@"Select a category and start entering infomation about %@"),[MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:nil tag:MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG];
            AddAdditionalItemViewController *addItemViewController = NEW_VC(AddAdditionalItemViewController);
            [self.navigationController pushViewController:addItemViewController animated:NO];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initializeData];
    [self.treeView reloadData];
    [self.navigationController setNavigationBarHidden:YES];
//    [self refreshInformationData];
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
-(void) initializeUI {
    // Setup navigation bar ( with PLUS button to go to another page)
    [self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(back)];
    [self createRightNavigationWithTitle:MA_ADD_BUTTON_TEXT action:@selector(addItemClicked:)];
    // page title
    self.title = LSSTRING(@"Additional Information");
    //add gesture swipe to go back
    [self addSwipeBackGesture];
}

//go to add item page
-(void) goToAddInformationView:(PartnerInformationItem*) item{
    AddAdditionalItemViewController *addItemViewController = [self getViewControllerByName:@"AddAdditionalItemViewController"];
    addItemViewController.informationItem = item;
    [self nextTo:addItemViewController];
}

- (NSArray*) getItemsInCategory:(PartnerInformation*) information{
    return [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:information];
}

#pragma mark - data function
//reload the table view to show new update information
- (void)refreshInformationData
{
    if([[MASession sharedSession] currentPartner]){
        self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
        [self.cachedDictionary removeAllObjects];
        [self.informationTableView reloadData];
        
        self.nonEmptyPartnerInformation = [NSMutableArray array];
        for(PartnerInformation *infor in self.partnerInformation){
            NSArray *items = [self getItemsInCategory:infor];
            if(items.count > 0){
                [self.nonEmptyPartnerInformation addObject:infor];
            }
        }
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

// filter information use treeview
- (LinkedHashMap*) filterPartnerInformation: (NSMutableArray*) allData {
    LinkedHashMap* lhm = [[[LinkedHashMap alloc] init] autorelease];
    BOOL flag = NO;
    for (PartnerInformation *infor in allData) {
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self getItemsInCategory:infor]];
        if (lhm.allKeys.count == 0) {
            DLogInfo(@"parentCategory.name %@",infor.parentCategory.name);
            [lhm insertValue:items withKey:infor.parentCategory.name];
            DLogInfo(@"preference name %@",infor.name);
        } else {
            for (NSString *key in [lhm allKeys]) {
                if ([key isEqual:infor.parentCategory.name]) { // update
                    DLogInfo(@"parentCategory.name %@",infor.parentCategory.name);
                    DLogInfo(@"preference name %@",infor.name);
                    NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
                    NSLog(@"list 1: %@",itemsFromHashMap.description);
                    [itemsFromHashMap addObjectsFromArray:items];
                    NSLog(@"list 2: %@",[[lhm valueForKey:key] description]);
                    flag = YES;
                }
            }
            if (!flag) { // them moi.
                DLogInfo(@"parentCategory.name %@",infor.parentCategory.name);
                DLogInfo(@"preference name %@",infor.name);
                [lhm insertValue:items withKey:infor.parentCategory.name];
                flag = NO;
            } else {
                flag = NO;
            }
        }
    }
    return lhm;
}
// filter infomation item use treeview
- (NSMutableArray*) filterPartnerInformationItem: (LinkedHashMap*) linkedHashMapParent {
    NSMutableArray *listObject = [NSMutableArray array];
    if (linkedHashMapParent.allKeys.count > 0) {
        BOOL isTrue = NO;
        for (NSString *key in [linkedHashMapParent allKeys]) {
            DLogInfo(@"key: %@",key);// parent category
            NSMutableArray *itemsFromHashMap = [linkedHashMapParent valueForKey:key];
            LinkedHashMap* linkedHashMapSub = [[[LinkedHashMap alloc] init] autorelease];
            for (PartnerInformationItem *infoItem in itemsFromHashMap) {
                if (linkedHashMapSub.allKeys.count == 0) {
                    DLogInfo(@"preItem.category.name %@",infoItem.information.name);
                    NSMutableArray *infoItems = [NSMutableArray array];
                    [infoItems addObject:infoItem];
                    [linkedHashMapSub insertValue:infoItems withKey:infoItem.information.name];
                } else {
                    for (NSString *keySub in [linkedHashMapSub allKeys]) {
                        if ([keySub isEqual:infoItem.information.name]) { // update
                            DLogInfo(@"preItem.category.name %@",infoItem.information.name);
                            NSMutableArray *itemsFromHashMap = [linkedHashMapSub valueForKey:keySub];
                            NSLog(@"list 1: %@",itemsFromHashMap.description);
                            [itemsFromHashMap addObject:infoItem];
                            NSLog(@"list 2: %@",[[linkedHashMapSub valueForKey:keySub] description]);
                            isTrue = YES;
                        }
                    }
                    if (!isTrue) { // them moi.
                        DLogInfo(@"preItem.category.name %@",infoItem.information.name);
                        NSMutableArray *preItems = [NSMutableArray array];
                        [preItems addObject:infoItem];
                        [linkedHashMapSub insertValue:preItems withKey:infoItem.information.name];
                        isTrue = NO;
                    } else {
                        isTrue = NO;
                    }
                }
            }
            NSMutableArray *listSubCategory = [NSMutableArray array];
            if (linkedHashMapSub.allValues.count > 0) {
                for (NSString *keyItem in [linkedHashMapSub allKeys]) {
                    NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kInformation arrayInput:[linkedHashMapSub valueForKey:keyItem]];
                    RADataObject *raDOSubOfCategory = [RADataObject dataObjectWithName:keyItem children:items isParent:NO isSubParent:NO isSubOfSubParent: YES isPreference:NO isLike:NO];
                    [listSubCategory addObject:raDOSubOfCategory];
                }
            }
            RADataObject *raDOCategory = [RADataObject dataObjectWithName:key children:listSubCategory isParent:NO isSubParent:YES isSubOfSubParent: NO isPreference:NO isLike:NO];
            [listObject addObject:raDOCategory];
        }
    }
    return listObject;
}

//load all data
- (void) initializeData {
    if (![[MASession sharedSession] currentPartner]) {
        return;
    }
    self.data = [NSMutableArray array];
    
    self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
    NSMutableArray *allData = [NSMutableArray array];
    for (PartnerInformation *infor  in self.partnerInformation) {
        NSArray *items = [self getItemsInCategory:infor];
        if (items && items.count > 0) {
            [allData addObject:infor];
        }
    }
    
    LinkedHashMap* lhm = [self filterPartnerInformation:allData];
    NSMutableArray *listObject = [self filterPartnerInformationItem: lhm];
    
    if (listObject && listObject.count > 0) {
        RADataObject *preference = [RADataObject dataObjectWithName:@"Other info" children:listObject isParent:YES isSubParent:NO  isSubOfSubParent: NO isPreference:NO isLike:NO];
        [self.data addObject:preference];
    }
    
    // Check exisiting information
    if ([[MASession sharedSession] currentPartner].information.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultInformationForPartner:[[MASession sharedSession] currentPartner]];
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
//    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
//    [cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name ]];
//    DLogInfo(@"h: %f",cell.frame.size.height);
//    if (raDO.isParent || raDO.isSubOfSubParent || raDO.isSubParent) {
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    } else {
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    }
//    cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
//    return cell;
    static NSString *CellIdentifier = @"Cell";
    MAInformationCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = (MAInformationCell *)[Util getCell:[MAInformationCell class] owner:self];
    }
    [cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name ]];
    if (raDO.isParent || raDO.isSubOfSubParent || raDO.isSubParent) {
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
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.treeView.frame.size.width + 1, MANAPP_ADDITIONAL_VIEW_HEADER_HEIGHT)] autorelease];
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
        } else if (isSubOfSubParent){
            backgroundView.image = [UIImage imageNamed:@"header_background_sub_category"];
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
    PartnerInformationItem *itemInfo  = [[DatabaseHelper sharedHelper] getItemPartnerInformationItem:data.itemID];
    if (itemInfo) {
        [self goToAddInformationView:itemInfo];
    }
    
}




//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return self.partnerInformation.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    PartnerInformation *information = [self.partnerInformation objectAtIndex:section];
//    NSArray *inforItems = [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:information];
//    return inforItems.count;
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    //check the number of item, only show view if number of item is more than 0
//    PartnerInformation *information = [self.partnerInformation objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:information];
//    if(items.count > 0){
//        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, MANAPP_ADDITIONAL_VIEW_HEADER_HEIGHT)] autorelease];
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
//        if(information.parentCategory != nil)
//        {
//            //display the category name together with the parent's name
//            lblTitle.text = [NSString stringWithFormat:@"%@ - %@",information.parentCategory.name,information.name];
//        }
//        else{
//            lblTitle.text = information.name;
//        }
//        
//        return headerView;
//    }
//    else{
//        return nil;
//    }
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    PartnerInformation *information = [self.partnerInformation objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsInCategory:information];
//    if(items.count > 0){
//        return MANAPP_ADDITIONAL_VIEW_HEADER_HEIGHT;
//    }
//    else{
//        return 0;
//    }
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    PartnerInformation *information = [self.partnerInformation objectAtIndex:indexPath.section];
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsInCategory:information];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    PartnerInformationItem *item = [items objectAtIndex:indexPath.row];
//    
//    return [MAInformationCell cellHeightForItem:item];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"MAInformationCell";
//    
//    MAInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = (MAInformationCell *)[Util getCell:[MAInformationCell class] owner:self];
//    }
//    
//    // Configure the cell...
//    PartnerInformation *information = [self.partnerInformation objectAtIndex:indexPath.section];
//    
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsInCategory:information];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    
//    PartnerInformationItem *item = [items objectAtIndex:indexPath.row];
//    cell.lblTitle.text = item.name;
//    [cell.lblTitle enlargeHeightToKeepFontSize];
//    if(indexPath.row == items.count - 1){
//        cell.viewSeparate.hidden = YES;
//        
//        if([information isEqual:self.nonEmptyPartnerInformation[self.nonEmptyPartnerInformation.count - 1]]){
//            cell.viewSeparate.hidden = NO;
//        }
//    }
//    else{
//        cell.viewSeparate.hidden = NO;
//    }
//    
//    return cell;
//    
//}
//
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PartnerInformation *pInformation = [self.partnerInformation objectAtIndex:indexPath.section];
//    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:pInformation];
//    PartnerInformationItem *item = [items objectAtIndex:indexPath.row];
//    [self goToAddInformationView:item];
//}

#pragma mark - KOAprocessbar delegate
-(void)didTouchKOAProgressBar:(KOAProgressBar *)processBar{
    [self showMessage:[[MAUserProcessManager sharedInstance] hintToGetOneHundred]];
}
@end
