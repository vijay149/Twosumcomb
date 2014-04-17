//
//  AvatarSpecialZoneView.m
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "AvatarSpecialZoneView.h"
#import "MASession.h"
#import "SpecialZoneDTO.h"
#import "enum.h"
#import "ImageHelper.h"
#import "DatabaseHelper.h"
#import "AvatarHelper.h"
#import "GCDispatch.h"
#import "ImageHelper.h"
#import "ItemCategory.h"
#import "ItemToAvatar.h"
#import "UIColor-Expanded.h"
#import "ItemCategory.h"
#import "ItemToAvatar.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "PartnerMood.h"
#import "Item.h"
#import "ImageHelper.h"
#import "Global.h"



// USE IF EXITS HAIR.
static NSString *ERO_ZONE_HAIR = @"_ero_zone";
static NSString *HEAD_FOR = @"head_for_";
@interface AvatarSpecialZoneView() {
    BOOL isSaveEroZone;
    
}

- (NSString*) getImageURLFormat:(Partner*) partner;
- (void) addImageToAvatarOnEroZone: (MAEroZone) eroZone withSex: (int) sex;
- (UIImage*) getSkinColorForAvatar:(Partner*) partner withImage:(UIImage*) imageInput;
@end
@implementation AvatarSpecialZoneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.isTouchalble = YES;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.isTouchalble = YES;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapGesture];
    [tapGesture release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - tab gesture
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        if(_selectedZone){
            [self.delegate avatarSpecialZoneView:self didDoubleTouchZone:_selectedZone];
            [self highLightZone:_selectedZone];
           
        }
    }
}

#pragma mark - ero zone functions

//get the zone correspond with the current touching point
-(SpecialZoneDTO *) getZoneByPoint:(CGPoint) point{
    NSArray *zones = [self.delegate zonesForAvatarSpecialZoneView:self];
    for(SpecialZoneDTO *zone in zones){
        for(ZoneBoundDTO *bound in zone.zoneBounds){
            if(CGRectContainsPoint(bound.bound, point)){
                return zone;
            }
        }
    }
    
    return nil;
}

//reload the ui when touch a zone
-(void)didTouchZone:(SpecialZoneDTO *) zone{
    [[self delegate] avatarSpecialZoneView:self didTouchZone:zone];
    [self highLightZone:zone];
}

-(void) turnoffHighLight {
    UIView *mask = [self viewWithTag:MA_GRAY_MASK_VIEW_TAG];
    if(mask){
        [mask removeFromSuperview];
    }
}


/// !!!: showGrayedZone when Ero zone item non data.
- (void) showGrayedZone:(NSArray *) specialZone {
    [self turnoffHighLight];
    if (specialZone) {
        NSMutableArray *arraySpecialZone =  [[DatabaseHelper sharedHelper] getAllSpecialZoneNonPartnerEroZoneBySpecialZoneList:specialZone];
        if (arraySpecialZone) {
            for (SpecialZoneDTO *item in arraySpecialZone) {
                [self addImageToAvatarOnEroZone:item.zoneType withSex:item.sex];
            }
        }
    }
    
    if (_selectedZone) {
        [self highLightZone:_selectedZone];
    }
    
}

