//
//  SummaryViewController.m
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "SummaryViewController.h"
#import "UILabel+Additions.h"
#import "MANotesCell.h"
#import "AddOrUpdateNoteViewController.h"
#import "Util.h"
#import "Note.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "HomepageViewController.h"
#import "NoteViewController.h"
#import "MAPreferenceCell.h"
#import "PreferenceCategory.h"
#import "PreferenceItem.h"
#import "PartnerMeasurement.h"
#import "PartnerInformation.h"
#import "PartnerMeasurementItem.h"
#import "PartnerInformationItem.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "PartnerEroZone.h"
#import "ErogeneousZone.h"
#import "enum.h"
#import "NoteViewController.h"
#import "MAMeasurementCell.h"
#import "LinkedHashMap.h"

#define MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT 31
@interface SummaryViewController () <RATreeViewDelegate, RATreeViewDataSource>

@property (nonatomic, retain) NSArray *preferences;
@property (nonatomic, retain) NSArray *measurements;
@property (nonatomic, retain) NSArray *partnerInformation;

- (void)initializeUI;
// Preference
- (NSArray *)getItemsOfPreference:(PreferenceCategory *)preference;
- (void)backToNotes:(id)sender;
- (IBAction)backToHome:(id)sender;

//Measurement
- (NSArray *)getItemsInCategory:(PartnerMeasurement *)measurement;

//PartnerInformation
- (NSArray *)getItemsInCategoryInformation:(PartnerInformation *)information;

//Tree view
- (void)initializeTreeView;
- (UIView *)createUIViewHeader:(BOOL)isParent isSubParent:(BOOL)isSubParent isSubOfSubParent:(BOOL)isSubOfSubParent withTitle:(NSString *)title;
- (NSArray *)getAllEroZoneByType;
- (NSMutableArray *)loadPreferences;
- (NSMutableArray *)loadMeasurements;
- (NSMutableArray *)loadAdditionalInfo;
@property (retain, nonatomic) RATreeView *treeView;
@property (retain, nonatomic) NSMutableArray *data;
@end

@implementation SummaryViewController

- (void)dealloc {
	[_preferences release];
	[_measurements release];
	[_partnerInformation release];
	[_treeView release];
	[_data release];
	[super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self initializeUI];
	[self initializeTreeView];
}

#pragma mark - init functions
- (void)initializeUI {
	[self.navigationController setNavigationBarHidden:YES];
	[self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(backToHome:)];
	[self createButtonNavigationWithTitle:LSSTRING(@"Notes")  frame:CGRectMake(75, 27, 60, 23) action:@selector(backToNotes:)];
	[self createButtonByImageName:@"btnSummarySelected" frame:CGRectMake(152, 20, 75, 40) action:@selector(initializeTreeView)];
	//gesture
	[self addSwipeBackGesture];
}

// Information
- (NSArray *)getItemsInCategoryInformation:(PartnerInformation *)information {
	return [[DatabaseHelper sharedHelper] getAllItemForPartnerInformation:information];
}

// Measurement
- (NSArray *)getItemsInCategory:(PartnerMeasurement *)measurement {
	return [[DatabaseHelper sharedHelper] getAllItemForPartnerMeasurement:measurement];
}

// get items of the selected preference
- (NSArray *)getItemsOfPreference:(PreferenceCategory *)preference {
	if (self.preferenceViewState == MAPreferenceViewStateShowAll) {
		return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference];
	}
	else if (self.preferenceViewState == MAPreferenceViewStateLikeOnly) {
		return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference isLike:TRUE];
	}
	else if (self.preferenceViewState == MAPreferenceViewStateDislikeOnly) {
		return [[DatabaseHelper sharedHelper] getAllItemForPartnerPreference:preference isLike:FALSE];
	}
	else {
		return [[[NSArray alloc] init] autorelease];
	}
}

// next view NoteViewController
- (void)backToNotes:(id)sender {
	[self popToView:[NoteViewController class]];
}

- (NSMutableArray *)loadMeasurements {
	NSMutableArray *listObject = [NSMutableArray array];
	self.measurements = [[DatabaseHelper sharedHelper] getAllPartnerMeasurementForPartner:[[MASession sharedSession] currentPartner]];
	// end for Measurements
	for (PartnerMeasurement *measurement in self.measurements) {
		NSArray *items = [self convertAbstractArrayToRADataObjectArray:kMeasurement arrayInput:[self getItemsInCategory:measurement]];
		if (items.count > 0) {
			RADataObject *raDO = [RADataObject dataObjectWithName:measurement.name children:items isParent:NO isSubParent:YES isSubOfSubParent:NO isPreference:NO isLike:NO];
			[listObject addObject:raDO];
		}
	}
	return listObject;
}

