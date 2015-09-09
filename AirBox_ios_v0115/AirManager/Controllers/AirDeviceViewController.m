//
//  AirDeviceViewController.m
//  AirManager
//

#import "AirDeviceViewController.h"
#import "AirDeivceManageViewController.h"
#import "AirConditionViewController.h"
#import "IRDeviceModelSelectionViewController.h"
#import "IRDeviceManager.h"
#import "AirDevice.h"
#import "AirQuality.h"
#import "IRDevice.h"
#import "IRDeviceManager.h"
#import "AirDeviceManager.h"
#import "AirQualityHistoryViewController.h"
#import "UIDevice+Resolutions.h"
#import <uSDKFramework/uSDKDevice.h>
#import "AppDelegate.h"
#import "SDKRequestManager.h"
//#import "AlertBox.h"
#import "UserLoginedInfo.h"
#import "AirBoxStatus.h"
#import "CustomModelViewController.h"
#import "AirPurgeModel.h"
#import "NewHistoryViewController.h"
#import "GenerateRandom.h"
#import "IntelligenceVCViewController.h"
#import "CityDataHelper.h"

@interface AirDeviceViewController (){
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblMood;
    IBOutlet UILabel *lblMoodMessage;
    IBOutlet UILabel *lblTemperature;
    IBOutlet UILabel *lblPM;
    IBOutlet UILabel *lblHumidity;
    IBOutlet UIActivityIndicatorView *connectWaitView;
    IBOutlet UILabel *connectWaitTitle;
    IBOutlet UIImageView *airBoxIcon;
    IBOutlet UILabel *lblMoodHint;
    
    __weak IBOutlet UILabel *wenduDanweiLabel;
    __weak IBOutlet UILabel *shiduHintLabel;
    __weak IBOutlet UIImageView *backgroupImageView;
    
    __weak IBOutlet UILabel *shiduDanweiLabel;
    __weak IBOutlet UILabel *lblVOC;
    NSString *imageBackupImage;
    
    __weak IBOutlet UIView *pm25Color;

    NSTimer *waitTimerCase1;
    NSInteger waitTimeCase1;
    
    BOOL isLogOut;
    BOOL isNetworkConnenctLocal;
}


@end

@implementation AirDeviceViewController

@synthesize curDevice;
@synthesize arrBindedIRDevice;
@synthesize curDeviceAirQuality;
/* 05.22
@synthesize blackModelAnimation;
 */

- (void)dealloc
{
    if([waitTimerCase1 isValid])
    {
        [waitTimerCase1 invalidate];
    }
    
    waitTimerCase1 = nil;
    
    DDLogFunction();
   
    [self removeObserver];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.arrBindedIRDevice = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[pm25Color layer] setBorderColor:[UIColor colorWithHex:0xffffff alpha:0.2f].CGColor];
    [[pm25Color layer] setBorderWidth:1];
    [[pm25Color layer] setCornerRadius:2];
    
    self.curDeviceAirQuality = [[AirQuality alloc] init];
    
    [self registerObserver];
    
    isNetworkConnenctLocal =YES;
    
    isLogOut = NO;
    
    if(MainDelegate.isCustomer)
    {
        AirQuality *quality = [[AirQuality alloc] init];
        quality.temperature = CUSTEMER_TEMP;
        quality.humidity = @478;
        quality.pm25 = @"26";
        quality.voc = @1;
        quality.mark = @80;
        
        curDevice = [[AirDevice alloc] init];
        curDevice.name = NSLocalizedString(@"盒子总部",@"AirDeviceViewController.m");
        
        curDevice.userAirMode = [[AirPurgeModel alloc] init];
        curDevice.city = @"101010100";
        
        self.curDeviceAirQuality = quality;
        
        [self loadAirDeviceInfo:quality];
    }
    else
    {
        [self currentAirDeviceInfo];
//        [self downloadIrDevice];
        [self doWithCacheData];
        [self downloadIRDeviceBindOnAirDeviceAndCheckIRCode];
    }
    [Utility setExclusiveTouchAll:self.view];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Download Air Device Info

- (BOOL)isIntellgentMode
{
    if(MainDelegate.isCustomer)
    {
        if([curDevice.userAirMode.modeIndex integerValue] == 4 ||
        [curDevice.userAirMode.modeIndex integerValue] == 5)
        {
             return YES;
        }
        return  NO;
        
    }
    else
    {
        if([curDevice.userAirMode.modeIndex integerValue] == 4 )
        {
            if(([curDevice.userAirMode.acflag boolValue] && [Utility isBindedDevice:self.arrBindedIRDevice withType:kDeviceTypeAC]) ||
               ([curDevice.userAirMode.apflag boolValue] && [Utility isBindedDevice:self.arrBindedIRDevice withType:kDeviceTypeAP]))
            {
                return YES;
            }
        }
        else if([curDevice.userAirMode.modeIndex integerValue] == 5)
        {
            if([Utility isBindedDevice:self.arrBindedIRDevice withType:kDeviceTypeAC])
            {
                return YES;
            }
        }
        
        return NO;
    }
}
- (void)downloadAirBoxModel
{
    if(MainDelegate.isCustomer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *result = [UserDefault objectForKey:kNoAccountUserAirMode];
            if(result)
            {
                [curDevice.userAirMode parserAirModel:result];
                
                [(AirDeivceManageViewController *)self.parentViewController addModelAnimation];
            }
        });
        return;
    }
    
    if(![MainDelegate isNetworkAvailable])return;
    
    //[MainDelegate showProgressHubInView:self.view];
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_DOWN_DEV_MODEL(curDevice.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         //[MainDelegate hiddenProgressHubInView:self.view];
         if(!error)
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->下载用户空气盒子模式信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 if(isObject(result[@"userAirMode"]))
                 {
                     [curDevice.userAirMode parserAirModel:result[@"userAirMode"]];
                     
                     [(AirDeivceManageViewController *)self.parentViewController addModelAnimation];
                 }
            }
         }
     }];
}

