//
//  SettingViewController.m
//  AirManager
//

#import "SettingViewController.h"
#import "CitySelectionViewController.h"
#import "CityDataHelper.h"
#import "DeviceManagementViewController.h"
#import "InfoCenterViewController.h"
#import "UIDevice+Resolutions.h"
#import "UISwitchCustom.h"
#import "HelpViewController.h"
#import "WeatherManager.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "UIViewExt.h"
#import "SDKRequestManager.h"
#import "FeedbackViewController.h"
#import "CityDataHelper.h"
#import "CityViewController.h"
#import "CurrentCityWeather.h"
#import "CityManager.h"
#import "Utility.h"
#import "WXApi.h"

/**
#define kHintWeatherRowIndex        0
#define kHintIndoorRowIndex         1
#define kCitySelectionRowIndex      2
#define kUndefinedRowIndex          3
#define kFackBackRowIndex           4
 **/

#define kSubViewTagButton           100
#define kSubViewTagSwitchWeather    101
#define kSubViewTagSwitchIndoor     102

@interface SettingViewController ()
{
    IBOutlet UITableView    *_tableView;
    BOOL isLogout;
    /*
    int                     deviceManagementRowIndex;
    int                     infoCenterRowIndex;
    int                     selectedCityRowIndex;
    int                     helpRowIndex;
    int                     logoutRowIndex;
     */
    
/*---------------------------Mine--------------------------*/
    int         cityLocationIdx;
    int         selectedIdx;
    int         deviceManagerIdx;
    int         helpViewIdx;
    int         logoutIdx;
    
    int         stepIdx;
/*-----------------------------------------------------*/

}

@end

@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
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

