//
//  SDKRequestManager.m
//  AirManager
//

#import "SDKRequestManager.h"
#import "IRDeviceManager.h"
#import "AirDevice.h"
#import "UserLoginedInfo.h"
#import <uSDKFramework/uSDKDevice.h>
#import <uSDKFramework/uSDKNotificationCenter.h>
#import <uSDKFramework/uSDKDeviceManager.h>
#import <uSDKFramework/uSDKManager.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "AlertBox.h"
#import "AirBoxStatus.h"
#import "GenerateRandom.h"

@interface SDKRequestManager ()
{
    uSDKErrorConst sdkResult;
    NSDictionary *alarmInfo;
}

/**
 *  after device list changed this method will be called
 **/
- (void)deviceListChangedMessage:(NSNotification *)notification;

/**
 *  device alarm control
 **/
- (void)deviceAlarm:(NSDictionary *)alarm;

/**
 *  device status changed
 **/
- (void)deviceStatusChanged:(NSDictionary *)status;

/**
 *  receive ir study code
 **/
- (void)deviceReceiveIrFromRemoteControl:(uSDKTransparentMessage *)irMessage;

@property (nonatomic, strong)NSDictionary *alarmInfo;

@end

@implementation SDKRequestManager

@synthesize sdkReturnedDeviceDict;
@synthesize isSDKRunning;
@synthesize alarmInfo;

#pragma mark - singleton

+ (SDKRequestManager *)sharedInstance
{
    static SDKRequestManager *singleton = nil;
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        singleton = [[super allocWithZone:NULL] init];
    });
    return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.sdkReturnedDeviceDict = [[NSMutableDictionary alloc] init];
        isSDKRunning = NO;
        //---------------ybyao-----------------
        NSString *filePath = [[NSString alloc]init];
        if ([MainDelegate isLanguageEnglish]) {
             filePath = [[NSBundle mainBundle] pathForResource:@"enAlarmMessage.plist" ofType:nil];
        }
        else{
             filePath = [[NSBundle mainBundle] pathForResource:@"AlarmMessage.plist" ofType:nil];
        }
        //---------------ybyao-------------
        self.alarmInfo = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    return self;
}

- (BOOL)isWaitConnect:(NSString *)mac
{
    DDLogFunction();
    uSDKDevice *device = sdkReturnedDeviceDict[mac];
    if(device == nil || device.status == STATUS_UNAVAILABLE || device.status == STATUS_ONLINE || device.status == STATUS_OFFLINE)
    {
        return YES;
    }
    return NO;
}

-(uSDKDeviceStatusConst)getDeviceConnectStatus:(NSString *)mac
{
    uSDKDevice *device = sdkReturnedDeviceDict[mac];
    if(!device)
    {
        return STATUS_UNAVAILABLE;
    }
    return device.status;
}

- (NSMutableArray *)deviceList
{
    NSArray *deviceList = [[uSDKDeviceManager getSingleInstance] getDeviceList];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [deviceList count]; i++)
    {
        uSDKDevice *device = deviceList[i];
        // 做容错处理，方式奔溃
        if([device isKindOfClass:[uSDKDevice class]])
        {
            if(device.type == SMART_HOME && ([device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER] || [device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER_V15]))
            {
                [array addObject:deviceList[i]];
            }
        }
    }
    return array;
}

- (void)registeListChangeNotificaion
{
    DDLogCVerbose(@"\n\n注册设备列表变化消息通知 %@\n\n",@"--->");
    [SDKNotificationCenter subscribeDeviceListChanged:self selector:@selector(deviceListChangedMessage:) withDeviceType:SMART_HOME];
}

- (void)registeDeviceNotification:(NSArray *)devList
{
    
    NSMutableArray *devMacs = [[NSMutableArray alloc] init];
    for (int i = 0; i < devList.count; i++)
    {
        AirDevice *airDev = devList[i];
        [devMacs addObject:airDev.mac];
    }
    DDLogCVerbose(@"注册设备\n注册的设备mac地址:%@",[devMacs description]);
    [SDKNotificationCenter subscribeDevice:self selector:@selector(deviceStatusChangedMessage:) withMacList:devMacs];
    DDLogCVerbose(@"注册设备\n注册的设备mac地址:%@",[devMacs description]);
}

- (void)unSubscribeDeviceNotification:(NSArray *)devList;
{
    NSMutableArray *devMacs = [[NSMutableArray alloc] init];
    for (int i = 0; i < devList.count; i++)
    {
        AirDevice *airDev = devList[i];
        [devMacs addObject:airDev.mac];
    }
    [SDKNotificationCenter unSubscribeDevice:self withMacList:devMacs];
}

