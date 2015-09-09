//
//  NSTimer+TFAddition.m
//  AirManager
//
//  Created by yuan jie on 14-10-9.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "NSTimer+TFAddition.h"

@implementation NSTimer (TFAddition)

-(void)pauseTimer{
    
    if (![self isValid]) {
        return ;
    }
    
    [self setFireDate:[NSDate distantFuture]]; //如果给我一个期限，我希望是4001-01-01 00:00:00 +0000
    
    
}


-(void)resumeTimer{
    
    if (![self isValid]) {
        return ;
    }
    
    //[self setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [self setFireDate:[NSDate date]];
    
}

@end
