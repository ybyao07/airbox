//
//  ImageString.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "ImageString.h"

@implementation ImageString

+ (NSString *)getImageString:(NSString *)day_weather
{
    NSDictionary *dic = @{
                            NSLocalizedString(@"晴",): @"Sunny.png",
                            NSLocalizedString(@"晴天有云",): @"Cloudy.png",
                            NSLocalizedString(@"多云",): @"Cloudy.png",
                            NSLocalizedString(@"阴",):@"Overcast.png",
                            NSLocalizedString(@"阵雨",):@"Shower.png",
                          
                            NSLocalizedString(@"雷阵雨",):@"Thundershower.png",
                            NSLocalizedString(@"雷阵雨伴有冰雹",): @"Thundershower_with_hail.png",
                          
                            NSLocalizedString(@"雨夹雪",): @"Sleet.png",
                            NSLocalizedString(@"小雨",): @"Light_rain.png",
                            NSLocalizedString( @"中雨",): @"Moderate_rain.png",
                            NSLocalizedString(@"大雨",): @"Heavy_rain.png",
                            NSLocalizedString(@"暴雨",): @"Storm.png",
                            NSLocalizedString(@"大暴雨",): @"Storm.png",
                            NSLocalizedString(@"特大暴雨",): @"Storm.png",
                            NSLocalizedString(@"冻雨",): @"Ice_rain.png",
                            NSLocalizedString(@"小到中雨",): @"Moderate_rain.png",
                            NSLocalizedString(@"中到大雨",): @"Heavy_rain.png",
                            NSLocalizedString(@"大到暴雨",): @"Storm.png",
                            NSLocalizedString(@"暴雨到大暴雨",): @"Storm.png",
                            NSLocalizedString(@"大暴雨到特大暴雨",): @"Storm.png",
                            NSLocalizedString(@"大暴雨",): @"Storm.png",
                          
                            NSLocalizedString(@"阵雪",):@"Heavy_snow.png",
                            NSLocalizedString(@"小雪",):@"Light_snow.png",
                            NSLocalizedString(@"中雪",):@"Moderate_snow.png",
                            NSLocalizedString(@"大雪",): @"Heavy_snow.png",
                            NSLocalizedString(@"暴雪",): @"Snowstorm.png",
                            NSLocalizedString(@"小到中雪",): @"Moderate_snow.png",
                            NSLocalizedString(@"中到大雪",): @"Heavy_snow.png",
                            NSLocalizedString(@"大到暴雪",):@"Snowstorm.png",
                          
                            NSLocalizedString(@"雾",):@"Foggy.png",
                          
                            NSLocalizedString(@"沙尘暴",):@"Duststorm.png",
                            NSLocalizedString(@"浮尘",): @"Dust.png",
                            NSLocalizedString(@"扬沙",): @"Sand.png",
                            NSLocalizedString(@"强沙尘暴",): @"Sandstorm.png",
                          
                            NSLocalizedString(@"霾",): @"Haze.png"
                          };
    NSString *string = [dic valueForKey:day_weather];
    if (string == nil) {
        string = @"Sunny.png";
    }
    return string;
}

