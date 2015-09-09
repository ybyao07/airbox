//
//  uSDKManager.h
//  uSDK_iOS_v2
//
//  Created by Zono on 14-1-7.
//  Copyright (c) 2014年 haierubic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "uSDKConstantInfo.h"

//#define CERTIFICATE_FILE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/ios.cert"]
//NSString* usdk_appID;
//NSString* usdk_secretKey;
//NSString* usdk_curTime;
/**
 *	@brief	功能描述：<br>
 *      uSDK服务单例类，用于管理uSDK服务的生命周期。
 */
@interface uSDKManager : NSObject

/**
 *	@brief	功能描述：<br>
 *      日志级别，此变量为uSDK内部私有变量，设置无效
 */
@property (nonatomic, assign) uSDKLogLevelConst logLevel;

/**
 *	@brief	功能描述：<br>
 *      uSDK错误码对应的中文含义描述；此变量只读，设置无效
 */
@property (nonatomic, strong) NSDictionary* constantInfoDic;

/**
 *	@brief	功能描述：<br>
 *      uSDK版本号。版本号格式为：主版本号.次版本号.修正版本号_发布时间；此变量只读，设置无效
 */
@property (nonatomic, strong) NSString* uSDKVersion;

/**
 *	@brief	功能描述：<br>
 *      获取uSDK单例，此单例用于管理uSDK服务。
 *
 *
 *	@return	返回uSDKManager单例
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      uSDKManager* sdkManager = [uSDKManager getSingleInstance];
 *  </pre>
 */
+ (uSDKManager*)getSingleInstance;

/**
 *	@brief	功能描述：<br>
 *          设置uSDK日志信息接口。uSDK的日志信息包括设置日志级别和是否写日志文件，日志级别设置的越高，输出的日志信息就越详细，如果要写日志文件，需要在手机上插入SD存储卡。<br>
 *          详细的日志信息便于开发者快速分析程序bug，日志文件将会保存到/sdcard/uHomeSDK目录下。如果手机上没有插入存储卡，日志信息会被输出到终端上。日志文件最大为10MBytes。
 *
 *
 *	@param 	level   日志输出级别，详细含义请参见uSDKLogLevelConst
 *	@param 	isWriteToFile   是否需要写日志文件。true表示把日志写到文件中，false表示把日志写到终端上。
 *
 *	@return	返回设置日志结果
 *  
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      [[uSDKManager getSingleInstance]initLog:USDK_LOG_DEBUG withWriteToFile:NO];
 *  </pre>
 */
- (uSDKErrorConst)initLog:(uSDKLogLevelConst)level withWriteToFile:(BOOL)isWriteToFile;

/**
 *	@brief	功能描述：<br>
 *      启动uSDK服务接口，接口超时时间为5s。uSDK服务启动后，将提供设备自动发现能力。如果uSDK服务无法启动，此接口返回uSDK启动失败。
 *
 *
 *	@return	返回uSDK启动成功或失败
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      [[uSDKManager getSingleInstance] startSDK];
 *
 *  </pre>
 */
- (uSDKErrorConst)startSDK;
//-(uSDKErrorConst)startSDKWithAppId:(NSString*)aID AndSecretKey:(NSString*)sKey;

/**
 *	@brief	功能描述：<br>
 *      停止SDK服务接口。调用此接口，uSDK会停止设备自动发现能力，所有设备都将处于无效状态。
 *
 *
 *	@return	返回停止uSDK结果
 *
 *  <p>
 *  示例代码：
 *  </p>
 *
 *  <pre>
 *      [[uSDKManager getSingleInstance] stopSDK];
 *  </pre>
 */
- (uSDKErrorConst)stopSDK;

@end



