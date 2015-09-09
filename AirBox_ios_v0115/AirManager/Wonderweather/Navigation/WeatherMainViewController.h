//
//  WeatherMainViewController.h
//  wonderweather
//
//  Created by zhongke on 14-5-21.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"
#import "WeekEntity.h"
#import "CurrentCity.h"
#import "Weather24.h"
#import "IndexData.h"
#import "AirData.h"
#import "CurrentCityWeather.h"
#import "CitySelectedProtocol.h"
#import "MobClick.h"
#import "TempIndexView.h"
#import "IndexContentView.h"

@interface WeatherMainViewController : UIViewController
<
  UITableViewDataSource,
  UITableViewDelegate,
  CitySelectedProtocol,
  UIActionSheetDelegate
>
{
    MJRefreshHeaderView *_header;
    TempIndexView *_tempIndexView;
    IndexContentView *_indexContV;
}
@property (weak, nonatomic) IBOutlet UIView *viewWeekSuperTop;
@property (weak, nonatomic) IBOutlet UIView *viewWeekSuper;
@property (weak, nonatomic) IBOutlet UILabel *splitLineWeather;
@property (weak, nonatomic) IBOutlet UIImageView *topView;
@property (weak, nonatomic) IBOutlet UILabel *splitLineView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (copy, nonatomic) CurrentCityWeather *weather;

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIView *weekview;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UIScrollView *timeView;

@property (weak, nonatomic) IBOutlet UILabel *labelWeather;
@property (weak, nonatomic) IBOutlet UIImageView *weather_imageView;
@property (weak, nonatomic) IBOutlet UIImageView *first_digil;
@property (weak, nonatomic) IBOutlet UILabel *lebalFengLiDangwei;
@property (weak, nonatomic) IBOutlet UIImageView *second_digil;
@property (weak, nonatomic) IBOutlet UIImageView *digilImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UILabel *city_name;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidyLabel;
@property (weak, nonatomic) IBOutlet UILabel *windDre;
@property (weak, nonatomic) IBOutlet UILabel *windRank;
@property (weak, nonatomic) IBOutlet UILabel *tempQuality;
@property (weak, nonatomic) IBOutlet UILabel *qualityRank;
@property (weak, nonatomic) IBOutlet UILabel *freeslikeLable;
@property (weak, nonatomic) IBOutlet UILabel *tmpDangwei;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *autoIndexButton;

- (IBAction)Back:(id)sender;
- (void)addCity;

@end
