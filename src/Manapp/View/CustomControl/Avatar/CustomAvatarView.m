//
//  CustomAvatarView.m
//  TwoSum
//
//  Created by Demigod on 24/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "CustomAvatarView.h"
#import "Partner.h"
#import "DatabaseHelper.h"
#import "PartnerMood.h"
#import "ItemCategory.h"
#import "Item.h"
#import "ImageHelper.h"
#import "ItemToAvatar.h"
#import "UIColor-Expanded.h"
#import "MASession.h"
#import "MoodHelper.h"
#import "FileUtil.h"
#import "GCDispatch.h"

#define kImageURLFormatPantSkirtTennisFemale @"pant_skirt_tennis_female_%d"
#define kImageURLFormatShirtDressFemale @"shirt_dress_female_%d"
#define kImageNameShirtDressSpecialFemale @"shirt_dress_special_female_%d"
// for Tutu
#define kImageNameShirtDressForTuTuFemale @"shirt_dress_for_tutu_female_%d"
#define kImageNamePantTuTuFemale @"pant_tutu_female_%d"

@interface CustomAvatarView()


- (void) isShirtDressAndPantTennisOrTuTuWithPartner:(Partner *)partner;
@end

@implementation CustomAvatarView

- (void)dealloc {
    [_imgAvatar release];
    [_viewHair release];
    [_viewShoe release];
    [_viewPant release];
    [_viewShirt release];
    [_viewGlass release];
    [_viewAccessory release];
    [_partner release];
    [_imgHair release];
    [_imgShoe release];
    [_imgPant release];
    [_imgShirt release];
    [_imgGlass release];
    [_imgAccessory release];
    [_itemAccessoryPreview release];
    [_itemGlassPreview release];
    [_itemHairPreview release];
    [_itemPantPreview release];
    [_itemShirtPreview release];
    [_itemShoePreview release];
    [_colorEyePreview release];
    [_colorSkinPreview release];
    [_colorHairPreview release];
    [_colorBeardPreview release];
    [_abstractItem release];
    [_currentViewAvatar release];
    [super dealloc];
}

#pragma mark - avata functions
- (void)loadAvatarForPartner:(Partner *)partner{
    self.partner = partner;
    
    //avatar
    self.imgAvatar.image = [self getAvatarImageForPartner:partner];
    if(self.imgAvatar.image){
        self.imgHair.image = [self getHairImageForPartner:partner];
        self.imgGlass.image = [self getGlassImageForPartner:partner];
        self.imgShirt.image = [self getShirtImageForPartner:partner];
        self.imgPant.image = [self getPantImageForPartner:partner];
        self.imgShoe.image = [self getShoeImageForPartner:partner];
        self.imgBear.image = [self getBearImageForPartner:partner];
        [self isShirtDressAndPantTennisOrTuTuWithPartner:partner];
    }

}

//WhenChangeMood
- (void)loadAvatarForPartnerPreviewMood:(Partner *)partner withPose:(NSInteger) pose {
    self.partner = partner;
    //avatar
    self.imgAvatar.image = [self getAvatarImageForPartner:partner withPose:pose];
    if(self.imgAvatar.image){
        self.imgHair.image = [self getHairImageForPartner:partner withPose:pose];
        self.imgGlass.image = [self getGlassImageForPartner:partner withPose:pose];
        self.imgShirt.image = [self getShirtImageForPartner:partner withPose:pose];
        self.imgPant.image = [self getPantImageForPartner:partner withPose:pose];
        self.imgShoe.image = [self getShoeImageForPartner:partner withPose:pose];
        self.imgBear.image = [self getBearImageForPartner:partner withPose:pose];
        [self isShirtDressAndPantTennisOrTuTuWithPartner:partner withPose:pose];
    }
    
}

- (void)loadPreviewAvatarForPartner:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item{
    self.partner = partner;
    self.imgAvatar.image = [self getPreviewAvatarImageForPartner:partner withAvatarItemType:avatarItemType withItem:item];
    if(self.imgAvatar.image){
        self.imgHair.image = [self getPreviewHairImageForPartner:partner];
        self.imgGlass.image = [self getPreviewGlassImageForPartner:partner];
        self.imgShirt.image = [self getPreviewShirtImageForPartner:partner];
        self.imgPant.image = [self getPreviewPantImageForPartner:partner];
        self.imgShoe.image = [self getPreviewShoeImageForPartner:partner];
        self.imgBear.image = [self getPreviewBearImageForPartner:partner];
        [self isShirtDressAndPantTennisOrTuTuWithPartner:partner];
    }
}

