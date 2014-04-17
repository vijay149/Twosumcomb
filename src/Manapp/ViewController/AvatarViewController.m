//
//  AvatarViewController.m
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AvatarViewController.h"
#import "ClothingViewController.h"
#import "FileUtil.h"
#import "AvatarHelper.h"
#import "MASession.h"
#import "UIColor-Expanded.h"
#import "AvatarShowRoomViewController.h"

@interface AvatarViewController ()
-(void) loadUI;
@end

@implementation AvatarViewController
@synthesize btnShoe = _btnShoe;
@synthesize btnHair = _btnHair;
@synthesize btnShirt = _btnShirt;
@synthesize btnPant = _btnPant;
@synthesize btnEye = _btnEye;
@synthesize btnBack = _btnBack;
@synthesize btnSave = _btnSave;

- (void)dealloc {
    [_btnShoe release];
    [_btnHair release];
    [_btnShirt release];
    [_btnPant release];
    [_btnEye release];
    [_btnBack release];
    [_btnSave release];
    [_scrollToolBar release];
    [_btnMaleShoe release];
    [_btnSkirt release];
    [_btnEyeStyle release];
    [_btnSkin release];
    [_btnHairColor release];
    [_btnEyeColor release];
    [_avatarView release];
    [_btnShowRoom release];
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
    [self loadUI];
}

