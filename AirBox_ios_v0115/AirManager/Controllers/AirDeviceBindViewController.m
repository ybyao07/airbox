//
//  AirDeviceBindViewController.m
//  AirManager
//

#import "AirDeviceBindViewController.h"
#import "Reachability.h"
#import "AirDeviceManager.h"
#import "AirDevice.h"
#import "MainViewController.h"
#import "AirBoxConnectAnimationView.h"
#import "DeviceManagementViewController.h"
#import "CityDataHelper.h"
#import "UserLoginedInfo.h"
#import <uSDKFramework/uSDKDevice.h>
#import <uSDKFramework/uSDKDeviceConfigInfo.h>
#import <uSDKFramework/uSDKDeviceManager.h>
#import "AppDelegate.h"
#import "SDKRequestManager.h"
#import "AlertBox.h"
#import "IRDeviceModelSelectionViewController.h"
#import "FeedbackViewController.h"
#import "LocationController.h"
#import "CityViewController.h"
#import "UIDevice+Resolutions.h"

#define  kAirBoxNameMaxLength           16
enum
{
    kSecondBindError = 0,
    kFirstBindError = 1
};

typedef enum
{
    kPutOut = 665,
    kFlash  = 666,
    kBright = 667
}LightStatus;

@interface AirDeviceBindViewController ()
{
    __weak IBOutlet UIButton *pwdErrorBtn;
    IBOutlet UIView         *inputPwdView;
    IBOutlet UIView         *bindProgressView;
    IBOutlet UIView         *bindSucceedView;
    IBOutlet UIView         *firstBindFailedView;
    IBOutlet UIView         *checkWifi;
    IBOutlet UIView         *pwdErrorView;
    IBOutlet UIView         *secondBindFailedView;
    
    __weak IBOutlet UIButton *btnComplete;
    __weak IBOutlet UITextField *txtName;
    __weak IBOutlet UILabel *lblLocation;
    __weak IBOutlet UIImageView *locationImg;
    IBOutlet UILabel        *ssidLbl;
    IBOutlet UITextField    *ssidPwdTxf;
//    IBOutlet UILabel        *bindFinishedMessage;
    IBOutlet AirBoxConnectAnimationView *connectView;
    
    IBOutlet UILabel *lblDeployState;
    
    NSMutableArray          *airBoxNameList;
    NSString                *airBoxName;
    NSOperationQueue        *queue;
    NSInteger               countBindedDevice;
    BOOL                    isEasyLinking;
    NSInteger               checkTimeCount;
    NSInteger               bindTimeCount;
    NSInteger               waitTimeCount;
    
    NSString                *wifiSsid;
    NSString                *wifiPwd;
    LightStatus             lightStatus;
    
    IBOutlet UILabel        *pwdErrorMessage;
    IBOutlet UIView         *pwdErrorFlash;
    BOOL                    isFinishLocation;
    NSTimer                 *_countDownTimer;
}

- (void)submitAppError:(NSString *)body;

@property(nonatomic,strong)NSString *airBoxName;
@property(nonatomic,strong)NSArray *sdkSearchedDevice;
@property(nonatomic,strong)NSString *wifiSsid;
@property(nonatomic,strong)NSString *wifiPwd;
@property(nonatomic,assign)NSInteger curDeviceIndex;
@property(nonatomic,strong)NSString *cityName;
@property(nonatomic,strong)NSString *cityID;
@property(nonatomic,strong)NSArray *arrBindDev;
@property (nonatomic, assign) NSInteger keyboardHeight;                 // 键盘高度

@end

@implementation AirDeviceBindViewController

@synthesize airBoxName;
@synthesize wifiSsid;
@synthesize wifiPwd;

- (void)dealloc
{
    DDLogFunction();
    [[LocationController getInstance] stopUpdatingLocationWithSender:self];
    
    if(_countDownTimer.isValid)
    {
        [_countDownTimer invalidate];
    }
    
    _countDownTimer = nil;
}

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
    
    bindTimeCount = 0;
    waitTimeCount = 0;
    _curDeviceIndex = -1;
    
    queue = [[NSOperationQueue alloc] init];
    airBoxNameList = [[NSMutableArray alloc] init];
    for (int i = 0; i < MainDelegate.loginedInfo.arrUserBindedDevice.count; i++)
    {
        AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
        [airBoxNameList addObject:device.name];
    }
    [connectView prepareConnect];
    
    isFinishLocation = NO;
    [[LocationController getInstance] startUpdatingLocationWithPurpose:@"" andSender:self];
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
    
    _baseview.frame = CGRectMake(0, ADDHEIGH, 320, BASEVIEWHEIGH);
    _baseview.backgroundColor  = [UIColor clearColor];
    [self.view addSubview:_baseview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self regKeyboardNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unregKeyboardNotification];
}


