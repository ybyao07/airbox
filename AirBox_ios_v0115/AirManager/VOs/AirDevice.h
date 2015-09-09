//
//  AirDevice.h
//  AirManager
//
//  Save air box info from the server

#import <Foundation/Foundation.h>

@class AirPurgeModel;

@interface AirDevice : NSObject <NSCoding>
{
    NSString *name;
    NSString *type; // 以前是wifitype，根据接口是type
    NSString *country;
    NSString *mac;
    AirPurgeModel *userAirMode;
    NSString *city;
    NSString *province;
    NSString *lat;
    NSString *lng;
    NSNumber *isOnLine;
    NSString *eprotocolver;
    NSString *versionmyself;
    NSString *versiondevfile;
    NSString *hardwarever;
    NSString *platformver;
    NSString *baseboard_hardware;
    NSString *baseboard_software;
    NSString *voiceValue;
}

- (id)initWithAirDeviceInfo:(NSDictionary *)info;

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *country;
@property (nonatomic,strong) NSString *mac;
@property (nonatomic,strong) AirPurgeModel *userAirMode;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *lat;
@property (nonatomic,strong) NSString *lng;
@property (nonatomic,strong) NSNumber *isOnLine;
@property (nonatomic,strong) NSString *eprotocolver;
@property (nonatomic,strong) NSString *versionmyself;
@property (nonatomic,strong) NSString *versiondevfile;
@property (nonatomic,strong) NSString *hardwarever;
@property (nonatomic,strong) NSString *platformver;
@property (nonatomic,strong) NSString *baseboard_hardware;
@property (nonatomic,strong) NSString *baseboard_software;
@property (nonatomic,strong) NSString *voiceValue;


@end
