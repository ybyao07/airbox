//
//  MainViewController.m
//  AirManager
//

#import "MainViewController.h"
#import "RegisterViewController.h"
//#import "HomeViewController.h"
#import "AirDevice.h"
#import "AirDeviceBindViewController.h"
#import "UIDevice+Resolutions.h"
#import "RetrievePasswordWebViewController.h"
#import "AirBoxListViewController.h"
#import "Reachability.h"
#import "WeatherManager.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "CitySelectionViewController.h"
#import "AccountActivationViewController.h"
#import "OnlyIdentifier.h"
#import "AirDeivceManageViewController.h"
#import "WeatherMainViewController.h"
#import "CityViewController.h"
#import "PushRequest.h"

#import "CustomModelViewController.h"

@interface MainViewController (){
    IBOutlet UITextField *txfUserName;
    IBOutlet UITextField *txfPassWord;
    IBOutlet UIButton *autoLoginBtn;
    IBOutlet UILabel *autoLoginLbl;
    IBOutlet UIButton *weatherButton;
}

- (IBAction)login:(id)sender;
- (IBAction)accountRegister:(id)sender;
- (IBAction)isAutoLogin:(id)sender;
- (IBAction)forgetPassWord:(id)sender;

@property (nonatomic, strong) AirBoxListViewController *airBoxListVC;


@end



@implementation MainViewController

- (void)dealloc
{
    [NotificationCenter removeObserver:self];
    DDLogFunction();
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    [NotificationCenter addObserver:self
                           selector:@selector(disMissModalView)
                               name:AllAirDeviceRemovedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(disMissModalViewByDeleted)
                               name:AllAirDeviceRemovedNotificationByDeleted
                             object:nil];

    NSDictionary *loginInfo = [UserDefault objectForKey:AutoLoginInfo];
    if([loginInfo[IsAutoLogin] boolValue])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            txfUserName.text = loginInfo[LoginUserName];
            txfPassWord.text = loginInfo[LoginPassWord];
            autoLoginBtn.selected = [loginInfo[IsAutoLogin] boolValue];
            
            [self openDownloadAirBoxListPage:YES];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            txfUserName.text = loginInfo[LoginUserName];
            autoLoginBtn.selected = [loginInfo[IsAutoLogin] boolValue];
        });
    }
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(![MainDelegate isNetworkAvailableWiFiOr3G]) return;//ybyao07-20111111
    [MainDelegate testNetworkAvailable];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Open New Page
- (void)disMissModalView
{
    [MainDelegate.loginedInfo.arrUserBindedDevice removeAllObjects];
    [[WeatherManager sharedInstance] stopAutoReload];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(!autoLoginBtn.selected)
    {
        txfPassWord.text = @"";
    }
}

- (void)disMissModalViewByDeleted
{
    [MainDelegate.loginedInfo.arrUserBindedDevice removeAllObjects];
    [[WeatherManager sharedInstance] stopAutoReload];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(!autoLoginBtn.selected)
    {
        txfPassWord.text = @"";
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openDownloadAirBoxListPage:YES];
        });
    }
}

- (void)pushToHomeView
{
    DDLogFunction();
 
    if(![MainDelegate isNetworkAvailableWiFiOr3G]) return;//ybyao07
    
    MainDelegate.isCustomer = NO;
    NSString *newName = ([UIDevice isRunningOn4Inch]?@"AirDeivceManageViewController":@"AirDeivceManageViewController_35");
    AirDeivceManageViewController *homeView = [[AirDeivceManageViewController alloc] initWithNibName:newName bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeView];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)openDownloadAirBoxListPage:(BOOL)isAutoLogin
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailableWiFiOr3G]) return;//ybyao07
    AirBoxListViewController *airBox = [[AirBoxListViewController alloc] initWithNibName:@"AirBoxListViewController" bundle:nil];
    
    [self setAirBoxListVC:airBox];
    [airBox setParentVC:self];
    airBox.isFromAutoLogin = isAutoLogin;
    airBox.view.frame = _baseview.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        airBox.view.alpha = 0.0;
        [MainDelegate.window addSubview:airBox.view];
        [UIView animateWithDuration:0.3 animations:^{
            airBox.view.alpha = 1.0;
         }];
    });
}