- (void)loadPreviewAvatarForPartnerPreviewMood:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item withPose:(NSInteger) pose {
    self.partner = partner;
    self.imgAvatar.image = [self getPreviewAvatarImageForPartner:partner withAvatarItemType:avatarItemType withItem:item withPose:pose];
    if(self.imgAvatar.image){
        self.imgHair.image = [self getPreviewHairImageForPartner:partner withPose:pose];
        self.imgGlass.image = [self getPreviewGlassImageForPartner:partner withPose:pose];
        self.imgShirt.image = [self getPreviewShirtImageForPartner:partner withPose:pose];
        self.imgPant.image = [self getPreviewPantImageForPartner:partner withPose:pose];
        self.imgShoe.image = [self getPreviewShoeImageForPartner:partner withPose:pose];
        self.imgBear.image = [self getPreviewBearImageForPartner:partner withPose:pose];
        [self isShirtDressAndPantTennisOrTuTuWithPartner:partner withPose:pose];
    }
}

- (void) isShirtDressAndPantTennisOrTuTuWithPartner:(Partner *)partner {
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    [self isShirtDressAndPantTennisOrTuTuWithPartner:partner withPose:pose];
}

- (void)reload{
    self.imgAccessory.image = nil;
    self.imgAvatar.image = nil;
    self.imgGlass.image = nil;
    self.imgHair.image = nil;
    self.imgPant.image = nil;
    self.imgShirt.image = nil;
    self.imgShoe.image = nil;
    self.imgBear.image = nil;
    
    if(self.isPreview){
        [self loadPreviewAvatarForPartner:self.partner withAvatarItemType:self.currentAvatarItemType withItem:self.abstractItem];
    }
    else{
        [self loadAvatarForPartner:self.partner];
    }
}

- (void)reloadWhenPreviewMood:(NSInteger) pose {
    self.imgAccessory.image = nil;
    self.imgAvatar.image = nil;
    self.imgGlass.image = nil;
    self.imgHair.image = nil;
    self.imgPant.image = nil;
    self.imgShirt.image = nil;
    self.imgShoe.image = nil;
    self.imgBear.image = nil;
    if(self.isPreview){
        [self loadPreviewAvatarForPartnerPreviewMood:self.partner withAvatarItemType:self.currentAvatarItemType withItem:self.abstractItem withPose:pose];
    }
    else{
        [self loadAvatarForPartnerPreviewMood:self.partner withPose:pose];
    }
    
}

- (void) generateAvatarForPreviewMood: (void(^)(BOOL)) blockResult {
    [[Util sharedUtil] showLoadingView];
    [GCDispatch performBlockInBackgroundQueue:^{
        for (int i = 0; i < 5; i++) {
            [self reloadPartnerPreviewMood:self.partner withPose:i];
//            UIImage *result = [ImageHelper saveAnUIViewToImage:self];
//            if (result) {
//                UIImage *imageOverlay = [ImageHelper overlayImage:self.imgShirt.image overImage:result];
//                if (imageOverlay) {
//                    NSString *imageName = [NSString stringWithFormat:@"avatar_male_preview_mood_%d",i];
//                    if([[MASession sharedSession] currentPartner].sex.integerValue == MANAPP_SEX_FEMALE) {
//                        imageName = [NSString stringWithFormat:@"avatar_female_preview_mood_%d",i];
//                    }
//                    [FileUtil saveImage:imageOverlay toDocumentWithName:imageName];// save image to document
////                    UIImageWriteToSavedPhotosAlbum([FileUtil imageInDocumentWithName:imageName], nil, nil, nil);
//                }
//            }
            
            UIImage *result = [ImageHelper saveAnUIViewToImage:self];
            if (result) {
                NSString *imageName = [NSString stringWithFormat:@"avatar_male_preview_mood_%d",i];
                if([[MASession sharedSession] currentPartner].sex.integerValue == MANAPP_SEX_FEMALE) {
                    imageName = [NSString stringWithFormat:@"avatar_female_preview_mood_%d",i];
                }
                [FileUtil saveImage:result toDocumentWithName:imageName];// save image to document
                //                    UIImageWriteToSavedPhotosAlbum([FileUtil imageInDocumentWithName:imageName], nil, nil, nil);
            }

        }
    } completion:^{
        blockResult(YES);
        [[Util sharedUtil] hideLoadingView];
    }];
}

