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

@interface AvatarViewController : BaseViewController

@property (retain, nonatomic) IBOutlet UIButton *btnShoe;
@property (retain, nonatomic) IBOutlet UIButton *btnHair;
@property (retain, nonatomic) IBOutlet UIButton *btnShirt;
@property (retain, nonatomic) IBOutlet UIButton *btnPant;
@property (retain, nonatomic) IBOutlet UIButton *btnEye;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;

- (IBAction)btnShoe_touchUpInside:(id)sender;
- (IBAction)btnHair_touchUpInside:(id)sender;
- (IBAction)btnShirt_touchUpInside:(id)sender;
- (IBAction)btnPant_touchUpInside:(id)sender;
- (IBAction)btnEye_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;
- (IBAction)btnSave_touchUpInside:(id)sender;

@end
