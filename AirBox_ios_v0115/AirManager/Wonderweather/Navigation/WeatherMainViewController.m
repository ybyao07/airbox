//
//  WeatherMainViewController.m
//  wonderweather
//
//  Created by zhongke on 14-5-21.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#define WIDTH 320/5
#define WeekViewHeight  105
#define TimeViewHeight  143


#import "WeatherMainViewController.h"
#import "AFNetworking.h"
#import "ImageString.h"
#import "ImageSetting.h"
#import "CityManager.h"
//#import "DKLiveBlurView.h"
#import "CityViewController.h"
#import "CustomIndexViewController.h"
#import "AppDelegate.h"
#import "UserLoginedInfo.h"
#import "SettingViewController.h"
#import "CurrentCity.h"

@interface WeatherMainViewController ()
{
    AFHTTPRequestOperation *_operation1;
    AFHTTPRequestOperation *_operation2;
    AFHTTPRequestOperation *_operation3;
    AFHTTPRequestOperation *_operation4;
    AFHTTPRequestOperation *_operation5;
    AFHTTPRequestOperation *_operation6;
    
    IBOutlet UIImageView *minus;// TreeJohn
}

@property (nonatomic) CurrentCityWeather *downloadingWeather;
@property (nonatomic) BOOL currentDownloaded;
@property (nonatomic) BOOL fiveDaysDownloaded;
@property (nonatomic) BOOL todayDaysDownloaded;
@property (nonatomic) BOOL airDownloaded;
@property (nonatomic) BOOL freeslikeDownloaded;
@property (nonatomic) BOOL indexDownloaded;
@property (nonatomic) BOOL animationOK;
@property (nonatomic) BOOL runOK;
@property (copy,nonatomic) NSString *date;
@property (strong,nonatomic) NSMutableArray *transformArray;
@property (strong,nonatomic) NSTimer *timer;
@property (nonatomic) int flag;
//@property (nonatomic,strong) DKLiveBlurView *backgroundView;
@property (nonatomic,assign) NSInteger viewWeekBackgroudNormalColor;
@property (nonatomic,assign) NSInteger viewWeekBackgroudSelectColor;
@property (nonatomic,assign) NSInteger viewTimeBackgroudColor;
@property (nonatomic,assign) NSInteger viewIndexBackgroudColor;
@property (nonatomic,assign) NSInteger indexTitleLabelColor;
@property (nonatomic,assign) NSInteger indexLevelLabelColor;

@end

@implementation WeatherMainViewController

- (void) dealloc
{
    if(_timer.isValid)
    {
        [_timer invalidate];
    }
    _timer = nil;
    
    DDLogFunction();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeAllTimeViewSubViews];//ybyao07-20141113
    [self createTimeView];//ybyao07-20141113
    
    [MobClick beginLogPageView:@"PageOne"];
    //ybyao07
    [_tableView setContentOffset:CGPointMake(0,0) animated:NO];
    //ybyao07
    _settingButton.userInteractionEnabled = YES;
    _autoIndexButton.userInteractionEnabled = YES;
    // refresh only if current city changed
//    if (_weather != [[CityManager sharedManager] currentCityWeather])
    {
        _weather = [[CityManager sharedManager] currentCityWeather];
        [self refresh];
    }
}

-(void)removeAllTimeViewSubViews
{
    for(UIView *view in [_timeView subviews])
    {
        [view removeFromSuperview];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *citylist = [[CityManager sharedManager] currentCityList];
    if ([citylist count] == 0)
    {
        [self addCity];
    }
    _downloadingWeather = [[CurrentCityWeather alloc] init];
    _weather  = [[CityManager sharedManager] currentCityWeather];
    if (_weather == nil)
    {
        _weather = [[CurrentCityWeather alloc] init];
    }
    
    _animationOK = NO;
    // create views
    [self layoutView];
//    [self createTimeView];//ybyao07-20141113
    [self createWeekView];
    [self createIndexView];
    
    // update views
    [self updateWeekView];
    [self updateCurrentWeather];
//    [self updateTimeView];
    [self updateIndexView];
    //下拉刷新
    [self addHeader];
    
    
    [Utility setExclusiveTouchAll:self.view];
    
}

#pragma mark 视图

- (void)layoutView
{
    //判断是不是ios7
    if (IOS7)
    {
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
        self.automaticallyAdjustsScrollViewInsets = NO;
        #endif
    }
    
    _baseView.frame = CGRectMake(0, ADDHEIGH, 320, VIEWHEIGHT);
//    _bgImageView.frame = CGRectMake(0, 0, 320, _baseView.frame.size.height);
//    
//    _backgroundView = [[DKLiveBlurView alloc] initWithFrame:_bgImageView.frame];
//    [_bgImageView addSubview:_backgroundView];
    
    _tableView.frame = CGRectMake(0, 0, 320, _baseView.frame.size.height);

    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    _indexContV = [[IndexContentView alloc] initWithFrame:bounds];
    _indexContV.hidden = YES;
    [self.view addSubview:_indexContV];
    
    [self setbackGroupColor:_weather.weather.temperature];
    
    _tableView.backgroundColor = [UIColor colorWithHex:_viewIndexBackgroudColor alpha:1.0f];

}

- (void)createWeekView
{
    DDLogFunction();
    _viewWeekSuperTop.backgroundColor = [UIColor colorWithHex:_viewWeekBackgroudNormalColor alpha:1.0f];
    [_labelWeather setAdjustsFontSizeToFitWidth:YES];
    for (int i = 0; i < 5; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0+i*320/5, 0, WIDTH, WeekViewHeight)];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WeekViewHeight)];
        [view addSubview:view1];

        UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320/5, WeekViewHeight)];
        selectedImageView.tag = (i + 1) * 11;
        [view addSubview:selectedImageView];
        
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 320/5-1, 10)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.tag = (i + 1) * 111;
        timeLabel.font = [UIFont systemFontOfSize:10];
        [view addSubview:timeLabel];
        
//        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 320/5-1, 15)];
//        dateLabel.textAlignment = NSTextAlignmentCenter;
//        dateLabel.textColor = [UIColor colorWithRed:79/255.f green:77/255.f blue:71/255.f alpha:1  ];
//        dateLabel.backgroundColor = [UIColor clearColor];
//        dateLabel.tag = (i + 1) * 1111;
//        dateLabel.font = [UIFont systemFontOfSize:12];
//        [view addSubview:dateLabel];
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 25, 28, 28)];
        imageView.tag = (i + 1) * 11111;
        [view addSubview:imageView];
        
        UILabel *degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 320/5-1, 11)];
        degreeLabel.backgroundColor = [UIColor clearColor];
        degreeLabel.textAlignment = NSTextAlignmentCenter;
        degreeLabel.textColor = [UIColor whiteColor];
        degreeLabel.tag = (i + 1) * 111111;
        degreeLabel.font = [UIFont systemFontOfSize:11];
        [view addSubview:degreeLabel];
        
        UILabel *windLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 85, 320/5-1 - 4, 20)];
        windLabel.numberOfLines=0;
        windLabel.backgroundColor = [UIColor clearColor];
        windLabel.textAlignment = NSTextAlignmentCenter;
        windLabel.adjustsFontSizeToFitWidth = YES;
        windLabel.tag = (i + 1) * 1111111;
        windLabel.textColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:0.4  ];
        windLabel.font = [UIFont systemFontOfSize:10];
        windLabel.minimumScaleFactor = 0.7;
        [view addSubview:windLabel];
        
        if(i < 4)
        {
            UILabel *splintLine = [[UILabel alloc] initWithFrame:CGRectMake(320/5 - kLineHeight1px, 0, kLineHeight1px, WeekViewHeight)];
            [splintLine setBackgroundColor:[UIColor colorWithHex:0x000000 alpha:0.2f]];
            [view addSubview:splintLine];
        }
        
        [_weekview addSubview:view];
    }
}

