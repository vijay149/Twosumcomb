//
//  AdditionalInformationViewController.h
//  Manapp
//
//  Created by Demigod on 22/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MACommon.h"

@class Partner;

#define MANAPP_ADDITIONAL_VIEW_DATA_EMPTY_ALERT_TAG 10

@interface AdditionalInformationViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    
}

@property (nonatomic, retain) NSMutableDictionary *cachedDictionary;
@property (nonatomic, retain) NSArray *partnerInformation;
@property (retain, nonatomic) IBOutlet UITableView *informationTableView;

@end
