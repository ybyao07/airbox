//
//  CityViewController.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-21.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "CityViewController.h"
#import "WeatherMainViewController.h"
#import "CurrentCity.h"
#import "WeekEntity.h"

#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "CityManager.h"

#import "Toast+UIView.h"
#import "CityDataHelper.h"
#import "WeatherManager.h"
#import "MainViewController.h"

#import <CoreLocation/CLLocationManager.h>
#import  <CoreLocation/CLGeocoder.h>
#import "AppDelegate.h"
#import "AirDevice.h"
#import "UserLoginedInfo.h"
static NSMutableArray *_cityListPinyinArray = nil;
static NSMutableArray *_cityListPinyinHeadArray = nil;
static NSMutableArray *_cityListCountArray = nil;
static NSMutableArray *_cityNameArray = nil;
static NSMutableDictionary *_cityID_CityName_dic = nil;
static NSMutableDictionary *_cityName_CityID_dic = nil;
static BOOL finish;
@interface CityViewController ()

@property(nonatomic,strong)CLGeocoder *myGeocoder;

@end

@implementation CityViewController
@synthesize cityListArray,lm;

- (void)dealloc
{
    DDLogFunction();
    _myGeocoder = nil;
    [[LocationController getInstance] stopUpdatingLocationWithSender:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if(_fromDeviceBind)
    {
        _backButton.hidden = YES;
    }
    else
    {
        _backButton.hidden = NO;
    }
    
    
    _myGeocoder = [[CLGeocoder alloc] init];
    
    
    cityListArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    _navigationView.backgroundColor = [UIColor colorWithRed:(46.0f/255.0f) green:(54.0f/255.0f) blue:(63.0f/255.0f) alpha:1.0f];
    [self layoutView];
    [self readDataString];
    [self createCityButton];
    [self createSearch];
    
    [Utility setExclusiveTouchAll:self.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboard
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    // 键盘高度变化通知，ios5.0新增的
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    if (IOS7) {
        
        _myTableView.Frame = CGRectMake(0, _baseview.frame.origin.y + _navigationView.frame.size.height + _mySearchBar.frame.size.height - 20, 320, _baseview.frame.size.height - keyboardRect.size.height - 88);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        
#endif
    }else
    {
        
        _myTableView.frame = CGRectMake(0, _baseview.frame.origin.y + _navigationView.frame.size.height + _mySearchBar.frame.size.height, 320, _baseview.frame.size.height - keyboardRect.size.height - 88);
    }
    
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    _myTableView.hidden = YES;
}

#pragma mark - UI

- (void)layoutView
{
    
    //判断是不是ios7
    if (IOS7) {
        //        for (UIView *view in self.view.subviews) {
        //            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        //        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
#endif
    }
    
    _baseview.frame = CGRectMake(0, ADDHEIGH, 320, VIEWHEIGHT);
    
}

- (void)createCityButton
{
    NSInteger count = 0;
    float screenTmp;
    if ([UIScreen mainScreen].bounds.size.height > 480) {
        screenTmp = 0;
    }else
    {
        screenTmp = -8;
    }
    
    for (int i = 0; i < cityListArray.count / 3 + 1; i++) {
        for (int j = 0; j < 3; j ++) {
            if (i == 0 && j == 0) {
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                /*------------------ybyao----------------------*/
                [button setTitle:NSLocalizedString(@"定位" ,@"CityViewController.m") forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.frame = CGRectMake(1 , 100 + screenTmp, 106, 30);
                [button addTarget:self action:@selector(locationButton) forControlEvents:UIControlEventTouchUpInside];
                [_baseview addSubview:button];
                
                UIImageView *locationView = [[UIImageView alloc] init];
                locationView.image = [UIImage imageNamed:@"location.png"];
                if ([MainDelegate isLanguageEnglish]) {
                    locationView.frame = CGRectMake(5, 2, 15, 25);

                }else{
                    locationView.frame = CGRectMake(15, 2, 15, 25);

                }
                
                [button addSubview:locationView];
                
            } else {
                CurrentCity *city = [cityListArray objectAtIndex:count];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                /*----------------ybyao----------------*/
                [button setTitle:NSLocalizedString(city.cityName,@"CityViewController.m") forState:UIControlStateNormal];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.frame = CGRectMake(1 + j * 106, 100 + i * 30 + screenTmp, 106, 30);
                button.tag = count;
                [button addTarget:self action:@selector(selectCityButton:) forControlEvents:UIControlEventTouchUpInside];
                [_baseview addSubview:button];

                CurrentCityWeather *weekentity = [[CityManager sharedManager]  currentCityWeather];
                if ([city.areaId isEqualToString:weekentity.city.areaId]) {
                    UIImageView *selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checked.png"]];
                    if ([MainDelegate isLanguageEnglish]) {
                        selectImageView.frame = CGRectMake(90, 5, 18, 18);
                    }else{
                        selectImageView.frame = CGRectMake(80, 5, 18, 18);

                    }
                    [button addSubview:selectImageView];
                }
                
                count ++;
                
                if (count == [cityListArray count]) {
                    break;
                }
            }
            
        }
    }
}

#pragma mark - read data

- (void)readDataString
{
    NSError *error;
    NSString *textFileContents ;
    
    if ([MainDelegate isLanguageEnglish]) {
        textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recommendationcitylistEn" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
    }else{
        textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"recommendationcitylist" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
    }
    if (textFileContents == nil) {
        DDLogCVerbose(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    
    NSDictionary *dic = [Utility jsonValue:textFileContents];
    NSArray *listArray = [dic valueForKey:@"citylist"];
    
    for (id tmp in listArray) {
        NSDictionary *dic = tmp;
        CurrentCity *city = [[CurrentCity alloc] init];
        city.cityName = [dic valueForKey:@"name"];
        city.areaId = [dic valueForKey:@"id"];
        [cityListArray addObject:city];
    }
    
}

+ (void)readDataCityListString
{
    finish = NO;
    NSError *error;
    NSString *textFileContents;
    if ([MainDelegate isLanguageEnglish]) {
        textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"citylistEn" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
    }else{
        textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"citylist" ofType:@"txt" ] encoding:NSUTF8StringEncoding error:& error];
    }
    if (textFileContents == nil) {
        DDLogCVerbose(@"Error reading text file. %@", [error localizedFailureReason]);
    }
    
    int count = 0;
    
    NSData *data=[textFileContents dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *listArray = [dic valueForKey:@"citylist"];
    BOOL needConvert = NO;
    if (_cityListPinyinArray == nil) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cityListPinyinArray = [[NSMutableArray alloc] initWithCapacity:listArray.count];
            _cityListPinyinHeadArray = [[NSMutableArray alloc] initWithCapacity:listArray.count];
            _cityListCountArray = [[NSMutableArray alloc] initWithCapacity:listArray.count];
            _cityNameArray = [[NSMutableArray alloc] initWithCapacity:listArray.count];
            _cityID_CityName_dic = [[NSMutableDictionary alloc] initWithCapacity:listArray.count];
            _cityName_CityID_dic = [[NSMutableDictionary alloc] initWithCapacity:listArray.count];
        });
        needConvert = YES;
    }
    for (id tmp in listArray) {
        if (count == 0) {
            count ++;
            continue;
        }
        NSDictionary *dic = tmp;
        CurrentCity *city = [[CurrentCity alloc] init];
        city.cityName = [dic valueForKey:@"name"];
        city.areaId = [dic valueForKey:@"id"];
        city.provinceName = [dic valueForKey:@"province_name"];
        NSString *str = [[NSString alloc] initWithFormat:@"%@-%@",city.cityName,city.provinceName];
        [_cityListCountArray addObject:city];
        [_cityNameArray addObject:str];
        
        // 创建城市和城市id的字典
        NSString *strCity = nil;
        if([city.provinceName isEqualToString:city.cityName])
        {
             strCity= [[NSString alloc] initWithFormat:@"%@",city.provinceName];
        }
        else
        {
            strCity= [[NSString alloc] initWithFormat:@"%@%@",city.provinceName,city.cityName];
        }
        [_cityID_CityName_dic setObject:strCity forKey:city.areaId];
        [_cityName_CityID_dic setObject:city.areaId forKeyedSubscript:strCity];
        
        if(needConvert) {
            NSString *pinyin;
            
            pinyin = [PinYinForObjc chineseConvertToPinYin:city.cityName];
            if (pinyin == nil) {
                pinyin = @"";
            }
            [_cityListPinyinArray addObject:pinyin];
            
            pinyin = [PinYinForObjc chineseConvertToPinYinHead:city.cityName];
            if (pinyin == nil) {
                pinyin = @"";
            }
            [_cityListPinyinHeadArray addObject:pinyin];
        }
        
    }
    finish = YES;
}

+ (NSString *)getCityNameByID :(NSString *)cityID
{
    return [_cityID_CityName_dic objectForKey:cityID];
}

+ (NSString *)getCityIDByName :(NSString *)cityName
{
    return [_cityName_CityID_dic objectForKey:cityName];
}


#pragma mark - call back

- (void)selectCityButton:(UIButton *)button
{
    NSInteger count = button.tag;
    
    CurrentCity *city =[cityListArray objectAtIndex:count];
    //改变盒子地址ybyao07-20141114
    [self getLatLngFromCity:city];
    
    [self doSelectCity:city];
    
}

-(void) getLatLngFromCity:(CurrentCity *)city
{
    NSString * cityName = city.cityName;
    [_myGeocoder geocodeAddressString:cityName completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error)
        {
            DDLogCVerbose(@"Geocoder error : %@",error);
            return ;
        }
        if([placemarks count] == 0)
        {
            DDLogCVerbose(@"Could found the address. %@",@"--->");
            return ;
        }
        CLPlacemark *placeMark = [placemarks objectAtIndex:0];
        NSNumber *lat = [NSNumber numberWithDouble:placeMark.location.coordinate.latitude];
        
        NSNumber *lng = [NSNumber numberWithDouble:placeMark.location.coordinate.longitude];
        
        if(lat && lng)
        {
            NSDictionary *deviceLocation = @{DeviceLat:lat,
                                             DeviceLng:lng
                                             };
            [UserDefault setObject:deviceLocation forKey:DeviceLocation];
            [UserDefault synchronize];
        }
    }];
    
}