-(void)createTimeView
{
    DDLogFunction();
//    for (int i = 0; i< 24; i++)
     for (int i = 0; i< 48; i++)//ybyao07--20141113
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0+i*320/5, 0, WIDTH, TimeViewHeight)];
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, TimeViewHeight)];
        view1.backgroundColor = [UIColor clearColor];
        view1.tag = i + 100;
        [view addSubview:view1];
        view.backgroundColor = [UIColor clearColor];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, TimeViewHeight - 21, 320/5, 11)];
        timeLabel.tag = i + 200;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:11];
        [view addSubview:timeLabel];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 25, 24, 24)];
        imageView.tag = i + 300;
        [view addSubview:imageView];
        
        UILabel *degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 320/5, 15)];
        degreeLabel.backgroundColor = [UIColor clearColor];
        degreeLabel.textAlignment = NSTextAlignmentCenter;
        degreeLabel.font = [UIFont systemFontOfSize:11];
        degreeLabel.tag = i + 400;

        [view addSubview:degreeLabel];
        
        [_timeView addSubview:view];
    
        _tempIndexView = [[TempIndexView alloc] init];
        _viewWeekSuper.backgroundColor = [UIColor colorWithHex:_viewTimeBackgroudColor alpha:1.0f];
        _weekview.backgroundColor = [UIColor clearColor];
        _tempIndexView.backgroundColor = [UIColor clearColor];
        [_timeView addSubview:_tempIndexView];
        
        
        UIImageView *lowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lowimage.png"]];
        lowImageView.tag = i + 600;
        [view addSubview:lowImageView];
        lowImageView.hidden = YES;
        
        UILabel *whiteImageView = [[UILabel alloc] init];
        [whiteImageView setBackgroundColor:[UIColor colorWithHex:0xffffff alpha:0.4f]];
        whiteImageView.tag = i + 700;
        [view addSubview:whiteImageView];
        whiteImageView.hidden = YES;
    }
}
- (void)createIndexView
{
    DDLogFunction();
    _bottomView.backgroundColor = [UIColor colorWithHex:_viewIndexBackgroudColor alpha:1.0f];
    _detailView.backgroundColor = [UIColor clearColor];
    _transformArray = [NSMutableArray array];
    for (int i = 0; i < 10; i ++)
    {
        UIView *view = [_detailView viewWithTag:100 + i + 1];
        [_transformArray addObject:NSStringFromCGAffineTransform(view.transform)];
        view.layer.cornerRadius = 45;
        view.bounds = CGRectMake(0, 0, 90, 90);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(press:)];
        tap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tap];
        [view setHidden:NO];
    }
    
    if (_weather.weatherIndex.count == 0)
    {
        _detailView.hidden = YES;
    }else
    {
        _detailView.hidden = NO;
    }
    
}

- (void)addHeader
{
    DDLogFunction();
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:0.4];
    header.scrollView = _tableView;
    header.frame = CGRectMake(0, -600, 320, 600);

    __weak typeof(self) weakSelf = self;
    header.beginRefreshingBlock = ^(MJRefreshBaseView * refreshView)
    {
        //重新加载数据
        NSString *idString = _weather.city.areaId;
        [weakSelf dataRequest:idString];
        [weakSelf dataRequest1:idString];
        [weakSelf dataRequest2:idString];
        [weakSelf dataRequest3:idString];
        [weakSelf dataRequest4:idString];
        [weakSelf dataRequest5:idString];
    };
    _header = header;
}

#pragma mark  DataRequest网络请求
#pragma mark  json解析


-(void)dataRequest:(NSString *)cityId
{
    DDLogFunction();
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/forecast5/%@",BASEURL,cityId];
    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    DDLogCVerbose(@"%@",requestStr);
    
    _operation1 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    [_operation1 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
      
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
        DDLogCVerbose(@"--->dataRequest response data :%@",dic);
        NSMutableArray *tmpArray = [NSMutableArray array];
//        if (dic && ( ![[dic objectForKey:@"retInfo"] isEqual:[NSNull null]])  && ([[dic objectForKey:@"retInfo"] isEqualToString:@"成功"]))
       if (([[dic objectForKey:@"retCode"] isEqualToString:@"00000"]))//ybyao07
        {
            NSArray *arr = [[NSArray alloc] initWithObjects:@"weather1",@"weather2",@"weather3",@"weather4",@"weather5", nil];

            for (int  i = 0; i<arr.count; i++)
            {
                NSMutableDictionary *dic1 = [[NSMutableDictionary alloc] initWithDictionary:[dic objectForKey:[arr objectAtIndex:i]]];
                WeekEntity *weekEntity = [[WeekEntity alloc] initWithDic:dic1];
                [tmpArray addObject:weekEntity];
            }
        }else
        {
            // server error
        }
        [weakSelf fiveDaysDownloaded:[NSArray arrayWithArray:tmpArray]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogCVerbose(@"forecast5通信失败 %@",@"--->");
        [weakSelf fiveDaysDownloaded:nil];
    }];
    [_operation1 start];
}

-(void)dataRequest1:(NSString *)cityId
{
    DDLogFunction();
    NSString *requestStr;
//    if ([MainDelegate isLanguageEnglish]) {
//                requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/current?city_code=%@&language=en",BASEURL,cityId];
//    }else{
        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/current?city_code=%@&language=zh_CN",BASEURL,cityId];
//    }
    NSURL *url = [NSURL URLWithString:requestStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    _operation2 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    [_operation2 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
     
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
        DDLogCVerbose(@"--->dataRequest1 response data :%@",dic);

        InstantWeather *weather;
//        if ([[dic objectForKey:@"error_info"] isEqualToString:@"success"])
        if ([[dic objectForKey:@"error_info"] isEqualToString:@"success"])//ybyao07
        {
            NSMutableDictionary *weatherDic = [dic objectForKey:@"instant_weather"];
            if (weatherDic)
            {
                // 通知更新盒子主页的室外天气的数据
                [NotificationCenter postNotificationName:WeatherDownloadedNotification object:kCurrentWeather userInfo:weatherDic];
                
                weather = [[InstantWeather alloc] initWithDic:weatherDic];
            }
        } else {//请求失败

        }
        [weakSelf currentDownloaded:weather];
       
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf currentDownloaded:nil];
        DDLogCVerbose(@"current通信失败 %@",@"--->");
    }];
    [_operation2 start];
}

-(void)dataRequest2:(NSString *)cityId
{
    DDLogFunction();
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/weather24?city_code=%@",BASEURL,cityId];
    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    _operation3 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;

    [_operation3 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];

        DDLogCVerbose(@"--->dataRequest2 response data :%@",str);
        NSMutableArray *tmpArray = [NSMutableArray array];
//        if (dic && ( ![[dic objectForKey:@"retInfo"] isEqual:[NSNull null]])  && ([[dic objectForKey:@"retInfo"] isEqualToString:@"成功"]))
         if (([[dic objectForKey:@"retCode"] isEqualToString:@"00000"]))//ybyao07
        {
            NSArray *arr = [[NSArray alloc] initWithArray:[dic objectForKey:@"weather24"]];
            for (id tmp in arr)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tmp];
                Weather24 *weath24 = [[Weather24 alloc] initWithDic:dic];
                [tmpArray addObject:weath24];
            }
        }else
        {
        }
        [weakSelf todayWeatherDownloaded:[NSArray arrayWithArray:tmpArray ]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogCVerbose(@"weather24通信失败 %@",@"--->");
        [weakSelf todayWeatherDownloaded:nil];
    }];
    [_operation3 start];
}

