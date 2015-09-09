//
//  NSURLConnection+Cache.m
//  AirManager
//
//  Created by yuan jie on 14-10-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "NSURLConnection+Cache.h"
#import "AppDelegate.h"
#import "DataController+Cache.h"

@implementation NSURLConnection (Cache)

+ (void)sendAsynchronousRequestTest:(NSURLRequest*) request
                               queue:(NSOperationQueue*) queue
                   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
    if(![MainDelegate isNetworkAvailable])
    {
         handler(nil,nil,[[NSError alloc] init]);
    }
    else
    {
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
    }
}

+ (void)sendAsynchronousRequestCache:(NSURLRequest*) request
                          queue:(NSOperationQueue*) queue
                        cacheKey:(NSString *)cacheKey
              completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler
{
    if(![MainDelegate isNetworkAvailable])
    {
        BOOL isCached = [[DataController getInstance] findCacheWithKey:cacheKey];
        
        if (isCached)
        {
            NSURLResponse *cacheResponse = [[DataController getInstance] loadCacheResponseWithKey:cacheKey];
            
            NSData *dataCache = [[DataController getInstance] loadCacheDataWithKey:cacheKey];
            handler(cacheResponse,dataCache,nil);
        }
        else
        {
             handler(nil,nil,[[NSError alloc] init]);
        }
    }
    else
    {
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
    }
}

@end