- (NSMutableArray *)loadAdditionalInfo {
	NSMutableArray *listObject = [NSMutableArray array];
	self.partnerInformation = [[DatabaseHelper sharedHelper] getAllPartnerInformationForPartner:[[MASession sharedSession] currentPartner]];
	NSMutableArray *allData = [NSMutableArray array];
	for (PartnerInformation *infor in self.partnerInformation) {
		NSArray *items = [self getItemsInCategoryInformation:infor];
		if (items && items.count > 0) {
			[allData addObject:infor];
		}
	}
	LinkedHashMap *lhm = [[[LinkedHashMap alloc] init] autorelease];
	BOOL flag = NO;
	for (PartnerInformation *infor in allData) {
		NSMutableArray *items = [NSMutableArray arrayWithArray:[self getItemsInCategoryInformation:infor]];
		if (lhm.allKeys.count == 0) {
			DLogInfo(@"parentCategory.name %@", infor.parentCategory.name);
			[lhm insertValue:items withKey:infor.parentCategory.name];
			DLogInfo(@"preference name %@", infor.name);
		}
		else {
			for (NSString *key in[lhm allKeys]) {
				if ([key isEqual:infor.parentCategory.name]) { // update
					DLogInfo(@"parentCategory.name %@", infor.parentCategory.name);
					DLogInfo(@"preference name %@", infor.name);
					NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
					NSLog(@"list 1: %@", itemsFromHashMap.description);
					[itemsFromHashMap addObjectsFromArray:items];
					NSLog(@"list 2: %@", [[lhm valueForKey:key] description]);
					flag = YES;
				}
			}
			if (!flag) { // them moi.
				DLogInfo(@"parentCategory.name %@", infor.parentCategory.name);
				DLogInfo(@"preference name %@", infor.name);
				[lhm insertValue:items withKey:infor.parentCategory.name];
				flag = NO;
			}
			else {
				flag = NO;
			}
		}
	}

	if (lhm.allKeys.count > 0) {
		BOOL isTrue = NO;
		for (NSString *key in[lhm allKeys]) {
			DLogInfo(@"key: %@", key); // parent category
			NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
			LinkedHashMap *linkedHashMapSub = [[[LinkedHashMap alloc] init] autorelease];
			for (PartnerInformationItem *infoItem in itemsFromHashMap) {
				if (linkedHashMapSub.allKeys.count == 0) {
					DLogInfo(@"preItem.category.name %@", infoItem.information.name);
					NSMutableArray *infoItems = [NSMutableArray array];
					[infoItems addObject:infoItem];
					[linkedHashMapSub insertValue:infoItems withKey:infoItem.information.name];
				}
				else {
					for (NSString *keySub in[linkedHashMapSub allKeys]) {
						if ([keySub isEqual:infoItem.information.name]) { // update
							DLogInfo(@"preItem.category.name %@", infoItem.information.name);
							NSMutableArray *itemsFromHashMap = [linkedHashMapSub valueForKey:keySub];
							NSLog(@"list 1: %@", itemsFromHashMap.description);
							[itemsFromHashMap addObject:infoItem];
							NSLog(@"list 2: %@", [[linkedHashMapSub valueForKey:keySub] description]);
							isTrue = YES;
						}
					}
					if (!isTrue) { // them moi.
						DLogInfo(@"preItem.category.name %@", infoItem.information.name);
						NSMutableArray *preItems = [NSMutableArray array];
						[preItems addObject:infoItem];
						[linkedHashMapSub insertValue:preItems withKey:infoItem.information.name];
						isTrue = NO;
					}
					else {
						isTrue = NO;
					}
				}
			}
			NSMutableArray *listSubCategory = [NSMutableArray array];
			if (linkedHashMapSub.allValues.count > 0) {
				for (NSString *keyItem in[linkedHashMapSub allKeys]) {
					NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kInformation arrayInput:[linkedHashMapSub valueForKey:keyItem]];
					RADataObject *raDOSubOfCategory = [RADataObject dataObjectWithName:keyItem children:items isParent:NO isSubParent:NO isSubOfSubParent:YES isPreference:NO isLike:NO];
					[listSubCategory addObject:raDOSubOfCategory];
				}
			}
			RADataObject *raDOCategory = [RADataObject dataObjectWithName:key children:listSubCategory isParent:NO isSubParent:YES isSubOfSubParent:NO isPreference:NO isLike:NO];
			[listObject addObject:raDOCategory];
		}
	}
	return listObject;
}

