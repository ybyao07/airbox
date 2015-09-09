//
//  Weather24.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "Weather24.h"

@implementation Weather24
-(Weather24 *)initWithDic:(NSMutableDictionary *)dic{
    
    NSArray *array = [dic allKeys];
    
    NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] initWithObjects:array forKeys:array];
    
    for (NSString *str in array) {
        
        if ([[dic objectForKey:str] isKindOfClass:[NSNull class]]) {
            [tmpDic setValue:@"" forKey:str];
        }
        else if ([[dic objectForKey:str] isKindOfClass:[NSNumber class]]) {
            [tmpDic setValue:[NSString stringWithFormat:@"%d",[[dic objectForKey:str] intValue]] forKey:str];
        }else
        {
            [tmpDic setValue:[dic objectForKey:str] forKey:str];
        }
    }

    if (self = [super init]) {
        self.temperature = [tmpDic objectForKey:@"temperature"];
        self.icon = [tmpDic objectForKey:@"icon"];
        self.date = [tmpDic objectForKey:@"date"];
        self.date = [tmpDic objectForKey:@"localDate"];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_temperature != nil) {
        [tmpDict setObject:_temperature forKey:@"temperature"];
    }
    if (_icon != nil) {
        [tmpDict setObject:_icon forKey:@"icon"];
    }
    if (_date != nil) {
        [tmpDict setObject:_date forKey:@"date"];
    }
    if (_date != nil) {
        [tmpDict setObject:_date forKey:@"localDate"];
    }
    return tmpDict;
}

@end
