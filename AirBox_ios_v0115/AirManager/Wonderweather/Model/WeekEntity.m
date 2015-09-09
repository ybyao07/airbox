//
//  WeekEntity.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "WeekEntity.h"


@implementation WeekEntity

-(WeekEntity *)initWithDic:(NSMutableDictionary *)dic{
    
    NSArray *array = [dic allKeys];
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithObjects:array forKeys:array];
    
    for (NSString *str in array) {
        
        if ([[dic objectForKey:str] isKindOfClass:[NSNull class]]) {
            [tmpDic setValue:@"" forKey:str];
        }
        else if ([[dic objectForKey:str] isKindOfClass:[NSNumber class]]) {
            [tmpDic setValue:[NSString stringWithFormat:@"%d",[[dic objectForKey:str] intValue]] forKey:str];
        }else
        {
            [tmpDic setValue:[dic objectForKey:str] forKey:str];
        }
    }

    if (self = [super init]) {
        self.week = [tmpDic objectForKey:@"week"];
        self.day_temp = [tmpDic objectForKey:@"day_temp"];
        self.day_weather = [tmpDic objectForKey:@"day_weather"];
        self.day_wind = [tmpDic objectForKey:@"day_wind"];
        self.day_wind_direction = [tmpDic objectForKey:@"day_wind_direction"];

        self.night_temp = [tmpDic objectForKey:@"night_temp"];
        self.night_weather = [tmpDic objectForKey:@"night_weather"];
        self.night_wind = [tmpDic objectForKey:@"night_wind"];
        self.night_wind_direction = [tmpDic objectForKey:@"night_wind_direction"];
        
        self.date = [tmpDic objectForKey:@"date"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_week != nil) {
        [tmpDict setObject:_week forKey:@"week"];
    }
    if (_day_temp != nil) {
        [tmpDict setObject:_day_temp forKey:@"day_temp"];
    }
    if (_day_weather != nil) {
        [tmpDict setObject:_day_weather forKey:@"day_weather"];
    }
    
    if (_day_wind != nil) {
        [tmpDict setObject:_day_wind forKey:@"day_wind"];
    }
    if (_day_wind_direction != nil) {
        [tmpDict setObject:_day_wind_direction forKey:@"day_wind_direction"];
    }
    if (_night_temp != nil) {
        [tmpDict setObject:_night_temp forKey:@"night_temp"];
    }
    if (_night_weather != nil) {
        [tmpDict setObject:_night_weather forKey:@"night_weather"];
    }
    if (_night_wind != nil) {
        [tmpDict setObject:_night_wind forKey:@"night_wind"];
    }
    if (_night_wind_direction != nil) {
        [tmpDict setObject:_night_wind_direction forKey:@"night_wind_direction"];
    }
    if (_date != nil) {
        [tmpDict setObject:_date forKey:@"date"];
    }
    
    return tmpDict;
}

@end
