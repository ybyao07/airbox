//
//  NearAirQuality.m
//  AirManager
//
//  Created by qitmac000242 on 14-12-12.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "NearAirQuality.h"

@implementation NearAirQuality

@synthesize deviceId;
@synthesize dateTime;
@synthesize temperature;
@synthesize humidity;
@synthesize pm25;
@synthesize voc;

@synthesize mark;
@synthesize markInfo;
@synthesize rank;
@synthesize city;
@synthesize lng;
@synthesize lat;
@synthesize locationMsg;

- (id)initWithNearAirQualityInfo:(NSDictionary *)info
{
    self = [super init];
    if(self)
    {
        self.deviceId = info[@"deviceId"] ? info[@"deviceId"] :@"";
        self.dateTime = info[@"dateTime"] ? info[@"dateTime"] :@"";
        self.temperature = info[@"temperature"] ? [info[@"temperature"] stringValue] :@ "--";
        self.humidity = info[@"humidity"] ? [info[@"humidity"] stringValue] :@ "--";
        self.pm25 = info[@"pm25"] ? [info[@"pm25"] stringValue] :@ "--";
        self.voc = info[@"voc"] ? [info[@"voc"] stringValue] :@ "--";
        self.mark = info[@"mark"] ? [info[@"mark"] stringValue] :@ "--";
        self.markInfo = info[@"markInfo"] ? info[@"deviceId"] :@"";
        self.rank = info[@"rank"] ? [info[@"rank"] stringValue] :@ "--";
        self.city = info[@"city"] ? info[@"city"] :@"";
        self.lng = info[@"lng"] ? info[@"lng"] :@"";
        self.lat = info[@"lat"] ? info[@"lat"] :@"";
        self.locationMsg = @"";
    }
    return self;
}


@end