- (void)dealloc
{
    DDLogFunction();
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSDictionary *city = [CityDataHelper selectedCity];
    /*
    if (!city)
    {
        selectedCityRowIndex = -1;
        deviceManagementRowIndex = kUndefinedRowIndex;
        infoCenterRowIndex = kUndefinedRowIndex + 1;
    }
    else
    {
        selectedCityRowIndex = kUndefinedRowIndex;
        deviceManagementRowIndex = kUndefinedRowIndex + 1;
        infoCenterRowIndex = kUndefinedRowIndex + 2;
        helpRowIndex = kUndefinedRowIndex + 3;
        logoutRowIndex = kUndefinedRowIndex + 4;
    }
     */
    
/*---------------------------Mine--------------------------*/
    /*
    if (!city) {
        selectedIdx = -1;
        cityLocationIdx = 0;
        deviceManagerIdx = 1+stepIdx;
        helpViewIdx = 2+stepIdx;
        logoutIdx = 3+stepIdx;
    }
    else
    {
        cityLocationIdx = 0;
        selectedIdx = 1;
        deviceManagerIdx = 2+stepIdx;
        helpViewIdx = 3+stepIdx;
        logoutIdx = 4+stepIdx;
    }
     */
/*-----------------------------------------------------*/
    [_tableView reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Private Methods

- (void)customTableView
{
    //Set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footerView;
    
    /*
    //Set the offset cell separator
    BOOL isSystemVersionIsIos7 = [UIDevice isSystemVersionOnIos7];
    if (isSystemVersionIsIos7)
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
     */
}

/**
- (UISwitchCustom *)createCustomSwitchWithTag:(NSInteger)tag
{
    CGRect switchFrame = CGRectMake(0, 0, 51, 31);
    UISwitchCustom *switchView = [[UISwitchCustom alloc] initWithFrame:switchFrame];
    switchView.tag = tag;
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    switchView.onImage = [UIImage imageNamed:@"switch_track_on.png"];
    switchView.offImage = [UIImage imageNamed:@"switch_track_off.png"];
    return switchView;
}
 **/

- (UIButton *)createAccessoryButton:(SEL)selector
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = kSubViewTagButton;
    [button setImage:[UIImage imageNamed:@"btn_right.png"] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(2, 18, 2, 18);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)createAccessoryButton:(SEL)selector withTitle:(NSString *)title
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = kSubViewTagButton;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Table view data source & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    if (MainDelegate.isCustomer)
    {
        number = 7;
    }
    else
    {
        number = 8;
        
        if(![MainDelegate isNetworkAvailable])
        {
            number = 2;
        }
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    DDLogCVerbose(@"IndexPath.row: %d", indexPath.row);
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:17];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = kTextColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        cell.indentationLevel = 0;
    }
    
/*---------------------------Mine--------------------------*/
    if(MainDelegate.isCustomer)
    {
        if (indexPath.row == 0)
        {
            NSMutableString *cityLocationMutable = [NSMutableString stringWithString:NSLocalizedString(@"城市定位:", @"SettingViewController1.m")];
            [cityLocationMutable appendString: [MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]]];
            NSString *cityLocation = [[NSString alloc] initWithString:cityLocationMutable];
            cell.textLabel.text = cityLocation;
            cell.accessoryView = [self createAccessoryButton:@selector(citySelectionButtonOnClicked:)];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"设备管理",@"SettingViewController.m");
            cell.accessoryView = [self createAccessoryButton:@selector(deviceManagementButtonOnClicked:)];
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"帮助",@"SettingViewController.m");
            cell.accessoryView = [self createAccessoryButton:@selector(helpButtonOnClicked:)];
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"版本检测",@"SettingViewController.m");
            cell.textLabel.textColor = [UIColor colorWithHex:0xbbbbbb alpha:1.0f];
            cell.accessoryView = [self createAccessoryButton:@selector(versionExamineOnClicked:)];
        }
        else if (indexPath.row == 4)
        {
            cell.textLabel.text = NSLocalizedString(@"意见反馈",@"SettingViewController.m");
            cell.textLabel.textColor = [UIColor colorWithHex:0xbbbbbb alpha:1.0f];
            cell.accessoryView = [self createAccessoryButton:@selector(FeedbackOnClicked:)];
        }
        else if (indexPath.row == 5)
        {
            cell.textLabel.text = NSLocalizedString(@"我要给空气盒子评分!",@"SettingViewController.m");
            cell.accessoryView = [self createAccessoryButton:@selector(ScoreOnClicked:)];
        }
        else if (indexPath.row == 6)
        {
            cell.textLabel.text = NSLocalizedString(@"关注我们",@"SettingViewController.m");
            cell.accessoryView = [self createAccessoryButton:@selector(myAttentonOnClicked:)];
        }
    }
    else
    {
        if([MainDelegate isNetworkAvailable])
        {
            if (indexPath.row == 0)
            {
                NSMutableString *cityLocationMutable = [NSMutableString stringWithString:NSLocalizedString(@"城市定位:", @"SettingViewController1.m")];
               [cityLocationMutable appendString: [MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]]];
                NSString *cityLocation = [[NSString alloc] initWithString:cityLocationMutable];
                cell.textLabel.text = cityLocation;
                cell.accessoryView = [self createAccessoryButton:@selector(citySelectionButtonOnClicked:)];
            }
            else if (indexPath.row == 1)
            {
                cell.textLabel.text = NSLocalizedString(@"设备管理",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(deviceManagementButtonOnClicked:)];
            }
            else if (indexPath.row == 2)
            {
                cell.textLabel.text = NSLocalizedString(@"帮助",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(helpButtonOnClicked:)];
            }
            else if (indexPath.row == 3)
            {
                cell.textLabel.text = NSLocalizedString(@"版本检测",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(versionExamineOnClicked:)];
            }
            else if (indexPath.row == 4)
            {
                cell.textLabel.text = NSLocalizedString(@"意见反馈",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(FeedbackOnClicked:)];
            }
            else if (indexPath.row == 5)
            {
                cell.textLabel.text = NSLocalizedString(@"我要给空气盒子评分!",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(ScoreOnClicked:)];
            }
            else if (indexPath.row == 6)
            {
                cell.textLabel.text = NSLocalizedString(@"关注我们",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(myAttentonOnClicked:)];
            }
            else if(indexPath.row == 7)
            {
                cell.textLabel.text = @"";
                CGRect frame = [UIDevice isSystemVersionOnIos7] ? CGRectMake(0, 3, 290, 38):CGRectMake(0, 3, 303, 38);
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = frame;
                [button setTitle:NSLocalizedString(@"注销",@"SettingViewController.m") forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:17];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor redColor]];
                [button addTarget:self action:@selector(logoutButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
            }
        }
        else
        {
            if (indexPath.row == 0)
            {
                cell.textLabel.text = NSLocalizedString(@"设备管理",@"SettingViewController.m");
                cell.accessoryView = [self createAccessoryButton:@selector(deviceManagementButtonOnClicked:)];
            }
            else if(indexPath.row == 1)
            {
                cell.textLabel.text = @"";
                CGRect frame = [UIDevice isSystemVersionOnIos7] ? CGRectMake(0, 3, 290, 38):CGRectMake(0, 3, 303, 38);
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = frame;
                [button setTitle:NSLocalizedString(@"注销",@"SettingViewController.m") forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:17];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button setBackgroundColor:[UIColor redColor]];
                [button addTarget:self action:@selector(logoutButtonOnClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
            }
        }
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.userInteractionEnabled =NO;//ybyao07
/*-----------------------------------------------------*/

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (indexPath.row == kCitySelectionRowIndex-2)
    {
        [self citySelectionButtonOnClicked:nil];
    }
     */
    
/*---------------------------Mine--------------------------*/
    //ybyao 存储当前时间
  NSString *lastTime = [UserDefault objectForKey:CurrentTime];
    [Utility storeCurrentTime];
    //获取时间差，防止按钮被连续点击ybyao07
    if (lastTime == nil || [Utility GetStringTimeDiff:lastTime timeE:[Utility GetCurTime]] >1) {
        if(MainDelegate.isCustomer)
        {
            if (indexPath.row == 0)
            {
                [self citySelectionButtonOnClicked:nil];
            }
            else if (indexPath.row == 1)
            {
                [self deviceManagementButtonOnClicked:[tableView cellForRowAtIndexPath:indexPath]];
            }
            else if (indexPath.row == 2)
            {
                [self helpButtonOnClicked:nil];
            }
            else if (indexPath.row == 3)
            {
                [self versionExamineOnClicked:@"button"];
            }
            else if (indexPath.row == 4)
            {
                [self FeedbackOnClicked:nil];
            }
            else if (indexPath.row == 5)
            {
                [self ScoreOnClicked:nil];
            }
            else if (indexPath.row == 6)
            {
                [self myAttentonOnClicked:nil];
            }
            
        }
        else
        {
            if([MainDelegate isNetworkAvailable])
            {
                if (indexPath.row == 0)
                {
                    [self citySelectionButtonOnClicked:nil];
                }
                else if (indexPath.row == 1)
                {
                    [self deviceManagementButtonOnClicked:[tableView cellForRowAtIndexPath:indexPath]];
                }
                else if (indexPath.row == 2)
                {
                    [self helpButtonOnClicked:nil];
                }
                else if (indexPath.row == 3)
                {
                    [self versionExamineOnClicked:@"button"];
                }
                else if (indexPath.row == 4)
                {
                    [self FeedbackOnClicked:nil];
                }
                else if (indexPath.row == 5)
                {
                    [self ScoreOnClicked:nil];
                }
                else if (indexPath.row == 6)
                {
                    [self myAttentonOnClicked:nil];
                }
            }
            else
            {
                if (indexPath.row == 0)
                {
                    [self deviceManagementButtonOnClicked:[tableView cellForRowAtIndexPath:indexPath]];
                }
            }
        }
    }
  /*-----------------------------------------------------*/
}

