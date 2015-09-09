//
//  Globals.h
//  AirManager
//


#define kLineHeight1px (1/[[UIScreen mainScreen] scale])

#define kCurNormalFontOfSize(fontSize)				[UIFont systemFontOfSize:fontSize]
#define kCurBoldFontOfSize(fontSize)				[UIFont boldSystemFontOfSize:fontSize]
#define kCurItalicFontOfSize(fontSize)				[UIFont italicSystemFontOfSize:fontSize]

#define kUIColorOfHex(color)						[UIColor colorWithHex:(color) alpha:1.0]


#define PNG                         @".png"
#define GIF                         @".gif"

#define HTTP_POST                   @"POST"
#define HTTP_GET                    @"GET"
#define HTTP_DELETE                 @"DELETE"
#define HTTP_PUT                    @"PUT"

// Cache数据
#define kCacheDataFile								@"CacheData.dat"

#define kCityIDBeijing          @"101010100"
#define kCityNameBeijing        @"北京"

#define BASEVIEWHEIGH               568
#define BASEVIEWWIDTH               320

#define CUSTEMER_TEMP               @557

#define AIRBOX_IDENTIFIER           @"101c120024000810140d00118003940000000000000000000000000000000000"
#define AIRBOX_IDENTIFIER_V15       @"101c120024000810140d00118003944600000000000000000000000000000000" // 1.5代的盒子

#define APP_ID                      @"MB-SMARTAIR1-0000"
#define APP_KEY                     @"1m62dg5c2vhtqf06w1se550h070aec1y" // (生产)
//#define APP_KEY                     @"4bc73ba50b00b2bddd984ed176e478c4" // (测试)
#define APP_SECRET                  @"C68D6FF33B47133DCE376A07756DE901"

#define APP_VERSION                 @"01.01.15.2.9.1"
#define APP_UPDATE_VERSION          @"2015010101"

/////////////////////////////////////////////////////////////////
/// 发布环境
/////////////////////////////////////////////////////////////////
#define SERVER                      @"http://uhome.haier.net:7080/smartair"
#define LOGIN_SERVER                @"http://uhome.haier.net:9080"
#define PMS_SERVER                  @"http://uhome.haier.net:6080"
#define COMMON_SERVER               @"http://uhome.haier.net:6000/commonapp"

/////////////////////////////////////////////////////////////////
/// 联调环境
/////////////////////////////////////////////////////////////////
//#define SERVER                      @"http://103.8.220.166:40000/smartair"
//#define LOGIN_SERVER                @"http://103.8.220.166:40000"
//#define PMS_SERVER                  @"http://103.8.220.166:40000"
//#define COMMON_SERVER               @"http://103.8.220.166:40000/commonapp"

/////////////////////////////////////////////////////////////////
/// 验收环境
/////////////////////////////////////////////////////////////////
//#define SERVER                      @"http://210.51.17.150:6000/smartair"
//#define LOGIN_SERVER                @"http://210.51.17.150:6000"
//#define PMS_SERVER                  @"http://210.51.17.150:6000"
//#define COMMON_SERVER               @"http://210.51.17.146:60000/commonapp"

#define SERVER_GETPMRANGE             [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/pm25/getCalibrationParameter",SERVER]]

