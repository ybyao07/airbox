//
//  AirDeviceManager.h
//  AirManager
//

#import <Foundation/Foundation.h>

@class AirQuality;
@class AirDevice;
@class uSDKDevice;

@interface AirDeviceManager : NSObject
{

}

/**
 *  download user binded device from server
 **/
- (void)downloadBindedDeviceWithCompletionHandler:(void(^)(NSMutableArray *array,BOOL succeed))handler;

/**
 *  download air device info from server
 **/
- (void)loadAirDeviceData:(AirDevice *)device completionHandler:(void(^)(AirQuality *quality,BOOL succeed))handler;

/**
 *  check current device is connect
 **/
+ (uSDKDevice *)connectedAirDevice:(AirDevice *)device;

/**
 *  remove binded air device, the handler is complete delegate
 **/
- (void)removeBindedAirDevice:(AirDevice *)device completionHandler:(void(^)(BOOL isSucceed))handler;

@end
