//
//  IntelligenceViewController.m
//  AirManager
//

#import "IntelligenceVCViewController.h"
#import "IntellAirAdjustCell.h"
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
#import "SegmentControl.h"
#import "DDCoutourView.h"
#import "UserLoginedInfo.h"
#import "AlertBoxViewController.h"


#define kHeaderUnSelectBgColor  [UIColor colorWithHex:0x9e9e9e alpha:1.0f]
#define kHeaderSelectedBgColor  [UIColor colorWithHex:0x4abb29 alpha:1.0f]

typedef enum
{
    kCellTemperatureType = 0,
    kCellACModuleType,
    kCellWindyType,
    kCellPM25Type,
}CellType;

@interface IntelligenceVCViewController ()
{
    
    BOOL                        isLeavePage;
    BOOL                        apOpened;
    BOOL                        acOpened;
    BOOL                        sleepOpened;
    SegmentControl              *segControlType;
    UITableView                 *acTableView;

    AirPurgeModel               *curPurgeModel;     //current data
    AirPurgeModel               *beforePurgeModel;     //current data
    NSOperationQueue            *acOptionQueue;
    
    NSDictionary                *dicCurverData;
}

@property (nonatomic, strong) UIView *baseview;
@property (nonatomic, strong)AirPurgeModel  *curPurgeModel;
@property (nonatomic, strong)AirPurgeModel  *beforePurgeModel;
@property (nonatomic, strong)NSOperationQueue   *acOptionQueue;

@end

@implementation IntelligenceVCViewController

#define CoolImg         @"04-制冷.png"
#define HotImg          @"制热-640.png"
#define JieNengImg      @"ic_jineng.png"
#define ShuShiImg       @"ic_shushi.png"

#define kSummerKey          @"Summer"
#define kWinterKey          @"Winter"
#define kTitleStringKey     @"TitleString"
#define kContentStringKey   @"ContentString"
#define kOldManRoomKey      @"OldManRoom"
#define kChildRoomKey       @"ChildRoom"
#define kManRoomKey         @"ManRoom"
#define kWoManRoomKey       @"WoManRoom"


@synthesize arrBindIRDevice;
@synthesize curPurgeModel;
@synthesize acOptionQueue;
@synthesize beforePurgeModel;


