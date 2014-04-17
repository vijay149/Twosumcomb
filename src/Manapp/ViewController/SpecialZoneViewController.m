//
//  SpecialZoneViewController.m
//  Manapp
//
//  Created by Demigod on 20/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "SpecialZoneViewController.h"
#import "SpecialZoneDTO.h"
#import "AvatarHelper.h"
#import "ErogeneousZone.h"
#import "PartnerEroZone.h"
#import "UIView+Additions.h"
#import "NSString+Extension.h"
#import "UIColor-Expanded.h"
#import "ImageHelper.h"
#import "ItemCategory.h"
#import "ItemToAvatar.h"
#import "DatabaseHelper.h"
#import "Partner.h"
#import "PartnerMood.h"
#import "Item.h"
#import "ImageHelper.h"
#import "Global.h"

#define PARTNERZONETEXTORIGIN 82
#define DEFAULT_DETAIL @"Learn about my body! & store it here"
@interface SpecialZoneViewController () {
    SpecialZoneDTO *specialZoneSelectedToSave;
}
-(void) loadUI;
-(void) loadData;
- (void) removeSubViewByEroZoneType: (MAEroZone) eroZone;
- (UIImage*) getSkinColorForAvatar:(Partner*) partner;
- (void) customHair:(Partner*) partner isRemoveGrayedLayer:(BOOL) isRemoveGrayedLayer;
- (void) backAction;
@end

@implementation SpecialZoneViewController


- (void)dealloc {
    [_scrollViewBackground release];
    [_viewAvatar release];
    [_txtZoneDetail release];
    [_btnBackground release];
    [_viewDetail release];
    [_imgAvatar release];
    [_zones release];
    [specialZoneSelectedToSave release];
    [_txtAvatarItemDetail release];
    [_lblAvatarItem release];
    [specialSelectedZoneArray release];
    [partnerZoneInput release];
    [grayZoneArray release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    partnerZoneInput = [[NSMutableArray alloc] init];
    specialSelectedZoneArray = [[NSMutableArray alloc] init];
    grayZoneArray = [[NSMutableArray alloc] init];
    didSave = YES;
    grayZoneHasChange = NO;
    self.txtZoneDetail.placeholder = @"Learn about my body! & store it here";
    
    [self loadUI];
    [self loadZones];
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init functions
-(void) initialize{

}

#pragma mark - data functions
-(void) fillDataWithZone:(ErogeneousZone *) zone{
    self.txtZoneDetail.frame = CGRectMake(PARTNERZONETEXTORIGIN, self.txtZoneDetail.frame.origin.y, 320-PARTNERZONETEXTORIGIN, self.txtZoneDetail.frame.size.height);
    [self.txtZoneDetail setEditable:YES];
    self.lblAvatarItem.textAlignment = NSTextAlignmentRight;
    if([MASession sharedSession].currentPartner){
        PartnerEroZone *partnerEroZone = [self getPartnerEroZoneWithId:zone.erogeneousZoneID.integerValue];
        if(!partnerEroZone){
         PartnerEroZone *realPartnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:zone.erogeneousZoneID.integerValue];
            if (realPartnerEroZone) {
              partnerEroZone = [self addTemporaryPartnerZone:realPartnerEroZone.eroZoneID.integerValue andValue:realPartnerEroZone.value];
            }
        }
       // PartnerEroZone *partnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:zone.erogeneousZoneID.integerValue];
        if(partnerEroZone){
//            self.txtZoneDetail.text = [NSString stringWithFormat:@"%@: %@",zone.name ,partnerEroZone.value];
            self.txtZoneDetail.text = partnerEroZone.value;
            self.lblAvatarItem.text = [NSString stringWithFormat:@"%@:",zone.name];
        }
        else{
            self.lblAvatarItem.text = [NSString stringWithFormat:@"%@:",zone.name];
            self.txtZoneDetail.text = [NSString stringWithFormat:@""];            
        }
    }
}

#pragma mark - UI functions
-(void)loadUI {
    //change the back button
    [self createBackNavigationWithTitle:@"Home" action:@selector(backAction)];
    [self createRightNavigationWithTitle:@"Save" action:@selector(btnSave_touchUpInside:)];
    
    //avatar
    if([MASession sharedSession].currentPartner.sex.integerValue == MANAPP_SEX_MALE) {
        self.imgAvatar.image = [UIImage imageNamed:@"avatar_male_special_zone"];//avatar_male_special_zone, MaleAvatarEroZone
    } else {
        self.imgAvatar.image = [UIImage imageNamed:@"avatar_female_special_zone"];//avatar_female_special_zone,FemaleAvatarEroZone
    }

    if(!IS_IPHONE_5) {
        self.scrollViewBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, 480);
        self.viewDetail.frame = CGRectMake(0, kScreenHeight-88, self.viewDetail.frame.size.width, self.viewDetail.frame.size.height);
        self.viewAvatar.frame = CGRectMake(self.viewAvatar.frame.origin.x, 30, self.viewAvatar.frame.size.width, self.viewAvatar.frame.size.height);// y: 40
        [self.btnBackground setSize:self.scrollViewBackground.frame.size];
    } else {
        self.scrollViewBackground.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 20);
        self.viewDetail.frame = CGRectMake(0, kScreenHeight-88, self.viewDetail.frame.size.width, self.viewDetail.frame.size.height);
    }
    
    self.txtZoneDetail.frame = CGRectMake(0, self.txtZoneDetail.frame.origin.y, 320, self.txtZoneDetail.frame.size.height);
    
    DLogInfo(@"y view detail: %f",self.viewDetail.frame.origin.y);
}

