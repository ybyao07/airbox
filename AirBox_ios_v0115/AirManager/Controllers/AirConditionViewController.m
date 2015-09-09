//
//  AirConditionViewController.m
//  AirManager
//

#import "AirConditionViewController.h"
#import "AirAdjustCell.h"
#import "TimingCell.h"
#import "SetTimeCell.h"
#import "IRDeviceManager.h"
#import "AirDevice.h"
#import "AirQuality.h"
#import "IRDevice.h"
#import "AirPurgeModel.h"
#import "IRDeviceModelSelectionViewController.h"
#import "AirDeviceManager.h"
#import "TimerAnimationView.h"
#import "UIDevice+Resolutions.h"
#import <uSDKFramework/uSDKConstantInfo.h>
#import <uSDKFramework/uSDKDevice.h>
#import "AppDelegate.h"
#import "AlertBox.h"
#import "ApAdjustCell.h"
#import "NewTimingCell.h"
#import "CustomModelViewController.h"
#import "AlertBoxViewController.h"

typedef enum {
    kSendApIrCode = 0,
    kSendAcIrCode,
    kSendNone
}SendIrCodeType;

@interface AirConditionViewController (){
    IBOutlet UIButton           *onOffBtn;
    IBOutlet UITableView        *acTableView;
    IBOutlet UILabel            *lblRoomTemp;
    UITapGestureRecognizer      *tapPointGesture;
    UITapGestureRecognizer      *tapTimeGesture;
    
    __weak IBOutlet UIButton    *btnStudy;
    BOOL                        isSetTimeModel;     //set time model，cell will show a picker
    BOOL                        isLimitTime;        //mark the limit time open status
    BOOL                        isLeavePage;
    BOOL                        openOrCloseAC;
    
    uSDKDevice                  *sdkDevice;
    AirPurgeModel               *curPurgeModel;     //current data
    AirPurgeModel               *beforePurgeModel;     //current data
    
    NSTimer                     *countDownTimer;
    NSTimeInterval              countDownSecond;
    NSOperationQueue            *acOptionQueue;
    NSInteger                   controlCounter;
    NSString                    *bootCodeKey;
    
    BOOL                        apOpened;
    BOOL                        acOpened;
    SendIrCodeType              sendIrCodeType;
    BOOL                        haveHealthyState;
    
    IBOutlet                    UIView *subBgView;
    
    UIButton                    *cancleButton;
    
}


@property (nonatomic, strong)AirPurgeModel  *curPurgeModel;
@property (nonatomic, strong)AirPurgeModel  *beforePurgeModel;
@property (nonatomic, strong)NSOperationQueue   *acOptionQueue;
@property (nonatomic, strong)NSString   *bootCodeKey;

@end

@implementation AirConditionViewController

#define NotLimitTag     @"9999"
#define CoolImg         @"04-制冷.png"
#define HotImg          @"制热-640.png"
#define JieNengImg      @"ic_jineng.png"
#define ShuShiImg       @"ic_shushi.png"
#define OnOrOffModel    @"30e0M0"

@synthesize airQuality;
@synthesize arrBindIRDevice;
@synthesize curPurgeModel;
@synthesize beforePurgeModel;
@synthesize acOptionQueue;
@synthesize bootCodeKey;

