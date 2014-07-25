//
//  MenstruationView.h
//  Manapp
//
//  Created by Demigod on 26/11/2012.
//  Copyright (c) 2012 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenstruationView : UIView{
    
}

@property (retain, nonatomic) IBOutlet UITextField *txtFirstPeriod;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIButton *btnBack;

- (IBAction)btnSave_touchUpInside:(id)sender;
- (IBAction)btnBack_touchUpInside:(id)sender;

@end