//getSkinColorForAvatar
- (UIImage*) getSkinColorForAvatar:(Partner*) partner {
    UIImage *image = nil;
    if (partner) {
        if(partner.skinColor && ![partner.skinColor isEqualToString:@""]){
            UIColor *skinColor = [UIColor colorWithHexString:partner.skinColor];
            if(skinColor){
                image = [ImageHelper changeImageColor:self.imgAvatar.image byMultiWithR:skinColor.red g:skinColor.green b:skinColor.blue a:1.0f];
            }
        }
    }
    return image;
}

-(void)loadData {
    
    NSArray *partnerEroZones = [[DatabaseHelper sharedHelper] getPartnerEroZonesForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue];
    
    if(partnerEroZones.count <= 0) {
//        self.txtZoneDetail.text = [NSString stringWithFormat:LSSTRING(@"Click a body part to enter customized notes and reminders about %@'s body"),[MASession sharedSession].currentPartner.name];
        self.txtZoneDetail.text = LSSTRING(@"Click on a part of me and prove that you have been paying attention!");
    }
    NSInteger isEnough = [[DatabaseHelper sharedHelper] checkSpecialZoneStoredSpecialZoneListIsEnough:self.zones];
    if (isEnough == 2) {
//        [UserDefault setValue:[NSNumber numberWithInt:isEnough] forKey:kSpecialZoneEnough];
//        [UserDefault synchronize];
        self.txtZoneDetail.text = LSSTRING(@"You’re learning the keys to my body…. become the KEY master!!");
    } else {
//        [UserDefault setValue:[NSNumber numberWithInt:isEnough] forKey:kSpecialZoneEnough];
//        [UserDefault synchronize];
    }

}

#pragma mark - event handler
-(void)btnSave_touchUpInside:(id) sender{
    BOOL result = FALSE;
    if ([_txtZoneDetail isFirstResponder]) {
        [_txtZoneDetail resignFirstResponder];
    }
    if(self.selectedZone && [MASession sharedSession].currentPartner){
        if ([specialSelectedZoneArray count]>0 || grayZoneHasChange) {
             result = [self copyZoneFromTemporaryToPartnerWhenSaving];
           
        }
        if(result) {
//            NSInteger number = [[UserDefault objectForKey:kSpecialZoneEnough] integerValue];
//            if (number == 0) {
//                [UserDefault setValue:[NSNumber numberWithInt:1] forKey:kSpecialZoneEnough];
//                [UserDefault synchronize];
//            } else {
//                [UserDefault setValue:[NSNumber numberWithInt:2] forKey:kSpecialZoneEnough];
//                [UserDefault synchronize];
//            }
            didSave = YES;
            [self resignAllTextField];
            /*
            if (specialZoneSelectedToSave) {
                [self removeSubViewByEroZoneType:specialZoneSelectedToSave.zoneType];
            }
            [self.viewAvatar setNeedsDisplay];
            
            */
            [self showMessage:@"Successfully Saved!"];
        }
        else {
            // Cuongnt comment to change following
//            [self showMessage:@"Fail to save"];
            [self showMessage:@"Successfully Saved!"];
        }
    }
    
    for (SpecialZoneDTO *aSpecialZone in specialSelectedZoneArray) {
        [self removeSubViewByEroZoneType:aSpecialZone.zoneType];
        [self.viewAvatar setNeedsDisplay];
    }
    [specialSelectedZoneArray removeAllObjects];
    if (grayZoneHasChange) {
         [self.viewAvatar showGrayedZone:grayZoneArray];
        grayZoneHasChange = NO;
    }
    
    //[grayZoneArray removeAllObjects];
    
}