- (void)openAirBoxBindPage
{
    DDLogFunction();
    if([UserDefault objectForKey:kSelectedCity] == nil)
    {
        CityViewController *vc = [[CityViewController alloc] init];
        vc.citySelectedProtocol =  nil;
        vc.fromDeviceBind = YES;
        [vc setParentVC:self];
        vc.view.frame = self.view.frame;
        dispatch_async(dispatch_get_main_queue(), ^{
            vc.view.alpha = 0.0;
            [MainDelegate.window addSubview:vc.view];
            [UIView animateWithDuration:0.3 animations:^{
                vc.view.alpha = 1.0;
            }];
            [self addChildViewController:vc];
        });
    }
    else
    {
        AirDeviceBindViewController *deviceBind = [[AirDeviceBindViewController alloc]initWithNibName:@"AirDeviceBindViewController" bundle:nil];
        deviceBind.view.frame = self.view.frame;
        [deviceBind setParentVC:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            deviceBind.view.alpha = 0.0;
            [MainDelegate.window addSubview:deviceBind.view];
            [UIView animateWithDuration:0.3 animations:^{
                deviceBind.view.alpha = 1.0;
             }];
            [self addChildViewController:deviceBind];
        });
    }
}

- (void)openActivatePage
{
    DDLogFunction();
    AccountActivationViewController *activation = [[AccountActivationViewController alloc] initWithNibName:@"AccountActivationViewController" bundle:nil];
    activation.phoneNumber = txfUserName.text;
    activation.passWord = txfPassWord.text;
    activation.isOpenFromRegiste = NO;
    [activation setParentVC:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        activation.view.alpha = 0.0;
        [MainDelegate.window addSubview:activation.view];
        [UIView animateWithDuration:0.3 animations:^{
            activation.view.alpha = 1.0;
        }];
        [self addChildViewController:activation];
    });
}

- (void)autoLogin:(NSString *)userName andPassword:(NSString *)password
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        txfUserName.text = userName;
        txfPassWord.text = password;
        [self storeLoginInfo];
        //[self startLogin];
        [self openDownloadAirBoxListPage:YES];
    });
}

#pragma mark - Button Event

- (IBAction)login:(id)sender
{
    DDLogFunction();
    if ([txfUserName.text length] == 0)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"帐号不能为空",@"MainViewController.m")];
        return;
    }
    else if([txfPassWord.text length] == 0)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"密码不能为空",@"MainViewController.m")];
        return;
    }
    else if(![MainDelegate isMobileNumber:txfUserName.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入正确的手机号码格式",@"MainViewController.m")];
        return;
    }
    
    if ([txfPassWord.text length]>20 || [txfPassWord.text length]<6)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入正确的密码格式,长度6-20位的数字或字母",@"MainViewController.m")];
        return;
    }
    
    NSString *regex = @"^[A-Za-z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:txfPassWord.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"密码由字母或数字组成，不能包含其他符号",@"MainViewController.m")];
        return;
    }
    
    [self hiddenKeyBoard];
    
    if([MainDelegate isNetworkAvailableWiFiOr3G])
    {
        [MainDelegate showProgressHubInView:self.view];
        [self startLogin:[NSNumber numberWithInt:0]];
    }
    
    [MainDelegate testNetworkAvailable];
}

- (IBAction)accountRegister:(id)sender
{
    DDLogFunction();
    [self hiddenKeyBoard];
    RegisterViewController *userRegister = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [userRegister setParentVC:self];
    
    userRegister.view.frame = self.view.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        userRegister.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            userRegister.view.alpha = 1.0;
            [MainDelegate.window addSubview:userRegister.view];
            [self addChildViewController:userRegister];
        }];
    });
}

- (IBAction)isAutoLogin:(id)sender
{
    DDLogFunction();
    autoLoginBtn.selected = !autoLoginBtn.selected;
    
    NSDictionary *dicAutoLoginInfo = [UserDefault objectForKey:AutoLoginInfo];
    
    if(dicAutoLoginInfo!= nil)
    {
        if(!autoLoginBtn.selected)
        {
            NSString *userName = [dicAutoLoginInfo objectForKey:LoginUserName];
            NSString *passWord = [dicAutoLoginInfo objectForKey:LoginPassWord];
            NSNumber *isAuto = [NSNumber numberWithBool:autoLoginBtn.selected] ;
            
            NSDictionary *dicAutoLoginInfoTmp = @{IsAutoLogin:isAuto,
                                               LoginUserName:userName,
                                               LoginPassWord:passWord};
            [UserDefault setObject:dicAutoLoginInfoTmp forKey:AutoLoginInfo];
        }
        [UserDefault synchronize];
    }
}

