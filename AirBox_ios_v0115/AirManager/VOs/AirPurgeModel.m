//
//  AirPurgeModel.m
//  AirManager
//

#import "AirPurgeModel.h"
#import "AppDelegate.h"
#import "NSMutableDictionary+Utility.h"
@interface AirPurgeModel ()
{

}

@end

@implementation AirPurgeModel

@synthesize acMode;
@synthesize mode;
@synthesize onOff;
@synthesize temperature;
@synthesize time;
@synthesize windSpeed;
@synthesize apOnOff;
@synthesize healthyState;

@synthesize tempList;
@synthesize windSpeedList;
//@synthesize apStatusList;
@synthesize airModelList;
@synthesize acModelList;
@synthesize healthyStateList;
@synthesize operationCodeList;
@synthesize modeIndex;
@synthesize apflag;
@synthesize acflag;
@synthesize pm25;
@synthesize sleepModeId;

- (id)init
{
    self = [super init];
    if(self)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *filePath;
        if ([MainDelegate isLanguageEnglish]) {
            filePath = [bundle pathForResource:@"AirConEn.plist" ofType:nil];

        }else{
            filePath = [bundle pathForResource:@"AirCon.plist" ofType:nil];

        }
        NSDictionary *dicAirCon = [NSDictionary dictionaryWithContentsOfFile:filePath];
        self.tempList = dicAirCon[@"Temperature"];
        self.windSpeedList = dicAirCon[@"WindSpeed"];
//        self.apStatusList = dicAirCon[@"APStatus"];
        self.airModelList = dicAirCon[@"AirModel"];
        self.acModelList = dicAirCon[@"AcModel"];
        self.healthyStateList = dicAirCon[@"HealthyState"];
        self.operationCodeList = dicAirCon[@"OperationCode"];
        
        self.acMode = acModelList[1];
        self.mode = airModelList[0];
        self.onOff = IRDeviceClose;
        self.temperature = tempList[10];
        self.time = @"00:00";
        self.windSpeed = windSpeedList[0];
        self.apOnOff = IRDeviceClose;
        self.healthyState = @"off";
        self.modeIndex = @0;
        self.acflag = @NO;
        self.apflag = @NO;
        self.pm25=@"50";
        self.sleepModeId = @"1";
    }
    return self;
}

- (void)parserAirModel:(NSDictionary *)list
{
    if([list isEqual:[NSNull null]] || !list)return;

    if(isObject(list[@"acmode"]) && list[@"acmode"])
    {
        self.acMode = [list[@"acmode"] isEqualToString:@"30e0M1"] ? operationCodeList[@"30e0M2"] : operationCodeList[list[@"acmode"]];
    }
    else
    {
        self.acMode = acModelList[1];
    }
    
    if(isObject(list[@"mode"]) && list[@"mode"])
    {
        self.modeIndex = list[@"mode"];
        self.mode = airModelList[[self.modeIndex integerValue]];
    }
    else
    {
        self.modeIndex = @3;
        self.mode = airModelList[[self.modeIndex integerValue]];
    }
    
    if(isObject(list[@"onoff"]) && list[@"onoff"])
    {
        self.onOff = list[@"onoff"];
    }
    else
    {
        self.onOff = IRDeviceClose;
    }
    
    if(isObject(list[@"temperature"]) && list[@"temperature"])
    {
        self.temperature = tempList[[list[@"temperature"] integerValue] - 16];
    }
    else
    {
        self.temperature = tempList[10];
    }
    
    if(isObject(list[@"time"]) && list[@"time"])
    {
        self.time = list[@"time"];
    }
    else
    {
         self.time = @"9999";
    }
    
    if(isObject(list[@"windspeed"]) && list[@"windspeed"])
    {
        self.windSpeed = operationCodeList[list[@"windspeed"]];
    }
    else
    {
        self.windSpeed  = windSpeedList[0];
    }
    
    if(isObject(list[@"aponoff"]) && list[@"aponoff"])
    {
        self.apOnOff = list[@"aponoff"] ;
    }
    else
    {
        self.apOnOff = IRDeviceClose;
    }
    
    if(isObject(list[@"healtyState"]) && list[@"healtyState"])
    {
        self.healthyState = list[@"healtyState"]  ;
    }
    else
    {
        self.healthyState = @"off";
    }
    
    if(isObject(list[@"apflag"]) && list[@"apflag"])
    {
        self.apflag = list[@"apflag"] ? list[@"apflag"] : @NO;
    }
    else
    {
        self.apflag = @NO;
    }
    
    if(isObject(list[@"acflag"]) && list[@"acflag"])
    {
        self.acflag = list[@"acflag"];
    }
    else
    {
        self.acflag = @NO;
    }
    
    if(isObject(list[@"pm25"]) && list[@"pm25"])
    {
        self.pm25 = list[@"pm25"] ;
    }
    else
    {
        self.pm25 = @"50";
    }
    
    if(isObject(list[@"sleepModeId"]) && list[@"sleepModeId"])
    {
        self.sleepModeId = list[@"sleepModeId"];
    }
    else
    {
        self.sleepModeId = @"1";
    }
}