//removeSubViewByEroZoneType. remove  Grayed subview
- (void) removeSubViewByEroZoneType: (MAEroZone) eroZone {
    for (UIView *viewItem in self.viewAvatar.subviews) {
        NSLog(@"-------tag: %d",viewItem.tag);
        if ([viewItem isKindOfClass:[UIView class]] && viewItem.tag > 0) {
            if (viewItem.tag == 11 && eroZone == MAEroZoneHead) {// 11 = MAEroZoneHead because default tag = 0;
                [viewItem removeFromSuperview];
                [self customHair:nil isRemoveGrayedLayer:YES];
                break;
            } else if (viewItem.tag == eroZone) {
                [viewItem removeFromSuperview];
                break;
            }
        }
    }
}


#pragma mark - ero zone functions
//get zone list
-(void) loadZones {
    self.zones = [AvatarHelper eroZoneFromPlist:@"SpecialZone"];
    [[DatabaseHelper sharedHelper] generateZoneWithZoneList:self.zones forAvatarType:1 sex:[MASession sharedSession].currentPartner.sex.integerValue];
    // show grayed zone.
   // [grayZoneArray addObjectsFromArray:self.zones];
    
    [self.viewAvatar showGrayedZone:self.zones];
    
    // add Hair and skin color.
    Partner *partner = [MASession sharedSession].currentPartner;
    if (partner) {
        UIImage *imageAvatarWithSkin = [self getSkinColorForAvatar:partner];
        if (imageAvatarWithSkin) {
            self.imgAvatar.image = imageAvatarWithSkin;
        }
        [self customHair:partner isRemoveGrayedLayer:NO];
    }
   
}

// if Grayed Layer not remove , hair will use else hair will use self.imgAvatar.
- (void) customHair:(Partner*) partner isRemoveGrayedLayer:(BOOL) isRemoveGrayedLayer {
    if (!partner) {
        partner = [MASession sharedSession].currentPartner;
    }
    
    UIImage *imageHair = [self.viewAvatar getHairImageForPartner:partner];
    if (imageHair) {
        BOOL isExist = NO;
        for (UIView *viewItem in self.viewAvatar.subviews) {
            NSLog(@"tag: %d",viewItem.tag);
            if (viewItem.tag > 0 && viewItem.tag == 11) {// 11 = MAEroZoneHead because default tag = 0;
                isExist = YES;
                for (UIImageView *imageView in viewItem.subviews) {
                    if (imageView) {
                        UIImage *im = [ImageHelper overlayImage:imageHair overImage:imageView.image];
                        if (im) {
                            imageView.image = im;
                            break;
                        }
                    }
                }
                break;
            }
        }
        
        if (!isExist || isRemoveGrayedLayer) {
            UIImage *im = [ImageHelper overlayImage:imageHair overImage:self.imgAvatar.image];
            if (im) {
                self.imgAvatar.image = im;
            }
        }
    }
}


#pragma mark - avatar special zone delegate
-(NSArray *)zonesForAvatarSpecialZoneView:(AvatarSpecialZoneView *)view{
    if(self.zones && [[MASession sharedSession] currentPartner]){
        return self.zones;
    }
    else{
        return nil;
    }
}

