//
//  AppDelegate.m
//  AirManager
//
#import "AppDelegate.h"
#import "MainViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DBSDDFileLogger.h"
#import "AirQuality.h"
#import "GuideViewController.h"
#import "AirDevice.h"
#import "Reachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "OnlyIdentifier.h"
#import "UserLoginedInfo.h"
#import "SDKRequestManager.h"
#import "AlertBox.h"
#import "WXApi.h"
#import "CityDataHelper.h"
#import "MobClick.h"
#import "CityManager.h"
#import "CityViewController.h"
#import <Foundation/NSException.h>
#import "UncaughtExceptionHandler.h"
#import "PushRequest.h"
#import "FeedbackViewController.h"

@interface AppDelegate ()

@property (nonatomic, copy) NSString *token;
//@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AppDelegate

@synthesize loginedInfo;
@synthesize curBindDevice;
@synthesize curAirQuality;
@synthesize isShowingAlertBox;
@synthesize allAirBoxStatus;
@synthesize isCustomer;
@synthesize isNetworkConnenct;
@synthesize devicelat;
@synthesize devicelng;

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isNetworkConnenct = YES;
    _isNoFirstTime = NO;
    _dicNSTime = [[NSMutableDictionary alloc] init];
    
    [MobClick startWithAppkey:UMLAPPKEY reportPolicy:SEND_INTERVAL   channelId:@"App Store"];
    [MobClick checkUpdate];
    
    [CityManager sharedManager];

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    // Override point for customization after application launch.
        
    // Setup the logging framework
    // 记录一天的日志
    DBSDDFileLogger *fileLogger = [[DBSDDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
    
    [DDLog addLogger:fileLogger];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        //读取本地城市列表
        [CityViewController readDataCityListString];
    });
    
    //registerWX
    [WXApi registerApp:@"wx8c40a8755448074f"];
    
    //RegisterRemoteNotification
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
   
    
    if([UserDefault objectForKey:AirManagerLastInfo] == nil){
        [UserDefault setObject:[NSArray array] forKey:AirManagerLastInfo];
        [UserDefault synchronize];
    }
    
    if([UserDefault objectForKey:AutoLoginInfo] == nil){
        NSDictionary *dicAutoLoginInfo = @{IsAutoLogin:[NSNumber numberWithBool:NO],
                                           LoginUserName:@"",
                                           LoginPassWord:@""};
        [UserDefault setObject:dicAutoLoginInfo forKey:AutoLoginInfo];
        [UserDefault synchronize];
    }
    
    if([UserDefault objectForKey:IRDeviceIRCodeStore] == nil){
        [UserDefault setObject:[NSMutableDictionary dictionary] forKey:IRDeviceIRCodeStore];
        [UserDefault synchronize];
    }
    
    if([UserDefault objectForKey:DeviceAlarmStore] == nil){
        [UserDefault setObject:[NSDictionary dictionary] forKey:DeviceAlarmStore];
        [UserDefault synchronize];
    }
    
    if([UserDefault objectForKey:DeviceLocation] == nil){
        [UserDefault setObject:[NSDictionary dictionary] forKey:DeviceLocation];
        [UserDefault synchronize];
    }
    NSDictionary* deviceLocation =[UserDefault objectForKey:DeviceLocation];
    if (deviceLocation) {
        NSNumber *tempLat = [deviceLocation objectForKey:DeviceLat];
        NSNumber *tempLng = [deviceLocation objectForKey:DeviceLng];
        devicelat = tempLat;
        devicelng = tempLng;
    }
    
    self.allAirBoxStatus = [[NSMutableDictionary alloc] init];
    self.loginedInfo = [[UserLoginedInfo alloc] init];
    [[SDKRequestManager sharedInstance] startSDK];
    [[SDKRequestManager sharedInstance] initSDKLog];
    [[SDKRequestManager sharedInstance] registeListChangeNotificaion];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    
    // guide
    BOOL hasGuidePresented = [UserDefault boolForKey:kGuidePresented];
    if (!hasGuidePresented)
    {
        [UserDefault setBool:YES forKey:kGuidePresented];
        [UserDefault synchronize];
        
        GuideViewController *vcGuide = [[GuideViewController alloc] init];
        vcGuide.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vcGuide];
        
        navController.navigationBar.translucent = NO;
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
        [self.window makeKeyAndVisible];
    }
    else
    {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
        
        navController.navigationBar.translucent = NO;
        navController.navigationBarHidden = YES;
        self.window.rootViewController = navController;
        [self.window makeKeyAndVisible];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *cleintVersion = [UserDefault stringForKey:kClientVersion];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *saveDate = [formatter stringFromDate:[NSDate date]];
    
    if(!cleintVersion)
    {
        [UserDefault setObject:app_Version forKey:kClientVersion];
        [UserDefault setBool:YES forKey:kIsShowScoreView];
        [UserDefault setBool:YES forKey:kIsShowGuideView];
        [UserDefault setObject:saveDate forKey:kSaveDate];
        [UserDefault synchronize];
    }
    else
    {
        if(![cleintVersion isEqualToString:app_Version])
        {
            [UserDefault setObject:app_Version forKey:kClientVersion];
            [UserDefault setBool:YES forKey:kIsShowScoreView];
            [UserDefault setBool:YES forKey:kIsShowGuideView];
            [UserDefault setObject:saveDate forKey:kSaveDate];
            [UserDefault synchronize];
        }
    }
    
    BOOL isShowScoreView = [UserDefault boolForKey:kIsShowScoreView];
    if(isShowScoreView)
    {
        [self performSelector:@selector(doWithScoreView) withObject:nil afterDelay:10];
    }
    
    [self testNetworkAvailable];
    
    [UncaughtExceptionHandler InstallUncaughtExceptionHandler];
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandlers);
    
    
    //Open the application from push notification
    //  处理推送
    NSDictionary *userInfoPush = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (userInfoPush != nil)
    {
        [self performSelector:@selector(startHandleMessage:) withObject:userInfoPush afterDelay:5];
    }
    
    return YES;
}


