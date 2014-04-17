//
//  MAChangePasswordPopupView.m
//  TwoSum
//
//  Created by Duong Van Dinh on 9/20/13.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "MAChangePasswordPopupView.h"

@interface MAChangePasswordPopupView ()

- (void) createBSKeyboardControls;
@end

@implementation MAChangePasswordPopupView


- (IBAction)btnDone:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(changePassword:newPassword:confirmPassword:)]) {
        [self.delegate changePassword:self.txtCurrentPassword.text newPassword:self.txtNewPassword.text confirmPassword:self.txtConfirmPassword.text];
    }
}

- (IBAction)btnCancel:(id)sender {
    if (self.delegate &&  [(NSObject*)self.delegate respondsToSelector:@selector(changePasswordDidFinish:)]) {
        [self.delegate changePasswordDidFinish:self];
    }
}

// Done button
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControl
{
    [keyboardControl.activeTextField resignFirstResponder];
    [self.scrollViewChangePassword setContentOffset:CGPointMake(0, 0) animated:YES];
}


- (void) createBSKeyboardControls {
    NSArray *fields = @[ self.txtCurrentPassword, self.txtNewPassword, self.txtConfirmPassword];
    
    self.keyboardControls = [[BSKeyboardControls alloc] init];
    self.keyboardControls.delegate = self;
    self.keyboardControls.textFields = fields;
    // Add the keyboard control as accessory view for all of the text fields
    // Also set the delegate of all the text fields to self
    [self.keyboardControls reloadTextFields];
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
    NSLog(@"%f",self.scrollViewChangePassword.frame.origin.y);
//    if (IS_IPHONE_5) {
//        self.viewInputTextSearch.frame = CGRectMake(0, 250, self.viewInputTextSearch.frame.size.width, self.viewInputTextSearch.frame.size.height);
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    NSLog(@" %f --- %f", self.scrollViewChangePassword.contentOffset.x, self.scrollViewChangePassword.contentOffset.y);
    [self.scrollViewChangePassword setContentOffset:CGPointMake(0, textField.frame.origin.y - 45) animated:YES];
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([self.keyboardControls.textFields containsObject:textView])
        self.keyboardControls.activeTextField = textView;
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
    [_btnChangePassword release];
    [_viewFormChangePassword release];
    [_lblCurrentPassword release];
    [_txtCurrentPassword release];
    [_lblNewPassword release];
    [_txtNewPassword release];
    [_lblConfirmPassword release];
    [_txtConfirmPassword release];
    [_btnCancel release];
    [_keyboardControls release];
    [_scrollViewChangePassword release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBtnChangePassword:nil];
    [self setViewFormChangePassword:nil];
    [self setLblCurrentPassword:nil];
    [self setTxtCurrentPassword:nil];
    [self setLblNewPassword:nil];
    [self setTxtNewPassword:nil];
    [self setLblConfirmPassword:nil];
    [self setTxtConfirmPassword:nil];
    [self setBtnCancel:nil];
    [self setScrollViewChangePassword:nil];
    [super viewDidUnload];
}
@end
