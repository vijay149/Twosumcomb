//
//  AvatarViewController.m
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "AvatarViewController.h"

@interface AvatarViewController ()

@end

@implementation AvatarViewController
@synthesize btnShoe = _btnShoe;
@synthesize btnHair = _btnHair;
@synthesize btnShirt = _btnShirt;
@synthesize btnPant = _btnPant;
@synthesize btnEye = _btnEye;
@synthesize btnBack = _btnBack;
@synthesize btnSave = _btnSave;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_btnShoe release];
    [_btnHair release];
    [_btnShirt release];
    [_btnPant release];
    [_btnEye release];
    [_btnBack release];
    [_btnSave release];
    [super dealloc];
}

#pragma mark - event handler
- (IBAction)btnShoe_touchUpInside:(id)sender {
}

- (IBAction)btnHair_touchUpInside:(id)sender {
}

- (IBAction)btnShirt_touchUpInside:(id)sender {
}

- (IBAction)btnPant_touchUpInside:(id)sender {
}

- (IBAction)btnEye_touchUpInside:(id)sender {
}

- (IBAction)btnBack_touchUpInside:(id)sender {
}

- (IBAction)btnSave_touchUpInside:(id)sender {
}
@end
