//
//  InstantWeather.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstantWeather : NSObject

@property (copy, nonatomic) NSString *wind_direction;
@property (copy, nonatomic) NSString *humidy;
@property (copy, nonatomic) NSString *weather;
@property (copy, nonatomic) NSString *wind;
@property (copy, nonatomic) NSString *temperature;
@property (copy, nonatomic) NSString *time;


-(InstantWeather *)initWithDic:(NSMutableDictionary *)dic;
- (NSDictionary *)toDictionary;
@end
