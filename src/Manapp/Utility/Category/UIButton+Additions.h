//
//  UIButton+Additions.h
//  IKEA
//
//  Created by Demigod on 03/01/2013.
//  Copyright (c) 2013 MEE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIBUTTON_ADDITIONS_VERTICAL_PADDING 10
#define UIBUTTON_ADDITIONS_HORIZONTAL_PADDING 12

@interface UIButton (Additions)

- (void) resizeToFitText;
- (void) resizeWidthToFitText;
- (void) changeTitle:(NSString *)title;
- (void) changeTitleColor:(UIColor *)color;
- (void) changeTitleAndAutoFitSize:(NSString *) title;
- (void) changeTitleAndAutoFitWidth:(NSString *) title;
- (void) setBackgroundImageWithImageName:(NSString *) imageName;
- (void) setImageWithImageName:(NSString *) imageName;
@end