- (void)dataRequest3:(NSString *)cityId
{
    DDLogFunction();
    NSString *requestStr;
    if ([MainDelegate isLanguageEnglish]) {
        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/index?city_code=%@&language=en",BASEURL,cityId];
    }else{
        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/index?city_code=%@&language=zh_CN",BASEURL,cityId];
    }

    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    _operation4 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    [_operation4 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
            DDLogCVerbose(@"--->dataRequest3 response data:%@\n%@",requestStr,str);
        
            NSMutableArray *tmpArray = [NSMutableArray array];
            if (([[dic objectForKey:@"code"] integerValue] == 0))//ybyao07
        {
            NSArray *arr = [[NSArray alloc] initWithArray:[dic objectForKey:@"data"]];
            for (id tmp in arr)
            {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:tmp];
                IndexData *indexData = [[IndexData alloc] initWithDic:dic];
                [tmpArray addObject:indexData];
            }

        }else
        {
            
            
        }
        [weakSelf indexDownloaded:[NSArray arrayWithArray:tmpArray ]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogCVerbose(@"index通信失败 %@",@"--->");
        [weakSelf indexDownloaded:nil];
    }];
    [_operation4 start];
}

- (void)dataRequest4:(NSString *)cityId{
    DDLogFunction();
    NSString *requestStr;
//    if ([MainDelegate isLanguageEnglish]) {
//        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/air?city_code=%@&language=en",BASEURL,cityId];
//    }else{
        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/air?city_code=%@&language=zh_CN",BASEURL,cityId];
//    }

    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *airManagerPM25CacheKey = [NSString stringWithFormat:@"%@:%@",AirManagerPM25Cache,cityId];
    _operation5 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;

    [_operation5 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
        DDLogCVerbose(@"--->dataRequest4 response data: %@",str);
        NSString *air = @"--";
            if ([[dic objectForKey:@"code"] integerValue] == 0)//ybyao07
        {
            if([dic objectForKey:@"data"] && ![[dic objectForKey:@"data"]isEqual:[NSNull null]])
            {
                AirData *airDate = [[AirData alloc] initWithDic:[dic objectForKey:@"data"]];
                air = airDate.pm25;
            // 通知更新盒子主页的pm2.5的数据
                [NotificationCenter postNotificationName:WeatherDownloadedNotification object:kCurrentPM25 userInfo:[dic objectForKey:@"data"]];
                
                [UserDefault setObject:[dic objectForKey:@"data"] forKey:airManagerPM25CacheKey];
                [UserDefault synchronize];
            }
            else
            {
//                [NotificationCenter postNotificationName:WeatherDownloadedNotification object:kCurrentPM25 userInfo:@{@"pm25":@"--"}];
            }
        }
        else{
            
            [weakSelf doAirDownLoadPmFaild:airManagerPM25CacheKey];
        }
        [weakSelf airDownloaded:air];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogCVerbose(@"air通信失败 %@",@"--->");
        [weakSelf airDownloaded:nil];
//         [[weakSelf doAirDownLoadPmFaild:airManagerPM25CacheKey];
        
    }];
    [_operation5 start];
}

- (void)doAirDownLoadPmFaild:(NSString *)airManagerPM25CacheKey
{
    DDLogFunction();
    NSDictionary *dicPM25 = [UserDefault objectForKey:airManagerPM25CacheKey];
    if(dicPM25)
    {
        [NotificationCenter postNotificationName:WeatherDownloadedNotification object:kCurrentPM25 userInfo:dicPM25];
    }
    else
    {
//        [NotificationCenter postNotificationName:WeatherDownloadedNotification object:kCurrentPM25 userInfo:@{@"pm25":@"--"}];
    }
}
- (void)dataRequest5:(NSString *)cityId{
    DDLogFunction();
    NSString *requestStr;
//    if ([MainDelegate isLanguageEnglish]) {
//        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/feelslike?city_code=%@&language=en",BASEURL,cityId];
//    }else{
        requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/feelslike?city_code=%@&language=zh_CN",BASEURL,cityId];
//    }


    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    _operation6 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;

    [_operation6 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
        DDLogCVerbose(@"--->dataRequest5 response data: %@\n%@",requestStr,str);
        
        NSString *freesLike;
//        if (dic && ( ![[dic objectForKey:@"retInfo"] isEqual:[NSNull null]])  && ([[dic objectForKey:@"retInfo"] isEqualToString:@"成功"]))
              if (([[dic objectForKey:@"retCode"] isEqualToString:@"00000"]))//ybyao07
        {
            freesLike = [[NSString alloc] initWithString:[dic objectForKey:@"freesLike"]];
        }else
        {
            
            
        }
        [weakSelf freeslikeDownloaded:freesLike];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogCVerbose(@"feelslike通信失败 %@",@"--->");
        [weakSelf freeslikeDownloaded:nil];
    }];
    [_operation6 start];
}

#pragma mark - View updata

-(void)updateWeekView
{
    DDLogFunction();
    _viewWeekSuperTop.backgroundColor = [UIColor colorWithHex:_viewWeekBackgroudNormalColor alpha:1.0f];
    
    for (int i = 0; i < 5; i++) {
        
        
        if(_weather.weather.weather != nil || [_weather.weather.weather length] > 0)
        {
            _splitLineWeather.backgroundColor = [UIColor whiteColor];
            [_splitLineWeather setFrame:CGRectMake(_splitLineWeather.frame.origin.x,
                                                   _splitLineWeather.frame.origin.y,
                                                   kLineHeight1px,_splitLineWeather.frame.size.height)];
            _splitLineWeather.hidden = NO;
        }
        else
        {
            _splitLineWeather.hidden = YES;
        }
        
        WeekEntity *entity;
        if ([_weather.fiveDaysWeathers count] > 0)
        {
            entity = [_weather.fiveDaysWeathers objectAtIndex:i];
            _weekview.hidden = NO;
        }else
        {
            _weekview.hidden = YES;
            _tempLabel.text = @"--";
            _labelWeather.text = @"--";
            return ;
        }
        
        if (_weather.weather.temperature == nil)
        {
            _tempLabel.text = @"--";
        }
        if(_weather.weather.weather == nil)
        {
            _labelWeather.text = @"--";
        }
        else
        {
            /*-----------------------ybyao-----------------*/
            _labelWeather.text =NSLocalizedString( _weather.weather.weather,@"WeatherMainViewController1.m");
        }
        

        UIImageView *selectedImageView = (UIImageView *)[_weekview viewWithTag:(i + 1) * 11];
 
        UILabel *timeLabel = (UILabel *)[_weekview viewWithTag:(i + 1) * 111];
      /**-----------------------------ybyao--------------------------------**/
        NSString* strWeek= [NSString stringWithFormat:@"%@" , [entity.week stringByReplacingOccurrencesOfString:@"星期" withString:(@"周")] ];
//        timeLabel.text = [NSString stringWithFormat:@"%@ %@", [entity.week stringByReplacingOccurrencesOfString:@"星期" withString:NSLocalizedString(@"周",@"WeatherMainViewController.m")] ,[[entity.date substringFromIndex:5] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]];
        NSString *textStr = NSLocalizedString(strWeek,@"WeatherMainViewController.m");
        NSMutableString *str = [NSMutableString stringWithString:textStr];
        NSString *hello = [NSString stringWithFormat:@" %@",[[entity.date substringFromIndex:5] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]];
        [str appendString:hello];
        NSString *test = [[NSString alloc] initWithString:str];
        timeLabel.text = test ;
          /**-----------------------------ybyao--------------------------------**/
        
//        UILabel *dateLabel = (UILabel *)[_weekview viewWithTag:(i + 1) * 1111];
//        dateLabel.text = [entity.date substringFromIndex:5];
        
        UIImageView *imageView = (UIImageView *)[_weekview viewWithTag:(i + 1) * 11111];
        NSString *imageStr = [ImageString getImageString:NSLocalizedString(entity.day_weather, ) ];

        imageView.image = [UIImage imageNamed:imageStr];
        
        UILabel *degreeLabel = (UILabel *)[_weekview viewWithTag:(i + 1) * 111111];
        degreeLabel.text = [NSString stringWithFormat:@"%@~%@°",entity.night_temp,entity.day_temp];
        
        UILabel *windLabel = (UILabel *)[_weekview viewWithTag:(i + 1) * 1111111];
        if ([entity.day_wind_direction isEqualToString:NSLocalizedString(@"无持续风向", ) ])//ybyao
        {
//            windLabel.text = entity.day_wind;//ybyao
            /*--------------ybyao------------*/
            windLabel.text = NSLocalizedString(entity.day_wind,@"WeatherMainViewController.m");
        }else
        {
        
            NSString *textStr = NSLocalizedString(entity.day_wind_direction,@"WeatherMainViewController.m");
            NSMutableString *str = [NSMutableString stringWithString:textStr];
            /*--------------ybyao---------*/
            NSString *level ;
            if ([MainDelegate isLanguageEnglish]) {
             level =  [NSString stringWithFormat:@"\n%@", [ NSLocalizedString(entity.day_wind, )  stringByReplacingOccurrencesOfString:@"级" withString:NSLocalizedString(@"级",@"WeatherMainViewController.m")] ];
            }else{
            level =  [NSString stringWithFormat:@"%@", [ NSLocalizedString(entity.day_wind, )  stringByReplacingOccurrencesOfString:@"级" withString:NSLocalizedString(@"级",@"WeatherMainViewController.m")] ];
            }
            [str appendString:level];
            NSString *test = [[NSString alloc] initWithString:str];
//            windLabel.text = [NSString stringWithFormat:@"%@%@",entity.day_wind_direction,entity.day_wind];
            windLabel.text = test;
        }
        
        NSDate *date = [NSDate date];
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [f stringFromDate:date];
        
        if ([dateStr isEqualToString:entity.date])
        {
            /*------------------ybyao-----------------------*/
            timeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"今天",@"WeatherMainViewController.m") ,[[entity.date substringFromIndex:5] stringByReplacingOccurrencesOfString:@"-" withString:@"/"]];
            selectedImageView.backgroundColor = [UIColor colorWithHex:_viewWeekBackgroudSelectColor alpha:1.0f];
            selectedImageView.alpha = 1;
            NSString *lightImageStr = [ImageString getMainImageString:NSLocalizedString(entity.day_weather, ) ];
            imageView.image = [UIImage imageNamed:lightImageStr];
            _tempLabel.text = [NSString stringWithFormat:@"%@~%@°",entity.night_temp,entity.day_temp];
        }
        else
        {
            selectedImageView.backgroundColor = [UIColor colorWithHex:_viewWeekBackgroudNormalColor alpha:1.0f];
            imageView.image = [UIImage imageNamed:imageStr];
        }
    }
    
}

