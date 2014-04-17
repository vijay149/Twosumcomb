//
//  PreferenceViewController.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "PreferenceViewController.h"
#import "Partner.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "PreferenceItem.h"
#import "PreferenceCategory.h"
#import "AddPreferenceItemViewController.h"
#import "MAPreferenceCell.h"
#import "MAUserProcessManager.h"
#import "UILabel+Additions.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "LinkedHashMap.h"
@interface PreferenceViewController ()<RATreeViewDelegate, RATreeViewDataSource>

- (void) initialize;
- (void) initializeData;

- (void) reloadViewByState:(MAPreferenceViewState) viewState;
- (void) goToAddItemView:(PreferenceItem *) item;
- (NSArray*) getItemsOfPreference:(PreferenceCategory*) preference;

- (void) addItemClicked:(id)sender;
- (void) goViewAddPreference;
//Tree view
- (void) initializeTreeView;
- (LinkedHashMap*) filterParentCategories:(NSMutableArray*) allData;
- (NSMutableArray*) filterSubCategories:(LinkedHashMap*) linkedHashMapParentCategories;
@property (retain, nonatomic) RATreeView *treeView;
@property (retain, nonatomic) NSMutableArray *data;
@property (nonatomic, assign) BOOL firstTime;
@end

@implementation PreferenceViewController
@synthesize tableViewPreference = _tableViewPreference;
@synthesize cachedDictionary = _cachedDictionary;
@synthesize preferences = _preferences;
@synthesize preferenceViewState = _preferenceViewState;
@synthesize btnLike = _btnLike;
@synthesize btnDislike = _btnDislike;

