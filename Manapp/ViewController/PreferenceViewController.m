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

@interface PreferenceViewController ()

@property (nonatomic, retain) UIButton *btnLike;
@property (nonatomic, retain) UIButton *btnDislike;

- (void) initialize;
- (void) initializeData;

- (void) showPreferenceButtons;
- (void) hidePreferenceButtons;
- (void) togglePreferenceState:(BOOL) likeClicked;
- (void) reloadViewByState:(MAPreferenceViewState) viewState;
- (void) goToAddItemView:(PreferenceItem *) item;
- (NSArray*) getItemsOfPreference:(PreferenceCategory*) preference;

- (void) addItemClicked:(id)sender;
- (void) likeButton_touchUpInside:(id)sender;
- (void) dislikeButton_touchUpInside:(id)sender;

@end

@implementation PreferenceViewController
@synthesize tableViewPreference = _tableViewPreference;
@synthesize cachedDictionary = _cachedDictionary;
@synthesize preferences = _preferences;
@synthesize preferenceViewState = _preferenceViewState;
@synthesize btnLike = _btnLike;
@synthesize btnDislike = _btnDislike;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.preferenceViewState = MAPreferenceViewStateShowAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //init the UI
    [self initialize];
    
    //init the data
    [self initializeData];
}

-(void)viewWillAppear:(BOOL)animated{
    //show the preference button
    [self showPreferenceButtons];
    
    //reload the data
    [self reloadViewByState:self.preferenceViewState];
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    //hide the preference button
    [self hidePreferenceButtons];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_tableViewPreference release];
    [_cachedDictionary release];
    [_preferences release];
    [_btnDislike release];
    [_btnLike release];
    [super dealloc];
}

