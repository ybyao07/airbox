//
//  WeatherViewController.m
//  AirManager
//

#import "WeatherViewController.h"
#import "SettingViewController.h"
#import "CityDataHelper.h"
#import "WeatherManager.h"
#import "UIViewExt.h"
#import "UIDevice+Resolutions.h"
#import "PointsWeatherView.h"
#import "AppDelegate.h"
#import "UserLoginedInfo.h"
#import "AlertBox.h"


/**
 #define kWeatherLineWitdh(low,tail) ((tail < 0 ? -low + tail : low > 0 ? tail-low: abs(low)+abs(tail)))*(120/80.0f)
 #define kWeatherLineLeft(low) 74+70+low*120/80.0f
 **/

@interface WeatherViewController ()
{
    IBOutlet UILabel *lblCurTemperature;
    IBOutlet UILabel *lblCurWeather;
    IBOutlet UILabel *lblHumidity;
    IBOutlet UILabel *lblWindSpeed;
    IBOutlet UILabel *lblWindDirect;
    
    IBOutlet UILabel *lblSecondWeekDay;
    IBOutlet UIImageView *secondWeatherIcon;
    IBOutlet UILabel *lblSecondTemperature;
    
    IBOutlet UILabel *lblThirdWeekDay;
    IBOutlet UIImageView *thirdWeatherIcon;
    IBOutlet UILabel *lblThirdTemperature;
    
    IBOutlet UILabel *lblForthWeekDay;
    IBOutlet UIImageView *forthWeatherIcon;
    IBOutlet UILabel *lblForthTemperature;
    
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblCity;
    
    IBOutlet UIActivityIndicatorView *weatherWaitView;
    IBOutlet UILabel *weatherWaitTitle;
    IBOutlet UIImageView *weatherIcon;
    
    IBOutlet UIImageView *weatherBackGroundView;
    
    IBOutlet UIView *contextView;
    IBOutlet UILabel *noWeatherMessage;
    
    IBOutlet UIScrollView *bodyScrollView;
    IBOutlet UIScrollView *pointScrollView;
    
    IBOutlet UILabel *lblClothesIDX;
    IBOutlet UILabel *lblBodyTemperature;
    IBOutlet UILabel *lblPM25;
    IBOutlet UILabel *lblPM25SubTitle;
    
    IBOutlet UILabel *lblOpenIDX;
}

/**
 *  back superior in weather page
 */
- (IBAction)weatherPageDone;

/**
 *  go setting page
 *
 *  @param sender event object
 */
- (IBAction)setting:(id)sender;

/**
 *  receive notification
 *
 *  @param notification notification object
 */
- (void)weatherUpdateStatus:(NSNotification *)notification;

/**
 *  load current weather
 */
- (void)loadCurrentWeatherToScreen;

/**
 *  load future weather
 */
- (void)loadFutureWeatherToScreen;

/**
 *  load index weather
 */
- (void)loadIndexWeatherToScreen;

/**
 *  load points weather
 */
- (void)loadPointsWeatherToScreen;

/**
 *  load air quality
 */
- (void)loadAirQuality;

/**
 *  covent date
 *
 *  @param string from object
 *
 *  @return HH:mm
 */
- (NSDate *)coventDateFromString:(NSString *)string;

/**
 *  get weather waiting View show
 **/
- (void)showWeatherWaitView;

/**
 *  get weather waiting view hidden
 **/
- (void)hiddenWeatherWaitView;

@end

@implementation WeatherViewController


