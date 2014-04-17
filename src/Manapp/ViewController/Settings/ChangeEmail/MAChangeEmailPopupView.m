//
//  MAChangeEmailPopupView.m
//  TwoSum
//
//  Created by Duong Van Dinh on 9/20/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MAChangeEmailPopupView.h"

@interface MAChangeEmailPopupView ()

- (void) createBSKeyboardControls;
@end

@implementation MAChangeEmailPopupView


- (IBAction)btnDone:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(changeEmail:newEmail:)]) {
        [self.delegate changeEmail:self.txtCurrentPassword.text newEmail:self.txtNewEmail.text];
    }
}

- (IBAction)btnCancel:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(changeEmailDidFinish:)]) {
        [self.delegate changeEmailDidFinish:self];
    }
}

#pragma mark -
#pragma mark Keyboard Controls Delegate
// Done button
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    [keyboardControl.activeTextField resignFirstResponder];
    [self.scrollViewChangeEmail setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (void) createBSKeyboardControls {
    NSArray *fields = @[ self.txtCurrentPassword, self.txtNewEmail];
    self.keyboardControls = [[BSKeyboardControls alloc] init];
    self.keyboardControls.delegate = self;
    self.keyboardControls.textFields = fields;
    // Add the keyboard control as accessory view for all of the text fields
    // Also set the delegate of all the text fields to self
    [self.keyboardControls reloadTextFields];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([self.keyboardControls.textFields containsObject:textView])
        self.keyboardControls.activeTextField = textView;
}

- (void)presentWithSuperview:(UIView *)superview
{
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0.0, - kScreenHeight);
    self.view.frame = frame;
    [superview addSubview:self.view];
	
    // Animate to new location
    if(!IS_IPAD()){
        [UIView animateWithDuration:0.1 animations:^{
            CGRect frame1 = self.view.frame;
            frame1.origin = CGPointZero;
            self.view.frame = frame1;
        } completion:^(BOOL finished) {
            [superview bringSubviewToFront:self.view];
        }];
    }
    else{
        [UIView animateWithDuration:0.1 animations:^{
            CGRect frame1 = self.view.frame;
            frame1.origin = CGPointMake(0, 600);
            self.view.frame = frame1;
        } completion:^(BOOL finished) {
        }];
        
    }
    
}

// Method called when removeFromSuperviewWithAnimation's animation completes
- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context
{
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
    }
}

// Slide this view to bottom of superview, then remove from superview
- (void)removeFromSuperviewWithAnimation
{
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
	
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
    // Move this view to bottom of superview
    CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0.0, - kScreenHeight);
    self.view.frame = frame;
    [UIView commitAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createBSKeyboardControls];
    
    //change font
    [self.lblCurrentPassword setFont:[UIFont fontWithName:kFontAppleGothic size:13]];
    [self.lblNewEmail setFont:[UIFont fontWithName:kFontAppleGothic size:13]];
    [self.lblChangeEmailForm setFont:[UIFont fontWithName:kFontAppleGothic size:15]];
    [self.btnSubmit.titleLabel setFont:[UIFont fontWithName:kAppFont size:14]];
    [self.txtNewEmail setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    [self.txtCurrentPassword setFont:[UIFont fontWithName:kFontAppleGothic size:14]];
    //    if (IS_IPHONE_5) {
    //        self.viewInputTextSearch.frame = CGRectMake(0, 250, self.viewInputTextSearch.frame.size.width, self.viewInputTextSearch.frame.size.height);
    //    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //BSKeyboardControls
    if ([self.keyboardControls.textFields containsObject:textField])
        self.keyboardControls.activeTextField = textField;
    //    self.actifText = textField;
    NSLog(@"textfield y: %f", textField.frame.origin.y);
    NSLog(@" %f --- %f", self.scrollViewChangeEmail.contentOffset.x, self.scrollViewChangeEmail.contentOffset.y);
    [self.scrollViewChangeEmail setContentOffset:CGPointMake(0, textField.frame.origin.y - 45) animated:YES];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_txtCurrentPassword release];
    [_txtNewEmail release];
    [_btnSubmit release];
    [_btnCancel release];
    [_lblNewEmail release];
    [_lblCurrentPassword release];
    [_scrollViewChangeEmail release];
    [_lblChangeEmailForm release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTxtCurrentPassword:nil];
    [self setTxtNewEmail:nil];
    [self setBtnSubmit:nil];
    [self setBtnCancel:nil];
    [self setLblNewEmail:nil];
    [self setLblCurrentPassword:nil];
    [self setScrollViewChangeEmail:nil];
    [self setLblChangeEmailForm:nil];
    [super viewDidUnload];
}
@end