#define SERVER_REGISTER             [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/register",SERVER]]
#define SERVER_IS_ACTIVE(uID)       [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/queryactivate/%@",SERVER,uID]]
#define SERVER_ACTIVE               [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/activate",SERVER]]
#define SERVER_GET_CODE             [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/users/getcode",SERVER]]
#define SERVER_LOGIN                [NSURL URLWithString:[NSString stringWithFormat:@"%@/security/userlogin",LOGIN_SERVER]]
#define SERVER_LOGOUT               [NSURL URLWithString:[NSString stringWithFormat:@"%@/security/userlogout",LOGIN_SERVER]]
#define SERVER_PMS(uID)             [NSURL URLWithString:[NSString stringWithFormat:@"%@/pms/aas/%@/assignAdapter",PMS_SERVER,uID]]
#define SERVER_DEVICE_LIST(uID)     [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/devices",SERVER,uID]]
#define SERVER_AIR_QUALITY(dID)     [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/quality/instant/%@",SERVER,dID]]
#define SERVER_COUNT_QUALITY(uID)   [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/gethappyscore/%@",SERVER,uID]]
#define SERVER_UNBIND_DEV(uID,dID)  [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/unbinddevices/%@",SERVER,uID,dID]]
#define SERVER_BIND_DEV(uID)        [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/binddevices",SERVER,uID]]
#define SERVER_HISTORY(dID)         [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/quality/%@",SERVER,dID]]
#define SERVER_HISTORY_HOUR(dID)    [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/quality/instantDate/%@",SERVER,dID]]
#define SERVER_RENAME(dID)          [NSURL URLWithString:[NSString stringWithFormat:@"%@/devices/%@",SERVER,dID]]
#define SERVER_CHECK_IRCODE(dID)    [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdata/check/%@",SERVER,dID]]
#define SERVER_DOWNLOAD_IRCODE(dID) [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdata/%@",SERVER,dID]]
#define SERVER_BINDED_IRDEV(dID)    [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdevices/getlist/%@",SERVER,dID]]
#define SERVER_UNBIND_IRDEV(dID)    [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdevices/unbind/%@",SERVER,dID]]
#define SERVER_IRDEV_MODEL_LIST     [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdevices/models/getlist",SERVER]]
#define SERVER_DEV_BIND_IRDEV(dID)  [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdevices/bind/%@",SERVER,dID]]
#define SERVER_CUR_WEATHER(uID)     [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/weather/instant/%@",SERVER,uID]]
#define SERVER_FUT_WEATHER(uID)     [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/weather/%@",SERVER,uID]]
#define SERVER_DOWN_DEV_MODEL(dID)  [NSURL URLWithString:[NSString stringWithFormat:@"%@/modes/getmode/%@",SERVER,dID]]
#define SERVER_SET_DEV_MODEL(dID)   [NSURL URLWithString:[NSString stringWithFormat:@"%@/modes/setmode/%@",SERVER,dID]]
#define SERVER_SUGGESTION(uID)      [NSURL URLWithString:[NSString stringWithFormat:@"%@/suggestion/add/%@",SERVER,uID]]
#define SERVER_IR_MATCH(dID)        [NSURL URLWithString:[NSString stringWithFormat:@"%@/irdata/match/%@",SERVER,dID]]
#define SERVER_SEND_TOKEN           [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/devicetoken/upload",SERVER]]
#define SERVER_FEEDBACK(uID)        [NSURL URLWithString:[NSString stringWithFormat:@"%@/suggestion/list/%@",SERVER,uID]]
#define SERVER_SUBMIT_ERRORCODE(uID)[NSURL URLWithString:[NSString stringWithFormat:@"%@/apperror/submit/%@",SERVER,uID]]
#define SERVER_GET_IRCODE(macID,uID,irVersion) [NSURL URLWithString:[NSString stringWithFormat:@"%@/userircode/%@/%@/%@",SERVER,macID,uID,irVersion]]
#define SERVER_SET_IRCODE(macID,uID)[NSURL URLWithString:[NSString stringWithFormat:@"%@/userircode/%@/%@",SERVER,macID,uID]]
#define SERVER_VERSION(uID)         [NSURL URLWithString:[NSString stringWithFormat:@"%@/appversion/getnewversion/%@",SERVER,uID]]
#define SERVER_DEL_IRCODE(macID,uID,keyCode,sequenceId) [NSURL URLWithString:[NSString stringWithFormat:@"%@/userircode/%@/%@?keycode=%@&sequenceId=%@",SERVER,macID,uID,keyCode,sequenceId]]
#define SERVER_WEATHER_AIRQUALITY(uID)      [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/weather/air/%@",SERVER,uID]]
#define SERVER_WEATHER_IDNEX(uID)           [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/weather/index/%@",SERVER,uID]]
#define SERVER_WEATHER_POINT(uID)           [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/weather/pointbyarea/%@",SERVER,uID]]

//修改小A位置信息ybyao07
#define SERVER_CHANGE_DEVICELOCATION         [NSURL URLWithString:[NSString stringWithFormat:@"%@/device/updatelocation",SERVER]]
//获取非数显盒子Pm2.5校准参数

