//
//  MAInformationCell.h
//  Manapp
//
//  Created by Demigod on 19/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PartnerInformationItem;

#define MANAPP_INFORMATION_CELL_HEIGHT 30
#define MANAPP_INFORMATION_CELL_PADDING 4

@interface MAInformationCell : UITableViewCell{
    
}
@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIView *viewSeparate;
-(CGFloat) cellHeightForText:(NSString *) text;
+ (CGFloat)cellHeightForItem:(PartnerInformationItem *)item;

@end