#pragma mark - init functions
-(void) initialize{
    //show the navigation bar
    [self.navigationController setNavigationBarHidden:NO];
    
    //navigation buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClicked:)];
    
    // preference buttons
    self.btnLike = [[UIButton alloc] initWithFrame:CGRectMake(110, 20, 40, 37)];
    [self.btnLike setBackgroundImage:[UIImage imageNamed:@"btnLike"]forState:UIControlStateNormal];
    [self.btnLike addTarget:self action:@selector(likeButton_touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btnDislike = [[UIButton alloc] initWithFrame:CGRectMake(151, 27, 40, 37)];
    [self.btnDislike setBackgroundImage:[UIImage imageNamed:@"btnDislike"]forState:UIControlStateNormal];
    [self.btnDislike addTarget:self action:@selector(dislikeButton_touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    //gesture
    [self addSwipeBackGesture];
}

//load all data
- (void) initializeData{
    // Get current partner's preference data
    if ([[MASession sharedSession] currentPartner]) {
        self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    // Check exisiting measurements
    if ([[MASession sharedSession] currentPartner].preferences.count == 0) {
        [[DatabaseHelper sharedHelper] initDefaultPreferenceForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    // Others
    self.cachedDictionary = [NSMutableDictionary dictionary];
    
    // check if there is anydata, if not, then move to add preference view
    if([[MASession sharedSession] currentPartner]){
        NSArray *preferenceItems = [[DatabaseHelper sharedHelper] getAllItemPreferenceForPartner:[[MASession sharedSession] currentPartner]];
        if([preferenceItems count] == 0){
            [self showMessage:@"You don't have any data yet, please input some data first." title:@"MANAPP" cancelButtonTitle:@"OK" otherButtonTitle:nil delegate:self tag:MANAPP_PREFERENCE_VIEW_DATA_EMPTY_ALERT_TAG];
        }
    }
}

//display the preference buttons on the navigation bar
- (void) showPreferenceButtons{
    //only add the buttons to the navigation bar if it wasn't added before
    if(![self.navigationController.view.subviews containsObject:self.btnLike]){
        [self.navigationController.view addSubview:self.btnLike];
    }
    
    if(![self.navigationController.view.subviews containsObject:self.btnDislike]){
        [self.navigationController.view addSubview:self.btnDislike];
    }
}

//hide the preference buttons on the navigation bar
- (void) hidePreferenceButtons{
    //only remove the buttons to the navigation bar if it was added before
    if([self.navigationController.view.subviews containsObject:self.btnLike]){
        [self.btnLike removeFromSuperview];
    }
    
    if([self.navigationController.view.subviews containsObject:self.btnDislike]){
        [self.btnDislike removeFromSuperview];
    }
}

//reload the view depend on the current state
- (void) reloadViewByState:(MAPreferenceViewState) viewState{
    //change button state and data list
    if(self.preferenceViewState == MAPreferenceViewStateShowAll){
        [self.btnLike setBackgroundImage:[UIImage imageNamed:@"btnLike"]forState:UIControlStateNormal];
        [self.btnDislike setBackgroundImage:[UIImage imageNamed:@"btnDislike"]forState:UIControlStateNormal];
    }
    else if(self.preferenceViewState == MAPreferenceViewStateHideAll){
        [self.btnLike setBackgroundImage:[UIImage imageNamed:@"btnLike-deactive"]forState:UIControlStateNormal];
        [self.btnDislike setBackgroundImage:[UIImage imageNamed:@"btnDislike-deactive"]forState:UIControlStateNormal];
    }
    else if(self.preferenceViewState == MAPreferenceViewStateLikeOnly){
        [self.btnLike setBackgroundImage:[UIImage imageNamed:@"btnLike"]forState:UIControlStateNormal];
        [self.btnDislike setBackgroundImage:[UIImage imageNamed:@"btnDislike-deactive"]forState:UIControlStateNormal];
    }
    else if(self.preferenceViewState == MAPreferenceViewStateDislikeOnly){
        [self.btnLike setBackgroundImage:[UIImage imageNamed:@"btnLike-deactive"]forState:UIControlStateNormal];
        [self.btnDislike setBackgroundImage:[UIImage imageNamed:@"btnDislike"]forState:UIControlStateNormal];
    }
    
    if ([[MASession sharedSession] currentPartner]) {
        self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceForPartner:[[MASession sharedSession] currentPartner]];
    }
    
    //clear cache
    [self.cachedDictionary removeAllObjects];
    
    //reload table data
    [self.tableViewPreference reloadData];
}

#pragma mark - private functions
//toggle when click on the preference buttons
-(void) togglePreferenceState:(BOOL) likeClicked{
    //if we click the like button
    if(likeClicked){
        //if we are in the showall state, we will hide all like items
        if(self.preferenceViewState == MAPreferenceViewStateShowAll){
            self.preferenceViewState = MAPreferenceViewStateDislikeOnly;
        }
        //if we are in the hide all state, we will show all like items only
        else if(self.preferenceViewState == MAPreferenceViewStateHideAll){
            self.preferenceViewState = MAPreferenceViewStateLikeOnly;
        }
        //if we are in the show dislike state, we will show all items
        else if(self.preferenceViewState == MAPreferenceViewStateDislikeOnly){
            self.preferenceViewState = MAPreferenceViewStateShowAll;
        }
        //if we are in the show like state, we will hide all items
        else if(self.preferenceViewState == MAPreferenceViewStateLikeOnly){
            self.preferenceViewState = MAPreferenceViewStateHideAll;
        }
    }
    else{
        //if we are in the showall state, we will hide all dislike items
        if(self.preferenceViewState == MAPreferenceViewStateShowAll){
            self.preferenceViewState = MAPreferenceViewStateLikeOnly;
        }
        //if we are in the hide all state, we will show all dislike items only
        else if(self.preferenceViewState == MAPreferenceViewStateHideAll){
            self.preferenceViewState = MAPreferenceViewStateDislikeOnly;
        }
        //if we are in the show like state, we will show all items
        else if(self.preferenceViewState == MAPreferenceViewStateLikeOnly){
            self.preferenceViewState = MAPreferenceViewStateShowAll;
        }
        //if we are in the show dislike state, we will hide all items
        else if(self.preferenceViewState == MAPreferenceViewStateDislikeOnly){
            self.preferenceViewState = MAPreferenceViewStateHideAll;
        }
    }
}

//push add item view
- (void) goToAddItemView:(PreferenceItem *)item{
    AddPreferenceItemViewController *addItemViewController = [self getViewControllerByName:@"AddPreferenceItemViewController"];
    addItemViewController.preferenceItem = item;
    [self.navigationController pushViewController:addItemViewController animated:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.preferences.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    PreferenceCategory *preference = [self.preferences objectAtIndex:section];
    
    // depend on which type of preference(like or dislike)
    NSArray *items = [self getItemsOfPreference:preference];
    return [items count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PreferenceCategory *preference = [self.preferences objectAtIndex:section];
    NSArray *items = [self getItemsOfPreference:preference];
    if (items.count > 0) {
        if(preference.parentCategory != nil)
        {
            //display the category name together with the parent's name
            return [NSString stringWithFormat:@"%@ - %@",preference.parentCategory.name,preference.name];
        }
        else{
            return preference.name;
        }
        
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
    PreferenceCategory *pPreference = [self.preferences objectAtIndex:indexPath.section];
    
    //using cached help us to increase speed
    NSNumber *key = [NSNumber numberWithInteger:indexPath.section];
    NSArray *items = [self.cachedDictionary objectForKey:key];
    
    if (!items) {
        items = [self getItemsOfPreference:pPreference];
        [self.cachedDictionary setObject:items forKey:key];
    }
    
    PreferenceItem *item = [items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PreferenceCategory *pPreference = [self.preferences objectAtIndex:indexPath.section];
    NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:pPreference];
    PreferenceItem *item = [items objectAtIndex:indexPath.row];
    
    [self goToAddItemView:item];
}

#pragma mark - event handler
- (void) addItemClicked:(id)sender{
    [self goToAddItemView:nil];
}

- (void) likeButton_touchUpInside:(id)sender{
    //pass YES as we click like button
    [self togglePreferenceState:YES];
    
    //reload view
    [self reloadViewByState:self.preferenceViewState];
}

- (void) dislikeButton_touchUpInside:(id)sender{
    //pass NO as we click dislike button
    [self togglePreferenceState:NO];
    
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
@end
