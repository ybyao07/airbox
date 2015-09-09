//
//  WeatherManager.h
//  AirManager
//

#import <Foundation/Foundation.h>

@interface WeatherManager : NSObject
{
}

+ (WeatherManager *)sharedInstance;

@property (nonatomic) BOOL weatherUpdatedFailed;

/**
 *  start download weather from server
 **/
- (void)loadWeather;

/**
 *  stop auto update weather
 **/
- (void)stopAutoReload;

@end
