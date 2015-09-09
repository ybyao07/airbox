//
//  HomeViewController.m
//  AirManager
//

#import "HomeViewController.h"
#import "AirDeivceManageViewController.h"
#import "SettingViewController.h"
#import "AirDevice.h"
#import "AirQuality.h"
#import "CityDataHelper.h"
#import "WeatherManager.h"
#import "AirDeviceManager.h"
#import "UIDevice+Resolutions.h"
#import "UserLoginedInfo.h"
#import <uSDKFramework/uSDKDevice.h>
#import "AppDelegate.h"
#import "SDKRequestManager.h"
#import "AirBoxStatus.h"

@interface HomeViewController (){
    IBOutlet UITapGestureRecognizer *tapWeatheRecognizer;
    IBOutlet UITapGestureRecognizer *tapAirRecognizer;
    IBOutlet UIView *weathView;
    IBOutlet UIView *airBoxView;
    
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblCity;
    
    IBOutlet UILabel *lblTemperature;
    IBOutlet UILabel *lblWeather;
    IBOutlet UIImageView *weatherIcon;
    
    IBOutlet UILabel *lblAirManagerName;
    IBOutlet UILabel *lblAirScore;
    IBOutlet UILabel *lblRoomEnvironment;
    
    IBOutlet UIActivityIndicatorView *weatherWaitView;
    IBOutlet UIActivityIndicatorView *airManagerWaitView;
    IBOutlet UILabel *weatherWaitTitle;
    IBOutlet UILabel *airManagerWaitTitle;
    IBOutlet UIImageView *airBoxIcon;
    
//    IBOutlet UIImageView *helpView;
    IBOutlet UIImageView *weatherBackGroundView;
    
    NSArray *arrAirManagerDevice;

}

- (IBAction)setting:(id)sender;

/**
 *  tap weather, open weather page
 **/
- (IBAction)tapWeatherPage:(UITapGestureRecognizer *)sender;

/**
 *  tap air box, open air box management page
 **/
- (IBAction)tapAirPage:(UITapGestureRecognizer *)sender;

/**
 *  tap help page to hidden it
 **/
- (IBAction)tapToHiddenHelp:(UITapGestureRecognizer *)sender;
 
/**
 *   get current small A info
 **/
- (void)currentAirDeviceInfo;

/**
 *  Download small A info
 **/
- (void)downloadAirDeviceInfo;

/**
 *  Show small info for a View
 **/
- (void)loadAirDeviceInfo:(AirQuality *)info;

/**
 *  Show connection small A wait for View
 **/
- (void)showConnectWaitView;

/**
 *  Hidden connrction small A wait for View
 **/
- (void)hiddenConnectWaitView;

/**
 *  Show access weather wait View
 **/
- (void)showWeatherWaitView;

/**
 *  Hidden access weather wait View
 **/
- (void)hiddenWeatherWaitView;

/**
 *  register observer
 **/
- (void)registerObserver;

/**
 *  remove observer
 **/
- (void)removeObserver;

@property (nonatomic, strong) NSArray *arrAirManagerDevice;

@end

@implementation HomeViewController

@synthesize arrAirManagerDevice;

- (void)dealloc
{
    DDLogFunction();
    [self removeObserver];
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
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd"];
    dispatch_async(dispatch_get_main_queue(), ^{
        lblDate.text = [format stringFromDate:[NSDate date]];
    });
    
    [self loadCurrentWeatherToScreen];
    [self loadFutureWeatherToScreen];
    
    NSDate *lastDate = [UserDefault objectForKey:kWeatherTimeKey];
    if(!lastDate || abs([lastDate timeIntervalSinceNow]) > khour)
    {
        [[WeatherManager sharedInstance] stopAutoReload];
        [[WeatherManager sharedInstance] loadWeather];
    }
    
    MainDelegate.curBindDevice = MainDelegate.loginedInfo.arrUserBindedDevice[0];
    [self registerObserver];
    [self currentAirDeviceInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*
    BOOL homePageHelp = [UserDefault boolForKey:kHomePageHelp];
    if (!homePageHelp)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view bringSubviewToFront:helpView];
            helpView.hidden = NO;
            helpView.alpha = 1;
        });
    }
     */
    
    [self checkAirBoxConnectStatus];
    [self loadDeviceStatus];
    [self loadAirDeviceInfo:MainDelegate.curAirQuality];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)loadCurrentWeatherToScreen
{
    NSDictionary *curWeather = [NSKeyedUnarchiver unarchiveObjectWithData:[UserDefault objectForKey:kCurrentWeather]];
    if(curWeather.count > 0)
    {
        NSDictionary *weather = curWeather[InstantWeatherDefine];
        NSString *imageName = [MainDelegate siftCurrentIconWithName:weather[CurWeather] needNight:YES Hour:99];
        dispatch_async(dispatch_get_main_queue(), ^{
            weatherBackGroundView.image = [UIImage imageNamed:weather[kBackGroundName]];
            lblWeather.text = weather[CurWeather];
            lblTemperature.text = [NSString stringWithFormat:@"%@%@",weather[Temperature],CelciusSymbol];
            weatherIcon.image = [UIImage imageNamed:imageName];
        });
    }
    else
    {
        NSString *cityName = [CityDataHelper cityNameOfSelectedCity];
        lblCity.text = [NSString stringWithFormat:@"%@ 7~15%@",cityName,CelciusSymbol];
    }
}

