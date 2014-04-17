//
//  CustomAvatarViewController.m
//  TwoSum
//
//  Created by Demigod on 24/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "CustomAvatarViewController.h"
#import "CustomAvatarView.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "Item.h"
#import "ItemCategory.h"
#import "ItemToAvatar.h"
#import "Partner.h"
#import "ImageHelper.h"
#define MANAPP_ALERT_LEAVE_TO_HOME_PAGE 100

@interface CustomAvatarViewController ()

- (void) resetToDefaultPositionHorizontalListView;
- (void) isMaleWillChangeIcons;
@end

@implementation CustomAvatarViewController

- (void)dealloc {
    [_viewAvatarPlaceHolder release];
    [_btnShoe release];
    [_btnHair release];
    [_btnShirt release];
    [_btnPant release];
    [_btnBack release];
    [_btnSave release];
    [_scrollToolBar release];
    [_btnSkin release];
    [_btnHairColor release];
    [_btnEyeColor release];
    [_avatarView release];
    [_btnBeard release];
    [_btnBeardColor release];
    [super dealloc];
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setViewAvatarPlaceHolder:nil];
    [self setBtnShoe:nil];
    [self setBtnSkin:nil];
    [self setBtnHair:nil];
    [self setBtnHairColor:nil];
    [self setBtnEyeColor:nil];
    [self setBtnBeard:nil];
    [self setBtnBeardColor:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - init functions
- (void)initialize{
    _isSaved = YES;
}

#pragma mark - UI functions
- (void)loadUI{
    self.avatarView = (CustomAvatarView *)[Util getView:[CustomAvatarView class]];
    self.avatarView.isPreview = YES;
    self.avatarView.frame = CGRectMake(0, 0, self.viewAvatarPlaceHolder.frame.size.width, self.viewAvatarPlaceHolder.frame.size.height);
    [self.viewAvatarPlaceHolder addSubview:self.avatarView];
    if ([MASession sharedSession].currentPartner) {
        [self.avatarView loadAvatarForPartner:[MASession sharedSession].currentPartner];
    }
    
    
    //change the size of the scroll bar to extend until the last button in the scroll bar (eye button)
    [self.scrollToolBar setContentSize:CGSizeMake(self.btnHairColor.frame.origin.x + self.btnHairColor.frame.size.width, self.scrollToolBar.frame.size.height)];
    self.scrollToolBar.showsHorizontalScrollIndicator = NO;
    
    if(IS_IPHONE_5){
        _listSubItemView = [[HorizontalListView alloc] initWithFrame:CGRectMake(0, 400, 320, 52)];
    }
    else{
        _listSubItemView = [[HorizontalListView alloc] initWithFrame:CGRectMake(0, 312, 320, 52)];
    }
    self.listSubItemView.delegate = self;
    self.listSubItemView.datasource = self;
    self.listSubItemView.hidden = YES;
    [self.view addSubview:self.listSubItemView];
    
    // button Home, Save
    [self.navigationController setNavigationBarHidden:YES];
    [self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(btnBack_touchUpInside:)];
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(btnSave_touchUpInside:)];
    
    [self isMaleWillChangeIcons];
    
}

