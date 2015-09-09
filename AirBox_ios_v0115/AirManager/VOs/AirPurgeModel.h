//
//  AirPurgeModel.h
//  AirManager
//

#import <Foundation/Foundation.h>

@interface AirPurgeModel : NSObject<NSCopying ,NSCoding>
{
    NSString *acMode;
    NSString *mode;
    NSString *onOff;
    NSString *temperature;
    NSString *time;
    NSString *windSpeed;
    NSString *apOnOff;
    NSString *healthyState;
    
    NSArray *tempList;
    NSArray *windSpeedList;
//    NSArray *apStatusList;
    NSArray *airModelList;
    NSArray *acModelList;
    NSArray *healthyStateList;
    NSDictionary *operationCodeList;
    NSNumber *modeIndex;
    NSNumber *acflag;
    NSNumber *apflag;
    NSString *pm25;
    NSString *sleepModeId;
}

- (id)init;

/**
 *  parser air info from server
 **/
- (void)parserAirModel:(NSDictionary *)list;

// 序列化参数数据
- (void)seriaAirModel:(NSMutableDictionary *)jsonDictionary;

@property (nonatomic, strong) NSString *acMode;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSString *onOff;
@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *windSpeed;
@property (nonatomic, strong) NSString *apOnOff;
@property (nonatomic, strong) NSString *healthyState;

@property (nonatomic, strong) NSArray *tempList;
@property (nonatomic, strong) NSArray *windSpeedList;
//@property (nonatomic, strong) NSArray *apStatusList;
@property (nonatomic, strong) NSArray *airModelList;
@property (nonatomic, strong) NSArray *acModelList;
@property (nonatomic, strong) NSArray *healthyStateList;
@property (nonatomic, strong) NSDictionary *operationCodeList;

@property (nonatomic, strong) NSNumber *modeIndex;
@property (nonatomic, strong) NSNumber *acflag;
@property (nonatomic, strong) NSNumber *apflag;
@property (nonatomic, strong) NSString *pm25;
@property (nonatomic, strong) NSString *sleepModeId;

@end
