//
//  IndexData.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-5-27.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "IndexData.h"

@implementation IndexData

-(IndexData *)initWithDic:(NSMutableDictionary *)dic{
    
    NSArray *array = [dic allKeys];
    
    for (NSString *str in array) {
        
        if ([[dic objectForKey:str] isKindOfClass:[NSNull class]]) {
            [dic setValue:nil forKey:str];
        }
        if ([[dic objectForKey:str] isKindOfClass:[NSNumber class]]) {
            [dic setValue:[NSString stringWithFormat:@"%d",[[dic objectForKey:str] intValue]] forKey:str];
        }
    }
    
    if (self = [super init]) {
        self.shortName = [dic objectForKey:@"shortName"];
        self.aliasName = [dic objectForKey:@"aliasName"];
        self.level = [dic objectForKey:@"level"];
        self.name = [dic objectForKey:@"name"];
        self.content = [dic objectForKey:@"content"];
    }
    return self;
}

- (IndexData *)initWithName:(NSString *)name
{
    if (self = [super init]) {
        self.shortName = @"";
        self.aliasName = @"";
        self.level = @"暂无";
        self.name = name;
        self.content = @"暂无";
    }

    return self;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    if (_shortName != nil) {
        [tmpDict setObject:_shortName forKey:@"shortName"];
    }
    if (_aliasName != nil) {
        [tmpDict setObject:_aliasName forKey:@"aliasName"];
    }
    if (_level != nil) {
        [tmpDict setObject:_level forKey:@"level"];
    }
    if (_name != nil) {
        [tmpDict setObject:_name forKey:@"name"];
    }
    if (_content != nil) {
        [tmpDict setObject:_content forKey:@"content"];
    }
    return tmpDict;
}


@end
