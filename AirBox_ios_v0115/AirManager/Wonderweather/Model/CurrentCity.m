//
//  CurrentCity.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "CurrentCity.h"

@implementation CurrentCity
-(CurrentCity *)initWithDic:(NSDictionary *)dic
{
    
    NSArray *array = [dic allKeys];
    
    for (NSString *str in array) {
        
        if ([[dic objectForKey:str] isKindOfClass:[NSNull class]]) {
            [dic setValue:@"" forKey:str];
        }
        if ([[dic objectForKey:str] isKindOfClass:[NSNumber class]]) {
            [dic setValue:[NSString stringWithFormat:@"%d",[[dic objectForKey:str] intValue]] forKey:str];
        }
    }

    if (self = [super init]) {
        _areaId = [dic objectForKey:@"areaId"];
        _cityName = [dic objectForKey:@"city_name"];
        _provinceName = [dic objectForKey:@"province_name"];
        
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_areaId != nil) {
        [tmpDict setObject:_areaId forKey:@"areaId"];
    }
    if (_cityName != nil) {
        [tmpDict setObject:_cityName forKey:@"city_name"];
    }
    if (_provinceName != nil) {
        [tmpDict setObject:_provinceName forKey:@"province_name"];
    }
    return tmpDict;
}


@end
