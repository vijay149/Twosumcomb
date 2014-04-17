//
//  SpecialZoneViewController.h
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MASession.h"
#import "DatabaseHelper.h"
#import "AvatarSpecialZoneView.h"
#import "UIPlaceHolderTextView.h"
#import "NSManagedObject+Clone.h"
@class SpecialZoneDTO;

@interface SpecialZoneViewController : BaseViewController<AvatarSpecialZoneViewDelegate, UITextViewDelegate,UIAlertViewDelegate>{
    
    NSMutableArray *partnerZoneInput;
    NSMutableArray *specialSelectedZoneArray;
    NSMutableArray *grayZoneArray;
    BOOL didSave;
    BOOL grayZoneHasChange;
    
}

@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *txtZoneDetail;
@property (retain, nonatomic) IBOutlet UIView *viewDetail;
@property (retain, nonatomic) IBOutlet UIButton *btnBackground;
@property (retain, nonatomic) IBOutlet AvatarSpecialZoneView *viewAvatar;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewBackground;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *txtAvatarItemDetail;
@property (retain, nonatomic) IBOutlet UILabel *lblAvatarItem;

@property (retain, nonatomic) IBOutlet UIImageView *imgAvatar;
@property (nonatomic, retain) NSArray *zones;
@property (nonatomic, strong) ErogeneousZone *selectedZone;
@end