- (void)downloadIRDeviceBindOnAirDeviceAndCheckIRCode
{
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [irDeviceManager loadIRDeviceBindOnAirDevice:curDevice.mac
                               completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC)
     {
         if(isLoadSucceed)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.arrBindedIRDevice = array;
                 [(AirDeivceManageViewController *)self.parentViewController addModelAnimation];
                 // 获取IRCode
                 if(self.arrBindedIRDevice.count > 0)
                 {
                     [self checkIRCodeForCache];
                 }
             });
         }
     }];
}
- (void)downloadIRDeviceBindOnAirDevice
{
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [irDeviceManager loadIRDeviceBindOnAirDevice:curDevice.mac
                               completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC)
     {
         if(isLoadSucceed)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.arrBindedIRDevice = array;
                 [(AirDeivceManageViewController *)self.parentViewController addModelAnimation];
                 
             });
         }
     }];
}

- (void)doIRDeviceChanged:(NSNotification *)notification
{
    NSString *mac = notification.object;
    if([mac isEqualToString:curDevice.mac])
    {
        [self downloadIRDeviceBindOnAirDevice];
    }
}

- (void)pM25ChangeStatus:(NSNotification *)notification
{
    DDLogCVerbose(@"pM25ChangeStatus  空气质量得分:%@  PM2.5:%@ ",[curDeviceAirQuality.mark stringValue],lblPM.text);
    
    lblMoodMessage.text = [self moodeMessageTitle:[curDeviceAirQuality.mark stringValue] withPM25:lblPM.text];
}

- (void)changeAirBoxName
{
    AirDevice *deviceTmp = [self getAirDevice];
    if(deviceTmp)
    {
        curDevice = deviceTmp;
    }
    lblDeviceName.text =  curDevice.name;
}

- (AirDevice*) getAirDevice
{
    for (int i = 0; i < [MainDelegate.loginedInfo.arrUserBindedDevice count]; i++)
    {
        AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
        if([curDevice.mac isEqualToString:device.mac])
        {
            return device;
        }
    }
    return nil;
}

- (void)checkAirBoxConnectStatus
{
    if([[SDKRequestManager sharedInstance] isWaitConnect:curDevice.mac])
    {
        [self showConnectWaitView:NO];
    }
    else
    {
        [self hiddenConnectWaitView];
    }
}

- (void)currentAirDeviceInfo
{
    [self checkAirBoxConnectStatus];
    [self downloadAirDeviceInfo];
    /**
    if(curDeviceAirQuality == nil)
    {
        [self downloadAirDeviceInfo];
    }
    else
    {
        [self loadDeviceStatus];
        [self loadAirDeviceInfo:curDeviceAirQuality];
    }
     **/
}

- (void)downloadAirDeviceInfo
{
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    DDLogCVerbose(@"各个空气盒子信息=%@",curDevice);//ybyao07-2011-11-11
    [airDeviceManager loadAirDeviceData:curDevice completionHandler:^(AirQuality *quality,BOOL isSucceed)
    {
        if(isSucceed)
        {
            self.curDeviceAirQuality = quality;
//            if (!quality)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadDeviceStatus];
                    [self loadAirDeviceInfo:quality];
                });//ybyao07-20141112
            }
        }
        
    }];
}

#pragma mark - Tap Air Adujust Button

- (void)airDeviceDone
{
     DDLogFunction();
    [self removeObserver];
    [self removeFromParentViewController];
}

- (IBAction)openAirTrendPage:(id)sender
{
    if(MainDelegate.isCustomer)
    {
    }
    else
    {
        if(![MainDelegate isNetworkAvailable])return;
    }
    
    
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    DDLogCVerbose(@"各个空气盒子信息=%@",curDevice);//ybyao07-2011-11-11
    [airDeviceManager loadAirDeviceData:curDevice completionHandler:^(AirQuality *quality,BOOL isSucceed)
     {
         if(isSucceed)
         {
             curDeviceAirQuality.rank = quality.rank;
         }
         
         NSString *newName = nil;
         
         if([UIDevice isRunningOn4Inch])
         {
             if (IOS7)
             {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                 newName = @"NewHistoryViewController";
#else
                 newName = @"NewHistoryViewController_2";
#endif
             }
             else
             {
                 newName = @"NewHistoryViewController_2";
             }
         }
         else
         {
             if (IOS7)
             {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
                 newName = @"NewHistoryViewController_35";
#else
                 newName = @"NewHistoryViewController_35_2";
#endif
             }
             else
             {
                 newName = @"NewHistoryViewController_35_2";
             }
         }
         NewHistoryViewController *newHistory = [[NewHistoryViewController alloc] initWithNibName:newName bundle:nil];
         newHistory.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
         newHistory.airDevice = curDevice;
         newHistory.rankValue = curDeviceAirQuality.rank;
         [self presentViewController:newHistory animated:YES completion:nil];
         return;
         
     }];
    
    
    
    /* 6.17
    NSString *name = ([UIDevice isRunningOn4Inch]?@"AirQualityHistoryViewController":@"AirQualityHistoryViewController_35");
    AirQualityHistoryViewController *history = [[AirQualityHistoryViewController alloc] initWithNibName:name bundle:nil];
    history.airDevice = curDevice;
    history.view.frame = [self parentViewController].view.frame;;
    history.view.alpha = 0.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            history.view.alpha = 1.0;
             [MainDelegate.window addSubview:history.view];
            [self addChildViewController:history];
         }];
    });
     */
}