- (void)dealloc
{
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
    
    [self setupRootView:_baseview];
    
    isLeavePage = NO;
    _isFromSleepModule = NO;
    
    [self createDicCurverData];
    
    self.curPurgeModel = [[AirPurgeModel alloc] init];
    self.beforePurgeModel = [[AirPurgeModel alloc] init];
    
    self.acOptionQueue = [[NSOperationQueue alloc] init];
    
    [self customTableView];

    [self performSelectorInBackground:@selector(downloadAirBoxModel:) withObject:0];
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)createDicCurverData
{
    DDLogFunction();
    dicCurverData = @{
                      kWinterKey :
                            @{
                              kManRoomKey:    @[@21,@22,@23,    @24,@24,    @24,@24,@23,    @23],
                              kWoManRoomKey:  @[@22,@23,@24,    @25,@25,    @25,@25,@24,    @24],
                              kOldManRoomKey: @[@21,@23,@24,    @24,@25,    @25,@25,@24,    @24],
                              kChildRoomKey:  @[@19,@20,@22,    @23,@23,    @23,@23,@22,    @24]
                              },
                      kSummerKey :
                            @{
                              kManRoomKey:    @[@24,@25,@26,    @27,@27,    @27,@27,@27,    @27],
                              kWoManRoomKey:  @[@25,@26,@27,    @27,@28,    @28,@28,@27,    @27],
                              kOldManRoomKey: @[@25,@26,@27,    @27,@28,    @28,@27,@27,    @27],
                              kChildRoomKey:  @[@23,@24,@25,    @26,@26,    @26,@26,@26,    @26]
                              },
                      kTitleStringKey :
                            @{
                              kManRoomKey:    @"成年男性",
                              kWoManRoomKey:  @"成年女性",
                              kOldManRoomKey: @"老人房间",
                              kChildRoomKey:  @"儿童房间"
                              },
                      kContentStringKey :
                            @{
                              kManRoomKey:  @"    睡眠曲线按照人体睡眠不同的深浅阶段,设置不同的温度,协助人体入睡、熟睡和逐步清醒。\n    男性生理对对睡眠温度要求不高,确保深度睡眠环境温度稳定,拥有更高睡眠质量。",
                              kWoManRoomKey:@"    睡眠曲线按照人体睡眠不同的深浅阶段,设置不同的温度,协助人体入睡、熟睡和逐步清醒。\n    女性特殊生理机制,房间温度需相对略高,并保持较低变化率。",
                            kOldManRoomKey: @"    睡眠曲线按照人体睡眠不同的深浅阶段,设置不同的温度,协助人体入睡、熟睡和逐步清醒。\n    老年人大脑皮质功能减退,新陈代谢慢,睡眠时间相对减少,老年曲线根据体质区别,设计房内温度曲线,打造最适环境。",
                              kChildRoomKey:@"    睡眠曲线按照人体睡眠不同的深浅阶段,设置不同的温度,协助人体入睡、熟睡和逐步清醒。\n    儿童体温调节中枢功能发育中,随温度的变化调节慢,儿童曲线变化率低,保证房间温度稳定,确保宝宝睡眠稳定。"
                              }
                      };
}
#pragma mark -
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)customTableView
{
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
                if([mode integerValue] == 4 ||
                   [mode integerValue] == 5 )
                {
                    [curPurgeModel parserAirModel:airMode];
                    curPurgeModel.onOff = [curPurgeModel.acflag boolValue] ? IRDeviceOpen :IRDeviceClose;
                    curPurgeModel.apOnOff = [curPurgeModel.apflag boolValue] ? IRDeviceOpen :IRDeviceClose;
                    beforePurgeModel = [curPurgeModel copy];
                }
                else if([mode integerValue] == 0 ||
                        [mode integerValue] == 3)
                {
                    [beforePurgeModel parserAirModel:airMode];
                    curPurgeModel = [beforePurgeModel copy];
                    curPurgeModel.apflag = @NO;
                    curPurgeModel.acflag = @NO;
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
                     if([mode integerValue] == 4 ||
                        [mode integerValue] == 5 )
                     {
                         [curPurgeModel parserAirModel:airMode];
                         curPurgeModel.onOff = [curPurgeModel.acflag boolValue] ? IRDeviceOpen :IRDeviceClose;
                         curPurgeModel.apOnOff = [curPurgeModel.apflag boolValue] ? IRDeviceOpen :IRDeviceClose;
                         beforePurgeModel = [curPurgeModel copy];
                     }
                     else if([mode integerValue] == 3 ||
                             [mode integerValue] == 0)
                     {
                         [beforePurgeModel parserAirModel:airMode];
                         curPurgeModel = [beforePurgeModel copy];
                         curPurgeModel.apflag = @NO;
                         curPurgeModel.acflag = @NO;
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

- (void)loadCurrentModel
{
    DDLogFunction();
    if(isLeavePage)return;
    
    if(curPurgeModel.modeIndex.integerValue == 4)
    {
        acOpened = [[curPurgeModel acflag] boolValue];
        apOpened = [[curPurgeModel apflag] boolValue];
        sleepOpened = NO;
    }
    
    if(curPurgeModel.modeIndex.integerValue == 5)
    {
        sleepOpened = YES;
        acOpened = NO;
        apOpened = NO;
    }
    if(!curPurgeModel.pm25 || curPurgeModel.pm25.length ==0)
    {
        curPurgeModel.pm25 = @"50";
    }
    if(!curPurgeModel.temperature || curPurgeModel.temperature.length == 0)
    {
        curPurgeModel.temperature = @"26";
    }
    if(!curPurgeModel.acMode  || curPurgeModel.temperature.length == 0)
    {
        curPurgeModel.acMode = curPurgeModel.acModelList[1];
    }
    if(!curPurgeModel.windSpeed || curPurgeModel.windSpeed.length == 0)
    {
        curPurgeModel.windSpeed = curPurgeModel.windSpeedList[0];
    }
    
    // 睡眠模式
    if(curPurgeModel.modeIndex.integerValue == 5)
    {
        [segControlType setSelectedSegmentIndex:1];
    }
    else
    {
        [segControlType setSelectedSegmentIndex:0];
    }
    
    if(!MainDelegate.isCustomer)
    {
        if(curPurgeModel.modeIndex.integerValue == 4)
        {
            if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAP])
            {
                curPurgeModel.apflag = @NO;
                curPurgeModel.apOnOff = IRDeviceClose;
                apOpened= NO;
            }
            
            if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
            {
                curPurgeModel.acflag = @NO;
                curPurgeModel.onOff = IRDeviceClose;
                acOpened= NO;
            }
        }
        else if(curPurgeModel.modeIndex.integerValue == 5)
        {
            if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
            {
                sleepOpened = NO;
                curPurgeModel.onOff = IRDeviceClose;
            }
        }
    }
    
    [self reloadTableView];
}


- (void)reloadTableView
{
    if(isLeavePage)return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [acTableView reloadData];
    });
}



