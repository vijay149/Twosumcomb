//
//  BaseViewController.m
//  ManApp
//
//  Created by Hieu Bui on 8/29/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import "BaseViewController.h"
#import "PreferenceItem.h"

#import "PartnerMeasurementItem.h"
#import "PartnerInformationItem.h"



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

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
    [self back];
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

#pragma mark - event handler
- (IBAction)btnBackground_touchUpInside:(id)sender{
    [self resignAllTextField];
}

-(void) resignAllTextField{
    
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    //add controls
    NSInteger numberOfControl = [controls count];
    for(NSInteger i=0; i< numberOfControl; i++){
        [alert addSubview:[controls objectAtIndex:i]];
    }
    
    [alert show];
    [alert release];
}

- (void)showMessageWithTextInput:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
    [alert release];
}

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls withIncreaseHeight: (CGFloat) height {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:Translate(message) delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle,nil];
    alert.tag = tag;
    [alert setFrame:CGRectMake(10, 100, 300, 320)];
    
    
    //add controls
    NSInteger numberOfControl = [controls count];
    for(NSInteger i=0; i< numberOfControl; i++){
        [alert addSubview:[controls objectAtIndex:i]];
    }
    
    [alert show];
    CGAffineTransform myTransform = CGAffineTransformMakeScale(1.0, 0.5f);
    [alert setTransform:myTransform];
    DLog(@"height 1: %f : y: %f",alert.frame.size.height, alert.frame.origin.y);
    alert.frame = CGRectMake(alert.frame.origin.x, alert.frame.origin.y - 100, alert.frame.size.width, alert.frame.size.height + height);
    DLog(@"height 2: %f : y: %f",alert.frame.size.height, alert.frame.origin.y);
    [alert release];
}

- (void)showMessage:(NSString *)message
{
    [self showMessage:message title:kAppName cancelButtonTitle:@"Close"];
}

- (void)showErrorMessage:(NSString *)error
{
    [self showMessage:error title:kAppName cancelButtonTitle:@"Close"];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:hidden animated:animated];
}

- (void)pushViewControllerByName:(NSString*)viewControllerName{
    Class viewControllerClass = NSClassFromString(viewControllerName);
    id viewController = [[[viewControllerClass alloc] initWithNibName:viewControllerName bundle:nil] autorelease];
    [self nextTo:viewController];
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
        if(![self.view.subviews containsObject:modalView]){
            return;
        }
        
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
        if([self.view.subviews containsObject:modalView]){
            return;
        }
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
        [self.view bringSubviewToFront:modalView];
        
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
        if(_scrollViewDidResize){
            return;
        }
        
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            if(changeOffset){
                CGPoint scrollViewContentOffset = scrollView.contentOffset;
                scrollViewContentOffset.y = scrollViewContentOffset.y + self.keyboardHeight;
                [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            }
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - self.keyboardHeight);
            [scrollView setContentSize:contentSize];
            
        } completion:^(BOOL finished) {
            
        }];
        
        _scrollViewDidResize = TRUE;
    }
    else{
        if(!_scrollViewDidResize){
            return;
        }
        
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + self.keyboardHeight);
        _scrollViewDidResize = FALSE;
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
    
    CGFloat pickerHeight = picker.frame.size.height - 44; //44 is the picker bar height
    
    if(isShowing){
        CGSize contentSize = scrollView.frame.size;
        [UIView animateWithDuration:0.4 animations:^{
            
            CGPoint scrollViewContentOffset = scrollView.contentOffset;
            scrollViewContentOffset.y = scrollViewContentOffset.y;
            [scrollView setContentOffset:scrollViewContentOffset animated:YES];
            
            scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height - pickerHeight);
            [scrollView setContentSize:contentSize];
            
            _scrollViewDidResize = TRUE;
        }];
    }
    else{
        scrollView.frame = CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height + pickerHeight);
        
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

- (void)scrollView:(UIScrollView *) scrollView changeOffsetToView:(UIView *) view{
    if(![view isKindOfClass:[UIView class]]){
        return;
    }
    CGPoint pt;
    CGRect rc = [view bounds];
    rc = [view convertRect:rc toView:scrollView];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [scrollView setContentOffset:pt animated:YES];
}