- (void)dealloc {
    [_tableViewPreference release];
    [_cachedDictionary release];
    [_preferences release];
    [_btnDislike release];
    [_btnLike release];
    [_btnAllPreference release];
    [_processBar release];
    [_lblProcess release];
    [_data release];
    [_treeView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //init the UI
    [self initialize];
    
    //init the data
    
    [self initializeData];
    [self initializeTreeView];
    
    if (iOS7OrLater) {
        self.firstTime = YES;
    } else {
        [self goViewAddPreference];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.preferenceViewState = MAPreferenceViewStateShowAll;
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (iOS7OrLater) {
        if (self.firstTime) {
            self.firstTime = NO;
            [self goViewAddPreference];
        }
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //reload the data
    [self initializeData];
    [self.treeView reloadData];
//    [self reloadViewByState:self.preferenceViewState];
    [self loadProgressBar];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - init functions
-(void) initialize{
    [self.navigationController setNavigationBarHidden:YES];
    [self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(back)];
    [self createRightNavigationWithTitle:MA_ADD_BUTTON_TEXT action:@selector(addItemClicked:)];
    //gesture
    [self addSwipeBackGesture];
}

//filterParentCategories use for treeview
- (LinkedHashMap*) filterParentCategories:(NSMutableArray*) allData {
    LinkedHashMap* lhm = [[[LinkedHashMap alloc] init] autorelease];
    BOOL flag = NO;
    for (PreferenceCategory *preference in allData) {
        //NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kPreference arrayInput:[self getItemsOfPreference:preference]];
        NSMutableArray *items = [NSMutableArray arrayWithArray:[self getItemsOfPreference:preference]];
        if (lhm.allKeys.count == 0) {
            DLogInfo(@"parentCategory.name %@",preference.parentCategory.name);
            [lhm insertValue:items withKey:preference.parentCategory.name];
            DLogInfo(@"preference name %@",preference.name);
        } else {
            for (NSString *key in [lhm allKeys]) {
                if ([key isEqual:preference.parentCategory.name]) { // update
                    DLogInfo(@"parentCategory.name %@",preference.parentCategory.name);
                    DLogInfo(@"preference name %@",preference.name);
                    NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
                    NSLog(@"list 1: %@",itemsFromHashMap.description);
                    [itemsFromHashMap addObjectsFromArray:items];
                    NSLog(@"list 2: %@",[[lhm valueForKey:key] description]);
                    flag = YES;
                }
            }
            if (!flag) { // them moi.
                DLogInfo(@"parentCategory.name %@",preference.parentCategory.name);
                DLogInfo(@"preference name %@",preference.name);
                [lhm insertValue:items withKey:preference.parentCategory.name];
                flag = NO;
            } else {
                flag = NO;
            }
        }
    }
    return lhm;
}

//filterSubCategories use for treeview
- (NSMutableArray*) filterSubCategories:(LinkedHashMap*) linkedHashMapParentCategories {
    NSMutableArray *listObject = [NSMutableArray array];
    if (linkedHashMapParentCategories.allKeys.count > 0) {
        BOOL isTrue = NO;
        for (NSString *key in [linkedHashMapParentCategories allKeys]) {
            DLogInfo(@"key: %@",key);// parent category
            NSMutableArray *itemsFromHashMap = [linkedHashMapParentCategories valueForKey:key];
            LinkedHashMap* linkedHashMapSub = [[[LinkedHashMap alloc] init] autorelease];
            for (PreferenceItem *preItem in itemsFromHashMap) {
                if (linkedHashMapSub.allKeys.count == 0) {
                    DLogInfo(@"preItem.category.name %@",preItem.category.name);
                    NSMutableArray *preItems = [NSMutableArray array];
                    [preItems addObject:preItem];
                    [linkedHashMapSub insertValue:preItems withKey:preItem.category.name];
                } else {
                    for (NSString *keySub in [linkedHashMapSub allKeys]) {
                        if ([keySub isEqual:preItem.category.name]) { // update
                            DLogInfo(@"preItem.category.name %@",preItem.category.name);
                            NSMutableArray *itemsFromHashMap = [linkedHashMapSub valueForKey:keySub];
                            NSLog(@"list 1: %@",itemsFromHashMap.description);
                            [itemsFromHashMap addObject:preItem];
                            NSLog(@"list 2: %@",[[linkedHashMapSub valueForKey:keySub] description]);
                            isTrue = YES;
                        }
                    }
                    if (!isTrue) { // them moi.
                        DLogInfo(@"preItem.category.name %@",preItem.category.name);
                        NSMutableArray *preItems = [NSMutableArray array];
                        [preItems addObject:preItem];
                        [linkedHashMapSub insertValue:preItems withKey:preItem.category.name];
                        isTrue = NO;
                    } else {
                        isTrue = NO;
                    }
                }
            }
            NSMutableArray *listSubCategory = [NSMutableArray array];
            if (linkedHashMapSub.allValues.count > 0) {
                for (NSString *keyItem in [linkedHashMapSub allKeys]) {
                    NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kPreference arrayInput:[linkedHashMapSub valueForKey:keyItem]];
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
    self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceForPartner:[[MASession sharedSession] currentPartner]];
    NSMutableArray *allData = [NSMutableArray array];
    for (PreferenceCategory *preItem in self.preferences) {
        NSArray *items = [self getItemsOfPreference:preItem];
        if (items && items.count > 0) {
            [allData addObject:preItem];
        }
    }
    
    LinkedHashMap* lhm = [self filterParentCategories:allData];
    NSMutableArray *listObject = [self filterSubCategories:lhm];
    
    if (listObject && listObject.count > 0) {
        RADataObject *preference = [RADataObject dataObjectWithName:@"Likes & Dislikes" children:listObject isParent:YES isSubParent:NO  isSubOfSubParent: NO isPreference:NO isLike:NO];
        [self.data addObject:preference];
    }
    
    // Check exisiting Preferences
    if ([[MASession sharedSession] currentPartner].preferences.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultPreferenceForPartner:[[MASession sharedSession] currentPartner]];
    }
}

- (void) goViewAddPreference {
    // check if there is anydata, if not, then move to add preference view
    if([[MASession sharedSession] currentPartner]){
        NSArray *preferenceItems = [[DatabaseHelper sharedHelper] getAllItemPreferenceForPartner:[[MASession sharedSession] currentPartner]];
        if([preferenceItems count] == 0){
            [self showMessage:[NSString stringWithFormat:@"Please select a category and start entering the likes and dislikes for %@.",[MASession sharedSession].currentPartner.name] title:kAppName cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:nil tag:MANAPP_PREFERENCE_VIEW_DATA_EMPTY_ALERT_TAG];
            
            AddPreferenceItemViewController *addItemViewController = NEW_VC(AddPreferenceItemViewController);
            [self.navigationController pushViewController:addItemViewController animated:NO];
        }
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

    DLogInfo(@"position %d",treeNodeInfo.positionInSiblings);
    if (raDO.isPreference) {
        static NSString *CellIdentifier = @"Cell";
        MAPreferenceCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = (MAPreferenceCell *)[Util getCell:[MAPreferenceCell class] owner:self];
           
        }
        if(raDO.isLike){
            cell.imageRight.image = [UIImage imageNamed:@"btnLikeSmallSelected"];
        } else {
            cell.imageRight.image = [UIImage imageNamed:@"btnDislikeSmallSelected"];
        }
        [cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name ]];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
        if (raDO.isLastItem) {
            cell.viewSeparate.hidden = YES;
        }
        return cell;
    } else {
        UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
        [cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name ]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
        return cell;
    }
}

- (UIView*) createUIViewHeader:(BOOL) isParent isSubParent: (BOOL) isSubParent isSubOfSubParent:(BOOL) isSubOfSubParent withTitle: (NSString *) title {
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.treeView.frame.size.width + 1, MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT)] autorelease];
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
    PreferenceItem *itemPre  = [[DatabaseHelper sharedHelper] getItemPreference:data.itemID];
    if (itemPre) {
        [self goToAddItemView:itemPre];
    }
    
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

//reload the view depend on the current state
- (void) reloadViewByState:(MAPreferenceViewState) viewState{
//    //change button state and data list
//    if(self.preferenceViewState == MAPreferenceViewStateShowAll){
//
//    }
//    else if(self.preferenceViewState == MAPreferenceViewStateHideAll){
//
//    }
//    else if(self.preferenceViewState == MAPreferenceViewStateLikeOnly){
//
//    }
//    else if(self.preferenceViewState == MAPreferenceViewStateDislikeOnly){
//
//    }
//    
//    if ([[MASession sharedSession] currentPartner]) {
//        self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceForPartner:[[MASession sharedSession] currentPartner]];
//    }
//    
//    self.nonEmptyPreferences = [NSMutableArray array];
//    for(PreferenceCategory *preference in self.preferences){
//        NSArray *items = [self getItemsOfPreference:preference];
//        if(items.count > 0){
//            [self.nonEmptyPreferences addObject:preference];
//        }
//    }
//    
//    //clear cache
//    [self.cachedDictionary removeAllObjects];
//    
    //reload table data
//    [self.tableViewPreference reloadData];
    [self initializeData];
    [self.treeView reloadData];
}

#pragma mark - private functions

//push add item view
- (void) goToAddItemView:(PreferenceItem *)item{
    AddPreferenceItemViewController *addItemViewController = [self getViewControllerByName:@"AddPreferenceItemViewController"];
    addItemViewController.preferenceItem = item;
    [self nextTo:addItemViewController];
}

// get items of the selected preference
- (NSArray*) getItemsOfPreference:(PreferenceCategory*) preference{
    if(self.preferenceViewState == MAPreferenceViewStateShowAll){
        return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference];
    }
    else if(self.preferenceViewState == MAPreferenceViewStateLikeOnly){
        return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference isLike:TRUE];
    }
    else if(self.preferenceViewState == MAPreferenceViewStateDislikeOnly){
        return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference isLike:FALSE];
    }
    else{
        return [[[NSArray alloc] init] autorelease];
    }
}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    return self.preferences.count;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    PreferenceCategory *preference = [self.preferences objectAtIndex:section];
//    
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsOfPreference:preference];
//    return [items count];
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    //check the number of item, only show view if number of item is more than 0
//    PreferenceCategory *preference = [self.preferences objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsOfPreference:preference];
//    if(items.count > 0){
//        UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT)] autorelease];
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
//        if(preference.parentCategory != nil)
//        {
//            //display the category name together with the parent's name
//            lblTitle.text = [NSString stringWithFormat:@"%@ - %@",preference.parentCategory.name,preference.name];
//        }
//        else{
//            lblTitle.text = preference.name;
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
//    PreferenceCategory *preference = [self.preferences objectAtIndex:section];
//    // depend on which type of preference(like or dislike)
//    NSArray *items = [self getItemsOfPreference:preference];
//    if(items.count > 0){
//        return MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT;
//    }
//    else{
//        return 0;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    MAPreferenceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = (MAPreferenceCell *)[Util getCell:[MAPreferenceCell class] owner:self];
//    }
//    
//    // Configure the cell...
//    PreferenceCategory *pPreference = [self.preferences objectAtIndex:indexPath.section];
//    
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsOfPreference:pPreference];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    
//    PreferenceItem *item = [items objectAtIndex:indexPath.row];
//    
//    if(item.isLike.boolValue){
////        cell.imageRight.image = [UIImage imageNamed:@"btnLikeSmall"];
//        cell.imageRight.image = [UIImage imageNamed:@"btnLikeSelected"];// change by request from customer : MA-249
//    }
//    else{
////        cell.imageRight.image = [UIImage imageNamed:@"btnDislikeSmall"];
//        cell.imageRight.image = [UIImage imageNamed:@"btnDislikeSmallSelected"];// change by request from customer : MA-249
//    }
//    
//    cell.lblTitle.text = item.name;
//    [cell.lblTitle enlargeHeightToKeepFontSize];
//    
//    if(indexPath.row == items.count - 1){
//        cell.viewSeparate.hidden = YES;
//        if([pPreference isEqual:self.nonEmptyPreferences[self.nonEmptyPreferences.count - 1]]){
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
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    PreferenceCategory *pPreference = [self.preferences objectAtIndex:indexPath.section];
//    
//    //using cached help us to increase speed
//    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
//    NSArray *items = [self.cachedDictionary objectForKey:key];
//    
//    if (!items) {
//        items = [self getItemsOfPreference:pPreference];
//        [self.cachedDictionary setObject:items forKey:key];
//    }
//    
//    PreferenceItem *item = [items objectAtIndex:indexPath.row];
//    
//    return [MAPreferenceCell cellHeightForItem:item];
//}
//#pragma mark - Table view delegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    PreferenceCategory *pPreference = [self.preferences objectAtIndex:indexPath.section];
//    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:pPreference];
//    PreferenceItem *item = [items objectAtIndex:indexPath.row];
//    
//    [self goToAddItemView:item];
//}

