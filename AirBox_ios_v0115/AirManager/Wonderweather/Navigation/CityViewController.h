//
//  CityViewController.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-21.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CitySelectedProtocol.h"
#import "MobClick.h"
#import "LocationController.h"

@interface CityViewController : UIViewController<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,LocationDelegate>
{
    NSMutableArray *_searchResults;
    UISearchDisplayController *searchDisplayController;
    UITableView *_myTableView;
}
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (weak, nonatomic) IBOutlet UIView *baseview;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (strong, nonatomic) NSMutableArray *cityListArray;
@property (nonatomic, weak) id<CitySelectedProtocol> citySelectedProtocol;
@property (nonatomic) CLLocationManager *lm;
@property(nonatomic,assign)BOOL fromDeviceBind;
@property (nonatomic,strong)  UIViewController *parentVC;

- (IBAction)back:(id)sender;
+ (void)readDataCityListString;
+ (NSString *)getCityNameByID:(NSString *)cityID;
+ (NSString *)getCityIDByName :(NSString *)cityName;
@end
