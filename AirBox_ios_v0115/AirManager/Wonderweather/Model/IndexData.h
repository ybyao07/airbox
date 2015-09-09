//
//  IndexData.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-27.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndexData : NSObject
@property (copy, nonatomic) NSString *shortName;
@property (copy, nonatomic) NSString *aliasName;
@property (copy, nonatomic) NSString *level;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *content;

- (IndexData *)initWithDic:(NSMutableDictionary *)dic;
- (IndexData *)initWithName:(NSString *)name;
- (NSDictionary *)toDictionary;
@end