- (void)dealloc
{
    if([countDownTimer isValid])
    {
        [countDownTimer invalidate];
    }
    countDownTimer = nil;
    
    DDLogFunction();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
   
    countDownSecond = 0;//default value
    isSetTimeModel = NO;
    isLimitTime = NO;
    isLeavePage = NO;
    sendIrCodeType = kSendNone;
    
    [self onOffBtnHighligthImage];
    NSString *temp = [NSString stringWithFormat:@"%d",[MainDelegate countTempVlue:airQuality.temperature
                                                                         hardWare:_curDevice.baseboard_software
                                                                           typeID:_curDevice.type]];
    if([airQuality.temperature integerValue] == 0)
    {
        if(MainDelegate.isCustomer)
        {
            temp = [NSString stringWithFormat:@"%d",[MainDelegate countTempVlue:CUSTEMER_TEMP
                                                                       hardWare:nil
                                                                         typeID:nil]];
        }
        else
        {
            temp = @"--";
        }
    }
    if ([MainDelegate isLanguageEnglish]) {
        lblRoomTemp.text = [NSString stringWithFormat:@"Air contidition: current indoor temperature%@%@",temp,CelciusSymbol];
        lblRoomTemp.font=[lblRoomTemp.font fontWithSize:10];
        
    }else{
        lblRoomTemp.text = [NSString stringWithFormat:@"空调: 当前室内温度%@%@",temp,CelciusSymbol];
        
    }
    
    self.curPurgeModel = [[AirPurgeModel alloc] init];
    self.beforePurgeModel = [[AirPurgeModel alloc] init];
    
    [self checkIsIncludeHeathly];
    self.acOptionQueue = [[NSOperationQueue alloc] init];
    
    tapPointGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countDownTimeSet)];
    tapTimeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countDownTimeSet)];
    
    sdkDevice = [AirDeviceManager connectedAirDevice:MainDelegate.curBindDevice];
    [self customTableView];

    [self performSelectorInBackground:@selector(downloadAirBoxModel:) withObject:0];
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)layoutView
{
    _baseview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BASEVIEWWIDTH, BASEVIEWHEIGH)];
    
    for(UIView *subView in self.view.subviews)
    {
        if(subView != _baseview)
        {
            [subView removeFromSuperview];
            [_baseview addSubview:subView];
        }
    }
    
    //判断是不是ios7
    if (IOS7) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
       [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
#endif
    }
    
    _baseview.frame = CGRectMake(0, ADDHEIGH, 320, VIEWHEIGHT);
    _baseview.backgroundColor  = [UIColor clearColor];
    [self.view addSubview:_baseview];
}
- (void)viewDidAppear:(BOOL)animated
{
    [NotificationCenter postNotificationName:AirControlPageOpenCompleteNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View Option

- (void)checkIsIncludeHeathly
{
    DDLogFunction();
    for (int i = 0; i < [arrBindIRDevice count]; i++)
    {
        IRDevice * device = arrBindIRDevice[i];
        if([device.devType isEqualToString:@"AC"])
        {
            // Being only AC, without regard to AP
            NSString *key = [NSString stringWithFormat:@"%@%@%@",device.brand,device.devType,device.devModel];
            NSDictionary *irCodeStore = [UserDefault objectForKey:IRDeviceIRCodeStore][key];
            haveHealthyState = [irCodeStore[IRCode][HealthyState] boolValue];
        }
    }
}

- (void)customTableView
{
    DDLogFunction();
    //Set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    acTableView.tableFooterView = footerView;
    
    //Set the offset cell separator
    BOOL isSystemVersionIsIos7 = [UIDevice isSystemVersionOnIos7];
    if (isSystemVersionIsIos7) {
        [acTableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)reloadTableView
{
    DDLogFunction();
    if(isLeavePage)return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self onOffBtnHighligthImage];
        [acTableView reloadData];
    });
}

- (void)reloadSection:(NSIndexSet *)sections
{
    DDLogCVerbose(@"%lu",(unsigned long)sections.firstIndex);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sections.firstIndex == 0)
        {
            [acTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [acTableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

#pragma mark - Count Down Control

- (void)countDownAnimationStart:(TimingCell *)cell
{
    [cell.timerView addGestureRecognizer:tapPointGesture];
    [cell.lblTime addGestureRecognizer:tapTimeGesture];
    [cell.timerView startAnimating];
    [self startCountDown];
}

- (void)countDownAnimationStop:(TimingCell *)cell
{
    [cell.timerView removeGestureRecognizer:tapPointGesture];
    [cell.lblTime removeGestureRecognizer:tapTimeGesture];
    [cell.timerView stopAnimating];
    [self stopCountDown];
}

- (void)startCountDown
{
    if(countDownTimer.isValid)return;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self
                                                    selector:@selector(updateTime)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)updateTime
{
    NewTimingCell *cell = (NewTimingCell *)[acTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    countDownSecond = countDownSecond - 60;
    DDLogCVerbose(@"coun download : ===\n\n%f===\n\n",countDownSecond);
    if(countDownSecond < 60)
    {
        [self startOrStopModel:nil];
        return;
    }
    
    [self limitTime];
    if(isSetTimeModel)return;
    cell.lblContent.text = curPurgeModel.time;
}

- (void)stopCountDown
{
    if(countDownTimer.isValid)
    {
        [countDownTimer invalidate];
    }
    countDownTimer = nil;
}

#pragma mark - Download And Load Model

- (void)downloadAirBoxModel:(NSInteger)requestCount
{
    DDLogFunction();
    
    if(MainDelegate.isCustomer)
    {
        NSDictionary *airMode = [UserDefault objectForKey:kNoAccountUserAirMode];
        if(airMode)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSNumber *mode = isObject(airMode[@"mode"])?airMode[@"mode"]:[NSNumber numberWithInt:1];
                if([mode integerValue] == 0)
                {
                    [curPurgeModel parserAirModel:airMode];
                    beforePurgeModel = [curPurgeModel copy];
                }
                else if([mode integerValue] == 4 ||
                        [mode integerValue] == 5 ||
                        [mode integerValue] == 3)
                {
                    [beforePurgeModel parserAirModel:airMode];
                    curPurgeModel = [beforePurgeModel copy];
                    curPurgeModel.onOff = IRDeviceClose;
                    curPurgeModel.apOnOff = IRDeviceClose;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadCurrentModel];
                });
            });
        }
        return;
    }
    
    @autoreleasepool
    {
        
        NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_DOWN_DEV_MODEL(MainDelegate.curBindDevice.mac)];
        
        if(![MainDelegate isNetworkAvailable])
        {
            NSDictionary *airMode = isObject([UserDefault objectForKey:cacheKey])?[UserDefault objectForKey:cacheKey]:[NSDictionary dictionary];
            NSNumber *mode = isObject(airMode[@"mode"])?airMode[@"mode"]:[NSNumber numberWithInt:1];
            
            if([mode integerValue] == 0)
            {
                [curPurgeModel parserAirModel:airMode];
                beforePurgeModel = [curPurgeModel copy];
            }
            else if([mode integerValue] == 4 ||
                    [mode integerValue] == 5 ||
                    [mode integerValue] == 3)
            {
                [beforePurgeModel parserAirModel:airMode];
                curPurgeModel = [beforePurgeModel copy];
                curPurgeModel.onOff = IRDeviceClose;
                curPurgeModel.apOnOff = IRDeviceClose;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadCurrentModel];
            });
            
            return;
        }
        if(isLeavePage)return;
        [MainDelegate showProgressHubInView:self.view];
        NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
        NSString *body = [MainDelegate createJsonString:dicBody];
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_DOWN_DEV_MODEL(MainDelegate.curBindDevice.mac)
                                                         method:HTTP_POST
                                                           body:body];
        
        [NSURLConnection sendAsynchronousRequestTest:request
                                                queue:acOptionQueue
                                    completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
         {
             if(isLeavePage)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 return;
             }
             
             NSString *errorInfo = NSLocalizedString(@"模式下载失败", );
             if(error)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 if(isLeavePage)return;
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [AlertBox showWithMessage:errorInfo];
                 });
             }
             else
             {
                 NSDictionary *result = [MainDelegate parseJsonData:data];
                 result = isObject(result) ? result : nil;
                 DDLogCVerbose(@"--->下载用户空气盒子模式信息%@",result);
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                 {
                     [MainDelegate hiddenProgressHubInView:self.view];
                     NSDictionary *airMode = isObject(result[@"userAirMode"])?result[@"userAirMode"]:[NSDictionary dictionary];
                     NSNumber *mode = isObject(airMode[@"mode"])?airMode[@"mode"]:[NSNumber numberWithInt:1];
                
                     if([mode integerValue] == 0)
                     {
                         [curPurgeModel parserAirModel:airMode];
                         beforePurgeModel = [curPurgeModel copy];
                         // 组织Json数据
                         NSMutableDictionary *dictionaryJson = [[NSMutableDictionary alloc] init];
                         [curPurgeModel seriaAirModel:dictionaryJson];
                         
                         [UserDefault setObject:dictionaryJson forKey:cacheKey];
                         [UserDefault synchronize];
                     }
                     else if([mode integerValue] == 4 ||
                             [mode integerValue] == 5 ||
                             [mode integerValue] == 3)
                     {
                         [beforePurgeModel parserAirModel:airMode];
                         curPurgeModel = [beforePurgeModel copy];
                         curPurgeModel.onOff = IRDeviceClose;
                         curPurgeModel.apOnOff = IRDeviceClose;
                     }
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self loadCurrentModel];
                     });
                 }
                 else
                 {
                     if(result && ![result[HttpReturnCode] isEqual:[NSNull null]])
                     {
                         if([result[HttpReturnCode] intValue] == InvalidTokenCode || [result[HttpReturnCode] intValue] == InvalidTokenCode2)
                         {
                             if(requestCount < 3)
                             {
                                 [MainDelegate reDownloadToken:^(BOOL succeed){
                                     [self downloadAirBoxModel:requestCount + 1];
                                 }];
                                 return;
                             }
                         }
                     }
                     
                     [MainDelegate hiddenProgressHubInView:self.view];
                     if(result && isObject(result[HttpReturnInfo]))
                     {
                         if(result[HttpReturnInfo] && ![result[HttpReturnInfo] isEqualToString:@"会话过期"])
                         {
                             errorInfo = result[HttpReturnInfo];
                         }
                     }
                     if(isLeavePage)return;
                    [AlertBox showWithMessage:errorInfo];
                 }
             }
         }];
    }
}