- (void)checkIRCode
{
    __block int counter = 0;
    int irDeviceCount = [arrBindedIRDevice count];
    for (int i = 0; i < irDeviceCount; i++)
    {
        IRDevice *irDevice = arrBindedIRDevice[i];
        IRDeviceManager *deviceManager = [[IRDeviceManager alloc] init];
        [deviceManager setCompletionHandler:^(BOOL isSucceed)
         {
             counter++;
             if(counter == irDeviceCount)
             {
                 //已经check完所有红外设备的红外编码
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self openACoperatePage:nil];
                    [MainDelegate hiddenProgressHubInView:self.view];
                });
             }
         }];
        [deviceManager checkIRDevice:irDevice onAirDevice:curDevice];
    }
}

- (void)checkIRCodeForCache
{
    __block int counter = 0;
    int irDeviceCount = [arrBindedIRDevice count];
    for (int i = 0; i < irDeviceCount; i++)
    {
        IRDevice *irDevice = arrBindedIRDevice[i];
        IRDeviceManager *deviceManager = [[IRDeviceManager alloc] init];
        [deviceManager setCompletionHandler:^(BOOL isSucceed)
         {
             counter++;
             if(counter == irDeviceCount)
             {
             }
         }];
        [deviceManager checkIRDevice:irDevice onAirDevice:curDevice];
    }
}


#pragma mark - Update UI


- (void)loadDeviceStatus
{
    DDLogCVerbose(@"%@",MainDelegate.allAirBoxStatus);
    DDLogCVerbose(@"Mac:%@ Name:%@",curDevice.mac,curDevice.name);
    AirBoxStatus *status = MainDelegate.allAirBoxStatus[curDevice.mac];
    if(status)
    {
        curDeviceAirQuality.temperature = status.temperature;
        curDeviceAirQuality.humidity = status.humidity;
        curDeviceAirQuality.pm25 = status.pm25;
        curDeviceAirQuality.voc = [NSNumber numberWithInteger:[[status.voc stringByReplacingOccurrencesOfString:@"30w00" withString:@""] integerValue]];
        // 记录盒子的音量
        if(status.voiceVaule.length > 0)
        {
            curDevice.voiceValue = status.voiceVaule ;
        }
        int mood = [status.moodPoint intValue];
        if(mood < 0)
        {
            // mood = -1 表示失败了，不刷新界面
        }
        else if(mood >=0 && mood <= 100)
        {
            curDeviceAirQuality.mark = [NSNumber numberWithInt:mood];
        }
        if(mood > 100)
        {
            curDeviceAirQuality.mark = [NSNumber numberWithInt:100];
        }
    }
}

- (void)loadAirDeviceInfo:(AirQuality *)info
{
    DDLogFunction();
    DDLogCVerbose(@"更新小A状态值到UI %@",@"--->");
    int moodTag = [MainDelegate moodValueConvert:[info.mark intValue]];
    NSString *name = [NSString stringWithFormat:@"mood_icon_%d.png",moodTag];
    DDLogCVerbose(@"info.mark  %@  moodtag  %d    name %@",info.mark,moodTag,name);
    
    if(info.pm25)
    {
        NSString * indoorPm25=[Utility coventPM25StatusForAirManagerIndoor:info.pm25 withMac:curDevice.mac];
        DDLogCVerbose(@"randomPm25%@",indoorPm25);
        
        lblPM.text = [NSString stringWithFormat:@"%@",indoorPm25];
    }
    else
    {
        lblPM.text = @"--";
    }
    //ybyao07-20141114
    //    [pm25Color setBackgroundColor:[UIColor colorWithHex:[Utility getPM25Color:info.pm25] alpha:1.0f]];
    [pm25Color setBackgroundColor:[UIColor colorWithHex:[Utility getPM25Color:lblPM.text] alpha:1.0f]];
    
    
    if(info.mark)
    {
        airBoxIcon.image = [UIImage imageNamed:name];
        
        DDLogCVerbose(@"__mark:%@___name :%@   icon  %@",info.mark,name,airBoxIcon);
        lblMood.text = [self moodeSubTitle:[info.mark stringValue]];
        if ([MainDelegate isLanguageEnglish]) {
            lblMoodHint.text = [NSString stringWithFormat:@"Air quality %@ points",[info.mark stringValue]];
        }else{
            lblMoodHint.text = [NSString stringWithFormat:@"空气质量%@分",[info.mark stringValue]];
        }
         lblMoodMessage.text = [self moodeMessageTitle:[info.mark stringValue] withPM25:lblPM.text];
    }
    else
    {
        if ([MainDelegate isLanguageEnglish]) {
            lblMoodHint.text = @"Air quality -- points";
        }else{
            lblMoodHint.text = @"空气质量--分";
        }
        if ([MainDelegate isLanguageEnglish]) {
            lblMoodMessage.text = @"Air Quality: --";
            
        }else{
            lblMoodMessage.text = @"室内空气--";
        }
        lblMood.text = @"--";
    }
    
    lblDeviceName.text = curDevice.name;
    if(imageBackupImage != nil)
    {
        backgroupImageView.image = [UIImage imageNamed:imageBackupImage];
    }
    
    if(info.temperature)
    {
        if([info.temperature intValue] == 0)
        {
            lblTemperature.text = @"--";
        }
        else
        {
            lblTemperature.text = [NSString stringWithFormat:@"%d",[MainDelegate countTempVlue:info.temperature
                                                                                      hardWare:curDevice.baseboard_software
                                                                                        typeID:curDevice.type]];
        }
    }
    else
    {
        lblTemperature.text = @"--";
    }

    if(info.humidity)
    {
        if([info.humidity intValue] == 0)
        {
            lblHumidity.text = @"--";
        }
        else
        {
            int value = [MainDelegate countHumValue:info.humidity
                                           withTemp:info.temperature
                                           hardWare:curDevice.baseboard_software
                                             typeID:curDevice.type];
            NSString *humValue = [NSString stringWithFormat:@"%d",value];
            
            lblHumidity.text = humValue;
        }
    }
    else
    {
        lblHumidity.text = @"--";
    }
    
    if(lblHumidity.text != nil && ![lblHumidity.text isEqualToString:@"--"])
    {
        
        CGSize mySize = [lblHumidity.text  sizeWithFont:lblHumidity.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:lblHumidity.lineBreakMode];
        mySize.width += 2;
        lblHumidity.frame = CGRectMake(shiduHintLabel.center.x - mySize.width / 2, lblHumidity.frame.origin.y, mySize.width, lblHumidity.frame.size.height);
        
        shiduDanweiLabel.hidden = NO;
        [shiduDanweiLabel setFrame:CGRectMake(shiduHintLabel.center.x + mySize.width / 2, shiduDanweiLabel.frame.origin.y, shiduDanweiLabel.frame.size.width, shiduDanweiLabel.frame.size.height)];
    }
    else
    {
        shiduDanweiLabel.hidden = YES; // by TreeJohn
    }
    
    if(lblTemperature.text != nil && ![lblTemperature.text isEqualToString:@"--"])
    {
        
        CGSize mySize = [lblTemperature.text  sizeWithFont:lblTemperature.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:lblTemperature.lineBreakMode];
        mySize.width += 2;
        lblTemperature.frame = CGRectMake(160 - mySize.width / 2, lblTemperature.frame.origin.y, mySize.width, lblTemperature.frame.size.height);
        
        wenduDanweiLabel.hidden = NO;
        [wenduDanweiLabel setFrame:CGRectMake(160 + mySize.width / 2, wenduDanweiLabel.frame.origin.y, wenduDanweiLabel.frame.size.width, wenduDanweiLabel.frame.size.height)];
    }
    else
    {
        wenduDanweiLabel.hidden = YES;
    }
    
    if(info.voc)
    {
        NSString *textVoc=[NSString stringWithFormat:@"30w00%@",info.voc];
        lblVOC.text = [NSString stringWithFormat:@"VOC:%@" ,[MainDelegate coventVOCStatus:textVoc]];
    }
    else
    {
        lblVOC.text = [NSString stringWithFormat:@"VOC:--"];
    }
}

