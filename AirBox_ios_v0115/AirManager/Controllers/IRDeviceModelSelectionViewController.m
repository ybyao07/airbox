//
//  IRDeviceModelSelectionViewController.m
//  AirManager
//

#import "IRDeviceModelSelectionViewController.h"
#import "IRDevice.h"
#import "IRDeviceManager.h"
#import "AirDevice.h"
#import "AirConditionViewController.h"
#import "UIDevice+Resolutions.h"
#import <uSDKFramework/uSDKDevice.h>
#import "AppDelegate.h"
#import "SDKRequestManager.h"
#import "AlertBox.h"
#import "FeedbackViewController.h"
#import "RMDownloadIndicator.h"
#import "UIDevice+Resolutions.h"
#import "UIViewExt.h"
#import "IRDeviceCell.h"
#import "AirDeviceBindViewController.h"
#import "DeviceManagementViewController.h"
#import "CustomModelViewController.h"
#import "AirPurgeModel.h"
#import "IntelligenceVCViewController.h"
#import "AirDeivceManageViewController.h"
#import "AirDeviceViewController.h"

#define kBrandIndex     0
#define kModelIndex     1

#define kBrandString    @"Brand"
#define kModelString    @"Model"
#define kDeviceString   @"Device"

#define kButtonNormalImageName @"ir_dev_radio_normal.png"
#define kButtonPressImageName @"ir_dev_radio_pressed.png"

#define kCellBodyColor  [UIColor colorWithRed:240/255.0f green:237/255.0f blue:229/255.0f alpha:1]

typedef void(^AnimationCompletionHandler)();

@interface IRDeviceModelSelectionViewController ()
{
    IBOutlet UIView         *isACOpendByControl;
    IBOutlet UIView         *acNotOpendByControl;
    IBOutlet UIView         *allACList;
    IBOutlet UIView         *downloadIRCode;
    IBOutlet UIView         *sendTestIRCode;
    IBOutlet UIView         *isOpenedACByTestCode;
    IBOutlet UIView         *bindSucceed;
    IBOutlet UIView         *bindFailure;
    IBOutlet UIView         *downloadError;
    IBOutlet UIView         *progressView;
    IBOutlet UIView         *sendIrToAirBox;
    IBOutlet UIView         *matchingView;
    IBOutlet UIView         *matchFailed;
    
    IBOutlet UITableView    *acTableView;
    IBOutlet UIImageView    *signalInOpenAc;
    IBOutlet UIImageView    *signalInSendIrToAirBox;

    IBOutlet UILabel        *titleInOpenAc;
    IBOutlet UILabel        *tipsInOpenAc;
    IBOutlet UILabel        *titleInCheckAcStatus;
    IBOutlet UILabel        *tipsInCheckAcStatus;
    IBOutlet UILabel        *titleInAcNotOpenByControl;
    IBOutlet UILabel        *titleInAllAcList;
    IBOutlet UILabel        *titleInDownloadIrCode;
    IBOutlet UILabel        *tipsInDownloadIrCode;
    IBOutlet UILabel        *titleInSendIrCode;
    IBOutlet UILabel        *tipsInSendIrCode;
    IBOutlet UILabel        *titleInIsHearAcRing;
    IBOutlet UILabel        *tipsInIsHearAcRing;
    IBOutlet UILabel        *titleInBindSucceed;
    IBOutlet UILabel        *tipsInBindSucceed;
    IBOutlet UILabel        *titleInBindFailed;
    IBOutlet UILabel        *tipsInBindFailed;
    IBOutlet UILabel        *titleInErrorView;

    
    IBOutlet UILabel        *titleInSendIrToAirBox;
    IBOutlet UILabel        *titleInMatching;
    IBOutlet UILabel        *titleInMatchFailed;
    IBOutlet UILabel        *tips1InSendIrToAirBox;
    IBOutlet UILabel        *tips2InSendIrToAirBox;
    
    IBOutlet UIButton       *cancelBtnInSendIrCode;
    IBOutlet UIButton       *cancelBtnInDownloadIr;
    IBOutlet UIImageView    *lineInSendIrCode;
    IBOutlet UIImageView    *lineInDownloadIr;
    
    RMDownloadIndicator     *circleView;
    NSDictionary            *curIRDeviceCode;
    
    NSMutableArray          *_IRDeviceList;
    NSMutableArray          *_IRDeviceTitles;
    NSMutableArray          *_bindIRDeviceList;

    NSInteger               deviceCount;
    NSInteger               selectedIRDeviceIdx;
    NSInteger               dowloadIRCodeIndex;

    NSString                *testIrKey;
    BOOL                    isAlreadyBind;
    BOOL                    isCancelDownload;
    BOOL                    isManualBind;
    NSString                *autoStudyCode;
    IRDevice                *autoStudyIrDevice;
    BOOL                    isInMatchingView;
    NSInteger               autoStudyWaitTime;
    NSTimer                 *studyWaitTimer;
    BOOL                    isCountDowning;
    BOOL                    pageIsDisplay;
}

/**
 *  Download and verity the infrared codes
 **/
- (void)downloadIRCode:(id)sender;

/**
 *  Binding small A infraed device
 **/
- (void)bindIRDevice;

/**
 *  IRDevice download is complete
 **/

- (void)irCodeDownloaded;

- (IBAction)sendIrByControlNext:(id)sender;

- (IBAction)enterManual:(id)sender;

- (IBAction)notEnteManual:(id)sender;

- (IBAction)nextInOpenAc:(id)sender;

- (IBAction)backInCheckAcStatus:(id)sender;

- (IBAction)acOpenedByControl:(id)sender;

- (IBAction)acNotOpenByControl:(id)sender;

- (IBAction)backInAcNotOpend:(id)sender;

- (IBAction)cancelInAllAcList:(id)sender;

- (IBAction)cancelInDownloadIrCode:(id)sender;

- (IBAction)cancelInSendIrCode:(id)sender;

- (IBAction)hearAcRing:(id)sender;

- (IBAction)notHearAcRing:(id)sender;

- (IBAction)reTryInErrorView:(id)sender;

- (IBAction)cancelInErrorView:(id)sender;

- (IBAction)notFindControl:(id)sender;

@property (nonatomic,strong) NSDictionary *curIRDeviceCode;
@property (nonatomic,strong) NSString     *irDeviceName;
@property (nonatomic,strong) NSString     *testIrKey;
@property (nonatomic,strong) NSString     *autoStudyCode;
@property (nonatomic,strong)IRDevice      *autoStudyIrDevice;

@end

@implementation IRDeviceModelSelectionViewController

@synthesize curIRDeviceCode;
@synthesize testIrKey;
@synthesize autoStudyCode;
@synthesize autoStudyIrDevice;
@synthesize selectedAirDevice;
@synthesize airPurgeModel;

#pragma mark - View LifeCycle

