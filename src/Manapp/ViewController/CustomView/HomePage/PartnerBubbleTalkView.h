//
//  PartnerBubbleTalkView.h
//  Manapp
//
//  Created by Demigod on 07/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PagedFlowView.h"
#import "PartnerBubbleTalk.h"

@class Message;

#define MANAPP_PARTNER_BUBBLE_TALK_EVENT_ITEM_PADDING_VERTICAL 10
#define MANAPP_PARTNER_BUBBLE_TALK_MAXIMUM_HEIGHT 109
#define MANAPP_PARTNER_BUBBLE_TALK_MINIMUM_HEIGHT 60
#define MANAPP_PARTNER_BUBBLE_TALK_WIDTH          166
@interface PartnerBubbleTalkView : PagedFlowView{
    
}

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (strong, nonatomic) Message *tip;
@property (strong, nonatomic) PartnerBubbleTalk *partnerBubbleTalk;
-(void) reloadBubbleTalk;

@end