- (void)limitTime
{
    int timeSecond = countDownSecond;
    int second = (int)timeSecond % 60;
    if(second > 0)
    {
        timeSecond = timeSecond + 60;
    }
    int hour = timeSecond / (60 * 60);
    int minute = (timeSecond - hour * 60 * 60) / 60;
    curPurgeModel.time = [NSString stringWithFormat:@"%02d:%02d",hour,minute];
}

- (void)limitTimeToSecond:(NSString *)time
{
    countDownSecond = [[time substringToIndex:2] intValue] * 60 * 60 + [[time substringWithRange:NSMakeRange(2, 2)] intValue] * 60 + [[time substringFromIndex:4] intValue];
}

- (void)loadCurrentModel
{
    if(isLeavePage)return;
    
    if([curPurgeModel.onOff isEqualToString:IRDeviceOpen])
    {
        acOpened = YES;
    }
    else
    {
        acOpened = NO;
    }
    
    if([curPurgeModel.apOnOff isEqualToString:IRDeviceOpen])
    {
        apOpened = YES;
    }
    else if([curPurgeModel.apOnOff isEqualToString:IRDeviceClose])
    {
        apOpened = NO;
    }
    
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAP])
        {
            apOpened= NO;
        }
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            acOpened = NO;
        }
    }
    // 手动模式的空调已关闭的话，time清零
    if(!acOpened)
    {
        curPurgeModel.time = @"9999";
    }
    if(!MainDelegate.isCustomer )
    {
        if(![MainDelegate isNetworkAvailable])
        {
            curPurgeModel.time = @"9999";
        }
    }
    NSString *time = curPurgeModel.time;
    if([time isEqualToString:@"9999"] || [time isEqualToString:@"999999"] ||
       [time isEqualToString:@"00:00"]|| [time isEqualToString:@"0000"])
    {
        isLimitTime = NO;
        countDownSecond = 0;
    }
    else
    {
        isLimitTime = YES;
        [self limitTimeToSecond:time];
    }
    
    [self limitTime];
        
    [self reloadTableView];
}

#pragma mark - Send IR Code



- (void)prepareSendApIRCode
{
    DDLogFunction();
    if(MainDelegate.isCustomer) return;
    if(isLeavePage)return;
    NSDictionary *allIRCode = [UserDefault objectForKey:IRDeviceIRCodeStore];
    for (int i = 0; i < [arrBindIRDevice count]; i++)
    {
        if(isLeavePage)return;
        
        IRDevice * device = arrBindIRDevice[i];
        if(isLeavePage)return;
        
        if([device.devType isEqualToString:@"AP"])
        {
            // Being only AC, without regard to AP
            NSString *key = [NSString stringWithFormat:@"%@%@%@",device.brand,device.devType,device.devModel];
            NSDictionary *irCodeStore = allIRCode[key];
    
            NSInteger index = apOpened ? 0 : 1;
            NSString *code = irCodeStore[IRCode][IRDeviceCloseCodeTag];
            if(index == 0)
            {
                code = irCodeStore[IRCode][APDeviceOpenCodeTag];
            }
            if(!code)
            {
                [AlertBox showWithMessage:NSLocalizedString(@"没有找到相应红外命令", )];
                return;
            }
            sendIrCodeType = kSendApIrCode;
            [self performSelectorInBackground:@selector(sendIRCode:) withObject:code];
        }
    }
}

