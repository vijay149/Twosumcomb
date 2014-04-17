//
//  AvatarSpecialZoneView.h
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MADeviceUtil.h"
#import "Partner.h"

#define MA_GRAY_MASK_VIEW_TAG 1000

@class AvatarSpecialZoneView;
@class SpecialZoneDTO;

@protocol AvatarSpecialZoneViewDelegate

@optional
-(NSArray *) zonesForAvatarSpecialZoneView:(AvatarSpecialZoneView *) view;
-(void) avatarSpecialZoneView:(AvatarSpecialZoneView *) view didTouchZone:(SpecialZoneDTO *)zone;
-(void) avatarSpecialZoneView:(AvatarSpecialZoneView *) view didDoubleTouchZone:(SpecialZoneDTO *)zone;
@end

@interface AvatarSpecialZoneView : UIView{
    SpecialZoneDTO *_selectedZone;
}
@property (nonatomic, assign) BOOL isTouchalble;
@property (nonatomic, strong) IBOutlet id<AvatarSpecialZoneViewDelegate> delegate;

-(void) turnoffHighLight;
- (void) showGrayedZone:(NSArray *) specialZone;
- (UIImage *)getHairImageForPartner:(Partner *)partner;
@end
