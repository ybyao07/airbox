//
//  CurrentCity.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstantWeather.h"
@interface CurrentCity : NSObject
@property (copy, nonatomic) NSString *areaId;
@property (copy, nonatomic) NSString *cityName;
@property (copy, nonatomic) NSString *provinceName;


-(CurrentCity *)initWithDic:(NSDictionary *)dic;
- (NSDictionary *)toDictionary;
@end