- (void)prepareSendAcIRCode:(BOOL)selected
{
    DDLogFunction();
    if(MainDelegate.isCustomer) return;
    if(isLeavePage)return;
    NSDictionary *allIRCode = [UserDefault objectForKey:IRDeviceIRCodeStore];
    
    for (int i = 0; i < [arrBindIRDevice count]; i++)
    {
        if(isLeavePage)return;
        
        IRDevice * device = arrBindIRDevice[i];
        if(isLeavePage)return;
        
        if([device.devType isEqualToString:@"AC"])
        {
            // Being only AC, without regard to AP
            NSString *key = [NSString stringWithFormat:@"%@%@%@",device.brand,device.devType,device.devModel];
            NSDictionary *irCodeStore = allIRCode[key];
            NSString *temp = [curPurgeModel.temperature stringByReplacingOccurrencesOfString:CelciusSymbol withString:@""];
            NSString *speed = curPurgeModel.operationCodeList[curPurgeModel.windSpeed];
            NSString *model = curPurgeModel.operationCodeList[curPurgeModel.acMode];
            NSString *onOrOff = curPurgeModel.onOff;
            NSString *healthyState = [curPurgeModel.healthyState isEqualToString:@"on"] ? @"T" : @"F";
            
            if(openOrCloseAC)
            {
                NSArray *allKeys = [irCodeStore[IRCode] allKeys];
                NSString *onOffModelKey = nil;
                for (int i = 0 ; i < allKeys.count; i++)
                {
                    NSString *key = allKeys[i];
                    if([key rangeOfString:@"30e0M020e00E"].length > 0 && selected)
                    {
                        onOffModelKey = key;
                        break;
                    }
                    else if([key rangeOfString:@"30e0M020e00F"].length > 0 && !selected)
                    {
                        onOffModelKey = key;
                        break;
                    }
                }
                if(onOffModelKey)
                {
                    NSString *onOffModelCode = irCodeStore[IRCode][onOffModelKey];
                    sendIrCodeType = kSendAcIrCode;
                    [self performSelectorInBackground:@selector(sendIRCode:) withObject:onOffModelCode];
                    return;
                }
            }
            
            if(selected && [onOrOff isEqualToString:IRDeviceClose])
            {
                onOrOff = IRDeviceOpen;
            }
            
            NSString *codeKey = [NSString stringWithFormat:@"%@%@%@%@",temp,speed,model,onOrOff];
            if(haveHealthyState)
            {
                codeKey = [codeKey stringByAppendingString:healthyState];
            }
            NSString *code = irCodeStore[IRCode][codeKey];
            if(!selected && code == nil)
            {
                code = irCodeStore[IRCode][IRDeviceCloseCodeTag];
            }
            
            if(!code)
            {
                if(openOrCloseAC && selected)
                {
                    NSArray *allKeys = [irCodeStore[IRCode] allKeys];
                    for (int i = 0 ; i < allKeys.count; i++)
                    {
                        NSString *key = allKeys[i];
                        if([key rangeOfString:@"30e0M1"].length > 0)
                        {
                            self.bootCodeKey = key;
                            break;
                        }
                    }
                    
                    if(bootCodeKey)
                    {
                        code = irCodeStore[IRCode][bootCodeKey];
                        sendIrCodeType = kSendAcIrCode;
                        [self performSelectorInBackground:@selector(sendIRCode:) withObject:code];
                    }
                    else
                    {
                        [AlertBox showWithMessage:NSLocalizedString(@"没有找到相应红外命令",) ];
                    }
                    controlCounter--;
                    return;
                }
                
                [AlertBox showWithMessage:NSLocalizedString(@"没有找到相应红外命令",) ];
                controlCounter--;
                return;
            }
            sendIrCodeType = kSendAcIrCode;
            [self performSelectorInBackground:@selector(sendIRCode:) withObject:code];
        }
    }
}

static int cmdsn = 0;

- (void)sendIRCode:(NSString *)code
{
    @autoreleasepool
    {
        if(isLeavePage)return;
        cmdsn = (cmdsn + 1) / 10000;
        NSMutableArray *cmdList = [[NSMutableArray alloc] init];
        [self deviceCommands:cmdList withCmdName:SendIRCommand withCmdValue:code];

        DDLogCVerbose(@"execDeviceOperation 开始%@",@"----->");
        uSDKErrorConst error = [sdkDevice execDeviceOperation:cmdList withCmdSN:cmdsn withGroupCmdName:nil];
        DDLogCVerbose(@"execDeviceOperation 结束%@",@"----->");
        controlCounter--;
        
        DDLogCVerbose(@"Send IR Code Return Code: %u",error);
        if(error == RET_USDK_OK)
        {
            if(sendIrCodeType == kSendAcIrCode)
            {
                if(!acOpened)
                {
                    curPurgeModel.time = @"00:00";
                    isLimitTime = NO;
                    [self reloadSection:[NSIndexSet indexSetWithIndex:0]];
                }
                
                if(bootCodeKey && openOrCloseAC && acOpened)
                {
                    curPurgeModel.temperature = [NSString stringWithFormat:@"%@%@",[bootCodeKey substringToIndex:2],CelciusSymbol];
                    curPurgeModel.windSpeed = curPurgeModel.operationCodeList[[bootCodeKey substringWithRange:NSMakeRange(2,6)]];
                    self.bootCodeKey = nil;
                }
                
                [self reloadTableView];
                
                [self uploadAcModel:NO];
            }
            else if(sendIrCodeType == kSendApIrCode)
            {
                apOpened = apOpened ? YES : NO;
                [self reloadSection:[NSIndexSet indexSetWithIndex:2]];
                [self uploadAcModel:NO];
            }
        }
        else
        {
            if(sendIrCodeType == kSendAcIrCode)
            {
                if(error == RET_USDK_DEV_OFFLINE_ERR)
                {
                    [AlertBox showWithMessage:NSLocalizedString(@"当前设备不在线",@"AirConditionViewController.m") delegate:nil showCancel:NO];
                    return;
                }
                
                if(isLeavePage)return;
                
                [AlertBox showIsRetryBoxWithDelegate:(id)self];
                
                if(openOrCloseAC)
                {
                    acOpened = !acOpened;
                    
                    if(!acOpened)
                    {
                        countDownSecond = 0;
                        [self limitTime];
                        isLimitTime = acOpened;
                    }
                }
                
                [self reloadTableView];
            }
            else if(sendIrCodeType == kSendApIrCode)
            {
                if(error == RET_USDK_DEV_OFFLINE_ERR)
                {
                    [AlertBox showWithMessage:NSLocalizedString(@"当前设备不在线",@"AirConditionViewController.m") delegate:nil showCancel:NO];
                    return;
                }
                
                if(isLeavePage)return;
                
                apOpened = apOpened ? NO : YES;
                [self reloadSection:[NSIndexSet indexSetWithIndex:2]];
            }
        }
    }
    
}

