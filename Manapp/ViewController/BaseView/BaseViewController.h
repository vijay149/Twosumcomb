//
//  BaseViewController.h
//  ManApp
//
//  Created by Hieu Bui on 8/29/12.
//  Copyright (c) 2012 BK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iHTTPConnectionManagerDelegate.h"
#import "MACommon.h"
#import "MBProgressHUD.h"

@class MASession;

typedef enum{
    MAModalViewDirectionLeft = 1,
    MAModalViewDirectionRight,
    MAModalViewDirectionTop,
    MAModalViewDirectionBottom
}MAModalViewDirection;

@interface BaseViewController : UIViewController<iHTTPConnectionManagerDelegate>{
    CGFloat _keyboardHeight;
    BOOL _scrollViewDidResize;
}

@property CGFloat keyboardHeight;

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls;
- (void)showMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)error;
- (void)addSwipeBackGesture;
- (void)addTouchBackgroundGesture;
- (void)tap:(id)sender;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)keyboardWillShow:(NSNotification*)notification;
- (void)keyboardWillHide;
- (void)resizeScrollView:(UIScrollView*) scrollView withKeyboardState:(BOOL) isShowing willChangeOffset:(BOOL) changeOffset;
- (void)resizeTableView:(UITableView*) tableView withKeyboardState:(BOOL) isShowing willChangeOffset:(BOOL) changeOffset;
- (void)resizeScrollView:(UIScrollView*) scrollView withDatePicker:(UIDatePicker*) picker pickerState:(BOOL) isShowing;
- (void)resizeScrollView:(UIScrollView*) scrollView withActionSheet:(UIActionSheet*) actionSheet actionSheetState:(BOOL) isShowing;
- (void)resizeScrollView:(UIScrollView*) scrollView withView:(UIView*) view viewState:(BOOL) isShowing;
- (void)showWaitingHud;
- (void)hideWaitingHud;
- (void)pushViewControllerByName:(NSString*)viewControllerName;
- (id)getViewControllerByName:(NSString*)viewControllerName;
- (void)hideModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL) autoAdd;
- (void)showModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL) autoAdd;;
@end