- (void)dealloc
{
    if([studyWaitTimer isValid])
    {
        [studyWaitTimer invalidate];
    }
    
    studyWaitTimer = nil;
    
    [self removeAutoStudyNotification];
    DDLogFunction();
   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _IRDeviceList = [[NSMutableArray alloc] initWithCapacity:5];
        _IRDeviceTitles = [[NSMutableArray alloc] initWithCapacity:5];
        _bindIRDeviceList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
   
    [super viewDidLoad];
    
    [self layoutView];
    
    pageIsDisplay = YES;
    [self registeAutoStudyNotification];

    if([self.deviceType isEqualToString:kDeviceTypeAC])
    {
        isManualBind = NO;
    }
    else
    {
        isManualBind = YES;
    }

    NSArray *images = @[[UIImage imageNamed:@"ir_signal1.png"],
                        [UIImage imageNamed:@"ir_signal2.png"],
                        [UIImage imageNamed:@"ir_signal3.png"]];
    
    signalInSendIrToAirBox.animationImages = images;
    signalInSendIrToAirBox.animationDuration = 1;
    signalInSendIrToAirBox.animationRepeatCount = 0;
    [signalInSendIrToAirBox startAnimating];
    
    signalInOpenAc.animationImages = images;
    signalInOpenAc.animationDuration = 1;
    signalInOpenAc.animationRepeatCount = 0;
    [signalInOpenAc startAnimating];
    
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

- (void)checkBindModel
{
    if(!isManualBind)
    {
        //[MainDelegate showProgressHubInView:self.view];
        uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[MainDelegate.curBindDevice.mac];
        
        DDLogCVerbose(@" 当前盒子的状态 -----> device.netType = @%d",device.netType);
        if(device.netType == NET_TYPE_REMOTE)
        {
            [AlertBox showWithMessage:NSLocalizedString(@"红外学习条件不满足(需手机与空气盒子连接至同一无线路由器),请手动选择绑定",@"IRDeviceModelSelectionViewController.m")];
            [self notFindControl:nil];
        }
        else
        {
            [self openView:sendIrToAirBox completion:^{
                dispatch_async(dispatch_queue_create("OpenStudy", NULL), ^{
                    for (int i = 0; i < 3; i++)
                    {
                        if([self openAirBoxStudyModel:YES] == RET_USDK_OK)
                        {
                            [MainDelegate hiddenProgressHubInView:self.view];
                            if(pageIsDisplay)
                            {
                                [self performSelectorOnMainThread:@selector(startCountStudyWaitTime) withObject:nil waitUntilDone:NO];
                            }
                            break;
                        }
                        
                        if(i == 2)
                        {
                            [MainDelegate hiddenProgressHubInView:self.view];
                            //将小A设置为学习模式失败，直接进入询问是否进入手动控制
                            [self openView:matchFailed completion:^{
                                [self closeView:sendIrToAirBox complttion:nil];
                            }];
                        }
                    }
                });
            }];
        }
    }
    else
    {
        [self setupTitleAndTips];
        [self customTableview:acTableView];
        [self openView:allACList completion:nil];
        [self downloadIRDeviceList:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self checkBindModel];
    [self setupTitleAndTips];
    
//    [NotificationCenter postNotificationName:AirControlPageOpenCompleteNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    pageIsDisplay = NO;
    [self stopCountStudyWaitTime];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Private Methods

- (void)startCountStudyWaitTime
{
    DDLogFunction();
    isCountDowning = YES;
    autoStudyWaitTime = AutoStudyWaitTime;
    if([studyWaitTimer isValid])
    {
        [self stopCountStudyWaitTime];
    }
    studyWaitTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(changeWaitTime)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)stopCountStudyWaitTime
{
    DDLogFunction();
    isCountDowning = NO;
    if([studyWaitTimer isValid])
    {
        [studyWaitTimer invalidate];
    }
    
    studyWaitTimer = nil;
}

- (void)changeWaitTime
{
    DDLogFunction();
    autoStudyWaitTime--;
    DDLogCVerbose(@"changeWaitTime in auto bind %d",autoStudyWaitTime);
    if(!isCountDowning)return;
    if(autoStudyWaitTime <= 0)
    {
        [self removeAutoStudyNotification];
        [self stopCountStudyWaitTime];
        [AlertBox showWithMessage:NSLocalizedString(@"空气盒子未接收到任何遥控器指令，请重试",@"IRDeviceModelSelectionViewController.m") delegate:(id)self showCancel:NO];
    }
}

- (void)registeAutoStudyNotification
{
    DDLogFunction();
    [NotificationCenter addObserver:self selector:@selector(receiveAutoStudyIrCode:)
                               name:SdkDeviceReceiveIrNotification object:nil];
}

- (void)removeAutoStudyNotification
{
    DDLogFunction();
    [NotificationCenter removeObserver:self];
}


- (void)checkMatchingStatus
{
    DDLogFunction();
    if(isInMatchingView)
    {
        if(!self.autoStudyCode)
        {
            [self openView:matchFailed completion:^{
                [self closeView:matchingView complttion:^{
                    isInMatchingView = NO;
                }];
            }];
        }
    }
}

- (void)receiveAutoStudyIrCode:(NSNotification *)notify
{
    DDLogFunction();
    DDLogCVerbose(@"红外匹配收到的红外码通知 :%@",notify.object);
    [self stopCountStudyWaitTime];
    [self removeAutoStudyNotification];
    self.autoStudyCode = notify.object;
    /** 5.26
    if(isInMatchingView)
    {
        [self matchAcBrandFromServer];
    }
     **/
    [self matchAcBrandFromServer];
}

- (void)matchAcBrandFromServer
{
    DDLogFunction();
    if(self.autoStudyCode.length > 0)
    {
        NSDictionary *dicBody = @{@"ircode":@[self.autoStudyCode],
                                  @"devType":self.deviceType,
                                  @"sequenceId":[MainDelegate sequenceID]};
        NSString *body = [MainDelegate createJsonString:dicBody];
        NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_IR_MATCH(selectedAirDevice.mac)
                                                         method:HTTP_POST
                                                           body:body];
        [NSURLConnection sendAsynchronousRequestTest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {

             if(connectionError)
             {
                 [self openView:matchFailed completion:^{
                     [self closeView:matchingView complttion:^{
                         isInMatchingView = NO;
                     }];
                 }];
             }
             else
             {
                 NSDictionary *result = [MainDelegate parseJsonData:data];
                 result = isObject(result) ? result : nil;
                 DDLogCVerbose(@"--->matchAcBrandFromServer response data: %@, Json: %@", data, result);
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                 {
                     self.autoStudyIrDevice = [[IRDevice alloc] init];
                     autoStudyIrDevice.brand = isObject(result[@"brand"])?result[@"brand"]:@"";
                     autoStudyIrDevice.devType = isObject(result[@"devType"])?result[@"devType"]:@"";
                     autoStudyIrDevice.devModel = isObject(result[@"devModel"])?result[@"devModel"]:@"";
                     
                     cancelBtnInDownloadIr.hidden = isManualBind ? NO : YES;
                     lineInDownloadIr.hidden = isManualBind ? NO : YES;
                     [self openView:downloadIRCode completion:^{
                         [self closeView:matchingView complttion:^{
                             isInMatchingView = NO;
                         }];
                     }];
                     isCancelDownload = NO;
                     [self downloadIRCode:nil];
                 }
                 else
                 {
                     [self openView:matchFailed completion:^{
                         [self closeView:matchingView complttion:^{
                             isInMatchingView = NO;
                         }];
                     }];
                 }
             }
         }];

    }
    else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self openView:matchFailed completion:^{
                [self closeView:matchingView complttion:^{
                    isInMatchingView = NO;
                }];
            }];
        });
    }
}

