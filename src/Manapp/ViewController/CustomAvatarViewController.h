//
//  CustomAvatarViewController.h
//  TwoSum
//
//  Created by Demigod on 24/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HorizontalListView.h"
#import "HorizontalListViewItem.h"
#import "CustomAvatarView.h"
#import "ColorPickerViewController.h"
#import "enum.h"


@interface CustomAvatarViewController : BaseViewController<HorizontalListViewDatasource, HorizontalListViewDelegate, ColorPickerViewControllerDelegate, UIAlertViewDelegate>{
    AvatarItemType _currentItemType;
    BOOL _isSaved;
}
@property (retain, nonatomic) IBOutlet UIButton *btnBeardColor;

@property (retain, nonatomic) IBOutlet UIView *viewAvatarPlaceHolder;
@property (retain, nonatomic) IBOutlet UIButton *btnShoe;
@property (retain, nonatomic) IBOutlet UIButton *btnHair;
@property (retain, nonatomic) IBOutlet UIButton *btnShirt;
@property (retain, nonatomic) IBOutlet UIButton *btnPant;
@property (retain, nonatomic) IBOutlet UIButton *btnGlass;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnSkin;
@property (retain, nonatomic) IBOutlet UIButton *btnHairColor;
@property (retain, nonatomic) IBOutlet UIButton *btnEyeColor;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollToolBar;

@property (retain, nonatomic) CustomAvatarView *avatarView;
@property (retain, nonatomic) HorizontalListView *listSubItemView;
@property (retain, nonatomic) NSMutableArray *subItems;
@property (retain, nonatomic) IBOutlet UIButton *btnBeard;

- (IBAction)btnShoe_touchUpInside:(id)sender;
- (IBAction)btnHair_touchUpInside:(id)sender;
- (IBAction)btnShirt_touchUpInside:(id)sender;
- (IBAction)btnPant_touchUpInside:(id)sender;
- (IBAction)btnGlass_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSkin_touchUpInside:(id)sender;
- (IBAction)btnHairColor_touchUpInside:(id)sender;
- (IBAction)btnEyeColor_touchUpInside:(id)sender;
- (IBAction)btnBear_touchUpInside:(id)sender;
- (IBAction)btnBearColor_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;
@end
