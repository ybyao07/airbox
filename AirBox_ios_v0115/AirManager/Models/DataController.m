//
//  DataController.m
//  QunarClient
//
//  Created by huangqing on 9/29/10.
//  Copyright 2010 nanjing. All rights reserved.
//

#import "DataController.h"
#import "DataController+Cache.h"

@interface DataController (Private)

// 获取和设置CacheData
- (void)setCacheData:(CacheData *)cacheDataNew;

@end


// =====================================================================================
// 全局数据控制器
// =====================================================================================
// 全局数据控制器
static DataController *globalDataController = nil;

// 数据控制器实现
@implementation DataController

// 获取数据管理的控制器
+ (DataController *)getInstance
{
	@synchronized(self)
	{
		// 实例对象只分配一次
		if(globalDataController == nil)
		{
			globalDataController = [[super allocWithZone:NULL] init];
			
            [globalDataController setCacheData:nil];
		}
	}
	
	return globalDataController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// 设置CacheData
- (void)setCacheData:(CacheData *)cacheDataNew
{
	cacheData = cacheDataNew;
}

// 保存
- (void)save
{
	[self saveCacheData];
}

// 销毁
- (void)destroy
{
    [cacheData destroy];
}
@end
