//
//  DBSDDFileLogger.h
//  AirManager
//
//  Created by yuan jie on 14-11-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "DDFileLogger.h"

@interface DBSDDFileLogger : DDFileLogger

- (id)init;
- (NSString*)getDBSCacheLogsDir;


@end