#pragma mark - Cell On Clicked Events

- (void)citySelectionButtonOnClicked:(id)sender
{
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }
    
    CityViewController *cityVC = [[CityViewController alloc] init];
    cityVC.citySelectedProtocol =  nil;
    cityVC.fromDeviceBind = NO;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cityVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
    
//    [self.navigationController pushViewController:cityVC animated:YES];
}


 - (void)FeedbackOnClicked:(id)sender
 {
     if ([sender isKindOfClass:UIButton.class ]) {
         ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
     }
     
     if(MainDelegate.isCustomer)
     {
         [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"WeatherMainViewController")];
         return;
     }
     
     if(![MainDelegate isNetworkAvailable])
     {
         [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
         return;
     }
     
     FeedbackViewController *feedBackController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
     feedBackController.parentContoller = self;
     [self.navigationController pushViewController:feedBackController animated:YES];
 }
 
 
/**
- (void)removeCityButtonOnClicked:(id)sender
{
   
    isLogout = NO;
 [AlertBox showWithMessage:NSLocalizedString(@"您是否要删除该城市?",@"SettingViewController.m") delegate:(id)self showCancel:YES];
}
 **/

- (void)deviceManagementButtonOnClicked:(id)sender
{
    if ([sender isKindOfClass:UIButton.class ]) {
        ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
    }
    if(MainDelegate.isCustomer)
    {
        DeviceManagementViewController *vc = [[DeviceManagementViewController alloc] initWithNibName:@"DeviceManagementViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //if(![MainDelegate isNetworkAvailable])
            if(![MainDelegate isNetworkAvailableWiFiOr3G])//ybyao07
        {
            [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
            return;
        }
        
        DeviceManagementViewController *vc = [[DeviceManagementViewController alloc] initWithNibName:@"DeviceManagementViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
//      ((UITableViewCell *)sender).userInteractionEnabled = YES;
}

- (void)infoCenterButtonOnClicked:(id)sender
{
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }
    
    InfoCenterViewController *vc = [[InfoCenterViewController alloc] initWithNibName:@"InfoCenterViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)helpButtonOnClicked:(id)sender
{
    if ([sender isKindOfClass:UIButton.class ]) {
        ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
    }
    
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"WeatherMainViewController")];
        return;
    }
    
    HelpViewController *helpController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    [self.navigationController pushViewController:helpController animated:YES];
}

- (void)versionExamineOnClicked:(id)sender
{
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"WeatherMainViewController")];
        return;
    }
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }
    
    [MainDelegate versionExamineOnClicked:sender];
}