//check sex to change icon shoe and beard
- (void) isMaleWillChangeIcons {
    if ([MASession sharedSession].currentPartner && [MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE) {
        self.btnShoe.frame = CGRectMake(CGRectGetMinX(self.btnShoe.frame), 5 + 10, 60, 27);
        [self.btnShoe setImage:[UIImage imageNamed:@"icon_shoe_tennis_male"] forState:UIControlStateNormal];
    }
    self.btnEyeColor.hidden = YES;// eye is beard
    self.btnHairColor.frame = CGRectMake(self.btnSkin.frame.origin.x - 10, self.btnSkin.frame.origin.y, self.btnHairColor.frame.size.width, self.btnHairColor.frame.size.height);
    self.btnSkin.frame = CGRectMake(self.btnEyeColor.frame.origin.x, self.btnSkin.frame.origin.y, self.btnSkin.frame.size.width, self.btnSkin.frame.size.height);
}

- (void)reloadSubItemListWithType:(AvatarItemType)type{
    _currentItemType = type;
    self.subItems = [NSMutableArray array];
    if(type == AvatarItemTypeHair){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypeGlass){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_GLASS];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypePant){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_PANT];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypeShirt){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHIRT];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypeShoe){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHOE];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypeBear){
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
        if(category){
            NSArray *items = [[DatabaseHelper sharedHelper] getAllItemForCategory:category sex:[MASession sharedSession].currentPartner.sex.integerValue];
            self.subItems = [NSMutableArray arrayWithArray:items];
        }
    }
    else if(type == AvatarItemTypeSkinColor){
        [self.subItems addObject:RGB(253, 238, 244)];
//        [self.subItems addObject:RGB(237, 218, 116)];
        [self.subItems addObject:RGB(255, 255, 204)];
        [self.subItems addObject:RGB(232, 173, 170)];
        [self.subItems addObject:RGB(197, 144, 142)];
        [self.subItems addObject:RGB(138, 65, 23)];
        [self.subItems addObject:RGB(70, 62, 65)];
    }
    else if(type == AvatarItemTypeEyeColor){
        [self.subItems addObject:RGB(175, 120, 123)];
        [self.subItems addObject:RGB(127, 70, 44)];
        [self.subItems addObject:RGB(78, 56, 126)];
        [self.subItems addObject:RGB(65, 56, 60)];
        [self.subItems addObject:RGB(0, 128, 0)];
        [self.subItems addObject:RGB(0, 0, 255)];
    }
    else if(type == AvatarItemTypeHairColor){
        [self.subItems addObject:RGB(175, 120, 123)];
        [self.subItems addObject:RGB(127, 70, 44)];
        [self.subItems addObject:RGB(78, 56, 126)];
        [self.subItems addObject:RGB(65, 56, 60)];
        [self.subItems addObject:RGB(0, 128, 0)];
        [self.subItems addObject:RGB(0, 0, 255)];
    }
//    else if(type == AvatarItemTypeBearColor){
//        [self.subItems addObject:RGB(175, 120, 123)];
//        [self.subItems addObject:RGB(127, 70, 44)];
//        [self.subItems addObject:RGB(78, 56, 126)];
//        [self.subItems addObject:RGB(65, 56, 60)];
//        [self.subItems addObject:RGB(0, 128, 0)];
//        [self.subItems addObject:RGB(0, 0, 255)];
//    }
    [[self listSubItemView] reloadData];
}

#pragma mark - avatar functions
- (void)applyColor:(UIColor *) color{
    if(_currentItemType == AvatarItemTypeSkinColor){
        //[[DatabaseHelper sharedHelper] changeSkinColorForPartner:[MASession sharedSession].currentPartner toColor:color];
        self.avatarView.colorSkinPreview = color;
    }
    else if(_currentItemType == AvatarItemTypeEyeColor){
        //[[DatabaseHelper sharedHelper] changeEyeColorForPartner:[MASession sharedSession].currentPartner toColor:color];
        self.avatarView.colorEyePreview = color;
    }
    else if(_currentItemType == AvatarItemTypeHairColor){
        //[[DatabaseHelper sharedHelper] changeHairColorForPartner:[MASession sharedSession].currentPartner toColor:color];
        self.avatarView.colorHairPreview = color;
    }
//    else if(_currentItemType == AvatarItemTypeBearColor){
//        self.avatarView.colorBeardPreview = color;
//    }
}

#pragma mark - event handler
- (IBAction)btnShoe_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeShoe && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeShoe];
}

- (IBAction)btnHair_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeHair && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeHair];
}

- (IBAction)btnShirt_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeShirt && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeShirt];
}

- (IBAction)btnPant_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypePant && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypePant];
}

- (IBAction)btnGlass_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeGlass && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeGlass];
}

- (IBAction)btnBack_touchUpInside:(id)sender{
    if(_isSaved){
        [self back];
    }
    else{
        [self showMessage:@"I noticed that you have not saved the work you have done, Do you want to stay and save your changes or leave and loose them" title:kAppName cancelButtonTitle:@"Stay" otherButtonTitle:@"Leave" delegate:self tag:MANAPP_ALERT_LEAVE_TO_HOME_PAGE];
    }
}