- (void)deviceCommands:(NSMutableArray*)cmdlist withCmdName:(NSString*)cmdname withCmdValue:(NSString*)cmdvalue
{
    DDLogFunction();
    if (nil == cmdname)
    {
        cmdvalue = @"";
    }
    if (nil == cmdvalue)
    {
        cmdvalue = @"";
    }
    uSDKDeviceAttribute* attr = [[uSDKDeviceAttribute alloc] init];
    attr.attrName = cmdname;
    attr.attrValue = cmdvalue;
    [cmdlist addObject:attr];
}

- (void)uploadAcModel:(BOOL)isWait
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
    }
    NSInteger curMode = 0; // 个人模式
    NSString *curTemp = [curPurgeModel.temperature stringByReplacingOccurrencesOfString:CelciusSymbol withString:@""];
    NSString *curStatus = curPurgeModel.onOff;
    NSString *acmode = curPurgeModel.operationCodeList[curPurgeModel.acMode];;
    NSString *speed = curPurgeModel.operationCodeList[curPurgeModel.windSpeed];
    NSString *time = curPurgeModel.time;
    NSString *apOnOff = curPurgeModel.apOnOff;
    if(!isLimitTime)
    {
        time = NotLimitTag;
    }
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *healthyState = curPurgeModel.healthyState ? curPurgeModel.healthyState : @"";
    NSNumber *acflag = curPurgeModel.acflag ? curPurgeModel.acflag : @NO;
    NSNumber *apflag = curPurgeModel.apflag ? curPurgeModel.apflag : @NO;
    NSString *pm25 = curPurgeModel.pm25 ? curPurgeModel.pm25 : @"50";
    NSString *sleepModeId = curPurgeModel.sleepModeId ? curPurgeModel.sleepModeId : @"";
    
    if([time isEqualToString:@"0000"])
    {
        time = @"9999";
    }
    
    NSDictionary *dicMode = @{@"mode":[NSString stringWithFormat:@"%d",curMode],
                              @"time":time,
                              @"temperature":curTemp,
                              @"onoff":curStatus,
                              @"acmode":acmode,
                              @"windspeed":speed,
                              @"aponoff":apOnOff,
                              @"healtyState":healthyState,
                              //  智能控制新增加的几个参数
                              @"acflag":acflag,
                              @"apflag":apflag,
                              @"pm25":pm25,
                              @"sleepModeId":sleepModeId
                              };
    // 重置一下前期保存的beforePurgeModel的modeIndex
    beforePurgeModel.modeIndex = [NSNumber numberWithInteger:curMode];
    
    if(MainDelegate.isCustomer)
    {
        [UserDefault setObject:dicMode forKey:kNoAccountUserAirMode];
        [UserDefault synchronize];
       
        return;
    }
    
    if(isLeavePage)return;
    if(isWait)
    {
        [MainDelegate showProgressHubInView:self.view];
    }

    NSDictionary *dicBody = @{@"userAirMode":dicMode,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_SET_DEV_MODEL(MainDelegate.curBindDevice.mac)
                                                     method:HTTP_POST
                                                       body:body];
    DDLogCVerbose(@"上传小A模式到服务器  %@  %@",dicBody,request);
    
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:acOptionQueue
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_DOWN_DEV_MODEL(MainDelegate.curBindDevice.mac)];
         NSMutableDictionary *dicModeTmp = [dicMode mutableCopy];
         [dicModeTmp setObject: @"9999" forKey: @"time"];
         [UserDefault setObject:dicModeTmp forKey:cacheKey];
         [UserDefault synchronize];
         
         NSDictionary *result = [MainDelegate parseJsonData:data];
         result = isObject(result) ? result : nil;
         DDLogCVerbose(@"--->设置用户空气盒子模式返回值%@",result);
         if(isWait)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             isLeavePage = YES;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.navigationController popViewControllerAnimated:YES];
             });
         }
    }];
}

#pragma mark - AP Device Control

- (void)bindIrDevice:(NSString *)type
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您没有网络,无法绑定新设备",@"WeatherMainViewController")];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = @"IRDeviceModelSelectionViewController";
        IRDeviceModelSelectionViewController *vc = [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
        vc.deviceType = type;
        vc.selectedAirDevice = MainDelegate.curBindDevice;
        vc.airPurgeModel = curPurgeModel;
        vc.view.frame = self.view.frame;
        vc.view.alpha = 0.0;
        [MainDelegate.window addSubview:vc.view];
        [self addChildViewController:vc];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
    });
}

- (void)changeApStatus
{
    apOpened = YES;
    [self reloadSection:[NSIndexSet indexSetWithIndex:2]];
}

#pragma mark - Button Action

- (void)onOffBtnHighligthImage
{
    NSString *imgName = acOpened ? @"08-开.png" : @"08-关.png";
    dispatch_async(dispatch_get_main_queue(), ^{
        [onOffBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        subBgView.backgroundColor = [UIColor colorWithRed:acOpened ? 71.0/255.0 : 158.0/255.0
                                                    green:acOpened ? 189.0/255.0 : 158.0/255.0
                                                     blue:acOpened ? 60.0/255.0 : 158.0/255.0
                                                    alpha:1.0];
    });
}

- (void)apOnOffBtnHighligthImage
{
    NSString *imgName = apOpened ? @"08-开.png" : @"08-关.png";
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    ApAdjustCell *cell = (ApAdjustCell *)[acTableView cellForRowAtIndexPath:indexPath];
    [cell.onOffBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    cell.subBg.backgroundColor = [UIColor colorWithRed:apOpened ? 71.0/255.0 : 158.0/255.0
                                                 green:apOpened ? 189.0/255.0 : 158.0/255.0
                                                  blue:apOpened ? 60.0/255.0 : 158.0/255.0
                                                 alpha:1.0];
}

- (void)countDownTimeSet
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![MainDelegate isNetworkAvailable])
            return;
    }
    if(!isSetTimeModel)
    {
        isSetTimeModel = YES;
        [self reloadSection:[NSIndexSet indexSetWithIndex:0]];
    }
}


