//
//  LocationDelegate.m
//  QunariPhone
//
//  Created by zhou jinfeng on 13-3-14.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "LocationController.h"

#define IOS_VERSION_5_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)? (YES):(NO))

typedef enum
{
    CLStatusInactive = 1,
    CLStatusActive,
}eLocationControllerStatus;

// =====================================================================================
// 全局定位器控制器
// =====================================================================================
// 全局定位器控制器
static LocationController *globalLocationController = nil;

@interface LocationDelegateInfo : NSObject

@property (nonatomic, weak) id<LocationDelegate>		delegate;                   // 回调对象
@property (nonatomic, strong) NSString                  *purpose;                   // 定位目的

@end

@implementation LocationDelegateInfo

@end

@implementation LocationController

- (void)dealloc
{
    DDLogFunction();
    if ([[LocationController getInstance] activeStatus] == CLStatusActive)
    {
        [[[LocationController getInstance] arrayDelegate] removeAllObjects];
        [[[LocationController getInstance] locationManager] stopUpdatingLocation];
    }
    
    // 解决某些破解版的系统bug
    if([[[LocationController getInstance] locationManager] respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)] == YES)
    {
        [[[LocationController getInstance] locationManager] stopMonitoringSignificantLocationChanges];
    }

    [[[LocationController getInstance] locationManager] setDelegate:nil];
}

// 获取数据管理的控制器
// 获取数据管理的控制器
+ (LocationController *)getInstance
{
    @synchronized(self)
    {
        // 实例对象只分配一次
        if(globalLocationController == nil)
        {
            globalLocationController = [[super allocWithZone:NULL] init];
            
            // 初始化
            CLLocationManager *locationManagerTemp = [[CLLocationManager alloc] init];
            [locationManagerTemp setDelegate:globalLocationController];
 
            if ([locationManagerTemp respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [locationManagerTemp requestWhenInUseAuthorization];
            }
            
            [globalLocationController setLocationManager:locationManagerTemp];
            
            NSMutableArray *arrayDelegateTemp = [[NSMutableArray alloc] init];
            [globalLocationController setArrayDelegate:arrayDelegateTemp];
            
            [globalLocationController setActiveStatus:CLStatusInactive];
        }
    }
    
    return globalLocationController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// 请求定位
- (void)startUpdatingLocationWithPurpose:(NSString *)purpose andSender:(id<LocationDelegate>)sender
{
    if ([[LocationController getInstance] activeStatus] == CLStatusInactive)
    {
		NSString *errorText = @"";
		
		// 判断定位服务是否可用
		if ([CLLocationManager locationServicesEnabled] == NO)
		{
			errorText = NSLocalizedString(@"请在系统设置中打开“定位服务”来允许“空气盒子”确定您的位置(设置-隐私-定位服务)", @"LocationController.m") ;
		}
		else
		{
			CLAuthorizationStatus locationStatus = [CLLocationManager authorizationStatus];
			
			switch (locationStatus)
			{
				case kCLAuthorizationStatusRestricted:
				{
					errorText = NSLocalizedString(@"请在系统设置中打开“定位服务”来允许“空气盒子”确定您的位置(设置-隐私-定位服务)", @"LocationController.m");
					
					break;
				}
					
					// 空气盒子定位服务未开启
				case kCLAuthorizationStatusDenied:
				{
					errorText = NSLocalizedString(@"请在系统设置中打开“定位服务”来允许“空气盒子”确定您的位置(设置-隐私-定位服务)", @"LocationController.m");
					
					break;
				}
					
					// 未确定
				case kCLAuthorizationStatusNotDetermined:
				{
					break;
				}
					
					// 空气盒子定位服务未开启
				default:
					break;
			}
		}
		
		if (errorText != nil && [errorText length] > 0)
		{
            if ([sender conformsToProtocol:@protocol(LocationDelegate)] == YES)
            {
                [sender UpdateToLocation:nil fromLocation:nil WithPurpose:purpose andError:errorText andErrorCode:kLocationErrorWithPermission];
            }
		}
		else
		{
			LocationDelegateInfo *info = [[LocationDelegateInfo alloc] init];
			[info setPurpose:purpose];
			[info setDelegate:sender];
			
			[[[LocationController getInstance] arrayDelegate] addObject:info];
			[[[LocationController getInstance] locationManager] startUpdatingLocation];
			[[LocationController getInstance] setActiveStatus:CLStatusActive];
		}
    }
    
    
    else
    {
        LocationDelegateInfo *info = [[LocationDelegateInfo alloc] init];
        [info setPurpose:purpose];
        [info setDelegate:sender];
        
        [[[LocationController getInstance] arrayDelegate] addObject:info];
    }
    
    
}

// 回调所有请求对象
- (void)callBackWithUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation andError:(NSString *)error andErrorCode:(NSInteger)errorCode
{
    NSInteger arrayCount = [[[LocationController getInstance] arrayDelegate] count];
    NSMutableArray *arrayRemove = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < arrayCount; ++i)
    {
        LocationDelegateInfo *info = [[[LocationController getInstance] arrayDelegate] objectAtIndex:i];
        
        if ([info delegate] != nil && [[info delegate] conformsToProtocol:@protocol(LocationDelegate)])
        {
            [[info delegate] UpdateToLocation:newLocation fromLocation:oldLocation WithPurpose:[info purpose] andError:error andErrorCode:errorCode];
            [arrayRemove addObject:info];
        }
    }
    
    [[[LocationController getInstance] arrayDelegate] removeObjectsInArray:arrayRemove];
    [arrayRemove removeAllObjects];
}

// 根据sender和purpose停止回调
- (void)stopUpdatingLocationWithPurpose:(NSString *)purpose andSender:(id<LocationDelegate>)sender
{
    NSInteger arrayCount = [[[LocationController getInstance] arrayDelegate] count];
    NSMutableArray *arrayRemove = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < arrayCount; ++i)
    {
        LocationDelegateInfo *info = [[[LocationController getInstance] arrayDelegate] objectAtIndex:i];
        
        if ([info delegate] == sender)
        {
            if ([info purpose] != nil && [[info purpose] isEqualToString:purpose])
            {
                [arrayRemove addObject:info];
            }
            else if ([info purpose] == nil && purpose == nil)
            {
                [arrayRemove addObject:info];
            }
        }
    }
    
    [[[LocationController getInstance] arrayDelegate] removeObjectsInArray:arrayRemove];
    [arrayRemove removeAllObjects];
    
    [self checkLoactionStatus];

}