- (void)saveFromPreview {
    
    if(self.itemGlassPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemGlassPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_GLASS];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.itemAccessoryPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemAccessoryPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_ACCESSORY];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.itemHairPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemHairPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.itemPantPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemPantPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_PANT];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.itemShirtPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemShirtPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHIRT];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.itemShoePreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemShoePreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHOE];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }
    
    if(self.colorSkinPreview){
        [[DatabaseHelper sharedHelper] changeSkinColorForPartner:[MASession sharedSession].currentPartner toColor:self.colorSkinPreview];
    }
    
    if(self.itemBearPreview){
        [[DatabaseHelper sharedHelper] addItem:self.itemBearPreview toPartner:[MASession sharedSession].currentPartner];
    }
    else{
        ItemCategory *category = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
        [[DatabaseHelper sharedHelper] removeItemOfCategory:category fromPartner:[MASession sharedSession].currentPartner];
    }

    // remove this function.
//    if(self.colorEyePreview){
//        [[DatabaseHelper sharedHelper] changeEyeColorForPartner:[MASession sharedSession].currentPartner toColor:self.colorEyePreview];
//    }
    
    if(self.colorHairPreview){
        [[DatabaseHelper sharedHelper] changeHairColorForPartner:[MASession sharedSession].currentPartner toColor:self.colorHairPreview];
    }
//    if(self.colorBeardPreview){
//        [[DatabaseHelper sharedHelper] changeBeardColorForPartner:[MASession sharedSession].currentPartner toColor:self.colorBeardPreview];
//    }
}

- (void)reloadWithPartner:(Partner *)partner{
    self.partner = partner;
    [self reload];
}

- (void)reloadPartnerPreviewMood:(Partner *)partner withPose:(NSInteger) pose {
    self.partner = partner;
    [self reloadWhenPreviewMood:pose];
}

- (UIImage *)getHairImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getHairImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewHairImageForPartner:(Partner *)partner {
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    if(self.itemHairPreview){
        if (self.itemHairPreview.imageURLFormat) {
            UIImage *imgHair = [UIImage imageNamed:[NSString stringWithFormat:self.itemHairPreview.imageURLFormat,pose]];
            if(self.colorHairPreview){
                imgHair = [ImageHelper changeImageColor:imgHair byMultiWithR:self.colorHairPreview.red g:self.colorHairPreview.green b:self.colorHairPreview.blue a:1.0f];
            }
            return imgHair;
        }
    }
    
    return nil;
}

- (UIImage *)getPreviewHairImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    if(self.itemHairPreview){
        if (self.itemHairPreview.imageURLFormat) {
            UIImage *imgHair = [UIImage imageNamed:[NSString stringWithFormat:self.itemHairPreview.imageURLFormat,pose]];
            if(self.colorHairPreview){
                imgHair = [ImageHelper changeImageColor:imgHair byMultiWithR:self.colorHairPreview.red g:self.colorHairPreview.green b:self.colorHairPreview.blue a:1.0f];
            }
            return imgHair;
        }
    }
    
    return nil;
}

- (UIImage *)getBeardImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    
    //beard
    ItemCategory *beardCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
    if(beardCategory){
        ItemToAvatar *partnerBeard = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:beardCategory];
        if(partnerBeard){
            self.itemBearPreview = partnerBeard.item;
            if(partnerBeard.item.imageURLFormat && ![partnerBeard.item.imageURLFormat isEqual:@""]){
                UIImage *imgBeard = [UIImage imageNamed:[NSString stringWithFormat:partnerBeard.item.imageURLFormat,pose]];
                
                if(partnerBeard.color && ![partnerBeard.color isEqualToString:@""]){
                    UIColor *beardColor = [UIColor colorWithHexString:partnerBeard.color];
                    self.colorBeardPreview = beardColor;
                    if(beardColor){
                        imgBeard = [ImageHelper changeImageColor:imgBeard byMultiWithR:beardColor.red g:beardColor.green b:beardColor.blue a:1.0f];
                    }
                }
                return imgBeard;
            }
        }
    }
    
    return nil;
}