- (IBAction)btnSave_touchUpInside:(id)sender{
    self.listSubItemView.hidden = YES;
    _isSaved = YES;
    [self.avatarView saveFromPreview];
    [self showMessage:@"Avatar was saved successfully"];
    ///!!!: generateAvatarForPreviewMood
//    [self.avatarView generateAvatarForPreviewMood:^(BOOL blockResult)  {
//        if (blockResult) {
//
//        }
//        
//    }];
}

- (IBAction)btnSkin_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeSkinColor && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeSkinColor];
}

- (IBAction)btnHairColor_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeHairColor && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeHairColor];
}

// using for Bear
- (IBAction)btnEyeColor_touchUpInside:(id)sender{
//    [self resetToDefaultPositionHorizontalListView];
//    if(_currentItemType == AvatarItemTypeEyeColor && self.listSubItemView.hidden == NO){
//        self.listSubItemView.hidden = YES;
//    }
//    else{
//        self.listSubItemView.hidden = NO;
//    }
//    [self reloadSubItemListWithType:AvatarItemTypeEyeColor];
    
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeBear && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeBear];
}

// don't use
- (IBAction)btnBearColor_touchUpInside:(id)sender {
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeEyeColor && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeBearColor];

}


- (IBAction)btnBear_touchUpInside:(id)sender{
    [self resetToDefaultPositionHorizontalListView];
    if(_currentItemType == AvatarItemTypeBear && self.listSubItemView.hidden == NO){
        self.listSubItemView.hidden = YES;
    }
    else{
        self.listSubItemView.hidden = NO;
    }
    [self reloadSubItemListWithType:AvatarItemTypeBear];
}


- (void)btnBackground_touchUpInside:(id)sender{
    self.listSubItemView.hidden = YES;
}

#pragma mark - horizonal list view datasource
-(NSInteger)numberOfItemsInHorizontalListView:(HorizontalListView *)view{
    if(self.subItems.count == 0){
        return 0;
    }
    return self.subItems.count + 1;
}

-(CGFloat)paddingBetweenItemsInHorizontalListView:(HorizontalListView *)view{
    return 25;
}

-(CGFloat)horizontalListView:(HorizontalListView *)listView widthForItemAtIndex:(NSInteger)index{
    return 42;
}

-(HorizontalListViewItem *)horizontalListView:(HorizontalListView *)listView itemAtIndex:(NSInteger)index{
    HorizontalListViewItem *itemView = [[[HorizontalListViewItem alloc] initWithSize:CGSizeMake(42, self.listSubItemView.frame.size.height)] autorelease];
    
    if(_currentItemType == AvatarItemTypeSkinColor || _currentItemType == AvatarItemTypeEyeColor || _currentItemType == AvatarItemTypeHairColor){
        if(index < self.subItems.count){
            UIColor *color = [self.subItems objectAtIndex:index];
            itemView.backgroundColor = color;
        }
        else{
            UIImageView *imgColorPicker = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)] autorelease];
            imgColorPicker.image = [UIImage imageNamed:@"colorPicker"];
            
            [itemView addSubview:imgColorPicker];
        }
        
        //change item view style
        itemView.layer.cornerRadius = 5;
        itemView.layer.borderColor = [[UIColor whiteColor] CGColor];
        itemView.layer.borderWidth = 2;
    }
    else{
        if(index < self.subItems.count){
            Item *item = [self.subItems objectAtIndex:index];
            
            NSInteger imgViewTag = 100;
            UIImageView *imgColorPicker = (UIImageView *)[itemView viewWithTag:imgViewTag];
            if (imgColorPicker) {
                [imgColorPicker removeFromSuperview];
            }
            imgColorPicker = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)] autorelease];
            [itemView addSubview:imgColorPicker];
            imgColorPicker.image = [UIImage imageNamed:item.icon];
        }
        //delete button
        else{
            
        }
        
        //change item view style
        itemView.layer.cornerRadius = 5;
        itemView.layer.borderColor = [[UIColor whiteColor] CGColor];
        itemView.layer.borderWidth = 2;
    }
    return itemView;
}

