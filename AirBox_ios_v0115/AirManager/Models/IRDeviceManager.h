//
//  IRDeviceManager.h
//  AirManager
//

#import <Foundation/Foundation.h>

#define Brand           @"brand"
#define Type            @"devType"
#define Model           @"devModel"
#define Mac             @"mac"
#define Token           @"token"
#define Version         @"irversion"
#define IRZIPCode       @"irzipfile"
#define IRCode          @"IrCodes"
#define TempLimt        @"temperatureLimit"
#define HealthyState    @"healthy_state"

@class AirDevice;
@class IRDevice;

typedef void(^IRCodeCheckCompletionHandler)(BOOL isSucceed);

@interface IRDeviceManager : NSObject
{
    IRCodeCheckCompletionHandler completionHandler;
}

/**
 *  check is there have ir code or the version is newest
 *
 **/
- (void)checkIRDevice:(IRDevice *)irDevice onAirDevice:(AirDevice *)airDevice;

/**
 *  download air device binded ir device from server
 **/
- (void)loadIRDeviceBindOnAirDevice:(NSString *)mac
                  completionHandler:(void(^)(NSMutableArray *irDevices,BOOL isLoadSucceed,BOOL isBindAC))handler;

/**
 *  remove bind ir device on air device
 **/
- (void)removeBindIRDevice:(IRDevice *)irDevice onAirDevice:(AirDevice *)airDevice completionHandler:(void(^)(BOOL isSucceed))handler;

@property (nonatomic, copy) IRCodeCheckCompletionHandler completionHandler;

@end
