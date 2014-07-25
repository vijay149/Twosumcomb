//
//  EventsView.m
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import "EventsView.h"
#import "UIView+Additions.h"
#import "EventItemView.h"

@implementation EventsView
@synthesize viewFertle = _viewFertle;
@synthesize viewMenstrating = _viewMenstrating;
@synthesize viewCalendar = _viewCalendar;
@synthesize lblFertle = _lblFertle;
@synthesize lblMenstrating = _lblMenstrating;
@synthesize lblCalendar = _lblCalendar;
@synthesize scrollViewEvents = _scrollViewEvents;
@synthesize btnAddEvent = _btnAddEvent;
@synthesize btnMenstration = _btnMenstration;
@synthesize btnRemoveEvent = _btnRemoveEvent;
@synthesize delegate;

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

-(void)layoutSubviews{
    [self.lblCalendar setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.lblFertle setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
    [self.lblMenstrating setFont:[UIFont fontWithName:@"BankGothic Md BT" size:12]];
}

- (void)dealloc {
    self.delegate = nil;
    [_viewFertle release];
    [_viewMenstrating release];
    [_viewCalendar release];
    [_lblFertle release];
    [_lblMenstrating release];
    [_lblCalendar release];
    [_scrollViewEvents release];
    [_btnAddEvent release];
    [_btnMenstration release];
    [_btnRemoveEvent release];
    [super dealloc];
}

#pragma mark - UI functions
-(void)reloadViewWithEvents:(NSArray *)events{
    //remove all subview
    [self.scrollViewEvents removeAllSubviews];
    
    //add new one
    if(!events || events.count == 0){
        EventItemView *itemView = [[[EventItemView alloc] initWithFrame:CGRectMake(0, 0, self.scrollViewEvents.frame.size.width, self.scrollViewEvents.frame.size.height)] autorelease];
        itemView.lblEventTitle.text = @"There is no event";
        itemView.lblEventDescription.text = @"";
        [self.scrollViewEvents addSubview:itemView];
    }
    else{
        
    }
}

#pragma mark - event handler
- (IBAction)btnRemoveEvent_touchUpInside:(id)sender {
    [self.delegate didTouchRemoveEventButtonInEventsView:self];
}

- (IBAction)btnAddEvent_touchUpInside:(id)sender {
    [self.delegate didTouchAddEventButtonInEventsView:self];
}

- (IBAction)btnMenstration_touchUpInside:(id)sender {
    [self.delegate didTouchMenstrationButtonInEventsView:self];
}
@end
