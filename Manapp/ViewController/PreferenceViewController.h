//
//  PreferenceViewController.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

typedef enum {
    MAPreferenceViewStateShowAll          = 1,
    MAPreferenceViewStateLikeOnly         = 2,
    MAPreferenceViewStateDislikeOnly      = 3,
    MAPreferenceViewStateHideAll          = 4,
} MAPreferenceViewState;

#define MANAPP_PREFERENCE_VIEW_DATA_EMPTY_ALERT_TAG 10

@interface PreferenceViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    
}

@property (retain, nonatomic) IBOutlet UITableView *tableViewPreference;

@property (nonatomic, retain) NSMutableDictionary *cachedDictionary;
@property (nonatomic, retain) NSArray *preferences;
@property MAPreferenceViewState preferenceViewState;

@end