+ (NSString *)getLightImageString:(NSString *)day_weather
{
    NSDictionary *dic = @{
                          NSLocalizedString(@"晴",): @"Sunny_light.png",
                          NSLocalizedString(@"晴天有云",): @"Cloudy_light.png",
                          NSLocalizedString(@"多云",): @"Cloudy_light.png",
                          NSLocalizedString(@"阴",):@"Overcast_light.png",
                          NSLocalizedString(@"阵雨",):@"Shower_light.png",
                          
                          NSLocalizedString(@"雷阵雨",):@"Thundershower_light.png",
                          NSLocalizedString(@"雷阵雨伴有冰雹",): @"Thundershower_with_hail_light.png",
                          
                          NSLocalizedString(@"雨夹雪",): @"Sleet_light.png",
                          NSLocalizedString(@"小雨",): @"Light_rain_light.png",
                          NSLocalizedString(@"中雨",): @"Moderate_rain_light.png",
                          NSLocalizedString(@"大雨",): @"Heavy_rain_light.png",
                          NSLocalizedString(@"暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"大暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"特大暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"冻雨",): @"Ice_rain_light.png",
                          NSLocalizedString(@"小到中雨",): @"Moderate_rain_light.png",
                          NSLocalizedString(@"中到大雨",): @"Heavy_rain_light.png",
                          NSLocalizedString(@"大到暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"暴雨到大暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"大暴雨到特大暴雨",): @"Storm_light.png",
                          NSLocalizedString(@"大暴雨",): @"Storm_light.png",
                          
                          NSLocalizedString(@"阵雪",):@"Heavy_snow_light.png",
                          NSLocalizedString(@"小雪",):@"Light_snow_light.png",
                          NSLocalizedString(@"中雪",):@"Moderate_snow_light.png",
                          NSLocalizedString(@"大雪",): @"Heavy_snow_light.png",
                          NSLocalizedString(@"暴雪",): @"Snowstorm_light.png",
                          NSLocalizedString(@"小到中雪",): @"Moderate_snow_light.png",
                          NSLocalizedString(@"中到大雪",): @"Heavy_snow_light.png",
                          NSLocalizedString(@"大到暴雪",):@"Snowstorm_light.png",
                          
                          NSLocalizedString(@"雾",):@"Foggy_light.png",
                          
                          NSLocalizedString(@"沙尘暴",):@"Duststorm_light.png",
                          NSLocalizedString(@"浮尘",): @"Dust_light.png",
                          NSLocalizedString(@"扬沙",): @"Sand_light.png",
                          NSLocalizedString(@"强沙尘暴",): @"Sandstorm_light.png",
                          
                          NSLocalizedString(@"霾",): @"Haze_light.png"
                          };
    NSString *string = [dic valueForKey:day_weather];
    if (string == nil) {
        string = @"Sunny_light.png";
    }
    return string;
}

+ (NSString *)getMainImageString:(NSString *)day_weather
{
    NSDictionary *dic = @{
                          NSLocalizedString(@"晴",): @"Sunny_main.png",
                          NSLocalizedString(@"晴天有云",): @"Cloudy_main.png",
                          NSLocalizedString(@"多云",): @"Cloudy_main.png",
                          NSLocalizedString(@"阴",):@"Overcast_main.png",
                          NSLocalizedString(@"阵雨",):@"Shower_main.png",
                          
                          NSLocalizedString(@"雷阵雨",):@"Thundershower_main.png",
                          NSLocalizedString(@"雷阵雨伴有冰雹",): @"Thundershower_with_hail_main.png",
                          
                          NSLocalizedString(@"雨夹雪",): @"Sleet_main.png",
                          NSLocalizedString(@"小雨",): @"Light_rain_main.png",
                          NSLocalizedString(@"中雨",): @"Moderate_rain_main.png",
                          NSLocalizedString(@"大雨",): @"Heavy_rain_main.png",
                          NSLocalizedString(@"暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"大暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"特大暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"冻雨",): @"Ice_rain_main.png",
                          NSLocalizedString(@"小到中雨",): @"Moderate_rain_main.png",
                          NSLocalizedString(@"中到大雨",): @"Heavy_rain_main.png",
                          NSLocalizedString(@"大到暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"暴雨到大暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"大暴雨到特大暴雨",): @"Storm_main.png",
                          NSLocalizedString(@"大暴雨",): @"Storm_main.png",
                          
                          NSLocalizedString(@"阵雪",):@"Heavy_snow_main.png",
                          NSLocalizedString(@"小雪",):@"Light_snow_main.png",
                          NSLocalizedString(@"中雪",):@"Moderate_snow_main.png",
                          NSLocalizedString(@"大雪",): @"Heavy_snow_main.png",
                          NSLocalizedString(@"暴雪",): @"Snowstorm_main.png",
                          NSLocalizedString(@"小到中雪",): @"Moderate_snow_main.png",
                          NSLocalizedString(@"中到大雪",): @"Heavy_snow_main.png",
                          NSLocalizedString(@"大到暴雪",):@"Snowstorm_main.png",
                          
                          NSLocalizedString(@"雾",):@"Foggy_main.png",
                          
                          NSLocalizedString(@"沙尘暴",):@"Duststorm_main.png",
                          NSLocalizedString(@"浮尘",): @"Dust_main.png",
                          NSLocalizedString(@"扬沙",): @"Sand_main.png",
                          NSLocalizedString(@"强沙尘暴",): @"Sandstorm_main.png",
                          
                          NSLocalizedString(@"霾",): @"Haze_main.png"
                          };
   
    NSString *string = [dic valueForKey:day_weather];
    if (string == nil) {
        string = @"";
    }
    return string;
}


+ (NSString *)getBackroudImageString:(NSString *)day_temperature
{
    NSString *string = @"background_green.png";
    if(day_temperature != nil && [day_temperature length] > 0)
    {
        NSInteger temperature = [day_temperature integerValue];
        if(temperature >= 35)
        {
            string = @"background_Orange.png";
        }
        else if( temperature >=20 &&  temperature < 35)
        {
            string = @"background_Yellow.png";
        }
        else if( temperature >=5 &&  temperature < 20)
        {
            string = @"background_green.png";
        }
        else if( temperature >=-10 &&  temperature < 5)
        {
            string = @"background_Blue.png";
        }
        else
        {
            string = @"background_Blue_Purple.png";
        }
        
    }
    return string;
}


+ (NSString *)getAirManagerBackroudImageString:(NSString *)day_weather
{
    NSDictionary *dic = @{
                          @"晴": @"sun_backgrond.png",
                          
                          @"晴天有云": @"cloud_background.png",
                          @"多云": @"cloud_background.png",
                          @"阴":@"cloud_background.png",
                          
                          @"阵雨":@"rain_background.png",
                          @"雷阵雨":@"rain_background.png",
                          @"雷阵雨伴有冰雹": @"rain_background.png",
                          @"雨夹雪": @"rain_background.png",
                          @"小雨": @"rain_background.png",
                          @"中雨": @"rain_background.png",
                          @"大雨": @"rain_background.png",
                          @"暴雨": @"rain_background.png",
                          @"大暴雨": @"rain_background.png",
                          @"特大暴雨": @"rain_background.png",
                          @"冻雨": @"rain_background.png",
                          @"小到中雨": @"rain_background.png",
                          @"中到大雨": @"rain_background.png",
                          @"大到暴雨": @"rain_background.png",
                          @"暴雨到大暴雨": @"rain_background.png",
                          @"大暴雨到特大暴雨": @"rain_background.png",
                          @"大暴雨": @"rain_background.png",
                          
                          @"阵雪":@"snow_background.png",
                          @"小雪":@"snow_background.png",
                          @"中雪":@"snow_background.png",
                          @"大雪": @"snow_background.png",
                          @"暴雪": @"snow_background.png",
                          @"小到中雪": @"snow_background.png",
                          @"中到大雪": @"snow_background.png",
                          @"大到暴雪":@"snow_background.png",
                          
                          @"雾":@"haze_background.png",
                          @"沙尘暴":@"haze_background.png",
                          @"浮尘": @"haze_background.png",
                          @"扬沙": @"haze_background.png",
                          @"强沙尘暴": @"haze_background.png",
                          @"霾": @"haze_background.png"
                          };
    NSString *string = [dic valueForKey:day_weather];
    if (string == nil) {
        string = @"offline_backgrond.png";
    }
    return string;
}


+ (NSString *)getBlueImageString:(NSString *)day_weather
{
    NSDictionary *dic = @{
                          @"晴": @"Sunny_blue@2x.png",
                          @"晴天有云": @"Cloudy_blue@2x.png",
                          @"多云": @"Cloudy_blue@2x.png",
                          @"阴":@"Overcast_blue@2x.png",
                          @"阵雨":@"Shower_blue@2x.png",
                          
                          @"雷阵雨":@"Thundershower_blue@2x.png",
                          @"雷阵雨伴有冰雹": @"Thundershower_with_hail_blue@2x.png",
                          
                          @"雨夹雪": @"Sleet_blue.png",
                          @"小雨": @"Light_rain_blue.png",
                          @"中雨": @"Moderate_rain_blue.png",
                          @"大雨": @"Heavy_rain_blue.png",
                          @"暴雨": @"Storm_blue.png",
                          @"大暴雨": @"Storm_blue.png",
                          @"特大暴雨": @"Storm_blue.png",
                          @"冻雨": @"Ice_rain_blue.png",
                          @"小到中雨": @"Moderate_rain_blue.png",
                          @"中到大雨": @"Heavy_rain_blue.png",
                          @"大到暴雨": @"Storm_blue.png",
                          @"暴雨到大暴雨": @"Storm_blue.png",
                          @"大暴雨到特大暴雨": @"Storm_blue.png",
                          @"大暴雨": @"Storm_blue.png",
                          
                          @"阵雪":@"Heavy_snow_blue.png",
                          @"小雪":@"Light_snow_blue.png",
                          @"中雪":@"Moderate_snow_blue.png",
                          @"大雪": @"Heavy_snow_blue.png",
                          @"暴雪": @"Snowstorm_blue.png",
                          @"小到中雪": @"Moderate_snow_blue.png",
                          @"中到大雪": @"Heavy_snow_blue.png",
                          @"大到暴雪":@"Snowstorm_blue.png",
                          
                          @"雾":@"Foggy_blue.png",
                          
                          @"沙尘暴":@"Duststorm_blue.png",
                          @"浮尘": @"Dust_blue.png",
                          @"扬沙": @"Sand_blue.png",
                          @"强沙尘暴": @"Sandstorm_blue.png",
                          
                          @"霾": @"Haze_blue.png"
                          };
    
    NSString *string = [dic valueForKey:day_weather];
    if (string == nil) {
        string = @"Sunny_blue.png";
    }
    return string;
}

+ (NSString *)getIndexHeadImageStr:(NSString *)indexStr
{
    NSDictionary *dic = @{
                          @"空调开启指数":@"ic_index_air_head@2x.png",
                          //                          @"息斯敏过敏指数":@"",
                          @"晨练指数":@"ic_index_morning_head@2x.png",
                          @"舒适度指数":@"ic_index_comfort_head@2x.png",
                          @"穿衣指数":@"ic_index_cloth_head@2x.png",
                          @"钓鱼指数":@"ic_index_fishing_head@2x.png",
                          @"防晒指数":@"ic_index_sunscreen_head@2x.png",
                          @"逛街指数":@"ic_index_shopping_head@2x.png",
                          @"感冒指数":@"ic_index_cold_head@2x.png",
                          @"划船指数":@"ic_index_rowing_head@2x.png",
                          @"交通指数":@"ic_index_traffic_head@2x.png",
                          @"路况指数":@"ic_index_road_head@2x.png",
                          @"晾晒指数":@"ic_index_drying_head@2x.png",
                          @"美发指数":@"ic_index_salon_head@2x.png",
                          //                          @"夜生活指数":@"",
                          @"啤酒指数":@"ic_index_beer_head@2x.png",
                          @"放风筝指数":@"ic_index_kite_head@2x.png",
                          @"空气污染扩散条件指数":@"ic_index_airpollution_head@2x.png",
                          @"化妆指数":@"ic_index_makeup_head@2x.png",
                          @"旅游指数":@"ic_index_tour_head@2x.png",
                          @"紫外线强度指数":@"ic_index_ultraviolet_head@2x.png",
                          @"风寒指数":@"ic_index_chill_head@2x.png",
                          @"洗车指数":@"ic_index_washCar_head@2x.png",
                          @"心情指数":@"ic_index_mood_head@2x.png",
                          @"运动指数":@"ic_index_sport_head@2x.png",
                          //                          @"约会指数":@"",
                          @"雨伞指数":@"ic_index_umbrella_head@2x.png",
                          @"中暑指数":@"ic_index_heatstroke_head@2x.png",                          };

    
    NSString *string = [dic valueForKey:indexStr];
    
    return string;
}

+ (NSString *)getIndexImageStr:(NSString *)NameStr
{
    NSDictionary *dic = @{
                          @"空调开启指数":@"ic_index_air@2x.png",
                          //                          @"息斯敏过敏指数":@"",
                          @"晨练指数":@"ic_index_morning@2x.png",
                          @"舒适度指数":@"ic_index_comfort@2x.png",
                          @"穿衣指数":@"ic_index_cloth@2x.png",
                          @"钓鱼指数":@"ic_index_fishing@2x.png",
                          @"防晒指数":@"ic_index_sunscreen@2x.png",
                          @"逛街指数":@"ic_index_shopping@2x.png",
                          @"感冒指数":@"ic_index_cold@2x.png",
                          @"划船指数":@"ic_index_rowing@2x.png",
                          @"交通指数":@"ic_index_traffic@2x.png",
                          @"路况指数":@"ic_index_road@2x.png",
                          @"晾晒指数":@"ic_index_drying@2x.png",
                          @"美发指数":@"ic_index_salon@2x.png",
                          //                          @"夜生活指数":@"",
                          @"啤酒指数":@"ic_index_beer@2x.png",
                          @"放风筝指数":@"ic_index_kite@2x.png",
                          @"空气污染扩散条件指数":@"ic_index_airpollution@2x.png",
                          @"化妆指数":@"ic_index_makeup@2x.png",
                          @"旅游指数":@"ic_index_tour@2x.png",
                          @"紫外线强度指数":@"ic_index_ultraviolet@2x.png",
                          @"风寒指数":@"ic_index_chill@2x.png",
                          @"洗车指数":@"ic_index_washCar@2x.png",
                          @"心情指数":@"ic_index_mood@2x.png",
                          @"运动指数":@"ic_index_sport@2x.png",
                          //                          @"约会指数":@"",
                          @"雨伞指数":@"ic_index_umbrella@2x.png",
                          @"中暑指数":@"ic_index_heatstroke@2x.png",
                          };
    
    
    NSString *string = [dic valueForKey:NameStr];
    
    if ([string isEqualToString:@""]) {
        string = @"ic_index_umbrella@2x.png";
    }else if(string == nil)
    {
        string = @"ic_index_umbrella@2x.png";
    }
    
    return string;
}

+ (NSString *)getIndexContentStr:(NSString *)NameStr
{
    NSDictionary *dic = @{
                          @"空调开启指数":@"今日是否适宜开启空调",
                          @"晨练指数":@"给您今日是否适宜晨练的建议",
                          @"舒适度指数":@"查询今日的舒适度",
                          @"穿衣指数":@"出行穿衣小贴士",
                          @"钓鱼指数":@"给您今日是否适宜钓鱼的建议",
                          @"防晒指数":@"出行时的防晒小贴士",
                          @"逛街指数":@"今日是否适宜逛街",
                          @"感冒指数":@"今日是否容易感冒",
                          @"划船指数":@"今日是否适宜划船",
                          @"交通指数":@"开车出行的交通状况",
                          @"路况指数":@"开车出行的路面状况",
                          @"晾晒指数":@"是否适宜晾晒衣物",
                          @"美发指数":@"出行对于秀发的保护小贴士",
                          @"啤酒指数":@"是否适宜喝啤酒",
                          @"放风筝指数":@"今日是否适宜放风筝",
                          @"空气污染扩散条件指数":@"出行空气污染提醒",
                          @"化妆指数":@"爱美人士的化妆建议",
                          @"旅游指数":@"今日是否适宜去该城市旅游",
                          @"紫外线强度指数":@"出行时的防紫外线小贴士",
                          @"风寒指数":@"防寒小贴士",
                          @"洗车指数":@"给爱车一族的洗车建议",
                          @"心情指数":@"心情分享",
                          @"运动指数":@"今日是否适宜进行户外运动",
                          @"雨伞指数":@"出行是否需要带伞",
                          @"中暑指数":@"炎炎夏日防暑宝典",
                          };
    
    
    NSString *string = [dic valueForKey:NameStr];
    
    return string;
}



@end