static int cmdsn = 0;
- (uSDKErrorConst )openAirBoxStudyModel:(BOOL)open
{
    DDLogFunction();
    cmdsn = (cmdsn + 1) / 10000;
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[selectedAirDevice.mac];
    uSDKDeviceAttribute *attr = [[uSDKDeviceAttribute alloc] init];
    attr.attrName = open ? @"20w00i" : @"20w00j";
    attr.attrValue = @"";
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:attr,nil];
    uSDKErrorConst errorConst = [device execDeviceOperation:array withCmdSN:cmdsn withGroupCmdName:nil];
    DDLogCVerbose(@"Set air box to auto status result : %d",errorConst);
    return errorConst;
}

- (void)downloadIRDeviceList:(BOOL)autoFailed
{
    
    DDLogFunction();
    
    if(![MainDelegate isNetworkAvailable])return;
    [MainDelegate showProgressHubInView:self.view];
    
    NSDictionary *dicBody = @{@"version":@"0",@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_IRDEV_MODEL_LIST
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         
         NSString *errorInfo = NSLocalizedString(@"获取设备型号列表失败",@"IRDeviceModelSelectionViewController.m");
         if (connectionError)
         {
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             DDLogCVerbose(@"--->downloadIRDeviceList response data: %@, Json: %@", data, result);
             result = isObject(result) ? result : nil;
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSArray *devices = result[@"irdevices"];
                 if(![devices isEqual:[NSNull null]])
                 {
                     for (NSDictionary *device in devices)
                     {
                         IRDevice *irDevice = [[IRDevice alloc] initWithDevice:device];
                         [_IRDeviceList addObject:irDevice];
                     }
                 }
                 
                 // reset picker titles
                 [self resetPickerTitles:_IRDeviceTitles withIRDeviceList:_IRDeviceList];
                 if([self.deviceType isEqualToString:kDeviceTypeAC])
                 {
                     [self openView:allACList completion:^{
                         /** 5.23
                         [self closeView:isACOpendByControl complttion:nil];
                          **/
                         if(autoFailed)
                         {
                             [self closeView:matchFailed complttion:nil];
                         }
                         else
                         {
                             [self closeView:sendIrToAirBox complttion:nil];
                         }
                     }];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [acTableView reloadData];
                 });
             }
             else
             {
                 if(result && isObject(result[HttpReturnInfo]))
                 {
                     if(result[HttpReturnInfo] && ![result[HttpReturnInfo] isEqualToString:@"会话过期"])
                     {
                         errorInfo = result[HttpReturnInfo];
                     }
                 }
                 [AlertBox showWithMessage:errorInfo];
             }
         }
     }];
}

- (void)prepareDownloadIRCode:(UIButton *)sender
{
    DDLogFunction();
    UIButton *button = (UIButton *)sender;
    button.userInteractionEnabled = NO;
    [button performSelector:@selector(setUserInteractionEnabled:)  withObject:[NSNumber  numberWithBool:YES]  afterDelay:0.5];
    
    [self openView:downloadIRCode completion:^{
        [self closeView:allACList complttion:nil];
    }];

    isCancelDownload = NO;
    selectedIRDeviceIdx = sender.tag - 1000;
    dowloadIRCodeIndex = 0;
    
    NSDictionary *dictBrand = _IRDeviceTitles[selectedIRDeviceIdx];
    NSArray *arrModel = dictBrand[kModelString];
    deviceCount = [arrModel count];
    
    [_bindIRDeviceList removeAllObjects];

    [self setDeviceNameWithIndex:selectedIRDeviceIdx];

    [self downloadIRCode:sender];
}

- (void)downloadIRCode:(UIButton *)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])return;

    if(isManualBind)
    {
        NSDictionary *dictBrand = _IRDeviceTitles[selectedIRDeviceIdx];
        NSArray *arrModel = dictBrand[kModelString];
        if(arrModel && dowloadIRCodeIndex < arrModel.count)
        {
            NSDictionary *dictModel = arrModel[dowloadIRCodeIndex];
            IRDevice *device = dictModel[kDeviceString];
            [_bindIRDeviceList addObject:device];
            IRDeviceManager *deviceManager = [[IRDeviceManager alloc] init];
            [deviceManager setCompletionHandler:^(BOOL isSucceed){
                if(isCancelDownload) return;
                if(isSucceed)
                {
                    NSDictionary *dictModel = arrModel[dowloadIRCodeIndex];
                    IRDevice *device = dictModel[kDeviceString];
                    NSString *name = [NSString stringWithFormat:@"%@%@%@",device.brand,device.devType,device.devModel];
                    self.irDeviceName = name;
                    [self irCodeDownloaded];
                }
                else
                {
                    if(isCancelDownload)return;
                    [self openView:downloadError completion:^{
                        [self closeView:downloadIRCode complttion:^{
                            progressView.width = 0;
                        }];
                    }];
                }
            }];
            [deviceManager checkIRDevice:device onAirDevice:selectedAirDevice];
        }
    }
    else
    {
        IRDeviceManager *deviceManager = [[IRDeviceManager alloc] init];
        [deviceManager setCompletionHandler:^(BOOL isSucceed){
            if(isCancelDownload) return;
            if(isSucceed)
            {
                NSString *name = [NSString stringWithFormat:@"%@%@%@",
                                  autoStudyIrDevice.brand,
                                  autoStudyIrDevice.devType,
                                  autoStudyIrDevice.devModel];
                self.irDeviceName = name;
                [self irCodeDownloaded];
            }
            else
            {
                if(isCancelDownload)return;
                [self openView:matchFailed completion:^{
                    [self closeView:downloadIRCode complttion:^{
                        progressView.width = 0;
                    }];
                }];
            }
        }];
        [deviceManager checkIRDevice:autoStudyIrDevice onAirDevice:selectedAirDevice];
    }

}

- (void)resetPickerTitles:(NSMutableArray *)pickerTitles withIRDeviceList:(NSArray *)deviceList
{
    
    DDLogFunction();
    DDLogCVerbose(@"Device list: %@", deviceList);
    
    [pickerTitles removeAllObjects];
    
    for (IRDevice *device in deviceList)
    {
        if (![device.devType isEqualToString:self.deviceType]) continue;
        
        BOOL hasAdded = NO;
        for (NSDictionary *dict in pickerTitles)
        {
            if ([dict[kBrandString] isEqualToString:device.brandName])
            {
                BOOL hasExistedModel = NO;
                for (NSDictionary *dictModel in dict[kModelString])
                {
                    NSString *model = dictModel[kModelString];
                    if ([model isEqualToString:device.devModelName])
                    {
                        hasExistedModel = YES;
                        break;
                    }
                }
                
                if (!hasExistedModel)
                {
                    NSDictionary *dictModel = [NSDictionary dictionaryWithObjectsAndKeys:
                                               device.devModelName, kModelString,
                                               device, kDeviceString,
                                               nil];
                    [dict[kModelString] addObject:dictModel];
                }
                
                hasAdded = YES;
                break;
            }
        }
        
        if (hasAdded) continue;
        
        NSDictionary *dictModel = [NSDictionary dictionaryWithObjectsAndKeys:
                                   device.devModelName, kModelString,
                                   device, kDeviceString,
                                   nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              device.brandName, kBrandString,
                              [NSMutableArray arrayWithObject:dictModel], kModelString,
                              nil];
        [pickerTitles addObject:dict];
    }
    
    DDLogCVerbose(@"Picker titles: %@", pickerTitles);
}