- (void)regKeyboardNotification
{
    // 键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    // 键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


// 键盘显示
- (void)keyboardDidShow:(NSNotification *)notification
{
    if([UIDevice isRunningOn4Inch])
    {
        return;
    }
    if(_keyboardHeight == 0)
    {
        NSValue *frameEnd = nil;
        
        frameEnd = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        // 3.2以后的版本
        if(frameEnd != nil)
        {
            // 键盘的Frame
            CGRect keyBoardFrame;
            [frameEnd getValue:&keyBoardFrame];
            
            // 保存键盘的高度
            [self setKeyboardHeight:keyBoardFrame.size.height];
        }
        else
        {
            // 保存键盘的高度
            [self setKeyboardHeight:216];
        }
        [UIView animateWithDuration:0.2 animations:^{
            // 修正TableView的高度
            [self.view setViewY:(self.view.frame.origin.y - _keyboardHeight + 60)];
        } completion:^(BOOL finished){
        }];
        
    }
}

// 键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    if([UIDevice isRunningOn4Inch])
    {
        return;
    }
    [self.view setViewY:(self.view.frame.origin.y + _keyboardHeight - 60)];
    [self setKeyboardHeight:0];
}

// =======================================================================
#pragma mark - 定位函数
// =======================================================================
- (void)UpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation WithPurpose:(NSString *)purpose andError:(NSString *)error andErrorCode:(NSInteger)errorCode
{
    isFinishLocation = YES;
    DDLogFunction();
    if (errorCode == kLocationErrorWithPermission || (errorCode != 0 && (error != nil && [error length] > 0) ))
    {
        /*--------------------------ybyao--------------------*/
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                           message:error
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"确定",@"CityViewController.m")
                                                 otherButtonTitles:nil];
        [pwdAlert show];
        return;
    }
    
    NSString *lat = [[NSString alloc] initWithFormat:@"%g",
                     newLocation.coordinate.latitude];
    
    NSString *lng = [[NSString alloc] initWithFormat:@"%g",
                     newLocation.coordinate.longitude];
    
    NSNumber *latNum = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
    
    NSNumber *lngNum = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
    
    if(latNum && lngNum)
    {
        NSDictionary *deviceLocation = @{
                                         DeviceLat:latNum,
                                         DeviceLng:lngNum
                                         };
        [UserDefault setObject:deviceLocation forKey:DeviceLocation];
        [UserDefault synchronize];
        
        MainDelegate.devicelat = latNum;
        MainDelegate.devicelng = lngNum;
        
        
        NSString *urlStr = [NSString stringWithFormat:@"%@wonderweather/location?lng=%@&lat=%@",BASEURL,lng,lat];
        [self dataRequestLocation:urlStr];
    }
}

-(void)dataRequestLocation:(NSString *)urlStr{
    
    DDLogFunction();
    NSString *requestStr = urlStr;
    NSURL *url = [NSURL URLWithString:requestStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        DDLogCVerbose(@"--->dataRequestLocation reponse data --->:%@ ",str);
        if ([[dic objectForKey:@"code"] integerValue] == 0) {
            NSMutableDictionary *currentCityDic = [[NSMutableDictionary alloc] initWithDictionary:[dic valueForKey:@"data"]];
            NSString *prov = nil;
            NSString *city = nil;
            if([MainDelegate isLanguageEnglish]){
                prov = [currentCityDic objectForKey:@"proven"];
                city = [currentCityDic objectForKey:@"nameen"];
            }
            else{
                prov = [currentCityDic objectForKey:@"provcn"];
                city = [currentCityDic objectForKey:@"namecn"];
                
            }
            weakSelf.cityID = [currentCityDic objectForKey:@"areaid"];
            if(prov || city)
            {
                if([prov isEqualToString:city])
                {
                    weakSelf.cityName = city;
                }
                else
                {
                    weakSelf.cityName = [NSString stringWithFormat:@"%@%@",prov,city] ;
                }
            }
        }else{//请求失败
            
                   }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    [operation start];
}

#pragma mark - Button Action

- (IBAction)accordWithBindCondtion:(id)sender
{
    DDLogFunction();
    if (![MainDelegate isCurrentNetworkWiFi]) {
        [AlertBox showWithMessage:NSLocalizedString(@"Wi-Fi网络未连接，请连接Wi-Fi",@"AirDeviceBindViewController.m")];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ssidLbl.text = [MainDelegate ssidForConnectedNetwork];
        self.wifiSsid = ssidLbl.text;
    });
    [self openView:inputPwdView completion:nil];
}

- (IBAction)checkWifi:(id)sender
{
    DDLogFunction();
    [self openView:checkWifi completion:nil];
}

- (IBAction)chekWifiOk:(id)sender
{
    DDLogFunction();
    [self closeView:checkWifi completion:nil];
}

