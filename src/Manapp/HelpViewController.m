//
//  HelpViewController.m
//  Manapp
//
//  Created by Demigod on 02/01/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#define kNumberOfImageHelp 8
#define kOriginalYForCurrentImageIP5 40

#import "HelpViewController.h"
#import "MASession.h"
#import "Partner.h"

@interface HelpViewController ()
-(void) loadUI;
-(void) btnBack_touchUpInside:(id) sender;
@end

@implementation HelpViewController
@synthesize currentImageView;

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
    [self loadUI];
    
    //LeftGesture
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveLeft:)];
    [leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftGesture];
    
    //Right Gesture
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveRight:)];
    [rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightGesture];
    
    
    [self loadHelpImage];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollAvatar.bounds),
//                                      CGRectGetMidY(self.scrollAvatar.bounds));
//    [self view:self.currentImageView setCenter:centerPoint];
    

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

    if (IS_IPHONE_5) {
        self.currentImageView.frame = CGRectMake(0, kOriginalYForCurrentImageIP5, image.size.width, image.size.height);
    }
    self.currentImageView.image = image;
    self.currentImageView.contentMode = UIViewContentModeScaleToFill;
    [self.currentImageView sizeToFit];
    self.scrollAvatar.contentSize = image.size;


    self.scrollAvatar.delegate = self;
    self.scrollAvatar.minimumZoomScale = 1.0;
    self.scrollAvatar.maximumZoomScale = 100.0;

}
#pragma mark - init functions
-(void)loadUI{
    //add back button
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH_PORTRAIT, SCREEN_HEIGHT_PORTRAIT);
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
    return self.currentImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv {
    UIView* zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
    
}
-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{

//    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.scrollAvatar.bounds),
//                                      CGRectGetMidY(self.scrollAvatar.bounds));
//    [self view:currentImageView   setCenter:centerPoint];


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
//        if(IS_IPHONE_5){
//            contentsFrame.origin.y = 10;
//        }
        
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


- (void)view:(UIView*)view setCenter:(CGPoint)centerPoint
{
    CGRect vf = view.frame;
    CGPoint co = self.scrollAvatar.contentOffset;
    
    CGFloat x = centerPoint.x - vf.size.width / 2.0;
    CGFloat y = centerPoint.y - vf.size.height / 2.0;
    
    if(x < 0)
    {
        co.x = -x;
        vf.origin.x = 0.0;
    }
    else
    {
        vf.origin.x = x;
    }
    if(y < 0)
    {
        co.y = -y;
        vf.origin.y = 0.0;
    }
    else
    {
        vf.origin.y = y;
    }
    
    view.frame = vf;
    if (IS_IPHONE_5) {
        co.y = -50;
    }
    self.scrollAvatar.contentOffset = co;
}


@end