#pragma mark - navigation bar
- (void) addLeftBarCancelButton{
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchLeftBarButton:)] autorelease];
}
- (void) addRightBarDoneButton{
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(touchRightBarButton:)] autorelease];
}
-(void) addRightBarSaveButton{
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(touchRightBarButton:)] autorelease];
}

- (void) createBackNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action{
    ButtonControl *btnBack = [ButtonControl ButtonWithTitle:title];
    btnBack.tag = MA_NAVIGATION_COMMON_LEFT_BUTTON_TAG;
    [btnBack setBackgroundImage:[UIImage imageNamed:@"btnBack"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"btnBack"] forState:UIControlStateHighlighted];
    [btnBack setBackgroundColor:[UIColor clearColor]];
    btnBack.frame = frame;
    [btnBack.titleLabel setFont:[UIFont fontWithName:kAppFont size:11]];
    [btnBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnBack setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 1, -5)];
    [btnBack addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnBack];
}

- (void) createBackNavigationWithTitle:(NSString *)title action:(SEL) action{
    [self createBackNavigationWithTitle:title frame:CGRectMake(4, 27, 54, 23) action:action];
}

- (void) createBackNavigationWithTitle:(NSString *)title{
    [self createBackNavigationWithTitle:title action:@selector(touchLeftBarButton:)];
}

- (void) createRightNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action{
    ButtonControl *btnRight = [ButtonControl ButtonWithTitle:title];
    btnRight.tag = MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG;
    [btnRight setBackgroundImage:[UIImage imageNamed:@"btnRight"] forState:UIControlStateNormal];
    [btnRight setBackgroundImage:[UIImage imageNamed:@"btnRight"] forState:UIControlStateHighlighted];
    [btnRight setBackgroundColor:[UIColor clearColor]];
    btnRight.frame = frame;
    [btnRight.titleLabel setFont:[UIFont fontWithName:kAppFont size:12]];
    [btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnRight setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, -5)];
    [btnRight addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnRight];
}

- (void) createButtonNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action {
    ButtonControl *btn = [ButtonControl ButtonWithTitle:title];
    btn.tag = MA_NAVIGATION_COMMON_SUMMARY_BUTTON_TAG;
    [btn setBackgroundImage:[UIImage imageNamed:@"btnRight"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btnRight"] forState:UIControlStateHighlighted];
    
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.frame = frame;
    [btn.titleLabel setFont:[UIFont fontWithName:kAppFont size:11]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 1, 0)];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void) createButtonByImageName:(NSString *)name frame:(CGRect) frame action:(SEL) action {
    ButtonControl *btn = [ButtonControl ButtonWithTitle:@""];
    btn.tag = MA_NAVIGATION_COMMON_NOTE_BUTTON_TAG;
    [btn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateHighlighted];
    
    [btn setBackgroundColor:[UIColor clearColor]];
    btn.frame = frame;
    [btn.titleLabel setFont:[UIFont fontWithName:kAppFont size:12]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 2, -5)];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}


- (void) createRightNavigationWithTitle:(NSString *)title action:(SEL) action{
    [self createRightNavigationWithTitle:title frame:CGRectMake(251, 27, 55, 23) action:action];
}

- (void) createRightNavigationWithTitle:(NSString *)title{
    [self createRightNavigationWithTitle:title action:@selector(touchRightBarButton:)];
}

- (void) touchLeftBarButton:(id)sender{
    [self back];
}
- (void) touchRightBarButton:(id)sender{
    
}

- (void) moveNavigationButtonsToView:(UIView *)view{
    UIButton * leftButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_LEFT_BUTTON_TAG];
    if(leftButton){
        [leftButton removeFromSuperview];
        [view addSubview:leftButton];
    }
    
    UIButton * rightButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_RIGHT_BUTTON_TAG];
    if(rightButton){
        [rightButton removeFromSuperview];
        [view addSubview:rightButton];
    }
    
    UIButton * noteButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_NOTE_BUTTON_TAG];
    if(noteButton){
        [noteButton removeFromSuperview];
        [view addSubview:noteButton];
    }
    
    UIButton * summaryButton = (UIButton *)[self.view viewWithTag:MA_NAVIGATION_COMMON_SUMMARY_BUTTON_TAG];
    if(summaryButton){
        [summaryButton removeFromSuperview];
        [view addSubview:summaryButton];
    }
}