- (void)doWithScoreView
{
    if([self isNetworkAvailable])
    {
        BOOL isShowScoreView = [UserDefault boolForKey:kIsShowScoreView];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *saveDateNow = [formatter stringFromDate:[NSDate date]];
        
        NSString *saveDateCache = [UserDefault objectForKey:kSaveDate];
        
        if(isShowScoreView && ![saveDateNow isEqualToString:saveDateCache])
        {
            [self performSelector:@selector(showScoreView:) withObject:nil afterDelay:300];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication* app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^(void)
              {
                  [app endBackgroundTask:bgTask];
                  bgTask = UIBackgroundTaskInvalid;
              }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(_isNoFirstTime)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:ResumeAnimationsEnterForegroundNotification object:nil userInfo:nil];
    }
    else
    {
        _isNoFirstTime = YES;
    }
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:(id)self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return  [WXApi handleOpenURL:url delegate:(id)self];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UserDefault setObject:deviceToken forKey:DeviceToken];
    DDLogCVerbose(@"deviceToken:%@",deviceToken);
    [UserDefault synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DDLogCVerbose(@"Register Remote Notifications error:{%@}",[error localizedDescription]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (userInfo != nil)
    {
        [PushRequest startHandleMessage:userInfo];
    }
}

#pragma mark - Public
-(void)resetCurAirDevice
{
    if(!self.curBindDevice)
    {
        if(self.loginedInfo.arrUserBindedDevice.count > 0)
        {
            self.curBindDevice = [self.loginedInfo.arrUserBindedDevice objectAtIndex:0];
        }
    }
    else
    {
        AirDevice *curAirDeviceTmp = nil;
        for (int i = 0; i < self.loginedInfo.arrUserBindedDevice.count; i++)
        {
            AirDevice *airDeviceTmp = (AirDevice *)[self.loginedInfo.arrUserBindedDevice objectAtIndex: i];
            if([airDeviceTmp.mac isEqualToString:self.curBindDevice.mac])
            {
                curAirDeviceTmp = airDeviceTmp;
            }
        }
        
        if(!curAirDeviceTmp)
        {
            if(self.loginedInfo.arrUserBindedDevice.count > 0)
            {
                curAirDeviceTmp = [self.loginedInfo.arrUserBindedDevice objectAtIndex:0];
            }
        }
        
        if(curAirDeviceTmp)
        {
            self.curBindDevice = curAirDeviceTmp;
        }
    }
}

-(void)showScoreView:(id)sender
{
    UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"最近雾霾好严重，小A好辛苦~求大家赏个好评…T_T",@"AppDelegate.m")
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"赏个好评",@"AppDelegate.m")
                                             otherButtonTitles:NSLocalizedString(@"残忍的拒绝",@"AppDelegate.m"),NSLocalizedString(@"以后再说",@"AppDelegate.m"),nil];
    [pwdAlert setTag:100000];
    [pwdAlert show];
}


- (NSURL *)applicationDocumentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [output appendFormat:@"%02x", digest[i]];
    }
    return  output;
}

- (NSMutableURLRequest *)requestUrl:(NSURL *)url method:(NSString *)method body:(NSString *)body
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"UTF-8" forHTTPHeaderField:@"Charset"];
    [request addValue:APP_ID forHTTPHeaderField:@"appId"];
    [request addValue:APP_KEY forHTTPHeaderField:@"appKey"];
    [request addValue:APP_VERSION forHTTPHeaderField:@"appVersion"];
    NSString *tokenTmp = self.token ? self.token :@"";
    [request addValue:tokenTmp forHTTPHeaderField:@"clientId"];
    [request addValue:loginedInfo.accessToken forHTTPHeaderField:@"accessToken"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [request setTimeoutInterval:30.0f];
    DDLogCVerbose(@"\n%@\n",[request allHTTPHeaderFields]);
    DDLogCVerbose(@"Request: %@ %@\n%@\n%@\n", method, url, body, self.token);
    return request;
}

