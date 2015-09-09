//
//  CacheData.m
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "CacheData.h"

@implementation CacheData

// 初始化函数
- (id)init
{
	if(self = [super init])
	{
		_arrayCacheData = nil;
		
		return self;
	}
	
	return nil;
}

// 销毁
- (void)destroy
{
	_arrayCacheData = nil;
}

@end
