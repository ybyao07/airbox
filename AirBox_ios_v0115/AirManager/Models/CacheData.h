//
//  CacheData.h
//  QunariPhone
//
//  Created by 姜琢 on 13-7-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheData : NSObject

@property (nonatomic, strong) NSMutableArray *arrayCacheData;		// 缓存数据

// 初始化函数
- (id)init;

// 销毁
- (void)destroy;

@end