- (void)startSDK
{
//    NSInteger ret = [[uSDKManager getSingleInstance] startSDK:APP_ID WithSecretKey:APP_SECRET];
    NSInteger ret = [[uSDKManager getSingleInstance] startSDK];
    if(ret == 0)
    {
        isSDKRunning = YES;
    }
}

- (void)stopSDK
{
    [SDKNotificationCenter unSubscribeDeviceListChanged:self];
    if([[uSDKManager getSingleInstance] stopSDK] == 0)
    {
        isSDKRunning = NO;
    }
}

- (void)initSDKLog
{
    sdkResult = [[uSDKManager getSingleInstance] initLog:USDK_LOG_DEBUG withWriteToFile:NO];
    DDLogCVerbose(@"%d",sdkResult);
}

#pragma mark -
#pragma mark Start EasyLink

- (uSDKErrorConst)easyLinkWithDeviceInfo:(uSDKDeviceConfigInfo *)info
{
    sdkResult = [[uSDKDeviceManager getSingleInstance] setDeviceConfigInfo:CONFIG_MODE_SMARTCONFIG
                                                        watitingConfirm:NO
                                                       deviceConfigInfo:info];
    DDLogCVerbose(@"Easy Link Result:%d",sdkResult);
    return sdkResult;
}

#pragma mark -
#pragma mark Remote Login And Logout

- (void)remoteLogin:(NSArray *)devList
{
    @autoreleasepool
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < [devList count]; i++)
        {
            AirDevice *airDevice = devList[i];
            uSDKDevice *device = [uSDKDevice newRemoteDeviceInstance:airDevice.mac
                                            withDeviceTypeIdentifier:airDevice.type
                                                          withOnline:[airDevice.isOnLine intValue]
                                                withSmartLinkVersion:airDevice.versionmyself
                                               withSmartLinkPlatform:airDevice.platformver];
            [array addObject:device];
        }
        
        int port = [MainDelegate.loginedInfo.accessPort intValue];
        sdkResult = [[uSDKDeviceManager getSingleInstance] remoteUserLogin:MainDelegate.loginedInfo.accessToken
                                                      withRemoteDevices:array
                                                withAccessGatewayDomain:MainDelegate.loginedInfo.accessIP
                                                  withAccessGatewayPort:port];
        
        
        [[SDKRequestManager sharedInstance] registeListChangeNotificaion];
        
        DDLogCVerbose(@"\n\n远程登录设备列表:%@\n\n用户token:%@\n\nIP:%@\n\n端口:%d",
                     [array description],
                     MainDelegate.loginedInfo.accessToken,
                     MainDelegate.loginedInfo.accessIP,
                     port);
    }
}

- (void)remoteLogout
{
    sdkResult = [[uSDKDeviceManager getSingleInstance] remoteUserLogout];
   
    DDLogCVerbose(@"Remote Logout Result %u",sdkResult);
}

- (NSDate *)coventDateFromString:(NSString *)string
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [format dateFromString:string];
}

- (AirDevice *)airDeviceByMac:(NSString *)mac
{
    for (int i = 0; i < MainDelegate.loginedInfo.arrUserBindedDevice.count; i++)
    {
        AirDevice *airDevice = MainDelegate.loginedInfo.arrUserBindedDevice[i];
        if([airDevice.mac isEqualToString:mac])
        {
            return airDevice;
        }
    }
    return nil;
}

