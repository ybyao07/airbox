//
//  AirData.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "AirData.h"

@implementation AirData

-(AirData *)initWithDic:(NSMutableDictionary *)dic{
    
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
      
        self.pm25 = [tmpDic objectForKey:@"pm25"];
        self.aqi = [tmpDic objectForKey:@"aqi"];
        self.date = [tmpDic objectForKey:@"date"];
        
    }
    return self;
}


@end
