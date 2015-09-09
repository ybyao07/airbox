//
//  AgreementViewController.m
//  AirManager
//

#import "AgreementViewController.h"

@interface AgreementViewController ()

- (IBAction)backToMainView:(id)sender;

- (IBAction)agreeUserAgreement:(id)sender;

@end

@implementation AgreementViewController

@synthesize isFromRegisteView;

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
    [self loadHTMLAgreement];
    
    [Utility setExclusiveTouchAll:self.view];
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

- (IBAction)agreeUserAgreement:(id)sender
{
    if(isFromRegisteView)
    {
        [NotificationCenter postNotificationName:AgreeUserAgreementNotification object:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.view.alpha = 0.0;
            } completion:^(BOOL finished){
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        });
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (IBAction)backToMainView:(id)sender
{
    if(isFromRegisteView)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.view.alpha = 0.0;
            } completion:^(BOOL finished){
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        });
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadHTMLAgreement
{
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"agreement" ofType:@"html"];
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlString baseURL:nil];
}

@end