- (void)deviceAlarm:(NSDictionary *)alarm
{
    if(MainDelegate.loginedInfo.arrUserBindedDevice.count == 0)return;
    
    NSArray *allKey = [alarm allKeys];
    for (int i = 0; i < allKey.count; i++)
    {
        NSString *strKey = allKey[i];
        AirDevice *airDevice = [self airDeviceByMac:strKey];
        if(airDevice)
        {
            DDLogCVerbose(@" airDevice is not nil %@",@"--->");
            if([alarm[strKey] count] > 0)
            {
                [self performSelectorInBackground:@selector(closeAlarm:) withObject:strKey];
            }
            
            for (int j = 0; j < [alarm[strKey] count]; j++)
            {
                NSMutableDictionary *allStoredAlarm = [[NSMutableDictionary alloc] initWithDictionary:[UserDefault objectForKey:DeviceAlarmStore]];
                uSDKDeviceAlarm *deviceAlarm = alarm[strKey][j];
                NSString *mesType = deviceAlarm.alarmMessage;
                DDLogCVerbose(@" alarm message %@",deviceAlarm.alarmMessage);
                NSString *storeName = [NSString stringWithFormat:@"%@%@",strKey,mesType];
                NSDate *storedTimeStamp = allStoredAlarm[storeName];
                if(storedTimeStamp)
                {
                    DDLogCVerbose(@"\n\n alert 时间 1%@--%@",storedTimeStamp,[NSDate date]);
                    DDLogCVerbose(@"%d\n\n",abs([storedTimeStamp timeIntervalSinceDate:[NSDate date]]));
                    
                    if(abs([storedTimeStamp timeIntervalSinceDate:[NSDate date]]) > 60 * 30)//（60 * 30）30分钟内不再弹出提示对话框, ybyao
                    {
                        if(alarmInfo[mesType] && ![mesType isEqualToString:@"50w000"])
                        {
                            [allStoredAlarm setObject:[NSDate date] forKey:storeName];
                            [UserDefault setObject:allStoredAlarm forKey:DeviceAlarmStore];
                            [UserDefault synchronize];
                            
                            if(airDevice.name && ![mesType isEqualToString:@"50w000"] && ![mesType isEqualToString:@"50w004"] && ![mesType isEqualToString:@"50w007"])
                            {
                                NSString *message = [NSString stringWithFormat:@"[%@]%@",NSLocalizedString(airDevice.name,@"SDKRequestManager1.m"),NSLocalizedString(alarmInfo[mesType],@"SDKRequestManager1.m")];//ybyao
                                [self showAlarmMessage:message];
                                [self playSoundAndShake];
                            }
                        }
                    }
                }
                else
                {
                    DDLogCVerbose(@"\n\n alert 时间 2%@--%@",storedTimeStamp,[NSDate date]);
                    DDLogCVerbose(@"%d\n\n",abs([storedTimeStamp timeIntervalSinceDate:[NSDate date]]));
                    if(alarmInfo[mesType] && ![mesType isEqualToString:@"50w000"])
                    {
                        [allStoredAlarm setObject:[NSDate date] forKey:storeName];
                        [UserDefault setObject:allStoredAlarm forKey:DeviceAlarmStore];
                        [UserDefault synchronize];
                        
                        if(airDevice.name && ![mesType isEqualToString:@"50w000"])
                        {
                            NSString *message = [NSString stringWithFormat:@"[%@]%@",NSLocalizedString(airDevice.name,@"SDKRequestManager1.m"),NSLocalizedString(alarmInfo[mesType],@"SDKRequestManager1.m")];
                            
                            [self showAlarmMessage:message];
                            [self playSoundAndShake];
                        }
                    }
                }
            }
        }
    }
}

- (void)showAlarmMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"警告信息",@"SDKRequestManager.m")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定",@"SDKRequestManager.m")
                                              otherButtonTitles:nil];
        [alert show];
    });
}

- (void)playSoundAndShake
{
    static SystemSoundID soundID = 1006;
    /** 5.26
    NSString * path = [[NSBundle mainBundle] pathForResource:@"glass" ofType:@"wav"];
    if (path)
    {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    }
     */
    AudioServicesPlaySystemSound (soundID);
    // 播放震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

static int cmdsn = 0;
- (void)closeAlarm:(NSString *)mac
{
    cmdsn = (cmdsn + 1) / 10000;
    uSDKDevice *device = self.sdkReturnedDeviceDict[mac];
    uSDKDeviceAttribute *attr = [[uSDKDeviceAttribute alloc] init];
    attr.attrName = @"20w0ZX";
    attr.attrValue = @"";
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:attr,nil];
    uSDKErrorConst error = [device execDeviceOperation:array withCmdSN:cmdsn withGroupCmdName:nil];
   
    DDLogCVerbose(@"%d",error);
}