- (UIImage *)getPreviewBeardImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    if(self.itemBearPreview){
        if (self.itemBearPreview.imageURLFormat) {
            UIImage *imgBeard = [UIImage imageNamed:[NSString stringWithFormat:self.itemBearPreview.imageURLFormat,pose]];
            if(self.colorBeardPreview){
                imgBeard = [ImageHelper changeImageColor:imgBeard byMultiWithR:self.colorBeardPreview.red g:self.colorBeardPreview.green b:self.colorBeardPreview.blue a:1.0f];
            }
            return imgBeard;
        }
    }
    return nil;
}

- (UIImage *)getGlassImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getGlassImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewGlassImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewGlassImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewGlassImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    if(self.itemGlassPreview){
        UIImage *imgGlass = [UIImage imageNamed:[NSString stringWithFormat:self.itemGlassPreview.imageURLFormat,pose]];
        
        return imgGlass;
    }
    
    return nil;
}

- (UIImage *)getShirtImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getShirtImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewShirtImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewShirtImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewShirtImageForPartner:(Partner *)partner withPose: (NSInteger) pose {
    if(self.itemShirtPreview){
        UIImage *imgShirt = [UIImage imageNamed:[NSString stringWithFormat:self.itemShirtPreview.imageURLFormat,pose]];
        
        return imgShirt;
    }
    return nil;
}

- (UIImage *)getPantImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPantImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewPantImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewPantImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewPantImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    if(self.itemPantPreview){
        UIImage *imgPant = [UIImage imageNamed:[NSString stringWithFormat:self.itemPantPreview.imageURLFormat,pose]];
        
        return imgPant;
    }
    return nil;
}

- (UIImage *)getShoeImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getShoeImageForPartner:partner withPose:pose];
}


- (UIImage *)getPreviewShoeImageForPartner:(Partner *)partner{
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewShoeImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewShoeImageForPartner:(Partner *)partner withPose: (NSInteger) pose {
    if(self.itemShoePreview){
        UIImage *imgShoe = [UIImage imageNamed:[NSString stringWithFormat:self.itemShoePreview.imageURLFormat,pose]];
        return imgShoe;
    }
    return nil;
}

- (UIImage *)getBearImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    ItemCategory *bearCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
    if(bearCategory){
        ItemToAvatar *partnerBear = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:bearCategory];
        if(partnerBear){
            self.itemBearPreview = partnerBear.item;
            if(partnerBear.item.imageURLFormat && ![partnerBear.item.imageURLFormat isEqual:@""]){
                UIImage *imgBear = [UIImage imageNamed:[NSString stringWithFormat:partnerBear.item.imageURLFormat,pose]];
                return imgBear;
            }
        }
    }
    return nil;
}


- (UIImage *)getPreviewBearImageForPartner:(Partner *)partner{
   // CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewBearImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewBearImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    if(self.itemBearPreview){
        UIImage *imgBear = [UIImage imageNamed:[NSString stringWithFormat:self.itemBearPreview.imageURLFormat,pose]];
        return imgBear;
    }
    return nil;
}


- (UIImage *)getAvatarImageForPartner:(Partner *)partner{
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getAvatarImageForPartner:partner withPose:pose];
}

