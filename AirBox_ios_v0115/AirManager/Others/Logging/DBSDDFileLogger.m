//
//  DBSDDFileLogger.m
//  AirManager
//
//  Created by yuan jie on 14-11-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "DBSDDFileLogger.h"
#import "DBSDDLogFileManagerDefault.h"


#define DBSLogDir @"AirManagerClientLogs"

@implementation DBSDDFileLogger
- (id)init{
    DBSDDLogFileManagerDefault *defaultLogFileManager = [[DBSDDLogFileManagerDefault alloc] initWithLogsDirectory:[self getDBSCacheLogsDir]];
    return [self initWithLogFileManager:defaultLogFileManager];
}

- (NSString*)getDBSCacheLogsDir{
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *cachedLogDir=[dir stringByAppendingPathComponent:DBSLogDir];
    return cachedLogDir;
}

@end

