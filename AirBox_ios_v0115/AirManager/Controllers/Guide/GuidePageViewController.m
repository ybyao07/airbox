//
//  GuidePageViewController.m
//  AirManager
//

#import "GuidePageViewController.h"

#define kIndexImageWidth        33
#define kIndexImageHeight       5
#define kIndexImageVMargin      40


@interface GuidePageViewController ()
{
    UIImageView    *_imageView;
}

@end

@implementation GuidePageViewController
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // image
    NSString *imageName = [NSString stringWithFormat:@"guide%d", self.pageIndex + 1];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _imageView.image = [UIImage imageNamed:imageName];
    [self.view addSubview:_imageView];
    
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 80)];
    // start button
    _startButton.hidden = (self.pageIndex == 2) ? NO : YES;
    [self.view addSubview:_startButton];
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
