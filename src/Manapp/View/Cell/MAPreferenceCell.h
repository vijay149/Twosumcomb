//
//  MAPreferenceCell.h
//  Manapp
//
//  Created by Demigod on 04/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PreferenceItem;

#define MANAPP_PREFERENCE_CELL_HEIGHT 30
#define MANAPP_PREFERENCE_CELL_PADDING 4

@interface MAPreferenceCell : UITableViewCell{
    
}
@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIImageView *imageRight;
@property (retain, nonatomic) IBOutlet UIView *viewSeparate;

-(CGFloat) cellHeightForText:(NSString *) text;
+ (CGFloat)cellHeightForItem:(PreferenceItem *)item;
+ (CGFloat)cellHeightForName:(NSString *)name;
@end