- (void) addImageToAvatarOnEroZone: (MAEroZone) eroZone withSex: (int) sex {
    NSString *imageNameMale = @"";
    NSString *imageNameFeMale = @"";
    switch (eroZone) {
        case MAEroZoneHead:
        {
            imageNameMale =   @"part_head_grayed_male_1";
            imageNameFeMale = @"part_head_grayed_female_2";

            
        }
            break;
        case MAEroZoneNeck:
        {
            imageNameMale = @"part_neck_grayed_male_1";
            imageNameFeMale = @"part_neck_grayed_female_2";
        }
            break;
        case MAEroZoneChest:
        {
            imageNameMale = @"part_chest_grayed_male_1";
            imageNameFeMale = @"part_chest_grayed_female_2";
        }
            break;
        case MAEroZoneLegLeft:
        {
            imageNameMale = @"part_leg_grayed_left_male_1";
            imageNameFeMale = @"part_leg_grayed_left_female_2";
        }
            break;
        case MAEroZoneLegRight:
        {
            imageNameMale = @"part_leg_grayed_right_male_1";
            imageNameFeMale = @"part_leg_grayed_right_female_2";
        }
            break;
        case MAEroZoneArmLeft:
        {
            imageNameMale = @"part_arm_grayed_left_male_1";
            imageNameFeMale = @"part_arm_grayed_left_female_2";
        }
            break;
        case MAEroZoneArmRight:
        {
            imageNameMale = @"part_arm_grayed_right_male_1";
            imageNameFeMale = @"part_arm_grayed_right_female_2";
        }
            break;
        case MAEroZoneHandLeft:
        {
            imageNameMale = @"part_hand_grayed_left_male_1";
            imageNameFeMale = @"part_hand_grayed_left_female_2";
        }
            break;
        case MAEroZoneHandRight:
        {
            imageNameMale = @"part_hand_grayed_right_male_1";
            imageNameFeMale = @"part_hand_grayed_right_female_2";
        }
            break;
        case MAEroZoneHip:
        {
//            imageNameMale = @"part_hip_grayed_male_1";
            imageNameMale = @"part_underware_male_1";

            imageNameFeMale = @"part_hip_grayed_female_2";
        }
            break;
        case MAEroZoneFootRight:
        {
            imageNameMale = @"part_foot_grayed_right_male_1";
            imageNameFeMale = @"part_foot_grayed_right_female_2";
        }
            break;
        case MAEroZoneFootLeft:
        {
            imageNameMale = @"part_foot_grayed_left_male_1";
            imageNameFeMale = @"part_foot_grayed_left_female_2";
            
        }
            break;
        case MAEroZoneWaist:
        {
            imageNameMale = @"part_waist_grayed_male_1";
            imageNameFeMale = @"part_waist_grayed_female_2";
            
        }
            break;
        case MAEroZoneThighLeft:
        {
            imageNameMale = @"part_thing_grayed_left_male_1";
            imageNameFeMale = @"part_thing_grayed_left_female_2";
            
        }
            break;
        case MAEroZoneThighRight:
        {
            imageNameMale = @"part_thing_grayed_right_male_1";
            imageNameFeMale = @"part_thing_grayed_right_female_2";
            
        }
            break;
        default:
            break;
    }
    UIView *viewMain = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    [viewMain setBackgroundColor:[UIColor clearColor]];
    if (eroZone == MAEroZoneHead) {
        viewMain.tag = 11;
    } else {
        viewMain.tag = eroZone;
    }
    if (![self viewWithTag:viewMain.tag]) {
        [self addSubview:viewMain];
    }
    
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *imgUnderware = nil;
    UIImage *imgItemEroZone = nil;
    NSString *partUnderware = @"";
    if(sex == 0) {
        imgItemEroZone = [UIImage imageNamed:imageNameFeMale];
        partUnderware = @"part_underware_special_zone_female_1";
        if (eroZone == MAEroZoneThighLeft || eroZone == MAEroZoneThighRight || eroZone == MAEroZoneHip || eroZone == MAEroZoneWaist) {
            imgUnderware = [UIImage imageNamed:partUnderware];
            imageView.image = [ImageHelper overlayImage:imgUnderware overImage:imgItemEroZone];
        } else {
            imageView.image = imgItemEroZone;
        }
    } else {
        imgItemEroZone = [UIImage imageNamed:imageNameMale];
        partUnderware = @"part_underware_male_1";
        if (eroZone == MAEroZoneThighLeft || eroZone == MAEroZoneThighRight || eroZone == MAEroZoneWaist) {
            imgUnderware = [UIImage imageNamed:partUnderware];
            imageView.image = [ImageHelper overlayImage:imgUnderware overImage:imgItemEroZone];
        } else {
            imageView.image = imgItemEroZone;
        }

    }
//    if (eroZone == MAEroZoneThighLeft || eroZone == MAEroZoneThighRight || eroZone == MAEroZoneHip || eroZone == MAEroZoneWaist) {
//        imgUnderware = [UIImage imageNamed:partUnderware];
//        imageView.image = [ImageHelper overlayImage:imgUnderware overImage:imgItemEroZone];
//    } else {
//        imageView.image = imgItemEroZone;
//    }
//    imageView.image = imgItemEroZone;
    [viewMain addSubview:imageView];
}