- (void)irCodeDownloaded
{
    DDLogFunction();
    if(isCancelDownload)return;
    NSDictionary *allIRCode = [UserDefault objectForKey:IRDeviceIRCodeStore];
    self.curIRDeviceCode = allIRCode[self.irDeviceName];
    if(curIRDeviceCode != nil && [curIRDeviceCode count] > 0)
    {
        [self testIRCode];
    }
}

#define TestIRCodeKey24 @"2430e0W630e0M120e00E"
#define TestIRCodeKey25 @"2530e0W630e0M120e00E"
- (void)testIRCode
{
    DDLogFunction();
    if(isCancelDownload)return;
    NSMutableDictionary *allIRCode = [NSMutableDictionary dictionaryWithDictionary:curIRDeviceCode[IRCode]];
    DDLogCVerbose(@"\n\n%@\n\n",allIRCode);
    if(allIRCode.count == 0)
    {
        [MainDelegate hiddenProgressHubInView:self.view];
        if(isCancelDownload)return;
        if(isManualBind)
        {
            [self openView:downloadError completion:^{
                [self closeView:downloadIRCode complttion:^{
                    progressView.width = 0;
                }];
            }];
        }
        else
        {
            [self openView:matchFailed completion:^{
                [self closeView:downloadIRCode complttion:^{
                    progressView.width = 0;
                }];
            }];
        }

        if(isCancelDownload)return;
    }
    
    NSString *testIRCode = nil;
    if([self.deviceType isEqualToString:kDeviceTypeAC])
    {
        testIRCode = allIRCode[TestIRCodeKey24];
        self.testIrKey = TestIRCodeKey24;
        if(testIRCode.length == 0)
        {
            testIRCode = allIRCode[TestIRCodeKey25];
            self.testIrKey = TestIRCodeKey25;
        }
        
        if(testIRCode.length == 0)
        {
            [allIRCode removeObjectForKey:IRDeviceCloseCodeTag];
            NSMutableArray *autoModelKey = [self filteAutoModel:[allIRCode allKeys]];
            if(autoModelKey.count != 0)
            {
                testIRCode = allIRCode[autoModelKey[0]];
                self.testIrKey = autoModelKey[0];
            }
        }
        
        if(testIRCode.length == 0)
        {
            testIRCode = [allIRCode allValues][0];
            NSArray *keyByValue = [allIRCode allKeysForObject:testIRCode];
            if(keyByValue.count > 0)
            {
                self.testIrKey = keyByValue[0];
            }
        }
    }
    else
    {
        testIRCode = allIRCode[APDeviceOpenCodeTag];
    }
    
    DDLogCVerbose(@"\n\n=======\n%@\n=======\n\n",testIRCode);
    
    uSDKDevice *device = nil;
    NSMutableArray *deviceList = [[SDKRequestManager sharedInstance] deviceList];
    for(int i = 0; i < [deviceList count]; i++)
    {
        uSDKDevice *sdkDevice = deviceList[i];
        if([sdkDevice.mac isEqualToString:selectedAirDevice.mac])
        {
            device = sdkDevice;
            break;
        }
    }
    uSDKDeviceAttribute* attr = [[uSDKDeviceAttribute alloc] initWithAttrName:SendIRCommand withAttrValue:testIRCode];
    NSMutableArray *cmdList = [NSMutableArray arrayWithObject:attr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
                progressView.width = 235;
        } completion:^(BOOL finished){
            if (isCancelDownload) return;
            cancelBtnInSendIrCode.hidden = isManualBind ? NO : YES;
            lineInSendIrCode.hidden = isManualBind ? NO : YES;
            [self openView:sendTestIRCode completion:^{
                [self closeView:downloadIRCode complttion:^{
                    progressView.width = 0;
                }];
            }];
            [self performSelector:@selector(startDrawCircle) withObject:nil afterDelay:0];
            dispatch_async(dispatch_queue_create("send_ir_code", NULL), ^{
                uSDKErrorConst error = [device execDeviceOperation:cmdList withCmdSN:1000 withGroupCmdName:nil];
               
                DDLogCVerbose(@"Test IR Code Request: %u",error);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self updateUIInStep7:error];
                });
            });
        }];
    });
}

- (NSMutableArray *)filteAutoModel:(NSArray *)array
{
    DDLogFunction();
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++)
    {
        NSString *key = array[i];
        if([key rangeOfString:@"30e0M1"].length > 0)
        {
            [newArray addObject:key];
            break;
        }
    }
    return newArray;
}

