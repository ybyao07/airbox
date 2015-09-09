//
//  uSDKNotificationCenter.h
//  uSDK_iOS_v2
//
//  Created by oet on 14-1-13.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uSDKConstantInfo.h"

/**
 *	@brief	uSDK通知中心类
 */
@interface uSDKNotificationCenter : NSObject

/**
 *	@brief	消息字典集合，[{Key: 消息类型, Object: 对应通知数据}, {}...] <br>
 *    消息类型及对应的数据：<br>
 *    deviceListChangedNotify --- 发生变化的设备列表 <br>
 *    deviceOnlineChangedNotify --- 发生变化的设备Mac：此设备的在线状态，uSDKDeviceStatusConst类型 <br>
 *    deviceStatusChangedNotify --- 发生变化的设备Mac：此设备当前发生的属性变化字典 <br>
 *    deviceAlarmNotify --- 发生变化的设备Mac：此设备当前上报的报警列表 <br>
 *    deviceInfraredInfoNotify --- 当前上报的红外消息，uSDKTransparentMessage类实例 <br>
 *    bigDataNotify --- 当前上报的大数据消息，uSDKTransparentMessage类实例 <br>
 *    deviceBindMessageNotify --- 设备Mac：解绑或绑定 <br>
 *    businessMessageNofify --- 当前推送的业务消息，uSDKBusinessMessage类实例 <br>
 *    sessionExceptionNotify --- 当前失效的远程session，字符串类型
 */
//@property(nonatomic, strong) NSMutableDictionary *messageDictionary;

/**
 *	@brief	获取uSDKNotificationCenter单例
 *
 *	@return	返回uSDKNotificationCenter单例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      uSDKNotificationCenter* messageCenter = [uSDKNotificationCenter defaultCenter];
 *  </pre>
 */
+ (uSDKNotificationCenter*)defaultCenter;

/**
 *	@brief	订阅设备相关消息,设备处于任何状态时都可以进行订阅，将需要关注的设备订阅，就会收到该设备的状态信息。
 *
 *	@param 	object 	需要接收通知的对象实例
 *	@param 	aSelector 	接收到通知后执行的回调方法
 *	@param 	deviceMacList 	需要订阅的家电设备Mac地址列表
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 在某个view controller中订阅设备（下面代码中的self即这个view controller）
 *      for (uSDKDevice* device in [[uSDKDeviceManager getSingleInstance] getDeviceList]) {
 *          NSArray* deviceMacs = [NSArray arrayWithObjects:device.mac, nil];
 *          [[uSDKNotificationCenter defaultCenter] subscribeDevice:self selector:@selector(deviceAttibuteReport:) withMacList:deviceMacs];
 *      }
 *
 *      // 在这个view controller中的tableView上刷新设备属性状态
 *      -(void)deviceAttibuteDict:(NSNotification*)notification
 *      {
 *          dispatch_queue_t network_queue;
 *          network_queue = dispatch_queue_create("com.myapp.saveDeviceInfo", nil);
 *          dispatch_async(network_queue, ^{
 *              dispatch_async(dispatch_get_main_queue(), ^{
 *                  [self.tableView reloadData];
 *              });
 *          });
 *      }
 *  </pre>
 */
- (void)subscribeDevice:(id)object selector:(SEL)aSelector withMacList:(NSArray*)deviceMacList;

