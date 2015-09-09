//
//  uSDKDeviceConfigInfo.h
//  uSDK_iOS_v2
//
//  Created by Zono on 14-1-7.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uSDKConstantInfo.h"
/**
 *	@brief  功能描述：<br>
 *      uSDK设备配置信息类，用于描述设备的配置信息。设备配置信息包括设备的一些基本信息、要连接的路由ssid和密码以及当前能够搜索到的路由列表。<br>
 *      当获取设备的配置信息时，配置信息以类实例方式返回。当设置设备的配置信息时，要设置的配置信息以类实例方式传给uSDK。
 */
@interface uSDKDeviceConfigInfo : NSObject {
    @private
    NSString* eProtocolVer_;
    NSString* roomname_;
    NSString* typeIdentifier_;
    NSString* devicePassword_;
    BOOL isDHCP_;
    NSString* mask_;
    NSString* gateway_;
    NSString* dns_;

}

/**
 *	@brief  功能描述：<br>
 *      设备大类分类信息；此变量只读，设置无效
 */
@property (nonatomic, assign) uSDKDeviceTypeConst type;

/**
 *	@brief	功能描述：<br>
 *      家电设备mac；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* mac;

/**
 *	@brief	功能描述：<br>
 *      家电设备ip；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* ip;

/**
 *	@brief	功能描述：<br>
 *      家电设备搜索到的wifi列表；此变量只读，设置无效
 */
@property (nonatomic, strong) NSMutableArray* aplist;

/**
 *	@brief	功能描述：<br>
 *      配置需要连接的SSID；此变量只写，读取的值无效
 */
@property (nonatomic, strong) NSString* apSsid;

/**
 *	@brief	功能描述：<br>
 *      配置需要连接SSID对应的密码；此变量只写，读取的值无效
 */
@property (nonatomic, strong) NSString* apPassword;

/**
 *	@brief	功能描述：<br>
 *      家电设备E++协议版本【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* mainGatewayDomain;

/**
 *	@brief	功能描述：<br>
 *      家电设备所在房间名称【此变量已废弃，值无效】
 */
@property (nonatomic, assign) NSInteger mainGatewayPort;

/**
 *	@brief	功能描述：<br>
 *      配置家电设备所连接的主网关域名；此变量只写，读取的值无效
 *  @todo   变量名改成mainGatewayDomain
 */
@property (nonatomic, strong) NSString* accessGatewayDomain;

/**
 *	@brief	功能描述：<br>
 *      配置家电设备所连接的接入网关端口；此变量只写，读取的值无效
 */
@property (nonatomic, assign) NSInteger accessGatewayPort;

/**
 *	@brief	功能描述：<br>
 *      配置家电设备所连接的接入网关域名；此变量只写，读取的值无效
 *  @todo   变量名改成accessGatewayDomain
 */
@property (nonatomic, strong) NSString* eProtocolVer;

/**
 *	@brief	功能描述：<br>
 *      配置家电设备所连接的接入网关端口；此变量只写，读取的值无效
 *  @todo   变量名改成accessGatewayPort
 */
@property (nonatomic, strong) NSString* roomname;

/**
 *	@brief	功能描述：<br>
 *      家电设备Identifier标识码【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* typeIdentifier;

/**
 *	@brief	功能描述：<br>
 *      【准备废弃】连接家电设备使用的密码【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* devicePassword;

/**	@brief	功能描述：<br>
 *      是否使用DHCP【此变量已废弃，值无效】
 */
@property (nonatomic, assign) BOOL isDHCP;

/**
 *	@brief	功能描述：<br>
 *      子网掩码地址【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* mask;

/**
 *	@brief	功能描述：<br>
 *      网关地址【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* gateway;

/**
 *	@brief	功能描述：<br>
 *      DNS地址【此变量已废弃，值无效】
 */
@property (nonatomic, strong) NSString* dns;

@end


/**
 *	@brief	功能描述：<br>
 *      uSDK设备配置信息中的AP信息类，用于描述路由信息，包括ap加密方式、ap信号强度、ap的ssid名称。<br>
 *      当获取设备softap配置信息时，在设备返回的当前能够搜索到的ap列表中，存放的就是AP信息类实例。
 */
@interface uSDKDeviceConfigInfoAp : NSObject

/**
 *	@brief	功能描述：<br>
 *      wifi热点的SSID；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* ssid;

/**
 *	@brief	功能描述：<br>
 *      wifi热点的信号强度 范围是0～100；此变量只读，设置无效
 */
@property (nonatomic, assign) int power;

/**
 *	@brief	功能描述：<br>
 *      wifi加密方式；此变量只读，设置无效
 */
@property (nonatomic, assign) uSDKApEncryptionTypeConst encrytionType;


@end