#pragma mark - event handler
- (void) addItemClicked:(id)sender{
    [self goToAddItemView:nil];
}

- (IBAction)allPreferenceButton_touchUpInside:(id)sender{
    //pass YES as we click like button
    self.preferenceViewState = MAPreferenceViewStateShowAll;
    
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmall"] forState:UIControlStateNormal];
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmall"] forState:UIControlStateHighlighted];
    
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmall"] forState:UIControlStateNormal];
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmall"] forState:UIControlStateHighlighted];
    
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreferenceSelected"] forState:UIControlStateNormal];
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreferenceSelected"] forState:UIControlStateHighlighted];
    
    //reload view
    [self reloadViewByState:self.preferenceViewState];
}

- (IBAction)likeButton_touchUpInside:(id)sender{
    //pass YES as we click like button
    self.preferenceViewState = MAPreferenceViewStateLikeOnly;
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmallSelected"] forState:UIControlStateNormal];
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmallSelected"] forState:UIControlStateHighlighted];
    
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmall"] forState:UIControlStateNormal];
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmall"] forState:UIControlStateHighlighted];
    
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreference"] forState:UIControlStateNormal];
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreference"] forState:UIControlStateHighlighted];
    
    //reload view
    [self reloadViewByState:self.preferenceViewState];
}

