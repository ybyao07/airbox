//
//  AppDelegate.h
//  AirManager
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class UserLoginedInfo;
@class AirDevice;
@class AirQuality;
#import "PushMessage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>{
    UserLoginedInfo     *loginedInfo;
    AirDevice           *curBindDevice;            //在home界面显示的绑定的空气盒子
    AirQuality          *curAirQuality;
    BOOL                isShowingAlertBox;
    NSMutableDictionary *allAirBoxStatus;
    BOOL                isCustomer;                // 是否为游客
}




/**
 * Return program document files
 **/
- (NSURL *)applicationDocumentsDirectory;

/**
 * md5 Encryption
 **/
- (NSString *)md5:(NSString *)input;

/**
 *  Return a network request
 **/
- (NSMutableURLRequest *)requestUrl:(NSURL *)url method:(NSString *)method body:(NSString *)body;

/**
 * Conversion mood value
 **/
- (int)moodValueConvert:(int)value;

/**
 *  covent pm2.5 value to string
 **/
- (NSString *)coventPM25Status:(NSString *)code;
/**
 * covent VOC value to string
 **/
- (NSString *)coventVOCStatus:(NSString *)code;
/**
 * Wait view show
 **/
- (void)showProgressHubInView:(UIView *)view;


/**
 * Wait view hidden
 **/
- (void)hiddenProgressHubInView:(UIView *)view;

/**
 *  parse json data
 **/
- (id)parseJsonData:(NSData *)data;

/**
 *  create json data
 **/
- (NSString *)createJsonString:(NSDictionary *)dictionary;

/**
 *  create operation
 **/
- (NSInvocationOperation *)operationWithTarget:(id)target selector:(SEL)sel object:(id)object;

/**
 *  Get connected net work ssid
 **/
- (NSString*)ssidForConnectedNetwork;

/**
 *  check the net work connect status
 **/
- (BOOL)isNetworkAvailable;

/**
 *外网判断
 **/
- (BOOL)isNetworkAvailableWiFiOr3G;

/**
 *  count the right temp value
 **/
- (int)countTempVlue:(NSNumber *)temp hardWare:(NSString *)version typeID:(NSString *)type;

/**typeID:(NSString *)type
 *  count the right humidity value
 **/
- (int)countHumValue:(NSNumber *)hum withTemp:(NSNumber *)temp hardWare:(NSString *)version typeID:(NSString *)type;

/**
 *  create a sequence id
 **/
- (NSString *)sequenceID;

// Judgment phone format
- (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 *  use error code to get error string 
 **/
- (NSString *)erroInfoWithErrorCode:(NSString *)errorCode;

/**
 *  The current network is WiFi
 **/
- (BOOL)isCurrentNetworkWiFi;

/**
 *  Version examine
 */
- (void)versionExamineOnClicked:(id)sender;

/**
 *  The current network is enable
 **/
- (void)isCurrentNetworkEnable:(void(^)(BOOL enable))handler;

/**
 *  Session expiration，relogin donwload new token
 **/
- (void)reDownloadToken:(void(^)(BOOL succeed))handler;

/**
 *  sift point weather icon name
 *
 *  @param name server icon name
 *
 *  @return icon name
 */
- (NSString *)siftCurrentIconWithName:(NSString *)name needNight:(BOOL)need Hour:(NSInteger)hour;
/**
 * 是否为英文
 *
 *
 *
 *  @return range
 */

-(void)resetCurAirDevice;

-(BOOL)isLanguageEnglish;

-(NSString *)cityNameInternationalized:(NSString*)cityname;

- (void)testNetworkAvailable;
-(void)startGetPm25FloatRange:(AirDevice *)device;

- (void)doHandleMessage:(PushMessage *)pushMessage;

- (void)sendConfirmMessage:(NSNumber *)isYES;;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) UserLoginedInfo *loginedInfo;
@property (strong, nonatomic) AirDevice *curBindDevice;
@property (strong, nonatomic) AirQuality *curAirQuality;
@property (nonatomic,assign)  BOOL isShowingAlertBox;
@property (strong, nonatomic) NSMutableDictionary *allAirBoxStatus;
@property (copy,nonatomic) NSMutableDictionary* pm25FloatRange;
@property (nonatomic,assign)  BOOL isCustomer;
@property (nonatomic,assign)  BOOL isNetworkConnenct;

@property (nonatomic,strong) NSNumber *devicelat;//ybyao07
@property (nonatomic,strong) NSNumber *devicelng;

@property (nonatomic,assign)  BOOL isNoFirstTime;
@property (nonatomic,strong) NSMutableDictionary *dicNSTime;

@property (nonatomic, copy) NSString *pushMessageID;


@end
