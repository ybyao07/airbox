//
//  CityManager.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "CurrentCityWeather.h"

@interface CityManager : NSObject

+ (CityManager *)sharedManager;

- (NSArray *)currentCityList;
- (void)removeCity:(CurrentCityWeather *)currentCityWeather;
- (CurrentCityWeather *)currentCityWeather;
- (void)changeCurrentCity:(CurrentCityWeather *)currentCityWeather;
- (CurrentCityWeather *)currentCityForID:(NSString *)areaID areaName:(NSString*)areaName;
- (void)addCity:(CurrentCityWeather *)currentCityWeather;
- (void)save;
- (BOOL)hasCity:(CurrentCityWeather *)currentCityWeather;
- (BOOL)hasCapacityForNewCity;

@end
