//
//  LocationDelegate.h
//  QunariPhone
//
//  Created by zhou jinfeng on 13-3-14.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocationManager.h>
#import <MapKit/MapKit.h>

#define kLocationErrorWithPermission -1

@protocol LocationDelegate <NSObject>

// 如果定位成功则newLocation不为nil，否则error不为nil
// 如果定位失败的原因为设备不支持或没有权限的话则errorCode为-1,其它定位失败的原因参见CLError
- (void)UpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation WithPurpose:(NSString *)purpose andError:(NSString *)error andErrorCode:(NSInteger)errorCode;

@end

@interface LocationController : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager		*_locationManager;           // 定位管理器
    CLLocation              *_location;                  // 经纬度
    
    NSMutableArray          *_arrayDelegate;             // 代理对象的数组
    NSInteger               _activeStatus;               // 定位的状态
}

@property (nonatomic, strong) CLLocationManager		*locationManager;           // 定位管理器
@property (nonatomic, strong) CLLocation            *location;                  // 定位管理器
@property (nonatomic, strong) NSMutableArray        *arrayDelegate;             // 定位管理器
@property (nonatomic, assign) NSInteger             activeStatus;               // 定位的状态

// 获取数据管理的控制器(单例，防止全局变量的使用)
+ (LocationController *)getInstance;

- (void)startUpdatingLocationWithPurpose:(NSString *)purpose andSender:(id<LocationDelegate>)sender;

// 根据sender和purpose停止回调
- (void)stopUpdatingLocationWithPurpose:(NSString *)purpose andSender:(id<LocationDelegate>)sender;

// 根据sender停止回调
- (void)stopUpdatingLocationWithSender:(id<LocationDelegate>)sender;

// 停止定位，当App被结束时调用
- (void)stopUpdatingLocationForAppInactive;

@end
