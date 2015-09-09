//
//  PushRequest.h
//  AirManager
//
//  Created by qitmac000242 on 15-1-16.
//  Copyright (c) 2015年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushRequest : NSObject

// 发送Token
+ (void)sendTokenStart:(NSData *)deviceToken;

// 开始处理消息
+ (void)startHandleMessage:(NSDictionary *)userInfo;

@end
