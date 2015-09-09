//
//  InstantWeather.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "InstantWeather.h"

@implementation InstantWeather

-(InstantWeather *)initWithDic:(NSMutableDictionary *)dic
{
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
        self.wind_direction = [tmpDic objectForKey:@"wind_direction"];
        self.humidy = [tmpDic objectForKey:@"humidy"];
        self.weather = [tmpDic objectForKey:@"weather"];
        self.wind = [tmpDic objectForKey:@"wind"];
        self.temperature = [tmpDic objectForKey:@"temperature"];
        self.time = [tmpDic objectForKey:@"time"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_wind_direction != nil) {
        [tmpDict setObject:_wind_direction forKey:@"wind_direction"];
    }
    if (_humidy != nil) {
        [tmpDict setObject:_humidy forKey:@"humidy"];
    }
    if (_weather != nil) {
        [tmpDict setObject:_weather forKey:@"weather"];
    }
    
    if (_wind != nil) {
        [tmpDict setObject:_wind forKey:@"wind"];
    }
    if (_temperature != nil) {
        [tmpDict setObject:_temperature forKey:@"temperature"];
    }
    if (_time != nil) {
        [tmpDict setObject:_time forKey:@"time"];
    }

    
    return tmpDict;
}

@end
