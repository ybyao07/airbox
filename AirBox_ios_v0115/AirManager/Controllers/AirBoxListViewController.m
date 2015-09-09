//
//  AirBoxListViewController.m
//  AirManager
//

#import "AirBoxListViewController.h"
#import "AirDeviceManager.h"
#import "MainViewController.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "SDKRequestManager.h"
#import "AlertBox.h"
#import "AccountActivationViewController.h"
#import "OnlyIdentifier.h"

@interface AirBoxListViewController ()
{
    IBOutlet UIView *downloadFailedView;
    IBOutlet UIActivityIndicatorView *activeView;
    IBOutlet UILabel *message;
}

/**
 *  after request air box list failed,try to download it again
 **/
- (IBAction)reTryDowloadAirBox:(id)sender;

/**
 *  after request air box list failed,click this button back to login page
 **/
- (IBAction)cancelDowloadAirBox:(id)sender;

@end

@implementation AirBoxListViewController

@synthesize isFromAutoLogin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    DDLogFunction();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    [self startWaitAnimate];
    
    if(isFromAutoLogin)
    {
        [self loginInAirBoxList:[NSNumber numberWithInt:0]];
    }
    else
    {
        [self downloadAirBox];
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
    }
    
    _baseview.frame = CGRectMake(0, 0, 320, VIEWHEIGHT);
    _baseview.backgroundColor  = [UIColor clearColor];
    [self.view addSubview:_baseview];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)startWaitAnimate
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!activeView.isAnimating)
        {
            [activeView startAnimating];
        }
    });
}

- (void)loginInAirBoxList:(NSNumber *)requestCountNum
{
    DDLogFunction();
    NSInteger requestCount = [requestCountNum integerValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        message.text = NSLocalizedString(@"正在登录",@"AirBoxListViewController.m");
    });
    NSDictionary *loginInfo = [UserDefault objectForKey:AutoLoginInfo];
    NSDictionary *dicBody = @{@"loginId":loginInfo[LoginUserName],
                              @"password":loginInfo[LoginPassWord],
                              @"accType":[NSNumber numberWithInt:0],
                              @"sequenceId":[MainDelegate sequenceID],
                              @"loginType":[NSNumber numberWithInt:1]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@|%@|%@", loginInfo[LoginUserName],loginInfo[LoginPassWord],SERVER_LOGIN];
    
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_LOGIN
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue currentQueue]
                                         cacheKey:cacheKey
                                completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         if(!response)
         {
             if(requestCount < 5)
             {
                 [self performSelector:@selector(loginInAirBoxList:) withObject:[NSNumber numberWithInt:(requestCount + 1)] afterDelay:2];
                 
                 return;
             }
         }
         
         NSString *errorInfo = NSLocalizedString(@"网络异常,请稍后再试",@"AirBoxListViewController.m");
         if(error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 message.text = NSLocalizedString(@"登录失败",@"AirBoxListViewController.m");
             });
             [AlertBox showWithMessage:errorInfo delegate:(id)self showCancel:NO];
         }
         else
         {
             DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"---> loginInAirBoxList response: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [[DataController getInstance] addCache:data andCacheKey:cacheKey andCacheNSURLResponse:response];
                 
                 NSString *token = isObject(result[@"accessToken"]) ? result[@"accessToken"] : @"";
                 if(!token)
                 {
                     NSDictionary *header = [(NSHTTPURLResponse *)response allHeaderFields];
                     header = isObject(header) ? header : [NSDictionary dictionary];
                     NSString *accessToken = isObject(header[@"accessToken"]) ? header[@"accessToken"] : @"";
                     NSArray *arrToken = [accessToken componentsSeparatedByString:@","];
                     token = [[arrToken lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 }
                 
                 MainDelegate.loginedInfo.loginID = loginInfo[LoginUserName];
                 MainDelegate.loginedInfo.loginPwd = loginInfo[LoginPassWord];
                 MainDelegate.loginedInfo.accessToken = token;
                 MainDelegate.loginedInfo.userID = isObject(result[@"userId"]) ? result[@"userId"] : @"";
                 
                 [self verifyIsActiveInAirBoxList:0];
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
                                 
                                 [self loginInAirBoxList:[NSNumber numberWithInt:(requestCount + 1)]];
                             }];
                             return;
                         }
                     }
                 }

                 if(result)
                 {
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
                                 
                                 NSString *token = isObject(result[@"accessToken"]) ? result[@"accessToken"] : @"";
                                 if(!token)
                                 {
                                     NSDictionary *header = [(NSHTTPURLResponse *)cacheResponse allHeaderFields];
                                     header = isObject(header) ? header : [NSDictionary dictionary];
                                     NSString *accessToken = isObject(header[@"accessToken"]) ? header[@"accessToken"] : @"";
                                     NSArray *arrToken = [accessToken componentsSeparatedByString:@","];
                                     token = [[arrToken lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
                                 }
                                 
                                 MainDelegate.loginedInfo.loginID = loginInfo[LoginUserName];
                                 MainDelegate.loginedInfo.loginPwd = loginInfo[LoginPassWord];
                                 MainDelegate.loginedInfo.accessToken = token;
                                 MainDelegate.loginedInfo.userID = isObject(result[@"userId"]) ? result[@"userId"] : @"";
                                 [self verifyIsActiveInAirBoxList:0];
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
                     [AlertBox showWithMessage:errorInfo delegate:(id)self showCancel:NO];
                 }

             }
          }
     }];
}