- (NSDictionary *)getAirConditionModuleData
{
    NSDictionary *dicMode = nil;
    NSString *apOnOff = airPurgeModel.apOnOff ? airPurgeModel.apOnOff : IRDeviceClose;

    if([self.deviceType isEqualToString:kDeviceTypeAC])
    {
        dicMode = @{@"mode":@"0",
                    @"time":@"9999",
                    @"temperature":[testIrKey substringToIndex:2],
                    @"onoff":IRDeviceOpen,
                    @"acmode":[testIrKey substringWithRange:NSMakeRange(8, 6)],
                    @"windspeed":[testIrKey substringWithRange:NSMakeRange(2, 6)],
                    @"aponoff":apOnOff,
                    @"healtyState":@"off",
                    //  智能控制新增加的几个参数
                    @"acflag":@NO,
                    @"apflag":@NO,
                    @"pm25":@"50",
                    @"sleepModeId":@"1"
                    };
    }
    else
    {
            NSString *curTemp = [airPurgeModel.temperature stringByReplacingOccurrencesOfString:CelciusSymbol withString:@""];
            NSString *curStatus = airPurgeModel.onOff;
            NSString *acmode = airPurgeModel.operationCodeList[airPurgeModel.acMode];
            NSString *speed = airPurgeModel.operationCodeList[airPurgeModel.windSpeed];
            NSString *time = [airPurgeModel.time stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *healthyState = airPurgeModel.healthyState ? airPurgeModel.healthyState : @"";
            NSString *pm25 = airPurgeModel.pm25 ? airPurgeModel.pm25 : @"50";
            NSString *sleepModeId = airPurgeModel.sleepModeId ? airPurgeModel.sleepModeId : @"";
            if([time isEqualToString:@"0000"])
            {
                time = @"9999";
            }
            dicMode = @{@"mode":@"0",
                        @"time":time,
                        @"temperature":curTemp,
                        @"onoff":curStatus,
                        @"acmode":acmode,
                        @"windspeed":speed,
                        @"aponoff":IRDeviceOpen,
                        @"healtyState":healthyState,
                        //  智能控制新增加的几个参数
                        @"acflag":@NO,
                        @"apflag":@NO,
                        @"pm25":pm25,
                        @"sleepModeId":sleepModeId
                        };
    }
    
    return dicMode;

}

- (NSDictionary *)getIntelligenceModuleData:(BOOL)isFromSleepModule
{
    NSDictionary *dicMode = nil;
    NSString *apOnOff = airPurgeModel.apOnOff ? airPurgeModel.apOnOff : IRDeviceClose;
    NSNumber *apflag = airPurgeModel.apflag ? airPurgeModel.apflag : @NO;
    if([self.deviceType isEqualToString:kDeviceTypeAC])
    {
        if(!isFromSleepModule) // 个人模式开启情况下绑定空调
        {
            dicMode = @{@"mode":@"4",
                        @"time":@"9999",
                        @"temperature":@"26",
                        @"onoff":IRDeviceOpen,
                        @"acmode":airPurgeModel.operationCodeList[airPurgeModel.acModelList[1]],
                        @"windspeed":airPurgeModel.operationCodeList[airPurgeModel.windSpeedList[3]],
                        @"aponoff":apOnOff,
                        @"healtyState":@"off",
                        //  智能控制新增加的几个参数
                        @"acflag":@YES,
                        @"apflag":apflag,
                        @"pm25":@"50",
                        @"sleepModeId":@"1"
                        };
        }
        else // 睡眠模式开启情况下绑定空调
        {
            dicMode = @{@"mode":@"5",
                        @"time":@"9999",
                        @"temperature":@"26",
                        @"onoff":IRDeviceOpen,
                        @"acmode":airPurgeModel.operationCodeList[airPurgeModel.acModelList[1]],
                        @"windspeed":airPurgeModel.operationCodeList[airPurgeModel.windSpeedList[3]],
                        @"aponoff":IRDeviceClose,
                        @"healtyState":@"off",
                        //  智能控制新增加的几个参数
                        @"acflag":@NO,
                        @"apflag":@NO,
                        @"pm25":@"50",
                        @"sleepModeId":@"1"
                        };
        }
    }
    else
    {
        if([[self parentViewController] isKindOfClass:[AirDeivceManageViewController class]])
        {
            dicMode = @{@"mode":@"4",
                        @"time":@"9999",
                        @"temperature":@"26",
                        @"onoff":IRDeviceClose,
                        @"acmode":airPurgeModel.operationCodeList[airPurgeModel.acModelList[1]],
                        @"windspeed":airPurgeModel.operationCodeList[airPurgeModel.windSpeedList[3]],
                        @"aponoff":IRDeviceOpen,
                        @"healtyState":@"off",
                        //  智能控制新增加的几个参数
                        @"acflag":@NO,
                        @"apflag":@YES,
                        @"pm25":@"50",
                        @"sleepModeId":@"1"
                        };
            
        }
        else if ([self.parentViewController isKindOfClass:[IntelligenceVCViewController class]])
        {
            NSString *curTemp = [airPurgeModel.temperature stringByReplacingOccurrencesOfString:CelciusSymbol withString:@""];
            NSString *curStatus = airPurgeModel.onOff;
            NSString *acmode = airPurgeModel.operationCodeList[airPurgeModel.acMode];
            NSString *speed = airPurgeModel.operationCodeList[airPurgeModel.windSpeed];
            NSString *time = [airPurgeModel.time stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *healthyState = airPurgeModel.healthyState ? airPurgeModel.healthyState : @"";
            NSNumber *acflag = airPurgeModel.acflag ? airPurgeModel.acflag : @NO;
            NSString *pm25 = airPurgeModel.pm25 ? airPurgeModel.pm25 : @"50";
            NSString *sleepModeId = airPurgeModel.sleepModeId ? airPurgeModel.sleepModeId : @"";
            if([time isEqualToString:@"0000"])
            {
                time = @"9999";
            }
            dicMode = @{@"mode":@"4",
                        @"time":time,
                        @"temperature":curTemp,
                        @"onoff":curStatus,
                        @"acmode":acmode,
                        @"windspeed":speed,
                        @"aponoff":IRDeviceOpen,
                        @"healtyState":healthyState,
                        //  智能控制新增加的几个参数
                        @"acflag":acflag,
                        @"apflag":@YES,
                        @"pm25":pm25,
                        @"sleepModeId":sleepModeId
                        };
        }
    }
    
    return dicMode;
    
}
- (void)uploadOpenAcModel
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    
    if(self.airPurgeModel == nil)
    {
        self.airPurgeModel = selectedAirDevice.userAirMode;
    }
    
    NSDictionary *dicMode = nil;
    
    if([[self parentViewController] isKindOfClass:[AirDeivceManageViewController class]])
    {
        AirDeivceManageViewController *ac = (AirDeivceManageViewController *)[self parentViewController];
        if(ac.isFromMannul)
        {
            dicMode = [self getAirConditionModuleData];
        }
        else
        {
            dicMode = [self getIntelligenceModuleData:NO];
        }
    }
    
    else if([self.parentViewController isKindOfClass:[AirConditionViewController class]])
    {
        dicMode = [self getAirConditionModuleData];
    }
    
    else if ([self.parentViewController isKindOfClass:[IntelligenceVCViewController class]])
    {
        IntelligenceVCViewController *vc = (IntelligenceVCViewController *)self.parentViewController;
        dicMode = [self getIntelligenceModuleData:vc.isFromSleepModule];
    }
    else
    {
        dicMode = [self getAirConditionModuleData];
    }
    DDLogCVerbose(@"upload test model %@",dicMode);
    NSDictionary *dicBody = @{@"userAirMode":dicMode,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_SET_DEV_MODEL(selectedAirDevice.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         
         DDLogCVerbose(@"--->uploadOpenAcModel response data: %@", [MainDelegate parseJsonData:data]);
         
         if([[self parentViewController] isKindOfClass:[AirDeivceManageViewController class]])
         {
             AirDeivceManageViewController *ac = (AirDeivceManageViewController *)[self parentViewController];
             [ac openOpenModePage:^{
                 //[self backButtonOnClicked:nil];
             }];
             [self backButtonOnClicked:nil];
         }
         else if([self.parentViewController isKindOfClass:[AirConditionViewController class]])
         {
             AirConditionViewController *vc = (AirConditionViewController *)self.parentViewController;
             if([self.deviceType isEqualToString:kDeviceTypeAP])
             {
                 [vc changeApStatus];
             }
             else
             {
                 [vc downloadAirBoxModel:0];
                 [vc checkIsIncludeHeathly];
             }
             [self backButtonOnClicked:nil];
         }
         else if ([self.parentViewController isKindOfClass:[IntelligenceVCViewController class]])
         {
             IntelligenceVCViewController *vc = (IntelligenceVCViewController *)self.parentViewController;
             if([self.deviceType isEqualToString:kDeviceTypeAP])
             {
                 [vc changeApStatus];
             }
             else
             {
                 [vc downloadAirBoxModel:0];
             }
             [self backButtonOnClicked:nil];
         }
         else
         {
             [self backButtonOnClicked:nil];
         }
     }];
}

- (void)bindIRDevice
{
    DDLogFunction();
    IRDevice *device = isManualBind ? _bindIRDeviceList[dowloadIRCodeIndex] : self.autoStudyIrDevice;
    NSString *type = device.devType != nil ? device.devType : @"";
    NSString *brand = device.brand != nil ? device.brand : @"";
    NSString *model = device.devModel != nil ? device.devModel : @"";
    NSString *mac = selectedAirDevice.mac != nil ? selectedAirDevice.mac : @"";
    NSDictionary *dicDevice = @{@"brand":brand,@"devType":type,@"devModel":model};
    NSDictionary *dicBody = @{@"irdevice":dicDevice,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_DEV_BIND_IRDEV(mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
    {
        if(error)
        {
            [MainDelegate hiddenProgressHubInView:self.view];
            [self openView:bindFailure completion:^{
                [self closeView:isOpenedACByTestCode complttion:nil];
            }];
        }
        else
        {
            NSDictionary *result = [MainDelegate parseJsonData:data];
            result = isObject(result) ? result : nil;
            DDLogCVerbose(@"--->空气盒子绑定红外设备--->%@",result);
            if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
            {
                isAlreadyBind = NO;
                [self reDwonloadIrDevice];
            }
            else
            {
                if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 10107)
                {
                    isAlreadyBind = YES;
                    [self reDwonloadIrDevice];
                    return;
                }
                [MainDelegate hiddenProgressHubInView:self.view];
                [self openView:bindFailure completion:^{
                    [self closeView:isOpenedACByTestCode complttion:nil];
                }];
            }
        }
    }];
}

- (void)reDwonloadIrDevice
{
    DDLogFunction();
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [irDeviceManager loadIRDeviceBindOnAirDevice:selectedAirDevice.mac
                               completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC)
    {
        [MainDelegate hiddenProgressHubInView:self.view];
       if(isLoadSucceed)
       {
           DDLogCVerbose(@"== %@ ==",self.parentViewController);
           if([[self parentViewController] isKindOfClass:[AirConditionViewController class]])
           {
               AirConditionViewController *ac = (AirConditionViewController *)[self parentViewController];
               ac.arrBindIRDevice = array;
           }
           else if([[self parentViewController] isKindOfClass:[AirDeivceManageViewController class]])
           {
               AirDeivceManageViewController *ac = (AirDeivceManageViewController *)[self parentViewController];
               ac.curDeviceVC.arrBindedIRDevice = array;
               
           }
           else if([[self parentViewController] isKindOfClass:[IntelligenceVCViewController class]])
           {
               IntelligenceVCViewController *ac = (IntelligenceVCViewController *)[self parentViewController];
               ac.arrBindIRDevice = array;
           }
           
           [NotificationCenter postNotificationName:IRDevicesChangedNotification object:MainDelegate.curBindDevice.mac];
       }

        dispatch_async(dispatch_get_main_queue(), ^{
            if(isAlreadyBind)
            {
                tipsInBindSucceed.text = [self.deviceType isEqualToString:kDeviceTypeAC]?NSLocalizedString(@"已绑定空调",@"IRDeviceModelSelectionViewController.m"):NSLocalizedString(@"已绑定净化器",@"IRDeviceModelSelectionViewController.m");
            }
            else
            {
                tipsInBindSucceed.text = NSLocalizedString(@"配置成功",@"IRDeviceModelSelectionViewController.m");
            }
        });

        [self openView:bindSucceed completion:^{
            [self closeView:isOpenedACByTestCode complttion:nil];
        }];
   }];
}

