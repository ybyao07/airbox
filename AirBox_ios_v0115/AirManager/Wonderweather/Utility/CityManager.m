//
//  CityManager.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "CityManager.h"
#import "WeekEntity.h"
#import "AppDelegate.h"

@interface CityManager()
@property (nonatomic) NSMutableArray *cityList;
@end

@implementation CityManager
static CityManager *cityManager;

+ (CityManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cityManager = [[CityManager alloc] init];
    });
    return cityManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _cityList = [[NSMutableArray alloc] init];
        [self load];
    }

    return self;
}

- (void)save
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < [_cityList count]; i++) {
        CurrentCityWeather *weekentity = [_cityList objectAtIndex:i];
        [arr addObject:[weekentity toDictionary]];
    }
    [dic setObject:arr forKey:@"city_list"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path;
    //ybyao
//    if ([MainDelegate isLanguageEnglish]) {
//        database_path = [documents stringByAppendingPathComponent:@"weatherEn.plist"];
//    }
//    else{
        database_path = [documents stringByAppendingPathComponent:@"weather.plist"];
//    }
    
    
    [dic writeToFile:database_path atomically:YES];
    
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path;
    //ybyao
//    if ([MainDelegate isLanguageEnglish]) {
//        database_path = [documents stringByAppendingPathComponent:@"weatherEn.plist"];
//    }
//    else{
          database_path = [documents stringByAppendingPathComponent:@"weather.plist"];
//    }
  

    NSDictionary *dict;
    dict = [[NSDictionary alloc ]initWithContentsOfFile:database_path];

    NSArray *tmpArray = [dict objectForKey:@"city_list"];
    if (tmpArray == nil) return;
    if(![tmpArray isKindOfClass:[NSArray class]]) return;

    NSDictionary *tmpDictionary;
    CurrentCityWeather *weather;
    for (int i = 0; i < [tmpArray count]; i++) {
        tmpDictionary = [tmpArray objectAtIndex:i];
        weather = [[CurrentCityWeather alloc] init];
        [weather parseData:tmpDictionary];
        [_cityList addObject:weather];
    }
    
}


- (NSArray *)currentCityList
{
    return _cityList;
}

- (void)setCurrentCity:(CurrentCityWeather *)currentCityWeather
{
    [self save];
}

- (void)removeCity:(CurrentCityWeather *)currentCityWeather
{
    if (currentCityWeather == nil) return;
//    CurrentCityWeather *tmpWeather;
//    for (int i = 0; i < _cityList.count;++i) {
//        tmpWeather = [_cityList objectAtIndex:i];
//        if ([tmpWeather.city.areaId isEqualToString:currentCityWeather.city.areaId] ) {
//            _cityList.
//        }
//    }
    [_cityList removeObject:currentCityWeather];
    [self save];
}

- (CurrentCityWeather *)currentCityWeather
{
    if ([_cityList count]> 0) {
        
        return [_cityList firstObject];
    }
    return nil;
}

- (void)addCity:(CurrentCityWeather *)currentCityWeather
{
    if (currentCityWeather == nil) return;
    [_cityList addObject:currentCityWeather];
    [self save];
}

- (void)changeCurrentCity:(CurrentCityWeather *)currentCityWeather
{
    if (currentCityWeather == nil) return;
    [_cityList removeObject:currentCityWeather];
    [_cityList insertObject:currentCityWeather atIndex:0];
    [self save];
}

- (BOOL)hasCity:(CurrentCityWeather *)currentCityWeather
{
    for (CurrentCityWeather *tmpWeather in _cityList) {
        if ([tmpWeather.city.areaId isEqualToString:currentCityWeather.city.areaId] ) {
            return YES;
        }
    }
    return NO;
}

- (CurrentCityWeather *)currentCityForID:(NSString *)areaID areaName:(NSString*)areaName
{
    if (areaID == nil) return nil;

    for (CurrentCityWeather *tmpWeather in _cityList) {
        if ([tmpWeather.city.areaId isEqualToString:areaID]&&[tmpWeather.city.cityName isEqualToString:areaName] ) {
            return tmpWeather;
        }
    }
    return nil;
}

- (BOOL)hasCapacityForNewCity
{
    return _cityList.count < 9;
}
@end