- (void)deviceStatusChanged:(NSDictionary *)status
{
    DDLogCVerbose(@"处理收到的设备状态数据 %@",status);
    
    [status enumerateKeysAndObjectsUsingBlock:^(id objKey, id obj, BOOL *stop){
        AirBoxStatus *deviceStatus = MainDelegate.allAirBoxStatus[objKey]?MainDelegate.allAirBoxStatus[objKey]:[[AirBoxStatus alloc] init];
        uSDKDevice *device = self.sdkReturnedDeviceDict[objKey];
        DDLogCVerbose(@"设备所有状态值 %@",device.attributeDict);
        //[device.attributeDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            
            /**
            if([((uSDKDeviceAttribute *)obj).attrName isEqualToString:@"20w00i"])
            {
                DDLogCVerbose(@"device status value  %@  name %@",((uSDKDeviceAttribute *)obj).attrValue, ((uSDKDeviceAttribute *)obj).attrName);
            }
             //key20w00i uSDKDeviceAttribute attrValue = ""  "20w00i"

             
             **/
        NSArray *allKeys = [device.attributeDict allKeys];
        for (int i = 0; i < allKeys.count; i++)
        {
            NSString *key = allKeys[i];
            id obj = device.attributeDict[key];
            
            BOOL pmValueIsNum = NO;
            if([key isEqualToString:@"60w001"])
            {
                uSDKDeviceAttribute *temp = (uSDKDeviceAttribute *)obj;
                deviceStatus.temperature = [NSNumber numberWithDouble:[temp.attrValue doubleValue]];
                DDLogCVerbose(@"设备状态值温度: %f",[temp.attrValue doubleValue]);
            }
            else if([key isEqualToString:@"60w002"])
            {
                uSDKDeviceAttribute *hum = (uSDKDeviceAttribute *)obj;
                deviceStatus.humidity = [NSNumber numberWithDouble:[hum.attrValue doubleValue]];
                DDLogCVerbose(@"设备状态值湿度: %f",[hum.attrValue doubleValue]);
            }
            else if([key isEqualToString:@"60w007"] && !pmValueIsNum)
            {
                uSDKDeviceAttribute *pm25 = (uSDKDeviceAttribute *)obj;
                deviceStatus.pm25 = pm25.attrValue;
                DDLogCVerbose(@"设备状态值 60w007 PM2.5: %@",pm25.attrValue);
            }
            else if([key isEqualToString:@"60w004"])
            {
                uSDKDeviceAttribute *voc = (uSDKDeviceAttribute *)obj;
                deviceStatus.voc = voc.attrValue;
            }
            else if ([key isEqualToString:@"60w00k"])
            {
                uSDKDeviceAttribute *pm25 = (uSDKDeviceAttribute *)obj;
                if([pm25.attrValue intValue] > 0)
                {
                    deviceStatus.pm25 = pm25.attrValue;
                    pmValueIsNum = YES;
                }
                DDLogCVerbose(@"设备状态值 60w00k PM2.5: %@",pm25.attrValue);
            }
            // 播报音量
            else if ([key isEqualToString:@"20w00o"])
            {
                uSDKDeviceAttribute *voice = (uSDKDeviceAttribute *)obj;
                deviceStatus.voiceVaule = voice.attrValue;
                DDLogCVerbose(@"播报音量 20w00o: %@", voice.attrValue);
            }
        }
        //}];
        
        [self countAirDevice:device moodPoint:deviceStatus completeHandler:^(NSString *point){
            deviceStatus.moodPoint = point;
            [MainDelegate.allAirBoxStatus setObject:deviceStatus forKey:objKey];
            [NotificationCenter postNotificationName:SdkDeviceStatusChangedNotification object:nil userInfo:objKey];
            DDLogCVerbose(@"根据相关状态值上传服务器后计算得到的心情值 :%@",deviceStatus.moodPoint);
        }];
    }];
}

- (void)countAirDevice:(uSDKDevice *)device moodPoint:(AirBoxStatus *)status completeHandler:(void(^)(NSString *point))handler
{
    AirDevice *airDevice = [self airDeviceByMac:device.mac];
    NSString *temp = [NSString stringWithFormat:@"%d",[MainDelegate countTempVlue:status.temperature
                                                                         hardWare:airDevice.baseboard_software
                                                                           typeID:airDevice.type]];
    NSString *hum = [NSString stringWithFormat:@"%d",[MainDelegate countHumValue:status.humidity
                                                                        withTemp:status.temperature
                                                                        hardWare:airDevice.baseboard_software
                                                                          typeID:airDevice.type]];
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID],
                              @"temperature":status.temperature ? temp : @"",
                              @"humidity":status.humidity ? hum : @"",
                              @"pm25":status.pm25 ? status.pm25 : @"",
                              @"voc":status.voc ? status.voc : @""};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_COUNT_QUALITY(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         if(!error)
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->count point result:%@",result);
             if(result && [result[HttpReturnCode] intValue] == 0)
             {
                if(isObject(result[@"happyScore"]))
                {
                    NSNumber *happyScore = result[@"happyScore"];
                    handler([happyScore stringValue]);
                }
                else
                {
                    handler(@"-1");
                }
             }
             else
             {
                 handler(@"-1");
             }
         }
         else
         {
             double temperature = [[dicBody objectForKey:@"temperature"] doubleValue];
             double humidity = [[dicBody objectForKey:@"humidity"] doubleValue];
             NSString *pm25Str = [dicBody objectForKey:@"pm25"];
             NSInteger voc = [[dicBody objectForKey:@"voc"] integerValue];
             
             NSString * indoorPm25=[Utility coventPM25StatusForAirManagerIndoor:pm25Str withMac:airDevice.mac];
             DDLogCVerbose(@"randomPm25%@",indoorPm25);
        
             float totalFloat= [indoorPm25 floatValue];
             int pm25= roundf(totalFloat);
             
             if(temperature >= 60)
             {
                 
                 NSInteger moodTmp = [Utility happyScore:temperature :humidity :pm25 :voc];
                 if(moodTmp < 0)
                 {
                     handler(@"-1");
                 }
                 else
                 {
                     handler([NSString stringWithFormat:@"%d",moodTmp]);
                 }
             }
             else
             {
                 
                 NSInteger moodTmp = [Utility happyScore3:temperature :humidity :pm25 :voc];
                 if(moodTmp < 0)
                 {
                     handler(@"-1");
                 }
                 else
                 {
                     handler([NSString stringWithFormat:@"%d",moodTmp]);
                 }
             }
         }
         
     }];
}

