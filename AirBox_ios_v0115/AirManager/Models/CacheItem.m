//
//  CacheItem.m
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "CacheItem.h"

@implementation CacheItem
;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_dataCache forKey:@"kDataCache"];
    [encoder encodeObject:_cacheKey forKey:@"kCacheKey"];
    [encoder encodeObject:_cacheResponse forKey:@"kCacheResponse"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    _dataCache = [decoder decodeObjectForKey:@"kDataCache"];
    _cacheKey = [decoder decodeObjectForKey:@"kCacheKey"];
    _cacheResponse = [decoder decodeObjectForKey:@"kCacheResponse"];
    return self;
}


@end
