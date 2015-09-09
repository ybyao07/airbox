//
//  NearAirQuality.h
//  AirManager
//
//  Created by qitmac000242 on 14-12-12.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearAirQuality : NSObject
{
    NSString *deviceId;
    NSString *dateTime;
    NSString *temperature;
    NSString *humidity;
    NSString *pm25;
    NSString *voc;
    NSString *mark;
    NSString *markInfo;
    NSString *rank;
    NSString *city;
    NSString *lng;
    NSString *lat;
    NSString *locationMsg;
}

- (id)initWithNearAirQualityInfo:(NSDictionary *)info;

@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *dateTime;
@property (nonatomic,strong) NSString *temperature;
@property (nonatomic,strong) NSString *humidity;
@property (nonatomic,strong) NSString *pm25;
@property (nonatomic,strong) NSString *voc;
@property (nonatomic,strong) NSString *mark;
@property (nonatomic,strong) NSString *markInfo;
@property (nonatomic,strong) NSString *rank;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *lng;
@property (nonatomic,strong) NSString *lat;
@property (nonatomic,strong) NSString *locationMsg;

@end
