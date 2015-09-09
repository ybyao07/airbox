//
//  CitySelectionViewController.m
//  AirManager
//

#import "CitySelectionViewController.h"
#import "CityDataHelper.h"
#import "UIDevice+Resolutions.h"
#import "WeatherManager.h"
#import "MainViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AlertBox.h"
#import "AppDelegate.h"
#import "MainViewController.h"

@interface CitySelectionViewController ()
{
    IBOutlet UIButton *backBtn;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    IBOutlet UIButton *locationCity;
    NSString *curCity;
}

@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)CLGeocoder *geocoder;
@property(nonatomic,strong)NSString *curCity;

@end

@implementation CitySelectionViewController

@synthesize fromDeviceBind;
@synthesize locationManager;
@synthesize geocoder;
@synthesize curCity;

- (void)dealloc
{
    DDLogFunction();
}

- (void)viewDidLoad
{
    DDLogFunction();
    
    [super viewDidLoad];
    
    if(fromDeviceBind)
    {
        backBtn.hidden = YES;
    }
    else
    {
        backBtn.hidden = NO;
    }
    
    _cityArray =  [CityDataHelper cityArray];
    _filteredCityArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    [self customTableView:_tableView];
    [self customTableView:self.searchDisplayController.searchResultsTableView];
    
    [locationCity setTitle:(@"正在定位到当前城市...") forState:UIControlStateNormal];
    locationCity.hidden = NO;
    locationCity.userInteractionEnabled = NO;
    
    [self performSelector:@selector(currentLocation) withObject:nil afterDelay:1];
}

- (void)didReceiveMemoryWarning
{
    DDLogFunction();
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if(locations.count > 0)
    {
        [locationManager stopUpdatingLocation];
        CLLocation *location = locations[0];
        //        CLLocation *location = [[CLLocation alloc] initWithLatitude:39.97407261 longitude:116.31658868];
        CLGeocoder *tempGeocoder = [[CLGeocoder alloc] init];
        self.geocoder = tempGeocoder;
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placeMarks,NSError *error){
            if(error)
            {
                [self locationCityFailed];
            }
            else
            {
                if(placeMarks.count > 0)
                {
                    CLPlacemark *placeMark = placeMarks[0];
                    
                    NSString  *beijin=@"北京市",
                              *shanghai=@"上海市",
                              *tianjin=@"天津市",
                              *chongqin=@"重庆市";
                    
                    if ([placeMark.administrativeArea isEqualToString:beijin]
                        || [placeMark.administrativeArea isEqualToString:shanghai]
                        || [placeMark.administrativeArea isEqualToString:tianjin]
                        || [placeMark.administrativeArea isEqualToString:chongqin])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *title = [NSString stringWithFormat:@"当前定位城市: %@",placeMark.administrativeArea];
                            [locationCity setTitle:title forState:UIControlStateNormal];
                            locationCity.hidden = NO;
                            locationCity.userInteractionEnabled = YES;
                            self.curCity = placeMark.administrativeArea;
                        });
                    }
                    else  if(placeMark.locality.length > 0)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *title = [NSString stringWithFormat:@"当前定位城市: %@",placeMark.locality];
                            [locationCity setTitle:title forState:UIControlStateNormal];
                            locationCity.hidden = NO;
                            locationCity.userInteractionEnabled = YES;
                            self.curCity = placeMark.locality;
                        });
                    }
                    else
                    {
                        [self locationCityFailed];
                    }
                }
                else
                {
                    [self locationCityFailed];
                }
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self locationCityFailed];
}

- (void)locationCityFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[AlertBox showWithMessage:Localized(@"定位到当前城市失败")];
        [locationCity setTitle:(@"定位到当前城市失败") forState:UIControlStateNormal];
        locationCity.hidden = NO;
        locationCity.userInteractionEnabled = NO;
    });
}

#pragma mark - Private Methods

- (void)currentLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = (id)self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
    else
    {
        [AlertBox showWithMessage:Localized(@"定位服务不可用,请到设置里面打开定位服务")];
    }
}

- (void)customTableView:(UITableView *)tableView
{
    //set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
    
    /*
     //set the offset cell separator
     BOOL isSystemVersionIsIos7 = [UIDevice isSystemVersionOnIos7];
     if (isSystemVersionIsIos7) {
     [tableView setSeparatorInset:UIEdgeInsetsZero];
     }
     */
}

- (void)exitCurrentPage
{
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    
    if(fromDeviceBind)
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
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - IBAction Methods

- (IBAction)back:(id)sender
{
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    if(geocoder.geocoding)
    {
        [geocoder cancelGeocode];
    }
    
    if(!fromDeviceBind)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)selectLocationCity:(id)sender
{
    for (int i = 0; i < _cityArray.count; i++)
    {
        NSDictionary *dic = _cityArray[i];
        if([curCity rangeOfString:dic[kCityName]].length > 0 || [[curCity lowercaseString] isEqualToString:dic[kCityNameEN]])
        {
            [CityDataHelper updateSelectedCity:dic];
            [[WeatherManager sharedInstance] stopAutoReload];
            [[WeatherManager sharedInstance] loadWeather];
            [self exitCurrentPage];
            return;
        }
    }
}

#pragma mark - UITableView Data Source / Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DDLogFunction();
    
    return ((tableView == _tableView) ? _cityArray.count : _filteredCityArray.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogFunction();
    
    static NSString *CellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.textLabel.font = [UIFont fontWithName:@"EuphemiaUCAS" size:17];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = kTextColor;
    }
    
    NSArray *array = (tableView == _tableView) ? _cityArray : _filteredCityArray;
    NSDictionary *city = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", city[kCityName], city[kProvinceID]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogFunction();
    
    if(![MainDelegate isNetworkAvailable])return;
    
    NSArray *array = (tableView == _tableView) ? _cityArray : _filteredCityArray;
    if (array.count <= indexPath.row) return;
    NSDictionary *city = array[indexPath.row];
    [CityDataHelper updateSelectedCity:city];
    [[WeatherManager sharedInstance] stopAutoReload];
    [[WeatherManager sharedInstance] loadWeather];
    [NotificationCenter postNotificationName:CityChangedNotification object:nil userInfo:nil];
    [self exitCurrentPage];
}

#pragma mark - UISearchDisplay Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    DDLogFunction();
    
    [_filteredCityArray removeAllObjects];
    
    for (NSDictionary *city in _cityArray)
    {
        NSRange range = [city[kCityName] rangeOfString:searchString options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound)
        {
            range = [city[kCityNameEN] rangeOfString:searchString options:NSCaseInsensitiveSearch];
        }
        
        if (range.location != NSNotFound)
        {
            [_filteredCityArray addObject:city];
        }
    }
    
    return YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    DDLogFunction();
}

@end