-(void)avatarSpecialZoneView:(AvatarSpecialZoneView *)view didTouchZone:(SpecialZoneDTO *)zone{
    if([self.txtZoneDetail isFirstResponder]){
        [self.txtZoneDetail resignFirstResponder];
    }
    
    specialZoneSelectedToSave = zone;
    if(zone){
        self.selectedZone = [[DatabaseHelper sharedHelper] getEroZoneByTypeId:zone.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
        
        [self fillDataWithZone:self.selectedZone];
    }
    else{
        self.txtZoneDetail.text = @"Learn about my body! & store it here";
        self.lblAvatarItem.text = [NSString stringWithFormat:@"%@:",self.selectedZone.name];
//        self.txtZoneDetail.text = [NSString stringWithFormat:@"%@: %@",self.selectedZone.name ,@"Learn about my body! & store it here"];
    }
}

-(void)avatarSpecialZoneView:(AvatarSpecialZoneView *)view didDoubleTouchZone:(SpecialZoneDTO *)zone{
//    if ([_txtZoneDetail isFirstResponder]) {
//        return;
//    }
    if(zone){
        self.selectedZone = [[DatabaseHelper sharedHelper] getEroZoneByTypeId:zone.zoneType forPartner:[MASession sharedSession].currentPartner avatarType:1];
        
        [self fillDataWithZone:self.selectedZone];
        
        view.isTouchalble = NO;
        [self.txtZoneDetail becomeFirstResponder];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	self.viewDetail.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
    self.viewAvatar.isTouchalble = YES;
    if (textView == _txtZoneDetail) {
        if (![[Util trimSpace:_txtZoneDetail.text] isEqualToString:@""] &&![_txtZoneDetail.text  isEqualToString:DEFAULT_DETAIL]) {
            [self reloadHighLightArray];
        }else{
            PartnerEroZone *partnerEroZone = [self getPartnerEroZoneWithId:self.selectedZone.erogeneousZoneID.integerValue];
            if(!partnerEroZone){
                PartnerEroZone *realPartnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:self.selectedZone.erogeneousZoneID.integerValue];
                if (realPartnerEroZone) {
                    partnerEroZone = [self addTemporaryPartnerZone:realPartnerEroZone.eroZoneID.integerValue andValue:realPartnerEroZone.value];
                }
            }
            if (partnerEroZone) {
                if (![Util trimSpace:partnerEroZone.value].length == 0 ) {
                     [self reloadGrayZoneArray];
                }
            }
        }
         [self addTemporaryPartnerZone:self.selectedZone.erogeneousZoneID.integerValue andValue:_txtZoneDetail.text];
}

//	[textView resignFirstResponder];
//    [textView becomeFirstResponder];
    
    
}

#pragma mark - text view delegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    didSave = NO;
    _currentResponseView = textView;
    if(self.selectedZone && [MASession sharedSession].currentPartner){
        PartnerEroZone *partnerEroZone = [self getPartnerEroZoneWithId:self.selectedZone.erogeneousZoneID.integerValue];
        if(!partnerEroZone){
            PartnerEroZone *realPartnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:self.selectedZone.erogeneousZoneID.integerValue];
            if (realPartnerEroZone) {
                partnerEroZone = [self addTemporaryPartnerZone:realPartnerEroZone.eroZoneID.integerValue andValue:realPartnerEroZone.value];
            }
        }
        if(!partnerEroZone){
            self.txtZoneDetail.text = @"";
        }
    }
    else{
        self.txtZoneDetail.text = @"";
    }
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    self.viewDetail.transform = CGAffineTransformTranslate(self.viewDetail.transform, 0, -215);
	[UIView commitAnimations];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    /*
    // Any new character added is passed in as the "text" parameter
    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [self resignAllTextField];
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
     */
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