- (int)moodValueConvert:(int)value
{
    if(value >= 0 && value <= 20)
    {
        return 20;
    }
    else if(value > 20 && value <= 40)
    {
        return 40;
    }
    else if(value > 40 && value <=60)
    {
        return 60;
    }
    else if(value > 60 && value <= 80)
    {
        return 80;
    }
    else if(value > 80 && value <= 99)
    {
        return 99;
    }
    else
    {
        return 100;
    }
}

- (NSString *)coventPM25Status:(NSString *)code
{
    /**
     if([code isEqualToString:@"30w001"])
     {
     return NSLocalizedString(@"优",@"AppDelegate.m");
     }
     else if([code isEqualToString:@"30w002"])
     {
     return NSLocalizedString(@"良",@"AppDelegate.m");
     }
     else if([code isEqualToString:@"30w003"])
     {
     return NSLocalizedString(@"中",@"AppDelegate.m");
     }
     else if([code isEqualToString:@"30w004"])
     {
     return NSLocalizedString(@"差",@"AppDelegate.m");
     }
     //    else if([code intValue] <= 20)
     //    {
     //        return NSLocalizedString(@"优",@"AppDelegate.m");
     //    }
     //    else if([code intValue] > 20 && [code intValue] <= 70)
     //    {
     //        return NSLocalizedString(@"良",@"AppDelegate.m");
     //    }
     //    else if([code intValue] > 70 && [code intValue] <= 100)
     //    {
     //        return NSLocalizedString(@"中",@"AppDelegate.m");
     //    }
     //    else if([code intValue] > 100 )
     //    {
     //        return NSLocalizedString(@"差",@"AppDelegate.m");
     //    }
     return code;
     
     */
    
    if([code isEqualToString:@"30w001"])
    {
        return NSLocalizedString(@"优",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w002"])
    {
        return NSLocalizedString(@"良",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w003"])
    {
        return NSLocalizedString(@"中",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w004"])
    {
        return NSLocalizedString(@"差",@"AppDelegate.m");
    }
    else if([code intValue] > 0 && [code intValue] <= 500)
    {
        if ([code intValue] == 20)
        {
            return NSLocalizedString(@"优",@"AppDelegate.m");
        } else if ([code intValue] == 70)
        {
            return NSLocalizedString(@"良",@"AppDelegate.m");
        } else if ([code intValue] == 100) {
            return NSLocalizedString(@"中",@"AppDelegate.m");
        } else if([code intValue] == 200){
            return NSLocalizedString(@"差",@"AppDelegate.m");
        } else
        {
            return code;
        }
    }
    else if([code intValue] > 500)
    {
        return NSLocalizedString(@"差",@"AppDelegate.m");
    }
    else
    {
        return @"--";
    }
}

- (NSString *)coventVOCStatus:(NSString *)code
{
    
    if([code isEqualToString:@"30w001"])
    {
        return NSLocalizedString(@"优",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w002"])
    {
        return NSLocalizedString(@"良",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w003"])
    {
        return NSLocalizedString(@"中",@"AppDelegate.m");
    }
    else if([code isEqualToString:@"30w004"])
    {
        return NSLocalizedString(@"差",@"AppDelegate.m");
    }
    else
    {
        return @"--";
    }
}

- (void)showProgressHubInView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    });
}

- (void)hiddenProgressHubInView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
    });
}

- (id)parseJsonData:(NSData *)data
{
    DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if(data == nil)
    {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
}

- (NSString *)createJsonString:(NSDictionary *)dictionary
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSInvocationOperation *)operationWithTarget:(id)target selector:(SEL)sel object:(id)object
{
    return [[NSInvocationOperation alloc] initWithTarget:target selector:sel object:object];
}

- (BOOL)isNetworkAvailable
{
    return isNetworkConnenct;
}

- (void)testNetworkAvailable
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSURL *URL=SERVER_GETPMRANGE;
        
        NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID],
                                  @"temperature":@"24",
                                  @"humidity":@"24",
                                  @"pm25":@"24",
                                  @"voc":@"24"};
        NSString *body = [MainDelegate createJsonString:dicBody];
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_COUNT_QUALITY(@"")
                                                         method:HTTP_POST
                                                           body:body];
    
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setTimeoutInterval:10];
        
//        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
        if (response == nil) {
            isNetworkConnenct =  NO;
        }
        else{
            isNetworkConnenct = YES;
        }
    });
}