- (IBAction)forgetPassWord:(id)sender
{
    DDLogFunction();
    [self hiddenKeyBoard];
    //ybyao07-20111111
    if(![MainDelegate isNetworkAvailableWiFiOr3G]) return;//增加外网判断
    
    RetrievePasswordWebViewController *vc = [[RetrievePasswordWebViewController alloc] initWithNibName:@"RetrievePasswordWebViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goWonderWeatherVC:(id)sender
{
    DDLogFunction();
    [MainDelegate testNetworkAvailable];
    MainDelegate.isCustomer = YES;
    NSString *newName = ([UIDevice isRunningOn4Inch]?@"AirDeivceManageViewController":@"AirDeivceManageViewController_35");
    AirDeivceManageViewController *homeView = [[AirDeivceManageViewController alloc] initWithNibName:newName bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:homeView];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}
#pragma mark - Login Process
- (void)clearLoginInfo
{
    // 删除内存中的用户名密码，用来表示未登陆状态
    MainDelegate.loginedInfo.loginID = @"";
    MainDelegate.loginedInfo.loginPwd = @"";
    MainDelegate.loginedInfo.userID = @"";
}
- (void)startLogin:(NSNumber *)requestCountNum
{
    DDLogFunction();
    NSInteger requestCount = [requestCountNum integerValue];
    
    NSDictionary *dicBody = @{@"loginId":txfUserName.text,
                              @"password":txfPassWord.text,
                              @"accType":[NSNumber numberWithInt:0],
                              @"sequenceId":[MainDelegate sequenceID],
                              @"loginType":[NSNumber numberWithInt:1]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_LOGIN
                                                     method:HTTP_POST
                                                       body:body];
    NSString *cacheKey = [NSString stringWithFormat:@"%@|%@|%@", txfUserName.text,txfPassWord.text,SERVER_LOGIN];
    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue currentQueue]
                                         cacheKey:cacheKey
                                completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
    {
        if(!response)
        {
            if(requestCount < 5)
            {
                [self performSelector:@selector(startLogin:) withObject:[NSNumber numberWithInt:(requestCount + 1)] afterDelay:2];
                
                return;
            }
        }
        NSString *errorInfo = NSLocalizedString(@"网络异常,请稍后再试",@"MainViewController.m");
        if(error)
        {
            [MainDelegate hiddenProgressHubInView:self.view];
            [AlertBox showWithMessage:errorInfo];
        }
        else
        {
            DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSDictionary *result = [MainDelegate parseJsonData:data];
            result = isObject(result) ? result : nil;
            DDLogCVerbose(@"--->startLogin response: %@",result);
            
            if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
            {
                [[DataController getInstance] addCache:data andCacheKey:cacheKey andCacheNSURLResponse:response];
                
                [self storeLoginInfo];
                
                NSString *token = isObject(result[@"accessToken"]) ? result[@"accessToken"] : @"";
                if(!token)
                {
                    NSDictionary *header = [(NSHTTPURLResponse *)response allHeaderFields];
                    header = isObject(header) ? header : [NSDictionary dictionary];
                    NSString *accessToken = isObject(header[@"accessToken"]) ? header[@"accessToken"] : @"";
                    NSArray *arrToken = [accessToken componentsSeparatedByString:@","];
                    token = [[arrToken lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
                }
                
                MainDelegate.loginedInfo.loginID = txfUserName.text;
                MainDelegate.loginedInfo.loginPwd = txfPassWord.text;
                MainDelegate.loginedInfo.accessToken = token;
                MainDelegate.loginedInfo.userID = isObject(result[@"userId"])?result[@"userId"]:@"";
                
                
#warning 袁杰测试需要删除
//                [PushRequest startHandleMessage:@{@"aps":@{@"msg" :@"659790"}}];
                
                [self verifyIsActive:0];
                //[self accessServerInfo];
            }
            else
            {
                [MainDelegate hiddenProgressHubInView:self.view];
                if(result && ![result[HttpReturnCode] isEqual:[NSNull null]])
                {
                    if([result[HttpReturnCode] intValue] == InvalidTokenCode || [result[HttpReturnCode] intValue] == InvalidTokenCode2)
                    {
                        if(requestCount < 3)
                        {
                            [MainDelegate reDownloadToken:^(BOOL succeed){
                                [self startLogin:[NSNumber numberWithInt:(requestCount + 1)]];
                            }];
                            return;
                        }
                    }
                }
                if(result)
                {
                    //errorInfo = [MainDelegate erroInfoWithErrorCode:result[HttpReturnCode]];

//                    errorInfo = [NSString stringWithFormat:@"登录失败:%@",result[HttpReturnCode]];
                      errorInfo = [NSString stringWithFormat:@"登录失败"];//ybyao07
                    
                    if([result[HttpReturnCode] isEqualToString:@"22108"])
                    {
                        errorInfo = NSLocalizedString(@"用户名或密码错误", @"MainViewController.m") ;
                    }
                    else if ([result[HttpReturnCode] isEqualToString:@"22820"])
                    {
                        // 如果报22820，尝试离线登陆
                        BOOL isCached = [[DataController getInstance] findCacheWithKey:cacheKey];

                        if (isCached)
                        {
                            NSURLResponse *cacheResponse = [[DataController getInstance] loadCacheResponseWithKey:cacheKey];
                            
                            NSData *dataCache = [[DataController getInstance] loadCacheDataWithKey:cacheKey];
                            DDLogCVerbose(@"%@",[[NSString alloc] initWithData:dataCache encoding:NSUTF8StringEncoding]);
                            NSDictionary *result = [MainDelegate parseJsonData:dataCache];
                            result = isObject(result) ? result : nil;
                            DDLogCVerbose(@"Login response: %@",result);
                            
                            if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                            {
                                [self storeLoginInfo];
                                
                                NSString *token = isObject(result[@"accessToken"]) ? result[@"accessToken"] : @"";
                                if(!token)
                                {
                                    NSDictionary *header = [(NSHTTPURLResponse *)cacheResponse allHeaderFields];
                                    header = isObject(header) ? header : [NSDictionary dictionary];
                                    NSString *accessToken = isObject(header[@"accessToken"]) ? header[@"accessToken"] : @"";
                                    NSArray *arrToken = [accessToken componentsSeparatedByString:@","];
                                    token = [[arrToken lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
                                }
                                
                                MainDelegate.loginedInfo.loginID = txfUserName.text;
                                MainDelegate.loginedInfo.loginPwd = txfPassWord.text;
                                MainDelegate.loginedInfo.accessToken = token;
                                MainDelegate.loginedInfo.userID = isObject(result[@"userId"])?result[@"userId"]:@"";
                                
                                [self verifyIsActive:0];
                                //[self accessServerInfo];
                            }
                            errorInfo = nil;
                        }
                        else
                        {
                            errorInfo =NSLocalizedString( @"用户名或密码错误", @"MainViewController.m") ;
                        }
                    }
                }
                if(errorInfo)
                {
                    [AlertBox showWithMessage:errorInfo];
                }
            }
        }
    }];
}

- (void)verifyIsActive:(NSInteger)requestCount
{
    DDLogFunction();
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_IS_ACTIVE(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_IS_ACTIVE(MainDelegate.loginedInfo.loginID)];

    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue currentQueue]
                                         cacheKey:cacheKey
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = NSLocalizedString(@"登录失败",@"MainViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->verifyIsActive接口信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 if([isObject(result[@"activated"])?result[@"activated"]:@"0" boolValue])
                 {
                     [[DataController getInstance] addCache:data andCacheKey:cacheKey];
                     
                     [self accessServerInfo];
                 }
                 else
                 {
                     [MainDelegate hiddenProgressHubInView:self.view];
                     /*
                     AccountActivationViewController *activation = [[AccountActivationViewController alloc] initWithNibName:@"AccountActivationViewController" bundle:nil];
                     activation.phoneNumber = MainDelegate.loginedInfo.loginID;
                     activation.isOpenFromRegiste = NO;
                     [self.navigationController pushViewController:activation animated:YES];
                      */
                     [self openActivatePage];
                 }
                 
                 NSData *token = [UserDefault objectForKey:DeviceToken];
                 if (token)
                 {
                     [self sendTokenToServerWithToken:token];
                 }
             }
             else
             {
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]])
                 {
                     if([result[HttpReturnCode] intValue] == InvalidTokenCode || [result[HttpReturnCode] intValue] == InvalidTokenCode2)
                     {
                         if(requestCount < 3)
                         {
                             [MainDelegate reDownloadToken:^(BOOL succeed){
                                 [self verifyIsActive:requestCount + 1];
                             }];
                             return;
                         }
                     }
                 }
                 
                 [MainDelegate hiddenProgressHubInView:self.view];
                 [AlertBox showWithMessage:errorInfo];
             }
         }
     }];
}

