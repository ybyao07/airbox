//
//  DataController+CacheData.m
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "DataController+Cache.h"
#import "CacheData.h"
#import "CacheItem.h"

#define kDataControllerCacheMaxCount		1000

@implementation DataController (Cache)

// 初始化CityData
- (void)initCacheData
{
	if(cacheData == nil)
	{
		cacheData = [[CacheData alloc] init];
	}
}

- (NSMutableArray *)arrayCacheData
{
    [self initCacheData];
	
	if([cacheData arrayCacheData] == nil)
	{
		// 获取document文件夹位置
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *cacheDirectory = [paths objectAtIndex:0];
		
		// 写入文件
		NSString *cachePath = [cacheDirectory stringByAppendingPathComponent:kCacheDataFile];
		if([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == YES)
		{
            //加载文件中的数据
            
            NSData *data = [NSData dataWithContentsOfFile:cachePath];
            
            if(data)
            {
                NSMutableArray *arrayCacheDataFromFile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [self setArrayCacheData:arrayCacheDataFromFile];
            }
            else
            {
                // 初始化为空的字典
                NSMutableArray *arrayCacheDataDefault = [[NSMutableArray alloc] init];
                [self setArrayCacheData:arrayCacheDataDefault];
            }
		}
		else
		{
            // 初始化为空的字典
			NSMutableArray *arrayCacheDataDefault = [[NSMutableArray alloc] init];
			[self setArrayCacheData:arrayCacheDataDefault];
		}
	}
	
	return [cacheData arrayCacheData];
}

- (void)setArrayCacheData:(NSMutableArray *)arrayCacheDataNew
{
    [self initCacheData];
    [cacheData setArrayCacheData:arrayCacheDataNew];
}

- (void)addCache:(NSData *)data
     andCacheKey:(NSString *)cacheKey
{
    [self addCache:data andCacheKey:cacheKey andCacheNSURLResponse:[[NSURLResponse alloc] init]];
}

- (void)addCache:(NSData *)data
	 andCacheKey:(NSString *)cacheKey
andCacheNSURLResponse:(NSURLResponse *)response
{
    for (CacheItem *cacheItem in [self arrayCacheData])
    {
        if ([[cacheItem cacheKey] isEqualToString:cacheKey])
        {
            [cacheItem setDataCache:data];
            [cacheItem setCacheResponse:response];
            [self saveCacheData];
            return;
        }
    }
    
    // 缓存数据量已超过预计值，先删除最久未加载的缓存数据
    if ([[self arrayCacheData] count] >= kDataControllerCacheMaxCount)
    {
        [[self arrayCacheData] removeObjectAtIndex:0];
    }
    
	// 添加缓存数据
	CacheItem *cacheItem = [[CacheItem alloc] init];
	[cacheItem setCacheKey:cacheKey];
    [cacheItem setCacheResponse:response];
	[cacheItem setDataCache:data];
    
	[[self arrayCacheData] addObject:cacheItem];
	
	[self saveCacheData];
}

- (BOOL)findCacheWithKey:(NSString *)cacheKey
{
	for (CacheItem *cacheItem in [self arrayCacheData])
	{
		if ([[cacheItem cacheKey] isEqualToString:cacheKey])
		{
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)deleteCacheWithKey:(NSString *)cacheKey
{
	for (CacheItem *cacheItem in [self arrayCacheData])
	{
		if ([[cacheItem cacheKey] isEqualToString:cacheKey])
		{
			[[self arrayCacheData] removeObject:cacheItem];
			
			return YES;
		}
	}
	
	return NO;
}

- (NSData *)loadCacheDataWithKey:(NSString *)cacheKey
{
	NSInteger cacheDataCount = [[self arrayCacheData] count];
	for (NSInteger i=0; i < cacheDataCount; i++)
	{
		CacheItem *cacheItem = [[self arrayCacheData] objectAtIndex:i];
		
		if ([[cacheItem cacheKey] isEqualToString:cacheKey])
		{
            
            NSData *dataCache = [[cacheItem dataCache] mutableCopy];
			// 找到符合项即返回，而且已操作数组元素，继续循环可能引发错误
			return dataCache;
		}
	}
    
    return nil;
}
-(NSURLResponse *)loadCacheResponseWithKey:(NSString *)cacheKey
{
    NSInteger cacheDataCount = [[self arrayCacheData] count];
    for (NSInteger i=0; i < cacheDataCount; i++)
    {
        CacheItem *cacheItem = [[self arrayCacheData] objectAtIndex:i];
        
        if ([[cacheItem cacheKey] isEqualToString:cacheKey])
        {
            NSURLResponse *cacheResponse = [[cacheItem cacheResponse] copy];
            // 找到符合项即返回，而且已操作数组元素，继续循环可能引发错误
            return cacheResponse;
        }
    }
    
    return nil;
}

- (void)saveCacheData
{
	if((cacheData != nil) && ([cacheData arrayCacheData] != nil))
	{
		// 获取document文件夹位置
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *cacheDirectory = [paths objectAtIndex:0];
        
        NSData *dataTmp = [NSKeyedArchiver archivedDataWithRootObject:[cacheData arrayCacheData]];
		
		// 写入文件
		NSString *cachePath = [cacheDirectory stringByAppendingPathComponent:kCacheDataFile];
		[dataTmp writeToFile:cachePath atomically:YES];
	}
}

@end