#pragma mark - Lifeycycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    
    // set bodyScrollView
    if ([UIDevice currentResolution] != UIDevice_iPhoneTallerHiRes)
    {
        bodyScrollView.contentInset = UIEdgeInsetsMake(0, 0, 663+88, 0);
    }
    
    // set date
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd"];
    lblDate.text = [format stringFromDate:[NSDate date]];
    
    // load weather info
    [self loadCurrentWeatherToScreen];
    [self loadFutureWeatherToScreen];
    [self loadIndexWeatherToScreen];
    [self loadPointsWeatherToScreen];
    [self loadAirQuality];
    
    // register observer
    [self registerObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - IBAction

- (IBAction)weatherPageDone
{
    [NotificationCenter removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setting:(id)sender
{
    SettingViewController *setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [self.navigationController pushViewController:setting animated:YES];
}


#pragma mark - Private

- (void)registerObserver
{
    [NotificationCenter addObserver:self
                           selector:@selector(weatherUpdateStatus:)
                               name:WeatherDownloadedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(weatherUpdateStatus:)
                               name:WeatherStartDownloadNotification
                             object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(loadCurrentWeatherToScreen)
                               name:WeatherPageUpdateNotification
                             object:nil];
}

- (NSMutableAttributedString *)string:(NSString *)string font:(UIFont *)font inRange:(NSRange)range
{
    NSMutableAttributedString *attSpeed = [[NSMutableAttributedString alloc] initWithString:string];
    [attSpeed setAttributes:@{NSFontAttributeName:font} range:range];
    return attSpeed;
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
            else if ([info isEqualToString:kIndexWeather])
            {
                [self loadIndexWeatherToScreen];
            }
            else if ([info isEqualToString:kPointsWeather])
            {
                [self loadPointsWeatherToScreen];
            }
            else if ([info isEqualToString:kAirQuality])
            {
                [self loadAirQuality];
            }
        });
    }
}

- (BOOL)weatherDataValid
{
    NSDictionary *curWeather = [NSKeyedUnarchiver unarchiveObjectWithData:[UserDefault objectForKey:kCurrentWeather]];
    NSDictionary *futWeather = [MainDelegate parseJsonData:[UserDefault objectForKey:kFutureWather]];
    NSDictionary *weather1 = isObject(futWeather[Weather1]) ? futWeather[Weather1] : [NSDictionary dictionary];
    NSDictionary *weather2 = isObject(futWeather[Weather2]) ? futWeather[Weather2] : [NSDictionary dictionary];
    NSDictionary *weather3 = isObject(futWeather[Weather3]) ? futWeather[Weather3] : [NSDictionary dictionary];
    NSDictionary *weather4 = isObject(futWeather[Weather4]) ? futWeather[Weather4] : [NSDictionary dictionary];
    NSDictionary *instantWeather = isObject(curWeather[InstantWeather]) ? curWeather[InstantWeather] : [NSDictionary dictionary];
    
    if(isObject(curWeather) &&
       isObject(futWeather) &&
       curWeather.count > 0 &&
       instantWeather.count > 0 &&
       isObject(instantWeather[Temperature]) &&
       isObject(instantWeather[CurWeather]) &&
       isObject(instantWeather[WindDirect]) &&
       ![instantWeather[Temperature] isEqualToString:@"?"] &&
       ![instantWeather[CurWeather] isEqualToString:@"?"] &&
       ![instantWeather[WindDirect] isEqualToString:@"?"] &&
       futWeather.count > 0 &&
       weather1.count > 0 &&
       weather2.count > 0 &&
       weather3.count > 0 &&
       weather4.count > 0 &&
       isObject(weather1[DayTemp]) &&
       isObject(weather2[DayTemp]) &&
       isObject(weather3[DayTemp]) &&
       isObject(weather4[DayTemp]) &&
       ![weather1[DayTemp] isEqualToString:@"?"] &&
       ![weather2[DayTemp] isEqualToString:@"?"] &&
       ![weather3[DayTemp] isEqualToString:@"?"] &&
       ![weather4[DayTemp] isEqualToString:@"?"] &&
       isObject(weather1[NightWeather]) &&
       isObject(weather2[NightWeather]) &&
       isObject(weather3[NightWeather]) &&
       isObject(weather4[NightWeather]) &&
       ![weather1[NightWeather] isEqualToString:@"?"] &&
       ![weather2[NightWeather] isEqualToString:@"?"] &&
       ![weather3[NightWeather] isEqualToString:@"?"] &&
       ![weather4[NightWeather] isEqualToString:@"?"])
    {
        bodyScrollView.hidden = NO;
        noWeatherMessage.hidden = YES;
        return YES;
    }
    else
    {
        bodyScrollView.hidden = YES;
        noWeatherMessage.hidden = NO;
        lblCity.text = [NSString stringWithFormat:@"%@",[CityDataHelper cityNameOfSelectedCity]];
        return NO;
    }
}

