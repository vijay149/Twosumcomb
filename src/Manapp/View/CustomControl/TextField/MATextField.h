//
//  MATextField.h
//  Manapp
//
//  Created by Demigod on 01/02/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MATextField : UITextField{
    
}

@property (nonatomic, assign) float verticalPadding;
@property (nonatomic, assign) float horizontalPadding;

-(void) changePadding:(CGSize) inset;

@end