- (void)showConnectWaitView:(BOOL)isManual
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(!isManual)
        {
            if(!btnRetryConnect.hidden)
            {
                connectWaitTitle.hidden = YES;
                if([connectWaitView isAnimating])
                {
                    [connectWaitView stopAnimating];
                }
            }
            else
            {
                connectWaitTitle.hidden = NO;
                if(![connectWaitView isAnimating])
                {
                    [connectWaitView startAnimating];
                }
            }
        }
        else
        {
            btnRetryConnect.hidden = YES;
            connectWaitTitle.hidden = NO;
            if(![connectWaitView isAnimating])
            {
                [connectWaitView startAnimating];
            }
        }
        
        [(AirDeivceManageViewController *)self.parentViewController refreshModelAnimation:NO withMac:curDevice.mac];
    });
}

- (void)showConnectRetryView
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        connectWaitTitle.hidden = YES;
        if([connectWaitView isAnimating])
        {
            [connectWaitView stopAnimating];
        }
        
        btnRetryConnect.hidden = NO;
        [self resetEmptyView];
        
        [(AirDeivceManageViewController *)self.parentViewController refreshModelAnimation:NO withMac:curDevice.mac];
    });

}

- (void)hiddenConnectWaitView
{
    dispatch_async(dispatch_get_main_queue(), ^{

        connectWaitTitle.hidden = YES;
        if([connectWaitView isAnimating])
        {
            [connectWaitView stopAnimating];
        }
        btnRetryConnect.hidden = YES;
        
        [(AirDeivceManageViewController *)self.parentViewController refreshModelAnimation:YES withMac:curDevice.mac];
    });
}

- (void)resetEmptyView
{
    AirQuality *quality = [[AirQuality alloc] init];
    quality.temperature = @0;
    quality.humidity = @0;
    quality.pm25 = nil;
    quality.voc = nil;
    quality.mark = nil;
    
    self.curDeviceAirQuality = quality;
    
    [self loadAirDeviceInfo:quality];
}
#pragma mark - Observer Management

- (void)registerObserver
{
    [NotificationCenter addObserver:self
                           selector:@selector(receiveSdkManagerNotification:)
                               name:SdkDeviceOnlineChangedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(receiveSdkManagerNotification:)
                               name:SdkDeviceStatusChangedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(changeAirBoxName)
                               name:ChangeAirBoxSucceedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(logOutAction)
                               name:AllAirDeviceRemovedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(logOutAction)
                               name:AllAirDeviceRemovedNotificationByDeleted
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(resumeAnimation)
                               name:ResumeAnimationsEnterForegroundNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(doIRDeviceChanged:)
                               name:IRDevicesChangedNotification
                             object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(pM25ChangeStatus:)
                               name:WeathePM25ChangeNotification
                             object:nil];
    
    
}

- (void)removeObserver
{
    [NotificationCenter removeObserver:self];
}


#pragma mark - Notification Handler

- (void)receiveSdkManagerNotification:(NSNotification *)notification
{
    DDLogFunction();
    DDLogCVerbose(@"小A主页面收到设备状态变化的通知 %@",@"--->");
    if([notification.name isEqualToString:SdkDeviceStatusChangedNotification])
    {
        NSString *mac = (NSString *)notification.userInfo;
        if([mac isEqualToString:curDevice.mac])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadDeviceStatus];
                [self loadAirDeviceInfo:curDeviceAirQuality];
            });
        }
    }
    else if([notification.name isEqualToString:SdkDeviceOnlineChangedNotification])
    {
        [self checkAirBoxConnectStatus];
    }
}