- (IBAction) dislikeButton_touchUpInside:(id)sender{
    //pass NO as we click dislike button
    self.preferenceViewState = MAPreferenceViewStateDislikeOnly;
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmallSelected"] forState:UIControlStateNormal];
    [self.btnDislike setImage:[UIImage imageNamed:@"btnDislikeSmallSelected"] forState:UIControlStateHighlighted];
    
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmall"] forState:UIControlStateNormal];
    [self.btnLike setImage:[UIImage imageNamed:@"btnLikeSmall"] forState:UIControlStateHighlighted];
    
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreference"] forState:UIControlStateNormal];
    [self.btnAllPreference setImage:[UIImage imageNamed:@"btnAllPreference"] forState:UIControlStateHighlighted];
    
    //reload view
    [self reloadViewByState:self.preferenceViewState];
}

#pragma mark - alert view delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // go to add preference view if user didn't add any data for the preference table yet
    if(alertView.tag == MANAPP_PREFERENCE_VIEW_DATA_EMPTY_ALERT_TAG){
        [self goToAddItemView:nil];
    }
}

#pragma mark - KOAprocessbar delegate
-(void)didTouchKOAProgressBar:(KOAProgressBar *)processBar{
    [self showMessage:[[MAUserProcessManager sharedInstance] hintToGetOneHundred]];
}
@end
