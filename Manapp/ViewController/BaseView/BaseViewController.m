//
//  BaseViewController.m
//  ManApp
//
//  Created by Hieu Bui on 8/29/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController
@synthesize keyboardHeight = _keyboardHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _scrollViewDidResize = FALSE;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

// Add Swipe Gesture Recognizer
- (void)addSwipeBackGesture
{
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:gesture];
    [gesture release];
}

// Handle swipe action
- (void)swipe:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//add touch background
- (void)addTouchBackgroundGesture{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [gesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:gesture];
    [gesture release];
}

// Handle tap action
- (void)tap:(id)sender
{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - iHTTP connection manager delegate
- (void)startedDownloadWithTag:(NSString *)tag
{
}

- (void)finishedDownloadWithTag:(NSString *)tag downloadedData:(NSMutableData *)data
{
}

- (void)errorDownloadWithTag:(NSString *)tag error:(NSError *)error
{
}

#pragma mark - view function

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    
    //add controls
    NSInteger numberOfControl = [controls count];
    for(NSInteger i=0; i< numberOfControl; i++){
        [alert addSubview:[controls objectAtIndex:i]];
    }
    
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message
{
    [self showMessage:message title:@"ManApp" cancelButtonTitle:@"Close"];
}

- (void)showErrorMessage:(NSString *)error
{
    [self showMessage:error title:@"Error" cancelButtonTitle:@"Close"];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
}

- (void)pushViewControllerByName:(NSString*)viewControllerName{
    Class viewControllerClass = NSClassFromString(viewControllerName);
    id viewController = [[[viewControllerClass alloc] initWithNibName:viewControllerName bundle:nil] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (id)getViewControllerByName:(NSString*)viewControllerName{
    Class viewControllerClass = NSClassFromString(viewControllerName);
    id viewController = [[[viewControllerClass alloc] initWithNibName:viewControllerName bundle:nil] autorelease];
    return viewController;
}

//hide the modal view
- (void)hideModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL)autoAdd{
    if(!autoAdd){
        if(modalView.hidden == FALSE){
            [UIView animateWithDuration:0.2f animations:^{
                if(direction == MAModalViewDirectionBottom){
                    modalView.frame = CGRectMake(modalView.frame.origin.x, self.view.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionTop){
                    modalView.frame = CGRectMake(modalView.frame.origin.x, -modalView.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionRight){
                    modalView.frame = CGRectMake(self.view.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionLeft){
                    modalView.frame = CGRectMake(-modalView.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
                }
            } completion:^(BOOL finished) {
                modalView.hidden = TRUE;
            }];
        }
    }
    else{
        [UIView animateWithDuration:0.2f animations:^{
            if(direction == MAModalViewDirectionBottom){
                modalView.frame = CGRectMake(modalView.frame.origin.x, self.view.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionTop){
                modalView.frame = CGRectMake(modalView.frame.origin.x, -modalView.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionRight){
                modalView.frame = CGRectMake(self.view.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionLeft){
                modalView.frame = CGRectMake(-modalView.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
            }
        } completion:^(BOOL finished) {
            [modalView removeFromSuperview];
        }];
    }
}

//show the modal view
- (void)showModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL)autoAdd{
    if(!autoAdd){
        if(modalView.hidden == TRUE){
            modalView.hidden = FALSE;
            [UIView animateWithDuration:0.2f animations:^{
                if(direction == MAModalViewDirectionBottom){
                    modalView.frame = CGRectMake(modalView.frame.origin.x, self.view.frame.size.height - modalView.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionTop){
                    modalView.frame = CGRectMake(modalView.frame.origin.x, 0, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionRight){
                    modalView.frame = CGRectMake(self.view.frame.size.width - modalView.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
                }
                else if(direction == MAModalViewDirectionLeft){
                    modalView.frame = CGRectMake(0, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
                }
            }];
        }
    }
    else{
        //set frame
        if(direction == MAModalViewDirectionBottom){
            modalView.frame = CGRectMake(modalView.frame.origin.x, self.view.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
        }
        else if(direction == MAModalViewDirectionTop){
            modalView.frame = CGRectMake(modalView.frame.origin.x, -self.view.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
        }
        else if(direction == MAModalViewDirectionRight){
            modalView.frame = CGRectMake(self.view.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
        }
        else if(direction == MAModalViewDirectionLeft){
            modalView.frame = CGRectMake(-self.view.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
        }
        
        //add to subview
        [self.view addSubview:modalView];
        
        //move to main view
        [UIView animateWithDuration:0.2f animations:^{
            if(direction == MAModalViewDirectionBottom){
                modalView.frame = CGRectMake(modalView.frame.origin.x, self.view.frame.size.height - modalView.frame.size.height, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionTop){
                modalView.frame = CGRectMake(modalView.frame.origin.x, 0, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionRight){
                modalView.frame = CGRectMake(self.view.frame.size.width - modalView.frame.size.width, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
            }
            else if(direction == MAModalViewDirectionLeft){
                modalView.frame = CGRectMake(0, modalView.frame.origin.y, modalView.frame.size.width, modalView.frame.size.height);
            }
        }];
    }
}

#pragma mark - keyboard handler
//change the scrollview size when the keyboard show up
- (void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
}

- (void)keyboardWillHide{
    
}

//resize the scroll view depend on the keyboard state
- (void)resizeScrollView:(UIScrollView*) scrollView withKeyboardState:(BOOL) isShowing willChangeOffset:(BOOL) changeOffset{
    if(isShowing){
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            if(changeOffset){
                CGPoint scrollViewContentOffset = scrollView.contentOffset;
                scrollViewContentOffset.y = scrollViewContentOffset.y + self.keyboardHeight;
                [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            }
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - self.keyboardHeight);
            
        } completion:^(BOOL finished) {
            [scrollView setContentSize:contentSize];
        }];
    }
    else{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + self.keyboardHeight);
    }
}

//resize the table view depend on the keyboard state
- (void)resizeTableView:(UITableView*) tableView withKeyboardState:(BOOL) isShowing willChangeOffset:(BOOL) changeOffset{
    if(isShowing){
        CGSize contentSize = tableView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            CGPoint scrollViewContentOffset = tableView.contentOffset;
            scrollViewContentOffset.y = scrollViewContentOffset.y + (changeOffset)?self.keyboardHeight:0;
            [tableView setContentOffset:scrollViewContentOffset animated:YES];
            
            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height - self.keyboardHeight);
            [tableView setContentSize:contentSize];
        }];
    }
    else{
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height + self.keyboardHeight);
    }
}

//resize the scroll view depend on the date timepicker state
- (void)resizeScrollView:(UIScrollView*) scrollView withDatePicker:(UIDatePicker*) picker pickerState:(BOOL) isShowing{
    //if the scroll view resize before, then don't resize again
    if(_scrollViewDidResize){
        if(isShowing){
            return;
        }
    }
    
    if(!_scrollViewDidResize){
        if(!isShowing){
            return;
        }
    }
    
    if(isShowing){
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            CGPoint scrollViewContentOffset = scrollView.contentOffset;
            scrollViewContentOffset.y = scrollViewContentOffset.y;
            [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - picker.frame.size.height);
            [scrollView setContentSize:contentSize];
            
            _scrollViewDidResize = TRUE;
        }];
    }
    else{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + picker.frame.size.height);
        
        _scrollViewDidResize = FALSE;
    }
}

//resize the scroll view depend on the actionsheet state
- (void)resizeScrollView:(UIScrollView*) scrollView withActionSheet:(UIActionSheet*) actionSheet actionSheetState:(BOOL) isShowing{
    //if the scroll view resize before, then don't resize again
    if(_scrollViewDidResize){
        if(isShowing){
            return;
        }
    }
    
    if(!_scrollViewDidResize){
        if(!isShowing){
            return;
        }
    }

    if(isShowing){
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            CGPoint scrollViewContentOffset = scrollView.contentOffset;
            scrollViewContentOffset.y = scrollViewContentOffset.y;
            [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - actionSheet.frame.size.height);
            [scrollView setContentSize:contentSize];
        }];
        _scrollViewDidResize = TRUE;
    }
    else{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + actionSheet.frame.size.height);
        _scrollViewDidResize = FALSE;
    }
}

//resize the scroll view if there is a view show up
- (void)resizeScrollView:(UIScrollView*) scrollView withView:(UIView*) view viewState:(BOOL) isShowing{
    //if the scroll view resize before, then don't resize again
    if(_scrollViewDidResize){
        if(isShowing){
            return;
        }
    }
    
    if(!_scrollViewDidResize){
        if(!isShowing){
            return;
        }
    }
    
    if(isShowing){
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            CGPoint scrollViewContentOffset = scrollView.contentOffset;
            scrollViewContentOffset.y = scrollViewContentOffset.y;
            [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - view.frame.size.height);
            [scrollView setContentSize:contentSize];
        }];
        _scrollViewDidResize = TRUE;
    }
    else{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + view.frame.size.height);
        _scrollViewDidResize = FALSE;
    }
}

#pragma mark - loading hud
- (void)showWaitingHud{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;
    hud.labelText = @"Loading";
}
- (void)hideWaitingHud{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

@end
