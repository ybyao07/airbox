//
//  NearAirBoxesViewController.m
//  AirManager
//
//  Created by qitmac000242 on 14-12-8.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "NearAirBoxesViewController.h"
#import "DDRaderView.h"
#import "AppDelegate.h"
#import "NearAirQuality.h"

#define kPreNearAirBoxesNumber      3

#define kLatKey     @"lat"
#define klngKey     @"lng"
#define kValueKey   @"locationValue"

typedef NS_ENUM(NSInteger, DDRaderViewState) {
    DDRaderViewStateBegin = 0,
    DDRaderViewStateLoading,
    DDRaderViewStateEnd
};

@interface NearAirBoxesViewController ()

@property (nonatomic, strong) UIView *baseview;
@property (nonatomic, strong) DDRaderView *radarView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, assign) BOOL isLeave;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (nonatomic, assign) DDRaderViewState raderViewState;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (nonatomic, strong)NSNumber *lat;
@property (nonatomic, strong)NSNumber *lng;
@property (nonatomic, assign)NSUInteger pageIndex;
@property (nonatomic, retain)NSMutableArray *arrNeedGeocoder;
@property (nonatomic, retain)NSArray *arrNeedAirBoxes;
@property (nonatomic, retain)NSString *cityName;
@property (nonatomic, retain)NSString *cityID;

@end

@implementation NearAirBoxesViewController

- (void)dealloc
{
    DDLogFunction();
    
    [[LocationController getInstance] stopUpdatingLocationWithSender:self];
    
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
    _pageIndex = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    _backImageView.image = self.backImage;
    
    _arrNeedGeocoder = [[NSMutableArray alloc] init];
    [self layoutView];
    
    [self setupRootView:_baseview];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    [self startAnimation];
    [[LocationController getInstance] startUpdatingLocationWithPurpose:@"" andSender:self];
    
    [Utility setExclusiveTouchAll:self.view];
    
    _btnNext.enabled = NO;
}

#pragma mark -
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
    _headerView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.15f];
    [self.view addSubview:_baseview];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.raderViewState == DDRaderViewStateBegin) {
        [_radarView resetRadarImageViewImage:[UIImage imageNamed:@"saomiao"]];
    } else if (self.raderViewState == DDRaderViewStateEnd) {
        [_radarView resetRadarImageViewImage:[UIImage imageNamed:@"quanquan"]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.raderViewState == DDRaderViewStateLoading) {
        [_radarView reset];
        self.raderViewState = DDRaderViewStateBegin;
    }
    [_radarView resetRadarImageViewImage:nil];
}

#pragma mark -
// =======================================================================
#pragma mark - 主界面布局函数
// =======================================================================
- (void)setupRootView:(UIView *)viewParent
{
    // 父窗口尺寸
    CGRect parentFrame = [viewParent frame];

    _radarView = [[DDRaderView alloc] initWithFrame:CGRectMake(0, 50, parentFrame.size.width, parentFrame.size.height -50)];
    _radarView.rotationSpeed = 0.5;
    self.raderViewState = DDRaderViewStateBegin;
    [viewParent addSubview:_radarView];
}

- (void)startAnimation
{
    _btnNext.enabled = NO;
   
    if (self.raderViewState == DDRaderViewStateLoading) {
        return;
    }
    
    [_radarView start];
    
    self.raderViewState = DDRaderViewStateLoading;
    
}

- (NSDictionary *)createDate
{
    NSString *cityIdTmp = _cityID ? _cityID :@"101010200";
    NSDictionary *retDic = @{@"data" : @[
                                        @{@"deviceId":@"BCDEFABCDE88",
                                           @"temperature":@22,
                                           @"humidity":@45,
                                           @"pm25":@35,
                                           @"voc":@1,
                                           @"dateTime":@"20140103103035",
                                           @"mark":@85,
                                           @"markInfo":@"太冷了,会生病的!" ,
                                           @"city":cityIdTmp,
                                           @"lat":@"29.59",
                                           @"lng":@"118.04"},
                                         @{@"deviceId":@"BCDEFABCDE88",
                                           @"temperature":@22,
                                           @"humidity":@30,
                                           @"pm25":@79,
                                           @"voc":@1,
                                           @"dateTime":@"20140103103035",
                                           @"mark":@60,
                                           @"markInfo":@"太冷了,会生病的!" ,
                                           @"city":cityIdTmp,
                                           @"lat":@"29.59",
                                           @"lng":@"118.04"},
                                         @{@"deviceId":@"BCDEFABCDE88",
                                           @"temperature":@22,
                                           @"humidity":@90,
                                           @"pm25":@150,
                                           @"voc":@1,
                                           @"dateTime":@"20140103103035",
                                           @"mark":@31,
                                           @"markInfo":@"太冷了,会生病的!" ,
                                           @"city":cityIdTmp,
                                           @"lat":@"39.97",
                                           @"lng":@"116.298"}
                                        ]};
    
    return retDic;
    
}

