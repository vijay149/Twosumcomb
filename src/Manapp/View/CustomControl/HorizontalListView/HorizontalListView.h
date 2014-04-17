//
//  HorizontalListView.h
//  TwoSum
//
//  Created by Demigod on 04/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalListViewItem.h"

@class HorizontalListView;

@protocol HorizontalListViewDatasource

@optional
-(NSInteger) numberOfItemsInHorizontalListView:(HorizontalListView *) view;
-(CGFloat) paddingBetweenItemsInHorizontalListView:(HorizontalListView *) view;
-(CGFloat) horizontalListView:(HorizontalListView *) listView widthForItemAtIndex:(NSInteger) index;
-(HorizontalListViewItem*) horizontalListView:(HorizontalListView *) listView itemAtIndex:(NSInteger) index;
@end

@protocol HorizontalListViewDelegate

@optional
-(void) horizontalListView:(HorizontalListView *) listView didTouchItemAtIndex:(NSInteger) index withButton:(UIButton *) button;
@end

@interface HorizontalListView : UIView{
    
}

@property (nonatomic, retain) id<HorizontalListViewDatasource> datasource;
@property (nonatomic, retain) id<HorizontalListViewDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;

-(void) reloadData;

@end
