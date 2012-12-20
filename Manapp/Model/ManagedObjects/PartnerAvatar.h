//
//  PartnerAvatar.h
//  Manapp
//
//  Created by Demigod on 19/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Accessories, Bottom, Eye, Hair, Partner, Shoes, Skin, Top;

@interface PartnerAvatar : NSManagedObject

@property (nonatomic, retain) NSNumber * accessoriesID;
@property (nonatomic, retain) NSNumber * bottomID;
@property (nonatomic, retain) NSNumber * eyeID;
@property (nonatomic, retain) NSNumber * hairID;
@property (nonatomic, retain) NSNumber * partnerAvatarID;
@property (nonatomic, retain) NSNumber * partnerID;
@property (nonatomic, retain) NSNumber * shoesID;
@property (nonatomic, retain) NSNumber * skinID;
@property (nonatomic, retain) NSNumber * topID;
@property (nonatomic, retain) Accessories *fkPartnerAvatarToAccessories;
@property (nonatomic, retain) Bottom *fkPartnerAvatarToBottom;
@property (nonatomic, retain) Eye *fkPartnerAvatarToEye;
@property (nonatomic, retain) Hair *fkPartnerAvatarToHair;
@property (nonatomic, retain) Partner *fkPartnerAvatarToPartner;
@property (nonatomic, retain) Shoes *fkPartnerAvatarToShoes;
@property (nonatomic, retain) Skin *fkPartnerAvatarToSkin;
@property (nonatomic, retain) Top *fkPartnerAvatarToTop;

@end
