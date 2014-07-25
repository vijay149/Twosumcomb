//
//  EventsView.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

@class EventsView;
@class EventItemView;

@protocol EventsViewDelegate

@optional
-(void) didTouchAddEventButtonInEventsView:(EventsView*) view;
-(void) didTouchMenstrationButtonInEventsView:(EventsView*) view;
-(void) didTouchRemoveEventButtonInEventsView:(EventsView*) view;

@end

@interface EventsView : UIView{
    
}

@property (retain, nonatomic) IBOutlet UIView *viewFertle;
@property (retain, nonatomic) IBOutlet UIView *viewMenstrating;
@property (retain, nonatomic) IBOutlet UIView *viewCalendar;
@property (retain, nonatomic) IBOutlet UILabel *lblFertle;
@property (retain, nonatomic) IBOutlet UILabel *lblMenstrating;
@property (retain, nonatomic) IBOutlet UILabel *lblCalendar;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollViewEvents;
@property (retain, nonatomic) IBOutlet UIButton *btnAddEvent;
@property (retain, nonatomic) IBOutlet UIButton *btnMenstration;
@property (retain, nonatomic) IBOutlet UIButton *btnRemoveEvent;

@property (retain, nonatomic) id<EventsViewDelegate> delegate;
@property (retain, nonatomic) NSMutableArray *events;

- (IBAction)btnRemoveEvent_touchUpInside:(id)sender;
- (IBAction)btnAddEvent_touchUpInside:(id)sender;
- (IBAction)btnMenstration_touchUpInside:(id)sender;

- (void) reloadViewWithEvents:(NSArray *) events;

@end