- (NSComparisonResult)compareDateString:(Weather24 *)weath24
{
    DDLogFunction();
    NSComparisonResult result = [self.date compare:weath24.date];
    return result;
}

- (void)updateTimeView {
    
    DDLogFunction();
    _viewWeekSuper.backgroundColor = [UIColor colorWithHex:_viewTimeBackgroudColor alpha:1.0f];
    
    NSMutableArray *array;
    NSMutableArray *degreeArray;
    Weather24 *weath24;
    
    int highTemp = -173;
    int lowTemp = 100;
    int selectedCount = -1;
    
    if ([_weather.todayWeathers count] > 0)
    {
        array = [NSMutableArray arrayWithArray:_weather.todayWeathers];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        [array sortUsingDescriptors:sortDescriptors];
        
        degreeArray = [NSMutableArray arrayWithArray:_weather.todayWeathers];
//        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"temperature" ascending:NO];
//        NSArray *sortDescriptors2 = [[NSArray alloc] initWithObjects:&sortDescriptor2 count:1];
//        [degreeArray sortUsingDescriptors:sortDescriptors2];
//        
//        weath24 = [degreeArray firstObject];
//        highTemp = [weath24.temperature floatValue];
//        
//        weath24 = [degreeArray lastObject];
//        lowTemp = [weath24.temperature floatValue];
//        _timeView.hidden = NO;

        for (int i = 0; i < [degreeArray count]; i++)
        {
            weath24 = [degreeArray objectAtIndex:i];
            if([weath24.temperature floatValue] > highTemp)
            {
                highTemp = [weath24.temperature floatValue];
            }
            if([weath24.temperature floatValue] < lowTemp)
            {
                lowTemp = [weath24.temperature floatValue];
            }
        }
        
         _timeView.hidden = NO;
        
    }else
    {
        _timeView.hidden = YES;
        return ;
    }
    
    NSInteger count = array.count - 1;
    
    NSMutableArray *yPointArray = [NSMutableArray array];
    
//    for (int i = 0; i< 24; i++)//ybyao07 ---20141113
    for (int i = 0; i< array.count; i++)
    {
        if (count <0) break;

        weath24 = [array objectAtIndex:count];
        
        UIView *view1 = [_timeView viewWithTag:i + 100];
        
        UILabel *timeLabel = (UILabel *)[_timeView viewWithTag:i + 200];
        
        int  a = 0,y = 0;
        
        if ((highTemp - lowTemp) <= 2)
        {
            a = ([weath24.temperature floatValue] - lowTemp) / (highTemp - lowTemp) * (_timeView.frame.size.height - 130) + 100;
            y = _timeView.frame.size.height - a;
            
        }else
        {
            a = ([weath24.temperature floatValue] - lowTemp) / (highTemp - lowTemp) * (_timeView.frame.size.height - 95) + 90;
            y = _timeView.frame.size.height - a;
        }
        
//        DDLogCVerbose(@"%d",y);
        
        UIImageView *imageView = (UIImageView *)[_timeView viewWithTag:i + 300];
        imageView.image = nil;
        imageView.frame = CGRectMake(21, y, 22, 22);
        NSString *imageStr = [ImageString getBlueImageString:weath24.icon];
        imageView.image = [UIImage imageNamed:imageStr];

        
        
        UILabel *degreeLabel = (UILabel *)[_timeView viewWithTag:i + 400];
        degreeLabel.text = @"--";
        degreeLabel.text = [NSString stringWithFormat:@" %@°",weath24.temperature];
        degreeLabel.textAlignment = NSTextAlignmentCenter;
        degreeLabel.frame = CGRectMake(0, y + imageView.frame.size.height + 6, 320/5, 15);
        
        
        UIImageView *heightImageView = (UIImageView *)[_timeView viewWithTag:i + 500];
        
        UIImageView *lowImageView = (UIImageView *)[_timeView viewWithTag:i + 600];
        
        UIImageView *whiteImageView = (UIImageView *)[_timeView viewWithTag:i + 700];

        
        y = y + imageView.frame.size.height + degreeLabel.frame.size.height + 12;
        [yPointArray addObject:[NSString stringWithFormat:@"%d",y]];
        
        
        NSDate *date = [NSDate date];
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"HH"];
        NSString *dateStr = [f stringFromDate:date];
        int dataTmp = [dateStr intValue];

        if( i < dataTmp)
        {
            heightImageView.hidden = YES;
            whiteImageView.hidden = YES;
            lowImageView.hidden = YES;
            
            if (i<10)
            {
                timeLabel.text = [NSString stringWithFormat:@"0%d:00",i];
            }else
            {
                timeLabel.text = [NSString stringWithFormat:@"%d:00",i];
            }
            
            timeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:0.4f];
            degreeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:0.4f];
            imageView.alpha = 0.4;
            
        }
        else if (i == dataTmp)
        {
            selectedCount = i;
            /*-------------------ybyao-------------------------*/
            timeLabel.text = NSLocalizedString(@"现在",@"WeatherMainViewController.m");
            timeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0f];
            degreeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0f];
           
            if (a != 0)
            {
                heightImageView.hidden = NO;
                heightImageView.frame = CGRectMake(32 + 64 * i - 4, y - 4, 8, 8);
                
                whiteImageView.hidden = NO;
                whiteImageView.frame = CGRectMake(32  - 0.5, y - 4, kLineHeight1px, TimeViewHeight - y - 24);
                lowImageView.hidden = YES;
                lowImageView.frame = CGRectMake(32 - 5, 131 - 5, 8, 8);
            }
           
             imageView.alpha =1.0f;
            [_timeView setContentOffset:CGPointMake(view1.frame.size.width * (i - 1) , view1.frame.origin.y)];
            imageView.alpha = 1;
            
        }else
        {
            heightImageView.hidden = YES;
            whiteImageView.hidden = YES;
            lowImageView.hidden = YES;
            
            if (i<10)
            {
                timeLabel.text = [NSString stringWithFormat:@"0%d:00",i];
            }else
            {
                timeLabel.text = [NSString stringWithFormat:@"%d:00",i];
            }
            
            timeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0f];;
            degreeLabel.textColor = [UIColor colorWithHex:0xffffff alpha:1.0f];
            imageView.alpha =1.0f;

        }
        count --;
    }
    _tempIndexView.selectedCount = selectedCount;
    _tempIndexView.arry = yPointArray;
