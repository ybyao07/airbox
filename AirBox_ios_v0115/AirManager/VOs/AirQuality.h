//
//  AirQuality.h
//  AirManager
//
//  Save air quality info

#import <Foundation/Foundation.h>

@interface AirQuality : NSObject
{
    NSNumber *temperature;
    NSNumber *humidity;
    NSString *pm25;
    NSNumber *voc;
    NSNumber *pm10;
    NSNumber *co;
    NSNumber *no2;
    NSNumber *o3;
    NSNumber *so2;
    NSNumber *co2;
    NSNumber *hcho;
    NSNumber *mark;
    NSString *markInfo;
    NSString *dateTime;
    NSNumber *rank;
}

- (id)initWithAirQualityInfo:(NSDictionary *)info;

@property (nonatomic,strong) NSNumber *temperature;
@property (nonatomic,strong) NSNumber *humidity;
@property (nonatomic,strong) NSString *pm25;
@property (nonatomic,strong) NSNumber *voc;
@property (nonatomic,strong) NSNumber *pm10;
@property (nonatomic,strong) NSNumber *co;
@property (nonatomic,strong) NSNumber *no2;
@property (nonatomic,strong) NSNumber *o3;
@property (nonatomic,strong) NSNumber *so2;
@property (nonatomic,strong) NSNumber *co2;
@property (nonatomic,strong) NSNumber *hcho;
@property (nonatomic,strong) NSNumber *mark;
@property (nonatomic,strong) NSString *markInfo;
@property (nonatomic,strong) NSString *dateTime;
@property (nonatomic,strong) NSNumber *rank;

@end
