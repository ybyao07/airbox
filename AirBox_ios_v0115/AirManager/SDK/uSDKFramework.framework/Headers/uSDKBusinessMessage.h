//
//  uSDKBusinessMessage.h
//  uSDK_iOS_v2
//
//  Created by Zono on 14-1-7.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *	@brief	功能描述：<br>
 *      uSDK业务消息类。业务消息内容以二进制方式存储，uSDK不做任何解析，直接透传并通知APP。业务消息通常是由云平台发起的，可能与家电设备有关，也可能与家电设备无关。天气预报等业务消息即与家电设备无关的消息。
 */
@interface uSDKBusinessMessage : NSObject

/**
 *	@brief	功能描述：<br>
 *      业务消息所属的命令字；此变量只读，设置无效
 */
@property(nonatomic, assign) int command;

/**
 *	@brief	功能描述：<br>
 *      业务消息内容；此变量只读，设置无效
 */
@property(nonatomic, strong) NSData* messageContent;

/**
 *	@brief	功能描述：<br>
 *      与业务数据相关的家电设备Mac地址，如果与家电设备无关则Mac地址为全0；如果为全F，则表示业务消息需送达所有APP；此变量只读，设置无效
 */
@property(nonatomic, strong) NSString* deviceMac;

@end


/**
 *	@brief	功能描述：<br>
 *      设备透传消息类，用于描述透传消息。透传消息是指来源于设备的，需要uSDK向APP透传的消息，目前支持消息类型主要有红外数据、大数据、生产检测数据，请见uSDKMessageTypeConst枚举定义。
 */
@interface uSDKTransparentMessage : NSObject

/**
 *	@brief	功能描述：<br>
 *      透传消息类型 即此透传消息的消息类型（红外数据/生产检测数据/大数据）；此变量只读，设置无效
 */
@property(nonatomic, assign) uSDKMessageTypeConst messageType;

/**
 *	@brief	功能描述：<br>
 *      透传消息体内容，即此透传消息的消息内容。无论原始消息是哪种编码方式，uSDK都以字符串方式传递给APP。此变量只读，设置无效
 */
@property(nonatomic, strong) NSString* messageContent;

/**
 *	@brief	功能描述：<br>
 *      获取MAC地址，即产生透传消息的设备MAC地址；此变量只读，设置无效
 */
@property(nonatomic, strong) NSString* deviceMac;

@end
