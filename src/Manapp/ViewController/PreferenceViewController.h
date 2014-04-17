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
#import "KOAProgressBar.h"

typedef enum {
    MAPreferenceViewStateShowAll          = 1,
    MAPreferenceViewStateLikeOnly         = 2,
    MAPreferenceViewStateDislikeOnly      = 3,
    MAPreferenceViewStateHideAll          = 4,
} MAPreferenceViewState;

#define MANAPP_PREFERENCE_VIEW_DATA_EMPTY_ALERT_TAG 10
#define MANAPP_PREFERENCE_VIEW_HEADER_HEIGHT 31

@interface PreferenceViewController : BaseViewController<UIAlertViewDelegate, KOAProgressBarDelegate>{
    
}
@property (retain, nonatomic) IBOutlet UILabel *lblProcess;
@property (retain, nonatomic) IBOutlet KOAProgressBar *processBar;
@property (nonatomic, retain) IBOutlet UIButton *btnLike;
@property (nonatomic, retain) IBOutlet UIButton *btnDislike;
@property (retain, nonatomic) IBOutlet UIButton *btnAllPreference;
@property (retain, nonatomic) IBOutlet UITableView *tableViewPreference;

@property (nonatomic, retain) NSMutableDictionary *cachedDictionary;
@property (nonatomic, retain) NSArray *preferences;
@property (nonatomic, retain) NSMutableArray *nonEmptyPreferences;
@property MAPreferenceViewState preferenceViewState;

- (IBAction)allPreferenceButton_touchUpInside:(id)sender;
- (IBAction)likeButton_touchUpInside:(id)sender;
- (IBAction)dislikeButton_touchUpInside:(id)sender;

@end