- (IBAction)lastStepInStep2:(id)sender
{
    DDLogFunction();
    
//    [self closeView:step2];
    [self closeEasyLink:sender];
}

- (IBAction)startEasyLink:(id)sender
{
    DDLogFunction();
// 绑定设备页面，改为为不输入密码也可以绑定（wifi密码输入页面）
//    if (ssidPwdTxf.text.length <= 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [AlertBox showWithMessage:NSLocalizedString(@"请输入路由器密码",@"AirDeviceBindViewController.m")];
//        });
//        return;
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [connectView startAnimating];
    });
    [self openView:bindProgressView completion:^{
        [self closeView:inputPwdView completion:nil];
    }];
    
    [self easyLink];
}

- (IBAction)cancelInStep3:(id)sender
{
    DDLogFunction();
    bindTimeCount--;
    [self closeEasyLink:sender];

    /*
    [self stopEasyLink];
    [self closeView:step2];
    [self closeView:step3];
     */
}

- (IBAction)completeInStep4:(id)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])return;
    
    if ([[txtName.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能为空",@"ChangeNameViewController.m")];
        return;
    }
    
    if([txtName.text length] > kAirBoxNameMaxLength){
        [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能超过16个字符", @"ChangeNameViewController.m") ];
        return;
        return;
    }
    
    NSString *regex = @"^[A-Za-z0-9\u4E00-\u9FA5_-]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:txtName.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能包含特殊字符",@"ChangeNameViewController.m")];
        return;
    }
    
    if([airBoxNameList containsObject:txtName.text])
    {
        if(_curDeviceIndex >= 0  && _curDeviceIndex < _arrBindDev.count)
        {
            AirDevice *airDevice = [_arrBindDev objectAtIndex:_curDeviceIndex];
            if([airDevice.name isEqualToString:txtName.text])
            {
                [MainDelegate showProgressHubInView:self.view];
                [self modifyNickName:0];
            }
            else
            {
                [AlertBox showWithMessage:NSLocalizedString(@"不能与其他设备同名，请重新设置新的名称",@"ChangeNameViewController.m")];
            }
        }
    }
    else
    {
        [MainDelegate showProgressHubInView:self.view];
        [self modifyNickName:0];
    }
}


- (void)modifyNickName:(NSInteger)requestCount
{
    DDLogFunction();
    NSDictionary *dicBody = @{@"name":txtName.text,
                              @"userId":MainDelegate.loginedInfo.userID,
                              @"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    
    if(_curDeviceIndex >= 0  && _curDeviceIndex < _arrBindDev.count)
    {
        AirDevice *airDevice = [_arrBindDev objectAtIndex:_curDeviceIndex];
        
        if([airDevice.name isEqualToString:txtName.text])
        {
            // 没有修改名称的话，不用发送网络请求，直接下一个盒子命名
            [self gotoNextVC];
        }
        else
        {
            NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_RENAME(airDevice.mac)
                                                             method:HTTP_PUT
                                                               body:body];
            [NSURLConnection sendAsynchronousRequestTest:request
                                                   queue:[NSOperationQueue currentQueue]
                                       completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
             {
                 if(error)
                 {
                     if(requestCount < 3)
                     {
                         [MainDelegate reDownloadToken:^(BOOL succeed){
                             [self modifyNickName:requestCount + 1];
                         }];
                         return;
                     }

                     [self gotoNextVC];
                     
                 }
                 else
                 {
                     NSDictionary *result = [MainDelegate parseJsonData:data];
                     result = isObject(result) ? result : nil;
                     DDLogCVerbose(@"--->修改空气盒子名称接口信息%@",result);
                     if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                     {
                         [airBoxNameList removeObject:airDevice.name];
                         [airBoxNameList addObject:txtName.text];
                         airDevice.name = txtName.text;
                         
                         [self gotoNextVC];
                     }
                     else
                     {
                         if(requestCount < 3)
                         {
                             [MainDelegate reDownloadToken:^(BOOL succeed){
                                 [self modifyNickName:requestCount + 1];
                             }];
                             return;
                         }
                         
                         [self gotoNextVC];
                         
                     }
                 }
             }];
        }
    }
}


- (void)gotoNextVC
{
    [MainDelegate hiddenProgressHubInView:self.view];
    
    NSInteger count = _arrBindDev.count -1;
    if(_curDeviceIndex < count)
    {
        _curDeviceIndex ++;
        [self openView:bindSucceedView completion:nil];
        
    }
    else
    {
        if([[self parentViewController] isKindOfClass:[MainViewController class]])
        {
            [self openHomePage];
        }
        else
        {
            [self reloadDeviceMangementView];
        }
        
        // 更新缓存
        AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
        [airDeviceManager downloadBindedDeviceWithCompletionHandler:^(NSMutableArray *array,BOOL succeed){
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closeEasyLink:nil];
        });
    }
}
- (IBAction)retryEasyLink:(id)sender
{
    DDLogFunction();
    [bindProgressView removeFromSuperview];
    [self closeView:secondBindFailedView completion:^{
        [self openView:inputPwdView completion:nil];
    }];
}

