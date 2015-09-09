//
//  AboutViewController.m
//  AirManager
//

#import "AboutViewController.h"
#import "AgreementViewController.h"

@interface AboutViewController ()
{
    
}

- (IBAction)readUserAgreement:(id)sender;

- (IBAction)backToHelpView:(id)sender;

@end

@implementation AboutViewController

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
    
    [self layoutView];
    
    [Utility setExclusiveTouchAll:self.view];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated
{
    _userAgreementBtn.userInteractionEnabled = YES;
}

- (void)layoutView
{
    _baseview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BASEVIEWWIDTH, BASEVIEWHEIGH)];
    
    for(UIView *subView in self.view.subviews)
    {
        if(subView != _baseview)
        {
            [subView removeFromSuperview];
            [_baseview addSubview:subView];
        }
    }
    
    //判断是不是ios7
    if (IOS7) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
#endif
    }
    
    _baseview.frame = CGRectMake(0, ADDHEIGH, 320, VIEWHEIGHT);
    _baseview.backgroundColor  = [UIColor clearColor];
    [self.view addSubview:_baseview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)readUserAgreement:(id)sender
{
    if ([sender isKindOfClass:UIButton.class ]) {
        ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
    }
    AgreementViewController *agreement = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil];
    agreement.isFromRegisteView = NO;
    [self.navigationController pushViewController:agreement animated:YES];
}

- (IBAction)backToHelpView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