- (UIImage *)getPreviewAvatarImageForPartner:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item{
    
    CGFloat mood = [[DatabaseHelper sharedHelper] getTodayMoodOfPartner:partner];
    //CGFloat mood = [[DatabaseHelper sharedHelper] partnerMoodWithPartner:partner date:[NSDate date]].moodValue.floatValue;
    NSInteger pose = [MoodHelper getPoseByMood:mood];
    return [self getPreviewAvatarImageForPartner:partner withAvatarItemType:avatarItemType withItem:item withPose:pose];
}
- (UIImage *)getPreviewAvatarImageForPartner:(Partner *)partner withAvatarItemType: (AvatarItemType) avatarItemType withItem:(Item*)item withPose:(NSInteger) pose {
    UIImage *imgBody = nil;
    if(partner.sex.boolValue == MANAPP_SEX_MALE){
        imgBody = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_male_%d",pose]];
    }
    else{
        imgBody = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_female_%d",pose]];
    }
    
    //attach body and underware
    if(imgBody){
        if(self.colorSkinPreview){
            imgBody = [ImageHelper changeImageColor:imgBody byMultiWithR:self.colorSkinPreview.red g:self.colorSkinPreview.green b:self.colorSkinPreview.blue a:1.0f];
        }
        //underware
        UIImage *imgUnderware = nil;
        if (item) {
            if(partner.sex.boolValue == MANAPP_SEX_MALE) {
                if(!self.itemPantPreview) {
                    imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_male_%d",pose]];
                }
            }
            else{
                switch (avatarItemType) {
                    case AvatarItemTypeShirt:
                        if (!self.itemShirtPreview ) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        } else if(!self.itemPantPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }
                        break;
                    case AvatarItemTypePant:
                        if (!self.itemPantPreview ) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        } else if (!self.itemShirtPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }
                        break;
                    case AvatarItemTypeBearColor:
                    case AvatarItemTypeEyeColor:
                    case AvatarItemTypeHair:
                    case AvatarItemTypeGlass:
                    case AvatarItemTypeShoe:
                    case AvatarItemTypeHairColor:
                    case AvatarItemTypeSkinColor:
                        if(!self.itemShirtPreview && !self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
                        } else if(!self.itemShirtPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }else if(!self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }
                        break;
                    default:
                        break;
                }
                
            }
        } else {
            if(partner.sex.boolValue == MANAPP_SEX_MALE){
                if(!self.itemPantPreview) {
                    imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_male_%d",pose]];
                }
            }
            else{
                switch (avatarItemType) {
                    case AvatarItemTypeShirt:
                        if(!self.itemShirtPreview && !self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
                        } else if(!self.itemShirtPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }else if(!self.itemPantPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }
                        break;
                    case AvatarItemTypePant:
                        if(!self.itemShirtPreview && !self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
                        } else if(!self.itemShirtPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }else if(!self.itemPantPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }
                        break;
                    case AvatarItemTypeBearColor:
                    case AvatarItemTypeEyeColor:
                    case AvatarItemTypeHair:
                    case AvatarItemTypeGlass:
                    case AvatarItemTypeShoe:
                    case AvatarItemTypeHairColor:
                    case AvatarItemTypeSkinColor:
                        if(!self.itemShirtPreview && !self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
                        } else if(!self.itemShirtPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }else if(!self.itemPantPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }
                        break;
                    default:
                        if(!self.itemShirtPreview && !self.itemPantPreview) {
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
                        } else if(!self.itemShirtPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
                        }else if(!self.itemPantPreview){
                            imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
                        }

                        break;
                }
            }
        }
        UIImage *imgAvatar = nil;
        if (imgUnderware) {
            imgAvatar = [ImageHelper overlayImage:imgUnderware overImage:imgBody];
        }
        
        
        //eye
        UIImage *imgEye = nil;
        if(partner.sex.boolValue == MANAPP_SEX_MALE){
            imgEye = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_male_eye_%d",pose]];
        }
        else{
            imgEye = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_female_eye_%d",pose]];
        }
        
        if(imgEye){
            if(self.colorEyePreview){
                imgEye = [ImageHelper changeImageColor:imgEye byMultiWithR:self.colorEyePreview.red g:self.colorEyePreview.green b:self.colorEyePreview.blue a:1.0f];
            }
            //underware
            if (imgAvatar) {
                imgAvatar = [ImageHelper overlayImage:imgEye overImage:imgAvatar];
            } else {
                imgAvatar = [ImageHelper overlayImage:imgEye overImage:imgBody];
            }
            
        }
        return imgAvatar;
    }
    
    return nil;
}

