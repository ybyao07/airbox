//
//  WebViewController.m
//  AirManager
//
//  Created by chen on 14-5-27.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
{
    IBOutlet UIWebView *_webView;
    IBOutlet UIButton *backButton;
    IBOutlet UIActivityIndicatorView *activityView;
    IBOutlet UILabel *lblTitle;
    
}

/**
 *  close current Controller
 */
- (IBAction)dismissView:(id)sender;

@end

@implementation WebViewController

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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    lblTitle.text = NSLocalizedString(self.titleString,@"WebViewController1.m");//ybyao
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private

- (IBAction)dismissView:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityView stopAnimating];
    activityView.hidden = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityView stopAnimating];
    activityView.hidden = YES;
}


@end