- (void)accessServerInfo
{
    DDLogFunction();
    NSDictionary *dicBody = @{@"id":MainDelegate.loginedInfo.userID,
                              @"ip":@"192.168.0.10"};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_PMS(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];

    NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_PMS(MainDelegate.loginedInfo.loginID)];
    [NSURLConnection sendAsynchronousRequestCache:request
                                       queue:[NSOperationQueue currentQueue]
                                    cacheKey:cacheKey
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         if(error == nil)
         {
             DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->accessServerInfo response: %@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [[DataController getInstance] addCache:data andCacheKey:cacheKey];                 NSDictionary *adapter = isObject(result[@"appAdapter"])?result[@"appAdapter"]:[NSDictionary dictionary];
                 if(adapter.count > 0)
                 {
                     NSString *url = isObject(adapter[@"uri"])?adapter[@"uri"]:@"";
                     if(url.length > 0)
                     {
                         [self parseAccessServer:url];
                     }
                 }
             }
         }
         [MainDelegate hiddenProgressHubInView:self.view];
         [self openDownloadAirBoxListPage:NO];
     }];
}

- (void)sendTokenToServerWithToken:(NSData *)token
{
    DDLogFunction();
    NSString *tokenString = [NSString stringWithFormat:@"%@",token];
    tokenString = [tokenString substringWithRange:NSMakeRange(1, [tokenString length] -2)];
    NSDictionary *dictBody = @{@"loginId" : MainDelegate.loginedInfo.loginID,
                               @"appClient" : [OnlyIdentifier identifier],
                               @"deviceToken" : tokenString,
                               @"sequenceId" : [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dictBody];

    NSString *cacheKey = [NSString stringWithFormat:@"%@|%@",MainDelegate.loginedInfo.loginID,SERVER_SEND_TOKEN];
    
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_SEND_TOKEN method:HTTP_POST body:body];
    [NSURLConnection sendAsynchronousRequestCache:request queue:[NSOperationQueue currentQueue] cacheKey:cacheKey completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
        [[DataController getInstance] addCache:data andCacheKey:cacheKey];
        
         DDLogCVerbose(@"--->sendToken Response :%@ ",[MainDelegate parseJsonData:data]);
     }];
}


