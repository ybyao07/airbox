//
//  AirDevice.m
//  AirManager
//

#import "AirDevice.h"
#import "AirPurgeModel.h"

@implementation AirDevice

@synthesize name;
@synthesize type;
@synthesize country;
@synthesize mac;
@synthesize userAirMode;
@synthesize city;
@synthesize province;
@synthesize lat;
@synthesize lng;
@synthesize isOnLine;
@synthesize eprotocolver;
@synthesize versionmyself;
@synthesize versiondevfile;
@synthesize hardwarever;
@synthesize platformver;
@synthesize baseboard_hardware;
@synthesize baseboard_software;
@synthesize voiceValue;

- (id)initWithAirDeviceInfo:(NSDictionary *)info
{
    self = [super init];
    if(self)
    {
        self.name = [info[@"name"] isEqual:[NSNull null]] ? @"" : info[@"name"];
        self.type = [info[@"wifitype"] isEqual:[NSNull null]] ? @"" : info[@"wifitype"];
        self.country = [info[@"country"] isEqual:[NSNull null]] ? @"" : info[@"country"];
        self.mac = [info[@"mac"] isEqual:[NSNull null]] ? @"" : info[@"mac"];
        self.userAirMode = [[AirPurgeModel alloc] init];
        [userAirMode parserAirModel:info[@"userAirMode"]];
        
        self.city = [info[@"city"] isEqual:[NSNull null]] ? @"" : info[@"city"];
        
        self.province = [info[@"province"] isEqual:[NSNull null]] ? @"" : info[@"province"];
        self.lat = [info[@"lat"] isEqual:[NSNull null]] ? @"" : info[@"lat"];
        self.lng = [info[@"lng"] isEqual:[NSNull null]] ? @"" : info[@"lng"];
        self.isOnLine = [info[@"isonline"] isEqual:[NSNull null]] ? nil : info[@"isonline"];
        self.eprotocolver = [info[@"eprotocolver"] isEqual:[NSNull null]] ? @"" : info[@"eprotocolver"];
        self.versionmyself = [info[@"versionmyself"] isEqual:[NSNull null]] ? @"" : info[@"versionmyself"];
        self.versiondevfile = [info[@"versiondevfile"] isEqual:[NSNull null]] ? @"" : info[@"versiondevfile"];
        self.hardwarever = [info[@"hardwarever"] isEqual:[NSNull null]] ? @"" : info[@"hardwarever"];
        self.platformver = [info[@"platformver"] isEqual:[NSNull null]] ? @"" : info[@"platformver"];
        self.baseboard_hardware = [info[@"baseboard_hardware"] isEqual:[NSNull null]] ? @"" : info[@"baseboard_hardware"];
        self.baseboard_software = [info[@"baseboard_software"] isEqual:[NSNull null]] ? @"" : info[@"baseboard_software"];
        self.voiceValue = @"";
    }
    return self;
}

// 存储状态
- (void) encodeWithCoder:(NSCoder *)encoder
{
    encode(encoder, name, Object);
    encode(encoder, type, Object);
    encode(encoder, country, Object);
    encode(encoder, mac, Object);
    encode(encoder, userAirMode, Object);
    
    encode(encoder, city, Object);
    encode(encoder, province, Object);
    encode(encoder, lat, Object);
    encode(encoder, lng, Object);
    encode(encoder, isOnLine, Object);
    encode(encoder, eprotocolver, Object);
    encode(encoder, versiondevfile, Object);
    
    encode(encoder, versiondevfile, Object);
    encode(encoder, hardwarever, Object);
    encode(encoder, platformver, Object);
    encode(encoder, baseboard_hardware, Object);
    encode(encoder, baseboard_software, Object);
    encode(encoder, voiceValue, Object);
}

// 加载状态
- (id)initWithCoder:(NSCoder *)decoder
{
    decode(decoder, name, Object);
    decode(decoder, type, Object);
    decode(decoder, country, Object);
    decode(decoder, mac, Object);
    decode(decoder, userAirMode, Object);
    
    decode(decoder, city, Object);
    decode(decoder, province, Object);
    decode(decoder, lat, Object);
    decode(decoder, lng, Object);
    decode(decoder, isOnLine, Object);
    decode(decoder, eprotocolver, Object);
    decode(decoder, versiondevfile, Object);
    
    decode(decoder, versiondevfile, Object);
    decode(decoder, hardwarever, Object);
    decode(decoder, platformver, Object);
    decode(decoder, baseboard_hardware, Object);
    decode(decoder, baseboard_software, Object);
    decode(decoder, voiceValue, Object);
    
    return self;
}

@end