-(void) highLightZone:(SpecialZoneDTO *) zone {
    //have to remove the gray first
    [self turnoffHighLight];
    
    // COMMENT: create the gray mask for the view and put the part on top of it
    
    UIView *grayMask = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    grayMask.tag = MA_GRAY_MASK_VIEW_TAG;
//    [grayMask setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];// don't use boder gray
    [grayMask setBackgroundColor:[UIColor clearColor]];
    [self addSubview:grayMask];
    
//    CGFloat scale = 1;
//    if(IS_RETINA){
//        scale = 2;
//    }
    
    UIImageView *partImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)] autorelease];
    partImageView.contentMode = UIViewContentModeScaleAspectFill;
//    partImageView.image = zone.zoneImage;
    
    UIImage *imgUnderware = nil;
    NSLog(@"sex %d",zone.sex);
    UIImage *imgItemEroZone = nil;
    if(zone.sex == 0) {
        imgUnderware = [UIImage imageNamed:@"part_underware_special_zone_female_1"];
        if (zone.zoneType == MAEroZoneHead) {
            Partner *partner = [MASession sharedSession].currentPartner;
            if (partner) {
                NSString *imageURL = [self getImageURLFormat:partner];
                if (imageURL && imageURL.length > 0) {
                    imgItemEroZone = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",HEAD_FOR,imageURL]];
                    if (imgItemEroZone) {
                        partImageView.image = imgItemEroZone;
                    }
                } else {
                    partImageView.image = [ImageHelper overlayImage:imgUnderware overImage:zone.zoneImage];
                }
            }
        } else {
            partImageView.image = [ImageHelper overlayImage:imgUnderware overImage:zone.zoneImage];
        }
        
        //sample
//        partImageView.image = [ImageHelper overlayImage:[UIImage imageNamed:@"hair_sample_erozone"] overImage:zone.zoneImage];
    }
    else{
//        if (zone.zoneType == MAEroZoneHip || zone.zoneType == MAEroZoneLegLeft || zone.zoneType == MAEroZoneLegRight) {
//            imgUnderware = [UIImage imageNamed:@"part_underware_male_1"];
//            partImageView.image = [ImageHelper overlayImage:imgUnderware overImage:zone.zoneImage];
//        } else {
        
//        }
        if (zone.zoneType == MAEroZoneHead) {
            Partner *partner = [MASession sharedSession].currentPartner;
            if (partner) {
                NSString *imageURL = [self getImageURLFormat:partner];
                if (imageURL && imageURL.length > 0) {
                    imgItemEroZone = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",HEAD_FOR,imageURL]];
                    if (imgItemEroZone) {
                        partImageView.image = imgItemEroZone;
                    }
                } else {
                   partImageView.image = zone.zoneImage;
                }
            }
        } else {
            partImageView.image = zone.zoneImage;
        }
    }
    
    Partner *partner = [MASession sharedSession].currentPartner;
    if (partner) {
        UIImage *imageSkinColor =  [self getSkinColorForAvatar:partner withImage:partImageView.image];
        if (imageSkinColor) {
            partImageView.image = imageSkinColor;
        }
    }
    
    [grayMask addSubview:partImageView];
}

//getSkinColorForAvatar
- (UIImage*) getSkinColorForAvatar:(Partner*) partner withImage:(UIImage*) imageInput {
    UIImage *image = nil;
    if (imageInput) {
        if (partner) {
            if(partner.skinColor && ![partner.skinColor isEqualToString:@""]){
                UIColor *skinColor = [UIColor colorWithHexString:partner.skinColor];
                if(skinColor){
                    image = [ImageHelper changeImageColor:imageInput byMultiWithR:skinColor.red g:skinColor.green b:skinColor.blue a:1.0f];
                }
            }
        }
    }
    return image;
}