- (void)setupTitleAndTips
{
    DDLogFunction();
    if ([self.deviceType isEqualToString:kDeviceTypeAP])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* manul= NSLocalizedString(@"净化器手动识别绑定", @"IRDeviceModelSelectionViewController.m");
            NSString* unmanul= NSLocalizedString(@"净化器识别绑定", @"IRDeviceModelSelectionViewController.m");
            titleInOpenAc.text = isManualBind ? manul : unmanul;
            titleInCheckAcStatus.text = isManualBind ? manul : unmanul;
            titleInAcNotOpenByControl.text = isManualBind ? manul : unmanul;
            titleInDownloadIrCode.text = isManualBind ? manul : unmanul;
            titleInSendIrCode.text = isManualBind ? manul : unmanul;
            titleInIsHearAcRing.text = isManualBind ? manul : unmanul;
            titleInBindSucceed.text = isManualBind ? manul : unmanul;
            titleInBindFailed.text = isManualBind ? manul : unmanul;
            titleInErrorView.text = isManualBind ? manul : unmanul;
            
            tipsInOpenAc.text = NSLocalizedString(@"使用净化器遥控器对净化器按开关键", @"IRDeviceModelSelectionViewController.m") ;
            tipsInCheckAcStatus.text = NSLocalizedString(@"净化器是否成功开机?",@"IRDeviceModelSelectionViewController.m");
            titleInAllAcList.text = NSLocalizedString(@"选择净化器",@"IRDeviceModelSelectionViewController.m");
            tipsInIsHearAcRing.text = NSLocalizedString(@"空气盒子已尝试开启净化器，请确认净化器是否开启?",@"IRDeviceModelSelectionViewController.m");
            tipsInBindFailed.text = NSLocalizedString(@"净化器识别绑定失败",@"IRDeviceModelSelectionViewController.m");
            
            titleInSendIrToAirBox.text = unmanul;
            titleInMatching.text = unmanul;
            titleInMatchFailed.text = unmanul;
            
            tips1InSendIrToAirBox.text = NSLocalizedString(@"请确保净化器和空气盒子连接电源",@"IRDeviceModelSelectionViewController.m");
            tips2InSendIrToAirBox.text = NSLocalizedString(@"并使用净化器遥控器对空气盒子按开关键",@"IRDeviceModelSelectionViewController.m");
        });
    }
    else
    {
        NSString* manul= NSLocalizedString(@"空调手动识别绑定", @"IRDeviceModelSelectionViewController.m");
        NSString* unmanul= NSLocalizedString(@"空调识别绑定", @"IRDeviceModelSelectionViewController.m");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            titleInOpenAc.text = isManualBind ? manul : unmanul;
            titleInCheckAcStatus.text = isManualBind ? manul : unmanul;
            titleInAcNotOpenByControl.text = isManualBind ? manul : unmanul;
            titleInDownloadIrCode.text = isManualBind ? manul : unmanul;
            titleInSendIrCode.text = isManualBind ? manul : unmanul;
            titleInIsHearAcRing.text = isManualBind ? manul : unmanul;
            titleInBindSucceed.text = isManualBind ? manul : unmanul;
            titleInBindFailed.text = isManualBind ? manul : unmanul;
            titleInErrorView.text = isManualBind ? manul : unmanul;
            
            tipsInOpenAc.text = NSLocalizedString(@"使用空调遥控器对空调按开关键",@"IRDeviceModelSelectionViewController.m");
            tipsInCheckAcStatus.text = NSLocalizedString(@"空调是否成功开机?",@"IRDeviceModelSelectionViewController.m");
            titleInAllAcList.text = NSLocalizedString(@"选择空调",@"IRDeviceModelSelectionViewController.m");
            tipsInIsHearAcRing.text = NSLocalizedString(@"空气盒子已尝试开启空调，是否听到空调响?",@"IRDeviceModelSelectionViewController.m");
            tipsInBindFailed.text = NSLocalizedString(@"空调识别绑定失败",@"IRDeviceModelSelectionViewController.m");
            
            titleInSendIrToAirBox.text = NSLocalizedString(@"空调识别绑定",@"IRDeviceModelSelectionViewController.m");
            titleInMatching.text = NSLocalizedString(@"空调识别绑定",@"IRDeviceModelSelectionViewController.m");
            titleInMatchFailed.text = NSLocalizedString(@"空调识别绑定",@"IRDeviceModelSelectionViewController.m");
            
            tips1InSendIrToAirBox.text = NSLocalizedString(@"请确保空调和空气盒子连接电源",@"IRDeviceModelSelectionViewController.m");
            tips2InSendIrToAirBox.text = NSLocalizedString(@"并使用空调遥控器对空气盒子按开关键",@"IRDeviceModelSelectionViewController.m");
        });
    }
}

