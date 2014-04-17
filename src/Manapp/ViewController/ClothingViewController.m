//
//  ClothingViewController.m
//  Manapp
//
//  Created by Demigod on 15/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "ClothingViewController.h"

@interface ClothingViewController ()
-(void) loadUI;
@end

@implementation ClothingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithtType:(MAClothingViewType) type
{
    self = [self initWithNibName:@"ClothingViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _clothingType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_imageIcon release];
    [_lblViewTitle release];
    [_scrollItems release];
    [_btnNone release];
    [_btnSave release];
    [_btnBack release];
    [super dealloc];
}

#pragma mark - loading functions
-(void) loadUI{
    [self.scrollItems setContentSize:CGSizeMake(self.scrollItems.frame.size.width, self.scrollItems.frame.size.height + 70)];
    
    switch (_clothingType) {
        case MAClothingViewTypeEye:
        {
            self.imageIcon.image = [UIImage imageNamed:@"btnGlass"];
            self.lblViewTitle.text = @"Eye & Glass";
        }
            break;
        case MAClothingViewTypeHair:
        {
            self.imageIcon.image = [UIImage imageNamed:@"btnComb"];
            self.lblViewTitle.text = @"Hair";
        }
            break;
        case MAClothingViewTypePant:
        {
            self.imageIcon.image = [UIImage imageNamed:@"btnTrouser"];
            self.lblViewTitle.text = @"Pant";
        }
            break;
        case MAClothingViewTypeShirt:
        {
            self.imageIcon.image = [UIImage imageNamed:@"btnClothing"];
            self.lblViewTitle.text = @"Shirt";
        }
            break;
        case MAClothingViewTypeShoe:
        {
            self.imageIcon.image = [UIImage imageNamed:@"btnShoe"];
            self.lblViewTitle.text = @"Shoe";
        }
            break;
        default:
            break;
    }
}

#pragma mark - event handler
- (IBAction)btnNone_touchUpInside:(id)sender {
}

- (IBAction)btnBack_touchUpInside:(id)sender {
    [self back];
}

- (IBAction)btnSave_touchUpInside:(id)sender {
}
@end