#pragma mark -
// =======================================================================
#pragma mark - 主界面布局函数
// =======================================================================
- (void)setupRootView:(UIView *)viewParent
{
    // 父窗口尺寸
    CGRect parentFrame = [viewParent frame];
    
    // 子窗口高宽
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = parentFrame.size.height;
    
    spaceYStart += 44;
    
    // =======================================================================
    // 单程往返TabControl
    // =======================================================================
    // 创建TabControl
    UIView *segControlBGView = [[UIView alloc] initWithFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, 42)];
    [segControlBGView setBackgroundColor:[UIColor whiteColor]];
    
    segControlType = [[SegmentControl alloc] initWithFrame:CGRectMake(46, 7, segControlBGView.frame.size.width - 2*46, segControlBGView.frame.size.height - 2*7)];
    [segControlType appendSegmentWithTitle:@"个人模式"];
    [segControlType appendSegmentWithTitle:@"睡眠模式"];
    [segControlType setLeftImage:[UIImage imageNamed:@"buttonzuo.png"]];
    [segControlType setLeftSelectedImage:[UIImage imageNamed:@"buttonzuo-down.png"]];
    [segControlType setRightImage:[UIImage imageNamed:@"buttonyou.png"]];
    [segControlType setRightSelectedImage:[UIImage imageNamed:@"buttonyou-down.png"]];
    [segControlType setSelectedSegmentIndex:0];
    [segControlType setSegControlTitleButtonColor:0x4abb29 alpha:1.0f];
    [segControlType setSegControlTitleButtonSelectColor:0xffffff alpha:1.0f];
    [segControlType addTarget:self action:@selector(changeTabValue:) forControlEvents:UIControlEventValueChanged];
    [segControlBGView addSubview:segControlType];
    
    [viewParent addSubview:segControlBGView];
    
    spaceYStart += 42;

    // =======================================================================
    // 搜索结果TableView
    // =======================================================================
    // 创建TableView
    UITableView *tableViewResultTmp = [[UITableView alloc] initWithFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, spaceYEnd -spaceYStart) style:UITableViewStylePlain];
    [tableViewResultTmp setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableViewResultTmp setBackgroundColor:[UIColor colorWithHex:0xefefef alpha:1.0f]];
    [tableViewResultTmp setBackgroundView:nil];
    [tableViewResultTmp setDataSource:self];
    [tableViewResultTmp setDelegate:self];
    
    acTableView = tableViewResultTmp;
    
    [viewParent addSubview:tableViewResultTmp];

}