#pragma mark - Open new controller
- (IBAction)retryConnect:(UIButton *)sender
{
    DDLogFunction();
    [self startCheckWaitCountDownCase1];
}


- (void)openIntelligencePage:(void(^)())handler
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        IntelligenceVCViewController *airCondition = [[IntelligenceVCViewController alloc] initWithNibName:@"IntelligenceVCViewController" bundle:nil];
        airCondition.arrBindIRDevice = nil;
        [self.navigationController pushViewController:airCondition animated:YES];
        if(handler)
        {
            handler();
        }
    }
    else
    {
        IntelligenceVCViewController *airCondition = [[IntelligenceVCViewController alloc] initWithNibName:@"IntelligenceVCViewController" bundle:nil];
        airCondition.arrBindIRDevice = arrBindedIRDevice;
        [self.navigationController pushViewController:airCondition animated:YES];
        if(handler)
        {
            handler();
        }
    }
}

- (void)openACoperatePage:(void(^)())handler
{
    DDLogFunction();
    
    if(MainDelegate.isCustomer)
    {
        DDLogFunction();
        AirConditionViewController *airCondition = [[AirConditionViewController alloc] initWithNibName:@"AirConditionViewController" bundle:nil];
        airCondition.airQuality = nil;
        airCondition.arrBindIRDevice = nil;
        airCondition.curDevice = nil;
        [self.navigationController pushViewController:airCondition animated:YES];
        if(handler)
        {
            handler();
        }
    }
    else
    {
        DDLogFunction();
        AirConditionViewController *airCondition = [[AirConditionViewController alloc] initWithNibName:@"AirConditionViewController" bundle:nil];
        airCondition.airQuality = self.curDeviceAirQuality;
        airCondition.arrBindIRDevice = self.arrBindedIRDevice;
        airCondition.curDevice = self.curDevice;
        [self.navigationController pushViewController:airCondition animated:YES];
        if(handler)
        {
            handler();
        }
    }
}


- (void)logOutAction
{
    isLogOut = YES;
    [self stopWaitConnectCountDown];
}


- (void)resumeAnimation
{
    if(MainDelegate.isCustomer)
    {
        return;
    }
    // 刷新下面的两个按钮的状态
    [self startCheckWaitCountDownEnterForeground];
    [(AirDeivceManageViewController *)self.parentViewController addModelAnimation];
}




#pragma mark - 测试盒子的连接状态

- (void)startCheckWaitCountDownCase1
{
    DDLogFunction();
    [self stopWaitConnectCountDown];
    
    AirDeivceManageViewController *airDeivceManageViewController = (AirDeivceManageViewController *)self.parentViewController;
    if([[SDKRequestManager sharedInstance] isWaitConnect:self.curDevice.mac])
    {
        airDeivceManageViewController.intelligentBtn.enabled = NO;
        airDeivceManageViewController.airConditionBtn.enabled = NO;
        [self showConnectWaitView:YES];
        [self startWaitConnectCountDownCase1];
    }
    else
    {
        [self hiddenConnectWaitView];
        if([MainDelegate isNetworkAvailable])
        {
            airDeivceManageViewController.intelligentBtn.enabled = YES;
        }
        else
        {
            airDeivceManageViewController.intelligentBtn.enabled = NO;
        }
        airDeivceManageViewController.airConditionBtn.enabled = YES;
    }
}

- (void)startCheckWaitCountDownEnterForeground
{
    [self stopWaitConnectCountDown];
    
     AirDeivceManageViewController *airDeivceManageViewController = (AirDeivceManageViewController *)self.parentViewController;
    if([[SDKRequestManager sharedInstance] isWaitConnect:self.curDevice.mac])
    {
        airDeivceManageViewController.intelligentBtn.enabled = NO;
        airDeivceManageViewController.airConditionBtn.enabled = NO;
        [self startWaitConnectCountDownCase2];
        [self showConnectWaitView:YES];
    }
    else
    {
        [self hiddenConnectWaitView];
        if([MainDelegate isNetworkAvailable])
        {
            airDeivceManageViewController.intelligentBtn.enabled = YES;
        }
        else
        {
            airDeivceManageViewController.intelligentBtn.enabled = NO;
        }
        airDeivceManageViewController.airConditionBtn.enabled = YES;
    }
}

-(void)startWaitConnectCountDownCase1
{
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[self.curDevice.mac];
    if(device)
    {
        if(device.netType == NET_TYPE_REMOTE)
        {
            // 只有在线模式才需要测试网络状态
            if([MainDelegate isNetworkAvailable])
            {
                [self testNetworkAvailableForpPart];
            }
            [self startWaitConnectCountDownREMOTE];
        }
        else
        {
            [self startWaitConnectCountDownLOCAL];
        }
    }
}


- (void)testNetworkAvailableForpPart
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //        NSURL *URL=SERVER_GETPMRANGE;
        
        NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID],
                                  @"temperature":@"24",
                                  @"humidity":@"24",
                                  @"pm25":@"24",
                                  @"voc":@"24"};
        NSString *body = [MainDelegate createJsonString:dicBody];
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_COUNT_QUALITY(@"")
                                                         method:HTTP_POST
                                                           body:body];
        
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
        [request setTimeoutInterval:10];
        
        //        NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
        NSHTTPURLResponse *response;
        [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: nil];
        if (response == nil) {
            isNetworkConnenctLocal =  NO;
        }
        else{
            isNetworkConnenctLocal = YES;
        }
    });
}

-(void)startWaitConnectCountDownCase2
{
    waitTimeCase1 = 10;
    if([waitTimerCase1 isValid])
    {
        [self stopWaitConnectCountDown];
    }
    waitTimerCase1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownWaitTimeCase2) userInfo:nil repeats:YES];
}

