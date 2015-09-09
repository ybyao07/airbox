//
//  uSDKDevice.h
//  uSDK_iOS_v2
//
//  Created by Zono on 14-1-7.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uSDKConstantInfo.h"
#import "uSDKBusinessMessage.h"

@class uSDKErrorInfo;

/**
 *	@brief	功能描述：<br>
 *      家电设备类。此类提供设备的基本信息、设备的网络状态和设备的属性状态，以及执行设备操作。
 */
@interface uSDKDevice : NSObject

/**
 *	@brief	功能描述：<br>
 *      家电设备mac；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* mac;

/**
 *	@brief	功能描述：<br>
 *      家电设备IP；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* ip;

/**
 *	@brief	功能描述：<br>
 *      家电设备遵守的E++协议版本号；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* eProtocolVer;

/**
 *	@brief	功能描述：<br>
 *      家电设备wifi的平台信息；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* smartLinkPlatform;

/**
 *	@brief	功能描述：<br>
 *      家电设备wifi的软件版本号；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* smartLinkSoftwareVersion;

/**
 *	@brief	功能描述：<br>
 *      家电设备wifi的硬件版本号；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* smartLinkHardwareVersion;

/**
 *	@brief	功能描述：<br>
 *      家电设备使用的配置文件版本号；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* smartLinkDevfileVersion;

/**
 *	@brief	功能描述：<br>
 *      家电设备的类型唯一识别码，用来唯一标识家电设备类型；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* typeIdentifier;

/**
 *	@brief	功能描述：<br>
 *      家电设备的网络类型。网络类型是指本地和远程，详细请见uSDKDeviceNetTypeConst枚举定义；此变量只读，设置无效
 */
@property (nonatomic, assign) uSDKDeviceNetTypeConst netType;

/**
 *	@brief	功能描述：<br>
 *      获取家电设备的网络状态。网络状态是指在线、离线、就绪、无效，详细请见uSDKDeviceStatusConst枚举定义；此变量只读，设置无效
 */
@property (nonatomic, assign) uSDKDeviceStatusConst status;

/**
 *	@brief	功能描述：<br>
 *      家电设备大类分类，设备按照大类通常分类为：洗衣机、冰箱、柜机空调、冰箱酒柜等。详细请见uSDKDeviceTypeConst枚举定义；此变量只读，设置无效
 */
@property (nonatomic, assign) uSDKDeviceTypeConst type;

@property (nonatomic, assign) NSInteger middleType;

@property (nonatomic, strong) NSString* specialId;

/**
 *	@brief	功能描述：<br>
 *      家电设备属性状态列表。设备属性状态是指每种设备所特有的运行时状态，例如空调的当前环境温度、洗衣机当前剩余的洗涤时间等。每一种设备都有多个功能状态，在这个集合中，可以以属性名称为关键字，找到对应的属性状态；此变量只读，设置无效
 */
@property (nonatomic, strong) NSMutableDictionary* attributeDict;

/**
 *	@brief	功能描述：<br>
 *      获取家电设备报警信息。设备每次报警时，会上报一条或多条报警信息，uSDK会将这些报警信息放入报警列表中。注意：uSDK只保存设备最近一次发生的报警；此变量只读，设置无效
 */
@property (nonatomic, strong) NSMutableArray* alarmList;

/**
 *	@brief	功能描述：<br>
 *      家电设备生产检测命令返回的生产检测信息（此变量不存储其他透传数据，如大数据、红外数据）；此变量只读，设置无效
 */
@property (nonatomic, strong) uSDKTransparentMessage* checkingResultMessage;

/**
 *	@brief	功能描述：<br>
 *      家电设备是否已被订阅；此变量只读，设置无效
 */
@property (nonatomic, assign) BOOL isSubscribed;

/**
 *  @brief  功能描述：<br>
 *      APP通过解析获取到的远程家电设备xml内容得到设备信息，生成远程家电设备对象。
 *
 *
 *	@param 	deviceMac   家电设备Mac地址
 *	@param 	deviceTypeIdentifier 	家电设备类型唯一标识码
 *	@param 	online 	家电设备的网络状态
 *	@param 	smartLinkVersion 	家电设备wifi的软件版本
 *  @param 	smartLinkPlatform 	家电设备wifi的平台信息（用于区分水净化系统及老空调系列模块）
 *
 *	@return	返回家电设备实例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      NSString* mac = @"mac";
 *      NSString* typeID = @"wifitype";
 *      NSString* online = @"isonline";
 *      NSString* wifiVersion = @"versionmyself";
 *      NSString* wifiPlatm = @"platformver";
 *
 *      uSDKDevice* dev = [uSDKDevice newRemoteDeviceInstance:mac withDeviceTypeIdentifier:typeID withOnline:online withSmartLinkVersion:wifiVersion withSmartLinkPlatform:wifiPlatm];
 *  </pre>
 */