- (void)getNearAirBoxes
{
    __weak typeof(_radarView) weakRadarView = _radarView;
    __weak typeof(self) weakSelf = self;
    
    if(MainDelegate.isCustomer)
    {
        [self startAnimation];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.raderViewState = DDRaderViewStateEnd;
            
            NSDictionary *resultTmp = [self createDate];
            _arrNeedAirBoxes = [self parserNearAirQualityInfo:isObject(resultTmp[@"data"])?resultTmp[@"data"]:[NSArray array]];
            
            if([_arrNeedAirBoxes count]> 0 )
            {
                [weakRadarView setArrNearAirBoxes:_arrNeedAirBoxes];
                if(!_isLeave)
                {
                    [weakRadarView stop];
                    _btnNext.enabled = YES;
                }
            }
        });
    }
    else
    {
        [self startAnimation];
        
        NSDictionary *dicBody = @{@"deviceId":@"",
                                  @"count":[NSNumber numberWithInteger:kPreNearAirBoxesNumber],
                                  @"page":[NSNumber numberWithInteger:_pageIndex],
                                  @"lng":_lng,
                                  @"lat":_lat,
                                  @"sequenceId":[MainDelegate sequenceID]};
        NSString *body = [MainDelegate createJsonString:dicBody];
        
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_PERIPHERY_INSTANT
                                                         method:HTTP_POST
                                                           body:body];
        DDLogCVerbose(@"查询周边N个盒子的室内实时空气质量信息  %@  %@",dicBody,request);
        
        [NSURLConnection sendAsynchronousRequestTest:request
                                               queue:[NSOperationQueue currentQueue]
                                   completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
         {
             
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 if(error)
                 {
                     if(!_isLeave)
                     {
                         [weakRadarView setArrNearAirBoxes:nil];
                         weakSelf.raderViewState = DDRaderViewStateEnd;
                         
                         [weakRadarView stop];
                         _btnNext.enabled = YES;
                         
                         UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                            message:@"附近的盒子获取超时，请重试"
                                                                           delegate:weakSelf
                                                                  cancelButtonTitle:NSLocalizedString(@"重试",@"CityViewController.m")
                                                                  otherButtonTitles:@"取消",nil];
                         [pwdAlert setTag:10000];
                         [pwdAlert show];
                     }
                     
                     return;
                 }
                 
                 NSDictionary *result = [MainDelegate parseJsonData:data];
                 result = isObject(result) ? result : nil;
                 DDLogCVerbose(@"--->查询周边N个盒子的室内实时空气质量信息%@",result);
                 
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                 {
                     if([result[@"data"] isEqual:[NSNull null]])
                     {
                         if(!_isLeave)
                         {
                             [weakRadarView setArrNearAirBoxes:nil];
                             weakSelf.raderViewState = DDRaderViewStateEnd;
                             
                             [weakRadarView stop];
                             _btnNext.enabled = YES;
                             
                             if(_pageIndex == 1)
                             {
                                 UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                                    message:@"在附近未找到任何盒子，赶快召唤小伙伴们加入空气盒子大家庭吧。"
                                                                                   delegate:self
                                                                          cancelButtonTitle:NSLocalizedString(@"重试",@"CityViewController.m")
                                                                          otherButtonTitles:@"取消",nil];
                                 [pwdAlert setTag:10000];
                                 [pwdAlert show];
                             }
                             else
                             {
                                 UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                                    message:@"附近无其他空气盒子"
                                                                                   delegate:self
                                                                          cancelButtonTitle:NSLocalizedString(@"确定",@"CityViewController.m")
                                                                          otherButtonTitles:nil];
                                 [pwdAlert setTag:20000];
                                 [pwdAlert show];
                             }
                         }
                         return;
                     }
                     else
                     {
                         _arrNeedAirBoxes = [self parserNearAirQualityInfo:isObject(result[@"data"])?result[@"data"]:[NSArray array]];
                         if([_arrNeedAirBoxes count]> 0 )
                         {
                             if(!_isLeave)
                             {
                                 [weakRadarView setArrNearAirBoxes:_arrNeedAirBoxes];
                                 
                                 weakSelf.raderViewState = DDRaderViewStateEnd;
                                 
                                 [weakRadarView stop];
                                 
                                 _btnNext.enabled = YES;
                             }
                         }
                         else
                         {
                             if(!_isLeave)
                             {
                                 [weakRadarView setArrNearAirBoxes:nil];
                                 weakSelf.raderViewState = DDRaderViewStateEnd;
                                 [weakRadarView stop];
                                 _btnNext.enabled = YES;
                                 
                                 if(_pageIndex == 1)
                                 {
                                     UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                                        message:@"在附近未找到任何盒子，赶快召唤小伙伴们加入空气盒子大家庭吧。"
                                                                                       delegate:self
                                                                              cancelButtonTitle:NSLocalizedString(@"重试",@"CityViewController.m")
                                                                              otherButtonTitles:@"取消",nil];
                                     [pwdAlert setTag:10000];
                                     [pwdAlert show];
                                     return;
                                 }
                                 else
                                 {
                                     UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                                        message:@"附近无其他空气盒子"
                                                                                       delegate:self
                                                                              cancelButtonTitle:NSLocalizedString(@"确定",@"CityViewController.m")
                                                                              otherButtonTitles:nil];
                                     [pwdAlert setTag:20000];
                                     [pwdAlert show];
                                     return;
                                 }
                             }
                             return;
                         }
                     }
                     
                     _pageIndex ++;
                     
                 }
                 else
                 {
                     if(!_isLeave)
                     {
                         [weakRadarView setArrNearAirBoxes:nil];
                         weakSelf.raderViewState = DDRaderViewStateEnd;
                         
                         [weakRadarView stop];
                         _btnNext.enabled = YES;
                         
                         UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                            message:@"附近的盒子获失败，请重试"
                                                                           delegate:weakSelf
                                                                  cancelButtonTitle:NSLocalizedString(@"重试",@"CityViewController.m")
                                                                  otherButtonTitles:@"取消",nil];
                         [pwdAlert setTag:10000];
                         [pwdAlert show];
                         return;
                     }
                 }
                 
                 _btnNext.enabled = YES;
             
             });
             
         }];
    }
}

