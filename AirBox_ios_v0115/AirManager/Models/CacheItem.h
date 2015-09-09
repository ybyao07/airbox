//
//  CacheItem.h
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheItem : NSObject <NSCoding>

@property (nonatomic, strong) NSData *dataCache;
@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) NSURLResponse *cacheResponse;

@end