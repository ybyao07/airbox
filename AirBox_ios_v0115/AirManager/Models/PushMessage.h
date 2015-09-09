//
//  PushMessage.h
//  AirManager
//
//  Created by qitmac000242 on 15-1-16.
//  Copyright (c) 2015年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushMessage : NSObject

@property (nonatomic, strong) NSString *titleMessage;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *contentMessage;

@end
