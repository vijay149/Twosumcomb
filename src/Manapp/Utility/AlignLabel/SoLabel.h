//
//  SoLabel.h
//  TwoSum
//
//  Created by Kevil Cuong on 1/21/14.
//  Copyright (c) 2014 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface SoLabel : UILabel
@property (nonatomic, readwrite) VerticalAlignment verticalAlignment;

@end