- (IBAction)openPwdError:(UIButton *)sender
{
    DDLogFunction();
    NSDictionary *params = @{@"deviceId":@"",@"userId":MainDelegate.loginedInfo.userID,@"name":@""};
    NSDictionary *body = @{@"sequenceId":[MainDelegate sequenceID],
                           @"errorCode":@"",
                           @"errorInfo":@"first bind failed",
                           @"name":@"",
                           @"type":@"sdk",
                           @"errorTime":[self errorSubmitDate],
                           @"errorLevel":@"2",
                           @"clientType":[UIDevice currentDevice].systemVersion,
                           @"params":params
                           };
    NSString *bodyString = [MainDelegate createJsonString:body];
    [self submitAppError:bodyString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (sender.tag)
        {
            case kPutOut:
            {
                pwdErrorMessage.hidden = NO;
                pwdErrorFlash.hidden = YES;
                [pwdErrorBtn setTitle:@"重置完成，WiFi指示灯已闪烁" forState:UIControlStateNormal];
                [pwdErrorBtn setTitle:@"重置完成，WiFi指示灯已闪烁" forState:UIControlStateDisabled];
                [pwdErrorBtn setTitle:@"重置完成，WiFi指示灯已闪烁" forState:UIControlStateHighlighted];
            }
                break;
            case kFlash:
            {
                pwdErrorMessage.hidden = YES;
                pwdErrorFlash.hidden = NO;
                [pwdErrorBtn setTitle:@"下一步" forState:UIControlStateNormal];
                [pwdErrorBtn setTitle:@"下一步" forState:UIControlStateDisabled];
                [pwdErrorBtn setTitle:@"下一步" forState:UIControlStateHighlighted];
            }
                break;
                
            default:
                break;
        }
    });
    
    [self openView:pwdErrorView completion:^{
        [self closeView:firstBindFailedView completion:nil];
    }];
}

- (IBAction)retryInPwdErrorView:(id)sender
{
    DDLogFunction();
    [self closeView:pwdErrorView completion:nil];
}

- (IBAction)reBindInFirstErrorView:(id)sender
{
    DDLogFunction();
    NSDictionary *params = @{@"deviceId":@"",@"userId":MainDelegate.loginedInfo.userID,@"name":@""};
    NSDictionary *body = @{@"sequenceId":[MainDelegate sequenceID],
                           @"errorCode":@"",
                           @"errorInfo":@"Second bind failed",
                           @"name":@"",
                           @"type":@"sdk",
                           @"errorTime":[self errorSubmitDate],
                           @"errorLevel":@"2",
                           @"clientType":[UIDevice currentDevice].systemVersion,
                           @"params":params
                           };
    NSString *bodyString = [MainDelegate createJsonString:body];
    [self submitAppError:bodyString];
    
    [self openView:bindProgressView completion:^{
        [self closeView:firstBindFailedView completion:nil];
        [self easyLink];
    }];
}

- (IBAction)closeEasyLink:(id)sender
{
    DDLogFunction();
    if(sender)
    {
        if ([_parentVC isKindOfClass:[MainViewController class]])
        {
            [(MainViewController *)_parentVC clearLoginInfo];
        }
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });
}

- (IBAction)oepnACorAPBindPage:(UIButton *)sender
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = @"IRDeviceModelSelectionViewController";
        IRDeviceModelSelectionViewController *vc = [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
        vc.deviceType = sender.tag == 0 ? kDeviceTypeAP : kDeviceTypeAC;
        vc.selectedAirDevice = MainDelegate.curBindDevice;
        vc.view.frame = [self parentViewController].view.frame;
        vc.view.alpha = 0.0;
        [MainDelegate.window addSubview:vc.view];
        [self addChildViewController:vc];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        } completion:^(BOOL finished) {
//            [self completeInStep4:sender];
        }];
    });
}

- (IBAction)sendFeedBackForFailed
{
    DDLogFunction();
    FeedbackViewController *feedBackController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    feedBackController.view.frame = self.view.frame;
    feedBackController.parentContoller = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        feedBackController.view.alpha = 0.0;
        [MainDelegate.window addSubview:feedBackController.view];
        [UIView animateWithDuration:0.3 animations:^{
            feedBackController.view.alpha = 1.0;
            [self addChildViewController:feedBackController];
        }];
    });
}

#pragma mark - Open or close view

