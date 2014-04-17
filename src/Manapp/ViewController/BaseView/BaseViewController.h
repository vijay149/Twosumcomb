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
#import "ButtonControl.h"
#import "RADataObject.h"
#define kPreference  0
#define kMeasurement 1
#define kInformation 2

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
    id _currentResponseView;
}

@property CGFloat keyboardHeight;

- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls;
- (void)showMessageWithTextInput:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle delegate:(BaseViewController*)delegate tag:(NSInteger) tag subControls:(NSMutableArray*) controls withIncreaseHeight: (CGFloat) height;
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
- (void)scrollView:(UIScrollView *) scrollView changeOffsetToView:(UIView *) view;
- (void)showWaitingHud;
- (void)hideWaitingHud;
- (void)pushViewControllerByName:(NSString*)viewControllerName;
- (id)getViewControllerByName:(NSString*)viewControllerName;
- (void)hideModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL) autoAdd;
- (void)showModalView:(UIView*) modalView direction:(MAModalViewDirection) direction autoAddSubView:(BOOL) autoAdd;

- (void) addLeftBarCancelButton;
- (void) addRightBarDoneButton;
- (void) addRightBarSaveButton;
- (void) createBackNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action;
- (void) createBackNavigationWithTitle:(NSString *)title action:(SEL) action;
- (void) createBackNavigationWithTitle:(NSString *)title;
- (void) createRightNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action;
- (void) createRightNavigationWithTitle:(NSString *)title action:(SEL) action;
- (void) createRightNavigationWithTitle:(NSString *)title;
- (void) createButtonNavigationWithTitle:(NSString *)title frame:(CGRect) frame action:(SEL) action;
- (void) createButtonByImageName:(NSString *)name frame:(CGRect) frame action:(SEL) action;
- (void) touchLeftBarButton:(id)sender;
- (void) touchRightBarButton:(id)sender;
- (void) moveNavigationButtonsToView:(UIView *)view;

- (void) back;
- (void) nextTo:(UIViewController *)vc;
- (void) popToView: (Class)vc;
- (IBAction)btnBackground_touchUpInside:(id)sender;
- (void) resignAllTextField;
- (NSMutableArray*) convertAbstractArrayToRADataObjectArray:(NSInteger) type arrayInput: (NSArray*) arrayInput;
- (CGFloat)cellHeightForItem:(RADataObject *)item orTitle:(NSString *) title;
@end
