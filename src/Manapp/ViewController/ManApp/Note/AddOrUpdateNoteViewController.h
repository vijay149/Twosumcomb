//
//  AddOrUpdateNoteViewController.h
//  TwoSum
//
//  Created by Duong Van Dinh on 8/7/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPlaceHolderTextView.h"

@class Note;
@interface AddOrUpdateNoteViewController : BaseViewController <UITextViewDelegate>


@property (retain, nonatomic) IBOutlet UIScrollView *scrollview;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewNote;
@property (retain, nonatomic) IBOutlet UIView *viewNoteOverlay;
@property (retain, nonatomic) IBOutlet UIButton *btnBackground;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;

@property (retain, nonatomic) IBOutlet UIImageView *imageViewBackGroundNotes;
@property (retain, nonatomic) Note *note;

- (IBAction)btnDelete_touchUpInside:(id)sender;


@end
