//
//  InfoCenterViewController.m
//  AirManager
//

#import "InfoCenterViewController.h"
#import "UIDevice+Resolutions.h"
#import "UISwitchCustom.h"

@interface InfoCenterViewController ()
{
    IBOutlet UITableView *_tableView;
    NSArray *arrCellTitle;
}

@property (nonatomic,strong) NSArray *arrCellTitle;

@end

@implementation InfoCenterViewController

@synthesize arrCellTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    self.arrCellTitle = @[    NSLocalizedString(@"开启免打扰模式", @"InfoCenterViewController.m"),
                              NSLocalizedString(@"订阅信息", @"InfoCenterViewController.m"),
                              NSLocalizedString(@"增值信息", @"InfoCenterViewController.m"),
                              NSLocalizedString(@"提醒信息", @"InfoCenterViewController.m"),
                              NSLocalizedString(@"警告信息", @"InfoCenterViewController.m"),
                              NSLocalizedString(@"设置信息铃声", @"InfoCenterViewController.m")];
    
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
}


#pragma mark - Private Methods

- (void)customTableView
{
    //set the line TableView separator
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

#pragma mark - IBAction Methods

- (IBAction)exitPage
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)switchAction:(UISwitch *)sender
{

}

- (void)buttonAction:(UIButton *)sender
{
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [arrCellTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Euphemia UCAS" size:17];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.textLabel.text = NSLocalizedString(arrCellTitle[indexPath.row],@"InfoCenterViewController1.m");//ybyao
    if(indexPath.row == 0)
    {
        // switch
        UISwitchCustom *switchView = [[UISwitchCustom alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        switchView.tag = indexPath.row;
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        switchView.onImage = [UIImage imageNamed:@"switch_track_on.png"];
        switchView.offImage = [UIImage imageNamed:@"switch_track_off.png"];
        cell.accessoryView = switchView;
    }
    else
    {
        CGRect frame = CGRectMake(0, 0, 51, 31);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.tag = indexPath.row;
        [button setImage:[UIImage imageNamed:@"btn_right.png"] forState:UIControlStateNormal];
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 18, 2, 18);
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    return cell;
}

@end