- (IBAction)acPageDone:(id)sender{
    DDLogFunction();
    isLeavePage = YES;
    [self stopCountDown];

        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startOrStopModel:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
        
        controlCounter++;
        openOrCloseAC = YES;
    }
    
    if(!acOpened && [self isOpenAcOrApByIntelligenceModel])
    {
        [AlertBox showWithMessage:@"您的设备正处于智能控制中，点击确定将开启手动控制，同时关闭智能控制。" delegate:(id)self showCancel:YES withTag:1000];
    }
    else
    {
        acOpened = !acOpened;
        
        if(acOpened)
        {
            curPurgeModel.onOff = IRDeviceOpen;
        }
        else
        {
            isLimitTime = NO;
            curPurgeModel.onOff = IRDeviceClose;
        }
        
        if(cancleButton != nil && isSetTimeModel)
        {
            [self setTimeControl:cancleButton];
        }
        
        
        [self onOffBtnHighligthImage];
        if(MainDelegate.isCustomer)
        {
            [self uploadAcModel:NO];
            
        }
        else
        {
            [self prepareSendAcIRCode:acOpened];
        }
        
        [self reloadTableView];
    }
}

- (BOOL)isOpenAcOrApByIntelligenceModel
{
    if(!MainDelegate.isCustomer)
    {
        if(![MainDelegate isNetworkAvailable])
        {
            return NO;
        }
    }
    // 智能控制
    if([beforePurgeModel.modeIndex integerValue] == 4)
    {
        return ([beforePurgeModel.acflag boolValue] || [beforePurgeModel.apflag boolValue]);
    }
    else if([beforePurgeModel.modeIndex integerValue] == 5)
    {
        return YES;
    }
    return false;
}


- (void)timeLimit:(UIButton *)sender
{
    DDLogFunction();
    if(!acOpened)return;
    openOrCloseAC = NO;
    
    isLimitTime = NO;
    sender.hidden = YES;
    
    [self stopCountDown];
    
    if(!MainDelegate.isCustomer)
    {
        if(![MainDelegate isNetworkAvailable])return;
    }
    
    NewTimingCell *cell = (NewTimingCell *)[acTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if(isLimitTime)
    {
        curPurgeModel.time = @"01:00";
        countDownSecond = 60 * 60;
        /*6.17
        [self countDownAnimationStart:cell];
         */
    }
    else
    {
        curPurgeModel.time = @"00:00";
        countDownSecond = 0;
        /*6.17
        [self countDownAnimationStop:cell];
         */
    }
    cell.lblContent.text = curPurgeModel.time;
    /* 6.17
    cell.limitBtn.selected = isLimitTime;
     */
    
    [self uploadAcModel:NO];
}

- (void)acModelControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
        
        if(!acOpened)return;
        openOrCloseAC = NO;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    AirAdjustCell *cell = (AirAdjustCell *)[acTableView cellForRowAtIndexPath:indexPath];
    NSInteger index = 0;
    if([curPurgeModel.acModelList containsObject:cell.lblContent.text])
    {
        index = [curPurgeModel.acModelList indexOfObject:cell.lblContent.text];
    }
    if(sender.tag == 0)
    {
        index--;
        if(index < 0)
        {
            index = curPurgeModel.acModelList.count - 1;
        }
    }
    else
    {
        index++;
        if(index >= curPurgeModel.acModelList.count)
        {
            index = 0;
        }
    }
    
    curPurgeModel.acMode = curPurgeModel.acModelList[index];
    NSString *img = [curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]]?CoolImg:HotImg;
    cell.cellIcon.image = [UIImage imageNamed:img];
    cell.lblContent.text = curPurgeModel.acMode;
    if(MainDelegate.isCustomer)
    {
        [self uploadAcModel:NO];
    }
    else
    {
        [self prepareSendAcIRCode:acOpened];
    }
}

- (void)tempControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
        
        if(!acOpened)return;
        controlCounter++;
        openOrCloseAC = NO;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    AirAdjustCell *cell = (AirAdjustCell *)[acTableView cellForRowAtIndexPath:indexPath];
    NSInteger index = 0;
    if([curPurgeModel.tempList containsObject:cell.lblContent.text])
    {
        index = [curPurgeModel.tempList indexOfObject:cell.lblContent.text];
    }
    if(sender.tag == 0)
    {
        index--;
    }
    else
    {
        index++;
    }
    
    if(index >= 0 && index < curPurgeModel.tempList.count)
    {
        curPurgeModel.temperature = curPurgeModel.tempList[index];
        cell.lblContent.text = curPurgeModel.temperature;
        if(MainDelegate.isCustomer)
        {
            [self uploadAcModel:NO];
        }
        else
        {
            [self prepareSendAcIRCode:acOpened];
        }
    }
}

- (void)windSpeedControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
        
        if(!acOpened)return;
        controlCounter++;
        openOrCloseAC = NO;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    AirAdjustCell *cell = (AirAdjustCell *)[acTableView cellForRowAtIndexPath:indexPath];
    NSInteger index = 0;
    if([curPurgeModel.windSpeedList containsObject:cell.lblContent.text])
    {
        index = [curPurgeModel.windSpeedList indexOfObject:cell.lblContent.text];
    }
    if(sender.tag == 0)
    {
        index--;
        if(index < 0)
        {
            index = curPurgeModel.windSpeedList.count -1;
        }
    }
    else
    {
        index++;
        if(index >= curPurgeModel.windSpeedList.count)
        {
            index = 0;
        }
    }
    
    curPurgeModel.windSpeed = curPurgeModel.windSpeedList[index];
    cell.lblContent.text = curPurgeModel.windSpeed;
    if(MainDelegate.isCustomer)
    {
        [self uploadAcModel:NO];
    }
    else
    {
        [self prepareSendAcIRCode:acOpened];
    }
}

