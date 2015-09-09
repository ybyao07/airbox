//
//  SDKRequestManager.h
//  AirManager
//

#import <Foundation/Foundation.h>
#import <uSDKFramework/uSDKConstantInfo.h>

@class uSDKDeviceConfigInfo;

@interface SDKRequestManager : NSObject
{
    NSMutableDictionary *sdkReturnedDeviceDict;
    
    BOOL isSDKRunning;
}

+ (SDKRequestManager *)sharedInstance;

/**
 *  return a list include all SMART_HOME device
 **/
- (NSMutableArray *)deviceList;

/**
 *  registe list change notification
 **/
- (void)registeListChangeNotificaion;

/**
 *  registe device status change notification
 **/
- (void)registeDeviceNotification:(NSArray *)devList;

/**
 *  Unreguste device status change notification
 **/

- (void)unSubscribeDeviceNotification:(NSArray *)devList;

/**
 *  start SDK
 **/
- (void)startSDK;

/**
 *  stop SDK
 **/
- (void)stopSDK;

/**
 *  remote login
 **/
- (void)remoteLogin:(NSArray *)devList;

/**
 *  remote logout
 **/
- (void)remoteLogout;

/**
 *  init sdk log
 **/
- (void)initSDKLog;

/**
 *  do easy link
 **/
- (uSDKErrorConst)easyLinkWithDeviceInfo:(uSDKDeviceConfigInfo *)info;

/**
 *  check the air box connect status
 **/
- (BOOL)isWaitConnect:(NSString *)mac;

-(uSDKDeviceStatusConst)getDeviceConnectStatus:(NSString *)mac;

@property (nonatomic, strong) NSMutableDictionary *sdkReturnedDeviceDict;
@property (nonatomic, assign) BOOL isSDKRunning;

@end