- (UIView *) viewAtLocation:(CGPoint) touchLocation {
    for (UIView *subView in self.listSubItemView.scrollView.subviews)
        if (CGRectContainsPoint(subView.frame, touchLocation))
            return subView;
    return nil;
}

#pragma mark - horizontal delegate
-(void)horizontalListView:(HorizontalListView *)listView didTouchItemAtIndex:(NSInteger)index withButton:(UIButton *)button {
    //mark your change
    _isSaved = NO;
    
    if(_currentItemType == AvatarItemTypeSkinColor || _currentItemType == AvatarItemTypeEyeColor || _currentItemType == AvatarItemTypeHairColor){
        if(index == (self.subItems.count)){
            //if we click the custom color button
            ColorPickerViewController *colorPickerViewController = NEW_VC(ColorPickerViewController);
            colorPickerViewController.delegate = self;
            [self presentViewController:colorPickerViewController animated:YES completion:^{}];
            return;
        }
        // scroll item didTouch to center avatar. 
        [listView.scrollView setContentOffset:CGPointMake(button.frame.origin.x - 140, 0) animated:YES];
        [self applyColor:[self.subItems objectAtIndex:index]];
    }
    else{
        if(index < self.subItems.count){
            Item *item = [self.subItems objectAtIndex:index];
            //[[DatabaseHelper sharedHelper] addItem:item toPartner:[MASession sharedSession].currentPartner];
            if(_currentItemType == AvatarItemTypeHair){
                self.avatarView.itemHairPreview = item;
                self.avatarView.abstractItem = item;
            }
            else if(_currentItemType == AvatarItemTypeGlass){
                self.avatarView.itemGlassPreview = item;
                self.avatarView.abstractItem = item;
            }
            else if(_currentItemType == AvatarItemTypePant){
                self.avatarView.itemPantPreview = item;
                self.avatarView.abstractItem = item;
            }
            else if(_currentItemType == AvatarItemTypeShirt){
                self.avatarView.itemShirtPreview = item;
                self.avatarView.abstractItem = item;
            }
            else if(_currentItemType == AvatarItemTypeShoe){
                self.avatarView.itemShoePreview = item;
                self.avatarView.abstractItem = item;
            }
            else if(_currentItemType == AvatarItemTypeBear){
                self.avatarView.itemBearPreview = item;// bear
                self.avatarView.abstractItem = item;
            }
        }
        else{
            if(_currentItemType == AvatarItemTypeHair){
                self.avatarView.itemHairPreview = nil;
                self.avatarView.abstractItem = nil;
            }
            else if(_currentItemType == AvatarItemTypeGlass){
                self.avatarView.itemGlassPreview = nil;
                self.avatarView.abstractItem = nil;
            }
            else if(_currentItemType == AvatarItemTypePant){
                self.avatarView.itemPantPreview = nil;
                self.avatarView.abstractItem = nil;
            }
            else if(_currentItemType == AvatarItemTypeShirt){
                self.avatarView.itemShirtPreview = nil;
                self.avatarView.abstractItem = nil;
            }
            else if(_currentItemType == AvatarItemTypeShoe){
                self.avatarView.itemShoePreview = nil;
                self.avatarView.abstractItem = nil;
            }
            else if(_currentItemType == AvatarItemTypeBear){
                self.avatarView.itemBearPreview = nil;
                self.avatarView.abstractItem = nil;
            }
        }
    }
    self.avatarView.currentAvatarItemType = _currentItemType;
//    self.avatarView.currentViewAvatar = self.avatarView;
    [self.avatarView reload];
}

#pragma mark - color picker delegate
-(void)colorPickerViewController:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color{
//    [self reloadSubItemListWithType:AvatarItemTypeSkinColor];
    if(_currentItemType == AvatarItemTypeSkinColor || _currentItemType == AvatarItemTypeHairColor){
        [self applyColor:color];
        [self.avatarView reload];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelInColorPickerViewController:(ColorPickerViewController *)colorPicker{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - event handler
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.tag == MANAPP_ALERT_LEAVE_TO_HOME_PAGE){
        if(buttonIndex == 1){
            [self back];
        }
    }
}

- (void) resetToDefaultPositionHorizontalListView {
    [self.listSubItemView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}
@end