- (void)loadCurrentWeatherToScreen
{
    if(![self weatherDataValid])
    {
        return;
    }
    NSDictionary *curWeather = [NSKeyedUnarchiver unarchiveObjectWithData:[UserDefault objectForKey:kCurrentWeather]];
    NSDictionary *instantWeather = isObject(curWeather[InstantWeather]) ? curWeather[InstantWeather] : [NSDictionary dictionary];
    
    if(curWeather.count > 0)
    {
        if(instantWeather[CurWeather])
        {
            NSString *imageName = [MainDelegate siftCurrentIconWithName:instantWeather[CurWeather] needNight:YES Hour:MAX_HOURS];
            weatherIcon.image = [UIImage imageNamed:imageName];
        }
        
        NSString *bodyImageName = instantWeather[kBackGroundName];
        weatherBackGroundView.image = [UIImage imageNamed:bodyImageName];
        
        NSString *temp = [instantWeather[Temperature] isEqualToString:@"?"] ? @"--" : [NSString stringWithFormat:@"%@",instantWeather[Temperature]];
        lblCurTemperature.text = temp;
        lblCurWeather.text = [instantWeather[CurWeather] isEqualToString:@"?"] ? @"--" : instantWeather[CurWeather];
        lblWindDirect.text = [instantWeather[WindDirect] isEqualToString:@"?"] ? @"--" : instantWeather[WindDirect];
        
        NSString *windSpeed = @"--";
        if (isObject(instantWeather[Wind]))
        {
            windSpeed = [instantWeather[Wind] isEqualToString:@"?"] ? @"--" : instantWeather[Wind];
        }
        windSpeed = [windSpeed stringByAppendingString:@" 级"];
        lblWindSpeed.attributedText = [self string:windSpeed
                                              font:[UIFont systemFontOfSize:12]
                                           inRange:NSMakeRange(windSpeed.length - 1, 1)];
        
        if (isObject(instantWeather[Humidy]))
        {
            if([instantWeather[Humidy] isEqualToString:@"?"])
            {
                lblHumidity.text = @"--";
            }
            else
            {
                NSString *humValue = [NSString stringWithFormat:@"%@%@",instantWeather[Humidy],PercentSymbol];
                lblHumidity.attributedText = [self string:humValue
                                                     font:[UIFont systemFontOfSize:16]
                                                  inRange:NSMakeRange(humValue.length - 1, 1)];
            }
        }
        else
        {
            lblHumidity.text = @"--";
        }
        
        NSDictionary *futWeather = [MainDelegate parseJsonData:[UserDefault objectForKey:kFutureWather]];
        NSDictionary *weather1 = isObject(futWeather[Weather1]) ? futWeather[Weather1] : [NSDictionary dictionary];
        
        NSString *dayTemp = isObject(weather1[DayTemp]) ? (weather1[DayTemp] ? weather1[DayTemp] : @"") : @"";
        
        if([dayTemp stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
        {
            NSDictionary *weather2 = isObject(futWeather[Weather2]) ? futWeather[Weather2] : [NSDictionary dictionary];
            dayTemp = isObject(weather2) ? (weather2[DayTemp] ? weather2[DayTemp] : @"--") : @"--";
        }

        NSString *night = isObject(weather1[NightTemp]) ? (weather1[NightTemp] ? weather1[NightTemp] : @"--") : @"--";
        lblCity.text = [NSString stringWithFormat:@"%@ %@~%@%@",
                        [CityDataHelper cityNameOfSelectedCity],
                        night,
                        dayTemp,
                        CelciusSymbol];
    }
}

- (void)loadFutureWeatherToScreen
{
    if(![self weatherDataValid])
    {
        return;
    }
    NSDictionary *futWeather = [MainDelegate parseJsonData:[UserDefault objectForKey:kFutureWather]];
    
    if(futWeather.count > 0)
    {
        /**
        NSString *iconFile = [[NSBundle mainBundle] pathForResource:@"WeatherIcon" ofType:@".plist"];
        NSDictionary *icons = [NSDictionary dictionaryWithContentsOfFile:iconFile];
        **/
        
        NSDictionary *weather1 = futWeather[Weather1];
        NSDictionary *weather2 = futWeather[Weather2];
        NSDictionary *weather3 = futWeather[Weather3];
        NSDictionary *weather4 = futWeather[Weather4];

        lblSecondWeekDay.text = isObject(weather2[Week]) ? (weather2[Week] ? weather2[Week] : @"--") : @"--";
        
        NSString *nightTemp2 = isObject(weather2[NightTemp]) ? (weather2[NightTemp] ? weather2[NightTemp] : @"--") : @"--";
        NSString *dayTemp2 = isObject(weather2[DayTemp]) ? (weather2[DayTemp] ? weather2[DayTemp] : @"--") : @"--";
        lblSecondTemperature.text = [NSString stringWithFormat:@"%@° %@°",nightTemp2,dayTemp2];
        
        if (isObject(weather2[DayWeather]))
        {
            NSString *name = [MainDelegate siftCurrentIconWithName:weather2[DayWeather] needNight:NO Hour:MAX_HOURS];
            secondWeatherIcon.image = [UIImage imageNamed:name];
        }

        lblThirdWeekDay.text = isObject(weather3[Week]) ? (weather3[Week] ? weather3[Week] : @"--") : @"--";
        
        NSString *nightTemp3 = isObject(weather3[NightTemp]) ? (weather3[NightTemp] ? weather3[NightTemp] : @"--") : @"--";
        NSString *dayTemp3 = isObject(weather3[DayTemp]) ? (weather3[DayTemp] ? weather3[DayTemp] : @"--") : @"--";
        lblThirdTemperature.text = [NSString stringWithFormat:@"%@° %@°",nightTemp3,dayTemp3];
        
        if (isObject(weather3[DayWeather]))
        {
            NSString *name = [MainDelegate siftCurrentIconWithName:weather3[DayWeather] needNight:NO Hour:MAX_HOURS];
            thirdWeatherIcon.image = [UIImage imageNamed:name];
        }
        
        if (isObject(weather4[Week]))
        {
            lblForthWeekDay.text = isObject(weather4[Week]) ? (weather4[Week] ? weather4[Week] : @"--") : @"--";
        }
        
        NSString *nightTemp4 = isObject(weather4[NightTemp]) ? (weather4[NightTemp] ? weather4[NightTemp] : @"--") : @"--";
        NSString *dayTemp4 = isObject(weather4[DayTemp]) ? (weather4[DayTemp] ? weather4[DayTemp] : @"--") : @"--";
        lblForthTemperature.text = [NSString stringWithFormat:@"%@° %@°",nightTemp4,dayTemp4];
        
        
        if (isObject(weather4[DayWeather]))
        {
            NSString *name = [MainDelegate siftCurrentIconWithName:weather4[DayWeather] needNight:NO Hour:MAX_HOURS];
            forthWeatherIcon.image = [UIImage imageNamed:name];
        }
        
        NSString *dayTemp = weather1[DayTemp] ? weather1[DayTemp] : @"";
        if([dayTemp stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
        {
            dayTemp = weather2[DayTemp] ? weather2[DayTemp] : @"--";
        }
        
        NSString *night = isObject(weather1[NightTemp]) ? (weather1[NightTemp] ? weather1[NightTemp] : @"--") : @"--";
        lblCity.text = [NSString stringWithFormat:@"%@ %@~%@%@",
                        [CityDataHelper cityNameOfSelectedCity],
                        night,
                        dayTemp,
                        CelciusSymbol];
    }
}

- (void)loadIndexWeatherToScreen
{
    NSDictionary *weather = [MainDelegate parseJsonData:[UserDefault objectForKey:kIndexWeather]];
    if(!isObject(weather))
    {
        [self loadIndexWeatherFailed];
        return;
    }
    
    NSArray *indexWeatherList = weather[@"data"];
    
    if(!isObject(indexWeatherList))
    {
        [self loadIndexWeatherFailed];
        return;
    }
    
    for (NSDictionary *obj in indexWeatherList)
    {
        if (!isObject(obj) || !isObject(obj[@"name"]))
        {
            continue;
        }
        
        NSString *level = isObject(obj[@"level"]) ? obj[@"level"] : @"--";
        
        if ([obj[@"name"] isEqualToString:@"穿衣指数"])
        {
            lblClothesIDX.text = level;
        }
        else if ([obj[@"name"] isEqualToString:@"体感温度"])
        {
            lblBodyTemperature.text = [level stringByAppendingString:@" ˚"];
        }
        else if ([obj[@"name"] isEqualToString:@"空气质量"])
        {
            lblPM25.text = level;
        }
        else if ([obj[@"name"] isEqualToString:@"空调开启指数"])
        {
            lblOpenIDX.text = level;
        }
    }
}

- (void)loadIndexWeatherFailed
{
    lblClothesIDX.text = @"--";
    lblBodyTemperature.text = @"--";
    //lblPM25.text = @"--";
    lblOpenIDX.text = @"--";
}

const int airQualityCellHeight = 123;
const int airQualityCellWidth  = 64;
- (void)loadPointsWeatherToScreen
{
    NSDictionary *weather = [MainDelegate parseJsonData:[UserDefault objectForKey:kPointsWeather]];
    if(!isObject(weather))
    {
        return;
    }
    
    NSDictionary *dicData = weather[@"data"];
    if(!isObject(dicData))
    {
        return;
    }
    
    NSArray *pointWeathers = dicData[@"weatherPoints"];
    
    if(!isObject(pointWeathers))
    {
        return;
    }
    
    if(pointWeathers.count <= 0)
    {
        return;
    }
    
    if ([pointScrollView.subviews count] > 0)
    {
        [pointScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    int pointCount = [pointWeathers count] >= 24 ? 24 : [pointWeathers count];
    
    pointScrollView.contentSize = CGSizeMake(airQualityCellWidth * pointCount, airQualityCellHeight);
    
    NSInteger index = 0;
    for (int i = 0; i < [pointWeathers count]; i++)
    {
        if (isObject(pointWeathers[i][@"time"]))
        {
            /**
            NSDate * hour = [self coventDateFromString:pointWeathers[i][@"time"]];
            NSDate *curHour = [self currentHour];
            if ([curHour timeIntervalSinceDate:hour] > 0)
            {
                index++;
                continue;
            }
             **/
            
            for (int j = index; j < pointCount; j++)
            {
                PointsWeatherView *cell = [[[NSBundle mainBundle] loadNibNamed:@"PointsWeatherView" owner:self options:nil] lastObject];
                
                NSInteger hour = [[self coventHourFromString:pointWeathers[j][@"time"]] integerValue];
                NSInteger curHour = [[self currentHour] integerValue];
                if (curHour == hour)
                {
                    if (isObject(pointWeathers[j][@"feelsLike"]))
                    {
                        lblBodyTemperature.text = [pointWeathers[j][@"feelsLike"] stringByAppendingString:@" ˚"];
                    }
                    else
                    {
                        lblBodyTemperature.text = @"--";
                    }
                    cell.airIcon.alpha = 0.3;
                    cell.lblHour.textColor = [UIColor whiteColor];
                    cell.lblTemperature.textColor = [UIColor whiteColor];
                }
                cell.left = (j - index) * airQualityCellWidth;
                
                if (isObject(pointWeathers[j][@"time"]))
                {
                    cell.lblHour.text = [self coventHourFromString:pointWeathers[j][@"time"]];
                }
                else
                {
                    cell.lblHour.text = @"--";
                }
                cell.lblHour.adjustsFontSizeToFitWidth = YES;
                
                if (isObject(pointWeathers[j][@"temperature"]))
                {
                    cell.lblTemperature.text = [pointWeathers[j][@"temperature"] stringByAppendingString:@" ˚"];
                }
                else
                {
                    cell.lblTemperature.text = @"--";
                }
                cell.lblTemperature.adjustsFontSizeToFitWidth = YES;
                
                
                if (isObject(pointWeathers[j][@"icon"]))
                {
                    NSString *iconString = pointWeathers[j][@"icon"];
                    iconString = [iconString hasSuffix:@"night"] ? [iconString substringToIndex:([iconString length] -5)] : iconString;
                    NSString *iconName = [MainDelegate siftCurrentIconWithName:iconString needNight:YES Hour:[cell.lblHour.text integerValue]];
                    
                    if (isEmptyString(iconName))
                    {
                        iconName = [MainDelegate siftCurrentIconWithName:@"clear" needNight:YES Hour:[cell.lblHour.text integerValue]];
                    }
                    
                    NSString *iconFile = [[NSBundle mainBundle] pathForResource:iconName ofType:nil];
                    UIImage *icon = [UIImage imageWithContentsOfFile:iconFile];
                    cell.airIcon.image = icon;
                }
                
                [pointScrollView addSubview:cell];
            }
            break;
        }
    }
}

- (NSString *)currentHour
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
//    NSDate *curHour = [formatter dateFromString:dateString];
    return dateString;
}

- (void)loadAirQuality
{
    NSDictionary *result = [MainDelegate parseJsonData:[UserDefault objectForKey:kAirQuality]];
    NSString *string = @"-- --";
    if(!isObject(result))
    {
//        lblPM25.text = @"--";
//        lblPM25SubTitle.text = @"--";
//        lblPM25.attributedText = [self string:string
//                                         font:[UIFont systemFontOfSize:12]
//                                      inRange:NSMakeRange(string.length - 2, 2)];
        lblPM25.text = string;
        return;
    }
    
    if (isObject(result[@"data"]) && isObject(result[@"data"][@"pm25"]))
    {
        NSInteger pm25 = [result[@"data"][@"pm25"] integerValue];
//        lblPM25.text = [@(pm25) stringValue];
        NSString *string = [@(pm25) stringValue];
        if (pm25 >= 200)
        {
//            lblPM25SubTitle.text = @"差";
            string = [string stringByAppendingString:@" 差"];
        }
        else if (pm25 >= 100 && pm25 < 200)
        {
//            lblPM25SubTitle.text = @"中";
            string = [string stringByAppendingString:@" 中"];
        }
        else if (pm25 >= 51 && pm25 < 100)
        {
//            lblPM25SubTitle.text = @"良";
            string = [string stringByAppendingString:@" 良"];
        }
        else if (pm25 < 51)
        {
//            lblPM25SubTitle.text = @"优";
            string = [string stringByAppendingString:@" 优"];
        }
        
        lblPM25.attributedText = [self string:string
                                         font:[UIFont systemFontOfSize:12]
                                      inRange:NSMakeRange(string.length - 1, 1)];
    }
    else
    {
//        lblPM25.text = @"--";
//        lblPM25SubTitle.text = @"--";
//        lblPM25.attributedText = [self string:string
//                                         font:[UIFont systemFontOfSize:12]
//                                      inRange:NSMakeRange(string.length - 2, 2)];
        lblPM25.text = string;
    }
}

- (NSDate *)coventDateFromString:(NSString *)string
{
    NSString *time = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [[formatter dateFromString:time] dateByAddingTimeInterval:8*60*60];
    return date;
}

- (NSString *)coventHourFromString:(NSString *)string
{
    NSString *time = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date=[[formatter dateFromString:time] dateByAddingTimeInterval:8*60*60];
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

- (void)showWeatherWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       weatherWaitTitle.hidden = NO;
                       [weatherWaitView startAnimating];
                   });
}

- (void)hiddenWeatherWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       weatherWaitTitle.hidden = YES;
                       [weatherWaitView stopAnimating];
                   });
}

@end
