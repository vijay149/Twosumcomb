//
//  MATextField.m
//  Manapp
//
//  Created by Demigod on 01/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MATextField.h"

@implementation MATextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.horizontalPadding, bounds.origin.y + self.verticalPadding, bounds.size.width, bounds.size.height);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.horizontalPadding, bounds.origin.y + self.verticalPadding, bounds.size.width, bounds.size.height);
}

-(void)changePadding:(CGSize)inset{
    self.horizontalPadding = inset.width;
    self.verticalPadding = inset.height;
}

@end
