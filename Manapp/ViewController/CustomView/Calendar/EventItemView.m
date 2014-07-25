//
//  EventItemView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "EventItemView.h"
#import "MADeviceUtil.h"

@implementation EventItemView
@synthesize lblEventTitle = _lblEventTitle;
@synthesize lblEventDescription = _lblEventDescription;
@synthesize imgBackground = _imgBackground;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.imgBackground = [[UIImageView alloc] init];
        self.lblEventDescription = [[UILabel alloc] init];
        self.lblEventTitle = [[UILabel alloc] init];
        
        [self addSubview:self.imgBackground];
        [self addSubview:self.lblEventDescription];
        [self addSubview:self.lblEventTitle];
    }
    return self;
}

-(void)layoutSubviews{
    //background
    self.imgBackground.frame = self.frame;
    self.imgBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imgBackground.image = [UIImage imageNamed:@"bgDetailView"];
    
    //label title
    self.lblEventTitle.frame = CGRectMake(0, 0, 320, 37);
    self.lblEventTitle.backgroundColor = [UIColor clearColor];
    self.lblEventTitle.textColor = [UIColor whiteColor];
    [self.lblEventTitle setFont:[UIFont fontWithName:@"BankGothic Md BT" size:22]];
    self.lblEventTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
        self.lblEventTitle.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.lblEventTitle.textAlignment = UITextAlignmentCenter;
    }
    
    //label description
    self.lblEventDescription.frame = CGRectMake(0, 45, 320, 21);
    self.lblEventDescription.backgroundColor = [UIColor clearColor];
    self.lblEventDescription.textColor = [UIColor whiteColor];
    [self.lblEventDescription setFont:[UIFont fontWithName:@"BankGothic Md BT" size:15]];
    self.lblEventDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
        self.lblEventDescription.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.lblEventDescription.textAlignment = UITextAlignmentCenter;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_lblEventTitle release];
    [_lblEventDescription release];
    [_imgBackground release];
    [super dealloc];
}
@end
