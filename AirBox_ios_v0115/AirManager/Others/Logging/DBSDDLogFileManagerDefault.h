//
//  DBSDDLogFileManagerDefault.h
//  AirManager
//
//  Created by yuan jie on 14-11-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "DDFileLogger.h"

@interface DBSDDLogFileManagerDefault : DDLogFileManagerDefault

- (NSString *)generateShortUUID;
- (NSString *)createNewLogFile;
- (NSString*)isContainCharacter:(NSString*)fileName;
- (BOOL)isLogFile:(NSString *)fileName;

@end