+ (uSDKDevice*)newRemoteDeviceInstance:(NSString*)deviceMac withDeviceTypeIdentifier:(NSString*)deviceTypeIdentifier withOnline:(uSDKDeviceStatusConst)online withSmartLinkVersion:(NSString*)smartLinkVersion withSmartLinkPlatform:(NSString*)smartLinkPlatform;

/**
 *  @brief  功能描述：
 *      此函数可执行设备组命令和设备单命令，接口超时时间为5秒。每一种设备都有自己特定的命令集，详细的命令集描述请参看对应的设备ID文档。 设备单命令指命令名称和参数，例如洗衣机的启动、空调的设置温度等。如果单命令执行成功，uSDK更新设备的当前状态。 设备组命令需要严格遵守设备ID文档中的组命令格式，每条组命令都通过组命令名称来标识。如果组命令执行成功，设备状态的变化会随后通过消息通知方式通知APP。
 *      注意：<br>
 *      如果APP是异步调用此接口，可以通过DEVICE_OPERATION_ACK_NOTIFY消息来对应此次单命令的执行引起了哪些状态变化
 *
 *
 *	@param 	cmdList 要执行的设备操作列表，列表不能为null或空，设备操作列表中存放单个或一组命令。如果执行的是单命令，此列表中只存放一条命令；如果执行的是组命令，此列表中存放的是一组命令。
 *	@param 	cmdsn   命令sn 操作命令序号，由UI生成。如果传值为0，表示APP不关心操作命令的执行顺序；如果传值为正整数，表示APP需要把操作命令与执行结果对应起来。
 *	@param 	groupCmdName    组命令名称  组命令名称。如果执行的是组命令，组命令名称请查询对应的设备ID文档。如果要执行的是单命令，没有组命令名称，此参数应传入null或""。
 *
 *	@return	设备操作的执行结果
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 获取冰箱设备
 *      for {uSDKDevice* device in [[uSDKDeviceManager getSingleInstance] getDeviceList]) {
 *          if (device.type != SPLIT_AIRCONDITION) {
 *              continue;
 *          }
 *
 *          // 对冰箱执行进入速冻模式
 *          uSDKDeviceAttribute* attr = [[uSDKDeviceAttribute alloc] initWithAttrName:@"201007" withAttrValue:@"201007"];
 *          NSMutableArray* cmdList = [NSMutableArray arrayWithObject:attr];
 *          uSDKErrorConst uError = [iceBoxDev execDeviceOperation:cmdList withCmdSN:1000 withGroupCmdName:nil];
 *          if (uError == RET_USDK_OK) {
 *              NSLog(@"The cmd execute success.");
 *          }
 *      }
 *  </pre>
 */
- (uSDKErrorConst)execDeviceOperation:(NSMutableArray*)cmdList withCmdSN:(int)cmdsn withGroupCmdName:(NSString*)groupCmdName;

/**
 *  @brief  功能描述：
 *      此函数可执行设备组命令和设备单命令，接口超时时间为5秒。每一种设备都有自己特定的命令集，详细的命令集描述请参看对应的设备ID文档。 设备单命令指命令名称和参数，例如洗衣机的启动、空调的设置温度等。如果单命令执行成功，uSDK更新设备的当前状态。 设备组命令需要严格遵守设备ID文档中的组命令格式，每条组命令都通过组命令名称来标识。如果组命令执行成功，设备状态的变化会随后通过消息通知方式通知APP。
 *      注意：<br>
 *      如果APP是异步调用此接口，可以通过DEVICE_OPERATION_ACK_NOTIFY消息来对应此次单命令的执行引起了哪些状态变化
 *
 *
 *	@param 	cmdList 要执行的设备操作列表，列表不能为null或空，设备操作列表中存放单个或一组命令。如果执行的是单命令，此列表中只存放一条命令；如果执行的是组命令，此列表中存放的是一组命令。
 *	@param 	cmdsn   命令sn 操作命令序号，由UI生成。如果传值为0，表示APP不关心操作命令的执行顺序；如果传值为正整数，表示APP需要把操作命令与执行结果对应起来。
 *	@param 	groupName    组命令名称  组命令名称。如果执行的是组命令，组命令名称请查询对应的设备ID文档。如果要执行的是单命令，没有组命令名称，此参数应传入0。
 *
 *	@return	设备操作的执行结果
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 获取冰箱设备
 *      for {uSDKDevice* device in [[uSDKDeviceManager getSingleInstance] getDeviceList]) {
 *          if (device.type != SPLIT_AIRCONDITION) {
 *              continue;
 *          }
 *
 *          // 对冰箱执行进入速冻模式
 *          uSDKDeviceAttribute* attr = [[uSDKDeviceAttribute alloc] initWithAttrName:@"201007" withAttrValue:@"201007"];
 *          NSMutableArray* cmdList = [NSMutableArray arrayWithObject:attr];
 *          uSDKErrorConst uError = [iceBoxDev execDeviceOperation:cmdList withCmdSN:1000 withGroupName:0];
 *          if (uError == RET_USDK_OK) {
 *              NSLog(@"The cmd execute success.");
 *          }
 *      }
 *  </pre>
 */
