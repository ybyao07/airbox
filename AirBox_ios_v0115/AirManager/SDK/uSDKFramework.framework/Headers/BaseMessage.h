//
//  BaseMessage.h
//  uSDK_iOS_v2_zhangc
//
//  Created by Zono on 14-5-22.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseMessage : NSObject

@end

///////////////////////////////////////

@interface DeviceMessage : BaseMessage
@property (strong, nonatomic) id device;
@property (assign, nonatomic) NSInteger type;

@end

@interface DeviceAlarmReportMessage : DeviceMessage
@property (strong, nonatomic) NSArray* message;

@end

@interface DeviceAttributeReportMessage : DeviceMessage
@property (strong, nonatomic) NSDictionary* message;

@end

@interface DeviceOnlineChangedReportMessage : DeviceMessage
@property (assign, nonatomic) uSDKDeviceStatusConst status;

@end

///////////////////////////////////////

@interface DeviceListReportMessage : BaseMessage
@property (strong, nonatomic) NSArray* message;
@property (assign, nonatomic) NSInteger type;

@end

///////////////////////////////////////

@interface InnerErrorReportMessage : BaseMessage
@property (strong, nonatomic) NSDictionary* message;
@property (assign, nonatomic) NSInteger errorNo;

@end

///////////////////////////////////////

@interface SmartConfigInfoReportMessage : BaseMessage
@property (strong, nonatomic) NSString* mac;
@property (assign, nonatomic) NSInteger errorNo;

@end

///////////////////////////////////////

@interface DeviceExecACKMessage : BaseMessage


@end