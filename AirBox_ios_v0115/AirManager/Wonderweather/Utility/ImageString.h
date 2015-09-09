//
//  ImageString.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageString : NSObject
+ (NSString *)getImageString:(NSString *)day_weather;
+ (NSString *)getMainImageString:(NSString *)day_weather;
+ (NSString *)getLightImageString:(NSString *)day_weather;
+ (NSString *)getBackroudImageString:(NSString *)day_temperature;
+ (NSString *)getBlueImageString:(NSString *)day_weather;
+ (NSString *)getIndexHeadImageStr:(NSString *)indexStr;
+ (NSString *)getIndexImageStr:(NSString *)NameStr;
+ (NSString *)getIndexContentStr:(NSString *)NameStr;
+ (NSString *)getAirManagerBackroudImageString:(NSString *)day_weather;
@end
