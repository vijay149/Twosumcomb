//
//  MANotesCell.m
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MANotesCell.h"
#import "Note.h"
#import "UILabel+Additions.h"

@implementation MANotesCell

- (void)dealloc {
    [_lblTitle release];
    [_font release];
    [_viewSeparate release];
    [super dealloc];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self.lblTitle setFont:self.font];
}

#pragma mark - ui functions
-(CGFloat) cellHeightForText:(NSString *) text{
    [self.lblTitle setFont:self.font];
    [self.lblTitle changeSizeToMatchText:text allowWidthChange:NO];
    if(self.lblTitle.frame.size.height < MANAPP_PREFERENCE_CELL_HEIGHT){
        return MANAPP_PREFERENCE_CELL_HEIGHT;
    }
    else{
        return self.lblTitle.frame.size.height + MANAPP_PREFERENCE_CELL_PADDING;
    }
}

+ (CGFloat)cellHeightForItem:(Note *)noteItem{
    CGFloat minHeight = 30;
    
    CGFloat cellHeight = 4;
    
    CGFloat paddingVertical = 5;
    
    CGFloat commentWidth = 302;
    UIFont *commentFont = [UIFont fontWithName:kAppFont size:19];
    CGSize commentSize = [noteItem.note sizeWithFont:commentFont constrainedToSize:CGSizeMake(commentWidth, 20000) lineBreakMode: NSLineBreakByWordWrapping];
    
    cellHeight += paddingVertical + commentSize.height;
    
    if(cellHeight < minHeight){
        cellHeight = minHeight;
    }
    
    return cellHeight;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:kAppFont size:19];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}




@end
