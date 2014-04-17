//
//  MAAvatarView.m
//  TwoSum
//
//  Created by Demigod on 02/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MAAvatarView.h"
#import "ImageHelper.h"
#import "UIColor-Expanded.h"
#import "Partner.h"
#import "MASession.h"
#import "AvatarHelper.h"

@implementation MAAvatarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAvatarBody];
}

-(void) layoutIfNeeded{
    [super layoutIfNeeded];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAvatarBody];
}

-(void) dealloc{
    [super dealloc];
    [_imgViewBody release];
}

#pragma mark - public functions
-(void)reload{
    [self layoutIfNeeded];
}

-(void)reloadWithSessionColor{
    [self loadColor];
    [self layoutIfNeeded];
}

#pragma mark - init functions
-(void) initialize{
    [self loadColor];
}

-(void) loadColor{
    self.bodyColor = RGB(253, 238, 244);
    NSNumber *red = [[NSUserDefaults standardUserDefaults] objectForKey:@"skinRed"];
    NSNumber *green = [[NSUserDefaults standardUserDefaults] objectForKey:@"skinGreen"];
    NSNumber *blue = [[NSUserDefaults standardUserDefaults] objectForKey:@"skinBlue"];
    
    if(red && green && blue){
        self.bodyColor = [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1];
    }
}

#pragma mark - avatar creator functions
-(void) setAvatarBody{
    if(!self.imgViewBody){
        //create the image view
        _imgViewBody = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgViewBody.backgroundColor = [UIColor clearColor];
        self.imgViewBody.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imgViewBody];
    }
    
    if([MASession sharedSession].currentPartner.sex.boolValue == MANAPP_SEX_MALE){
        UIImage *imgBody = [AvatarHelper avatarBodyForPartner:[MASession sharedSession].currentPartner];
        UIImage *imgUnderware = [AvatarHelper underwareForPartner:[MASession sharedSession].currentPartner];
        
        UIImage *imgBodyWithColor = [ImageHelper changeImageColor:imgBody byMultiWithR:self.bodyColor.red g:self.bodyColor.green b:self.bodyColor.blue a:1.0f];
        UIImage *imgAvatar = [ImageHelper overlayImage:imgUnderware overImage:imgBodyWithColor];
        
        self.imgViewBody.image = imgAvatar;
    }
    else{
        UIImage *imgBody = [AvatarHelper avatarBodyForPartner:[MASession sharedSession].currentPartner];
        UIImage *imgBodyWithColor = [ImageHelper changeImageColor:imgBody byMultiWithR:self.bodyColor.red g:self.bodyColor.green b:self.bodyColor.blue a:1.0f];
        
        self.imgViewBody.image = imgBodyWithColor;
    }
}

@end