- (int)countTempVlue:(NSNumber *)temp hardWare:(NSString *)version typeID:(NSString *)type
{
    if([temp integerValue] == 0)
    {
        return 0;
    }
    
    // 华氏转摄氏度
    int newTemp = (int)round(([temp doubleValue]-300)/10);
    
    // 语音盒子
    if([type isEqualToString:AIRBOX_IDENTIFIER_V15])
    {
    }
    else
    {
        NSString *versionTmp = [version substringToIndex:6];
        // 软件版本号141103直接显示
        if([versionTmp isEqualToString:@"141103"])
        {
        }
        // 软件版本号140426和140430和140306和140501和140610的温度补偿统一 减4度
        else if([versionTmp isEqualToString:@"140426"] ||
                [versionTmp isEqualToString:@"140430"] ||
                [versionTmp isEqualToString:@"140306"] ||
                [versionTmp isEqualToString:@"140501"] ||
                [versionTmp isEqualToString:@"140610"])
        {
            newTemp -= 4;
        }
        // 其他版本直接显示
        else
        {
        }
    }
    
    if(newTemp < -30)
    {
        newTemp = -30;
    }
    
    if(newTemp > 100)
    {
        newTemp = 100;
    }
    
    return newTemp;
}

- (int)countHumValue:(NSNumber *)hum withTemp:(NSNumber *)temp hardWare:(NSString *)version typeID:(NSString *)type
{
    if([hum integerValue] == 0)
    {
        return 0;
    }
    
    // 先换算
    double correctHum = round([hum doubleValue]/10);
    
    // 语音盒子
    if([type isEqualToString:AIRBOX_IDENTIFIER_V15])
    {
    }
    else
    {
        NSString *versionTmp = [version substringToIndex:6];
        
        // 软件版本号140430,140306（ST传感器）和 141103（SHT（盛思锐）传感器）湿度取消补偿，APP显示值=空气盒子上报的湿度值。
        if([versionTmp isEqualToString:@"140430"] ||
           [versionTmp isEqualToString:@"140306"] ||
           [versionTmp isEqualToString:@"141103"])
        {
        }
        // 软件版本号140426，140501和 140610（SHT（盛思锐）传感器）按照之前的公式，采用3度进行补偿。
        else if([versionTmp isEqualToString:@"140426"] ||
                [versionTmp isEqualToString:@"140501"] ||
                [versionTmp isEqualToString:@"140610"])
        {
            int showTemp = [self countTempVlue:temp hardWare:version typeID:type];
            double tempFromBox = ([temp doubleValue] - 300)/10;
            double temporary = 4283.78 * (tempFromBox - showTemp -1) / (243.12 + tempFromBox) / (243.12 + showTemp);
            correctHum = (int)round(correctHum * exp(temporary));
        }
        // 其他版本直接显示
        else
        {
        }
    }
    
    if(correctHum < 0)
    {
        correctHum = 0;
    }
    else if(correctHum > 100)
    {
        correctHum = 100;
    }
    return (int)correctHum;
}


- (NSString *)jsonStringWithObject:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]]
        && ![object isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (!data)
    {
        DDLogCVerbose(@"Generate Json string error: %@", error);
        return nil;
    }
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSString*)ssidForConnectedNetwork
{
    NSArray *interfaces = (__bridge NSArray*)CNCopySupportedInterfaces();
    NSDictionary *info = nil;
    for (NSString *ifname in interfaces)
    {
        info = (__bridge NSDictionary*)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info && [info count])
        {
            break;
        }
        info = nil;
    }
    
    DDLogCVerbose(@"SSID == %@  info === %@",[info objectForKey:@"SSID"],info);
    NSString *ssid = nil;
    if ( info )
    {
        ssid = [info objectForKey:@"SSID"];
    }
    return ssid? ssid:@"";
}

static int sequenceCount = 0;

- (NSString *)sequenceID
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSDateComponents *component = [calendar components:unitFlags fromDate:[NSDate date]];
    sequenceCount = (sequenceCount + 1) % 1000000;
    NSString *sequence = [NSString stringWithFormat:@"%04d%02d%02d%02d%02d%02d%06d",
                          component.year,
                          component.month,
                          component.day,
                          component.hour,
                          component.minute,
                          component.second,
                          sequenceCount];
    return sequence;
}

- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * Phone number
     * mobile：134,135,136,137,138,139,147,150,151,152,157,158,159,182,183,187,188,1705
     * unicom：130,131,132,155,156,185,186,1709
     * telecom：133,153,180,189,177,1700
     */
    
    /**
    NSString *mobile = @"^1(3[4-9]\\d|47\\d|5[0-27-9]\\d|8[2378]\\d|705)\\d{7}$";
    NSString *unicon = @"^1(3[0-2]\\d|[58][56]\\d||709)\\d{7}$";
    NSString *telecom = @"^1([35]3\\d|8[09]\\d|77\\d|700)\\d{7}$";
    
    NSPredicate *regexMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobile];
    NSPredicate *regexUnicon = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", unicon];
    NSPredicate *regexTelecom = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", telecom];
    
    if ([regexMobile evaluateWithObject:mobileNum]
        || [regexUnicon evaluateWithObject:mobileNum]
        || [regexTelecom evaluateWithObject:mobileNum])
    {
        return YES;
    }
    else
    {
        return NO;
    }
     */
    
    NSString *mobile = @"^1\\d{10}$";
    NSPredicate *regexMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobile];
    
    if ([regexMobile evaluateWithObject:mobileNum])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isCurrentNetworkWiFi
{
    if([Reachability reachabilityForInternetConnection].currentReachabilityStatus == ReachableViaWiFi)
    {
        return YES;
    }
    return NO;
}

- (void)isCurrentNetworkEnable:(void(^)(BOOL enable))handler
{
    BOOL bEnabled = FALSE;
    NSString *url = @"uhome.haier.net";
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [url UTF8String]);
    SCNetworkReachabilityFlags flags;
    
    bEnabled = SCNetworkReachabilityGetFlags(ref, &flags);
    
    CFRelease(ref);
    if (bEnabled) {
        BOOL flagsReachable = ((flags & kSCNetworkFlagsReachable) != 0);
        BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
        BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
        bEnabled = ((flagsReachable && !connectionRequired) || nonWiFi) ? YES : NO;
    }
    handler(bEnabled);
}
- (BOOL)isNetworkAvailableWiFiOr3G
{
    if([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"AppDelegate.m")];
        //网络异常,请检查网络设置!
        return NO;
    }
    return YES;
}
- (void)reDownloadToken:(void(^)(BOOL succeed))handler
{
    if(![MainDelegate isNetworkAvailable])return;
    
    NSDictionary *dicBody = @{@"loginId":self.loginedInfo.loginID,
                              @"password":self.loginedInfo.loginPwd,
                              @"accType":[NSNumber numberWithInt:0],
                              @"sequenceId":[self sequenceID],
                              @"loginType":[NSNumber numberWithInt:1]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_LOGIN
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL succeed = YES;
         if(error)
         {
             succeed = NO;
         }
         else
         {
             DDLogCVerbose(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->reDownloadToken response: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSString *token = isObject(result[@"accessToken"]) ? result[@"accessToken"] : @"";
                 if(!token)
                 {
                     NSDictionary *header = [(NSHTTPURLResponse *)response allHeaderFields];
                     header = isObject(header) ? header : [NSDictionary dictionary];
                     NSString *accessToken = isObject(header[@"accessToken"]) ? header[@"accessToken"] : @"";
                     NSArray *arrToken = [accessToken componentsSeparatedByString:@","];
                     token = [[arrToken lastObject] stringByReplacingOccurrencesOfString:@" " withString:@""];
                 }
                 
                 self.loginedInfo.accessToken = token;
             }
             else
             {
                 succeed = NO;
             }
         }
         handler(succeed);
     }];
}


- (NSString *)siftCurrentIconWithName:(NSString *)name needNight:(BOOL)need Hour:(NSInteger)hour
{
    NSString *iconName;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"WeatherIcon.plist" ofType:nil];
    NSDictionary *icons = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    if ([icons[name] isKindOfClass:[NSArray class]])
    {
        if(need)
        {
            NSInteger curHour;
            
            if (hour > 24)
            {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                [formatter setDateFormat:@"HH"];
                NSString *dateString = [formatter stringFromDate:[NSDate date]];
                curHour = [dateString integerValue];
            }
            else
            {
                curHour = hour;
            }
            
            if (curHour > 6 && curHour < 19)
            {
                iconName = icons[name][0];
            }
            else
            {
                iconName = icons[name][1];
            }
        }
        else
        {
            iconName = icons[name][0];
        }
    }
    else
    {
        iconName = icons[name];
    }
    
    
    return [iconName stringByAppendingString:PNG];
}

- (NSString *)erroInfoWithErrorCode:(NSString*)errorCode
{
    NSString *filePath;
    if ([MainDelegate isLanguageEnglish]) {
        filePath = [[NSBundle mainBundle] pathForResource:@"enErrorInfo.plist" ofType:nil];
    }else{
        filePath = [[NSBundle mainBundle] pathForResource:@"ErrorInfo.plist" ofType:nil];
    }
    NSDictionary *errorInfoList = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *errorInfo = errorInfoList[errorCode];
    return errorInfo;
}

