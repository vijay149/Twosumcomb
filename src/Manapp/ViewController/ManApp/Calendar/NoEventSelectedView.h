//
//  NoEventSelectedView.h
//  TwoSum
//
//  Created by Duong Van Dinh on 10/3/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoEventSelectedViewDelegate <NSObject>

@optional
- (NSDate*) getSelectedDate;
@end

@interface NoEventSelectedView : UIView
@property (retain, nonatomic) IBOutlet UILabel *lblDateSelected;
@property (retain, nonatomic) id<NoEventSelectedViewDelegate> delegate;
@end