- (void)ScoreOnClicked:(id)sender
{
    if ([sender isKindOfClass:UIButton.class ]) {
        ((UIButton *)sender).userInteractionEnabled = NO;//ybyao07-20141113
    }
    
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }
    
    NSURL *httpURL = [[NSURL alloc] initWithString:@"https://itunes.apple.com/cn/app/kong-qi-he-zi/id849464472?mt=8"];
    
    [[UIApplication sharedApplication] openURL:httpURL];
}


- (void)myAttentonOnClicked:(id)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id)self
                                                    cancelButtonTitle:NSLocalizedString(@"取消",@"AirDeivceManageViewController.m")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"微信",@"AirDeivceManageViewController.m"),NSLocalizedString(@"微博",@"AirDeivceManageViewController.m"),NSLocalizedString(@"联系我们",@"AirDeivceManageViewController.m"), nil];
    [actionSheet setTag:10000];
    [actionSheet showInView:self.view];
}


- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)logoutButtonOnClicked:(id)sender
{
    if(MainDelegate.isCustomer)
    {
        [NotificationCenter postNotificationName:AllAirDeviceRemovedNotification object:nil];
    }
    else
    {
        isLogout = YES;
        [AlertBox showWithMessage:NSLocalizedString(@"是否注销?",@"SettingViewController.m") delegate:(id)self showCancel:YES];
    }
}
- (void)logout
{
    [MainDelegate showProgressHubInView:self.view];
    
    NSDictionary *dicBody = @{@"accessToken" : MainDelegate.loginedInfo.accessToken,
                              @"accType" : @"0",
                              @"lgonId" : MainDelegate.loginedInfo.loginID,
                              @"userId" : MainDelegate.loginedInfo.userID,
                              @"sequenceId" : [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_LOGOUT method:HTTP_POST body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         [[SDKRequestManager sharedInstance] unSubscribeDeviceNotification:MainDelegate.loginedInfo.arrUserBindedDevice];
         [[SDKRequestManager sharedInstance] remoteLogout];
         
         // 删除内存中的用户名密码，用来表示未登陆状态
         MainDelegate.loginedInfo.loginID = @"";
         MainDelegate.loginedInfo.loginPwd = @"";
         MainDelegate.loginedInfo.userID = @"";
         [MainDelegate hiddenProgressHubInView:self.view];
        
         [NotificationCenter postNotificationName:AllAirDeviceRemovedNotification object:nil];
         //[NotificationCenter postNotificationName:LogoutNotification object:nil];
         /**
          NSString *errorInfo = NSLocalizedString(@"注销失败",@"SettingViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             DDLogCVerbose(@"%@",result);
             if((result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0) || [result[HttpReturnCode] intValue] == 21003)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 [NotificationCenter postNotificationName:AllAirDeviceRemovedNotification object:nil];
             }
             else
             {
                 if(result[HttpReturnInfo] && ![result[HttpReturnInfo] isEqualToString:@"会话过期"])
                 {
                     errorInfo = result[HttpReturnInfo];
                 }
                 [MainDelegate hiddenProgressHubInView:self.view];
                 [AlertBox showWithMessage:errorInfo];
             }
         }
          **/
     }];
}