- (void)customTableview:(UITableView *)tableView
{
    DDLogFunction();
    //Set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
    
    /*
    //Set the offset cell separator
    BOOL isSystemVersionIsIos7 = [UIDevice isSystemVersionOnIos7];
    if (isSystemVersionIsIos7) {
        [acTableView setSeparatorInset:UIEdgeInsetsZero];
    }
     */
}

- (void)startDrawCircle
{
    DDLogFunction();
    if(isCancelDownload)return;
    tipsInSendIrCode.text = NSLocalizedString(@"正在发送开机命令", @"IRDeviceModelSelectionViewController.m") ;
    cancelBtnInSendIrCode.hidden = isManualBind ? NO : YES;
    lineInSendIrCode.hidden = isManualBind ? NO : YES;
    if (circleView == nil)
    {
        float height = self.view.height > 480 ? 189: 129;
        circleView = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(80, height, 160, 160) type:kRMClosedIndicator];
        [circleView setBackgroundColor:[UIColor clearColor]];
        [circleView setStrokeColor:[UIColor colorWithRed:120/255.0f green:189/255.0f blue:120/255.0f alpha:1]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [sendTestIRCode addSubview:circleView];
        });
        [circleView loadIndicator];
    }
    [circleView updateWithTotalBytes:100 downloadedBytes:0];
    [circleView setIndicatorAnimationDuration:2.0];
    [circleView updateWithTotalBytes:100 downloadedBytes:100];
}

- (void)updateUIInStep7:(uSDKErrorConst)result
{
    DDLogFunction();
    if(isCancelDownload)return;
    cancelBtnInSendIrCode.hidden = YES;
    lineInSendIrCode.hidden = YES;
    tipsInSendIrCode.text = NSLocalizedString(@"发送开机命令成功", @"IRDeviceModelSelectionViewController.m") ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(isCancelDownload)return;
        [self openView:isOpenedACByTestCode completion:^{
            [self closeView:sendTestIRCode complttion:nil];
            cancelBtnInSendIrCode.hidden = NO;
            lineInSendIrCode.hidden = NO;
        }];
    });
    
    /* 6.17 对应 redmine 3220
    if(result == RET_USDK_OK)
    {
        tipsInSendIrCode.text = @"发送开机命令成功";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(isCancelDownload)return;
            [self openView:isOpenedACByTestCode completion:^{
                [self closeView:sendTestIRCode complttion:nil];
                cancelBtnInSendIrCode.hidden = NO;
                lineInSendIrCode.hidden = NO;
            }];
        });
    }
    else
    {
        tipsInSendIrCode.text = @"发送开机命令失败";
        if(isManualBind)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(isCancelDownload)return;
                dowloadIRCodeIndex++;
                if ( deviceCount > dowloadIRCodeIndex)
                {
                    [self openView:downloadIRCode completion:^{
                        [self closeView:sendTestIRCode complttion:nil];
                        cancelBtnInSendIrCode.hidden = NO;
                        lineInSendIrCode.hidden = NO;
                    }];
                    [self setDeviceNameWithIndex:selectedIRDeviceIdx];
                    //        [self irCodeDownloaded];
                    [self downloadIRCode:nil];
                }
                else
                {
                    [self openView:bindFailure completion:^{
                        [self closeView:sendTestIRCode complttion:nil];
                        cancelBtnInSendIrCode.hidden = NO;
                        lineInSendIrCode.hidden = NO;
                    }];
                }
            });
        }
        else
        {
            [self openView:matchFailed completion:^{
                [self closeView:sendTestIRCode complttion:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cancelBtnInSendIrCode.hidden = NO;
                    lineInSendIrCode.hidden = NO;
                });
            }];
        }
    }
     */
}

- (void)openView:(UIView *)view completion:(AnimationCompletionHandler)animteComplete
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        view.frame = _baseview.frame;
        view.alpha = 0;
        [UIView animateWithDuration:0.3f animations:^{
            view.alpha = 1;
            [self.view addSubview:view];
        }completion:^(BOOL finished){
            if(finished)
            {
                if(animteComplete)
                {
                    animteComplete();
                }
            }
        }];
    });
}

- (void)closeView:(UIView *)view complttion:(AnimationCompletionHandler)animteComplete
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f animations:^{
            view.alpha = 0;
        }completion:^(BOOL finished){
            if(finished)
            {
                [view removeFromSuperview];
                if(animteComplete)
                {
                    animteComplete();
                }
            }
        }];
    });
}

- (void)setDeviceNameWithIndex:(int)index
{
    DDLogFunction();
    NSDictionary *dictBrand = _IRDeviceTitles[index];
    NSArray *arrModel = dictBrand[kModelString];
    NSDictionary *dictModel = arrModel[dowloadIRCodeIndex];
    IRDevice *device = dictModel[kDeviceString];
    NSString *tips = [[NSString alloc] init];
//    NSString *tips = [NSString stringWithFormat:@"空气盒子正在下载空调%@%@信息...",device.brandName,device.devModelName];
    //=-------------ybyao----------------------
    if ([MainDelegate isLanguageEnglish]) {
        tips = [NSString stringWithFormat:@"Downloading air condition information of %@%@...",device.brandName,device.devModelName];
    }
    else{
        tips = [NSString stringWithFormat:@"空气盒子正在下载空调%@%@信息...",device.brandName,device.devModelName];
    }
    if(![self.deviceType isEqualToString:kDeviceTypeAC])
    {
         if ([MainDelegate isLanguageEnglish]) {
             tips = [NSString stringWithFormat:@"Downloading air purifier information of %@%@...",device.brandName,device.devModelName];
         }
         else{
              tips = [NSString stringWithFormat:@"空气盒子正在下载空气净化器%@%@信息...",device.brandName,device.devModelName];
         }
    }
    tipsInDownloadIrCode.text = tips;
    //-----------ybyao----------
}

#pragma mark - IBAction Methods