- (void)loadFutureWeatherToScreen
{
    
    NSDictionary *futWeather = [MainDelegate parseJsonData:[UserDefault objectForKey:kFutureWather]];
    if(futWeather.count > 0)
    {
        NSDictionary *curDay = futWeather[Weather1];
        NSString *dayTemp = curDay[DayTemp];
        if([dayTemp stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
        {
            dayTemp = futWeather[Weather2][DayTemp];
        }
        NSString *info = [NSString stringWithFormat:@"%@ %@~%@%@",
                          [CityDataHelper cityNameOfSelectedCity],
                          curDay[NightTemp],
                          dayTemp,
                          CelciusSymbol];
        dispatch_async(dispatch_get_main_queue(), ^{
            lblCity.text = info;
        });
    }
    else
    {
        NSString *cityName = [CityDataHelper cityNameOfSelectedCity];
        lblCity.text = [NSString stringWithFormat:@"%@ 7~15%@",cityName,CelciusSymbol];
    }
}


- (void)currentAirDeviceInfo
{
    [self checkAirBoxConnectStatus];
    [self downloadAirDeviceInfo];
}

- (void)downloadAirDeviceInfo
{
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    [airDeviceManager loadAirDeviceData:MainDelegate.curBindDevice completionHandler:^(AirQuality *quality,BOOL isSucceed){
        if(isSucceed)
        {
            if(MainDelegate.curAirQuality == nil)
            {
                MainDelegate.curAirQuality = quality;
            }
            else
            {
                MainDelegate.curAirQuality.mark = quality.mark;
                MainDelegate.curAirQuality.markInfo = quality.markInfo;
            }
//            MainDelegate.curAirQuality = quality;
            [self loadDeviceStatus];
            [self loadAirDeviceInfo:quality];
        }
        else
        {
            //[AlertBox showWithMessage:Localized(@"获取空气质量数据失败")];
        }
    }];
}

- (void)loadDeviceStatus
{
    AirBoxStatus *status = MainDelegate.allAirBoxStatus[MainDelegate.curBindDevice.mac];
    if(status)
    {
        DDLogVerbose(@"loadDeviceStatus %@",status.moodPoint);
        MainDelegate.curAirQuality.temperature = status.temperature;
        MainDelegate.curAirQuality.humidity = status.humidity;
        MainDelegate.curAirQuality.pm25 = status.pm25;
        MainDelegate.curAirQuality.mark = [NSNumber numberWithInt:[status.moodPoint intValue]];
        DDLogVerbose(@"loadDeviceStatus %d",[MainDelegate.curAirQuality.mark intValue]);
    }
}

- (void)loadAirDeviceInfo:(AirQuality *)info
{
    if(info == nil)return;
    int moodTag = [MainDelegate moodValueConvert:[info.mark intValue]];
    NSString *name = [NSString stringWithFormat:@"mood_icon_%d.png",moodTag];
    dispatch_async(dispatch_get_main_queue(), ^{
        lblAirManagerName.text = MainDelegate.curBindDevice.name;
        lblAirScore.text = [info.mark stringValue];
        lblRoomEnvironment.text = info.markInfo;
        airBoxIcon.image = [UIImage imageNamed:name];
    });
}

#pragma mark - IBAction Event

- (IBAction)setting:(id)sender
{
    SettingViewController *setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:setting animated:YES];
}

- (IBAction)tapWeatherPage:(UITapGestureRecognizer *)sender
{
//    WeatherViewController *weatherView = [[WeatherViewController alloc] initWithNibName:@"WeatherViewController" bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:weatherView];
//    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    navController.navigationBar.translucent = NO;
//    navController.navigationBarHidden = YES;
//    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)tapAirPage:(UITapGestureRecognizer *)sender
{
    AirDeivceManageViewController *airDeviceView = [[AirDeivceManageViewController alloc] initWithNibName:@"AirDeivceManageViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:airDeviceView];
    navController.navigationBarHidden = YES;
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)tapToHiddenHelp:(UITapGestureRecognizer *)sender
{
    /*
    [UserDefault setBool:YES forKey:kHomePageHelp];
    [UserDefault synchronize];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            helpView.alpha = 0;
         }
        completion:^(BOOL finished){
                helpView.hidden = YES;
         }];
    });
     */
}

#pragma mark - Waiting View

- (void)checkAirBoxConnectStatus
{
    if([[SDKRequestManager sharedInstance] isWaitConnect:MainDelegate.curBindDevice.mac])
    {
        [self showConnectWaitView];
    }
    else
    {
        [self hiddenConnectWaitView];
    }
}

- (void)showConnectWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        airManagerWaitTitle.hidden = NO;
        if(!airManagerWaitView.isAnimating)
        {
            [airManagerWaitView startAnimating];
        }
    });
}

