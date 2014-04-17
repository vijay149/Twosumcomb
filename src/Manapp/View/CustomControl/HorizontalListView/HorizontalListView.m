//
//  HorizontalListView.m
//  TwoSum
//
//  Created by Demigod on 04/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "HorizontalListView.h"
#import "UIView+Additions.h"

@implementation HorizontalListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) dealloc{
    [super dealloc];
    self.delegate = nil;
    self.datasource = nil;
    [_scrollView release];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    [self layoutScroll];
    [self layoutItems];
}

-(void)layoutIfNeeded {
    [super layoutIfNeeded];
    
    [self layoutScroll];
    [self layoutItems];
}

#pragma mark - public functions
-(void)reloadData {
    [self layoutIfNeeded];
}

#pragma mark - UIFunction
-(void) layoutScroll {
    if(!self.scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        
        [self addSubview:self.scrollView];
    }
}

-(void) layoutItems {
    [[self scrollView] removeAllSubviews];
    NSInteger numberOfItems = [self.datasource numberOfItemsInHorizontalListView:self];
    CGFloat currentOffset = 0;
    for(NSInteger i = 0; i < numberOfItems; i++){
        CGFloat itemWidth = [self.datasource horizontalListView:self widthForItemAtIndex:i];
        NSLog(@"width %f",itemWidth);
        //place holder for item
        UIView *viewItem = [[[UIView alloc] initWithFrame:CGRectMake(currentOffset, 0, itemWidth, self.scrollView.frame.size.height)] autorelease];
        viewItem.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:viewItem];
        
        if(viewItem.frame.origin.x + viewItem.frame.size.width > self.scrollView.contentSize.width){
            [self.scrollView setContentSize:CGSizeMake(viewItem.frame.origin.x + viewItem.frame.size.width, self.scrollView.contentSize.height)];
        }
        
        HorizontalListViewItem *item = [self.datasource horizontalListView:self itemAtIndex:i];
        item.tag = i;
        [item setOrigin:CGPointMake(0, 0)];
        [viewItem removeAllSubviews];
        [viewItem addSubview:item];
        
        UIButton *btnItem = [[UIButton alloc] initWithFrame:viewItem.frame];
        btnItem.backgroundColor = [UIColor clearColor];
        btnItem.tag = i;
        [btnItem addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnItem];
        
        //inscreasee the offset
        currentOffset += itemWidth + [self.datasource paddingBetweenItemsInHorizontalListView:self];
    }
}

#pragma mark - event
-(void) itemClicked:(id)sender{
    if([((NSObject *)self.delegate) respondsToSelector:@selector(horizontalListView:didTouchItemAtIndex:withButton:)]){
        UIButton *btnSender = (UIButton *) sender;
        [self.delegate horizontalListView:self didTouchItemAtIndex:btnSender.tag withButton:btnSender];
    }
}


@end