- (void)doSelectCity:(CurrentCity *)city
{
    if (_citySelectedProtocol != nil  && (_citySelectedProtocol != nil && [_citySelectedProtocol conformsToProtocol:@protocol(CitySelectedProtocol)] ))
    {
        NSMutableDictionary *cityDic = [[NSMutableDictionary alloc] init];
        [cityDic setObject:city.areaId forKey:kCityID];
        [cityDic setObject:city.cityName forKey:kCityName];
        
        [CityDataHelper updateSelectedCity:cityDic];
        
        [_citySelectedProtocol citySelected:city];
        
        [[WeatherManager sharedInstance] stopAutoReload];
        [[WeatherManager sharedInstance] loadWeather];
        [NotificationCenter postNotificationName:CityChangedNotification object:nil userInfo:nil];
    }
    else
    {
        if (city == nil) return;
        DDLogCVerbose(@"citySelected %@",@"--->");
        CurrentCityWeather *currentCityWeather = [[CityManager sharedManager] currentCityForID:city.areaId areaName:city.cityName];
        if (currentCityWeather == nil)
        {
            currentCityWeather = [[CurrentCityWeather alloc] init];
            currentCityWeather.city = city;
            [[CityManager sharedManager] addCity:currentCityWeather];
        }
        [[CityManager sharedManager] changeCurrentCity:currentCityWeather];
        
        NSMutableDictionary *cityDic = [[NSMutableDictionary alloc] init];
        [cityDic setObject:city.areaId forKey:kCityID];
        [cityDic setObject:city.cityName forKey:kCityName];
        
        [CityDataHelper updateSelectedCity:cityDic];
        [[WeatherManager sharedInstance] stopAutoReload];
        [[WeatherManager sharedInstance] loadWeather];
        [NotificationCenter postNotificationName:CityChangedNotification object:nil userInfo:nil];
    }
    
    [self exitCurrentPage];
}