- (void)versionExamineOnClicked:(id)sender
{
    [self showProgressHubInView:nil];
    NSDictionary *bodyDict = @{@"sequenceId": [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:bodyDict];
    
    NSURLRequest *request = [MainDelegate requestUrl:SERVER_VERSION(self.loginedInfo.userID) method:HTTP_POST body:body];
    
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [self hiddenProgressHubInView:nil];
         NSDictionary *result = [MainDelegate parseJsonData:data];
         result = isObject(result) ? result : nil;
         
         DDLogCVerbose(@"--->后去app版本接口信息%@",result);
         
         if ([result[@"version"] isEqual:[NSNull null]] || result[@"version"] == nil)
         {
             return;
         }
         
         if ((connectionError && sender))
         {
             [AlertBox showWithMessage:NSLocalizedString(@"版本检测失败",@"AppDelegate.m")];
         }
         else
         {
             if ([APP_UPDATE_VERSION integerValue] < [result[@"version"] integerValue])
             {
                 [AlertBox showIsUpdateWithMessage:NSLocalizedString(@"空气盒子应用新版本上线啦!",@"AppDelegate.m") delegate:(id)self];
             }
             else if(sender)
             {
                 [AlertBox showWithMessage:NSLocalizedString(@"当前已是最新版本",@"AppDelegate.m")];
             }
         }
     }];
}

-(BOOL)isLanguageEnglish{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    DDLogCVerbose(@"language is %@",currentLanguage);
    if ([currentLanguage isEqualToString:@"zh-Hans"]) {
        return NO;
    }else
        return YES;
}

-(NSString *)cityNameInternationalized:(NSString*)cityname{
    NSError *error;
    
    NSString *textFileContents ;
    
    if ([MainDelegate isLanguageEnglish]) {
        if (![self isStringEnglish:cityname]) {
                    textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"citylistEn" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
//            [[CityManager sharedManager] addCity:currentCityWeather];

        }else{
            return cityname;
        }
    }else{
        if ([self isStringEnglish:cityname]) {
                    textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"citylist" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
        }else{
            return cityname;
        }
    }
    NSDictionary *dic = [Utility jsonValue:textFileContents];
    NSArray *listArray = [dic valueForKey:@"citylist"];
    for (id tmp in listArray) {
        NSDictionary *dic = tmp;
        NSString *cityID= [dic valueForKey:@"id"];
        if ([cityID isEqualToString:[CityDataHelper cityIDOfSelectedCity]]) {
            cityname= [dic valueForKey:@"name"];
        }
    }
    return cityname;
}


-(BOOL)isStringEnglish:(NSString*)text{

    if (text==nil) {
        return YES;
    }
        NSRange range = NSMakeRange(1, 1);
        NSString *subString = [text substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3)
        {
            return NO;
        }else{
            return YES;
        }

}

#pragma mark - Getter Methods

- (NSString *)token
{
    if (!_token || [_token isEqualToString: @"1234567812345678123456781234567812345678123456781234567812345678"])
    {
        NSData *token = [UserDefault objectForKey:DeviceToken];
        if (token)
        {
            NSString *tokenString = [NSString stringWithFormat:@"%@",token];
            _token = [tokenString substringWithRange:NSMakeRange(1, [tokenString length] -2)];
        }
        else
        {
            _token = @"1234567812345678123456781234567812345678123456781234567812345678";
        }
    }
    
    return _token;
}


-(void)startGetPm25FloatRange:(AirDevice *)device
{
    NSString *deviceMac = device.mac;
    [self getPm25FloatRange: device];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(device != nil)
    {
        [dict setObject:device forKey:@"devicePm25FloatRange"];
    }
    
    NSTimer *timerTmp = [_dicNSTime objectForKey:deviceMac];
    if(timerTmp)
    {
        if(timerTmp.isValid)
        {
            [timerTmp invalidate];
        }
        
        timerTmp = nil;
    }
    
    //  保存timer，以便下次关闭
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: 30 * 60
                                     target:self
                                   selector:@selector(getPm25FloatRangeForTime:)
                                   userInfo:dict
                                    repeats:YES];
    [_dicNSTime setObject:timer forKey:deviceMac];
}

