//
//  AFHTTPRequestOperation+Cache.h
//  AirManager
//
//  Created by yuan jie on 14-10-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (Cache)

- (void)setCompletionBlockWithSuccessTest:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