//    _tempIndexView.frame = CGRectMake(0 , 0, 320 * 24 / 5, 131);
     _tempIndexView.frame = CGRectMake(0 , 0, 320 * [array count] / 5, 131);//ybyao07--20141113
    [_tempIndexView setNeedsDisplay];

    
    NSInteger countTmp = [_weather.todayWeathers count];
//    _timeView.contentSize = CGSizeMake(countTmp*320/5, TimeViewHeight);
    _timeView.contentSize = CGSizeMake(countTmp*320/5, TimeViewHeight);

}

- (void)updateCurrentWeather
{
    DDLogFunction();
    NSDate *date = [NSDate date];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd"];
    NSString *dateStr = [f stringFromDate:date];
    /*------------------------------------ybyao---------------------*/
    _city_name.text =[NSString stringWithFormat:@"%@ %@",dateStr, NSLocalizedString([MainDelegate cityNameInternationalized:_weather.city.cityName],@"WeatherMainViewController.m")? NSLocalizedString([MainDelegate cityNameInternationalized:_weather.city.cityName],@"WeatherMainViewController.m"): @"--"];
    
    if (_weather.weather.humidy == nil ||
        [_weather.weather.humidy isEqualToString:@""] ||
        [_weather.weather.humidy isEqualToString:@"?"] ||
        [_weather.weather.humidy isEqualToString:@"未知"])
    {
        _humidyLabel.text = @"--";
        [_tmpDangwei setHidden:YES];
    }else
    {
        NSString *humidStr = [NSString stringWithFormat:@"%@",_weather.weather.humidy];
        _humidyLabel.text = humidStr;
        CGSize mySize = [_humidyLabel.text  sizeWithFont:[UIFont systemFontOfSize:24] constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:_humidyLabel.lineBreakMode];
        _humidyLabel.frame = CGRectMake(_humidyLabel.frame.origin.x, _humidyLabel.frame.origin.y, mySize.width, _humidyLabel.frame.size.height);

        [_tmpDangwei setHidden:NO];
        [_tmpDangwei setFrame:CGRectMake(_humidyLabel.frame.origin.x + mySize.width, _tmpDangwei.frame.origin.y, _tmpDangwei.frame.size.width, _tmpDangwei.frame.size.height)];
    }
    
    if (_weather.weather.wind_direction == nil||
        [_weather.weather.wind_direction isEqualToString:@"?"]||
        [_weather.weather.wind_direction isEqualToString:@"无确定风向"])
    {
        /*----------------------ybyao-----------------*/
        _windDre.text = NSLocalizedString(@"风力",@"WeatherMainViewController1.m");
        CGSize mySize = [_windDre.text sizeWithFont:_windDre.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:_windDre.lineBreakMode];
        _windDre.frame = CGRectMake(_windDre.frame.origin.x, _windDre.frame.origin.y, mySize.width, _windDre.frame.size.height);
        [_windDre sizeToFit];
        _windRank.text = @"--";
        [_lebalFengLiDangwei setHidden:YES];
    }else
    {
        /*------------------------ybyao---------------*/
        _windDre.text = NSLocalizedString(_weather.weather.wind_direction,@"WeatherMainViewController1.m");
        CGSize mySize = [_weather.weather.wind_direction sizeWithFont:_windDre.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:_windDre.lineBreakMode];
        _windDre.frame = CGRectMake(_windDre.frame.origin.x, _windDre.frame.origin.y, mySize.width, _windDre.frame.size.height);
        [_windDre sizeToFit];

        NSString *wind = [NSString stringWithFormat:@"%d",[_weather.weather.wind integerValue]];
        mySize = [wind sizeWithFont:_windRank.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:_windRank.lineBreakMode];
         /*------------------------ybyao---------------*/
        if ([_weather.weather.wind integerValue] == 0) {
            _windRank.text = NSLocalizedString(@"无风",@"WeatherMainViewController1.m");
            if ([MainDelegate isLanguageEnglish]) {
                _windRank.frame = CGRectMake(_windRank.frame.origin.x, _windRank.frame.origin.y, mySize.width+20, _windRank.frame.size.height);
            }else{
            _windRank.frame = CGRectMake(_windRank.frame.origin.x, _windRank.frame.origin.y, mySize.width+10, _windRank.frame.size.height);
            }
            [_windRank setAdjustsFontSizeToFitWidth:YES];
                [_lebalFengLiDangwei setHidden:YES];
        }else{
        _windRank.text = NSLocalizedString(wind,@"WeatherMainViewController1.m");
         _windRank.frame = CGRectMake(_windRank.frame.origin.x, _windRank.frame.origin.y, mySize.width, _windRank.frame.size.height);


        [_lebalFengLiDangwei setHidden:NO];
        [_lebalFengLiDangwei setFrame:CGRectMake(_windDre.frame.origin.x + mySize.width, _lebalFengLiDangwei.frame.origin.y, _lebalFengLiDangwei.frame.size.width, _lebalFengLiDangwei.frame.size.height)];
        }
    }
    
    
    _qualityRank.text = _weather.air ? _weather.air : @"--";
    CGSize mySize2 = [_qualityRank.text sizeWithFont:_qualityRank.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:_qualityRank.lineBreakMode];
    _qualityRank.frame = CGRectMake(_qualityRank.frame.origin.x, _qualityRank.frame.origin.y, mySize2.width, _qualityRank.frame.size.height);

    _tempQuality.frame = CGRectMake(_qualityRank.frame.origin.x + _qualityRank.frame.size.width + 3, _tempQuality.frame.origin.y, _tempQuality.frame.size.width, _tempQuality.frame.size.height);

    if (_qualityRank.text == nil||[_qualityRank.text isEqualToString:@""] || [_qualityRank.text isEqualToString:@"--"])
    {
        _tempQuality.text = @"";
    }else
    {
        int count = [_qualityRank.text intValue];
        /*------------------------ybyao------------------------*/
        if (count < 50) {
            _tempQuality.text = NSLocalizedString(@"优良",@"WeatherMainViewController1.m");
        } else if (count < 100 && count >= 50) {
            _tempQuality.text = NSLocalizedString(@"良好",@"WeatherMainViewController1.m");
        }else if (count < 150 && count >= 100) {
            _tempQuality.text = NSLocalizedString(@"轻度污染",@"WeatherMainViewController1.m");
        } else if (count < 200 && count >= 150) {
            _tempQuality.text = NSLocalizedString(@"中度污染",@"WeatherMainViewController1.m");
        } else if (count < 300 && count >= 200) {
            _tempQuality.text =NSLocalizedString( @"重度污染",@"WeatherMainViewController1.m");
        } else {
            _tempQuality.text = NSLocalizedString(@"严重污染",@"WeatherMainViewController1.m");
        }
    }
    [_tempQuality sizeToFit];

    if (_weather.freesLike == nil)
    {
       // _freeslikeLable.text = nil;
        _freeslikeLable.text = @"--";//ybyao07-20141112

    }else
    {
        if([_weather.freesLike intValue] == 0)
        {
            _weather.freesLike = @"0";
        }
        _freeslikeLable.text = [NSString stringWithFormat:@"%@°",_weather.freesLike];
    }
    
    NSString *imageStr = [ImageString getMainImageString:NSLocalizedString(_weather.weather.weather, ) ];
    NSString *backroundStr = [ImageString getBackroudImageString:_weather.weather.temperature];
    _weather_imageView.image = [UIImage imageNamed:imageStr];
    
    //    _bgImageView.image = [UIImage imageNamed:backroundStr];
//    _backgroundView.originalImage = [[UIImage imageNamed:backroundStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //    _backgroundView.originalImage = [UIImage imageNamed:@"bg1.jpg"];
    [_topView setImage:[[UIImage imageNamed:backroundStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0]];
    
    NSString *temperature = _weather.weather.temperature;
    if (_weather.weather.temperature == nil)
    {
        _digilImageView.hidden = YES;
        _first_digil.image = nil;
        _second_digil.image = nil;
    }else{
        
//        if (temperature.intValue >= 0)
//        {
        
            NSString *tempeDigit1 = [NSString stringWithFormat:@"digit%d", (int)fabs(temperature.intValue) / 10 % 10];
            NSString *tempeDigit2 = [NSString stringWithFormat:@"digit%d", (int)fabs(temperature.intValue) % 10];
            _first_digil.image = [UIImage imageNamed:tempeDigit1];
            _second_digil.image = [UIImage imageNamed:tempeDigit2];
            _digilImageView.hidden = NO;
            minus.hidden = YES;
        //ybyao07
        if (temperature.integerValue == 0) {
            _first_digil.hidden = YES;
            minus.hidden = YES;
        }
            // TreeJohn
            if (temperature.intValue < 0) {
                minus.hidden = NO;
            }
    }
}

- (void)updateIndexView
{
    
    DDLogFunction();
    _bottomView.backgroundColor = [UIColor colorWithHex:_viewIndexBackgroudColor alpha:1.0f];
    
    _tableView.backgroundColor = [UIColor colorWithHex:_viewIndexBackgroudColor alpha:1.0f];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *nameArray;
    if ([userDefaults objectForKey:@"selectIndexArray"])
    {
        nameArray = [userDefaults objectForKey:@"selectIndexArray"];
    }else
    {
        nameArray = @[@"雨伞指数",@"感冒指数",
                      @"逛街指数",@"舒适度指数",
                      @"穿衣指数",@"旅游指数",
                      @"运动指数",@"空调开启指数",
                      @"紫外线强度指数"];
    }
    
    NSMutableArray *newIndexArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < nameArray.count; i ++)
    {
        IndexData *indeDataTmp = [self getIndexDataWithName:[nameArray objectAtIndex:i]];
        if(indeDataTmp)
        {
            [newIndexArray addObject:indeDataTmp];
        }
        else
        {
             [newIndexArray addObject:[[IndexData alloc] initWithName:[nameArray objectAtIndex:i]]];
        }

    }
    _weather.weatherIndex = [NSArray arrayWithArray:newIndexArray];

    for (int i = 0; i < _weather.weatherIndex.count; i ++)
    {
        UIView *view = [_detailView viewWithTag:100 + i + 1];
        [view setBackgroundColor:[UIColor clearColor]];
        IndexData *indexData = [_weather.weatherIndex objectAtIndex:i];
        UIImageView *imageView = (UIImageView *)[view viewWithTag:1];
        imageView.image = [UIImage imageNamed:[ImageString getIndexImageStr:indexData.name]];
        [imageView setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//        [view setHidden:NO];
      
        UILabel *titleLabel = (UILabel *)[view viewWithTag:2];
/*------------------------------ybyao--------------------*/
        if ([indexData.name isEqualToString:@"紫外线强度指数"])
        {
            titleLabel.text =NSLocalizedString(@"紫外线指数",@"WeatherMainViewController1.m");
        }
        else if([indexData.name isEqualToString:@"空调开启指数"])
        {
            titleLabel.text = NSLocalizedString(@"空调指数",@"WeatherMainViewController1.m");
        }
        else if([indexData.name isEqualToString:@"空气污染扩散条件指数"])
        {
            titleLabel.text = NSLocalizedString(@"污染扩散指数",@"WeatherMainViewController1.m");
        }
        else
        {
            titleLabel.text = NSLocalizedString(indexData.name,@"WeatherMainViewController1.m");
        }
        [titleLabel setFrame:CGRectMake(3, 43, view.frame.size.width-6, 15)];
        [titleLabel setFont:[UIFont systemFontOfSize:12]];
        [titleLabel setTextColor:[UIColor colorWithHex:_indexTitleLabelColor alpha:1.0f]];
         
        
        UILabel *levelLabel = (UILabel *)[view viewWithTag:3];
//        CGRect rect;
//        float fontFloat;
//        if ([indexData.level length] > 4)
//        {
//            rect = CGRectMake(18, 54, 55, 45);
//            fontFloat = 12.f;
//        }else
//        {
//            rect = CGRectMake(5, 66, 80, 15);
//            fontFloat = 14.f;
//        }
        /*-----------------ybyao---------------*/
        levelLabel.text = NSLocalizedString(indexData.level,@"WeatherMainViewController1.m");//ybyao
        if ([MainDelegate isLanguageEnglish]) {
            [levelLabel setFrame:CGRectMake(10, 54, view.frame.size.width-20, 30)];
            [levelLabel setFont:[UIFont systemFontOfSize:9]];
            levelLabel.numberOfLines=0;
            levelLabel.lineBreakMode=NSLineBreakByWordWrapping;
        }else{
        [levelLabel setFrame:CGRectMake(0, 63, view.frame.size.width, 12)];
        [levelLabel setFont:[UIFont systemFontOfSize:12]];
        }
        [levelLabel setTextColor:[UIColor colorWithHex:_indexLevelLabelColor alpha:1.0f]];
//        levelLabel.frame = rect;
//        levelLabel.font = [UIFont systemFontOfSize:fontFloat];
    }
    
    [_splitLineView setBackgroundColor:[UIColor colorWithHex:0x000000 alpha:0.2f]];
    [_splitLineView setFrame:CGRectMake(_splitLineView.frame.origin.x,
                                        _splitLineView.frame.origin.y,
                                        _splitLineView.frame.size.width,kLineHeight1px)];
}

- (IndexData *)getIndexDataWithName:(NSString *)name
{
    for (IndexData *indexData in _weather.weatherIndex)
    {
        if ([indexData.name isEqualToString:name])
        {
            return indexData;
        }
    }

    return nil;
}
#pragma mark TableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.contentView addSubview:_cellView];
        
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1074.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addCity
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        CurrentCityWeather *currentCityWeather = [[CityManager sharedManager] currentCityForID:kCityIDBeijing areaName:kCityNameBeijing];
        if (currentCityWeather == nil)
        {
            currentCityWeather = [[CurrentCityWeather alloc] init];
            
            CurrentCity *city = [[CurrentCity alloc] init];
            city.cityName = kCityNameBeijing;
            city.areaId = kCityIDBeijing;
            currentCityWeather.city = city;
            [[CityManager sharedManager] addCity:currentCityWeather];
        }
        [[CityManager sharedManager] changeCurrentCity:currentCityWeather];
        return;
    }
    
    if (![[CityManager sharedManager] hasCapacityForNewCity]) {
        /*------------------------------ybyao-----------------------*/
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示",@"WeatherMainViewController1.m")
                                                           message:NSLocalizedString(@"最多添加9个城市",@"WeatherMainViewController1.m")
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"取消",@"WeatherMainViewController1.m")
                                                 otherButtonTitles:nil];
        [pwdAlert show];
        return;
    }
    
    CityViewController *cityVC = [[CityViewController alloc] init];
    cityVC.citySelectedProtocol =  self;
    cityVC.fromDeviceBind = NO;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cityVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navController.navigationBar.translucent = NO;
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
    
    //    [self.navigationController pushViewController:cityVC animated:YES];
}