- (void)locationButton
{
    [[LocationController getInstance] startUpdatingLocationWithPurpose:@"" andSender:self];
}


// =======================================================================
#pragma mark - 定位函数
// =======================================================================
- (void)UpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation WithPurpose:(NSString *)purpose andError:(NSString *)error andErrorCode:(NSInteger)errorCode
{
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
    }
    
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
            
            NSArray *subviewArr = [weakSelf.baseview subviews];
            for (id view in subviewArr) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *button = view;
                    button.userInteractionEnabled = YES;
                }
            }
            
            [weakSelf.view hideToastActivity];
            /*----------------------ybyao------------------*/
            [[[UIApplication sharedApplication] keyWindow] makeToast:NSLocalizedString(@"定位成功",@"CityViewController.m")
                                                            duration:1
                                                            position:@"bottom"
             ];
            
            
            NSMutableDictionary *currentCityDic = [[NSMutableDictionary alloc] initWithDictionary:[dic valueForKey:@"data"]];
            NSString *areaIdString = [currentCityDic valueForKey:@"areaid"];
            NSString *cityName ;
            if([MainDelegate isLanguageEnglish]){
                 cityName = [currentCityDic objectForKey:@"nameen"];
            }
            else{
              cityName = [currentCityDic objectForKey:@"namecn"];
            }

            CurrentCity *city = [[CurrentCity alloc] init];
            city.cityName = cityName;
            city.areaId = areaIdString;
            
            [weakSelf doSelectCity:city];
            
        }else{//请求失败
            
            NSArray *subviewArr = [weakSelf.baseview subviews];
            for (id view in subviewArr) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *button = view;
                    button.userInteractionEnabled = YES;
                }
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSArray *subviewArr = [weakSelf.baseview subviews];
        for (id view in subviewArr) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = view;
                button.userInteractionEnabled = YES;
            }
        }
        
        [weakSelf.view hideToastActivity];
        /*--------------------------ybyao---------------------*/
        [weakSelf.view makeToast:NSLocalizedString(@"定位失败,请手动选择城市",@"CityViewController.m")
                    duration:1
                    position:@"center"
         ];
        
        
        
    }];
    [operation start];
    [self.view makeToastActivity];
    NSArray *subviewArr = [_baseview subviews];
    for (id view in subviewArr) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = view;
            button.userInteractionEnabled = NO;
        }
    }
    
    
}



