//
//  CurrentCityWeather.m
//  wonderweather
//
//  Created by zhongke on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "CurrentCityWeather.h"
#import "WeekEntity.h"
#import "Weather24.h"
#import "IndexData.h"

@implementation CurrentCityWeather

- (id)init
{
    self =[super init];
    if (self) {
        _city = [[CurrentCity alloc] init];
        _weather = [[InstantWeather alloc] init];
        _fiveDaysWeathers = [NSArray array];
        _todayWeathers  = [NSArray array];
        _weatherIndex  = [NSArray array];
    }
    return self;
}

- (void)parseData:(NSDictionary *)dictionary
{
    NSDictionary *tmpDictionary;
    NSArray *tmpArray;
    
    tmpDictionary = [dictionary objectForKey:@"city"];
    if (tmpDictionary != nil) {
        _city = [[CurrentCity alloc] initWithDic:tmpDictionary];
    }

    tmpDictionary = [dictionary objectForKey:@"current_weather"];
    if (tmpDictionary != nil) {
        _weather = [[InstantWeather alloc] initWithDic:[NSMutableDictionary dictionaryWithDictionary:tmpDictionary]];
    }

    tmpArray = [dictionary objectForKey:@"day_forecast"];
    if (tmpArray != nil) {
        WeekEntity *dayForecast;
        NSMutableArray *dayForecasts = [NSMutableArray array];
        for (NSDictionary *dict in tmpArray) {
            dayForecast = [[WeekEntity alloc] initWithDic:[NSMutableDictionary dictionaryWithDictionary:dict]];
            [dayForecasts addObject:dayForecast];
        }
        _fiveDaysWeathers = [NSArray arrayWithArray:dayForecasts];
    }

    tmpArray = [dictionary objectForKey:@"hour_forecast"];
    if (tmpArray != nil) {
        Weather24 *hourForecast;
        NSMutableArray *dayForecasts = [NSMutableArray array];
        for (NSDictionary *dict in tmpArray) {
            hourForecast = [[Weather24 alloc] initWithDic:[NSMutableDictionary dictionaryWithDictionary:dict]];
            [dayForecasts addObject:hourForecast];
        }
        _todayWeathers = [NSArray arrayWithArray:dayForecasts];
    }
    
    tmpArray = [dictionary objectForKey:@"index"];
    if (tmpArray != nil) {
        IndexData *index;
        NSMutableArray *dayForecasts = [NSMutableArray array];
        for (NSDictionary *dict in tmpArray) {
            index = [[IndexData alloc] initWithDic:[NSMutableDictionary dictionaryWithDictionary:dict]];
            [dayForecasts addObject:index];
        }
        _weatherIndex = [NSArray arrayWithArray:dayForecasts];
    }
    
    NSString *tmpString = [dictionary objectForKey:@"air"];
    if (tmpString != nil) {
        _air = tmpString;
    }
    
    tmpString = [dictionary objectForKey:@"freesLike"];
    if (tmpString != nil) {
        _freesLike = tmpString;
    }

}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_city != nil) {
        [tmpDict setObject:[_city toDictionary] forKey:@"city"];
    }
    if (_weather != nil) {
        [tmpDict setObject:[_weather toDictionary] forKey:@"current_weather"];
    }
    if (_fiveDaysWeathers != nil) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        WeekEntity *dayForecast;
        for (int i = 0;i < _fiveDaysWeathers.count; ++i) {
            dayForecast = [_fiveDaysWeathers objectAtIndex:i];
            [tmpArray addObject:[dayForecast toDictionary]];
        }
        [tmpDict setObject:tmpArray forKey:@"day_forecast"];
    }
    if (_todayWeathers != nil) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        Weather24 *hourForecast;
        for (int i = 0;i < _todayWeathers.count; ++i) {
            hourForecast = [_todayWeathers objectAtIndex:i];
            [tmpArray addObject:[hourForecast toDictionary]];
        }
        [tmpDict setObject:tmpArray forKey:@"hour_forecast"];
    }
    
    if (_weatherIndex != nil) {
        NSMutableArray *tmpArray = [NSMutableArray array];
        IndexData *index;
        for (int i = 0;i < _weatherIndex.count; ++i) {
            index = [_weatherIndex objectAtIndex:i];
            if ([index isKindOfClass:[NSNull class]]) {
                break;
            }else
            {
            [tmpArray addObject:[index toDictionary]];
            }
        }
        if (tmpArray.count != 0) {
            [tmpDict setObject:tmpArray forKey:@"index"];
        }
    }
    
    if (_air != nil) {
        [tmpDict setObject:_air forKey:@"air"];
    }
    
    if (_freesLike!= nil) {
        [tmpDict setObject:_freesLike forKey:@"freesLike"];
    }

    return tmpDict;
}
@end