#pragma mark - shareList CallBack

- (IBAction)sharebutton:(id)sender
{
    DDLogFunction();
//    NSString *loginID =  MainDelegate.loginedInfo.loginID ;
//    NSString *loginPwd = MainDelegate.loginedInfo.loginPwd ;
//    
//    if((loginID != nil && [loginID length] > 0) &&
//       (loginPwd != nil && [loginPwd length] > 0)&& [MainDelegate.loginedInfo.arrUserBindedDevice count]>0)
     ((UIButton *)sender).userInteractionEnabled = NO;// ybyao07
    {
        SettingViewController *setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        [self.navigationController pushViewController:setting animated:YES];
    }
//    else
//    {
//        CityViewController *cityVC = [[CityViewController alloc] init];
//        cityVC.citySelectedProtocol =  self;
//        cityVC.fromDeviceBind = NO;
//        
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:cityVC];
//        navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        navController.navigationBar.translucent = NO;
//        navController.navigationBarHidden = YES;
//        [self presentViewController:navController animated:YES completion:nil];
//        
//        //    [self.navigationController pushViewController:cityVC animated:YES];
//    }
}


#pragma mark - callback

- (IBAction)Back:(id)sender
{
    DDLogFunction();
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)press:(id)sender
{
    DDLogFunction();
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    int tmp = [tap view].tag - 100;
    _indexContV.hidden = NO;
    IndexData *indexData = [_weather.weatherIndex objectAtIndex:tmp - 1];
    if ([indexData isKindOfClass:[NSNull class]])
    {
        return;
    }
    [_indexContV updateContentView:indexData];
}