-(void)getPm25FloatRangeForTime :(NSTimer *)timer
{
    AirDevice *deviceTmp = [[timer userInfo] objectForKey:@"devicePm25FloatRange"];
    [self getPm25FloatRange:deviceTmp];
}
-(void)getPm25FloatRange :(AirDevice *)device
{
    if(![MainDelegate isNetworkAvailable])return;
    
    NSString *deviceMac = device.mac;
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc] init];
    [dicBody setObject:[MainDelegate sequenceID] forKey:@"sequenceId"];
    [dicBody setObject:(deviceMac ? deviceMac : @"") forKey:@"deviceId"];
    [dicBody setObject:(MainDelegate.loginedInfo.userID ? MainDelegate.loginedInfo.userID : @"") forKey:@"userId" ];
    
    if(MainDelegate.devicelat)
    {
        [dicBody setObject:[NSString stringWithFormat:@"%@",MainDelegate.devicelat] forKey:@"lat"];
    }
    
    if(MainDelegate.devicelng)
    {
        [dicBody setObject:[NSString stringWithFormat:@"%@",MainDelegate.devicelng] forKey:@"lng"];
    }
    
    NSString *cityId = device.city ? device.city : @"";
    if(cityId && cityId.length > 0)
    {
        [dicBody setObject:cityId forKey:@"city"];
    }
    
    NSString *body = [MainDelegate createJsonString:dicBody];
 
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_GETPMRANGE
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL succeed = YES;
         if(error)
         {
             succeed = NO;
             [self.pm25FloatRange setObject:@[@70,@30,@4,@0]forKey:deviceMac];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->getPm25FloatRange response: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSNumber *xNum= result[@"range"][0];
                 NSNumber *yNum=result[@"range"][1];
                 NSNumber *zNum = result[@"range"][2];
                 NSNumber *aNum = @0;
                 
                 [self.pm25FloatRange setObject:@[xNum,yNum,zNum,aNum] forKey:deviceMac];
                 
                 [self loadCurrentPM25:device];
                 return;
             }
         }
     }];
}

- (void)loadCurrentPM25:(AirDevice *)device
{
    NSString *cityId = device.city;
    NSString *deviceMac = device.mac;
    if(cityId.length > 0)
    {
        NSString *requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/air?city_code=%@&language=zh_CN",BASEURL,cityId];
        NSURL *url = [NSURL URLWithString:requestStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"GET"];
        [request setTimeoutInterval:15];
        [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        AFHTTPRequestOperation *operation5 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        __weak typeof(self) weakSelf = self;
        [operation5 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSMutableDictionary *dic = [Utility jsonValue:str];
            
            DDLogCVerbose(@"--->loadCurrentPM25 response data: %@",str);
            if (([[dic objectForKey:@"code"] integerValue] == 0))
            {
                if([dic objectForKey:@"data"] && ![[dic objectForKey:@"data"]isEqual:[NSNull null]])
                {
                    NSArray *arrPm25 = [weakSelf.pm25FloatRange objectForKey:deviceMac];
                    NSNumber *xNum= @70;
                    NSNumber *yNum= @30;
                    NSNumber *zNum = @4;
                    NSNumber *aNum = @0;
                    NSString *pm25 = [[dic objectForKey:@"data"] objectForKey:@"pm25"];
                    if(pm25.length  > 0)
                    {
                        aNum = [NSNumber numberWithInt:[pm25 integerValue]];
                    }
                    if(arrPm25 && arrPm25.count >= 3)
                    {
                        xNum = [arrPm25 objectAtIndex:0];
                        yNum = [arrPm25 objectAtIndex:1];
                        zNum = [arrPm25 objectAtIndex:2];
                    }
                    [weakSelf.pm25FloatRange setObject:@[xNum,yNum,zNum,aNum] forKey:deviceMac];
                }
                else
                {
                }
                
            }else
            {
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        [operation5 start];
    }
}

- (void)doHandleMessage:(PushMessage *)pushMessage
{
    NSString *type = pushMessage.contentType;
    if(type.length == 9)
    {
        // * 前两位表示大类，
        NSString *str1 = [type substringToIndex:2];
        //  * 第三四表示小类
        NSString *str2 = [type substringWithRange:NSMakeRange (2, 2)];
        //  * 第七、八、九表示业务
        NSString *str4 = [type substringWithRange:NSMakeRange (6, 3)];
        
        // 00----代表消息类型为提示信息
        if([str1 isEqualToString:@"00"])
        {
            // 00采用弹出窗口显示内容，按钮“知道了”，点击后弹窗消失。
            if([str2 isEqualToString:@"00"])
            {
                //  000直接用普通弹出框显示消息
                if([str4 isEqualToString:@"000"])
                {
                    UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:pushMessage.titleMessage
                                                                       message:pushMessage.contentMessage
                                                                      delegate:nil
                                                             cancelButtonTitle:NSLocalizedString(@"知道了",@"CityViewController.m")
                                                             otherButtonTitles:nil];
                    [pwdAlert show];
                }
                // 025用普通弹出框显示，点击“知道了”跳转反馈页面
                else if([str4 isEqualToString:@"025"])
                {
                    [self showFeedBackAlert1:pushMessage];
                }
            }
            // 02采用弹出窗口显示内容，按钮“是和否”，点击通过端口回传值
            else if([str2 isEqualToString:@"02"])
            {
                //  000直接用普通弹出框显示消息
                if([str4 isEqualToString:@"000"])
                {
                    UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:pushMessage.titleMessage
                                                                       message:pushMessage.contentMessage
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"是",@"CityViewController.m")
                                                             otherButtonTitles:NSLocalizedString(@"否",@"CityViewController.m"),nil];

                    [pwdAlert setTag:2000];
                    [pwdAlert show];
                    
                }
                // 025用普通弹出框显示，点击“知道了”跳转反馈页面
                else if([str4 isEqualToString:@"025"])
                {
                    [self showFeedBackAlert2:pushMessage];
                }
            }
        }
    }
}