- (void)setAirAdjustCell:(IntellAirAdjustCell *)cell withType:(CellType)type isHightLight:(BOOL)isHightLight action:(SEL)action
{
    DDLogFunction();
        [cell.leftBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.rightBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
        [cell.leftBtn setExclusiveTouch:YES];
        [cell.rightBtn setExclusiveTouch:YES];
        switch (type)
        {
            case kCellTemperatureType:
            {
                cell.cellIcon.image = [UIImage imageNamed:@"02-室内温度.png"];
                cell.lblContent.text = curPurgeModel.temperature;
                cell.cellIcon.frame = CGRectMake(25, 21 , 31, 31);
            }
                break;
            case kCellACModuleType:
            {
                NSString *img = [curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]]?CoolImg:HotImg;
                cell.cellIcon.image = [UIImage imageNamed:img];
                cell.lblContent.text = curPurgeModel.acMode;
                cell.cellIcon.frame = CGRectMake(25, 21 , 31, 31);
            }
                break;
            case kCellWindyType:
            {
                cell.cellIcon.image = [UIImage imageNamed:@"03-风速.png"];
                cell.lblContent.text = curPurgeModel.windSpeed;
                if ([MainDelegate isLanguageEnglish]) {
                    cell.lblContent.font=[cell.lblContent.font fontWithSize:14];
                }
                cell.cellIcon.frame = CGRectMake(25, 21 , 31, 31);
            }
                break;
            case kCellPM25Type:
            {
                cell.cellIcon.image = [UIImage imageNamed:@"PM25.png"];
                cell.lblContent.text = curPurgeModel.pm25;
                cell.cellIcon.frame = CGRectMake(31, (cell.frame.size.height - 15) /2 , 57, 15);
            }
                break;
            default:
                break;
        }
        
        if(isHightLight)
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
        }
        else
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        cell.leftBtn.hidden = NO;
        cell.rightBtn.hidden = NO;
        [cell.leftBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [cell.rightBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}


- (void)setupHeaderViewSubs:(UIView *)parentView withSelect:(BOOL)isSelect withTitle:(NSString *) title action:(SEL)action
{
    DDLogFunction();
    NSUInteger startX = 26;
    NSUInteger startY = 15;
    NSUInteger endY = parentView.frame.size.height;
    NSUInteger endX = parentView.frame.size.width - 17;
    
    [parentView setBackgroundColor:[UIColor colorWithHex:0xefefef alpha:1.0f]];
    
    UIImageView *imageBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, parentView.frame.size.width, endY - startY )];
    if(isSelect){
        imageBg.backgroundColor = kHeaderSelectedBgColor;
    }else{
        imageBg.backgroundColor = kHeaderUnSelectBgColor;
    }
    [parentView addSubview:imageBg];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, 200,endY - startY)];
    [labelTitle setText:title];
    [labelTitle setTextColor:[UIColor whiteColor]];
    [labelTitle setFont: kCurNormalFontOfSize(18)];
    [labelTitle setBackgroundColor:[UIColor clearColor]];
    
    [parentView addSubview:labelTitle];
    
    UIButton *onOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
    onOffButton.frame = CGRectMake(endX- 57, 28, 57, 23);
    [onOffButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    NSString *imgName = isSelect ? @"08-开.png" : @"08-关.png";
    [onOffButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [onOffButton setExclusiveTouch:YES];
    
    [parentView addSubview:onOffButton];
}

// 创建空View的子界面
- (void)setupCellNoteSubs:(UIView *)viewParent withNote:(NSString *)noteStr
{
    // 移除子view
    for(UIView *subview in [viewParent subviews])
    {
        if (subview != nil)
        {
            [subview removeFromSuperview];
        }
    }
    
    // 父窗口属性
    CGRect parentFrame = [viewParent frame];
    
    // 子窗口高宽
    NSInteger spaceXStart = 0;
    NSInteger spaceXEnd = parentFrame.size.width;
    
    // 间隔
    spaceXStart += 28;
    spaceXEnd -=  24;
    
    // =====================================================
    // 内容视图 View
    // =====================================================
    // 创建视图
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setFrame:CGRectMake(spaceXStart, 8, 13, 13)];
    [imageView setImage:[UIImage imageNamed:@"tishi.png"]];
    [viewParent addSubview:imageView];
    
    noteStr = [noteStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    spaceXStart += 13;
    spaceXStart += 8;
    UILabel *noteLabel = [[UILabel alloc] init];
    [noteLabel setFrame:CGRectMake(spaceXStart,0, spaceXEnd -spaceXStart, viewParent.frame.size.height)];
    [noteLabel setFont:kCurNormalFontOfSize(12)];
    [noteLabel setText:noteStr];
    [noteLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [noteLabel setNumberOfLines:0];
    [noteLabel setTextAlignment:NSTextAlignmentLeft];
    [noteLabel setUserInteractionEnabled:NO];
    [noteLabel setTextColor:[UIColor colorWithHex:0x757171 alpha:0.7f]];
    
    // 保存
    [viewParent addSubview:noteLabel];
}


- (void)createViewCoutourView : (NSString *)type
{
    DDLogFunction();
    // 移除子view
    for(UIView *subview in [viewCurveContent subviews])
    {
        if (subview != nil)
        {
            [subview removeFromSuperview];
        }
    }
    
    DDCoutourView *coutourView = [[DDCoutourView alloc] initWithFrame:CGRectMake(0,0, viewCurveContent.frame.size.width, viewCurveContent.frame.size.height)];
    [coutourView setXEdgeMargin:10];
    [coutourView setYEdgeMargin:7];
    coutourView.XValues = @[
                            @"22:00",
                            @"23:00",
                            @"0:00",
                            @"1:00",
                            @"2:00",
                            @"3:00",
                            @"4:00",
                            @"5:00",
                            @"6:00"
                            ];
    coutourView.YValues = @[
                            @"32",
                            @"30",
                            @"28",
                            @"26",
                            @"24",
                            @"22",
                            @"20",
                            @"18"
                            ];
 
    coutourView.pointValues = [self getCurverDataForOne:type];
    coutourView.fillColors = @[
                               [UIColor colorWithRed:1 green:0.9098 blue:0.8942 alpha:1],
                               [UIColor whiteColor]
                               ];
    
    coutourView.lineColor = [UIColor colorWithRed:0.9843 green:0.2980 blue:0.1921 alpha:1];
    
    [viewCurveContent addSubview:coutourView];
    
    labelCureContent.text =  [[dicCurverData objectForKey: kContentStringKey] objectForKey:type];
    labelCureTitle.text = [[dicCurverData objectForKey:kTitleStringKey] objectForKey:type];
    
    if([type isEqualToString:kOldManRoomKey])
    {
        BOOL isUnSelect = ![curPurgeModel.sleepModeId isEqualToString:@"1"];
        if(sleepOpened)
        {
            btnApply.enabled = isUnSelect;
        }
        else
        {
            btnApply.enabled = NO;
        }
        if(isUnSelect)
        {
            [btnApply setTitle:@"应用" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用" forState:UIControlStateHighlighted];
        }
        else
        {
            [btnApply setTitle:@"应用中" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用中" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用中" forState:UIControlStateHighlighted];
        }
        btnApply.tag = 1;
    }
    else if([type isEqualToString:kChildRoomKey])
    {
        BOOL isUnSelect = ![curPurgeModel.sleepModeId isEqualToString:@"2"];
        if(sleepOpened)
        {
            btnApply.enabled = isUnSelect;
        }
        else
        {
            btnApply.enabled = NO;
        }
        if(isUnSelect)
        {
            [btnApply setTitle:@"应用" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用" forState:UIControlStateHighlighted];
        }
        else
        {
            [btnApply setTitle:@"应用中" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用中" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用中" forState:UIControlStateHighlighted];
        }
        btnApply.tag = 2;
        
    }
    else if([type isEqualToString:kManRoomKey])
    {
        
        BOOL isUnSelect = ![curPurgeModel.sleepModeId isEqualToString:@"3"];
        if(sleepOpened)
        {
            btnApply.enabled = isUnSelect;
        }
        else
        {
            btnApply.enabled = NO;
        }
        
        btnApply.tag = 3;
        if(isUnSelect)
        {
            [btnApply setTitle:@"应用" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用" forState:UIControlStateHighlighted];
        }
        else
        {
            [btnApply setTitle:@"应用中" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用中" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用中" forState:UIControlStateHighlighted];
        }
    }
    else if([type isEqualToString:kWoManRoomKey])
    {
        BOOL isUnSelect = ![curPurgeModel.sleepModeId isEqualToString:@"4"];
        if(sleepOpened)
        {
            btnApply.enabled = isUnSelect;
        }
        else
        {
            btnApply.enabled = NO;
        }
        if(isUnSelect)
        {
            [btnApply setTitle:@"应用" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用" forState:UIControlStateHighlighted];
        }
        else
        {
            [btnApply setTitle:@"应用中" forState:UIControlStateNormal];
            [btnApply setTitle:@"应用中" forState:UIControlStateDisabled];
            [btnApply setTitle:@"应用中" forState:UIControlStateHighlighted];
        }
        btnApply.tag = 4;
    }
}

-(NSArray *)getCurverDataForOne:(NSString *)type
{
    DDLogFunction();
    NSArray *arrReturn = [[NSArray alloc] init];
    if([curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]])
    {
        arrReturn = [[dicCurverData objectForKey:kSummerKey] objectForKey:type];
    }
    else
    {
        arrReturn = [[dicCurverData objectForKey:kWinterKey] objectForKey:type];

    }
    return arrReturn;
}
#pragma mark Table view data source
- (void)changeTabValue:(id)sender
{
    [self reloadTableView];
}

- (IBAction)gobackDone:(id)sender{
    DDLogFunction();
    isLeavePage = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)oldManRoomDone:(id)sender
{
    DDLogFunction();
    [self createViewCoutourView:kOldManRoomKey];
    [self openView:viewCurve completion:nil];
}

- (IBAction)childRoomDone:(id)sender
{
    DDLogFunction();
    [self createViewCoutourView:kChildRoomKey];
    [self openView:viewCurve completion:nil];
}

- (IBAction)manRoomDone:(id)sender
{
    DDLogFunction();
    [self createViewCoutourView:kManRoomKey];
    [self openView:viewCurve completion:nil];
}

- (IBAction)womanRoomDone:(id)sender
{
    DDLogFunction();
    [self createViewCoutourView:kWoManRoomKey];
    [self openView:viewCurve completion:nil];
}
- (IBAction)converDone:(id)sender
{
    DDLogFunction();
    [self closeView:viewCurve completion:nil];
}

- (void)openView:(UIView *)view completion:(void(^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [view setViewY:_baseview.frame.size.height +_baseview.frame.origin.y];
        btnConver.hidden = NO;
        btnConver.alpha = 0.0f;
        [_baseview bringSubviewToFront:btnConver];
        [self.view addSubview:view];
        [UIView animateWithDuration:0.2 animations:^{
            [view setViewY:_baseview.frame.size.height +_baseview.frame.origin.y - view.frame.size.height];
            btnConver.alpha =0.5f;
        } completion:^(BOOL finished){
            if(finished && completion)
            {
                completion();
            }
        }];
    });
}

- (void)closeView:(UIView *)view completion:(void(^)())completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            [view setViewY:_baseview.frame.size.height +_baseview.frame.origin.y];
            btnConver.alpha = 0.0f;
        } completion:^(BOOL finished){
            [view removeFromSuperview];
            btnConver.hidden = YES;
            if(completion)
            {
                completion();
            }
        }];
    });
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

