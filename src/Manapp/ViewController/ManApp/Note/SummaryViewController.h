//
//  SummaryViewController.h
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
typedef enum {
	MAPreferenceViewStateShowAll          = 1,
	MAPreferenceViewStateLikeOnly         = 2,
	MAPreferenceViewStateDislikeOnly      = 3,
	MAPreferenceViewStateHideAll          = 4,
} MAPreferenceViewState;
#define MANAPP_SUMMARY_VIEW_HEADER_HEIGHT 28

@interface SummaryViewController : BaseViewController


@property MAPreferenceViewState preferenceViewState;
@end