-(void)resignAllTextField {
    self.viewAvatar.isTouchalble = YES;
    [self.txtZoneDetail resignFirstResponder];
    
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"Hehe");
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) backAction {
    [self resignAllTextField];
    if (!didSave && [specialSelectedZoneArray count] !=0 ) {
        [self showMessage:@"You took the time to learn it. Do you want to take the time to save it?" title:@"TwoSum" cancelButtonTitle:@"NO" otherButtonTitle:@"YES" delegate:self tag:10];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - keyboard handler
// replace by textViewDidBeginEditing
//-(void)keyboardWillShow:(NSNotification *)notification{
//    [super keyboardWillShow:notification];
//    
//    [self.btnBackground setSize:self.scrollViewBackground.frame.size];
//    [self resizeScrollView:self.scrollViewBackground withKeyboardState:TRUE willChangeOffset:YES];
//    
//    //[self scrollView:self.scrollViewBackground changeOffsetToView:_currentResponseView];
//}
//
//-(void)keyboardWillHide{
//    [super keyboardWillHide];
//    
//    [self resizeScrollView:self.scrollViewBackground withKeyboardState:FALSE willChangeOffset:YES];
//    [self.btnBackground setSize:self.scrollViewBackground.frame.size];
//}
- (void)viewDidUnload {
    [self setImgAvatar:nil];
    [self setTxtAvatarItemDetail:nil];
    [self setLblAvatarItem:nil];
    [super viewDidUnload];
}
#pragma mark Partner Zone Process
- (void) clonePartnerEroZone:(NSArray*) partnerEroZoneArray
{
    partnerZoneInput = [[NSMutableArray alloc] init];
    for (PartnerEroZone *aZone in partnerEroZoneArray) {
        PartnerEroZone *newZone = [[DatabaseHelper sharedHelper] addFreePartnerEroZone:aZone.eroZoneID.integerValue andValue:aZone.value];
        [partnerZoneInput addObject:newZone];
    }
}
- (PartnerEroZone*) addTemporaryPartnerZone:(NSInteger) zoneID andValue:(NSString*) value
{
    PartnerEroZone *newZone = nil;
    for (PartnerEroZone *aEroZone in partnerZoneInput) {
        if (aEroZone.eroZoneID.integerValue == zoneID) {
            newZone = aEroZone;
            break;
        }
    }
    if (!newZone) {
        newZone = [[DatabaseHelper sharedHelper] addFreePartnerEroZone:zoneID andValue:value];
    }
    else{
        /*
        if (value.length >0) {
            newZone.value = value;
        }
        else{
            [partnerZoneInput removeObject:newZone];
            return newZone;
        }
         */
        newZone.value = value;
        
    }
    if (newZone) {
         [partnerZoneInput addObject:newZone];
    }
    return newZone;
}
-(BOOL) copyZoneFromTemporaryToPartnerWhenSaving
{
    BOOL result = FALSE;
    for (PartnerEroZone *aEroZone in partnerZoneInput) {
        PartnerEroZone *partnerEroZone = [[DatabaseHelper sharedHelper] getPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:aEroZone.eroZoneID.integerValue];
        if(partnerEroZone){
            if(aEroZone.value != nil && ![[Util trimSpace:aEroZone.value] isEqualToString:@""]){
                result = [[DatabaseHelper sharedHelper] editPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:aEroZone.eroZoneID.integerValue withValue:aEroZone.value];
            }
            else
            {
                result = [[DatabaseHelper sharedHelper] deleteManagedObject:partnerEroZone];
            }
        }
        //create new if it is not existed
        else{
            if(aEroZone.value != nil && ![[Util trimSpace:aEroZone.value] isEqualToString:@""]){
                PartnerEroZone *partnerEroZone = [[DatabaseHelper sharedHelper] addPartnerEroZoneForPartner:[MASession sharedSession].currentPartner.partnerID.integerValue andZone:aEroZone.eroZoneID.integerValue withValue:aEroZone.value];
                
                if(partnerEroZone){
                    result = TRUE;
                }
            }
        }
        result = [[DatabaseHelper sharedHelper] deleteManagedObject:aEroZone];
    }
    [partnerZoneInput removeAllObjects];
    return result;
}
- (void) removeTemporaryPartnerEroZoneArray
{
     for (PartnerEroZone *aEroZone in partnerZoneInput)
     {
         [[DatabaseHelper sharedHelper] deleteManagedObject:aEroZone];
     }
}
- (BOOL) partnerEroHasChanges
{
    BOOL result = NO;
    for (PartnerEroZone *aEroZone in partnerZoneInput)
    {
        if (aEroZone) {
            result = YES;
        }
    }
    return result;
}
- (PartnerEroZone*) getPartnerEroZoneWithId:(NSInteger) zoneID
{
    for (PartnerEroZone *aEroZone in partnerZoneInput) {
        if (aEroZone.eroZoneID.integerValue == zoneID) {
            return aEroZone;
        }
    }
    return nil;
}
- (void) reloadGrayZoneArray
{
    if (![grayZoneArray containsObject:specialZoneSelectedToSave] ) {
        grayZoneHasChange = YES;
        [grayZoneArray addObject:specialZoneSelectedToSave];
    }
    if ([specialSelectedZoneArray containsObject:specialZoneSelectedToSave]) {
        [specialSelectedZoneArray removeObject:specialZoneSelectedToSave];
    }
}

-(void) reloadHighLightArray
{
    if (![specialSelectedZoneArray containsObject:specialZoneSelectedToSave]) {
        [specialSelectedZoneArray addObject:specialZoneSelectedToSave];
    }
    if ([grayZoneArray containsObject:specialZoneSelectedToSave]) {
        [grayZoneArray removeObject:specialZoneSelectedToSave];
        grayZoneHasChange = YES;
    }
}

#pragma mark UIAlertDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10) {
        switch (buttonIndex) {
            case 0:{
                [self removeTemporaryPartnerEroZoneArray];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case 1:{
                BOOL saveResult = [self copyZoneFromTemporaryToPartnerWhenSaving];
                if (saveResult) {
                    [self showMessage:@"Successfully Saved!"];
                }
                else {
                    [self showMessage:@"Fail to save"];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
            default:
                break;
        }
    }
}
@end