- (void)startWaitConnectCountDownLOCAL
{
    // 盒子与app在同一个wifi下，
    waitTimeCase1 = 10;
    if([waitTimerCase1 isValid])
    {
        [self stopWaitConnectCountDown];
    }
    waitTimerCase1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownWaitTimeLOCAL) userInfo:nil repeats:YES];
}

- (void)startWaitConnectCountDownREMOTE
{
    // 盒子与app不在同一个wifi下，
    waitTimeCase1 = 30;
    if([waitTimerCase1 isValid])
    {
        [self stopWaitConnectCountDown];
    }
    waitTimerCase1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownWaitTimeREMOTE) userInfo:nil repeats:YES];
}

- (void)stopWaitConnectCountDown
{
    if([waitTimerCase1 isValid])
    {
        [waitTimerCase1 invalidate];
    }
    
    waitTimerCase1 = nil;
}

- (void)countDownWaitTimeLOCAL
{
    waitTimeCase1--;
    DDLogCVerbose(@"countDownWaitTimeLOCAL : %d",waitTimeCase1);
    if(waitTimeCase1 == 0)
    {
        [self stopWaitConnectCountDown];
        
        if([[SDKRequestManager sharedInstance] isWaitConnect:self.curDevice.mac] &&!isLogOut)
        {
            [self showConnectRetryView];
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                message:[NSString stringWithFormat: @"您的盒子“%@”与路由器连接出现了问题",self.curDevice.name]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定",@"SDKRequestManager.m")
                                                      otherButtonTitles:nil];
                
                [alert show];
                
//                [AlertBox showWithMessage:[NSString stringWithFormat: @"您的盒子“%@”与路由器连接出现了问题",self.curDevice.name]];
            }
        }
        else // 连接成功了
        {
            [self hiddenConnectWaitView];
            [(AirDeivceManageViewController *)self.parentViewController refreshModelAnimation:YES withMac:self.curDevice.mac];
        }
    }
}

- (void)countDownWaitTimeREMOTE
{
    waitTimeCase1--;
    DDLogCVerbose(@"countDownWaitTimeREMOTE : %d",waitTimeCase1);
    if(waitTimeCase1 == 0)
    {
        [self stopWaitConnectCountDown];
        
        if(!isNetworkConnenctLocal)
        {
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                message:[NSString stringWithFormat:@"您的盒子“%@”无法连接服务器",self.curDevice.name]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"确定",@"SDKRequestManager.m")
                                                      otherButtonTitles:nil];
                
                [alert show];

//                
//                [AlertBox showWithMessage:[NSString stringWithFormat:@"您的盒子“%@”无法连接服务器",self.curDevice.name]];
            }
            [self showConnectRetryView];
        }
        else
        {
            if([[SDKRequestManager sharedInstance] isWaitConnect:self.curDevice.mac] && !isLogOut)
            {
                [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                uSDKDeviceStatusConst  status = [[SDKRequestManager sharedInstance] getDeviceConnectStatus:self.curDevice.mac];
                
                
                NSString *message = [NSString stringWithFormat: @"连接失败,请确认您的盒子“%@”和路由器正常连接到互联网;可尝试重启空气盒子和路由器来解决此问题",self.curDevice.name];
                switch (status) {
                    case STATUS_UNAVAILABLE:
                    case STATUS_OFFLINE:
                        message = [NSString stringWithFormat: @"您的盒子“%@”所在的网络环境不稳定或盒子未接电",self.curDevice.name];
                        [self showConnectRetryView];
                        break;
                    case STATUS_ONLINE:
                        message = [NSString stringWithFormat: @"您的盒子“%@”数据获取失败，请点击重试",self.curDevice.name];
                        [self showConnectRetryView];
                        break;
                    default:
                        message =[NSString stringWithFormat: @"连接失败,请确认您的盒子“%@”和路由器正常连接到互联网;可尝试重启空气盒子和路由器来解决此问题",self.curDevice.name];
                        [self showConnectRetryView];
                        break;
                }
                if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
                {
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"确定",@"SDKRequestManager.m")
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
//                    [AlertBox showWithMessage:message];
                }
            }
            else // 连接成功了
            {
                [self hiddenConnectWaitView];
                [(AirDeivceManageViewController *)self.parentViewController refreshModelAnimation:YES withMac:self.curDevice.mac];
            }
        }
    }
}

- (void)countDownWaitTimeCase2
{
    waitTimeCase1--;
    DDLogCVerbose(@"countDownWaitTimeLOCAL : %d",waitTimeCase1);
    if(waitTimeCase1 == 0)
    {
        [self stopWaitConnectCountDown];
        
        if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            if(!isLogOut)
            {
                if([[SDKRequestManager sharedInstance] isWaitConnect:self.curDevice.mac])
                {
                    
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                    
//                    [AlertBox showWithMessage:[NSString stringWithFormat: @"您的盒子“%@”数据获取失败，请点击重试",self.curDevice.name]];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示信息",@"SDKRequestManager.m")
                                                                    message:[NSString stringWithFormat: @"您的盒子“%@”数据获取失败，请点击重试",self.curDevice.name]
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"确定",@"SDKRequestManager.m")
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    
                    [self showConnectRetryView];
                }
            }
        }
    }
}


#pragma mark - Open New Controller
#pragma mark - Prvate Methods