- (void)viewDidUnload {
    [self setBtnShoe:nil];
    [self setBtnMaleShoe:nil];
    [self setBtnSkirt:nil];
    [self setBtnEyeStyle:nil];
    [self setBtnSkin:nil];
    [self setBtnHair:nil];
    [self setBtnHairColor:nil];
    [self setBtnEyeColor:nil];
    [self setBtnShowRoom:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadAvatar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UI functions
-(void)loadUI{
    //load the avatar view
    if(IS_IPHONE_5){
        _avatarView = [[MAAvatarView alloc] initWithFrame:CGRectMake(0, 60, 320, 377)];
    }
    else{
        _avatarView = [[MAAvatarView alloc] initWithFrame:CGRectMake(0, 0, 320, 377)];
    }
    [self.view addSubview:self.avatarView];
    
    //change the size of the scroll bar to extend until the last button in the scroll bar (eye button)
    [self.scrollToolBar setContentSize:CGSizeMake(self.btnEyeColor.frame.origin.x + self.btnEyeColor.frame.size.width, self.scrollToolBar.frame.size.height)];
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
    [self createBackNavigationWithTitle:MA_HOME_BUTTON_TEXT action:@selector(back)];
    [self createRightNavigationWithTitle:MA_SAVE_BUTTON_TEXT action:@selector(btnSave_touchUpInside:)];
}

- (void)reloadAvatar{
    UIImage *image = [AvatarHelper avatarImageForPartnerInDocument:[MASession sharedSession].currentPartner];
    if(image){
        self.avatarView.imgViewBody.image = image;
    }
}

- (void)reloadWithPickerType:(AvatarPickerType)pickerType{
    _avatarPickerType = pickerType;
    self.subItems = [NSMutableArray array];
    
    if(_avatarPickerType == AvatarPickerTypeEye){
        [self.subItems addObject:RGB(175, 120, 123)];
        [self.subItems addObject:RGB(127, 70, 44)];
        [self.subItems addObject:RGB(78, 56, 126)];
        [self.subItems addObject:RGB(65, 56, 60)];
        [self.subItems addObject:RGB(0, 128, 0)];
        [self.subItems addObject:RGB(0, 0, 255)];
    }
    else if(_avatarPickerType == AvatarPickerTypeSkin){
        [self.subItems addObject:[UIColor colorWithRed:253.0f/255.0f green:238.0f/255.0f blue:244.0f/255.0f alpha:1.0f]];
        [self.subItems addObject:[UIColor colorWithRed:237.0f/255.0f green:218.0f/255.0f blue:116.0f/255.0f alpha:1.0f]];
        [self.subItems addObject:[UIColor colorWithRed:232.0f/255.0f green:173.0f/255.0f blue:170.0f/255.0f alpha:1.0f]];
        [self.subItems addObject:[UIColor colorWithRed:197.0f/255.0f green:144.0f/255.0f blue:142.0f/255.0f alpha:1.0f]];
        [self.subItems addObject:[UIColor colorWithRed:138.0f/255.0f green:65.0f/255.0f blue:23.0f/255.0f alpha:1.0f]];
        [self.subItems addObject:[UIColor colorWithRed:70.0f/255.0f green:62.0f/255.0f blue:65.0f/255.0f alpha:1.0f]];
    }
    
    [[self listSubItemView] reloadData];
}

#pragma mark - avatar functions
- (void)applyColor:(UIColor *) color{
    if(_avatarPickerType == AvatarPickerTypeSkin){
        self.avatarView.bodyColor = color;
    }
}

- (void)saveColor{
    if(_avatarPickerType == AvatarPickerTypeSkin){
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.avatarView.bodyColor.red] forKey:@"skinRed"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.avatarView.bodyColor.green] forKey:@"skinGreen"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:self.avatarView.bodyColor.blue] forKey:@"skinBlue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - event handler
- (IBAction)btnBack_touchUpInside:(id)sender {
    [self back];
}

- (IBAction)btnSave_touchUpInside:(id)sender {
    UIImage *avatarImage = self.avatarView.imgViewBody.image;
    if(avatarImage){
        if([FileUtil saveImage:avatarImage toDocumentWithName:[AvatarHelper imageNameForPartner:[MASession sharedSession].currentPartner]]){
            [self saveColor];
            
            [self showMessage:@"Successfully save"];
        }
        else{
            [self showMessage:@"Failed to save avatar"];
        }
    }
    else{
        [self showMessage:@"Successfully save"];
    }
}

- (IBAction)btnShoe_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnHair_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnShirt_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnPant_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnEye_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnMaleShoe_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnSkirt_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnEyeStyle_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnSkin_touchUpInside:(id)sender {
    if(_avatarPickerType == AvatarPickerTypeSkin){
        self.listSubItemView.hidden = !self.listSubItemView.hidden;
    }
    else{
        self.listSubItemView.hidden = NO;
        [self reloadWithPickerType:AvatarPickerTypeSkin];
    }
}

- (IBAction)btnHairColor_touchUpInside:(id)sender {
    self.listSubItemView.hidden = YES;
}

- (IBAction)btnEyeColor_touchUpInside:(id)sender {
    if(_avatarPickerType == AvatarPickerTypeEye){
        self.listSubItemView.hidden = !self.listSubItemView.hidden;
    }
    else{
        self.listSubItemView.hidden = NO;
        [self reloadWithPickerType:AvatarPickerTypeEye];
    }
}

- (IBAction)btnShowRoom_touchUpInside:(id)sender {
    AvatarShowRoomViewController *vc = NEW_VC(AvatarShowRoomViewController);
    [self nextTo:vc];
}

#pragma mark - horizonal list view datasource
-(NSInteger)numberOfItemsInHorizontalListView:(HorizontalListView *)view{
    //include a button for color picker
    if(_avatarPickerType == AvatarPickerTypeSkin || _avatarPickerType == AvatarPickerTypeEye){
        return self.subItems.count + 1;
    }
    else{
        return 0;
    }
}

-(CGFloat)paddingBetweenItemsInHorizontalListView:(HorizontalListView *)view{
    return 5;
}

-(CGFloat)horizontalListView:(HorizontalListView *)listView widthForItemAtIndex:(NSInteger)index{
    return 42;
}

-(HorizontalListViewItem *)horizontalListView:(HorizontalListView *)listView itemAtIndex:(NSInteger)index{
    if(_avatarPickerType == AvatarPickerTypeSkin || _avatarPickerType == AvatarPickerTypeEye){
        HorizontalListViewItem *itemView = [[[HorizontalListViewItem alloc] initWithSize:CGSizeMake(42, self.listSubItemView.frame.size.height)] autorelease];
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
        
        return itemView;
    }
    else{
        return nil;
    }
}

#pragma mark - horizontal delegate
-(void)horizontalListView:(HorizontalListView *)listView didTouchItemAtIndex:(NSInteger)index{
    if(_avatarPickerType == AvatarPickerTypeSkin || _avatarPickerType == AvatarPickerTypeEye){
        if(index == (self.subItems.count)){
            //if we click the custom color button
            ColorPickerViewController *colorPickerViewController = NEW_VC(ColorPickerViewController);
            colorPickerViewController.delegate = self;
            [self presentViewController:colorPickerViewController animated:YES completion:^{}];
            return;
        }
        [self applyColor:[self.subItems objectAtIndex:index]];
        [self.avatarView reload];
    }
}

#pragma mark - color picker delegate
-(void)colorPickerViewController:(ColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color{
    if(_avatarPickerType == AvatarPickerTypeSkin){
        [self applyColor:color];
        [self.avatarView reload];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)didCancelInColorPickerViewController:(ColorPickerViewController *)colorPicker{
    [self dismissModalViewControllerAnimated:YES];
}
@end
