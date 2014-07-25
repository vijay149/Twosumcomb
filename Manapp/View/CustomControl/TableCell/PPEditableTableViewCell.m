//
//  PPEditableTableViewCell.m
//  MedTalk
//
//  Created by Hieu Bui on 6/25/12.
//  Copyright (c) 2012 SETACINQ Vietnam. All rights reserved.
//

#import "PPEditableTableViewCell.h"

#define MARGIN_LEFT                         18
#define MARGIN_TOP                          13

@implementation PPEditableTableViewCell

@synthesize txtField = _txtField;
@synthesize indexPath = _indexPath;
@synthesize lblTitle = _lblTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _txtField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, self.frame.size.width - 2 * MARGIN_LEFT, self.frame.size.height - 2 * MARGIN_TOP)];
        _txtField.font = [UIFont systemFontOfSize:14];
        [self addSubview:_txtField];

        _lblTitle = [[UILabel alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier showTitle:(BOOL) showTitle
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if(showTitle)
        {
            _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, self.frame.size.width/3 - 2 * MARGIN_LEFT, self.frame.size.height - 2 * MARGIN_TOP)];
            _lblTitle.font = [UIFont boldSystemFontOfSize:16];
            _lblTitle.backgroundColor = [UIColor clearColor];
            [self addSubview:_lblTitle];
            
            _txtField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT + _lblTitle.frame.size.width, MARGIN_TOP, 2*self.frame.size.width/3 - 2 * MARGIN_LEFT, self.frame.size.height - 2 * MARGIN_TOP)];
            _txtField.font = [UIFont systemFontOfSize:14];
            [self addSubview:_txtField];
            
        }
        else{
            _txtField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT, MARGIN_TOP, self.frame.size.width - 2 * MARGIN_LEFT, self.frame.size.height - 2 * MARGIN_TOP)];
            _txtField.font = [UIFont systemFontOfSize:14];
            [self addSubview:_txtField];
            
            _lblTitle = [[UILabel alloc] init];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc
{
    [_lblTitle release];
    [_txtField release];
    [super dealloc];
}
@end
