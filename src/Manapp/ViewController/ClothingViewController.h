//
//  ClothingViewController.h
//  Manapp
//
//  Created by Demigod on 15/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

typedef enum {
    MAClothingViewTypeShoe          = 0,
    MAClothingViewTypeHair          = 1,
    MAClothingViewTypeShirt         = 2,
    MAClothingViewTypePant          = 3,
    MAClothingViewTypeEye           = 4
} MAClothingViewType;

@interface ClothingViewController : BaseViewController{
    MAClothingViewType _clothingType;
}

@property (retain, nonatomic) IBOutlet UIImageView *imageIcon;
@property (retain, nonatomic) IBOutlet UILabel *lblViewTitle;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollItems;
@property (retain, nonatomic) IBOutlet UIButton *btnNone;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)btnNone_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;

- (id)initWithtType:(MAClothingViewType) type;

@end