- (UIImage *)getAvatarImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    UIImage *imgBody = nil;
    if(partner.sex.boolValue == MANAPP_SEX_MALE){
        imgBody = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_male_%d",pose]];
    }
    else{
        imgBody = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_female_%d",pose]];
    }
    
    //attach body and underware
    if(imgBody){
        if(partner.skinColor && ![partner.skinColor isEqualToString:@""]){
            UIColor *skinColor = [UIColor colorWithHexString:partner.skinColor];
            self.colorSkinPreview = skinColor;
            if(skinColor){
                imgBody = [ImageHelper changeImageColor:imgBody byMultiWithR:skinColor.red g:skinColor.green b:skinColor.blue a:1.0f];
            }
        }
        //underware
        UIImage *imgUnderware = nil;
        if(partner.sex.boolValue == MANAPP_SEX_MALE){
            UIImage *getPants = [self getPantImageForPartner:partner];
            if (!getPants) {
                imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_male_%d",pose]];
            }
        }
        else{
            UIImage *getShirt = [self getShirtImageForPartner:partner];
            UIImage *getPants = [self getPantImageForPartner:partner];
            if (!getPants && !getShirt) {
                imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underware_female_%d",pose]];
            } else if (!getShirt) {
                imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"undershirt_female_%d",pose]];
            } else if (!getPants) {
                imgUnderware = [UIImage imageNamed:[NSString stringWithFormat:@"underpants_female_%d",pose]];
            }
        }
        UIImage *imgAvatar = nil;
        if (imgUnderware) {
            imgAvatar = [ImageHelper overlayImage:imgUnderware overImage:imgBody];
        }
        //eye
        UIImage *imgEye = nil;
        if(partner.sex.boolValue == MANAPP_SEX_MALE){
            imgEye = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_male_eye_%d",pose]];
        }
        else{
            imgEye = [UIImage imageNamed:[NSString stringWithFormat:@"avatar_female_eye_%d",pose]];
        }
        
        if(imgEye){
            if(partner.eyeColor && ![partner.eyeColor isEqualToString:@""]){
                UIColor *eyeColor = [UIColor colorWithHexString:partner.eyeColor];
                self.colorEyePreview = eyeColor;
                if(eyeColor){
                    imgEye = [ImageHelper changeImageColor:imgEye byMultiWithR:eyeColor.red g:eyeColor.green b:eyeColor.blue a:1.0f];
                }
            }
            //underware
            if (imgAvatar) {
                imgAvatar = [ImageHelper overlayImage:imgEye overImage:imgAvatar];
            } else {
                imgAvatar = [ImageHelper overlayImage:imgEye overImage:imgBody];
            }
        }
        return imgAvatar;
    }
    
    return nil;
}

- (UIImage *)getHairImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    //hair
    ItemCategory *hairCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
    if(hairCategory){
        ItemToAvatar *partnerHair = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:hairCategory];
        if(partnerHair){
            self.itemHairPreview = partnerHair.item;
            if(partnerHair.item.imageURLFormat && ![partnerHair.item.imageURLFormat isEqual:@""]){
                UIImage *imgHair = [UIImage imageNamed:[NSString stringWithFormat:partnerHair.item.imageURLFormat,pose]];
                
                if(partnerHair.color && ![partnerHair.color isEqualToString:@""]){
                    UIColor *hairColor = [UIColor colorWithHexString:partnerHair.color];
                    self.colorHairPreview = hairColor;
                    if(hairColor){
                        imgHair = [ImageHelper changeImageColor:imgHair byMultiWithR:hairColor.red g:hairColor.green b:hairColor.blue a:1.0f];
                    }
                }
                return imgHair;
            }
        }
    }
    
    return nil;
}


- (UIImage *)getGlassImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    ItemCategory *glassCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_GLASS];
    if(glassCategory){
        ItemToAvatar *partnerGlass = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:glassCategory];
        if(partnerGlass){
            self.itemGlassPreview = partnerGlass.item;
            if(partnerGlass.item.imageURLFormat && ![partnerGlass.item.imageURLFormat isEqual:@""]){
                UIImage *imgGlass = [UIImage imageNamed:[NSString stringWithFormat:partnerGlass.item.imageURLFormat,pose]];
                return imgGlass;
            }
        }
    }
    
    return nil;
}