// 查询周边N个盒子的室内实时空气质量信息
#define SERVER_PERIPHERY_INSTANT         [NSURL URLWithString:[NSString stringWithFormat:@"%@/data/quality/peripheryInstant",SERVER]]

// 根据msgid获取长消息体
#define SERVER_PUSH_MESSAGE(uID)               [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/originalMessages",COMMON_SERVER,uID]]

// 上传消息确认
#define SERVER_MESSEGES_CONFIRM(uID)           [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/messages/confirm",COMMON_SERVER,uID]]



#define MainDelegate                ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define UserDefault                 [NSUserDefaults standardUserDefaults]
#define NotificationCenter          [NSNotificationCenter defaultCenter]
#define SDKNotificationCenter       [uSDKNotificationCenter defaultCenter]

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#endif

#define AgreeUserAgreementNotification              @"AgreeUserAgreementNotification"
#define AirControlPageOpenCompleteNotification      @"AirControlPageOpenCompleteNotification"
#define AllAirDeviceRemovedNotification             @"AllAirDeviceRemovedNotification"
#define AllAirDeviceRemovedNotificationByDeleted    @"AllAirDeviceRemovedNotificationByDeleted"
#define AirDeviceRemovedNotification                @"AirDeviceRemovedNotification"
#define IRDevicesChangedNotification                @"IRDevicesChangedNotification"
#define AirDevicesChangedNotification               @"AirDevicesChangedNotification"
//#define LogoutNotification                          @"LogoutNotification"

#define SdkDeviceStatusChangedNotification          @"SdkDeviceStatusChangedNotification"
#define SdkDeviceOnlineChangedNotification          @"SdkDeviceOnlineChangedNotification"
#define SdkDeviceBindedNotification                 @"SdkDeviceBindedNotification"
#define SdkDeviceUNBindedNotification               @"SdkDeviceUNBindedNotification"
#define SdkDeviceReceiveIrNotification              @"SdkDeviceReceiveIrNotification"
#define WeatherDownloadedNotification               @"WeatherDownloadedNotification"
#define ChangeAirBoxSucceedNotification             @"ChangeAirBoxSucceedNotification"
#define ResumeAnimationsEnterForegroundNotification @"ResumeAnimationsEnterForegroundNotification"
#define CityChangedNotification                     @"CityChangedNotification"
#define WeathePM25ChangeNotification                @"WeathePM25ChangeNotification"

#define HttpReturnCode                              @"retCode"
#define HttpReturnInfo                              @"retInfo"
#define CelciusSymbol                               @"℃"
#define PercentSymbol                               @"%"
#define CelciusSymbol2                              @"°"

// The count downd seconds to enable retrive account activation code
#define kCountDownSeconds   60
#define InvalidTokenCode    21019
#define InvalidTokenCode2   21018
#define AutoStudyWaitTime   20

/**
 *  Automatic login information to access key
 **/
#define AutoLoginInfo           @"AutoLoginInfo"
#define IsAutoLogin             @"IsAutoLogin"
#define LoginUserName           @"LoginUserName"
#define LoginPassWord           @"LoginPassWord"

#define kNoAccountUserAirMode   @"NoAccountUserAirMode"

/**
 *  small A information access key
 **/
#define AirManagerLastInfo      @"AirManagerLastInfo"
#define AirManagerNickName      @"AirManagerNickName"
#define AirManagerRoomName      @"AirManagerRoomName"
#define AirManagerPM25          @"pm25"
#define AirManagerTemp          @"temperature"
#define AirManagerHumidity      @"humidity"
#define AirManagerPM25Cache     @"pm25Cache" // by TreeJohn
#define AirManagerTempCache     @"temperatureCache"// by TreeJohn
#define AirManagerHumidityCache @"humidityCache"// by TreeJohn
#define AirManagerMood          @"mark"
#define AirManagerMoodInfo      @"markInfo"
#define AirManagerMac           @"mac"
#define AirManagerBindIRDevInfo @"bindIRDeviceInfo"

#define DeviceLocation @"deviceLocation"//ybyao07
#define DeviceLat @"lat"
#define DeviceLng @"lng"
/**
 *  Infrared codes access key
 **/