- (NSString *)pm25SubTitle:(NSString *)pm25
{
    DDLogFunction();
    if([pm25 isEqualToString:@"中"] || [pm25 isEqualToString:@"差"])
    {
        return NSLocalizedString(@"有污染",@"AirDeviceViewController.m");
    }
    else if([pm25 isEqualToString:@"优"] || [pm25 isEqualToString:@"良"])
    {
        return NSLocalizedString(@"正常",@"AirDeviceViewController.m");
    }
    else if([pm25 intValue] <= 70)
    {
        return NSLocalizedString(@"正常",@"AirDeviceViewController.m");
    }
    else if([pm25 intValue] > 70)
    {
        return NSLocalizedString(@"有污染",@"AirDeviceViewController.m");
    }
    return NSLocalizedString(@"正常",@"AirDeviceViewController.m");
}

- (NSString *)tempSubTitle:(NSString *)temp
{
    DDLogFunction();
    if([temp intValue] > 28)
    {
        return NSLocalizedString(@"炎热",@"AirDeviceViewController.m");
    }
    else if([temp intValue] >= 10 && [temp intValue] <= 28)
    {
        return NSLocalizedString(@"正常",@"AirDeviceViewController.m");
    }
    else if([temp intValue] < 10)
    {
        return NSLocalizedString(@"寒冷",@"AirDeviceViewController.m");
    }
    return NSLocalizedString(@"--",@"AirDeviceViewController.m");
}

- (NSString *)humSubTitle:(NSString *)hum
{
    DDLogFunction();
    DDLogCVerbose(@"----》%@",@"AirDeviceViewController.m");
    if([hum intValue] > 70)
    {
        return NSLocalizedString(@"潮湿",@"AirDeviceViewController.m");
    }
    else if([hum intValue] >= 30 && [hum intValue] <= 70)
    {
        return NSLocalizedString(@"正常",@"AirDeviceViewController.m");
    }
    else if([hum intValue] < 30)
    {
        return NSLocalizedString(@"干燥",@"AirDeviceViewController.m");
    }
    return @"--";
}


- (NSString *)moodeSubTitle:(NSString *)moode
{
    DDLogFunction();
    if([moode intValue] >= 90)
    {
        imageBackupImage = ([UIDevice isRunningOn4Inch]?@"DeviceBackgroup1.png":@"DeviceBackgroup1_35.png");
        return NSLocalizedString(@"优",@"AirDeviceViewController.m");
    }
    else if([moode intValue] >= 80 && [moode intValue] <= 89)
    {
        imageBackupImage = ([UIDevice isRunningOn4Inch]?@"DeviceBackgroup2.png":@"DeviceBackgroup2_35.png");
        return NSLocalizedString(@"良",@"AirDeviceViewController.m");
    }
    else if([moode intValue] >=60 && [moode intValue] <= 79)
    {
        imageBackupImage = ([UIDevice isRunningOn4Inch]?@"DeviceBackgroup3.png":@"DeviceBackgroup3_35.png");
        return NSLocalizedString(@"中",@"AirDeviceViewController.m");
    }
    else if([moode intValue] < 60)
    {
        imageBackupImage = ([UIDevice isRunningOn4Inch]?@"DeviceBackgroup4.png":@"DeviceBackgroup4_35.png");
        return NSLocalizedString(@"差",@"AirDeviceViewController.m");
    }
    return @"--";
}
- (NSString *)moodeMessageTitle:(NSString *)moode withPM25:(NSString *)pm25
{
    NSString *returnStr = @"--";
    DDLogFunction();
    
    if(!MainDelegate.isCustomer)
    {
        NSString *cityId = [CityDataHelper cityIDOfSelectedCity] != nil ? [CityDataHelper cityIDOfSelectedCity] : @"";

        if(cityId)
        {
            NSString *pm25OutDoor = [(AirDeivceManageViewController *)self.parentViewController pm25OutDoor];
            
            if([cityId isEqualToString:curDevice.city] &&
               (pm25 && pm25.length > 0 && ![pm25 isEqualToString:@"--"]) &&
               (pm25OutDoor && pm25OutDoor.length > 0 && ![pm25OutDoor isEqualToString:@"--"]))
            {
                NSUInteger pm25InDoorNum =  [pm25 integerValue];
                NSUInteger pm25OutDoorNum = [pm25OutDoor integerValue];
                
                if(pm25InDoorNum <= 35)
                {
                    if(pm25OutDoorNum <= 35)
                    {
                        returnStr = @"空气真好哇！点个赞，趁机出去活动吧~";
                    }
                    else if(pm25OutDoorNum > 35 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"室内空气挺好哇，室外一般般，少开窗吧";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"室内环境很赞，别出门当人工吸尘器了~";
                    }
                    
                }
                else if(pm25InDoorNum > 35 && pm25InDoorNum <= 75)
                {
                    if(pm25OutDoorNum <= 75)
                    {
                        returnStr = @"室内空气还不错，开窗换气要控制时间哦";
                    }
                    else if(pm25OutDoorNum > 75 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"空气质量一般般，加强戒备雾霾劲敌啊！";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"室内空气挺干净，室外空气真不给力…";
                    }
                }
                else if(pm25InDoorNum > 75 && pm25InDoorNum <= 115)
                {
                    if(pm25OutDoorNum <= 75)
                    {
                        returnStr = @"呼吸有点儿不畅快，开会儿窗户吧~";
                    }
                    else if(pm25OutDoorNum > 75 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"一大波雾霾正在靠近，快传净化器护驾！";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"已经被雾霾包围了，快让净化器干活吧~";
                    }
                }
                else if(pm25InDoorNum > 115 && pm25InDoorNum <= 150)
                {
                    if(pm25OutDoorNum <= 75)
                    {
                        returnStr = @"空气被污染了，强烈建议开窗通风！";
                    }
                    else if(pm25OutDoorNum > 75 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"室内环境很差了，让净化器努力干活吧~";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"空气很糟糕呀，让净化器加个班吧";
                    }
                }
                
                else if(pm25InDoorNum > 150 && pm25InDoorNum <= 250)
                {
                    if(pm25OutDoorNum <= 75)
                    {
                        returnStr = @"空气都快中毒了，赶紧开窗喘口气吧！";
                    }
                    else if(pm25OutDoorNum > 75 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"空气感染很严重了，求你开净化器吧…";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"雾霾太猖狂，快开净化器，谨慎出门。";
                    }
                }
                else if(pm25InDoorNum > 250)
                {
                    if(pm25OutDoorNum <= 75)
                    {
                        returnStr = @"你才是雾霾制造者！请以光速打开窗户！";
                    }
                    else if(pm25OutDoorNum > 75 && pm25OutDoorNum <= 150)
                    {
                        returnStr = @"空气差得可以杀人！千万别让净化器停！";
                    }
                    else if(pm25OutDoorNum > 150)
                    {
                        returnStr = @"空气质量已彻底沦陷！关门，放净化器！";
                    }
                }
                
                return  returnStr;
            }
        }
    }
    
    if(moode && moode.length > 0 && ![moode isEqualToString:@"--"])
    {
        if([moode intValue] >= 90)
        {
            returnStr = NSLocalizedString(@"非常好",@"AirDeviceViewController.m");
        }
        else if([moode intValue] >= 80 && [moode intValue] <= 89)
        {
            returnStr =  NSLocalizedString(@"还不错",@"AirDeviceViewController.m");
        }
        else if([moode intValue] >=60 && [moode intValue] <= 79)
        {
            returnStr =  NSLocalizedString(@"有点差",@"AirDeviceViewController.m");
        }
        else if([moode intValue] < 60)
        {
            returnStr =  NSLocalizedString(@"太差啦",@"AirDeviceViewController.m");
        }
    }
    if ([MainDelegate isLanguageEnglish]) {
        returnStr = [NSString stringWithFormat:@"Air Quality: %@" ,returnStr];
        
    }else{
        returnStr = [NSString stringWithFormat:@"室内空气%@" ,returnStr];
        
    }

    return returnStr;
}