/**
 *	@brief	订阅设备列表变化消息，当设备列表发生变化时，通过Handler的uSDKNotificationCenter. DEVICE_LIST_CHANGED_NOTIFY将设备列表上报给UI，可以通过type来确定关注哪种类型的设备，或是全部关注。
 *
 *	@param 	object 	需要接收通知的对象实例
 *	@param 	selector 	接收到通知后执行的回调方法
 *  @param  deviceType  需要订阅变化通知的设别类型
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 在某个view controller中订阅所有类型的设备列表（下面代码中的self即这个view controller）
 *      [[uSDKNotificationCenter defaultCenter] subscribeDeviceListChanged:self selector:@selector(receiveDevLstReport:) withDeviceType:ALL_TYPE];
 *
 *      // 在这个view controller中的tableView上刷新设备列表
 *      -(void)receiveDevLstReport:(NSNotification*)notification
 *      {
 *          dispatch_queue_t network_queue;
 *          network_queue = dispatch_queue_create("com.myapp.saveDeviceInfo", nil);
 *          dispatch_async(network_queue, ^{
 *              dispatch_async(dispatch_get_main_queue(), ^{
 *                  [self.tableView reloadData];
 *              });
 *          });
 *      }
 *  </pre>
 */
- (void)subscribeDeviceListChanged:(id)object selector:(SEL)selector withDeviceType:(uSDKDeviceTypeConst)deviceType;

/**
 *	@brief	订阅内部错误上报。
 *
 *	@param 	object 	需要接收通知的对象实例
 *	@param 	selector 	接收到通知后执行的回调方法
 */
-(void)subscribeInnerErrorMessage:(id)object selector:(SEL)selector;

/**
 *	@brief	订阅业务数据上报通知
 *
 *	@param 	object 	需要接收通知的对象实例
 *	@param 	selector    接收到通知后执行的回调方法
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 在某个view controller中订阅业务消息（下面代码中的self即这个view controller）
 *      [[uSDKNotificationCenter defaultCenter] subscribeBusinessMessage:self selector:@selector(businessMessageReport:)];
 *
 *      // 在这个view controller的UIView上提示业务消息内容
 *      -(void)businessMessageReport:(NSNotification*)notification
 *      {
 *          dispatch_queue_t network_queue;
 *          network_queue = dispatch_queue_create("com.myapp.saveDeviceInfo", nil);
 *          dispatch_async(network_queue, ^{
 *              dispatch_async(dispatch_get_main_queue(), ^{
 *                  NSLog(@"We got a business Message!");
 *              });
 *          });
 *      }
 *  </pre>
 */
- (void)subscribeBusinessMessage:(id)object selector:(SEL)selector;

/**
 *	@brief	取消家电设备相关信息通知
 *
 *	@param 	object 	取消接收通知的对象实例
 *	@param 	deviceMacList 	取消订阅的家电设备Mac地址列表
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 取消订阅某个设备
 *      for (uSDKDevice* device in [[uSDKDeviceManager getSingleInstance] getDeviceList]) {
 *          NSArray* deviceMacs = [NSArray arrayWithObjects:device.mac, nil];
 *          [[uSDKNotificationCenter defaultCenter] unSubscribeDevice:self withMacList:deviceMacs];
 *      }
 *  </pre>
 */
- (void)unSubscribeDevice:(id)object withMacList:(NSArray*)deviceMacList;

/**
 *	@brief	取消订阅家电设备列表变化通知。一旦取消，将取消所有设备类型的设备列表订阅。
 *
 *	@param 	object 	取消接收通知的对象实例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 取消订阅设备列表
 *      [[uSDKNotificationCenter defaultCenter] unSubscribeDeviceListChanged:self];
 *  </pre>
 */
- (void)unSubscribeDeviceListChanged:(id)object;

/**
 *	@brief	取消业务数据上报通知
 *
 *	@param 	object 	取消接收通知的对象实例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 取消订阅业务消息
 *      [[uSDKNotificationCenter defaultCenter] unSubscribeBusinessMessage:self];
 *  </pre>
 */
- (void)unSubscribeBusinessMessage:(id)object;

/**
 *	@brief	取消内部错误上报通知
 *
 *	@param 	object 	取消接收通知的对象实例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      // 取消订阅业务消息
 *      [[uSDKNotificationCenter defaultCenter] unsubscribeInnerErrorMessage:self];
 *  </pre>
 */
-(void)unsubscribeInnerErrorMessage:(id)object;
@end
