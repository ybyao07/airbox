//
//  Weather24.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-23.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather24 : NSObject

@property (copy, nonatomic) NSString *temperature;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *date;


-(Weather24 *)initWithDic:(NSMutableDictionary *)dic;
- (NSDictionary *)toDictionary;
@end