- (NSMutableArray *)parserNearAirQualityInfo:(NSArray *)list
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if([list isEqual:[NSNull null]])
    {
        return array;
    }
    
    for (int i = 0; i < [list count]; i++)
    {
        NearAirQuality *irDevice = [[NearAirQuality alloc] initWithNearAirQualityInfo:list[i]];
        NSDictionary *dic = @{kLatKey:irDevice.lat, klngKey:irDevice.lng, kValueKey:irDevice};
        [_arrNeedGeocoder addObject:dic];
        
        [array addObject:irDevice];
    }
    return array;
}


- (IBAction)gobackDone:(id)sender{
    DDLogFunction();
    
    _isLeave =YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoNext:(id)sender{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:nil
                                                           message:@"更多信息请登录后查看"
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"确定",@"CityViewController.m")
                                                 otherButtonTitles:nil];
        [pwdAlert show];
        return;
    }
    else
    {
        [self getNearAirBoxes];
    }
}

// =======================================================================
#pragma mark - 定位函数
// =======================================================================
- (void)UpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation WithPurpose:(NSString *)purpose andError:(NSString *)error andErrorCode:(NSInteger)errorCode
{
    DDLogFunction();
    if (errorCode == kLocationErrorWithPermission || (errorCode != 0 && (error != nil && [error length] > 0) ))
    {
        
        if(!_isLeave)
        {
            [_radarView stop];
        }
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
    
    _lat = [NSNumber numberWithDouble:newLocation.coordinate.latitude];
    
    _lng = [NSNumber numberWithDouble:newLocation.coordinate.longitude];
    
    if(_lat && _lng)
    {
        NSDictionary *deviceLocation = @{
                                         DeviceLat:_lat,
                                         DeviceLng:_lng
                                         };
        [UserDefault setObject:deviceLocation forKey:DeviceLocation];
        [UserDefault synchronize];
        
        MainDelegate.devicelat = _lat;
        MainDelegate.devicelng = _lng;
    }
    
    NSDictionary *dic = @{kLatKey:lat, klngKey:lng, kValueKey:@""};
    [_arrNeedGeocoder addObject:dic];

    [self getNearAirBoxes];
    NSString *urlStr = [NSString stringWithFormat:@"%@wonderweather/location?lng=%@&lat=%@",BASEURL,lng,lat];
    [self dataRequestLocation:urlStr];
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



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
   
    if(tag == 10000)
    {
        if(buttonIndex == [alertView cancelButtonIndex])
        {
            
            [self getNearAirBoxes];
            
        }
        else
        {
            [self gobackDone:nil];
        }
    }
    else if(tag == 20000)
    {
        [self gobackDone:nil];
    }
}


@end
