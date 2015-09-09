//
//  AirData.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AirData : NSObject
@property (copy, nonatomic) NSString *pm25;
@property (copy, nonatomic) NSString *aqi;
@property (copy, nonatomic) NSString *date;

-(AirData *)initWithDic:(NSMutableDictionary *)dic;

@end
