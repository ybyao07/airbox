//
//  DataController+Cache.h
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "DataController.h"

@interface DataController (Cache)

- (void)addCache:(NSData *)data
     andCacheKey:(NSString *)cacheKey
;
- (void)addCache:(NSData *)data
     andCacheKey:(NSString *)cacheKey
andCacheNSURLResponse:(NSURLResponse *)response;

- (BOOL)findCacheWithKey:(NSString *)cacheKey;

- (BOOL)deleteCacheWithKey:(NSString *)cacheKey;

- (NSData *)loadCacheDataWithKey:(NSString *)cacheKey;

-(NSURLResponse *)loadCacheResponseWithKey:(NSString *)cacheKey;

- (void)saveCacheData;

@end