- (void)verifyIsActiveInAirBoxList:(NSInteger)requestCount
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        message.text = NSLocalizedString(@"正在验证用户是否激活",@"AirBoxListViewController.m");
    });
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_IS_ACTIVE(MainDelegate.loginedInfo.loginID)];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_IS_ACTIVE(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue currentQueue]
                                         cacheKey:cacheKey
                                completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = NSLocalizedString(@"登录失败",@"AirBoxListViewController.m");
         if(error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 message.text = NSLocalizedString(@"验证失败",@"AirBoxListViewController.m");
             });
             [AlertBox showWithMessage:errorInfo delegate:(id)self showCancel:NO];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"---> verifyIsActiveInAirBoxList response: %@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSString *activate = isObject(result[@"activated"]) ? result[@"activated"] : @"0";
                 if([activate boolValue])
                 {
                     [[DataController getInstance] addCache:data andCacheKey:cacheKey];
                     
                     [self accessServerInfo];
                 }
                 else
                 {
                     MainViewController *mainView = (MainViewController *)[self parentVC];
                     [mainView openActivatePage];
                     [self removeCurrentView];
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
                                 [self verifyIsActiveInAirBoxList:requestCount + 1];
                             }];
                             return;
                         }
                    }
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     message.text = NSLocalizedString(@"验证失败",@"AirBoxListViewController.m");
                 });
                 [AlertBox showWithMessage:errorInfo delegate:(id)self showCancel:NO];
             }
         }
     }];
}

- (void)accessServerInfo
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        message.text = NSLocalizedString(@"正在获取空气盒子列表",@"AirBoxListViewController.m");
    });
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
             DDLogCVerbose(@"---> accessServerInfo response: %@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [[DataController getInstance] addCache:data andCacheKey:cacheKey];
                 
                 NSDictionary *adapter = isObject(result[@"appAdapter"])?result[@"appAdapter"]:[NSDictionary dictionary];
                 NSString *adress = isObject(adapter[@"uri"])?adapter[@"uri"]:@"";
                 if(adress.length > 0)
                 {
                     NSString *newAdress = [adress substringFromIndex:7];
                     NSArray *arrAdress = [newAdress componentsSeparatedByString:@":"];
                     MainDelegate.loginedInfo.accessIP = arrAdress[0];
                     MainDelegate.loginedInfo.accessPort = arrAdress[1];
                 }
             }
         }
         [self downloadAirBox];
     }];
}

- (void)downloadAirBox
{
    DDLogFunction();
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    [airDeviceManager downloadBindedDeviceWithCompletionHandler:^(NSMutableArray *array,BOOL succeed)
    {
        if(succeed)
        {
            if([array count] > 0)
            {
                MainDelegate.loginedInfo.arrUserBindedDevice = array;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self removeCurrentView];
                    [self openHomePage];
                });
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self removeCurrentView];
                    [self openBindAirBoxPage];
                });
            }
        }
        else
        {
            downloadFailedView.alpha = 0.0;
            downloadFailedView.frame = _baseview.frame;
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^
                 {
                     downloadFailedView.alpha = 1.0;
                    [self.view addSubview:downloadFailedView];
                 }];
            });
            [activeView stopAnimating];
        }
    }];
}

- (void)openHomePage
{
    DDLogFunction();
    [[SDKRequestManager sharedInstance] registeDeviceNotification:MainDelegate.loginedInfo.arrUserBindedDevice];
    MainViewController *mainPage = (MainViewController *)[self parentVC];
    [mainPage pushToHomeView];
    dispatch_async(dispatch_queue_create("remoteLogin", NULL), ^{
        [[SDKRequestManager sharedInstance] remoteLogin:MainDelegate.loginedInfo.arrUserBindedDevice];
    });
}

- (void)openBindAirBoxPage
{
    DDLogFunction();
    MainViewController *mainPage = (MainViewController *)[self parentVC];
    [mainPage openAirBoxBindPage];
}

- (void)removeCurrentView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            _parentVC = nil;
        }];
    });
}

- (IBAction)reTryDowloadAirBox:(id)sender
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            downloadFailedView.alpha = 0.0;
        } completion:^(BOOL finished){
            [downloadFailedView removeFromSuperview];
            [self startWaitAnimate];
            [self downloadAirBox];
        }];
    });
}

- (IBAction)cancelDowloadAirBox:(id)sender
{
    [(MainViewController *)_parentVC clearLoginInfo];
    [self removeCurrentView];
}

#pragma -
#pragma AlertBoxDelegate
- (void)alertBoxOkButtonOnClicked
{
    [(MainViewController *)_parentVC clearLoginInfo];
    [self removeCurrentView];
}

@end
