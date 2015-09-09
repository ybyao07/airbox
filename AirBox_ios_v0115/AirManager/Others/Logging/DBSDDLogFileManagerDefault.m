//
//  DBSDDLogFileManagerDefault.m
//  AirManager
//
//  Created by yuan jie on 14-11-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "DBSDDLogFileManagerDefault.h"

@implementation DBSDDLogFileManagerDefault

- (NSString *)generateShortUUID{
    
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
    [threadUnsafeDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    NSString *dateFormatString = @"yyyy-MM-dd";
    [threadUnsafeDateFormatter setDateFormat:dateFormatString];
    NSString *filename = [threadUnsafeDateFormatter stringFromDate:date];
    return filename;
}
- (NSString *)createNewLogFile{
    NSString *logsDirectory = [self logsDirectory];
    int index = 1;
    NSString *fileName = [NSString stringWithFormat:@"airManager-log-%@.txt", [self generateShortUUID]];
    do
    {
        NSString *filePath = [logsDirectory stringByAppendingPathComponent:fileName];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            // Since we just created a new log file, we may need to delete some old log files
            [super deleteOldLogFiles];
            DDLogCVerbose(@"DBSDDLogFileManagerDefault create file:%@",fileName);
            return filePath;
        }
        else
        {
            NSString *strFile = [filePath stringByDeletingPathExtension];
            NSString *strFileName = [strFile lastPathComponent];
            NSString *strFileNameFormat = [self isContainCharacter:strFileName];
            if (strFileNameFormat) {
                strFileName = strFileNameFormat;
            }
            fileName =[NSString stringWithFormat:@"%@(%d).%@",strFileName,index,[filePath pathExtension]];
            index++;
        }
    } while(YES);
}

- (NSString*)isContainCharacter:(NSString*)fileName{
    NSString *strCharachter = @"(";
    NSRange foundPer=[fileName rangeOfString:strCharachter options:NSCaseInsensitiveSearch];
    if(foundPer.length>0) {
        NSRange rang;
        rang.location = 0;
        rang.length = foundPer.location;
        NSString *strRes = [fileName substringWithRange:rang];
        return strRes;
    }
    else {
        return nil;
    }
}

- (BOOL)isLogFile:(NSString *)fileName{
    if (fileName && [fileName length]>3) {
        NSRange rang;
        rang.location = [fileName length] - 4;
        rang.length = 4;
        NSString *strTmpName = [fileName substringWithRange:rang];
        if ([strTmpName isEqualToString:@".txt"]) {
            rang.location = 0;
            rang.length = 4;
            strTmpName = [fileName substringWithRange:rang];
            if ([@"dbs-" isEqualToString:strTmpName]) {
                return YES;
            }
        }
    }
    return NO;
}

@end;