- (void)openView:(UIView *)view completion:(void(^)())completion
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        if([view isEqual:bindSucceedView])
        {
            if(_curDeviceIndex >= 0  && _curDeviceIndex < _arrBindDev.count)
            {
                AirDevice *airDevice = [_arrBindDev objectAtIndex:_curDeviceIndex];
                
                NSString *btnTitle = (_curDeviceIndex == (_arrBindDev.count -1)) ? @"完成" :@"下一个盒子";
                [btnComplete setTitle:btnTitle forState:UIControlStateNormal];
                [btnComplete setTitle:btnTitle forState:UIControlStateHighlighted];
                [btnComplete setTitle:btnTitle forState:UIControlStateDisabled];
                
                txtName.text = airDevice.name;
            }
        }
         view.frame = _baseview.frame;
        view.alpha = 0;
        [self.view addSubview:view];
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 1.0;
        } completion:^(BOOL finished){
            if(finished && completion)
            {
                completion();
            }
        }];
    });
}

- (void)closeView:(UIView *)view completion:(void(^)())completion
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 0.0;
        } completion:^(BOOL finished){
            [view removeFromSuperview];
            if(completion)
            {
                completion();
            }
        }];
    });
}

- (void)openHomePage
{
    DDLogFunction();
    MainViewController *mainPage = (MainViewController *)[self parentViewController];
    [mainPage pushToHomeView];
}

- (void)reloadDeviceMangementView
{
    DDLogFunction();
    [NotificationCenter postNotificationName:AirDeviceRemovedNotification object:nil];
    DeviceManagementViewController *mainPage = (DeviceManagementViewController *)[self parentViewController];
    [mainPage reloadTableView1];
}

#pragma mark - Task 

- (NSString *)errorSubmitDate
{
    DDLogFunction();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *date = [formatter stringFromDate:[NSDate date]];
    return date;
}

- (void)submitAppError:(NSString *)body
{
    DDLogFunction();
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_SUBMIT_ERRORCODE(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
    {
        DDLogCVerbose(@"--->submitAppError %@",[MainDelegate parseJsonData:data]);
    }];
}

- (void)easyLink
{
    DDLogFunction();
    bindTimeCount++;
    
    self.wifiPwd = ssidPwdTxf.text;
    isEasyLinking = YES;
    
    uSDKDeviceConfigInfo *info = [[uSDKDeviceConfigInfo alloc] init];
    info.apSsid = wifiSsid;
    info.apPassword = wifiPwd;
    
    checkTimeCount = 20;
    
    [self checkDeployState:info];
    //[self performSelector:@selector(checkDeployState) withObject:nil afterDelay:1];
}

- (NSArray *)filteAirBoxDevice:(NSArray *)devList
{
    DDLogFunction();
    NSMutableArray *array = [NSMutableArray arrayWithArray:devList];
    for (int i = 0; i < array.count; i++)
    {
        uSDKDevice *device = array[i];
        if(!([device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER] || [device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER_V15]))
        {
            [array removeObject:device];
        }
    }
    return array;
}

- (void)stopEasyLink
{
    DDLogFunction();
    isEasyLinking = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)checkEasyLink
{
    DDLogFunction();
    if(checkTimeCount == 0)
    {
        NSDictionary *params = @{@"deviceId":@"",@"userId":MainDelegate.loginedInfo.userID,@"name":@""};
        NSDictionary *body = @{@"sequenceId":[MainDelegate sequenceID],
                               @"errorCode":@"",
                               @"errorInfo":@"Not found new device",
                               @"name":@"",
                               @"type":@"other",
                               @"errorTime":[self errorSubmitDate],
                               @"errorLevel":@"2",
                               @"clientType":[UIDevice currentDevice].systemVersion,
                               @"params":params
                               };
        NSString *bodyString = [MainDelegate createJsonString:body];
        [self submitAppError:bodyString];
        
        [self finishedCheck];
        return;
    }
    
    NSArray *devList = [[uSDKDeviceManager getSingleInstance] getDeviceList:SMART_HOME];
    NSArray *devAirBox = [self filteAirBoxDevice:devList];
    NSMutableArray *arrDevice = [NSMutableArray arrayWithArray:devAirBox];
    DDLogCVerbose(@"test test test %@ %@",[devList description],[devAirBox description]);
    
    for (int i = 0; i < devAirBox.count; i++)
    {
        uSDKDevice *device = devAirBox[i];
        if(device.status == STATUS_OFFLINE || device.status == STATUS_UNAVAILABLE)
        {
            [arrDevice removeObject:device];
            continue;
        }
        
        for (int j = 0; j < MainDelegate.loginedInfo.arrUserBindedDevice.count; j++)
        {
            AirDevice *airDev = MainDelegate.loginedInfo.arrUserBindedDevice[j];
            if([device.mac isEqualToString:airDev.mac])
            {
                [arrDevice removeObject:device];
                break;
            }
        }
    }
    
    if(arrDevice.count > 0)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        DDLogCVerbose(@"%@",[arrDevice description]);
        [self prepareBindDevice:arrDevice];
        return;
    }
    checkTimeCount--;
    [self performSelector:@selector(checkEasyLink) withObject:nil afterDelay:2];
}