-(void)refreshSleepRoomImageView
{
    DDLogFunction();
    oldRunningImageView.hidden = ![curPurgeModel.sleepModeId isEqualToString:@"1"];
    childRuningImageView.hidden = ![curPurgeModel.sleepModeId isEqualToString:@"2"];
    manRuningImageView.hidden = ![curPurgeModel.sleepModeId isEqualToString:@"3"];
    womanRuningImageView.hidden = ![curPurgeModel.sleepModeId isEqualToString:@"4"];
}

- (BOOL)isOpenAcOrApByMannulModel
{
    if(!MainDelegate.isCustomer)
    {
        if(![MainDelegate isNetworkAvailable])
        {
            return NO;
        }
    }
    
    // 手动控制
    if([beforePurgeModel.modeIndex integerValue] == 0)
    {
        return ([beforePurgeModel.onOff isEqualToString:IRDeviceOpen] ||  [beforePurgeModel.apOnOff isEqualToString:IRDeviceOpen]);
    }
    return false;
}

#pragma mark - Button Action
- (void)startOrStopModel:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            _isFromSleepModule = NO;
            //没有绑定AP,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
    }
    
    if(!acOpened )
    {
        BOOL isneedRefresh  = NO;
        if([self isOpenAcOrApByMannulModel])
        {
            [AlertBox showWithMessage:@"您的设备正处于手动控制中，点击确定将开启恒温模式，同时关闭手动控制。" delegate:(id)self showCancel:YES withTag:1000];
        }
        else
        {
            if(sleepOpened)
            {
                [AlertBox showWithMessage:@"您的设备正处于睡眠模式控制，点击确定将开启恒温模式，同时关闭睡眠模式。" delegate:(id)self showCancel:YES withTag:1000];
            }
            else
            {
                isneedRefresh = YES;
            }
        }
        
        if(isneedRefresh)
        {
            acOpened = !acOpened;
            curPurgeModel.acflag = @YES;
            curPurgeModel.onOff = IRDeviceOpen;
            sleepOpened = NO;
            [self uploadAcModel:NO];
            
            [self reloadTableView];
        }
        
    }
    else
    {
        acOpened = !acOpened;
        curPurgeModel.acflag = @NO;
        curPurgeModel.onOff = IRDeviceClose;
        
        [self uploadAcModel:NO];
        
        [self reloadTableView];
    }
}