- (void)apControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAP])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAP];
            return;
        }
    }
    
    if(!apOpened && [self isOpenAcOrApByIntelligenceModel])
    {
        [AlertBox showWithMessage:@"您的设备正处于智能控制中，点击确定将开启手动控制，同时关闭智能控制。" delegate:(id)self showCancel:YES withTag:2000];
    }
    else
    {
        apOpened = !apOpened;
        
        if(apOpened)
        {
            curPurgeModel.apOnOff = IRDeviceOpen;
        }
        else
        {
            curPurgeModel.apOnOff = IRDeviceClose;
        }
        
        openOrCloseAC = NO;
        
        if(MainDelegate.isCustomer)
        {
            [self uploadAcModel:NO];
        }
        else
        {
            [self prepareSendApIRCode];
        }
        
        [self apOnOffBtnHighligthImage];
    }
}

- (void)healthyControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
    }
    
    if(!acOpened)return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
    AirAdjustCell *cell = (AirAdjustCell *)[acTableView cellForRowAtIndexPath:indexPath];
    NSInteger index = 0;
    if([curPurgeModel.healthyStateList containsObject:cell.lblContent.text])
    {
        index = [curPurgeModel.healthyStateList indexOfObject:cell.lblContent.text];
    }
    if(sender.tag == 0)
    {
        index--;
        if(index < 0)
        {
            index = curPurgeModel.healthyStateList.count -1;
        }
    }
    else
    {
        index++;
        if(index >= curPurgeModel.healthyStateList.count)
        {
            index = 0;
        }
    }
    
    curPurgeModel.healthyState = (index == 0) ? @"on" : @"off";
    cell.lblContent.text = curPurgeModel.healthyStateList[index];
    
    if(MainDelegate.isCustomer)
    {
        [self uploadAcModel:NO];
    }
    else
    {
        [self prepareSendAcIRCode:acOpened];
    }
}

- (IBAction)irStudy:(UIButton *)sender
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"AirConditionViewController")];
        
        return;
    }
    
    sender.enabled = NO;
    
    CustomModelViewController *irStudy = [[CustomModelViewController alloc] initWithNibName:@"CustomModelViewController" bundle:nil];
    irStudy.macID = self.curDevice.mac;
    irStudy.view.frame = self.parentViewController.view.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MainDelegate.window addSubview:irStudy.view];
        irStudy.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            irStudy.view.alpha = 1.0;
            [self addChildViewController:irStudy];
            sender.enabled = YES;
        }];
    });
}

