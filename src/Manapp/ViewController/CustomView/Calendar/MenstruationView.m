//
//  MenstruationView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "MenstruationView.h"
#import "Partner.h"
#import "NSDate+Helper.h"
#import "MASession.h"

@interface MenstruationView()

-(void) checkboxesChecked:(id) sender;

@end

@implementation MenstruationView
@synthesize txtFirstPeriod = _txtFirstPeriod;
@synthesize btnSave = _btnSave;
@synthesize btnBack = _btnBack;
@synthesize delegate;
@synthesize checkBoxYes = _checkBoxYes;


- (void)dealloc {
    self.delegate = nil;
    [_txtFirstPeriod release];
    [_btnSave release];
    [_btnBack release];
    [_checkBoxYes release];
    [_lblTitle release];
    [_lblLastPeriod release];
    [_lblBirthControl release];
    [_lblYes release];
    [_lblNo release];
    [_lblWarning release];
    [_btnFirstDay release];
    [super dealloc];
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

-(void) layoutSubviews{
    [super layoutSubviews];
    
    [self.btnBack.titleLabel setFont:[UIFont fontWithName:kAppFont size:12]];
    [self.btnSave.titleLabel setFont:[UIFont fontWithName:kAppFont size:12]];
    
    [self.lblTitle setFont:[UIFont fontWithName:kAppFont size:18]];
    [self.lblLastPeriod setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.lblBirthControl setFont:[UIFont fontWithName:kAppFont size:13]];
    [self.lblNo setFont:[UIFont fontWithName:kAppFont size:13]];
    [self.lblYes setFont:[UIFont fontWithName:kAppFont size:13]];
    [self.lblWarning setFont:[UIFont fontWithName:kAppFont size:11]];
    
    if(!self.checkBoxYes){
        _checkBoxYes = [[MACheckBoxButton alloc] initWithFrame:CGRectMake(288, 91, 25, 25) checkStateImage:[UIImage imageNamed:@"btnSexCheck"] unCheckStateImage:[UIImage imageNamed:@"btnSexUncheck"]];
        [self.checkBoxYes addTarget:self action:@selector(checkboxesChecked:) forControlEvents:UIControlEventTouchUpInside];
        [self.checkBoxYes setCheckWithState:YES];
        [self addSubview:self.checkBoxYes];
        
        if([MASession sharedSession].currentPartner){
            [self fillViewWithPartnerData:[MASession sharedSession].currentPartner];
        }
    }
}

#pragma mark - UI functions
-(void) fillViewWithPartnerData:(Partner *)partner{
    if(partner){
        if(partner.lastPeriod){
            self.txtFirstPeriod.text = [partner.lastPeriod stringWithStyle:MANAPP_DATETIME_DEFAULT_TYPE];
        }
        
        [self.checkBoxYes setCheckWithState:[partner.birthControl boolValue]];
    }
}

#pragma mark - event handler

- (void) checkboxesChecked:(id)sender{
    
}

- (IBAction)btnSave_touchUpInside:(id)sender {
    if([((NSObject *)self.delegate) respondsToSelector:@selector(menstruationViewDidTouchSaveButton:)]){
        [self.delegate menstruationViewDidTouchSaveButton:self];
    }
}

- (IBAction)btnBack_touchUpInside:(id)sender {
    if([((NSObject *)self.delegate) respondsToSelector:@selector(menstruationViewDidTouchBackButton:)]){
        [self.delegate menstruationViewDidTouchBackButton:self];
    }
}

- (IBAction)btnFirstDay_touchUpInside:(id)sender {
    [self.txtFirstPeriod becomeFirstResponder];
}
@end