- (void)tempControl:(UIButton *)sender
{
    DDLogFunction();
    NSInteger index = 0;
    if([curPurgeModel.tempList containsObject:curPurgeModel.temperature])
    {
        index = [curPurgeModel.tempList indexOfObject:curPurgeModel.temperature];
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
        [self reloadTableView];
        [self uploadAcModel:NO];
    }
}

- (void)acModelControl:(UIButton *)sender
{
    DDLogFunction();
    NSInteger index = 0;
    if([curPurgeModel.acModelList containsObject:curPurgeModel.acMode])
    {
        index = [curPurgeModel.acModelList indexOfObject:curPurgeModel.acMode];
    }
    if(sender.tag == 0)
    {
        index--;
        if(index < 0)
        {
            index = curPurgeModel.acModelList.count -1;
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
    [self reloadTableView];
    [self uploadAcModel:NO];
}

- (void)windSpeedControl:(UIButton *)sender
{
    DDLogFunction();
    NSInteger index = 0;
    if([curPurgeModel.windSpeedList containsObject:curPurgeModel.windSpeed])
    {
        index = [curPurgeModel.windSpeedList indexOfObject:curPurgeModel.windSpeed];
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

    [self reloadTableView];
    [self uploadAcModel:NO];
}

- (void)changeApStatus
{
    apOpened = YES;
    [self reloadTableView];
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
    
    
    if(!apOpened )
    {
        BOOL isneedRefresh  = NO;
        if([self isOpenAcOrApByMannulModel])
        {
            [AlertBox showWithMessage:@"您的设备正处于手动控制中，点击确定将开启恒净模式，同时关闭手动控制。开启恒净模式前,务必确认净化器处于关闭状态。" delegate:(id)self showCancel:YES withTag:2000];
        }
        else
        {
            if(sleepOpened)
            {
                [AlertBox showWithMessage:@"您的设备正处于睡眠模式控制，点击确定将开启恒净模式，同时关闭睡眠模式。启恒净模式前,务必确认净化器处于关闭状态。" delegate:(id)self showCancel:YES withTag:2000];
            }
            else
            {
                [AlertBox showWithMessage:@"开启恒净模式前,务必确认净化器处于关闭状态。" delegate:(id)self showCancel:NO withTag:2000];
            }
        }
        if(isneedRefresh)
        {
            apOpened = !apOpened;
            curPurgeModel.apflag = @YES;
            curPurgeModel.apOnOff = IRDeviceOpen;
            sleepOpened = NO;
            [self uploadAcModel:NO];
            [self reloadTableView];
        }
        
    }
    else
    {
        apOpened = !apOpened;
        curPurgeModel.apOnOff = IRDeviceClose;
        curPurgeModel.apflag = @NO;
        
        [self uploadAcModel:NO];
        [self reloadTableView];
    }
}

-(void)pm25Control:(UIButton *)sender
{
    DDLogFunction();
    NSInteger pm25Value = curPurgeModel.pm25.integerValue;
    
    if(sender.tag == 0)
    {
        pm25Value-=5;
        if(pm25Value < 10)
        {
            pm25Value = 10;
        }
    }
    else
    {
        pm25Value+=5;
        if(pm25Value >= 200)
        {
            pm25Value = 200;
        }
    }
    
    curPurgeModel.pm25 = [NSString stringWithFormat:@"%d",pm25Value];
    
    [self reloadTableView];
    [self uploadAcModel:NO];
}

- (void)sleepControl:(UIButton *)sender
{
    DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        if(![Utility isBindedDevice:arrBindIRDevice withType:kDeviceTypeAC])
        {
            _isFromSleepModule = YES;
            //没有绑定AC,直接进入绑定;如果绑定了check红外码在进入此页面时候已经check完,不用再check
            [self bindIrDevice:kDeviceTypeAC];
            return;
        }
    }
    if(!sleepOpened)
    {
        BOOL isneedRefresh  = NO;
        if([self isOpenAcOrApByMannulModel])
        {
            [AlertBox showWithMessage:@"您的设备正处于手动控制中，点击确定将开启睡眠模式，同时关闭手动控制。" delegate:(id)self showCancel:YES withTag:3000];
        }
        else
        {
            if(acOpened || apOpened)
            {
                [AlertBox showWithMessage:@"您的设备正处于个人模式控制，点击确定将开启睡眠模式，同时关闭个人模式。" delegate:(id)self showCancel:YES withTag:3000];
            }
            else
            {
                isneedRefresh = YES;
            }
        }
        
        if(isneedRefresh)
        {
            sleepOpened = !sleepOpened;
            
            acOpened = NO;
            apOpened = NO;
            curPurgeModel.acflag = @NO;
            curPurgeModel.apflag = @NO;
            curPurgeModel.onOff = IRDeviceOpen;
            
            // 默认选择第一个房间模式
            if(!curPurgeModel.sleepModeId || curPurgeModel.sleepModeId.length == 0 || (curPurgeModel.sleepModeId.integerValue) < 1  || curPurgeModel.sleepModeId.integerValue > 4)
            {
                curPurgeModel.sleepModeId = @"1";
            }
            [self uploadAcModel:NO];
            
            [self reloadTableView];
        }
        
    }
    else
    {
        sleepOpened = !sleepOpened;
        
        curPurgeModel.onOff = IRDeviceClose;
        
        [self uploadAcModel:NO];
        
        [self reloadTableView];
    }
}


- (IBAction)applyControl:(UIButton *)sender
{
    DDLogFunction();
    NSUInteger tag = sender.tag;
    curPurgeModel.sleepModeId  = [NSString stringWithFormat:@"%d",tag];

    sender.enabled = NO;
    
    [btnApply setTitle:@"应用中" forState:UIControlStateNormal];
    [btnApply setTitle:@"应用中" forState:UIControlStateDisabled];
    [btnApply setTitle:@"应用中" forState:UIControlStateHighlighted];
    
    [self uploadAcModel:NO];
    [self reloadTableView];
}

- (void)uploadAcModel:(BOOL)isWait
{
    DDLogFunction();
    
    if(sleepOpened)
    {
        curPurgeModel.modeIndex = @5; // 睡眠模式
    }
    else if(apOpened || acOpened)
    {
        curPurgeModel.modeIndex = @4; // 恒温恒净模式
    }
    else
    {
        curPurgeModel.modeIndex = @3; // 无状态
    }
    
    NSInteger curMode = curPurgeModel.modeIndex.integerValue;
    NSString *curTemp = [curPurgeModel.temperature stringByReplacingOccurrencesOfString:CelciusSymbol withString:@""];
    NSString *curStatus = curPurgeModel.onOff;
    NSString *acmode = curPurgeModel.operationCodeList[curPurgeModel.acMode];;
    NSString *speed = curPurgeModel.operationCodeList[curPurgeModel.windSpeed];
    NSString *time = curPurgeModel.time;
    NSString *apOnOff = curPurgeModel.apOnOff;
    NSString *healthyState = curPurgeModel.healthyState ? curPurgeModel.healthyState : @"";
    NSNumber *acflag = curPurgeModel.acflag ? curPurgeModel.acflag : @NO;
    NSNumber *apflag = curPurgeModel.apflag ? curPurgeModel.apflag : @NO;
    NSString *pm25 = curPurgeModel.pm25 ? curPurgeModel.pm25 : @"50";
    NSString *sleepModeId = curPurgeModel.sleepModeId ? curPurgeModel.sleepModeId : @"";
    
    time = [time stringByReplacingOccurrencesOfString:@":" withString:@""];
    
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(segControlType.selectedSegmentIndex == 0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(segControlType.selectedSegmentIndex == 0)
    {
        if (section == 0)
        {
            return 3;
        }
        else if(section == 1)
        {
            if(apOpened)
            {
                return 2;
            }
            else
            {
                return 0;
            }
        }
    }
    else
    {
        return 2;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segControlType.selectedSegmentIndex == 0)
    {
        if(indexPath.section == 0 )
        {
            if(indexPath.row < 3)
            {
                return 74;
            }
            else
            {
                return 54;
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                return 74;
            }
            else
            {
                return 54;
            }
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            return 74;
        }
        else
        {
            return viewSleepModule.frame.size.height;
        }

    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 63;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(segControlType.selectedSegmentIndex == 0)
    {
        if(section == 0)
        {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 63)];
            [self setupHeaderViewSubs:headerView withSelect:acOpened withTitle:@"恒温控制" action:@selector(startOrStopModel:)];
            
            return headerView;
        }
        else if(section == 1)
        {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 63)];
            [self setupHeaderViewSubs:headerView withSelect:apOpened withTitle:@"恒净控制" action:@selector(apControl:)];
            
            return headerView;
        }
    }
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 63)];
        [self setupHeaderViewSubs:headerView withSelect:sleepOpened withTitle:@"睡眠模式" action:@selector(sleepControl:)];
        
        return headerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(segControlType.selectedSegmentIndex == 0)
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row < 2)
            {
                static NSString *identifier = @"IntellAirAdjustCell";
                IntellAirAdjustCell *cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                if(cell == nil)
                {
                    NSString *nibName =  @"IntellAirAdjustCell";
                    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
                    [tableView registerNib:nib forCellReuseIdentifier:identifier];
                    cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if(indexPath.row == 0 )
                {
                    [self setAirAdjustCell:cell withType:kCellTemperatureType isHightLight:YES action:@selector(tempControl:)];
                }
                else if(indexPath.row == 1)
                {
                    [self setAirAdjustCell:cell withType:kCellACModuleType isHightLight:NO action:@selector(acModelControl:)];
                }
                cell.lblContent.alpha = acOpened ? 1.0 : 0.3;
                cell.cellIcon.alpha = acOpened ? 1.0 : 0.3;
                cell.leftBtn.alpha = acOpened ? 1.0 : 0.3;
                cell.rightBtn.alpha = acOpened ? 1.0 : 0.3;
                cell.userInteractionEnabled = acOpened;
                
                return cell;
            }
            else
            {
                NSString *reusedIdentifier = @"AirNoteCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
                if(cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:reusedIdentifier];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                // 创建contentView
                CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, 54);
                [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
                
                NSString *noteString = @"制热模式下,室内低于设定温度(±1区间),盒子君将自动为您打开空调,高于设定温度自动关闭空调。";
                if([curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]])
                {
                    noteString = @"制冷模式下,室内高于设定温度(±1区间),盒子君将自动为您打开空调,低于设定温度自动关闭空调。";
                }
                cell.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
                [self setupCellNoteSubs:[cell contentView] withNote:noteString];

                
                return cell;
            }
            
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                static NSString *identifier = @"IntellAirAdjustCell";
                IntellAirAdjustCell *cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                if(cell == nil)
                {
                    NSString *nibName =  @"IntellAirAdjustCell";
                    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
                    [tableView registerNib:nib forCellReuseIdentifier:identifier];
                    cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
               
                [self setAirAdjustCell:cell withType:kCellPM25Type isHightLight:YES action:@selector(pm25Control:)];
                
                return cell;
            }
            else
            {
                NSString *reusedIdentifier = @"AirNoteCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
                if(cell == nil)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:reusedIdentifier];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                }
                
                NSString *noteString = @"开启后,室内PM2.5高于设定值(±10区间),盒子君将自动打开净化器,低于设定值将自动关闭净化器。";
                // 创建contentView
                CGSize contentViewSize = CGSizeMake(tableView.frame.size.width, 54);
                [[cell contentView] setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
                [self setupCellNoteSubs:[cell contentView] withNote:noteString];
                cell.contentView.backgroundColor = [UIColor whiteColor];
                
                return cell;
            }
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *identifier = @"IntellSleeplAdjustCell";
            IntellAirAdjustCell *cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if(cell == nil)
            {
                NSString *nibName =  @"IntellAirAdjustCell";
                UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:identifier];
                cell = (IntellAirAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self setAirAdjustCell:cell withType:kCellACModuleType isHightLight:YES action:@selector(acModelControl:)];
            
            cell.lblContent.alpha = sleepOpened ? 1.0 : 0.3;
            cell.cellIcon.alpha = sleepOpened ? 1.0 : 0.3;
            cell.leftBtn.alpha = sleepOpened ? 1.0 : 0.3;
            cell.rightBtn.alpha = sleepOpened ? 1.0 : 0.3;
            cell.userInteractionEnabled = sleepOpened;
            
            return cell;
        }
        else
        {
            static NSString *cellIdentifier = @"cellIdentifier";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [cell.contentView addSubview:viewSleepModule];
                
                [Utility setExclusiveTouchAll:viewSleepModule];
            }
            
            [self refreshSleepRoomImageView];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            viewSleepModule.alpha =  sleepOpened ? 1.0 : 0.3;
            
            return cell;
        }

    }
    return nil;
}