- (void)parseAccessServer:(NSString *)adress
{
    DDLogFunction();
    NSString *newAdress = [adress substringFromIndex:7];
    NSArray *arrAdress = [newAdress componentsSeparatedByString:@":"];
    MainDelegate.loginedInfo.accessIP = arrAdress[0];
    MainDelegate.loginedInfo.accessPort = arrAdress[1];
}

- (void)storeLoginInfo
{
    DDLogFunction();
    NSDictionary *dicLoginInfo = @{IsAutoLogin:[NSNumber numberWithBool:autoLoginBtn.selected],
                                   LoginUserName:txfUserName.text,
                                   LoginPassWord:txfPassWord.text};
    [UserDefault setObject:dicLoginInfo forKey:AutoLoginInfo];
    [UserDefault synchronize];
}

- (void)hiddenKeyBoard
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        if([txfUserName isFirstResponder])
        {
            [txfUserName resignFirstResponder];
        }
        
        if([txfPassWord isFirstResponder])
        {
            [txfPassWord resignFirstResponder];
        }
    });
}

#pragma mark-
#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DDLogFunction();
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    DDLogFunction();
    /*
    if (range.location > 0 && range.length == 1 && string.length == 0)
    {
        textField.text = [textField.text substringToIndex:textField.text.length - 1];
        return NO;
    }
    return YES;
     */
    return YES;
}

#pragma mark - Touch events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   
    
    [self hiddenKeyBoard];
    
    [super touchesEnded:touches withEvent:event];
}

@end