// 序列化参数数据
- (void)seriaAirModel:(NSMutableDictionary *)jsonDictionary
{
    [jsonDictionary setObjectSafe:self.acflag forKey:@"acflag"];
    [jsonDictionary setObjectSafe:operationCodeList[self.acMode] forKey:@"acmode"];
    [jsonDictionary setObjectSafe:self.apflag forKey:@"apflag"];
    [jsonDictionary setObjectSafe:self.apOnOff forKey:@"aponoff"];
    [jsonDictionary setObjectSafe:self.healthyState forKey:@"healtyState"];
    
    [jsonDictionary setObjectSafe:self.mode forKey:@"mode"];
    [jsonDictionary setObjectSafe:self.onOff forKey:@"onoff"];
    [jsonDictionary setObjectSafe:self.pm25 forKey:@"pm25"];
    [jsonDictionary setObjectSafe:self.sleepModeId forKey:@"sleepModeId"];
    [jsonDictionary setObjectSafe:self.temperature forKey:@"temperature"];
    
    [jsonDictionary setObjectSafe:self.time forKey:@"time"];
    [jsonDictionary setObjectSafe:operationCodeList[self.windSpeed] forKey:@"windspeed"];
    
}

- (id)copyWithZone:(NSZone *)zone
{
    AirPurgeModel *newModel = [[[self class] allocWithZone:zone] init];
    newModel.acMode = [self.acMode copy];
    newModel.mode = [self.mode copy];
    newModel.onOff = [self.onOff copy];
    newModel.temperature = [self.temperature copy];
    newModel.time = [self.time copy];
    newModel.windSpeed = [self.windSpeed copy];
    newModel.apOnOff = [self.apOnOff copy];
    newModel.tempList = [self.tempList copy];
    newModel.windSpeedList = [self.windSpeedList copy];
//    newModel.apStatusList = [self.apStatusList copy];
    newModel.airModelList = [self.airModelList copy];
    newModel.acModelList = [self.acModelList copy];
    newModel.healthyState = [self.healthyState copy];
    newModel.healthyStateList = [self.healthyStateList copy];
    newModel.operationCodeList = [self.operationCodeList copy];
    
    newModel.modeIndex = [self.modeIndex copy];
    newModel.acflag = [self.acflag copy];
    newModel.apflag = [self.apflag copy];
    newModel.pm25= [self.pm25 copy];
    newModel.sleepModeId = [self.sleepModeId copy];
    
    return newModel;
}

// 存储状态
- (void) encodeWithCoder:(NSCoder *)encoder
{
    encode(encoder, acMode, Object);
    encode(encoder, mode, Object);
    encode(encoder, onOff, Object);
    encode(encoder, temperature, Object);
    encode(encoder, time, Object);
    
    encode(encoder, windSpeed, Object);
    encode(encoder, apOnOff, Object);
    encode(encoder, healthyState, Object);
    encode(encoder, tempList, Object);
    encode(encoder, windSpeedList, Object);
    
//    encode(encoder, apStatusList, Object);
    encode(encoder, airModelList, Object);
    encode(encoder, acModelList, Object);
    encode(encoder, healthyStateList, Object);
    encode(encoder, operationCodeList, Object);
    
    encode(encoder, modeIndex, Object);
    encode(encoder, apflag, Object);
    encode(encoder, acflag, Object);
    encode(encoder, pm25, Object);
    encode(encoder, sleepModeId, Object);
}

// 加载状态
- (id)initWithCoder:(NSCoder *)decoder
{
    decode(decoder, acMode, Object);
    decode(decoder, mode, Object);
    decode(decoder, onOff, Object);
    decode(decoder, temperature, Object);
    decode(decoder, time, Object);
    
    decode(decoder, windSpeed, Object);
    decode(decoder, apOnOff, Object);
    decode(decoder, healthyState, Object);
    decode(decoder, tempList, Object);
    encode(decoder, windSpeedList, Object);
    
//    decode(decoder, apStatusList, Object);
    decode(decoder, airModelList, Object);
    decode(decoder, acModelList, Object);
    decode(decoder, healthyStateList, Object);
    decode(decoder, operationCodeList, Object);
    
    decode(decoder, modeIndex, Object);
    decode(decoder, acflag, Object);
    decode(decoder, apflag, Object);
    decode(decoder, pm25, Object);
    decode(decoder, sleepModeId, Object);
    
    return self;
}


@end