#define IRDeviceIRCodeStore     @"IRDeviceIRCode"
#define IRDeviceOpen            @"20e00E"
#define IRDeviceClose           @"20e00F"
#define IRDeviceCloseCodeTag    @"IRDeviceCloseCodeTag"
#define APDeviceOpenCodeTag     @"APDeviceOpenCodeTag"

/**
 *  Conditioned on the transmitted infrared command the operation name
 **/

#define SendIRCommand   @"60w0ZT"

// Background color
#define kPageBackgroundColor    [UIColor colorWithRed:228/255.0 green:226/255.0 blue:214/255.0 alpha:1.0]

#define kClientVersion          @"ClientVersionTmp"
#define kIsShowScoreView        @"isShowScoreView"
#define kIsShowGuideView        @"isShowGuideView"
#define kSaveDate               @"SaveDate"

// Key of guide presented
#define kGuidePresented         @"GuidePresented"

// Key of home page help present
#define kHomePageHelp           @"HomePageHelp"

// Key of air box management page help present
#define kAirBoxManagementHelp   @"AirBoxManagementHelp"

// Key of air box control page help present
#define kAirBoxControlHelp      @"AirBoxControlHelp"

// String utilities
#define isEmptyString( str )  (( str == nil || str == NULL || [str isEqualToString:@""] || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ) ? YES : NO)

// object is null
#define isObject(obj) [obj isEqual:[NSNull null]] ? NO : YES

// key of CityInfo
#define kSelectedCity           @"SelectedCity"

//setTimecellBodyColor
#define kSetTimeCellBodyColor   [UIColor colorWithRed:246/255.0f green:245/255.0f blue:241/255.0f alpha:1]
#define kTextColor              [UIColor colorWithRed:111/255.0f green:113/255.0f blue:121/255.0f alpha:1]

#define kColorWithRGB(r,g,b,a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// Weather key
#define kCurrentWeather  @"currentWeatherNew"
#define kWeatherTimeKey  @"weathertime"
#define kCurrentPM25     @"PM25"
#define khour 60*60

// device alarm store ky
#define DeviceAlarmStore @"DeviceAlarmStore"

#define DeviceToken      @"deviceToken"

#define CityName        @"city_name"
#define InstantWeatherDefine  @"instant_weather"
#define Temperature     @"temperature"
#define Humidy          @"humidy"
#define Wind            @"wind"
#define WindDirect      @"wind_direction"
#define CurWeather      @"weather"
#define CurTime         @"time"

#define Weather1        @"weather1"
#define Weather2        @"weather2"
#define Weather3        @"weather3"
#define Weather4        @"weather4"
#define Date            @"date"
#define DayTemp         @"day_temp"
#define DayWeather      @"day_weather"
#define DayWind         @"day_wind"
#define DayWindDirect   @"day_wind_direction"
#define NightTemp       @"night_temp"
#define NightWeather    @"night_weather"
#define NightWind       @"night_wind"
#define NightWindDirect @"night_wind_direction"
#define Week            @"week"
#define kBackGroundName @"backGroundImageName"



// device Type
#define kDeviceTypeAC   @"AC"
#define kDeviceTypeAP   @"AP"

// App store link

#define kAppStoreLink    [NSURL URLWithString:@"https://itunes.apple.com/cn/app/kong-qi-he-zi/id849464472?mt=8"]

#define MAX_HOURS       99

#define	encode(encoder, name, type)		[encoder encode##type:name forKey:[NSStringFromClass([self class]) stringByAppendingString:@#name]]
#define	decode(decoder, name, type)		self.name = [decoder decode##type##ForKey:[NSStringFromClass([self class]) stringByAppendingString:@#name]]

#define IRCodeOnline(macID,userName) [NSString stringWithFormat:@"%@|%@|IRCode|Online",macID,userName]
#define IRCodeAddOutline(macID,userName) [NSString stringWithFormat:@"%@|%@|IRCode|AddOutline",macID,userName]
#define IRCodeDeleteOutLine(macID,userName) [NSString stringWithFormat:@"%@|%@|IRCode|DeleteOutLine",macID,userName]
//ybyao07
#define CurrentTime @"currentTime"

//#define kNotFirstMode3Key(macID,userName)   [NSString stringWithFormat:@"FirstMode3|%@|%@",macID,userName]