-(void)showFeedBackAlert1:(PushMessage *)pushMessage
{
    NSString *userID = MainDelegate.loginedInfo.userID;
    
    if( userID.length > 0 &&
       [self isNetworkAvailable])
    {
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:pushMessage.titleMessage
                                                           message:pushMessage.contentMessage
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"知道了",@"CityViewController.m")
                                                 otherButtonTitles:nil];
        [pwdAlert setTag:1000];
        [pwdAlert show];
    }
}
-(void)showFeedBackAlert2:(PushMessage *)pushMessage
{
    NSString *userID = MainDelegate.loginedInfo.userID;
    
    if( userID.length > 0 &&
       [self isNetworkAvailable])
    {
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:pushMessage.titleMessage
                                                           message:pushMessage.contentMessage
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"是",@"CityViewController.m")
                                                 otherButtonTitles:NSLocalizedString(@"否",@"CityViewController.m"),nil];
        [pwdAlert setTag:3000];
        [pwdAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100000:
        {
            if(buttonIndex == [alertView cancelButtonIndex])
            {
                NSURL *httpURL = [[NSURL alloc] initWithString:@"https://itunes.apple.com/cn/app/kong-qi-he-zi/id849464472?mt=8"];
                
                [[UIApplication sharedApplication] openURL:httpURL];
                
                [UserDefault setBool:NO forKey:kIsShowScoreView];
                [UserDefault synchronize];
            }
            else if(buttonIndex == [alertView firstOtherButtonIndex])
            {
                [UserDefault setBool:NO forKey:kIsShowScoreView];
                [UserDefault synchronize];
            }
            else
            {
                [UserDefault setBool:YES forKey:kIsShowScoreView];
                [UserDefault synchronize];
            }
        }
            break;
        case 1000:
        {
            if(buttonIndex == [alertView cancelButtonIndex])
            {
                [self pushFeedBackVC];
            }
        }
            break;
        case 2000:
        {
            if(buttonIndex == [alertView cancelButtonIndex])
            {
                [self sendConfirmMessage:@YES];
            }
            else
            {
                [self sendConfirmMessage:@NO];
            }
        }
            break;
        case 3000:
        {
            if(buttonIndex == [alertView cancelButtonIndex])
            {
                [self pushFeedBackVC];
            }
        }
            break;
    }
}

- (void) sendConfirmMessage:(NSNumber *)isYES;
{
    if(_pushMessageID.length > 0 &&
       loginedInfo.userID.length > 0 &&
       [self isNetworkAvailable])
    {
        NSDictionary *dicBody = @{
                                  @"yesOrNo":isYES,
                                  @"messageId":_pushMessageID,
                                  };
        
        NSString *body = [MainDelegate createJsonString:dicBody];
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_MESSEGES_CONFIRM(loginedInfo.userID)
                                                         method:HTTP_POST
                                                           body:body];
        [NSURLConnection sendAsynchronousRequestTest:request
                                               queue:[NSOperationQueue currentQueue]
                                   completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
         {
             if(error)
             {
             }
             else
             {
                 NSDictionary *result = [MainDelegate parseJsonData:data];
                 result = isObject(result) ? result : nil;
                 
                 DDLogCVerbose(@"--->sendConfirmMessage%@",result);
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                 {
                 }
             }
         }];
    }

}

- (void)pushFeedBackVC
{
    DDLogFunction();
    FeedbackViewController *feedBackController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    feedBackController.view.frame = MainDelegate.window.frame;
    [feedBackController setParentContoller:feedBackController];
    dispatch_async(dispatch_get_main_queue(), ^{
        feedBackController.view.alpha = 0.0;
        [MainDelegate.window addSubview:feedBackController.view];
        [UIView animateWithDuration:0.3 animations:^{
            feedBackController.view.alpha = 1.0;
        }];
    });
}

#pragma mark - Protocol conformance


#pragma mark - AlertBoxDelegate

- (void)updateVersionButtonOnClicked
{
    [[UIApplication sharedApplication] openURL:kAppStoreLink];
}

- (void)notUpdateVersionButtonOnClicked
{
    
}


#pragma mark - WXApiDelegate

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]] && resp.errCode != WXSuccess && resp.errCode != WXErrCodeUserCancel)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"分享到微信失败",@"AppDelegate.m")];
    }
}

@end
