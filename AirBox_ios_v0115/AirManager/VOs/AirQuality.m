//
//  AirQuality.m
//  AirManager
//

#import "AirQuality.h"

@implementation AirQuality

@synthesize temperature;
@synthesize humidity;
@synthesize pm25;
@synthesize voc;
@synthesize pm10;
@synthesize co;
@synthesize no2;
@synthesize o3;
@synthesize so2;
@synthesize co2;
@synthesize hcho;
@synthesize mark;
@synthesize markInfo;
@synthesize dateTime;
@synthesize rank;

- (id)initWithAirQualityInfo:(NSDictionary *)info
{
    self = [super init];
    if(self)
    {
        self.temperature = info[@"temperature"];
        self.humidity = info[@"humidity"];
        self.pm25 = [info[@"pm25"] stringValue];
        self.voc = info[@"voc"];
        self.dateTime = info[@"dateTime"];
        self.pm10 = info[@"pm10"];
        self.co = info[@"co"];
        self.no2 = info[@"no2"];
        self.o3 = info[@"o3"];
        self.so2 = info[@"so2"];
        self.co2 = info[@"co2"];
        self.hcho = info[@"hcho"];
        self.mark = info[@"mark"];
        self.markInfo = info[@"markInfo"];
        self.rank = info[@"rank"];
    }
    return self;
}

@end
