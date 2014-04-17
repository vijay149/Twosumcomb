//
//  MeasurementViewController.h
//  Manapp
//
//  Created by Demigod on 23/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"
#import "KOAProgressBar.h"

@class Partner;

#define MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG 10
#define MANAPP_MEASUREMENT_VIEW_HEADER_HEIGHT 31

@interface MeasurementViewController : BaseViewController <UIAlertViewDelegate,KOAProgressBarDelegate>{
    
}

@property (nonatomic, retain) NSMutableDictionary *cachedDictionary;
@property (nonatomic, retain) NSArray *measurements;
@property (nonatomic, retain) NSMutableArray *nonEmptyMeasurements;
@property (retain, nonatomic) IBOutlet UITableView *measurementTableView;
@property (retain, nonatomic) IBOutlet KOAProgressBar *processBar;
@property (retain, nonatomic) IBOutlet UILabel *lblProcess;

@end