- (void)citySelected:(CurrentCity *)city
{
    DDLogFunction();
    if (city == nil) return;
    CurrentCityWeather *currentCityWeather = [[CityManager sharedManager] currentCityForID:city.areaId areaName:city.cityName];
    if (currentCityWeather == nil)
    {
        currentCityWeather = [[CurrentCityWeather alloc] init];
        currentCityWeather.city = city;
        [[CityManager sharedManager] addCity:currentCityWeather];
    }
    
    _weather = currentCityWeather;
    [[CityManager sharedManager] changeCurrentCity:_weather];
    [self refresh];
}

- (void)currentDownloaded:(InstantWeather *)weather
{
    DDLogFunction();
    _currentDownloaded = YES;
    if (weather != nil)
    {
        _downloadingWeather.weather = weather;
    }
    [self checkDownloaded];
}

- (void)fiveDaysDownloaded:(NSArray *)fiveDaysWeather
{
    DDLogFunction();
    _fiveDaysDownloaded = YES;
    if (fiveDaysWeather != nil)
    {
        _downloadingWeather.fiveDaysWeathers = fiveDaysWeather;
    }
    [self checkDownloaded];
}

- (void)todayWeatherDownloaded:(NSArray *)todayWeathers
{
    DDLogFunction();
    _todayDaysDownloaded = YES;

    if (todayWeathers != nil)
    {
        _downloadingWeather.todayWeathers = todayWeathers;
    }
    [self checkDownloaded];
}

- (void)airDownloaded:(NSString *)air
{
    DDLogFunction();
    _airDownloaded = YES;
    if (air != nil)
    {
        _downloadingWeather.air = air;
    }
    [self checkDownloaded];
}

- (void)freeslikeDownloaded:(NSString *)freeslike
{
    DDLogFunction();
    _freeslikeDownloaded = YES;
    if (freeslike != nil)
    {
        _downloadingWeather.freesLike = freeslike;
    }
    [self checkDownloaded];
}

- (void)indexDownloaded:(NSArray *)weatherIndexes
{
    DDLogFunction();
    _indexDownloaded = YES;
    if (weatherIndexes != nil)
    {
        _downloadingWeather.weatherIndex = weatherIndexes;
    }
    [self checkDownloaded];
}


