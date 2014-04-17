//
//  HelpViewController.m
//  Manapp
//
//  Created by Demigod on 02/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#define kNumberOfImageHelp 8

#import "HelpViewController.h"
#import "MASession.h"
#import "Partner.h"

@interface HelpViewController ()
-(void) loadUI;
-(void) btnBack_touchUpInside:(id) sender;
@end

@implementation HelpViewController

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
    // Do any additional setup after loading the view from its nib.
    //Add Gesture Recognize
    
    //LeftGesture
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeft:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftGesture];
    
    //Right Gesture
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightGesture];
    
    [self loadUI];
    [self loadHelpImage];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showMessage:@"Slide screen either way to get sum help today." title:kAppName cancelButtonTitle:@"OK"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - help functions
-(void)loadHelp{
    for(NSInteger i = 1; i <= kNumberOfImageHelp; i++){
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"help_%d",i]];
        DLogInfo(@"x: %f",self.scrollAvatar.frame.size.width * (i-1));
        //        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollAvatar.frame.size.width * (i-1), 0, self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
        UIImageView *imageView = nil;
        if (IS_IPHONE_5) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollAvatar.frame.size.width * (i-1), 10, self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
        }else{
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollAvatar.frame.size.width * (i-1), 0, self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
        }
        
        DLogInfo(@"self.scrollAvatar.frame.size.height: %f",self.scrollAvatar.frame.size.height);
        DLogInfo(@"width: %f",self.scrollAvatar.frame.size.width);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        if (i==1) {
            currentImageView = imageView;
        }
        /*
         UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinGesture:)];
         [imageView addGestureRecognizer:pin];
         [imageView setUserInteractionEnabled:YES];
         */
        [self.scrollAvatar addSubview:imageView];
    }
    [self.scrollAvatar setContentSize:CGSizeMake(self.scrollAvatar.frame.size.width * kNumberOfImageHelp, self.scrollAvatar.frame.size.height)];
    self.scrollAvatar.delegate = self;
    self.scrollAvatar.minimumZoomScale = 1.0;
    self.scrollAvatar.maximumZoomScale = 100.0;
    [self.scrollAvatar setPagingEnabled:YES];
    
    MAAppDelegate *appdelegate = (MAAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.indexImageShow == kIndexHelpShowHomepage) {
        self.scrollAvatar.contentOffset = CGPointMake(self.scrollAvatar.frame.size.width * kIndexHelpShowHomepage , self.scrollAvatar.frame.origin.y);
    }
}
-(void) loadHelpImage
{
    UIImage *image;
    MAAppDelegate *appdelegate = (MAAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.indexImageShow == kIndexHelpShowHomepage) {
        _currentPhotoIndex = kIndexHelpShowHomepage;
        image = [UIImage imageNamed:[NSString stringWithFormat:@"help_%d", _currentPhotoIndex]];
    }else{
        _currentPhotoIndex = 1;
        image = [UIImage imageNamed:@"help_1"];

    }
       UIImageView *imageView = nil;
    if (IS_IPHONE_5) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
    }else{
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    currentImageView = imageView;
    [self.scrollAvatar addSubview:imageView];
    [self.scrollAvatar setContentSize:CGSizeMake(self.scrollAvatar.frame.size.width, self.scrollAvatar.frame.size.height)];
    self.scrollAvatar.delegate = self;
    self.scrollAvatar.minimumZoomScale = 1.0;
    self.scrollAvatar.maximumZoomScale = 100.0;
}
#pragma mark - init functions
-(void)loadUI{
    //add back button
    self.scrollAvatar.frame = CGRectMake(0, 0, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
    [self createBackNavigationWithTitle:@"Home"];
}

#pragma mark - event handler
-(void) btnBack_touchUpInside:(id) sender{
    [self back];
}

- (void)dealloc {
    [_scrollAvatar release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollAvatar:nil];
    [super viewDidUnload];
}


-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return currentImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so you need to re-center the contents
    [self centerScrollViewContents];
}
-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self centerScrollViewContents];
}
- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollAvatar.bounds.size;
    CGRect contentsFrame = currentImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        // Cuongnt comment - fix center image
//        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
        contentsFrame.origin.y = 0;
        if(IS_IPHONE_5){
            contentsFrame.origin.y = 10;
        }
        
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    currentImageView.frame = contentsFrame;
    
}
#pragma mark Gesture
//Move left
-(void)moveLeft:(UISwipeGestureRecognizer*) swipeLeft
{
    [self setCurrentPhotoIndex:_currentPhotoIndex + 1 animated:YES];
}
//Move right
-(void) moveRight:(UISwipeGestureRecognizer*) swipeRight
{
    [self setCurrentPhotoIndex:_currentPhotoIndex - 1 animated:YES];
}

-(void)setCurrentPhotoIndex:(NSInteger)nextPhotoIndex animated:(BOOL)animated{
    
    // Reset the networkOperation.
    BOOL isNotFirstIndex = nextPhotoIndex >= 1;
    BOOL isNotLastIndex = nextPhotoIndex < kNumberOfImageHelp+1;
    
    if(isNotFirstIndex == YES && isNotLastIndex == YES){
        if(animated == YES){
            NSString *direction = (_currentPhotoIndex > nextPhotoIndex)?kCATransitionFromLeft:kCATransitionFromRight;
            
            if (UIInterfaceOrientationPortrait == [[UIApplication sharedApplication] statusBarOrientation]) {
                direction = (_currentPhotoIndex > nextPhotoIndex)?kCATransitionFromLeft:kCATransitionFromRight;
            } else if(UIInterfaceOrientationLandscapeLeft == [[UIApplication sharedApplication] statusBarOrientation]){
                direction = (_currentPhotoIndex > nextPhotoIndex)?kCATransitionFromTop:kCATransitionFromBottom;
            } else if(UIInterfaceOrientationLandscapeRight == [[UIApplication sharedApplication] statusBarOrientation]){
                direction = (_currentPhotoIndex > nextPhotoIndex)?kCATransitionFromBottom:kCATransitionFromTop;
            }
            
            [self transitionFromView:currentImageView toView:currentImageView usingContainerView:self.view andTransition:direction];
            currentImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"help_%d",nextPhotoIndex]];
        }
        _currentPhotoIndex = nextPhotoIndex;
    }
}

@end
