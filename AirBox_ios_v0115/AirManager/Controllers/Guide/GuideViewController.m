//
//  GuideViewController.m
//  AirManager
//

#import "GuideViewController.h"
#import "GuidePageViewController.h"
#import "UIDevice+Resolutions.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface GuideViewController ()
{
    IBOutlet UIScrollView   *_scrollView;
    UIButton                *_cancelBtn;
    UIImageView             *_imageViewIndex;
}

@end

@implementation GuideViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
////    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
////    if (self) {
////        // Custom initialization
////    }
////    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    
    [self loadPageViews];
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)layoutView
{
    
    NSInteger tabHeight = 0;
    
    //判断是不是ios7
    if (IOS7) {
        //        for (UIView *view in self.view.subviews) {
        //            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        //        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        view.backgroundColor = [UIColor blackColor];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        tabHeight = 20;
        [self.view addSubview:view];
#endif
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0 , tabHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - tabHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPageViews
{
    CGRect rect = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
    
    // scroll view
    _scrollView.contentSize = CGSizeMake(rect.size.width * 3.0, rect.size.height);
    
    UIView *view1 = [[UIView alloc]init];
    [view1 setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    [self setupViewSubs:view1 withIndex:0];
    [_scrollView addSubview:view1];
    
    UIView *view2 = [[UIView alloc]init];
    [view2 setFrame:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height)];
    [self setupViewSubs:view2 withIndex:1];
    [_scrollView addSubview:view2];
    
    UIView *view3 = [[UIView alloc]init];
    [view3 setFrame:CGRectMake(rect.size.width * 2, 0, rect.size.width, rect.size.height)];
    [self setupViewSubs:view3 withIndex:2];
    [_scrollView addSubview:view3];
    
//    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(295 -10, _scrollView.frame.origin.y + 10, 25,25)];
//    [_cancelBtn addTarget:self action:@selector(closePages) forControlEvents:UIControlEventTouchUpInside];
//    [_cancelBtn setImage:[UIImage imageNamed:@"guide_cancel.png"] forState:UIControlStateNormal];
//    
//    // cancleButton
//    [self.view addSubview:_cancelBtn];
    
    // image
    _imageViewIndex = [[UIImageView alloc] initWithFrame:CGRectMake((NSInteger)(self.view.frame.size.width - 33)/ 2, _scrollView.frame.size.height - ([UIDevice isRunningOn4Inch]? 40 :20), 33,5)];
    [_imageViewIndex setImage:[UIImage imageNamed:@"guide_dian1.png"]];
    [self.view addSubview:_imageViewIndex];
    
    [Utility setExclusiveTouchAll:self.view];
}

-(void)setupViewSubs:(UIView *)parentView withIndex:(NSInteger)index
{
    // image
    NSString *imageName = [NSString stringWithFormat:@"guide%d", index + 1];
    
    NSString *newName = ([UIDevice isRunningOn4Inch]?imageName:[NSString stringWithFormat:@"%@_35",imageName]);
    UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)];
    imageView.image = [UIImage imageNamed:newName];
    [parentView addSubview:imageView];
    
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake((NSInteger)(parentView.frame.size.width - 198)/ 2, parentView.frame.size.height - ([UIDevice isRunningOn4Inch]? 180 :160), 198,37)];
    [startButton setTitle:@"开始体验" forState:UIControlStateNormal];
    [startButton setBackgroundColor:[UIColor colorWithHex:0x81c16d alpha:1.0f]];
    [startButton addTarget:self action:@selector(closePages) forControlEvents:UIControlEventTouchUpInside];
    
    // start button
    startButton.hidden = (index== 2) ? NO : YES;
    [parentView addSubview:startButton];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if(aScrollView.contentOffset.x == 0)
    {
        _imageViewIndex.image = [UIImage imageNamed:@"guide_dian1.png"];
    }
    else if(aScrollView.contentOffset.x == _scrollView.frame.size.width)
    {
        _imageViewIndex.image = [UIImage imageNamed:@"guide_dian2.png"];
    }
    else if(aScrollView.contentOffset.x == _scrollView.frame.size.width * 2)
    {
        _imageViewIndex.image = [UIImage imageNamed:@"guide_dian3.png"];
    }
}

- (void)closePages
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:MainDelegate.mainViewController];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

@end
