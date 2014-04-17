//
//  MAMeasurementCell.h
//  Manapp
//
//  Created by Demigod on 06/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PartnerMeasurementItem;

#define MANAPP_MEASUREMENT_CELL_HEIGHT 30
#define MANAPP_MEASUREMENT_CELL_PADDING 4

@interface MAMeasurementCell : UITableViewCell{
    
}

@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIView *viewSeparate;
-(CGFloat) cellHeightForText:(NSString *) text;
+ (CGFloat)cellHeightForItem:(PartnerMeasurementItem *)item;
@end