- (IBAction)back:(id)sender {
    DDLogFunction();
    if ([_parentVC isKindOfClass:[MainViewController class]])
    {
        [(MainViewController *)_parentVC clearLoginInfo];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    NSArray *citylist = [[CityManager sharedManager] currentCityList];
    if (citylist.count <= 0) {
        if (_citySelectedProtocol != nil && [_citySelectedProtocol conformsToProtocol:@protocol(CitySelectedProtocol)])
        {
            WeatherMainViewController *weatherVC = (WeatherMainViewController *)_citySelectedProtocol;
            [[weatherVC navigationController] popViewControllerAnimated:YES];
        }
    }
}


- (void)exitCurrentPage
{
    DDLogFunction();
    [lm stopUpdatingLocation];
    lm.delegate = nil;
    
    if(_fromDeviceBind)
    {
        MainViewController *mainPage = (MainViewController *)[self parentViewController];
        [mainPage openAirBoxBindPage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.view.alpha = 0.0;
            } completion:^(BOOL finished){
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        });
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Search UI

- (void)createSearch
{
    DDLogFunction();
    /*------------------ybyao---------------------*/
    [_mySearchBar setPlaceholder:NSLocalizedString(@"搜索列表",@"CityViewController.m")];
    [self keyboard];
    
    _myTableView = [[UITableView alloc] init];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    _myTableView.hidden = YES;
    [_baseview addSubview:_myTableView];
    
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _searchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    CurrentCity *city = [_searchResults objectAtIndex:indexPath.row];
    /*------------------------------ybyao-----------------------*/
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",NSLocalizedString(city.cityName,@"CityViewController.m"),NSLocalizedString(city.provinceName,@"CityViewController.m")];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // SidebarViewController *sidbarVC = [SidebarViewController share];
    // WeatherMainViewController *weatherMainVC =  (WeatherMainViewController *)sidbarVC.currentMainController;
    CurrentCity *city = [_searchResults objectAtIndex:indexPath.row];
    // [weatherMainVC loadCityIdString:city.areaId];
    
    [self doSelectCity:city];
    
}

#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (finish != YES) {
        return;
    }
    self.navigationController.navigationBar.hidden = YES;
    _searchResults = [[NSMutableArray alloc]init];
    
    if (_mySearchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:_mySearchBar.text]) {
        for (int i=0; i<_cityNameArray.count; i++) {
            if ([ChineseInclude isIncludeChineseInString:_cityNameArray[i]]) {
                if (i > _cityListPinyinArray.count - 1) break;
                NSString *tempPinYinStr = [_cityListPinyinArray objectAtIndex:i];//[PinYinForObjc chineseConvertToPinYin:cityNameArray[i]];
                NSRange titleResult=[tempPinYinStr rangeOfString:_mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:_cityListCountArray[i]];
                } else {
                    if (i > _cityListPinyinHeadArray.count - 1) break;
                    NSString *tempPinYinHeadStr = [_cityListPinyinHeadArray objectAtIndex:i];//[PinYinForObjc chineseConvertToPinYinHead:cityNameArray[i]];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:_mySearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        [_searchResults addObject:_cityListCountArray[i]];
                    }
                }
            }
            else {
                NSRange titleResult = [_cityNameArray[i] rangeOfString:_mySearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [_searchResults addObject:_cityListCountArray[i]];
                }
            }
        }
        [_myTableView reloadData];
        
    } else if (_mySearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:_mySearchBar.text]) {
        int count = 0;
        for (NSString *tempStr in _cityNameArray) {
            NSRange titleResult = [tempStr rangeOfString:_mySearchBar.text options:NSCaseInsensitiveSearch];
            if (titleResult.length>0) {
                [_searchResults addObject:_cityListCountArray[count]];
                [_myTableView reloadData];
            }
            count ++;
        }
        [_myTableView reloadData];
    }
    [_myTableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            /*---------------------------ybyao------------------------*/
            [btn setTitle:NSLocalizedString(@"取消",@"CityViewController.m")  forState:UIControlStateNormal];
        }
    }
    _myTableView.hidden = NO;
    [_searchResults removeAllObjects];
    [_myTableView reloadData];
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.text = @"";
    for(id cc in [searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            /*-------------------ybyao---------------*/
            [btn setTitle:NSLocalizedString(@"取消",@"CityViewController.m")   forState:UIControlStateNormal];
        }
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _myTableView.hidden = YES;
    searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _myTableView.hidden = YES;
    _mySearchBar.text = @"";
    [_mySearchBar resignFirstResponder];
}
@end
