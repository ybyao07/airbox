//
//  WeatherManager.m
//  AirManager
//

#import "WeatherManager.h"
#import "CityDataHelper.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "AirDevice.h"
#import "AirData.h"

#define kInstantWeather  @"instant_weather"
#define kTemperature     @"temperature"
#define kBackGroundName  @"backGroundImageName"
#define kAirQuality      @"airQuality"

@interface WeatherManager ()
{
    AFHTTPRequestOperation *_operation5;
    AFHTTPRequestOperation *_operation2;
}

- (void)loadCurrentWeather:(NSInteger)requestCount;

- (void)loadCurrentPM25:(NSInteger)requestCount;

- (void)finishLoadWeatherWithName:(NSString *)name Info:(id)info;

/**
 *  start auto update weather
 **/
- (void)startAutoReload;

@end

@implementation WeatherManager

@synthesize weatherUpdatedFailed;

#pragma mark - singleton

+ (WeatherManager *)sharedInstance
{
    static WeatherManager *singleton = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        singleton = [[super allocWithZone:NULL] init];
    });
    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

- (void)loadWeather
{
    [self loadCurrentWeather:0];
    [self loadCurrentPM25:0];
}

- (void)startAutoReload
{
    [self performSelector:@selector(loadWeather) withObject:nil afterDelay:khour];
}

- (void)stopAutoReload
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)loadCurrentWeather:(NSInteger)requestCount
{
    NSString *cityId = [CityDataHelper cityIDOfSelectedCity] != nil ? [CityDataHelper cityIDOfSelectedCity] : @"";
    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/current?city_code=%@&language=zh_CN",BASEURL,cityId];
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
        
        DDLogCVerbose(@"--->loadCurrentWeather response data:%@",str);
        if (dic && [dic objectForKey:@"code"] && ![[dic objectForKey:@"code"]isEqual:[NSNull null]] && ([[dic objectForKey:@"code"] integerValue] == 0))
        {
            NSDictionary *weather = [dic objectForKey:@"instant_weather"];
            if(weather)
            {
                [weakSelf finishLoadWeatherWithName:kCurrentWeather Info:weather];
            }
        }else
        {
             if(requestCount < 3)
             {
                 [weakSelf loadCurrentPM25:requestCount + 1];
             }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(requestCount < 3)
        {
            [weakSelf loadCurrentPM25:requestCount + 1];
        }
        
        DDLogCVerbose(@"loadCurrentWeather通信失败 %@",@"--->");
    }];
    [_operation2 start];
}


- (void)loadCurrentPM25:(NSInteger)requestCount
{
    NSString *cityId = [CityDataHelper cityIDOfSelectedCity] != nil ? [CityDataHelper cityIDOfSelectedCity] : @"";

    NSString *requestStr = [[NSString alloc] initWithFormat:@"%@wonderweather/air?city_code=%@&language=zh_CN",BASEURL,cityId];
    NSURL *url = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:15];
    [request addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    _operation5 = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    __weak typeof(self) weakSelf = self;
    NSString *airManagerPM25CacheKey = [NSString stringWithFormat:@"%@:%@",AirManagerPM25Cache,cityId];
    [_operation5 setCompletionBlockWithSuccessTest:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *dic = [Utility jsonValue:str];
        
        DDLogCVerbose(@"--->loadCurrentPM25 response data: %@",str);
        if (dic && [dic objectForKey:@"code"] && ![[dic objectForKey:@"code"]isEqual:[NSNull null]] && ([[dic objectForKey:@"code"] integerValue] == 0))
        {
            if([dic objectForKey:@"data"] && ![[dic objectForKey:@"data"]isEqual:[NSNull null]])
            {
                [weakSelf finishLoadWeatherWithName:kCurrentPM25 Info:[dic objectForKey:@"data"]];
                
                [UserDefault setObject:[dic objectForKey:@"data"] forKey:airManagerPM25CacheKey];
                [UserDefault synchronize];
            }
            else
            {
                [weakSelf finishLoadWeatherWithName:kCurrentPM25 Info:@{@"pm25":@"--"}];
            }
            
        }else
        {
            if(requestCount < 3)
            {
                [weakSelf loadCurrentPM25:requestCount + 1];
            }
            else {
                 [weakSelf doAirDownLoadPmFaild:airManagerPM25CacheKey];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(requestCount < 3)
        {
            [weakSelf loadCurrentPM25:requestCount + 1];
        } else {
             [weakSelf doAirDownLoadPmFaild:airManagerPM25CacheKey];
            DDLogCVerbose(@"loadCurrentPM25通信失败 %@",@"--->");
        }
       
    }];
    [_operation5 start];
}

- (void)doAirDownLoadPmFaild:(NSString *)airManagerPM25CacheKey
{
    NSDictionary *dicPM25 = [UserDefault objectForKey:airManagerPM25CacheKey];
    if(dicPM25)
    {
        [self finishLoadWeatherWithName:kCurrentPM25 Info:dicPM25];
    }
    else
    {
        [self finishLoadWeatherWithName:kCurrentPM25 Info:@{@"pm25":@"--"}];
    }
}

- (void)finishLoadWeatherWithName:(NSString *)name Info:(id)info
{
    if (!info)
    {
        return;
    }
    
    if ([name isEqualToString:kCurrentWeather] || [name isEqualToString:kCurrentPM25])
    {
        [NotificationCenter postNotificationName:WeatherDownloadedNotification object:name userInfo:info];
    }
    else
    {
    }
}

@end
