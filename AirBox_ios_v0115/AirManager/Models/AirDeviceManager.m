//
//  AirDeviceManager.m
//  AirManager
//

#import "AirDeviceManager.h"
#import "AirDevice.h"
#import "AirQuality.h"
#import "UserLoginedInfo.h"
#import <uSDKFramework/uSDKDevice.h>
#import "AppDelegate.h"
#import "SDKRequestManager.h"

@interface AirDeviceManager ()
{

}

@end

@implementation AirDeviceManager

 
- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

#pragma mark - Dwonload Binded Device

- (void)downloadBindedDeviceWithCompletionHandler:(void(^)(NSMutableArray *array,BOOL succeed))handler
{
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_DEVICE_LIST(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_DEVICE_LIST(MainDelegate.loginedInfo.loginID)];
    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue currentQueue]
                                         cacheKey:cacheKey
                                completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             handler([NSMutableArray array],isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             DDLogCVerbose(@"--->从HTTP服务器上获取空气盒子列表成功: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [[DataController getInstance] addCache:data andCacheKey:cacheKey];
                 isSucceed = YES;
                 
                 NSMutableArray *arrDevice = [self parseBindedAirDevice:result[@"devices"]];
                 
                 // 获取pm2.5的随机数
                 for(AirDevice *airDeviceTmp in arrDevice)
                 {
                     [MainDelegate startGetPm25FloatRange:airDeviceTmp];
                 }
                 
                 handler(arrDevice,isSucceed);
                 
                 
             }
             else
             {
                 handler([NSMutableArray array],isSucceed);
             }
         }
     }];
}

- (NSMutableArray *)parseBindedAirDevice:(NSArray *)data
{
    if([data isEqual:[NSNull null]])return [NSMutableArray array];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [data count]; i++)
    {
        NSDictionary *dictionary = data[i];
        AirDevice *device = [[AirDevice alloc] initWithAirDeviceInfo:dictionary];
        [array addObject:device];
    }
    return array;
}

#pragma mark - Dwonload Air Device Info

- (void)loadAirDeviceData:(AirDevice *)device completionHandler:(void(^)(AirQuality *quality,BOOL succeed))handler
{
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_AIR_QUALITY(device.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             handler(nil,isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->空气盒子信息%@-- Device Mac:%@",result,device.mac);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 if([result[@"data"] isEqual:[NSNull null]])
                 {
                     handler(nil,isSucceed);
                 }
                 else
                 {
                     isSucceed = YES;
                     AirQuality *quality = [[AirQuality alloc] initWithAirQualityInfo:result[@"data"]];
                     handler(quality,isSucceed);
                 }
             }
             else
             {
                 handler(nil,isSucceed);
             }
         }
     }];
}

+ (uSDKDevice *)connectedAirDevice:(AirDevice *)device
{
    uSDKDevice *connectedDevice = nil;
    NSMutableArray *deviceList = [[SDKRequestManager sharedInstance] deviceList];
    for (int i = 0; i < [deviceList count]; i++)
    {
        uSDKDevice *uDevice = deviceList[i];
        if([device.mac isEqualToString:uDevice.mac])
        {
            connectedDevice = uDevice;
            break;
        }
    }
    return connectedDevice;
}

#pragma mark - Remove binded Air Device

- (void)removeBindedAirDevice:(AirDevice *)device completionHandler:(void(^)(BOOL isSucceed))handler
{
    NSDictionary *dicBody = @{@"userIds":@[MainDelegate.loginedInfo.userID],
                              @"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_UNBIND_DEV(MainDelegate.loginedInfo.userID,device.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             handler(isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             
             DDLogCVerbose(@"--->解除绑定盒子接口信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 isSucceed = YES;
                 handler(isSucceed);
             }
             else
             {
                 handler(isSucceed);
             }
         }
     }];
}

@end
