//
//  EventItemView.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Event;

@interface EventItemView : UIView{
    
}

@property (retain, nonatomic) UILabel *lblEventTitle;
@property (retain, nonatomic) UILabel *lblEventDescription;
@property (retain, nonatomic) UILabel *lblEventTime;
@property (retain, nonatomic) UIImageView *imgBackground;

-(void) fillViewWithEvent:(Event *) event;

@end
