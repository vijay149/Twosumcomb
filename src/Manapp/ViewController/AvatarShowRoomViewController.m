//
//  AvatarShowRoomViewController.m
//  TwoSum
//
//  Created by Demigod on 03/06/2013.
//  Copyright (c) 2013 Seta. All rights reserved.
//

#import "AvatarShowRoomViewController.h"
#import "MASession.h"
#import "Partner.h"
#import "UIView+Additions.h"

@interface AvatarShowRoomViewController ()

@end

@implementation AvatarShowRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_scrollView release];
    [_avatas release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark - init functions
- (void)initialize{
    self.avatas = [NSMutableArray array];
}

#pragma mark - UI functions
- (void)loadUI{
    [self createBackNavigationWithTitle:MA_CANCEL_BUTTON_TEXT action:@selector(back)];
    
    //avatars
    self.avatas = [NSMutableArray array];
    if([MASession sharedSession].currentPartner.sex.integerValue == MANAPP_SEX_FEMALE){
        UIImageView *imgDress = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
        imgDress.image = [UIImage imageNamed:@"F_Dress"];
        [self.avatas addObject:imgDress];
        
        UIImageView *imgSuit = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
        imgSuit.image = [UIImage imageNamed:@"F_Suit"];
        [self.avatas addObject:imgSuit];
    }
    else{
        UIImageView *imgDress = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
        imgDress.image = [UIImage imageNamed:@"M_Shoes"];
        [self.avatas addObject:imgDress];
        
        UIImageView *imgSuit = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)] autorelease];
        imgSuit.image = [UIImage imageNamed:@"M_Tee"];
        [self.avatas addObject:imgSuit];
    }
    
    //image
    NSInteger totalAvatar = self.avatas.count;
    for(NSInteger i = 0; i < totalAvatar; i++){
        UIImageView *imgAvatar = [self.avatas objectAtIndex:i];
        [imgAvatar setOriginX:i * self.scrollView.frame.size.width];
        [self.scrollView addSubview:imgAvatar];
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width * totalAvatar, self.scrollView.frame.size.height)];
}
@end
