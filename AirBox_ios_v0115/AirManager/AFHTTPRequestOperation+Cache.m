//
//  AFHTTPRequestOperation+Cache.m
//  AirManager
//
//  Created by yuan jie on 14-10-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "AFHTTPRequestOperation+Cache.h"
#import "AppDelegate.h"

@implementation AFHTTPRequestOperation (Cache)

- (void)setCompletionBlockWithSuccessTest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if(![MainDelegate isNetworkAvailable])
    {
        success(nil, nil);
        failure(nil, [[NSError alloc] init]);
    }
    else
    {
        [self setCompletionBlockWithSuccess:success failure:failure];
    }
}

@end