- (void)hiddenConnectWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        airManagerWaitTitle.hidden = YES;
        if(airManagerWaitView.isAnimating)
        {
            [airManagerWaitView stopAnimating];
        }
    });
}

- (void)showWeatherWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        weatherWaitTitle.hidden = NO;
        if(!weatherWaitView.isAnimating)
        {
            [weatherWaitView startAnimating];
        }
    });
}

- (void)hiddenWeatherWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        weatherWaitTitle.hidden = YES;
        if(weatherWaitView.isAnimating)
        {
            [weatherWaitView stopAnimating];
        }
    });
}

#pragma mark - Notification Handler

- (void)receiveSdkManagerNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:SdkDeviceStatusChangedNotification])
    {
        [self loadDeviceStatus];
        [self loadAirDeviceInfo:MainDelegate.curAirQuality];
    }
    else if([notification.name isEqualToString:SdkDeviceOnlineChangedNotification])
    {
        [self checkAirBoxConnectStatus];
    }
}

- (void)weatherUpdateStatus:(NSNotification *)notification
{
    if([notification.name isEqualToString:WeatherStartDownloadNotification])
    {
        [self showWeatherWaitView];
    }
    else if([notification.name isEqualToString:WeatherDownloadedNotification])
    {
        [self hiddenWeatherWaitView];
        NSString *info = notification.object;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([info isEqualToString:kCurrentWeather])
            {
                [self loadCurrentWeatherToScreen];
            }
            else if ([info isEqualToString:kFutureWather])
            {
                [self loadFutureWeatherToScreen];
            }

        });
    }
}


#pragma mark - Observer Management

- (void)registerObserver{
    [NotificationCenter addObserver:self
                           selector:@selector(currentAirDeviceInfo)
                               name:AirDeviceRemovedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(receiveSdkManagerNotification:)
                               name:SdkDeviceOnlineChangedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(receiveSdkManagerNotification:)
                               name:SdkDeviceStatusChangedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(weatherUpdateStatus:)
                               name:WeatherDownloadedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(weatherUpdateStatus:)
                               name:WeatherStartDownloadNotification
                             object:nil];
}

- (void)removeObserver{
    [NotificationCenter removeObserver:self name:AirDeviceRemovedNotification object:nil];
    [NotificationCenter removeObserver:self name:SdkDeviceOnlineChangedNotification object:nil];
    [NotificationCenter removeObserver:self name:SdkDeviceStatusChangedNotification object:nil];
    [NotificationCenter removeObserver:self name:WeatherDownloadedNotification object:nil];
    [NotificationCenter removeObserver:self name:WeatherStartDownloadNotification object:nil];
}

@end
