//
//  AvatarViewController.h
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "ColorPickerViewController.h"
#import "MAAvatarView.h"
#import "HorizontalListView.h"
#import "HorizontalListViewItem.h"

typedef enum {
	AvatarPickerTypeSkin = 1,
	AvatarPickerTypeEye  = 2,
} AvatarPickerType;

@interface AvatarViewController : BaseViewController<ColorPickerViewControllerDelegate, HorizontalListViewDatasource, HorizontalListViewDelegate>{
    AvatarPickerType _avatarPickerType;
}

@property (retain, nonatomic) IBOutlet UIButton *btnShoe;
@property (retain, nonatomic) IBOutlet UIButton *btnHair;
@property (retain, nonatomic) IBOutlet UIButton *btnShirt;
@property (retain, nonatomic) IBOutlet UIButton *btnPant;
@property (retain, nonatomic) IBOutlet UIButton *btnEye;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnMaleShoe;
@property (retain, nonatomic) IBOutlet UIButton *btnSkirt;
@property (retain, nonatomic) IBOutlet UIButton *btnEyeStyle;
@property (retain, nonatomic) IBOutlet UIButton *btnSkin;
@property (retain, nonatomic) IBOutlet UIButton *btnHairColor;
@property (retain, nonatomic) IBOutlet UIButton *btnEyeColor;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollToolBar;
@property (retain, nonatomic) IBOutlet UIButton *btnShowRoom;

@property (retain, nonatomic) MAAvatarView *avatarView;
@property (retain, nonatomic) HorizontalListView *listSubItemView;
@property (retain, nonatomic) NSMutableArray *subItems;

- (IBAction)btnShoe_touchUpInside:(id)sender;
- (IBAction)btnHair_touchUpInside:(id)sender;
- (IBAction)btnShirt_touchUpInside:(id)sender;
- (IBAction)btnPant_touchUpInside:(id)sender;
- (IBAction)btnEye_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;
- (IBAction)btnMaleShoe_touchUpInside:(id)sender;
- (IBAction)btnSkirt_touchUpInside:(id)sender;
- (IBAction)btnEyeStyle_touchUpInside:(id)sender;
- (IBAction)btnSkin_touchUpInside:(id)sender;
- (IBAction)btnHairColor_touchUpInside:(id)sender;
- (IBAction)btnEyeColor_touchUpInside:(id)sender;
- (IBAction)btnShowRoom_touchUpInside:(id)sender;

- (void)reloadWithPickerType:(AvatarPickerType)pickerType;

@end