#pragma mark - alertBoxDelegate

- (void)alertBoxOkButtonOnClicked
{
    if(isLogout)
    {
        [self logout];
    }
    else
    {
        [CityDataHelper removeSelectedCity];
        /*
         selectedCityRowIndex = -1;
         deviceManagementRowIndex = kUndefinedRowIndex;
         infoCenterRowIndex--;
         helpRowIndex--;
         logoutRowIndex--;
         */
        /*---------------------------Mine--------------------------*/
        selectedIdx = -1;
        deviceManagerIdx--;
        helpViewIdx--;
        logoutIdx--;
        /*-----------------------------------------------------*/
        
        [_tableView reloadData];
        
        //redownload weather
        [[WeatherManager sharedInstance] stopAutoReload];
        [[WeatherManager sharedInstance] loadWeather];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actionSheet tag] == 10000)
    {
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"微信",@"AirDeivceManageViewController.m")])
        {
            UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"微信搜索“kqzngj”订阅海尔空气盒子，了解盒子的最新动态",@"AppDelegate.m")
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"复制微信号",@"AppDelegate.m")
                                                     otherButtonTitles:nil];
            [pwdAlert show];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"微博",@"AirDeivceManageViewController.m")])
        {
            NSURL *httpURL = [[NSURL alloc] initWithString:@"http://weibo.com/kongqihezi"];
            
            [[UIApplication sharedApplication] openURL:httpURL];
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"联系我们",@"AirDeivceManageViewController.m")])
        {
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (mailClass != nil)
            {
                // We must always check whether the current device is configured for sending emails
                if ([mailClass canSendMail])
                {
                    [self displayMailComposerSheet];
                }
                else
                {
                    [self launchMailAppOnDevice];
                }
            }
            else
            {
                [self launchMailAppOnDevice];
            }
        }
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])
        {
            WXMediaMessage *message = [WXMediaMessage message];
            [message setThumbImage:[self cutScreenImage]];
            WXImageObject *ext = [WXImageObject object];
            ext.imageData = UIImagePNGRepresentation([self cutScreenImage]);
            message.mediaObject = ext;
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
            UIPasteboard *board = [UIPasteboard generalPasteboard];
            [board setString:@"kqzngj"];
        }
        else
        {
            [AlertBox showWithMessage:NSLocalizedString(@"还没有安装微信或者您的微信版本不支持此功能",@"AirDeivceManageViewController.m")];
        }
    }
}

- (UIImage *)cutScreenImage
{
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}


// 显示邮件编辑
- (void)displayMailComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // subject
    NSString *subject = @"";
    
    // emailBody
    NSString *emailBody = @"";
    
    [picker setToRecipients:[NSArray arrayWithObject:@"airbox@haierubic.com"]];
    
    [picker setSubject:subject];
    
    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

// 运行系统邮件服务
- (void)launchMailAppOnDevice
{
    // subject
    NSString *subject = @"";
    
    // emailBody
    NSString *emailBody = @"";
    
    NSString *recipients = [NSString stringWithFormat:@"mailto:airbox@haierubic.com?cc=&subject=%@", subject];
    NSString *body = [NSString stringWithFormat:@"&body=%@", emailBody];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:email];
    [[UIApplication sharedApplication] openURL:url];
}



// =======================================================================
#pragma mark - MFMailComposeViewControllerDelegate 函数
// =======================================================================
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