- (void)deviceReceiveIrFromRemoteControl:(uSDKTransparentMessage *)irMessage
{
    DDLogCVerbose(@"红外学习SDK上报的数据:%d---%@---%@",irMessage.messageType,irMessage.messageContent,irMessage.deviceMac);
    [NotificationCenter postNotificationName:SdkDeviceReceiveIrNotification object:irMessage.messageContent userInfo:nil];
}

#pragma mark - Device List Changed Notification

- (void)deviceListChangedMessage:(NSNotification *)notification
{
    DDLogFunction();
    NSDictionary* devLstDict = [uSDKDeviceManager getSingleInstance].deviceDict;
    self.sdkReturnedDeviceDict = [[NSMutableDictionary alloc] init];
    for (NSString *key in devLstDict)
    {
        uSDKDevice *device = [devLstDict objectForKey:key];
        
        // 做容错处理，方式奔溃
        if([device isKindOfClass:[uSDKDevice class]])
        {
            if(device.type == SMART_HOME && ([device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER] || [device.typeIdentifier isEqualToString:AIRBOX_IDENTIFIER_V15]))
            {
                [sdkReturnedDeviceDict setObject:device forKey:key];
            }
        }
    }
    
    DDLogCVerbose(@"\n\n\n设备列表发生变化\n\n%@\n\n",sdkReturnedDeviceDict);
}

- (void)deviceStatusChangedMessage:(NSNotification *)notification
{
    NSDictionary *object = [notification object];
    
    DDLogCVerbose(@"收到SDK通0知上报 :%@",[object description]);
    
    if([notification.name isEqualToString:DEVICE_STATUS_CHANGED_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_STATUS_CHANGED_NOTIFICATION:接收到设备状态发生变化通知\n%@\n",[object description]);
        [self deviceStatusChanged:object];
    }
    else if([notification.name isEqualToString:DEVICE_ONLINE_CHANGED_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_ONLINE_CHANGED_NOTIFICATION:接收到设备连接状态发生变化通知\n%@\n%@\n",[object description],[NSDate date]);
        [NotificationCenter postNotificationName:SdkDeviceOnlineChangedNotification object:object userInfo:nil];
    }
    else if([notification.name isEqualToString:DEVICE_BINDMESSAGE_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_BINDMESSAGE_NOTIFICATION:接收到设备绑定通知\n%@\n%@\n",[object description],[NSDate date]);
        [NotificationCenter postNotificationName:SdkDeviceBindedNotification object:object userInfo:nil];
    }
    else if([notification.name isEqualToString:DEVICE_UNBINDMESSAGE_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_UNBINDMESSAGE_NOTIFICATION:接收到设备解绑通知\n%@\n%@\n",[object description],[NSDate date]);
        [NotificationCenter postNotificationName:SdkDeviceUNBindedNotification object:object userInfo:nil];
    }
    else if([notification.name isEqualToString:DEVICE_ALARM_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_ALARM_NOTIFICATION:接收到报警通知\n%@\n%@\n",[object description],[NSDate date]);
        [self deviceAlarm:object];
    }
    else if([notification.name isEqualToString:DEVICE_INFRAREDINFO_NOTIFICATION])
    {
        DDLogCVerbose(@"\n\n DEVICE_INFRAREDINFO_NOTIFICATION:接收SDK上报的到红外学习通知\n%@\n%@\n",[object description],[NSDate date]);
        [self deviceReceiveIrFromRemoteControl:(uSDKTransparentMessage *)object];
    }
}

@end
