//
//  HelpViewController.m
//  AirManager
//

#import "HelpViewController.h"

#import "UIDevice+Resolutions.h"
#import "AlertBox.h"
#import "AboutViewController.h"
#import "WebViewController.h"

#define kRaidersIdx                 0
#define kcommonQFIdx                1
#define kAboutIdx                   2

@interface HelpViewController ()
{
    IBOutlet UITableView *_tableView;
    
}

- (IBAction)back:(id)sender;

@end

@implementation HelpViewController


#pragma mark - View LifeCycle

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
    // Do any additional setup after loading the view from its nib.
    [self customTableView];
    
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

#pragma mark - Private Methods

- (void)customTableView
{
    //Set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footerView;
    
    /*
    //set the offset cell separator 
    BOOL isSystemVersionIsIos7 = [UIDevice isSystemVersionOnIos7];
    if (isSystemVersionIsIos7) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
     */
}

- (UIButton *)accessoryButton
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:[UIImage imageNamed:@"btn_right.png"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(2, 18, 2, 18);
    return button;
}


#pragma mark - Protocol Conformance
#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:17];
        cell.textLabel.textColor = kTextColor;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == kRaidersIdx)
    {
        // text
        cell.textLabel.text = NSLocalizedString(@"使用攻略",@"HelpViewController.m");
        
        // button
        UIButton *button = [self accessoryButton];
        [button addTarget:self action:@selector(useRaidersOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    else
    
     if (indexPath.row == kcommonQFIdx)
    {
        /**
        // text
         cell.textLabel.text = NSLocalizedString(@"意见反馈",@"HelpViewController.m");
        
        // button
        UIButton *button = [self accessoryButton];
        [button addTarget:self action:@selector(FeedbackOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
         **/
        
        // text
        cell.textLabel.text = NSLocalizedString(@"常见问题与解答",@"HelpViewController.m");
        
        // button
        UIButton *button = [self accessoryButton];
        [button addTarget:self action:@selector(commonQuestionsAndFeedback:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;

    }
    else if (indexPath.row == kAboutIdx)
    {
        // text
        cell.textLabel.text = NSLocalizedString(@"关于",@"HelpViewController.m");
        
        // button
        UIButton *button = [self accessoryButton];
        [button addTarget:self action:@selector(aboutOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ybyao 存储当前时间
    NSString *lastTime = [UserDefault objectForKey:CurrentTime];
    [Utility storeCurrentTime];
    //获取时间差，防止按钮被连续点击ybyao07
    if (lastTime == nil || [Utility GetStringTimeDiff:lastTime timeE:[Utility GetCurTime]] >1)
    {
        if (indexPath.row == kRaidersIdx)
        {
            [self useRaidersOnClicked:nil];
        }
        else if (indexPath.row == kcommonQFIdx)
        {
            [self commonQuestionsAndFeedback:nil];
        }
        else if (indexPath.row == kAboutIdx)
        {
            [self aboutOnClicked:nil];
        }
    }

}


#pragma mark - IBAction Methods

/*
- (void)operateGuideOnClicked:(id)sender
{
    [UserDefault setBool:NO forKey:kHomePageHelp];
    [UserDefault setBool:NO forKey:kAirBoxManagementHelp];
    [UserDefault setBool:NO forKey:kAirBoxControlHelp];
    [UserDefault synchronize];
 [AlertBox showWithMessage:NSLocalizedString(@"操作指引将被重新显示",@"HelpViewController.m")];
}
 */

#define kRaiders @"http://uhome.haier.net/download/smartair/airbox_html/index.html"
- (void)useRaidersOnClicked:(id)sender
{
    [self openWebPageWithURLString:kRaiders Title:NSLocalizedString(@"使用攻略",@"HelpViewController.m")];
}

#define kCommon @"http://uhome.haier.net/download/smartair/airbox_html/faq.html"
- (void)commonQuestionsAndFeedback:(id)sender
{
    [self openWebPageWithURLString:kCommon Title:NSLocalizedString(@"常见问题与解答",@"HelpViewController.m")];
}

- (void)openWebPageWithURLString:(NSString *)urlString Title:(NSString *)title
{
    WebViewController *webCTRL = [[WebViewController alloc] initWithNibName:@"WebViewController"
                                                                   bundle:nil];
    webCTRL.titleString = title;
    webCTRL.urlString = urlString;
    [self presentViewController:webCTRL animated:NO completion:nil];
}

- (void)aboutOnClicked:(id)sender
{
    if ([sender isKindOfClass:UIButton.class ]) {
        ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
    }
    AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    [self.navigationController pushViewController:about animated:YES];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