- (NSMutableArray *)loadPreferences {
	NSMutableArray *listObject = [NSMutableArray array];
	self.preferences = [[DatabaseHelper sharedHelper] getAllPartnerPreferenceForPartner:[[MASession sharedSession] currentPartner]];
	NSMutableArray *allData = [NSMutableArray array];
	for (PreferenceCategory *preItem in self.preferences) {
		NSArray *items = [self getItemsOfPreference:preItem];
		if (items && items.count > 0) {
			[allData addObject:preItem];
		}
	}
	LinkedHashMap *lhm = [[[LinkedHashMap alloc] init] autorelease];
	BOOL flag = NO;
	// begin filter Parent category
	for (PreferenceCategory *preference in allData) {
		//NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kPreference arrayInput:[self getItemsOfPreference:preference]];
		NSMutableArray *items = [NSMutableArray arrayWithArray:[self getItemsOfPreference:preference]];
		if (lhm.allKeys.count == 0) {
			DLogInfo(@"parentCategory.name %@", preference.parentCategory.name);
			[lhm insertValue:items withKey:preference.parentCategory.name];
			DLogInfo(@"preference name %@", preference.name);
		}
		else {
			for (NSString *key in[lhm allKeys]) {
				if ([key isEqual:preference.parentCategory.name]) { // update
					DLogInfo(@"parentCategory.name %@", preference.parentCategory.name);
					DLogInfo(@"preference name %@", preference.name);
					NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
					NSLog(@"list 1: %@", itemsFromHashMap.description);
					[itemsFromHashMap addObjectsFromArray:items];
					NSLog(@"list 2: %@", [[lhm valueForKey:key] description]);
					flag = YES;
				}
			}
			if (!flag) { // them moi.
				DLogInfo(@"parentCategory.name %@", preference.parentCategory.name);
				DLogInfo(@"preference name %@", preference.name);
				[lhm insertValue:items withKey:preference.parentCategory.name];
				flag = NO;
			}
			else {
				flag = NO;
			}
		}
	}
	// end filter Parent category

	if (lhm.allKeys.count > 0) {
		BOOL isTrue = NO;

		for (NSString *key in[lhm allKeys]) {
			DLogInfo(@"key: %@", key); // parent category
			NSMutableArray *itemsFromHashMap = [lhm valueForKey:key];
			LinkedHashMap *linkedHashMapSub = [[[LinkedHashMap alloc] init] autorelease];
			// begin filter Sub category
			for (PreferenceItem *preItem in itemsFromHashMap) {
				if (linkedHashMapSub.allKeys.count == 0) {
					DLogInfo(@"preItem.category.name %@", preItem.category.name);
					NSMutableArray *preItems = [NSMutableArray array];
					[preItems addObject:preItem];
					[linkedHashMapSub insertValue:preItems withKey:preItem.category.name];
				}
				else {
					for (NSString *keySub in[linkedHashMapSub allKeys]) {
						if ([keySub isEqual:preItem.category.name]) { // update
							DLogInfo(@"preItem.category.name %@", preItem.category.name);
							NSMutableArray *itemsFromHashMap = [linkedHashMapSub valueForKey:keySub];
							NSLog(@"list 1: %@", itemsFromHashMap.description);
							[itemsFromHashMap addObject:preItem];
							NSLog(@"list 2: %@", [[linkedHashMapSub valueForKey:keySub] description]);
							isTrue = YES;
						}
					}
					if (!isTrue) { // them moi.
						DLogInfo(@"preItem.category.name %@", preItem.category.name);
						NSMutableArray *preItems = [NSMutableArray array];
						[preItems addObject:preItem];
						[linkedHashMapSub insertValue:preItems withKey:preItem.category.name];
						isTrue = NO;
					}
					else {
						isTrue = NO;
					}
				}
			} // // end filter Sub category
			NSMutableArray *listSubCategory = [NSMutableArray array];
			if (linkedHashMapSub.allValues.count > 0) {
				for (NSString *keyItem in[linkedHashMapSub allKeys]) {
					NSMutableArray *items = [self convertAbstractArrayToRADataObjectArray:kPreference arrayInput:[linkedHashMapSub valueForKey:keyItem]];
					RADataObject *raDOSubOfCategory = [RADataObject dataObjectWithName:keyItem children:items isParent:NO isSubParent:NO isSubOfSubParent:YES isPreference:NO isLike:NO];
					[listSubCategory addObject:raDOSubOfCategory];
				}
			}
			RADataObject *raDOCategory = [RADataObject dataObjectWithName:key children:listSubCategory isParent:NO isSubParent:YES isSubOfSubParent:NO isPreference:NO isLike:NO];
			[listObject addObject:raDOCategory];
		}
	}

	return listObject;
}