// 根据sender停止回调
- (void)stopUpdatingLocationWithSender:(id<LocationDelegate>)sender
{
    NSInteger arrayCount = [[[LocationController getInstance] arrayDelegate] count];
    NSMutableArray *arrayRemove = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < arrayCount; ++i)
    {
        LocationDelegateInfo *info = [[[LocationController getInstance] arrayDelegate] objectAtIndex:i];
        
        if ([info delegate] == sender)
        {
            [arrayRemove addObject:info];
        }
    }
    
    [[[LocationController getInstance] arrayDelegate] removeObjectsInArray:arrayRemove];
    [arrayRemove removeAllObjects];
    
    [self checkLoactionStatus];
}

// 暂停定位，当App被后台运行时调用
- (void)stopUpdatingLocationForAppInactive
{
    if (_activeStatus == CLStatusActive)
    {
        [[LocationController getInstance] setActiveStatus:CLStatusInactive];
        [[[LocationController getInstance] locationManager] stopUpdatingLocation];
        
        // 解决某些破解版的系统bug
        if([[[LocationController getInstance] locationManager] respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)] == YES)
        {
            [[[LocationController getInstance] locationManager] stopMonitoringSignificantLocationChanges];
        }
    }
}

- (void)checkLoactionStatus
{
    if (([[[LocationController getInstance] arrayDelegate] count] == 0)
		&& ([[LocationController getInstance] activeStatus] == CLStatusActive))
    {
        [[LocationController getInstance] setActiveStatus:CLStatusInactive];
        [[[LocationController getInstance] locationManager] stopUpdatingLocation];
        
        // 解决某些破解版的系统bug
        if([[[LocationController getInstance] locationManager] respondsToSelector:@selector(stopMonitoringSignificantLocationChanges)] == YES)
        {
            [[[LocationController getInstance] locationManager] stopMonitoringSignificantLocationChanges];
        }
    }
}

// =======================================================================
#pragma mark - CLLocationManagerDelegate的代理函数
// =======================================================================
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation 
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    // 时间是否再有效范围
    if(locationAge > 5.0)
	{
		return;
	}
	
    // 经纬度是否有效果
    if(newLocation.horizontalAccuracy < 0)
	{
		return;
	}
    
    [[LocationController getInstance] callBackWithUpdateToLocation:newLocation fromLocation:oldLocation andError:nil andErrorCode:0];
    
    [self checkLoactionStatus];    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSString *errorText = NSLocalizedString(@"定位失败，请重试", @"LocationController.m") ;
	
    [[LocationController getInstance] callBackWithUpdateToLocation:nil fromLocation:nil andError:errorText andErrorCode:[error code]];
	
    [self checkLoactionStatus];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
    } 
}


@end