- (void)checkDeployState:(uSDKDeviceConfigInfo *)info
{
    DDLogFunction();
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isNetworkWifi = [MainDelegate isCurrentNetworkWiFi];
        if (isNetworkWifi) {
     lblDeployState.text = NSLocalizedString(@"已连接至WIFI",@"AirDeviceBindViewController.m");
        }
        else
        {
            
        }
     
    });
     
     */
    
    //chick wifi network enable
    BOOL isNetworkWifi = [MainDelegate isCurrentNetworkWiFi];
    dispatch_async(dispatch_get_main_queue(), ^{
        lblDeployState.text = NSLocalizedString(@"检测WiFi中...",@"AirDeviceBindViewController.m");
    });
    if (!isNetworkWifi)
    {
        if((bindTimeCount % 2) == kFirstBindError)
        {
            [self openView:firstBindFailedView completion:^{
                [self closeView:bindProgressView completion:nil];
            }];
        }
        else
        {
            [self openView:secondBindFailedView completion:^{
                [self closeView:bindProgressView completion:nil];
            }];
        }

        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        lblDeployState.text = NSLocalizedString(@"检测网络中...",@"AirDeviceBindViewController.m");
    });
    
//    if(![MainDelegate isCurrentNetworkEnable])
//    {
//        [self openView:step5];
//        return;
//    }
    
    dispatch_async(dispatch_queue_create("check network", NULL), ^{
        [MainDelegate isCurrentNetworkEnable:^(BOOL enable){
            if(enable)
            {
                dispatch_async(dispatch_queue_create("easylink", NULL), ^{
                    uSDKErrorConst result = [[SDKRequestManager sharedInstance] easyLinkWithDeviceInfo:info];
                    if(result != RET_USDK_OK)
                    {
                        NSDictionary *params = @{@"deviceId":@"",@"userId":MainDelegate.loginedInfo.userID,@"name":@""};
                        NSDictionary *body = @{@"sequenceId":[MainDelegate sequenceID],
                                               @"errorCode":[NSString stringWithFormat:@"%d",result],
                                               @"errorInfo":@"device config failed",
                                               @"name":@"uSDKDeviceManager-->setDeviceConfigInfo",
                                               @"type":@"sdk",
                                               @"errorTime":[self errorSubmitDate],
                                               @"errorLevel":@"2",
                                               @"clientType":[UIDevice currentDevice].systemVersion,
                                               @"params":params
                                               };
                        NSString *bodyString = [MainDelegate createJsonString:body];
                        [self submitAppError:bodyString];
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        lblDeployState.text = NSLocalizedString(@"搜索设备",@"AirDeviceBindViewController.m");
                    });
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        lblDeployState.text = NSLocalizedString(@"绑定设备",@"AirDeviceBindViewController.m");
                        [self doCheckEasyLink];
                    });
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if((bindTimeCount % 2) == kFirstBindError)
                    {
                        [self openView:firstBindFailedView completion:^{
                            [self closeView:bindProgressView completion:nil];
                        }];
                    }
                    else
                    {
                        [self openView:secondBindFailedView completion:^{
                            [self closeView:bindProgressView completion:nil];
                        }];
                    }
                    
                });
            }
        }];
    });
    
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([MainDelegate isCurrentNetworkEnable])
        {
     lblDeployState.text = NSLocalizedString(@"网络连接正常",@"AirDeviceBindViewController.m");
        }
        else
        {
            
        }
    });
     */


}

- (void)doCheckEasyLink
{
    //  保存timer，以便下次关闭
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(startCheckEasyLink)
                                                    userInfo:nil
                                                     repeats:YES];
}
- (void)startCheckEasyLink
{
    waitTimeCount ++;
    if(isFinishLocation || waitTimeCount == 20)
    {
        if(_countDownTimer)
        {
            if(_countDownTimer.isValid)
            {
                [_countDownTimer invalidate];
            }
            
            _countDownTimer = nil;
            waitTimeCount = 0;
        }
        
        [self checkEasyLink];
    }
}

