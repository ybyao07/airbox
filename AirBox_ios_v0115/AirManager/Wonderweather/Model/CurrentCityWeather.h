//
//  CurrentCityWeather.h
//  wonderweather
//
//  Created by zhongke on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CurrentCity.h"
#import "InstantWeather.h"

@interface CurrentCityWeather : NSObject
@property (strong,nonatomic) CurrentCity *city;
@property (strong,nonatomic) InstantWeather *weather;
// WeekEntity
@property (strong,nonatomic) NSArray *fiveDaysWeathers;
@property (strong,nonatomic) NSArray *todayWeathers;
@property (strong,nonatomic) NSArray *weatherIndex;
@property (strong,nonatomic) NSString *air;
@property (strong,nonatomic) NSString *freesLike;
- (void)parseData:(NSDictionary *)dictionary;

- (NSDictionary *)toDictionary;
@end