- (void)setTimeControl:(UIButton *)sender
{
    DDLogFunction();
    openOrCloseAC = NO;
    isSetTimeModel = NO;

    if(!MainDelegate.isCustomer)
    {
        if(![MainDelegate isNetworkAvailable])return;
    }
    
    if(sender.tag == 0)
    {
        isLimitTime = YES;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    SetTimeCell *cell = (SetTimeCell *)[acTableView cellForRowAtIndexPath:indexPath];
    countDownSecond = cell.datePicker.countDownDuration;
    
    if(countDownSecond > 0)
    {
        if(sender.tag == 0 && acOpened)
        {
            [self limitTime];
            [self uploadAcModel:NO];
        }
        
        if(!acOpened)
        {
            countDownSecond = 0;
            [self limitTime];
        }
    }
    else
    {
        [self limitTime];
        isLimitTime = NO;
        
        if(sender.tag == 0 && acOpened)
        {
            [self uploadAcModel:NO];
        }

    }
    
    if(!isSetTimeModel)
    {
        [self reloadSection:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - Set Cell

- (void)setAirAdjustCell:(AirAdjustCell *)cell withIndex:(NSInteger)row
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.leftBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.rightBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        
        [cell.rightBtn setExclusiveTouch:YES];
        [cell.leftBtn setExclusiveTouch:YES];
        if(row == 0)
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.cellIcon.image = [UIImage imageNamed:@"02-室内温度.png"];
            cell.lblContent.text = curPurgeModel.temperature;
            
            cell.leftBtn.hidden = NO;
            cell.rightBtn.hidden = NO;
            
            [cell.leftBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(row == 1)
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
            
            NSString *img = [curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]]?CoolImg:HotImg;
            cell.cellIcon.image = [UIImage imageNamed:img];
            cell.lblContent.text = curPurgeModel.acMode;
            cell.leftBtn.hidden = NO;
            cell.rightBtn.hidden = NO;
            
            [cell.leftBtn addTarget:self action:@selector(acModelControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(acModelControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(row == 2)
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.cellIcon.image = [UIImage imageNamed:@"03-风速.png"];
            cell.lblContent.text = curPurgeModel.windSpeed;
            if ([MainDelegate isLanguageEnglish]) {
                cell.lblContent.font=[cell.lblContent.font fontWithSize:14];
            }
            cell.leftBtn.hidden = NO;
            cell.rightBtn.hidden = NO;
            
            [cell.leftBtn addTarget:self action:@selector(windSpeedControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(windSpeedControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(row == 3)
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
            cell.cellIcon.image = [UIImage imageNamed:@"05-健康.png"];
            cell.lblContent.text = [curPurgeModel.healthyState isEqualToString:@"on"] ? curPurgeModel.healthyStateList[0] : curPurgeModel.healthyStateList[1];
            cell.leftBtn.hidden = NO;
            cell.rightBtn.hidden = NO;

            [cell.leftBtn addTarget:self action:@selector(healthyControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(healthyControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.cellIcon.alpha = acOpened ? 1.0 : 0.3;
        cell.lblContent.alpha = acOpened ? 1.0 : 0.3;
        cell.leftBtn.alpha = acOpened ? 1.0 : 0.3;
        cell.rightBtn.alpha = acOpened ? 1.0 : 0.3;
        
        cell.cellIcon.userInteractionEnabled = acOpened ? YES : NO;
        cell.lblContent.userInteractionEnabled = acOpened ? YES : NO;
        cell.leftBtn.userInteractionEnabled = acOpened ? YES : NO;
        cell.rightBtn.userInteractionEnabled = acOpened ? YES : NO;

    });
}


#pragma mark -
#pragma mark Table view data source

#define HeaderColor [UIColor colorWithRed:240/255.0 green:239/255.0 blue:230/255.0 alpha:1.0]

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else if (section == 1)
    {
        return haveHealthyState ? 4 : 3;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && isSetTimeModel)
    {
        return 162;
    }
    else if(indexPath.section == 0 && !isSetTimeModel)
    {
        return [UIDevice isRunningOn4Inch] ? 75 : 60;
    }
    else if(indexPath.section == 1)
    {
        return [UIDevice isRunningOn4Inch] ? 80 : 60;
    }
    else
    {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(isSetTimeModel)
        {
            static NSString *identifier = @"SetTimeCell";
            SetTimeCell *cell = (SetTimeCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if(cell == nil)
            {
                cell = [[SetTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
            cell.countDownDuration = countDownSecond;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.okBtn addTarget:self action:@selector(setTimeControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.cancelBtn addTarget:self action:@selector(setTimeControl:) forControlEvents:UIControlEventTouchUpInside];
            
            cancleButton = cell.cancelBtn;
            
            [cell.cancelBtn setExclusiveTouch:YES];
            [cell.okBtn setExclusiveTouch:YES];
            return cell;
        }
        else
        {
            static NSString *identifier = @"NewTimingCell";
            NewTimingCell *cell = (NewTimingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if(cell == nil)
            {
                NSString *nibName = [UIDevice isRunningOn4Inch] ? @"NewTimingCell" : @"NewTimingCell_35";
                UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:identifier];
                cell = (NewTimingCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.lblContent addGestureRecognizer:tapTimeGesture];
                cell.rightBtn.hidden = isLimitTime ? NO : YES;
                [cell.rightBtn addTarget:self action:@selector(timeLimit:) forControlEvents:UIControlEventTouchUpInside];
                cell.lblContent.text = curPurgeModel.time;
                [cell.rightBtn setExclusiveTouch:YES];
                
                if(isLimitTime)
                {
                    [self startCountDown];
                }
                else
                {
                    [self stopCountDown];
                }
                if(MainDelegate.isCustomer)
                {
                    cell.lblContent.alpha = acOpened ? 1.0 : 0.3;
                    cell.iconImg.alpha = acOpened ? 1.0 : 0.3;
                    cell.lblTitle.alpha = acOpened ? 1.0 : 0.3;
                    cell.lblContent.userInteractionEnabled = acOpened ? YES : NO;
                }
                else
                {
                    if(![MainDelegate isNetworkAvailable])
                    {
                        cell.lblContent.alpha = 0.3;
                        cell.iconImg.alpha = 0.3;
                        cell.lblTitle.alpha = 0.3;
                        cell.lblContent.userInteractionEnabled = NO;
                    }
                    else
                    {
                        cell.lblContent.alpha = acOpened ? 1.0 : 0.3;
                        cell.iconImg.alpha = acOpened ? 1.0 : 0.3;
                        cell.lblTitle.alpha = acOpened ? 1.0 : 0.3;
                        cell.lblContent.userInteractionEnabled = acOpened ? YES : NO;
                    }
                }
            });
            
            return cell;
        }
    }
    else if(indexPath.section == 1)
    {
        static NSString *identifier = @"AirAdjustCell";
        AirAdjustCell *cell = (AirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil)
        {
            NSString *nibName = [UIDevice isRunningOn4Inch] ? @"AirAdjustCell" : @"AirAdjustCell_35";
            UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:identifier];
            cell = (AirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setAirAdjustCell:cell withIndex:indexPath.row];
        return cell;
    }
    else
    {
        static NSString *identifier = @"ApAdjustCell";
        ApAdjustCell *cell = (ApAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell == nil)
        {
            //NSString *nibName = [UIDevice isRunningOn4Inch] ? @"AirAdjustCell" : @"AirAdjustCell_35";
            UINib *nib = [UINib nibWithNibName:@"ApAdjustCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:identifier];
            cell = (ApAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.subBg.backgroundColor = [UIColor colorWithRed:apOpened ? 71.0/255.0 : 158.0/255.0
                                                     green:apOpened ? 189.0/255.0 : 158.0/255.0
                                                      blue:apOpened ? 60.0/255.0 : 158.0/255.0
                                                     alpha:1.0];
        [cell.onOffBtn addTarget:self action:@selector(apControl:) forControlEvents:UIControlEventTouchUpInside];
        NSString *imgName = apOpened ? @"08-开.png" : @"08-关.png";
        [cell.onOffBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        
        [cell.onOffBtn setExclusiveTouch:YES];
        
        return cell;
    }
}

#pragma mark - Alert Box Delegate

- (void)alertBoxOkButtonOnClicked:(AlertBoxViewController *)alertBoxViewController
{
    NSInteger tag = alertBoxViewController.tag;
    if(tag == 1000)
    {
        acOpened = !acOpened;
        
        if(acOpened)
        {
            curPurgeModel.onOff = IRDeviceOpen;
        }
        else
        {
            isLimitTime = NO;
            curPurgeModel.onOff = IRDeviceClose;
        }
        
        if(cancleButton != nil && isSetTimeModel)
        {
            [self setTimeControl:cancleButton];
        }
        
        
        if(MainDelegate.isCustomer)
        {
            [self uploadAcModel:NO];
            
        }
        else
        {
            [self prepareSendAcIRCode:acOpened];
        }
        
        [self onOffBtnHighligthImage];
        [self reloadTableView];
    }
    else if(tag == 2000)
    {
        apOpened = !apOpened;
        
        if(apOpened)
        {
            curPurgeModel.apOnOff = IRDeviceOpen;
        }
        else
        {
            curPurgeModel.apOnOff = IRDeviceClose;
        }
        
        openOrCloseAC = NO;
        
        if(MainDelegate.isCustomer)
        {
            [self uploadAcModel:NO];
        }
        else
        {
            [self prepareSendApIRCode];
        }
        
        [self apOnOffBtnHighligthImage];
        [self reloadTableView];
    }
    else
    {
        [self acPageDone:nil];
    }
}

- (void)retryBoxOkButtonOnClicked
{
    if(controlCounter == 0)
    {
        [self prepareSendAcIRCode:acOpened];
    }
}

- (void)retryBoxCancelButtonOnClicked
{
}

@end