- (void)finishedCheck
{
    DDLogFunction();
//    if(MainDelegate.loginedInfo.arrUserBindedDevice.count > 0)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
    //            bindFinishedMessage.text = NSLocalizedString(@"已经绑定当前所有空气盒子",@"AirDeviceBindViewController.m");
//        });
//    }
//    else
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
    //            bindFinishedMessage.text = NSLocalizedString(@"没有搜索到空气盒子",@"AirDeviceBindViewController.m");
//        });
//    }
    
    if((bindTimeCount % 2) == kFirstBindError)
    {
        [self openView:firstBindFailedView completion:^{
            [self closeView:bindProgressView completion:nil];
        }];
    }
    else
    {
        [self openView:secondBindFailedView completion:^{
            [self closeView:bindProgressView completion:nil];
        }];
    }
}

- (void)prepareBindDevice:(NSMutableArray *)deviceList
{
    DDLogFunction();
    if(!isEasyLinking)return;

    countBindedDevice = deviceList.count;
    for (int i = 0; i < deviceList.count; i++)
    {
        NSString *name = NSLocalizedString(@"我家的盒子1",@"AirDeviceBindViewController1.m");//ybyao
        if([airBoxNameList containsObject:name])
        {
            [self verifyNameAtIndex:i+1];
            name = airBoxName;
        }
        else
        {
            [airBoxNameList addObject:name];
        }
        uSDKDevice *device = deviceList[i];
        if(!device)
        {
            device = [[uSDKDevice alloc] init];
            device.mac = @"";
        }
        NSDictionary *dictionary = @{@"device" : device, @"name" : name};
        NSOperation *operation = [MainDelegate operationWithTarget:self
                                                          selector:@selector(bindAirDeviceToLoginUser:)
                                                            object:dictionary];
        [queue addOperation:operation];
    }
}

- (void)verifyNameAtIndex:(int)index
{
    DDLogFunction();
    if(!isEasyLinking)return;
    int i = index;
    //----------------ybyao-----------------
    NSMutableString *airboxMutable = [NSMutableString stringWithString:NSLocalizedString(@"我家的盒子",@"AirDeviceBindViewController1.m")] ;
    NSString *number = [NSString stringWithFormat:@"%d",i];
    [airboxMutable appendString:number];
    NSString *BoxName = [NSString stringWithString:airboxMutable];
     self.airBoxName = BoxName;
    //-------------------ybyao--------------------
//    self.airBoxName = [NSString stringWithFormat:@"空气盒子%d",i];
    if([airBoxNameList containsObject:airBoxName])
    {
        i++;
        [self verifyNameAtIndex:i];
    }
    else
    {
        [airBoxNameList addObject:airBoxName];
    }
}

- (void)bindAirDeviceToLoginUser:(NSDictionary *)info;
{
    DDLogFunction();
    if(!isEasyLinking)return;
    
    uSDKDevice *device = info[@"device"];
    
    DDLogCVerbose(@"%d",device.attributeDict.count);
    NSString *name = info[@"name"];
    NSString *platformver = device.smartLinkPlatform != nil ? device.smartLinkPlatform : @"";
    NSString *hardwarever = device.smartLinkHardwareVersion != nil ? device.smartLinkHardwareVersion : @"";
    NSString *versiondevfile = device.smartLinkDevfileVersion != nil ? device.smartLinkDevfileVersion : @"";
    NSString *versionmyself = device.smartLinkSoftwareVersion != nil ? device.smartLinkSoftwareVersion : @"";
    NSString *eprotocolver = device.eProtocolVer != nil ? device.eProtocolVer : @"";
    NSString *wifitype = device.typeIdentifier != nil ? device.typeIdentifier : @"";
    NSDictionary *city = [CityDataHelper selectedCity];
    NSString *provinceID = @"";
    NSString *cityID = @"";
    if(_cityID.length >0)
    {
        cityID = _cityID;
    }
    else
    {
        provinceID = city[kProvinceID] != nil ? city[kProvinceID] : @"";
        cityID = city[kCityID] != nil ? city[kCityID] : @"";
    }


    NSDictionary *dicDev = @{@"mac":device.mac,
                             @"name":name,
                             @"province":provinceID,
                             @"city":cityID,
                             @"lat":MainDelegate.devicelat ?  MainDelegate.devicelat : @0, // 传入double类型
                             @"lng":MainDelegate.devicelng ?  MainDelegate.devicelng : @0,// 传入double类型
                             @"wifitype":wifitype,
                             @"eprotocolver":eprotocolver,
                             @"platformver":platformver,
                             @"hardwarever":hardwarever,
                             @"versiondevfile":versiondevfile,
                             @"versionmyself":versionmyself};
    NSDictionary *dicBody = @{@"device":dicDev,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_BIND_DEV(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         if(!isEasyLinking)return;
         NSDictionary *result = [MainDelegate parseJsonData:data];
         result = isObject(result) ? result : nil;
         DDLogCVerbose(@"--->绑定盒子到用户名下接口信息%@",result);
         
         if(error || !result || [result[HttpReturnCode] isEqual:[NSNull null]] || [result[HttpReturnCode] intValue] != 0)
         {
             NSString *errorCode = @"";
             if(!error)
             {
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]])
                 {
                     errorCode = result[HttpReturnCode];
                 }
             }
             NSDictionary *params = @{@"deviceId":@"",@"userId":MainDelegate.loginedInfo.userID,@"name":@""};
             NSDictionary *body = @{@"sequenceId":[MainDelegate sequenceID],
                                    @"errorCode":errorCode,
                                    @"errorInfo":@"Bind device failed",
                                    @"name":@"binddevices",
                                    @"type":@"server",
                                    @"errorTime":[self errorSubmitDate],
                                    @"errorLevel":@"2",
                                    @"clientType":[UIDevice currentDevice].systemVersion,
                                    @"params":params
                                    };
             NSString *bodyString = [MainDelegate createJsonString:body];
             [self submitAppError:bodyString];
         }
         DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         countBindedDevice--;
         if(countBindedDevice == 0)
         {
             [self reDownloadAirDevice];
         }
     }];
}