- (void)checkDownloaded
{
    DDLogFunction();
    DDLogCVerbose(@"%d%d%d%d%d%d",_currentDownloaded,_fiveDaysDownloaded,_todayDaysDownloaded,_airDownloaded,_freeslikeDownloaded,_indexDownloaded);
    if (_currentDownloaded
        && _fiveDaysDownloaded
        && _todayDaysDownloaded
        && _airDownloaded
        && _freeslikeDownloaded
        && _indexDownloaded
        )
    {
        _weather.weather = _downloadingWeather.weather;
        _weather.fiveDaysWeathers = _downloadingWeather.fiveDaysWeathers;
        _weather.todayWeathers = _downloadingWeather.todayWeathers;
        _weather.air = _downloadingWeather.air;
        _weather.weatherIndex = _downloadingWeather.weatherIndex;
        _weather.freesLike = _downloadingWeather.freesLike;
        //_weather.todayWeathers = nil;
        if (_weather.todayWeathers == nil || (_weather.todayWeathers != nil && _weather.todayWeathers.count <= 0 ))
        {
//            NSMutableArray *tmpTodayWeathers = [NSMutableArray array];
            int  high = 0, low = 0;
            @try
            {
                WeekEntity *today = [_weather.todayWeathers objectAtIndex:1];
                high = [today.day_temp intValue];
            } @catch (NSException *exception)
            {
            } @finally
            {
            }

            @try
            {
                WeekEntity *today = [_weather.todayWeathers objectAtIndex:1];
                low = [today.night_temp intValue];
            } @catch (NSException *exception)
            {
            } @finally
            {
            }
        }
        
       //判断 当天 和 5天当天最高最低温度
        if ([_weather.fiveDaysWeathers count] > 0)
        {
            WeekEntity *entity;
            int i = 0;
            NSMutableArray *arr = [NSMutableArray array];
            
            for (i = 0; i < 5; i++)
            {
                NSDate *date = [NSDate date];
                NSDateFormatter *f = [[NSDateFormatter alloc] init];
                [f setDateFormat:@"yyyy-MM-dd"];
                NSString *dateStr = [f stringFromDate:date];
            
                entity = [_weather.fiveDaysWeathers objectAtIndex:i];

                if ([dateStr isEqualToString:entity.date])
                {
                    int tmpCurrentTemp = -9999;
                    int tmpLowestTemp = -9999;
                    int tmpHighestTemp = -9999;
                    @try {
                        if ([_weather.weather.temperature isEqualToString:@"?"]||
                            [_weather.weather.temperature isEqualToString:@"未知"]||
                            _weather.weather.temperature == nil)
                        {
                            _weather.weather.temperature = nil;
                        }else
                        {
                            tmpCurrentTemp = _weather.weather.temperature.intValue;
                        }
                    }@catch (NSException *exception) {
                    } @finally {
                    }
                    
                    if (tmpCurrentTemp != -9999)
                    {
                        @try
                        {
                            tmpLowestTemp = entity.night_temp.intValue;
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                        
                        @try
                        {
                            tmpHighestTemp = entity.day_temp.intValue;
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                        
                        @try {
                            if (tmpHighestTemp == -9999 || tmpCurrentTemp > tmpHighestTemp)
                            {
                                tmpHighestTemp = tmpCurrentTemp;
                            } else if (tmpLowestTemp == -9999 || tmpLowestTemp > tmpCurrentTemp)
                            {
                                tmpLowestTemp = tmpCurrentTemp;
                            }
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                        
                        entity.day_temp = [NSString stringWithFormat:@"%d",tmpHighestTemp];
                        entity.night_temp = [NSString stringWithFormat:@"%d",tmpLowestTemp];
                    }
                    [arr addObject:entity];

                }
                else
                {
                    [arr addObject:entity];
                }
            }
            _weather.fiveDaysWeathers = [NSArray arrayWithArray:arr];
        }
        
        if (_weather.weatherIndex.count == 0)
        {
            _detailView.hidden = YES;
        }else
        {
            _detailView.hidden = NO;
            _runOK = YES;
        }
        
        [self setbackGroupColor:_weather.weather.temperature];
        [self updateWeekView];
        [self updateCurrentWeather];
        [self updateTimeView];
        [self updateIndexView];
        [_header endRefreshing];
        _currentDownloaded = NO;
        _fiveDaysDownloaded = NO;
        _todayDaysDownloaded = NO;
        _airDownloaded = NO;
        _indexDownloaded = NO;
        _freeslikeDownloaded = NO;
        _downloadingWeather = [[CurrentCityWeather alloc] init];
        [[CityManager sharedManager] save];
    }
}

- (void)setbackGroupColor:(NSString *)day_temperature
{
    DDLogFunction();
    _viewWeekBackgroudNormalColor = 0x7ec13d;
    _viewWeekBackgroudSelectColor = 0x92db47;
    _viewTimeBackgroudColor = 0x62ad35;
    _viewIndexBackgroudColor = 0x4fa12a;
    _indexTitleLabelColor = 0x4fa12a;
    _indexLevelLabelColor = 0x237307;
    
    if(day_temperature != nil && [day_temperature length] > 0)
    {
        NSInteger temperature = [day_temperature integerValue];
        if(temperature >= 35)
        {
            _viewWeekBackgroudNormalColor = 0xfe6724;
            _viewWeekBackgroudSelectColor = 0xff8a43;
            _viewTimeBackgroudColor = 0xf3500f;
            _viewIndexBackgroudColor = 0xdc4612;
            _indexTitleLabelColor = 0xdc4612;
            _indexLevelLabelColor = 0xa82401;
        }
        else if( temperature >=20 &&  temperature < 35)
        {
            _viewWeekBackgroudNormalColor = 0xffa317;
            _viewWeekBackgroudSelectColor = 0xffbe59;
            _viewTimeBackgroudColor = 0xf98c00;
            _viewIndexBackgroudColor = 0xec7a00;
            _indexTitleLabelColor = 0xec7a00;
            _indexLevelLabelColor = 0xa74700;
        }
        else if( temperature >=5 &&  temperature < 20)
        {
            _viewWeekBackgroudNormalColor = 0x7ec13d;
            _viewWeekBackgroudSelectColor = 0x92db47;
            _viewTimeBackgroudColor = 0x62ad35;
            _viewIndexBackgroudColor= 0x4fa12a;
            _indexTitleLabelColor = 0x4fa12a;
            _indexLevelLabelColor = 0x237307;
        }
        else if( temperature >=-10 &&  temperature < 5)
        {
            _viewWeekBackgroudNormalColor = 0x00ccff;
            _viewWeekBackgroudSelectColor = 0x65e4ff;
            _viewTimeBackgroudColor = 0x00baff;
            _viewIndexBackgroudColor = 0x009cff;
            _indexTitleLabelColor = 0x009cff;
            _indexLevelLabelColor = 0x0472b8;
        }
        else
        {
            _viewWeekBackgroudNormalColor = 0x4285ff;
            _viewWeekBackgroudSelectColor = 0x7fafff;
            _viewTimeBackgroudColor = 0x3a76ff;
            _viewIndexBackgroudColor = 0x356de0;
            _indexTitleLabelColor = 0x356de0;
            _indexLevelLabelColor = 0x2344b1;
        }
        
    }

}
- (void)refresh
{
    DDLogFunction();
    _currentDownloaded = NO;
    _fiveDaysDownloaded = NO;
    _todayDaysDownloaded = NO;
    _airDownloaded = NO;
    _indexDownloaded = NO;
    _freeslikeDownloaded = NO;
    _animationOK = YES;
    _runOK = NO;
    if ([_header isRefreshing])
    {
        [_operation1 pause];
        [_operation1 cancel];
        _operation1 = nil;
        [_operation2 pause];
        [_operation2 cancel];
        _operation2 = nil;
        [_operation3 pause];
        [_operation3 cancel];
        _operation3 = nil;
        [_operation4 pause];
        [_operation4 cancel];
        _operation4 = nil;
        [_operation5 pause];
        [_operation5 cancel];
        _operation5 = nil;
        [_operation6 pause];
        [_operation6 cancel];
        _operation6 = nil;
        NSString *idString = _weather.city.areaId;
        [self dataRequest:idString];
        [self dataRequest1:idString];
        [self dataRequest2:idString];
        [self dataRequest3:idString];
        [self dataRequest4:idString];
        [self dataRequest5:idString];
    }
    else
    {
        [_header beginRefreshing];
    }
    
    for (int i = 0; i < 9; i ++)
    {
        UIView *view = [_detailView viewWithTag:100 + i + 1];
        [view.layer removeAllAnimations];
        view.hidden = YES;
   }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < 280)
//    {
//        float alpha = scrollView.contentOffset.y / ((400 * 2) / 3);
//        
//        _backgroundView.backgroundImageView.alpha = alpha;
////        DDLogCVerbose(@"image%f",alpha);
//        float alpha2 = MAX(0.0, MIN(_backgroundView.backgroundImageView.alpha  - 0.2, 0.2));
////        DDLogCVerbose(@"view%f",alpha2);
//        _backgroundView.backgroundGlassView.alpha = alpha2;
//    }
//    
    if (_animationOK == YES)
    {
        if (scrollView.contentOffset.y >= 342 - 90 && _runOK == YES)
        {
               if (!_timer)
               {
                    _flag = 0;
                    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(scaleAnimation) userInfo:nil repeats:YES];
                   [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
                }
                
            _animationOK = NO;
            _runOK = NO;
        }
    }
}

- (void)scaleAnimation
{
    if (_flag == 9)
    {
        [_timer invalidate];
        _timer = nil;
        return;
    }
    UIView *view = [_detailView viewWithTag:100 + _flag + 1];
    
    if(_flag < _weather.weatherIndex.count)
    {
        [view setHidden:NO];
    }
    else
    {
        [view setHidden:YES];
    }
    
    CABasicAnimation * animationStrong = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animationStrong.fromValue = [NSNumber numberWithFloat:0.f];
    animationStrong.toValue = [NSNumber numberWithFloat:1.0f];
    animationStrong.duration = 0.4;
    animationStrong.removedOnCompletion = NO;
    animationStrong.fillMode = kCAFillModeForwards;
    [view.layer addAnimation:animationStrong forKey:[NSString stringWithFormat:@"%d",_flag]];
    
    _flag ++;
}

- (IBAction)gotoCustomIndexView
{
    DDLogFunction();
    _autoIndexButton.userInteractionEnabled = NO;
    CustomIndexViewController *custIndexVC = [[CustomIndexViewController alloc] init];
    custIndexVC.citySelectedProtocol = self;
    [self.navigationController pushViewController:custIndexVC animated:YES];
}


@end
