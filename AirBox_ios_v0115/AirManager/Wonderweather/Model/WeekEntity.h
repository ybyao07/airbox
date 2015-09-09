//
//  WeekEntity.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeekEntity : NSObject
@property (copy, nonatomic) NSString *week;
@property (copy, nonatomic) NSString *day_temp;
@property (copy, nonatomic) NSString *day_weather;
@property (copy, nonatomic) NSString *day_wind;
@property (copy, nonatomic) NSString *day_wind_direction;

@property (copy, nonatomic) NSString *night_temp;
@property (copy, nonatomic) NSString *night_weather;
@property (copy, nonatomic) NSString *night_wind;
@property (copy, nonatomic) NSString *night_wind_direction;

@property (copy, nonatomic) NSString *date;

-(WeekEntity *)initWithDic:(NSMutableDictionary *)dic;
- (NSDictionary *)toDictionary;
@end