#pragma mark - touched event handle
/*********************************************************************************
 @Function description: get the data for the zone where we touch ( only do this if user selected a partner before)
 @Note:
 *********************************************************************************/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        return;
    }
    if(!self.isTouchalble){
        return;
    }
//    isSaveEroZone = NO;
    [self turnoffHighLight];
    NSArray *zones = [self.delegate zonesForAvatarSpecialZoneView:self];
    if(zones){
        for (UITouch *touch in [touches allObjects]) {
            CGPoint touchPoint = [touch locationInView:self];
            DLogInfo(@"x: %f",touchPoint.x);
            DLogInfo(@"y: %f",touchPoint.x);
            SpecialZoneDTO *selectedZone = [self getZoneByPoint:touchPoint];
            if(selectedZone){
                //if this is a new zone, reload the view
                if(_selectedZone.zoneType != selectedZone.zoneType || _selectedZone == nil) {
                    [self didTouchZone:selectedZone];
                }
                 _selectedZone = selectedZone;
            }
        }
    }
}

/*********************************************************************************
 @Function description: get the data for the zone where we move ( only do this if user selected a partner before)
 @Note:
 *********************************************************************************/
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!self.isTouchalble){
        return;
    }
    
    NSArray *zones = [self.delegate zonesForAvatarSpecialZoneView:self];
    if(zones){
        for (UITouch *touch in [touches allObjects]) {
            CGPoint touchPoint = [touch locationInView:self];
            SpecialZoneDTO *selectedZone = [self getZoneByPoint:touchPoint];
            if(selectedZone){
                
                //if this is a new zone, reload the view
                if(_selectedZone.zoneType != selectedZone.zoneType || _selectedZone == nil) {
                    [self didTouchZone:selectedZone];
                }
                _selectedZone = selectedZone;
            }
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // COMMNET: remove the highlight view if exist
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


//getHairImageForPartner
- (UIImage *)getHairImageForPartner:(Partner *)partner {
    UIImage *imgHair = nil;
    if (partner) {
        ItemCategory *hairCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
        if(hairCategory){
            ItemToAvatar *partnerHair = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:hairCategory];
            if(partnerHair){
                if(partnerHair.item.imageURLFormat && ![partnerHair.item.imageURLFormat isEqual:@""]){
                    //ERO_ZONE_HAIR
                    NSString *imageNameHair = [NSString stringWithFormat:partnerHair.item.imageURLFormat,2];
                    if (imageNameHair) {
                        DLogInfo(@"name hair: %@",[NSString stringWithFormat:@"%@%@",imageNameHair,ERO_ZONE_HAIR]);
                        imgHair = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",imageNameHair,ERO_ZONE_HAIR]];// type 2
                        if (imgHair) {
                            if(partnerHair.color && ![partnerHair.color isEqualToString:@""]){
                                UIColor *hairColor = [UIColor colorWithHexString:partnerHair.color];
                                if(hairColor){
                                    imgHair = [ImageHelper changeImageColor:imgHair byMultiWithR:hairColor.red g:hairColor.green b:hairColor.blue a:1.0f];
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    return imgHair;
}

- (NSString*) getImageURLFormat:(Partner*) partner {
    NSString *imageURLFormat = @"";
    if (partner) {
        ItemCategory *hairCategory = [[DatabaseHelper sharedHelper] getCategoryWithName:AVATAR_CATEGORY_HAIR];
        if(hairCategory){
            ItemToAvatar *partnerHair = [[DatabaseHelper sharedHelper] getItemForPartner:partner ofCategory:hairCategory];
            if(partnerHair){
                if(partnerHair.item.imageURLFormat && ![partnerHair.item.imageURLFormat isEqual:@""]){
                    //ERO_ZONE_HAIR
                    NSString *imageNameHair = [NSString stringWithFormat:partnerHair.item.imageURLFormat,2];
                    if (imageNameHair) {
                        DLogInfo(@"name hair: %@",[NSString stringWithFormat:@"%@%@",imageNameHair,ERO_ZONE_HAIR]);
                        imageURLFormat = [NSString stringWithFormat:@"%@%@",imageNameHair,ERO_ZONE_HAIR];
                    }
                    
                }
            }
        }
    }
    return imageURLFormat;
}



@end