- (void)reDownloadAirDevice
{
    DDLogFunction();
    if(!isEasyLinking)return;

    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    [airDeviceManager downloadBindedDeviceWithCompletionHandler:^(NSMutableArray *array,BOOL succeed)
    {
        if(!isEasyLinking)return;

        if(succeed)
        {
            if([array count] > 0)
            {
                NSMutableArray *bindDev = [NSMutableArray arrayWithArray:array];

                for (int i = 0; i < MainDelegate.loginedInfo.arrUserBindedDevice.count; i++)
                {
                    AirDevice *deviceName = MainDelegate.loginedInfo.arrUserBindedDevice[i];
                    AirDevice *deviceTmp = [self getAirDevice:deviceName.mac withArrDevice:bindDev];
                    if(deviceTmp)
                    {
                        [bindDev removeObject:deviceTmp];
                    }
                }
                MainDelegate.loginedInfo.arrUserBindedDevice = array;
                
                _arrBindDev = bindDev;
                
//                MainDelegate.curBindDevice = array[0];//ybyao07
               [MainDelegate resetCurAirDevice];
                
                dispatch_async(dispatch_queue_create("remoteLogin", NULL), ^{
                    [[SDKRequestManager sharedInstance] remoteLogin:bindDev];
                });
                [[SDKRequestManager sharedInstance] registeDeviceNotification:bindDev];
                
                if(_cityName.length > 0)
                {
                    lblLocation.text = _cityName;
                }
                else
                {
                    lblLocation.text = @"未能获取位置信息";
                }
                _curDeviceIndex = 0;
                [self openView:bindSucceedView completion:nil];
            }
            else
            {
                /*
                //bind air box failed
                dispatch_async(dispatch_get_main_queue(), ^{
                 bindFinishedMessage.text = NSLocalizedString(@"请检测路由器密码是否正确",@"AirDeviceBindViewController.m");
                });
                 */
                
                if((bindTimeCount % 2) == kFirstBindError)
                {
                    [self openView:firstBindFailedView completion:^{
                        [self closeView:bindProgressView completion:nil];
                    }];
                }
                else
                {
                    [self openView:secondBindFailedView completion:^{
                        [self closeView:bindProgressView completion:nil];
                    }];
                }
            }
        }
        else
        {
            /*
            //get air box list failed
            dispatch_async(dispatch_get_main_queue(), ^{
             bindFinishedMessage.text = NSLocalizedString(@"请检测路由器密码是否正确",@"AirDeviceBindViewController.m");
            });
             */
            if((bindTimeCount % 2) == kFirstBindError)
            {
                [self openView:firstBindFailedView completion:^{
                    [self closeView:bindProgressView completion:nil];
                }];
            }
            else
            {
                [self openView:secondBindFailedView completion:^{
                    [self closeView:bindProgressView completion:nil];
                }];
            }
        }
    }];
}

- (AirDevice*) getAirDevice:(NSString *)deviceName withArrDevice:(NSArray *)arrDevice
{
    for (int i = 0; i < [arrDevice count]; i++)
    {
        AirDevice *device = arrDevice[i];
        if([deviceName isEqualToString:device.mac])
        {
            return device;
        }
    }
    return nil;
}

#pragma mark - Touch events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([ssidPwdTxf isFirstResponder])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ssidPwdTxf resignFirstResponder];
        });
    }
    
    else if([txtName isFirstResponder])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [txtName resignFirstResponder];
        });
    }
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField resignFirstResponder];
    });
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     if ([textField.text length] >= 16 && range.length == 0  && ![string isEqualToString:@""]) {
     [AlertBox showWithMessage:@"设备名称不能超过16个字符"];
     [self.view endEditing:YES];
     return NO;
     }
     */
    return YES;
}
#pragma mark - Touch events

@end