- (void) back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) nextTo:(UIViewController *)vc{
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) popToView: (Class)vc {
    BOOL isFound = NO;
    if (vc) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 0) {
            for (UIViewController *view in viewControllers) {
                if ([view isKindOfClass:vc]) {
                    isFound = YES;
                    [self.navigationController popToViewController:view animated:YES];
                    break;
                }
            }
            if (!isFound) {
                [self nextTo:NEW_VC(vc)];
            }
        }
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


//convert Array PreferenceItem To RADataObjectArray
//convert Array PartnerMeasurementItem To RADataObjectArray
//convert Array PartnerInformationItem To RADataObjectArray
- (NSMutableArray*) convertAbstractArrayToRADataObjectArray:(NSInteger) type arrayInput: (NSArray*) arrayInput {
    NSMutableArray *arrayOutput = nil;
    switch (type) {
        case kPreference:
        {
            arrayOutput = [NSMutableArray array];
            int count = 0;
            for (PreferenceItem *item in arrayInput) {
                
                RADataObject *raDO = [RADataObject dataObjectWithName:item.name children:nil isParent:NO isSubParent:NO isSubOfSubParent: NO isPreference:YES isLike:[item.isLike boolValue]];
                raDO.itemID = item.itemID;
                raDO.isLastItem = NO;
                if (count == (arrayInput.count - 1)) {
                    raDO.isLastItem = YES;
                }
                [arrayOutput addObject:raDO];
                count++;
            }
//            for (PreferenceItem *item in arrayInput) {
//                RADataObject *raDO = [RADataObject dataObjectWithName:item.name children:nil isParent:NO isSubParent:NO isPreference:YES isLike:[item.isLike boolValue]];
//                [arrayOutput addObject:raDO];
//            }
        }
            break;
        case kMeasurement:
        {
            int count = 0;
            arrayOutput = [NSMutableArray array];
            for (PartnerMeasurementItem *item in arrayInput) {
                RADataObject *raDO = [RADataObject dataObjectWithName:item.name children:nil isParent:NO isSubParent:NO isSubOfSubParent: NO isPreference:NO isLike:NO];
                raDO.itemID = item.itemID;
                raDO.isLastItem = NO;
                if (count == (arrayInput.count - 1)) {
                    raDO.isLastItem = YES;
                }
                [arrayOutput addObject:raDO];
                count++;
            }
        }
            break;
        case kInformation:
        {
            int count = 0;
            arrayOutput = [NSMutableArray array];
            for (PartnerInformationItem *item in arrayInput) {
                RADataObject *raDO = [RADataObject dataObjectWithName:item.name children:nil isParent:NO isSubParent:NO isSubOfSubParent: NO isPreference:NO isLike:NO];
                raDO.itemID = item.itemID;
                raDO.isLastItem = NO;
                if (count == (arrayInput.count - 1)) {
                    raDO.isLastItem = YES;
                }
                [arrayOutput addObject:raDO];
                count++;
            }
        }
            break;
        default:
            break;
    }
    return arrayOutput;
}

#pragma mark TreeView Delegate methods
- (CGFloat)cellHeightForItem:(RADataObject *)item orTitle:(NSString *) title {
    
    CGFloat minHeight = 30;
    
    CGFloat cellHeight = 4;
    
    CGFloat paddingVertical = 5;
    
    CGFloat commentWidth = 302;
    UIFont *commentFont = [UIFont fontWithName:kAppFont size:19];
    CGSize commentSize;
    if (item) {
        commentSize = [item.name sizeWithFont:commentFont constrainedToSize:CGSizeMake(commentWidth, 20000) lineBreakMode: NSLineBreakByWordWrapping];
    } else {
        commentSize = [title sizeWithFont:commentFont constrainedToSize:CGSizeMake(commentWidth, 20000) lineBreakMode: NSLineBreakByWordWrapping];
    }
    cellHeight += paddingVertical + commentSize.height;
    if(cellHeight < minHeight){
        cellHeight = minHeight;
    }
    NSLog(@"cellHeight: %f",cellHeight);
    return cellHeight;
}


#pragma mark - Auto Rotation
-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    
}

@end
