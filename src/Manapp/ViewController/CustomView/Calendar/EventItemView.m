//
//  EventItemView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "EventItemView.h"
#import "MADeviceUtil.h"
#import "Event.h"
#import "NSDate+Helper.h"
#import "MACommon.h"

@implementation EventItemView
@synthesize lblEventTitle = _lblEventTitle;
@synthesize lblEventDescription = _lblEventDescription;
@synthesize imgBackground = _imgBackground;
@synthesize lblEventTime = _lblEventTime;


- (void)dealloc {
    [_lblEventTitle release];
    [_lblEventDescription release];
    [_imgBackground release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _imgBackground = [[UIImageView alloc] init];
        _lblEventDescription = [[UILabel alloc] init];
        _lblEventTitle = [[UILabel alloc] init];
        _lblEventTime = [[UILabel alloc] init];
        
        //[self addSubview:self.imgBackground];
        [self addSubview:self.lblEventDescription];
        [self addSubview:self.lblEventTitle];
        [self addSubview:self.lblEventTime];
    }
    return self;
}

-(void)layoutSubviews{
    //background
    self.imgBackground.frame = self.frame;
    self.imgBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imgBackground.image = [UIImage imageNamed:@"bgDetailView"];
    
    //label title
    self.lblEventTitle.frame = CGRectMake(0, 0, 320, 20);
    self.lblEventTitle.backgroundColor = [UIColor clearColor];
    self.lblEventTitle.textColor = [UIColor whiteColor];
    [self.lblEventTitle setFont:[UIFont fontWithName:kAppFont size:15]];
    self.lblEventTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
        self.lblEventTitle.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.lblEventTitle.textAlignment = UITextAlignmentCenter;
    }
    
    //label description
    self.lblEventDescription.frame = CGRectMake(0, 25, 320, 20);
    self.lblEventDescription.backgroundColor = [UIColor clearColor];
    self.lblEventDescription.textColor = [UIColor whiteColor];
    [self.lblEventDescription setFont:[UIFont fontWithName:kAppFont size:15]];
    self.lblEventDescription.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
        self.lblEventDescription.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.lblEventDescription.textAlignment = UITextAlignmentCenter;
    }
    
    //label time
    self.lblEventTime.frame = CGRectMake(0, 45, 320, 20);
    self.lblEventTime.backgroundColor = [UIColor clearColor];
    self.lblEventTime.textColor = [UIColor whiteColor];
    [self.lblEventTime setFont:[UIFont fontWithName:kAppFont size:15]];
    self.lblEventTime.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if([MADeviceUtil getDeviceIOSVersionNumber] >= 6.0f){
        self.lblEventTime.textAlignment = NSTextAlignmentCenter;
    }
    else{
        self.lblEventTime.textAlignment = UITextAlignmentCenter;
    }
}

#pragma mark - functions
-(void) fillViewWithEvent:(Event *) event{
    self.lblEventTitle.text = event.eventName;
    self.lblEventDescription.text = [event.eventTime toString];
    self.lblEventTime.text = [event.eventTime toTimeString];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