- (void)initializeTreeView {
	if (![[MASession sharedSession] currentPartner]) {
		return;
	}
	self.data = [NSMutableArray array];
	NSMutableArray *listPreferences = [self loadPreferences];
	NSMutableArray *listMeasurements = [self loadMeasurements];
	NSMutableArray *listAdditionalInfo = [self loadAdditionalInfo];

	if (listPreferences && listPreferences.count > 0) {
		RADataObject *preference = [RADataObject dataObjectWithName:@"Likes & Dislikes" children:listPreferences isParent:YES isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];

		[self.data addObject:preference];
	}
	if (listMeasurements && listMeasurements.count > 0) {
		RADataObject *mesurement = [RADataObject dataObjectWithName:@"Measurements" children:listMeasurements isParent:YES isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];

		[self.data addObject:mesurement];
	}
	if (listAdditionalInfo && listAdditionalInfo.count > 0) {
		RADataObject *additionalInfo = [RADataObject dataObjectWithName:@"Other info" children:listAdditionalInfo isParent:YES isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];
		[self.data addObject:additionalInfo];
	}

	NSArray *listObjectEroZone = [self getAllEroZoneByType];
	if (listObjectEroZone && listObjectEroZone.count > 0) {
		RADataObject *eroZone = [RADataObject dataObjectWithName:@"Know my Body" children:listObjectEroZone isParent:YES isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];
		[self.data addObject:eroZone];
	}

	RATreeView *treeView = [[[RATreeView alloc] initWithFrame:self.view.frame] autorelease];
//    treeView.scrollEnabled = NO;
	if (IS_IPHONE_5) {
		treeView.frame = CGRectMake(treeView.frame.origin.x + 20, treeView.frame.origin.y + 70, treeView.frame.size.width - 40, treeView.frame.size.height + 30);
	}
	else {
		treeView.frame = CGRectMake(treeView.frame.origin.x + 20, treeView.frame.origin.y + 70, treeView.frame.size.width - 40, treeView.frame.size.height - 45);
	}
	NSLog(@"x: %f, y : %f", treeView.frame.origin.x, treeView.frame.origin.y);
	treeView.delegate = self;
	treeView.dataSource = self;
	treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
	[treeView reloadData];
	[treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
	self.treeView = treeView;
	[self.view addSubview:treeView];
}

//    0];//MAEroZoneHead //    1];//MAEroZoneNeck //    2];//MAEroZoneChest //    31];//MAEroZoneLegLeft //    32];//MAEroZoneLegRight
//    41];//MAEroZoneArmLeft //    42];//MAEroZoneArmRight //    51];//MAEroZoneHandLeft //    52];//MAEroZoneHandRight
//    6];//MAEroZoneHip //    71];//MAEroZoneFootLeft //    72]; //MAEroZoneFootRight
//    MAEroZoneWaist             = 3, MAEroZoneThighLeft         = 4, MAEroZoneThighRight        = 5
- (NSArray *)getAllEroZoneByType {
	NSArray *arrayEroZone = @[@0, @1, @2, @31, @32, @41, @42, @51, @52, @6, @71, @72, @3, @4, @5];
	NSMutableArray *listObject = [NSMutableArray array];
	for (int i = 0; i < arrayEroZone.count; i++) {
		NSLog(@"i %d", [arrayEroZone[i] intValue]);
		ErogeneousZone *eroZone = [[DatabaseHelper sharedHelper] getEroZoneByTypeId:[arrayEroZone[i] intValue] forPartner:[MASession sharedSession].currentPartner avatarType:1];
		if (eroZone) {
			PartnerEroZone *partnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:eroZone.erogeneousZoneID.integerValue];
			if (partnerEroZone) {
				NSMutableArray *items = [NSMutableArray array];
				RADataObject *raDOSubItem = [RADataObject dataObjectWithName:partnerEroZone.value children:nil isParent:NO isSubParent:NO isSubOfSubParent:NO isPreference:NO isLike:NO];
				raDOSubItem.isEroZone = YES;
				[items addObject:raDOSubItem];
				RADataObject *raDO = [RADataObject dataObjectWithName:eroZone.name children:items isParent:NO isSubParent:YES isSubOfSubParent:NO isPreference:NO isLike:NO];
				[listObject addObject:raDO];
			}
		}
	}
	return listObject;
}

