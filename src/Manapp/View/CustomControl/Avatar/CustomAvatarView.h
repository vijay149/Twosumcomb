//
//  CustomAvatarView.h
//  TwoSum
//
//  Created by Demigod on 24/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enum.h"

@class Partner;
@class Item;

@interface CustomAvatarView : UIView{
    
}

@property (retain, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (retain, nonatomic) IBOutlet UIView *viewHair;
@property (retain, nonatomic) IBOutlet UIView *viewShoe;
@property (retain, nonatomic) IBOutlet UIView *viewPant;
@property (retain, nonatomic) IBOutlet UIView *viewShirt;
@property (retain, nonatomic) IBOutlet UIView *viewGlass;
@property (retain, nonatomic) IBOutlet UIView *viewAccessory;
@property (retain, nonatomic) IBOutlet UIView *viewBear;
@property (retain, nonatomic) IBOutlet UIImageView *imgHair;
@property (retain, nonatomic) IBOutlet UIImageView *imgShoe;
@property (retain, nonatomic) IBOutlet UIImageView *imgPant;
@property (retain, nonatomic) IBOutlet UIImageView *imgShirt;
@property (retain, nonatomic) IBOutlet UIImageView *imgGlass;
@property (retain, nonatomic) IBOutlet UIImageView *imgAccessory;
@property (retain, nonatomic) IBOutlet UIImageView *imgBear;

@property (retain, nonatomic) Partner *partner;
@property (assign, nonatomic) BOOL isPreview;
@property (retain, nonatomic) Item *itemHairPreview;
@property (retain, nonatomic) Item *itemShoePreview;
@property (retain, nonatomic) Item *itemPantPreview;
@property (retain, nonatomic) Item *itemShirtPreview;
@property (retain, nonatomic) Item *itemGlassPreview;
@property (retain, nonatomic) Item *itemAccessoryPreview;
@property (retain, nonatomic) Item *itemBearPreview;
@property (retain, nonatomic) UIColor *colorSkinPreview;
@property (retain, nonatomic) UIColor *colorHairPreview;
@property (retain, nonatomic) UIColor *colorEyePreview;
@property (retain, nonatomic) UIColor *colorBeardPreview;
@property (assign, nonatomic) AvatarItemType currentAvatarItemType;
@property (retain, nonatomic) Item *abstractItem;
@property (retain, nonatomic) CustomAvatarView *currentViewAvatar;
- (void)loadAvatarForPartner:(Partner *)partner;
- (void)loadPreviewAvatarForPartner:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item;
- (void)reload;
- (void)saveFromPreview;
- (void)reloadWithPartner:(Partner *)partner;
- (UIImage *) getPreviewAvatarImageForPartner:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item;
- (UIImage *)getAvatarImageForPartner:(Partner *)partner withPose:(NSInteger) pose;
- (void)reloadPartnerPreviewMood:(Partner *)partner withPose:(NSInteger) pose;
- (void)loadAvatarForPartnerPreviewMood:(Partner *)partner withPose:(NSInteger) pose;
- (void) generateAvatarForPreviewMood: (void(^)(BOOL)) blockResult;
@end
