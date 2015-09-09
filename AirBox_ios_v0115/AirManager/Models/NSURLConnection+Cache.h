//
//  NSURLConnection+Cache.h
//  AirManager
//
//  Created by yuan jie on 14-10-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (Cache)

+ (void)sendAsynchronousRequestTest:(NSURLRequest*) request
                              queue:(NSOperationQueue*) queue
                  completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;

+ (void)sendAsynchronousRequestCache:(NSURLRequest*) request
                               queue:(NSOperationQueue*) queue
                            cacheKey:(NSString *)cacheKey
                   completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler;
@end