#pragma mark - 处理离线时候的红外命令
- (void)doWithCacheData
{
    DDLogFunction();
    if([MainDelegate isNetworkAvailable])
    {
        NSArray *localCodesAdd = [UserDefault objectForKey:IRCodeAddOutline(curDevice.mac,MainDelegate.loginedInfo.loginID)];
        
        NSArray *localCodesDelete = [UserDefault objectForKey:IRCodeDeleteOutLine(curDevice.mac,MainDelegate.loginedInfo.loginID)];
        
        if(localCodesAdd && [localCodesAdd count] > 0)
        {
            for(NSDictionary *dicAdd in localCodesAdd)
            {
                [self storeIRCode:0 withDicIRCode:dicAdd];
            }
            
            [UserDefault removeObjectForKey:IRCodeAddOutline(curDevice.mac,MainDelegate.loginedInfo.loginID)];
            
            [UserDefault synchronize];
        }
        
        if(localCodesDelete && [localCodesDelete count] > 0)
        {
            for(NSDictionary *dicDelete in localCodesDelete)
            {
                [self deleteIRCode:0 withDicIRCode:dicDelete];
            }
    
            [UserDefault removeObjectForKey:IRCodeDeleteOutLine(curDevice.mac,MainDelegate.loginedInfo.loginID)];
            
            [UserDefault synchronize];
        }
        
    }
}

-(void)deleteIRCode:(NSInteger)requestCount withDicIRCode:(NSDictionary *)dicIRCode
{
    DDLogFunction();
    NSString *userID     = MainDelegate.loginedInfo.userID;
    NSString *keyCode    = dicIRCode[@"keycode"];
    NSString *sequenceID = [MainDelegate sequenceID];
    
    NSURLRequest *request = [MainDelegate requestUrl:SERVER_DEL_IRCODE(curDevice.mac, userID, keyCode, sequenceID) method:HTTP_DELETE body:@""];
    
    DDLogCVerbose(@"request IR code : %@",SERVER_DEL_IRCODE(curDevice.mac, userID, keyCode, sequenceID));
    
    [NSURLConnection sendAsynchronousRequestTest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         BOOL succeed = YES;
         if(connectionError)
         {
             succeed = NO;
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->Del IR code : %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 // 丢弃这条数据 合并一起删除
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
                                 //                                 [self :requestCount + 1];
                                 [self storeIRCode:(requestCount + 1) withDicIRCode:dicIRCode];
                             }];
                             return;
                         }
                         else
                         {
                             // 丢弃这条数据 合并一起删除
                         }
                     }
                 }
             }
         }
     }];
}

-(void)storeIRCode:(NSInteger)requestCount withDicIRCode:(NSDictionary *)dicIRCode
{
    DDLogFunction();
    NSString *keyCode = [[[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByReplacingOccurrencesOfString:@"." withString:@""] substringToIndex:13];
    NSDictionary *bodyDict =  @{@"userIRCode":@{@"ircode":dicIRCode[@"ircode"],
                                                @"name":dicIRCode[@"name"],
                                                @"keycode":keyCode},
                                @"sequenceId":  [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:bodyDict];
    NSString *userID = MainDelegate.loginedInfo.userID;
    NSURLRequest *request =[MainDelegate requestUrl:SERVER_SET_IRCODE(curDevice.mac, userID) method:HTTP_POST body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         BOOL succeed = YES;
         if(connectionError)
         {
             succeed = NO;
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             DDLogCVerbose(@"--->SET irCode List : %@",result);
             result = isObject(result) ? result : nil;
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 // 丢弃这条数据
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
                                 //                                 [self :requestCount + 1];
                                 [self storeIRCode:(requestCount + 1) withDicIRCode:dicIRCode];
                             }];
                             return;
                         }
                         else
                         {
                             // 丢弃这条数据
                         }
                     }
                 }
             }
         }
     }];
}


@end