- (IBAction)completeBind:(id)sender
{
    DDLogFunction();
    if(isAlreadyBind)
    {
        [self backButtonOnClicked:nil];
    }
    else
    {
        if ([self.parentViewController isKindOfClass:[DeviceManagementViewController class]])
        {
            [self reloadDeviceMangementView];
        }
        [self uploadOpenAcModel];
    }
}

- (IBAction)backButtonOnClicked:(id)sender
{
    DDLogFunction();
    
    /*
    if ([self.parentViewController isKindOfClass:[AirDeviceBindViewController class]]) {
        AirDeviceBindViewController *ac = (AirDeviceBindViewController *)self.parentViewController;
        [ac completeInStep4:sender];
        [ac.view removeFromSuperview];
        [ac removeFromParentViewController];
    }
     */
    [self stopCountStudyWaitTime];
    dispatch_async(dispatch_queue_create("CloseStudyStatusWhenBack", NULL), ^{
        [self openAirBoxStudyModel:NO];
    });
    
   
    [self removeAutoStudyNotification];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });
}

- (void)reloadDeviceMangementView
{
    DDLogFunction();
    [NotificationCenter postNotificationName:AirDeviceRemovedNotification object:nil];
    DeviceManagementViewController *vc = (DeviceManagementViewController *)self.parentViewController;
    [vc downloadIrDevice];
}

- (IBAction)sendIrByControlNext:(id)sender
{
    DDLogFunction();
    [self openView:matchingView completion:^{
        isInMatchingView = YES;
        [self closeView:sendIrToAirBox complttion:nil];
        if(self.autoStudyCode)
        {
            [self matchAcBrandFromServer];
        }
        else
        {
            [self performSelector:@selector(checkMatchingStatus) withObject:nil afterDelay:30.0f];
        }
    }];
}

- (IBAction)enterManual:(id)sender
{
    DDLogFunction();
    isManualBind = YES;
    [self setupTitleAndTips];
    
    [self customTableview:acTableView];
    [self downloadIRDeviceList:YES];
    
    /** 5.23
    [self closeView:matchFailed complttion:nil];
     **/
}

- (IBAction)notFindControl:(id)sender
{
    DDLogFunction();
    [self stopCountStudyWaitTime];
    dispatch_async(dispatch_queue_create("CloseStudyStatus", NULL), ^{
        [self openAirBoxStudyModel:NO];
    });
    isManualBind = YES;
    [self setupTitleAndTips];
    [self customTableview:acTableView];
    [self downloadIRDeviceList:NO];
}

- (IBAction)notEnteManual:(id)sender
{
    DDLogFunction();
    [self backButtonOnClicked:nil];
}

- (IBAction)nextInOpenAc:(id)sender
{
    DDLogFunction();
    [self openView:isACOpendByControl completion:nil];
}

- (IBAction)backInCheckAcStatus:(id)sender
{
    DDLogFunction();
    [self closeView:isACOpendByControl complttion:nil];
}

- (IBAction)acOpenedByControl:(id)sender
{
    DDLogFunction();
    [self customTableview:acTableView];
    [self downloadIRDeviceList:NO];
}

- (IBAction)acNotOpenByControl:(id)sender
{
    DDLogFunction();
    [self openView:acNotOpendByControl completion:nil];
}

- (IBAction)backInAcNotOpend:(id)sender
{
    DDLogFunction();
    [self closeView:acNotOpendByControl complttion:nil];
}

- (IBAction)cancelInAllAcList:(id)sender
{
    DDLogFunction();
    [self backButtonOnClicked:sender];
}

- (IBAction)cancelInDownloadIrCode:(id)sender
{
    DDLogFunction();
    isCancelDownload = YES;
    [self openView:allACList completion:^{
        [self closeView:downloadIRCode complttion:nil];
        progressView.width = 0;
    }];
}

- (IBAction)cancelInSendIrCode:(id)sender
{
    DDLogFunction();
    isCancelDownload = YES;
//    [self closeView:sendTestIRCode complttion:nil];
    [self openView:allACList completion:^{
        [self closeView:sendTestIRCode complttion:nil];
        progressView.width = 0;
        
    }];
}

- (IBAction)hearAcRing:(id)sender
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    [self bindIRDevice];
}

- (IBAction)notHearAcRing:(id)sender
{
    DDLogFunction();
//    [self openView:bindFailure completion:nil];
    isCancelDownload = NO;
    if(isManualBind){
        dowloadIRCodeIndex++;
        if ( deviceCount > dowloadIRCodeIndex)
        {
            [self openView:downloadIRCode completion:^{
                [self closeView:isOpenedACByTestCode complttion:nil];
            }];
            [self setDeviceNameWithIndex:selectedIRDeviceIdx];
    //        [self irCodeDownloaded];
            [self downloadIRCode:nil];
        }
        else
        {
            [self openView:bindFailure completion:^{
                [self closeView:isOpenedACByTestCode complttion:nil];
            }];
        }
    }
    else
    {
        [self openView:matchFailed completion:^{
            [self closeView:isOpenedACByTestCode complttion:nil];
        }];
    }
}

- (IBAction)reTryInErrorView:(id)sender
{
    DDLogFunction();
    [self closeView:downloadError complttion:^{
        [self openView:downloadIRCode completion:^{
            [self downloadIRCode:nil];
        }];
    }];
}

- (IBAction)cancelInErrorView:(id)sender
{
    DDLogFunction();
    [self backButtonOnClicked:sender];
}

- (IBAction)sendFeedBack
{
    DDLogFunction();
    FeedbackViewController *feedBackController = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
    feedBackController.view.frame = self.view.frame;
    feedBackController.parentContoller = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        feedBackController.view.alpha = 0.0;
        [MainDelegate.window addSubview:feedBackController.view];
        [UIView animateWithDuration:0.3 animations:^{
            feedBackController.view.alpha = 1.0;
            [self addChildViewController:feedBackController];
         }];
    });
}

- (IBAction)irStudy:(id)sender
{
    DDLogFunction();
    CustomModelViewController *irStudy = [[CustomModelViewController alloc] initWithNibName:@"CustomModelViewController" bundle:nil];
    irStudy.macID = self.selectedAirDevice.mac;
    irStudy.view.frame = self.view.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MainDelegate.window addSubview:irStudy.view];
        irStudy.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            irStudy.view.alpha = 1.0;
            [self addChildViewController:irStudy];
        }];
    });
}

- (IBAction)notFindInAllACList:(id)sender
{
    DDLogFunction();
    [self openView:bindFailure completion:^{
        [self closeView:allACList complttion:nil];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_IRDeviceTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"IRDeviceCell";
    IRDeviceCell *cell = (IRDeviceCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"IRDeviceCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = (IRDeviceCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.downloadButton.tag = indexPath.row+1000;
    [cell.downloadButton addTarget:self action:@selector(prepareDownloadIRCode:) forControlEvents:UIControlEventTouchUpInside];
    cell.lblName.text =NSLocalizedString([[_IRDeviceTitles objectAtIndex:indexPath.row] valueForKey:kBrandString],@"IRDeviceModelSelectionViewController1.m");//ybyao
    return cell;
}

#pragma mark - Alert Box Delegate

- (void)alertBoxOkButtonOnClicked
{
    [self notFindControl:nil];
}


@end