- (uSDKErrorInfo*)execDeviceOperation:(NSMutableArray*)cmdList withCmdSN:(int)cmdsn withGroupName:(int)groupName;

@end


/**
 *	@brief	功能描述：
 *      复杂类设备属性类
 */
@interface uSDKComplexDevice : uSDKDevice

/**
 *	@brief	功能描述：<br>
 *      复杂类设备子机号；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* subId;

/**
 *	@brief	功能描述：<br>
 *      复杂类设备子机类型；此变量只读，设置无效 <br>
 *      0：所有子设备，包括室内机和室外机；1：商用空调室内机；2：商用空调室外机
 */
@property (nonatomic, assign) int subType;

@end


/**
 *	@brief  功能描述：<br>
 *      uSDK设备属性类。属性类有两重含义：一是用于描述设备的属性名称和属性值，二是用于描述设备操作。<br>
 *      当APP向设备发送操作命令时，属性名称等同于操作名称，属性值等同于操作项。每种设备都有自己的命令ID集合，具体的含义请见该设备的ID文档。 当设备属性状态发生变化时，如果APP订阅了这个设备，就能够收到这个设备的状态变化通知消息。详细请见uSDKNotificationCenter类中的DEVICE_STATUS_CHANGED_NOTIFY消息
 */
@interface uSDKDeviceAttribute : NSObject

/**
 *	@brief	功能描述：<br>
 *      家电设备属性名 属性名称对应于设备ID文档中命令ID集合中的功能识别码；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* attrName;

/**
 *	@brief	功能描述：<br>
 *      家电设备属性值 对应于设备ID文档中命令ID集合中的属性参数编码；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* attrValue;

/**
 *	@brief	功能描述：功能描述：<br>
 *      创建并初始化家电设备属性实例。在APP向设备发送操作命令时使用。当APP下发操作命令时，需要将ID文档中的ID操作转换为操作命令对象
 *
 *
 *	@param 	attrName 	家电设备属性名
 *	@param 	attrValue 	家电设备属性值
 *
 *	@return	返回家电设备属性实例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      uSDKDeviceAttribute* attr = [[uSDKDeviceAttribute alloc] initWithAttrName:@"201007" withAttrValue:@"201007"];
 *  </pre>
 */
- (id)initWithAttrName:(NSString*)attrName withAttrValue:(NSString*)attrValue;

@end


/**
 *	@brief  功能描述：<br>
 *      uSDK设备报警信息类，用于描述设备的报警消息和报警时间，其中报警的时间以uSDK收到报警的时间为准。 当设备报警时，uSDK会将报警信息通知APP，如果APP订阅了这个设备，就会得到报警通知消息。详细请见uSDKNotificationCenter类。
 */
@interface uSDKDeviceAlarm : NSObject

/**
 *	@brief  功能描述：<br>
 *      报警信息  报警消息中存储的是报警消息ID，即设备ID文档中报警ID集合的报警属性。每种设备都有各自的报警ID集合，APP需要通过设备ID文档自行匹配对应的报警描述。
 */
@property (nonatomic, strong) NSString* alarmMessage;

/**
 *	@brief  功能描述：<br>
 *      报警时间   时间格式为yyyy-MM-dd HH:mm:ss.SSS，即年-月-日 时:分:秒.毫秒（其中小时为24小时制），例如2013-01-05 23:37:27.323
 */
@property (nonatomic, strong) NSString* alarmTimestamp;

@end

/**
 *	@brief  功能描述：<br>
 *      执行操作命令，特殊设备返回两种错误信息，对应此类中的两个成员变量。一般设备只返回一个错误码（只有一个属性有值）。
 */
@interface uSDKErrorInfo : NSObject

/**
 *	@brief  功能描述：<br>
 *      错误信息号
 */
@property (nonatomic, assign) NSInteger errorNo;

/**
 *	@brief  功能描述：<br>
 *      错误信息id
 */
@property (nonatomic, assign) NSInteger errorInfoId;
@end
