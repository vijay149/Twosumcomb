//
//  enum.h
//  MobileCRM
//
//  Created by Demigod on 04/02/2013.
//  Copyright (c) 2013 Setacinq. All rights reserved.
//

#ifndef ManApp_enum_h
#define ManApp_enum_h

//ero zone type
typedef enum {
    MAEroZoneHead              = 0,
    MAEroZoneNeck              = 1,
    MAEroZoneChest             = 2,
    MAEroZoneLegLeft           = 31,
    MAEroZoneLegRight          = 32,
    MAEroZoneArmLeft           = 41,
    MAEroZoneArmRight          = 42,
    MAEroZoneHandLeft          = 51,
    MAEroZoneHandRight         = 52,
    MAEroZoneHip               = 6,
    MAEroZoneFootLeft          = 71,
    MAEroZoneFootRight         = 72,
//    MAEroZoneBreast            = 2,
    MAEroZoneWaist             = 3,
    MAEroZoneThighLeft         = 4,
    MAEroZoneThighRight        = 5,
} MAEroZone;

//AvatarItemType
typedef enum {
	AvatarItemTypeHair        = 1,
    AvatarItemTypeGlass       = 2,
    AvatarItemTypeShoe        = 3,
    AvatarItemTypeShirt       = 4,
    AvatarItemTypePant        = 5,
    AvatarItemTypeSkinColor   = 6,
    AvatarItemTypeEyeColor    = 7,
    AvatarItemTypeHairColor   = 8,
    AvatarItemTypeBear        = 9,
    AvatarItemTypeBearColor   = 10,
} AvatarItemType;



#endif
