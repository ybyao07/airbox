//
//  UncaughtExceptionHandler.h
//  AirManager
//
//  Created by yuan jie on 14-11-15.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject{
    BOOL dismissed;
}

+(void) InstallUncaughtExceptionHandler;
void UncaughtExceptionHandlers (NSException *exception);

+ (NSArray *)backtrace;
- (void)handleException:(NSException *)exception;

@end


