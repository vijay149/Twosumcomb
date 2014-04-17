//
//  NoteViewController.h
//  Manapp
//
//  Created by Demigod on 07/03/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPlaceHolderTextView.h"
#import "BSKeyboardControls.h"
@class Note;

@interface NoteViewController : BaseViewController <UITextViewDelegate, BSKeyboardControlsDelegate, UIAlertViewDelegate> {
}
@property (retain, nonatomic) IBOutlet UIScrollView *scrollview;
@property (retain, nonatomic) IBOutlet UIPlaceHolderTextView *textViewNote;
@property (retain, nonatomic) IBOutlet UIView *viewNoteOverlay;
@property (retain, nonatomic) IBOutlet UIButton *btnBackground;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;
@property (retain, nonatomic) IBOutlet UIView *viewHeader;

@property (strong, nonatomic) Note *note;

- (IBAction)btnDelete_touchUpInside:(id)sender;


@end