#pragma mark - Alert Box Delegate
- (void)alertBoxOkButtonOnClicked:(AlertBoxViewController *)alertBoxViewController
{
    NSInteger tag = alertBoxViewController.tag;
    if(tag == 1000)
    {
        acOpened = !acOpened;
        curPurgeModel.acflag = @YES;
        curPurgeModel.onOff = IRDeviceOpen;
        sleepOpened = NO;
        
        [self uploadAcModel:NO];
        [self reloadTableView];
    }
    else if(tag == 2000)
    {
        apOpened = !apOpened;
        curPurgeModel.apflag = @YES;
        curPurgeModel.apOnOff = IRDeviceOpen;
        sleepOpened = NO;
        
        [self uploadAcModel:NO];
        [self reloadTableView];
    }
    else if(tag == 3000)
    {
        
        sleepOpened = !sleepOpened;
        
        acOpened = NO;
        apOpened = NO;
        curPurgeModel.acflag = @NO;
        curPurgeModel.apflag = @NO;
        curPurgeModel.onOff = IRDeviceOpen;
        
        // 默认选择第一个房间模式
        if(!curPurgeModel.sleepModeId || curPurgeModel.sleepModeId.length == 0 || (curPurgeModel.sleepModeId.integerValue) < 1  || curPurgeModel.sleepModeId.integerValue > 4)
        {
            curPurgeModel.sleepModeId = @"1";
        }
        
        [self uploadAcModel:NO];
        [self reloadTableView];
    }
    
}



@end