- (UIImage *)getShirtImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    ItemCategory *shirtCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHIRT];
    if(shirtCategory){
        ItemToAvatar *partnerShirt = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:shirtCategory];
        if(partnerShirt){
            self.itemShirtPreview = partnerShirt.item;
            if(partnerShirt.item.imageURLFormat && ![partnerShirt.item.imageURLFormat isEqual:@""]){
                UIImage *imgShirt = [UIImage imageNamed:[NSString stringWithFormat:partnerShirt.item.imageURLFormat,pose]];
                return imgShirt;
            }
        }
    }
    
    return nil;
}


- (UIImage *)getPantImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    ItemCategory *pantCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_PANT];
    if(pantCategory){
        ItemToAvatar *partnerPant = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:pantCategory];
        if(partnerPant){
            self.itemPantPreview = partnerPant.item;
            if(partnerPant.item.imageURLFormat && ![partnerPant.item.imageURLFormat isEqual:@""]){
                UIImage *imgPant = [UIImage imageNamed:[NSString stringWithFormat:partnerPant.item.imageURLFormat,pose]];
                return imgPant;
            }
        }
    }
    
    return nil;
}


- (UIImage *)getShoeImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    ItemCategory *shoeCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_SHOE];
    if(shoeCategory){
        ItemToAvatar *partnerShoe = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:shoeCategory];
        if(partnerShoe){
            self.itemShoePreview = partnerShoe.item;
            if(partnerShoe.item.imageURLFormat && ![partnerShoe.item.imageURLFormat isEqual:@""]){
                UIImage *imgShoe = [UIImage imageNamed:[NSString stringWithFormat:partnerShoe.item.imageURLFormat,pose]];
                return imgShoe;
            }
        }
    }
    
    return nil;
}


- (UIImage *)getBearImageForPartner:(Partner *)partner withPose:(NSInteger) pose {
    ItemCategory *bearCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_BEARD];
    if(bearCategory){
        ItemToAvatar *partnerBear = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:bearCategory];
        if(partnerBear){
            self.itemBearPreview = partnerBear.item;
            if(partnerBear.item.imageURLFormat && ![partnerBear.item.imageURLFormat isEqual:@""]){
                UIImage *imgBear = [UIImage imageNamed:[NSString stringWithFormat:partnerBear.item.imageURLFormat,pose]];
                return imgBear;
            }
        }
    }
    
    return nil;
}


- (void) isShirtDressAndPantTennisOrTuTuWithPartner:(Partner *)partner withPose:(NSInteger) pose {
    if (partner.sex.integerValue == 1) {
        return;
    }
    if (self.itemPantPreview && self.itemPantPreview.imageURLFormat && self.itemShirtPreview && self.itemShirtPreview.imageURLFormat) {
        NSLog(@"self.itemPantPreview.imageURLFormat %@",self.itemPantPreview.imageURLFormat);
        NSLog(@"self.itemShirtPreview.imageURLFormat %@",self.itemShirtPreview.imageURLFormat);
        NSString *imageURLFormatPant = self.itemPantPreview.imageURLFormat;
        NSString *imageURLFormatShirt = self.itemShirtPreview.imageURLFormat;
        
        if (imageURLFormatPant && imageURLFormatShirt && [imageURLFormatPant isEqualToString:kImageURLFormatPantSkirtTennisFemale] && [imageURLFormatShirt isEqualToString:kImageURLFormatShirtDressFemale]) {
            self.imgShirt.image = [UIImage imageNamed:[NSString stringWithFormat:self.itemPantPreview.imageURLFormat,pose]];
            self.imgPant.image = [UIImage imageNamed:[NSString stringWithFormat:kImageNameShirtDressSpecialFemale,pose]];
        }
        if (imageURLFormatPant && imageURLFormatShirt && [imageURLFormatPant isEqualToString:kImageNamePantTuTuFemale] && [imageURLFormatShirt isEqualToString:kImageURLFormatShirtDressFemale]) {
            self.imgShirt.image = [UIImage imageNamed:[NSString stringWithFormat:self.itemPantPreview.imageURLFormat,pose]];
            self.imgPant.image = [UIImage imageNamed:[NSString stringWithFormat:kImageNameShirtDressForTuTuFemale,pose]];
        }
    }
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
