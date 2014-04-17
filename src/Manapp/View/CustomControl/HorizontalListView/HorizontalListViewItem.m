//
//  HorizontalListViewItem.m
//  TwoSum
//
//  Created by Demigod on 04/04/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "HorizontalListViewItem.h"

@implementation HorizontalListViewItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithSize:(CGSize) size{
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) dealloc{
    [super dealloc];
    [_imgItem release];
}

-(void) layoutSubviews{
    [super layoutSubviews];
}

#pragma mark - UIFunction
-(void) layoutItem{
    if(!self.imgItem){
        _imgItem = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.imgItem.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.imgItem];
    }
}

@end
