//
//  MANotesCell.h
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>


#define MANAPP_PREFERENCE_CELL_HEIGHT 30
#define MANAPP_PREFERENCE_CELL_PADDING 4

@class Note;

@interface MANotesCell : UITableViewCell


@property (retain, nonatomic) UIFont *font;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIView *viewSeparate;

-(CGFloat) cellHeightForText:(NSString *) text;
+ (CGFloat)cellHeightForItem:(Note *)noteItem;

@end