#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
	RADataObject *raDO =  (RADataObject *)item;
	return [self cellHeightForItem:raDO orTitle:nil];
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
	return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
	return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel {
	return YES;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
	cell.backgroundColor = UIColorFromRGB(0xF7F7F7);
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
	RADataObject *raDO =  (RADataObject *)item;
	static NSString *CellIdentifier = @"Cell";
	if (raDO.isPreference) {
		MAPreferenceCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell) {
			cell = (MAPreferenceCell *)[Util getCell:[MAPreferenceCell class] owner:self];
		}
		if (raDO.isLike) {
			cell.imageRight.image = [UIImage imageNamed:@"btnLikeSelected"];
		}
		else {
			cell.imageRight.image = [UIImage imageNamed:@"btnDislikeSmallSelected"];
		}
		[cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
		if (raDO.isLastItem) {
			cell.viewSeparate.hidden = YES;
		}
		return cell;
	}
	else if (raDO.isEroZone) {
		UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
		[cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
		return cell;
	}
	else {
		MAMeasurementCell *cell = [treeView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell) {
			cell = (MAMeasurementCell *)[Util getCell:[MAMeasurementCell class] owner:self];
		}
		[cell addSubview:[self createUIViewHeader:raDO.isParent isSubParent:raDO.isSubParent isSubOfSubParent:raDO.isSubOfSubParent withTitle:raDO.name]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont fontWithName:kAppFont size:18];
		if (raDO.isLastItem) {
			cell.viewSeparate.hidden = YES;
		}
		return cell;
	}
}

- (UIView *)createUIViewHeader:(BOOL)isParent isSubParent:(BOOL)isSubParent isSubOfSubParent:(BOOL)isSubOfSubParent withTitle:(NSString *)title {
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.treeView.frame.size.width + 1, MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT)] autorelease];
	//background
	UIImageView *backgroundView = [[[UIImageView alloc] initWithFrame:headerView.frame] autorelease];
	[backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	UILabel *lblTitle = [[[UILabel alloc] initWithFrame:headerView.frame] autorelease];
	lblTitle.textAlignment = NSTextAlignmentCenter;
	if (isParent) {
		backgroundView.image = [UIImage imageNamed:@"header_background_summary"];
	}
	else if (!isParent && isSubParent) {
		backgroundView.image = [UIImage imageNamed:@"preferenceSectionBg"];
	}
	else if (isSubOfSubParent) {
		backgroundView.image = [UIImage imageNamed:@"header_background_sub_category"];
	}
	else {
		lblTitle.textAlignment = NSTextAlignmentLeft;
		lblTitle.frame = CGRectMake(lblTitle.frame.origin.x + 10, lblTitle.frame.origin.y, lblTitle.frame.size.width - 20, [self cellHeightForItem:nil orTitle:title]);
//        lblTitle.lineBreakMode = NSLineBreakByCharWrapping;
		lblTitle.numberOfLines = 5;
	}
	[headerView addSubview:backgroundView];
	lblTitle.backgroundColor = [UIColor clearColor];
	lblTitle.font = [UIFont fontWithName:kAppFont size:18];
	lblTitle.textColor = [UIColor blackColor];
	lblTitle.text = title;
	[headerView addSubview:lblTitle];
	return headerView;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return [self.data count];
	}
	RADataObject *data = item;
	return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
	RADataObject *data = item;
	if (item == nil) {
		return [self.data objectAtIndex:index];
	}
	return [data.children objectAtIndex:index];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.preferenceViewState = MAPreferenceViewStateShowAll;
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	//reload the data
//    [self reloadSummaryData];
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (IBAction)backToHome:(id)sender {
	[self popToView:[HomepageViewController class]];
}

@end
