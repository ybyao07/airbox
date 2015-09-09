//
//  AirViewController.m
//  AirManager
//

#import "AirDeivceManageViewController.h"
#import "AirDeviceViewController.h"
#import "AirConditionViewController.h"
#import "SettingViewController.h"
#import "AirDevice.h"
#import "AirQuality.h"
#import "UIDevice+Resolutions.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import <Social/Social.h>
#import "AlertBox.h"
#import "WXApi.h"
#import "CityDataHelper.h"
#import "WeatherManager.h"
#import "SDKRequestManager.h"
#import "WeatherMainViewController.h"
#import "IRDeviceManager.h"
#import "AirPurgeModel.h"
#import "Toast+UIView.h"
#import "IRDeviceModelSelectionViewController.h"
#import "ImageString.h"
#import "UIView+Utility.h"
#import "InstantWeather.h"
#import "CityViewController.h"
#import "AirDeviceManager.h"
#import <uSDKFramework/uSDKDevice.h>
#import "IntelligenceVCViewController.h"
#import "NearAirBoxesViewController.h"
#import "CustomModelViewController.h"

#define kDisplayNearAirBoxesOffset      68

@interface AirDeivceManageViewController (){
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIImageView *weatherIcon;
    IBOutlet UILabel *lblTemperature;
    IBOutlet UILabel *lblCity;
    __weak IBOutlet UIButton *guideBtn;
    __weak IBOutlet UIImageView *homeImageView;
    NSMutableArray *arrACControllers;
    NSInteger curPage;
    __weak IBOutlet UIImageView *offLineMode;
    IBOutlet UILabel *lblPM25;
    IBOutlet UILabel *lblHumidity;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIScrollView *baseview;

    __weak IBOutlet UIImageView *homeBackGroupImageView;
    __weak IBOutlet UIView *pm25Color;
    
    __weak IBOutlet UILabel *shiduHintLabel;
    __weak IBOutlet UILabel *wenduDanweiLabel;
    __weak IBOutlet UILabel *shiduDanweiLabel;
    UIImageView *buttonImageView;
    UILabel *buttonLabel;
    __weak IBOutlet UIButton *sharedBtn;
    __weak IBOutlet UIButton *setttingBtn;
    __weak IBOutlet UIView *viewWeather;
    __weak IBOutlet UILabel *labelOffLine;
    
    UIView *nearView;
    
    IBOutlet UIButton *weatherBtn;
}

@property (nonatomic, strong) NSMutableArray *arrACControllers;
@property (nonatomic, assign) BOOL isDisplayNear;
@property (nonatomic, strong) UIImageView *leftArrow;

@end

@implementation AirDeivceManageViewController

@synthesize arrACControllers;
@synthesize airDeviceScrollView;
@synthesize intelligentBtn;
@synthesize airConditionBtn;
/**
 @synthesize strDate;
 @synthesize strCity;
 **/

-(void)setCurDeviceVC:(AirDeviceViewController *)curDeviceVC
{
    if(_curDeviceVC != curDeviceVC)
    {
        _curDeviceVC = curDeviceVC;
        if(!MainDelegate.isCustomer)
        {
            // 刷新服务，需要处理
            [_curDeviceVC startCheckWaitCountDownCase1];
        }
        [_curDeviceVC downloadAirBoxModel];
        [self addModelAnimation];
    }
}

- (void)dealloc
{
    DDLogFunction();
    [self removeObserver];
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
    
    [self registerObserver];
    [lblCity setAdjustsFontSizeToFitWidth:YES];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xb9b9b9 alpha:0.2f];
    
    [[pm25Color layer] setBorderColor:[UIColor colorWithHex:0xffffff alpha:0.2f].CGColor];
    [[pm25Color layer] setBorderWidth:1];
    [[pm25Color layer] setCornerRadius:2];
    
    [intelligentBtn setImage:[UIImage imageNamed:@"settingIntellButtonBackgroup.png"] forState:UIControlStateNormal];

    [intelligentBtn setImage:[UIImage imageNamed:@"IntellButtonDisableBackgroup.png"] forState:UIControlStateDisabled];
    [[intelligentBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
    
    
    [airConditionBtn setImage:[UIImage imageNamed:@"ManuleButtonIcon.png"] forState:UIControlStateNormal];
    [airConditionBtn setImage:[UIImage imageNamed:@"ManuleButtonDisableIcon.png"] forState:UIControlStateDisabled];
    
    UIImageView *shareImageView = [[UIImageView alloc] init];
    [shareImageView setImage:[UIImage imageNamed:@"btn_share_bg_normal.png"]];
    [shareImageView setFrame:CGRectMake(6, 6, 30, 30)];
    [sharedBtn addSubview:shareImageView];
    [sharedBtn setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *settingImageView = [[UIImageView alloc] init];
    [settingImageView setImage:[UIImage imageNamed:@"setButtonBackground.png"]];
    [settingImageView setFrame:CGRectMake(6, 6, 30, 30)];
    [setttingBtn addSubview:settingImageView];
    [setttingBtn setBackgroundColor:[UIColor clearColor]];
    
    [self doNearAirBoxes]; // 身边盒子
    
    self.view.userInteractionEnabled = NO;//ybyao07-20141111
    [self loadWeatherToScreen :nil];
    [self loadWeatherToScreenPM25:nil];

    [[WeatherManager sharedInstance] stopAutoReload];
    [[WeatherManager sharedInstance] loadWeather];//ybyao07--20141111加载天气数据
    
    [self performSelector:@selector(customManageView) withObject:nil afterDelay:0.1];
    
    if(!MainDelegate.isCustomer)
    {
        //version Examine
        [MainDelegate versionExamineOnClicked:nil];
        [weatherIcon setViewX:6];
        [offLineMode setViewX:6];
        [backButton setHidden:YES];
        
        if([MainDelegate isNetworkAvailable])
        {
            [viewWeather setHidden:NO];
            [labelOffLine setHidden:YES];
            [lblCity setHidden:NO];
            [weatherIcon setHidden:NO];
            [offLineMode setHidden:YES];
            [sharedBtn setHidden:NO];
            
            [self setBottomViewButtonSubsView:intelligentBtn];
            [intelligentBtn setImage:[UIImage imageNamed:@"IntellButtonDisableBackgroup.png"] forState:UIControlStateDisabled];
            [[intelligentBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
        }
        else
        {
            [viewWeather setHidden:YES];
            [labelOffLine setHidden:NO];
            [lblCity setHidden:YES];
            [weatherIcon setHidden:YES];
            [offLineMode setHidden:NO];
            [sharedBtn setHidden:YES];
            [intelligentBtn setImage:[UIImage imageNamed:@"IntellButtonDisableOffLine.png"] forState:UIControlStateDisabled];
        }
    }
    else
    {
        [backButton setHidden:NO];
        [weatherIcon setViewX:42];
        [offLineMode setViewX:42];
        [viewWeather setHidden:NO];
        [labelOffLine setHidden:YES];
        [lblCity setHidden:NO];
        [weatherIcon setHidden:NO];
        [offLineMode setHidden:YES];
        [sharedBtn setHidden:NO];
        
        [self setBottomViewButtonSubsView:intelligentBtn];
        [intelligentBtn setImage:[UIImage imageNamed:@"IntellButtonDisableBackgroup.png"] forState:UIControlStateDisabled];
        [[intelligentBtn titleLabel] setFont:[UIFont systemFontOfSize:17.0f]];
    }
    
    BOOL isShowGudieView = [UserDefault boolForKey:kIsShowGuideView];
    if(isShowGudieView)
    {
        [baseview bringSubviewToFront:guideBtn];
        [guideBtn setHidden:NO];
    }
    else
    {
        [guideBtn setHidden:YES];
    }

    
    [Utility setExclusiveTouchAll:self.view];
    
    
}

- (void) doNearAirBoxes
{
    nearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,86, airDeviceScrollView.frame.size.height)];
    UIImageView *imageNear =[[UIImageView alloc] init];
    [imageNear setImage:[UIImage imageNamed:@"nearBoxes.png"]];
    [imageNear setFrame:CGRectMake(30, (NSUInteger)(nearView.frame.size.height - 41) / 2, 47, 41)];
    [nearView addSubview:imageNear];
    
    
    _leftArrow =[[UIImageView alloc] init];
    [_leftArrow setImage:[UIImage imageNamed:@"leftArrowNear.png"]];
    [_leftArrow setFrame:CGRectMake(8, (NSUInteger)(nearView.frame.size.height - 17) / 2, 17, 17)];
    [nearView addSubview:_leftArrow];
    [nearView setBackgroundColor:[UIColor clearColor]];
    
    if(MainDelegate.isCustomer)
    {
        _isDisplayNear = YES;
    }
    else
    {
        if([MainDelegate isNetworkAvailable])
        {
            _isDisplayNear = YES;
        }
        else
        {
            _isDisplayNear = NO;
        }
    }
    
}
- (void)setBottomViewButtonSubsView:(UIView *)viewParent
{
    // 子窗口高宽
	NSInteger spaceXStart = 0;
    
    spaceXStart += 24;
    
    CGSize imageSize = CGSizeMake(25, 25);
    buttonImageView= [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart, ( viewParent.frame.size.height - imageSize.height) / 2, 25 ,25)];
    [buttonImageView setImage:[UIImage imageNamed:@"settingIntellButtonIcon.png"]];
    [buttonImageView setUserInteractionEnabled:NO];

    buttonImageView.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"ingIntell_600.png"],
                                       [UIImage imageNamed:@"ingIntell_601.png"],
                                       [UIImage imageNamed:@"ingIntell_602.png"],
                                       [UIImage imageNamed:@"ingIntell_603.png"],
                                       [UIImage imageNamed:@"ingIntell_604.png"],
                                       [UIImage imageNamed:@"ingIntell_605.png"],
                                       [UIImage imageNamed:@"ingIntell_606.png"],
                                       [UIImage imageNamed:@"ingIntell_607.png"],
                                       [UIImage imageNamed:@"ingIntell_608.png"],
                                       [UIImage imageNamed:@"ingIntell_609.png"],
                                       
                                       [UIImage imageNamed:@"ingIntell_610.png"],
                                       [UIImage imageNamed:@"ingIntell_611.png"],
                                       [UIImage imageNamed:@"ingIntell_612.png"],
                                       [UIImage imageNamed:@"ingIntell_613.png"],
                                       [UIImage imageNamed:@"ingIntell_614.png"],
                                       [UIImage imageNamed:@"ingIntell_615.png"],
                                       [UIImage imageNamed:@"ingIntell_616.png"],
                                       [UIImage imageNamed:@"ingIntell_617.png"],
                                       [UIImage imageNamed:@"ingIntell_618.png"],
                                       [UIImage imageNamed:@"ingIntell_619.png"],
                                       
                                       [UIImage imageNamed:@"ingIntell_620.png"],
                                       [UIImage imageNamed:@"ingIntell_621.png"],
                                       [UIImage imageNamed:@"ingIntell_622.png"],
                                       [UIImage imageNamed:@"ingIntell_623.png"],
                                       [UIImage imageNamed:@"ingIntell_624.png"],
                                       [UIImage imageNamed:@"ingIntell_625.png"],
                                       [UIImage imageNamed:@"ingIntell_626.png"],
                                       [UIImage imageNamed:@"ingIntell_627.png"],
                                       [UIImage imageNamed:@"ingIntell_628.png"],
                                       [UIImage imageNamed:@"ingIntell_629.png"],
                                       
                                       [UIImage imageNamed:@"ingIntell_630.png"],
                                       [UIImage imageNamed:@"ingIntell_631.png"],
                                       [UIImage imageNamed:@"ingIntell_632.png"],
                                       [UIImage imageNamed:@"ingIntell_633.png"],
                                       [UIImage imageNamed:@"ingIntell_634.png"],
                                       [UIImage imageNamed:@"ingIntell_635.png"],
                                       [UIImage imageNamed:@"ingIntell_636.png"],
                                       [UIImage imageNamed:@"ingIntell_637.png"],
                                       [UIImage imageNamed:@"ingIntell_638.png"],
                                       [UIImage imageNamed:@"ingIntell_639.png"],
                                       
                                       [UIImage imageNamed:@"ingIntell_640.png"],
                                       [UIImage imageNamed:@"ingIntell_641.png"],
                                       [UIImage imageNamed:@"ingIntell_642.png"],
                                       [UIImage imageNamed:@"ingIntell_643.png"],
                                       [UIImage imageNamed:@"ingIntell_644.png"],
                                       [UIImage imageNamed:@"ingIntell_645.png"],
                                       [UIImage imageNamed:@"ingIntell_646.png"],
                                       [UIImage imageNamed:@"ingIntell_647.png"],
                                       [UIImage imageNamed:@"ingIntell_648.png"],
                                       [UIImage imageNamed:@"ingIntell_649.png"],
                                       
                                       nil];
    
    buttonImageView.animationDuration = 1.0f;
    buttonImageView.animationRepeatCount = 0;
    
    [viewParent addSubview:buttonImageView];
}


- (void)layoutView
{
    baseview.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);
    
    //判断是不是ios7
    if (IOS7)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        view.backgroundColor = [UIColor blackColor];
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = NO;
        [self.view addSubview:view];
#endif
    }
    baseview.showsHorizontalScrollIndicator = NO;
    baseview.showsVerticalScrollIndicator = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    setttingBtn.userInteractionEnabled = YES;
    weatherBtn.userInteractionEnabled = YES;
    
    [_curDeviceVC downloadAirBoxModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

-(void)doAirDeviceRemoved
{
    if([MainDelegate isCustomer])
    {
    }
    else
    {
        if(![MainDelegate.loginedInfo.arrUserBindedDevice containsObject:MainDelegate.curBindDevice])
        {
            MainDelegate.curBindDevice = MainDelegate.loginedInfo.arrUserBindedDevice[0];
        }
        curPage = [MainDelegate.loginedInfo.arrUserBindedDevice indexOfObject:MainDelegate.curBindDevice];
        [self loadAirDevice];
        [self loadScrollView];
        [self loadAirDeviceToView];
        
        [self addModelAnimation];
    }
}

- (void)customManageView
{
    if([MainDelegate isCustomer])
    {
        self.arrACControllers = [NSMutableArray array];
        for (int i = 0; i < 1; i++)
        {
            AirDeviceViewController *airDevice = [self createAieDeviceWithInfo:[[AirDevice alloc] init] index:i];
            [arrACControllers addObject:airDevice];
        }
    }
    else
    {
        if(![MainDelegate.loginedInfo.arrUserBindedDevice containsObject:MainDelegate.curBindDevice])
        {
            MainDelegate.curBindDevice = MainDelegate.loginedInfo.arrUserBindedDevice[0];
        }
        curPage = [MainDelegate.loginedInfo.arrUserBindedDevice indexOfObject:MainDelegate.curBindDevice];
        [self loadAirDevice];
    }
    
    [self loadScrollView];
    
    [self loadAirDeviceToView];
}

- (void)refreshModelAnimation:(BOOL)isConnect withMac:(NSString *)mac
{
     DDLogFunction();
    if(!MainDelegate.isCustomer)
    {
        AirDeviceViewController *airDevice = _curDeviceVC;
        
        if([airDevice.curDevice.mac isEqualToString:mac])
        {
            if(!isConnect)
            {
                intelligentBtn.enabled = NO;
                
                airConditionBtn.enabled = NO;
            }
            else
            {
                if([MainDelegate isNetworkAvailable])
                {
                    intelligentBtn.enabled = YES;
                }
                else
                {
                    intelligentBtn.enabled = NO;
                }
                airConditionBtn.enabled = YES;
            }
        }
        
        [self addModelAnimation];
    }
}

- (void)addModelAnimation
{
    AirDeviceViewController *airDevice = _curDeviceVC;
    if(airDevice.isIntellgentMode)
    {
        if(intelligentBtn.enabled)
        {
            [buttonImageView startAnimating];
            [intelligentBtn setImage:[UIImage imageNamed:@"settingIntellButtonBackgroup.png"] forState:UIControlStateNormal];
        }
        else
        {
            [buttonImageView stopAnimating];
            buttonImageView.image = [UIImage imageNamed:@"IntellButtonDisableIcon.png"];
        }
    }
    else
    {
        if(intelligentBtn.enabled)
        {
            [buttonImageView stopAnimating];
            buttonImageView.image = [UIImage imageNamed:@"cancelntellButtonIcon.png"];
            [intelligentBtn setImage:[UIImage imageNamed:@"cancelntellButtonBackgroup.png"] forState:UIControlStateNormal];
        }
        else
        {
            [buttonImageView stopAnimating];
            buttonImageView.image = [UIImage imageNamed:@"IntellButtonDisableIcon.png"];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma Button Event

- (IBAction)gobackToHome:(UIButton *)sender
{
    MainDelegate.isNetworkConnenct = YES;
    [self removeObserver];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareAirBoxInfo:(UIButton *)sender
{
    DDLogFunction();
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id)self
                                                    cancelButtonTitle:NSLocalizedString(@"取消",@"AirDeivceManageViewController.m")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"分享到新浪微博",@"AirDeivceManageViewController.m"),NSLocalizedString(@"分享到微信",@"AirDeivceManageViewController.m"), nil];
    [actionSheet setTag:10000];
    [actionSheet showInView:airDeviceScrollView];
}

- (void)backToHomePage
{
    [self removeObserver];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)setting:(UIButton *)sender
{
    DDLogFunction();
    sender.userInteractionEnabled = NO;// TreeJohn
    {
        SettingViewController *setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
        [self.navigationController pushViewController:setting animated:YES];
    }
}

- (IBAction)guideBtn:(UIButton *)sender
{
    [guideBtn removeFromSuperview];
    [UserDefault setBool:NO forKey:kIsShowGuideView];
    [UserDefault synchronize];
}
- (IBAction)tapWeatherPage:(UIButton *)sender
{
    DDLogFunction();
//    sender.userInteractionEnabled = NO;// TreeJohn
    if(!MainDelegate.isCustomer)
    {
        if([MainDelegate isNetworkAvailable])
        {
            WeatherMainViewController *vc = [[WeatherMainViewController alloc] initWithNibName:@"WeatherMainViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
            return;
        }
    }
    else
    {
        WeatherMainViewController *vc = [[WeatherMainViewController alloc] initWithNibName:@"WeatherMainViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)weatherUpdateStatus:(NSNotification *)notification
{
    DDLogFunction();
    if([notification.name isEqualToString:WeatherDownloadedNotification])
    {
        NSString *info = notification.object;
        if ([info isEqualToString:kCurrentWeather])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadWeatherToScreen:notification.userInfo];
            });
        }
        else if([info isEqualToString:kCurrentPM25])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadWeatherToScreenPM25:notification.userInfo];
            });
        }
    }
}

- (void)openOpenModePage:(void(^)())handler;
{
    if(_isFromMannul)
    {
        [_curDeviceVC openACoperatePage:handler];
    }
    else
    {
        [_curDeviceVC openIntelligencePage:handler];
    }
}
- (void)showSelectList:(BOOL)isManual
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您没有网络,无法绑定新设备",@"WeatherMainViewController")];
        return;
    }
    
    // 智能模式
    if(!isManual)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:NSLocalizedString(@"选择添加的设备类型", @"AirDeivceManageViewController.m")
                                          delegate:(id)self
                                          cancelButtonTitle:NSLocalizedString(@"取消", @"AirDeivceManageViewController.m")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"空调", @"AirDeivceManageViewController.m"), NSLocalizedString(@"净化器", @"AirDeivceManageViewController.m"),nil];
            
            [actionSheet setTag:20000];
            [actionSheet showInView:self.view];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                          initWithTitle:NSLocalizedString(@"选择添加的设备类型", @"AirDeivceManageViewController.m")
                                          delegate:(id)self
                                          cancelButtonTitle:NSLocalizedString(@"取消", @"AirDeivceManageViewController.m")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"空调", @"AirDeivceManageViewController.m"), NSLocalizedString(@"净化器", @"AirDeivceManageViewController.m"), NSLocalizedString(@"红外学习", @"AirDeivceManageViewController.m"),nil];
            
            [actionSheet setTag:20000];
            [actionSheet showInView:self.view];
        });
    }
}

- (IBAction)intelligenceModel:(UIButton *)sender
{
    DDLogFunction();
    
    if(MainDelegate.isCustomer)
    {
        [_curDeviceVC openIntelligencePage:nil];
        
        return;
    }
    
    if(![MainDelegate isNetworkAvailable])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [MainDelegate showProgressHubInView:self.view];
    });
    
    AirDeviceViewController *airDevice = _curDeviceVC;
    
    AirDevice *curDevice= airDevice.curDevice;
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [MainDelegate showProgressHubInView:self.view];
    
    [irDeviceManager loadIRDeviceBindOnAirDevice:curDevice.mac
                               completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC)
     {
         if(isLoadSucceed)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MainDelegate hiddenProgressHubInView:self.view];
                 airDevice.arrBindedIRDevice = array;
                 if(airDevice.arrBindedIRDevice.count == 0)
                 {
                     _isFromMannul = NO;
                     [self showSelectList:NO];
                 }
                 else
                 {
                     [airDevice openIntelligencePage:nil];
                 }
             });
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MainDelegate hiddenProgressHubInView:self.view];
                 [AlertBox showWithMessage:NSLocalizedString(@"获取红外设备失败",@"AirDeivceManageViewController.m")];
             });
         }
     }];
}

- (IBAction)manualModel:(UIButton *)sender
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [_curDeviceVC openACoperatePage:nil];
        return;
    }
    else
    {
        [self airDeviceBindedIRDevice];
    }
}

- (void)irStudy
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"AirConditionViewController")];
        
        return;
    }
    
    CustomModelViewController *irStudy = [[CustomModelViewController alloc] initWithNibName:@"CustomModelViewController" bundle:nil];
    irStudy.macID = _curDeviceVC.curDevice.mac;
    irStudy.view.frame = self.parentViewController.view.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MainDelegate.window addSubview:irStudy.view];
        irStudy.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            irStudy.view.alpha = 1.0;
            [self addChildViewController:irStudy];
        }];
    });
}

- (void)airDeviceBindedIRDevice
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    AirDeviceViewController *airDevice = _curDeviceVC;
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [irDeviceManager loadIRDeviceBindOnAirDevice:airDevice.curDevice.mac
                               completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC){
                                   if(isLoadSucceed)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           airDevice.arrBindedIRDevice = array;
                                           if(airDevice.arrBindedIRDevice.count > 0)
                                           {
                                               [airDevice checkIRCode];
                                           }
                                           else
                                           {
                                               
                                               [MainDelegate hiddenProgressHubInView:self.view];
                                               _isFromMannul = YES;
                                               [self showSelectList:YES];
                                           }
                                       });
                                       
                                   }
                                   else
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [MainDelegate hiddenProgressHubInView:self.view];
                                           [AlertBox showWithMessage:NSLocalizedString(@"获取红外设备失败",@"AirDeivceManageViewController.m")];
                                       });
                                   }
                               }];
}

- (void)gotoNearAirBoxesVC
{
    NearAirBoxesViewController *vc = [[NearAirBoxesViewController alloc] initWithNibName:@"NearAirBoxesViewController" bundle:nil];
    
    vc.backImage = homeBackGroupImageView.image;
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark - Init Air Device

- (AirDeviceViewController *)createAieDeviceWithInfo:(AirDevice *)info index:(NSInteger)index
{
    DDLogFunction();
    AirDeviceViewController *airDevice = [[AirDeviceViewController alloc] initWithNibName:@"AirDeviceViewController" bundle:nil];
    [self addChildViewController:airDevice];
    airDevice.curDevice = info;
    if(index == curPage)
    {
        airDevice.curDeviceAirQuality = MainDelegate.curAirQuality;
    }
    airDevice.view.frame = CGRectMake(0, 0, 320, airDeviceScrollView.frame.size.height);
    return airDevice;
}

- (void)loadAirDevice
{
    DDLogFunction();
//    self.arrACControllers = [NSMutableArray array];
    NSMutableArray *arrACControllersTmp = [NSMutableArray array];
    if(self.childViewControllers.count > 0)
    {
        [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    if([MainDelegate.loginedInfo.arrUserBindedDevice count] > 0)
    {
        [self  removeOneDeviceInArrACContollers];
        for (int i = 0; i < [MainDelegate.loginedInfo.arrUserBindedDevice count]; i++)
        {
            AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
            AirDeviceViewController *airDevice = [self getVCWithDevice:device];
            if(airDevice)
            {
                [airDevice changeAirBoxName];
                [arrACControllersTmp addObject:airDevice];
                [self addChildViewController:airDevice];
            }
            else
            {
                AirDeviceViewController *airDevice = [self createAieDeviceWithInfo:device index:i];
                [arrACControllersTmp addObject:airDevice];
            }
        }
    }
    arrACControllers = arrACControllersTmp;
//    if([MainDelegate.loginedInfo.arrUserBindedDevice count] > 0)
//    {
//        for (int i = 0; i < [MainDelegate.loginedInfo.arrUserBindedDevice count]; i++)
//        {
//            AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
//            AirDeviceViewController *airDevice = [self createAieDeviceWithInfo:device index:i];
//            [arrACControllers addObject:airDevice];
//        }
//    }
}

- (void) removeOneDeviceInArrACContollers
{
    DDLogFunction();
    for (int i = arrACControllers.count -1 ; i>=0;i--)
    {
        AirDeviceViewController *airDevice = (AirDeviceViewController *)[arrACControllers objectAtIndex:i];
        AirDevice *curDevice = [self getAirDevice:[airDevice curDevice]];
        if(!curDevice)
        {
            [arrACControllers removeObjectAtIndex:i];
        }
    }
}

- (AirDevice*) getAirDevice:(AirDevice *) curDevice
{
    DDLogFunction();
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
- (AirDeviceViewController *) getVCWithDevice:(AirDevice *) device
{
    for(int j= 0;  j< [arrACControllers count] ; j++)
    {
        AirDeviceViewController *airDevice = (AirDeviceViewController *)[arrACControllers objectAtIndex:j];
        if([[airDevice curDevice].mac isEqualToString:device.mac])
        {
            return airDevice;
        }
    }
    return nil;
}
- (void)loadAirDeviceForCustomer
{
    DDLogFunction();
    self.arrACControllers = [NSMutableArray array];
    if(self.childViewControllers.count > 0)
    {
        [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    }
    
    for (int i = 0; i < [MainDelegate.loginedInfo.arrUserBindedDevice count]; i++)
    {
        AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
        AirDeviceViewController *airDevice = [self createAieDeviceWithInfo:device index:i];
        [arrACControllers addObject:airDevice];
    }
}


#pragma mark - Display Air Manager To View
// 更新缓存
- (void)doAirDevicesChanged
{
    // 更新缓存
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    [airDeviceManager downloadBindedDeviceWithCompletionHandler:^(NSMutableArray *array,BOOL succeed){
    }];
}

- (void)cityChanged
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        lblCity.text = NSLocalizedString([MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]], @"AirDeivceManageViewController.m");
    });
}
- (void)loadWeatherToScreenPM25:(NSDictionary *)useinfo
{
    DDLogFunction();
    NSString *curPM25 = [useinfo objectForKey:@"pm25"];
    
    NSString *tempPM25 = nil;
    
    if(isObject(curPM25))
    {
        tempPM25 = [NSString stringWithFormat:@"%@",[Utility coventPM25StatusForAirManager:curPM25]];
    }
    else
    {
        tempPM25 = @"--";
    }
    
    lblPM25.text = tempPM25;
    _pm25OutDoor = tempPM25;
    
    if(useinfo)
    {
         [NotificationCenter postNotificationName:WeathePM25ChangeNotification object:nil];
    }
    
    [pm25Color setBackgroundColor:[UIColor colorWithHex:[Utility getPM25Color:tempPM25] alpha:1.0f]];

}
- (void)loadWeatherToScreen:(NSDictionary *)useinfo
{
    DDLogFunction();
    InstantWeather *curWeather = nil;
    NSMutableDictionary *weatherDic = [useinfo mutableCopy];
    if(isObject(weatherDic))
    {
        curWeather = [[InstantWeather alloc] initWithDic:weatherDic];
    }
    if(!curWeather)
    {
        lblCity.text = NSLocalizedString([MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]], @"AirDeivceManageViewController.m");
        return;
    }
    
    NSString *weatherTmp = nil;
    
    if(curWeather != nil)
    {
        if(curWeather.weather != nil && curWeather.weather.length > 0)
        {
            NSString *imageName = [MainDelegate siftCurrentIconWithName:curWeather.weather needNight:YES Hour:99];
            weatherIcon.image = [UIImage imageNamed:imageName];
            
            weatherTmp = curWeather.weather;
        }
        else
        {
        }
        
        NSString *temp = nil;
        if (curWeather.temperature != nil && curWeather.temperature.length > 0)
        {
            temp = curWeather.temperature;
            // TreeJohn
            [UserDefault setObject:curWeather.temperature forKey:AirManagerTempCache];
            [UserDefault synchronize];
            // end TreeJohn
        }
        else
        {
            // TreeJohn
            NSString *cacheTemp = [UserDefault objectForKey:AirManagerTempCache];
            if (cacheTemp) {
                temp = cacheTemp;
            } else {
                temp = @"--";
            }
            // end TreeJohn
        }
        
        lblTemperature.text = temp;
        
        
        if(curWeather.humidy != nil && curWeather.humidy.length > 0)
        {
            temp = curWeather.humidy;
            // TreeJohn
            [UserDefault setObject:curWeather.humidy forKey:AirManagerHumidityCache];
            [UserDefault synchronize];
            // end TreeJohn
        }
        else
        {
            // TreeJohn
            NSString *cacheHumidity = [UserDefault objectForKey:AirManagerHumidityCache];
            if (cacheHumidity) {
                temp = cacheHumidity;
            } else {
                temp = @"--";
            }
            // end TreeJohn
        }
        lblHumidity.text = temp;
    }
    
    if(lblHumidity.text != nil && ![lblHumidity.text isEqualToString:@"--"])
    {
        
        CGSize mySize = [lblHumidity.text  sizeWithFont:lblHumidity.font constrainedToSize:CGSizeMake(320, 2000) lineBreakMode:lblHumidity.lineBreakMode];
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
        lblTemperature.frame = CGRectMake(160 - mySize.width / 2, lblTemperature.frame.origin.y, mySize.width, lblTemperature.frame.size.height);
        
        wenduDanweiLabel.hidden = NO;
        [wenduDanweiLabel setFrame:CGRectMake(160 + mySize.width / 2, wenduDanweiLabel.frame.origin.y, wenduDanweiLabel.frame.size.width, wenduDanweiLabel.frame.size.height)];
    }
    else
    {
        wenduDanweiLabel.hidden = YES;
    }
    if(weatherTmp != nil)
    {
        
        lblCity.text = [NSString stringWithFormat:@"%@ · %@",  NSLocalizedString([MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]], @"AirDeivceManageViewController.m"),NSLocalizedString(weatherTmp, @"AirDeivceManageViewController.m")];
    }
    else
    {
        lblCity.text = NSLocalizedString([MainDelegate cityNameInternationalized:[CityDataHelper cityNameOfSelectedCity]], @"AirDeivceManageViewController.m");
    }
    
    homeBackGroupImageView.image = [UIImage imageNamed:[ImageString getAirManagerBackroudImageString:weatherTmp]];
    
    
    self.view.userInteractionEnabled = YES;

}

- (void)loadScrollView
{
    float width = airDeviceScrollView.frame.size.width;
    float hight = airDeviceScrollView.frame.size.height;
    NSUInteger totalWidth = arrACControllers.count * width;
    if(_isDisplayNear)
    {
        totalWidth += nearView.frame.size.width;
    }
    airDeviceScrollView.contentSize = CGSizeMake(totalWidth, hight);
    pageControl.numberOfPages = arrACControllers.count;
}

- (void)loadAirDeviceToView
{
    DDLogFunction();
    if([MainDelegate.loginedInfo.arrUserBindedDevice count] > 0)
    {
        MainDelegate.curBindDevice = MainDelegate.loginedInfo.arrUserBindedDevice[curPage];
    }
    pageControl.currentPage = curPage;
    //从scrollView上移除所有的subview
    NSArray *subViews = [airDeviceScrollView subviews];
    if([subViews count] > 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (int i = 0; i < arrACControllers.count; i++)
    {
        AirDeviceViewController *preView = ((AirDeviceViewController *)[arrACControllers objectAtIndex:i]);
        preView.view.frame = CGRectMake(i * 320,0,preView.view.frame.size.width,preView.view.frame.size.height);
        [airDeviceScrollView addSubview:preView.view];
    }
    
    if(_isDisplayNear)
    {
        [nearView setViewX:arrACControllers.count* 320];
        [airDeviceScrollView addSubview:nearView];
    }
    [airDeviceScrollView setContentOffset:CGPointMake(320 * curPage, 0) animated:NO];
    
    if(curPage >= 0 && curPage < arrACControllers.count)
    {
        [self setCurDeviceVC:[arrACControllers objectAtIndex:curPage]];
    }
}


#pragma mark - Observer Management

- (void)registerObserver
{
    [NotificationCenter addObserver:self
                           selector:@selector(doAirDeviceRemoved)
                               name:AirDeviceRemovedNotification
                             object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(weatherUpdateStatus:)
                               name:WeatherDownloadedNotification
                             object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(cityChanged)
                               name:CityChangedNotification
                             object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(doAirDevicesChanged)
                               name:AirDevicesChangedNotification
                             object:nil];
   
}

- (void)removeObserver
{
    [NotificationCenter removeObserver:self];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    
    pageControl.currentPage = aScrollView.contentOffset.x / aScrollView.frame.size.width > [MainDelegate.loginedInfo.arrUserBindedDevice count] - 1 ? [MainDelegate.loginedInfo.arrUserBindedDevice count] - 1 : aScrollView.contentOffset.x / aScrollView.frame.size.width;
    
    if(_isDisplayNear)
    {
        double offset = aScrollView.contentOffset.x - (arrACControllers.count - 1) * aScrollView.frame.size.width - 25;
        if( fabs(offset) < kDisplayNearAirBoxesOffset  && fabs(offset) )
        {
            _leftArrow.layer.transform=CATransform3DMakeRotation((double)(offset/ kDisplayNearAirBoxesOffset)* M_PI, 0, -1,0 );
        }
    }

    
    if([MainDelegate.loginedInfo.arrUserBindedDevice count] > 0)
    {
        MainDelegate.curBindDevice = MainDelegate.loginedInfo.arrUserBindedDevice[pageControl.currentPage];
        AirDeviceViewController *airDevice = arrACControllers[pageControl.currentPage];
        
        // 设置新的当前盒子页面
        [self setCurDeviceVC:airDevice];
        MainDelegate.curAirQuality = airDevice.curDeviceAirQuality;
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)aScrollView
{
    if(_isDisplayNear)
    {
        if(aScrollView.contentOffset.x >= (arrACControllers.count - 1) * aScrollView.frame.size.width + kDisplayNearAirBoxesOffset)
        {
            // 附近盒子
            [self gotoNearAirBoxesVC];
            [self resetScrollViewOffset:NO];
        }
        else if(aScrollView.contentOffset.x>  (arrACControllers.count - 1) * aScrollView.frame.size.width)
        {
            [self resetScrollViewOffset:YES];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    if(!MainDelegate.isCustomer)
    {
        [self addModelAnimation];
    }
}

- (void)resetScrollViewOffset:(BOOL)animated
{
    [airDeviceScrollView setContentOffset:CGPointMake( (arrACControllers.count - 1) * airDeviceScrollView.frame.size.width, 0) animated:animated];
}

- (UIImage *)cutScreenImage
{
    sharedBtn.hidden = YES;
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    sharedBtn.hidden = NO;
    return viewImage;
}

#pragma mark - UIActionSheetDelegate

#pragma mark - Open new controller

- (void)openIrBindPage:(NSString *)type
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = @"IRDeviceModelSelectionViewController";
        IRDeviceModelSelectionViewController *vc = [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
        vc.deviceType = type;
        vc.selectedAirDevice = MainDelegate.curBindDevice;
        vc.view.frame = [self parentViewController].view.frame;
        vc.view.alpha = 0.0;
        [MainDelegate.window addSubview:vc.view];
        [self addChildViewController:vc];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
    });
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actionSheet tag] == 20000)
    {
        if (buttonIndex == 0)
        {
            [self openIrBindPage:kDeviceTypeAC];
        }
        else if (buttonIndex == 1)
        {
            [self openIrBindPage:kDeviceTypeAP];
        }
        if(_isFromMannul)
        {
            if(buttonIndex == 2)
            {
                [self irStudy];
            }
        }
    }
     if([actionSheet tag] == 10000)
    {
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"分享到新浪微博",@"AirDeivceManageViewController.m")])
        {
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo])
            {
                __weak SLComposeViewController *weibo = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
                [weibo setInitialText:NSLocalizedString(@"来自海尔空气盒子",@"AirDeivceManageViewController.m")];
                [weibo addImage:[self cutScreenImage]];
                [self presentViewController:weibo animated:YES completion:^{}];
                [weibo setCompletionHandler:^(SLComposeViewControllerResult result){
//                    if (result) {
//                        [weibo resignFirstResponder];
//                    }
                    [weibo dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            else
            {
                [AlertBox showWithMessage:NSLocalizedString(@"分享失败",@"AirDeivceManageViewController.m")];
            }
        }
        else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"分享到微信",@"AirDeivceManageViewController.m")])
        {
            if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi])
            {
                WXMediaMessage *message = [WXMediaMessage message];
                [message setThumbImage:[self cutScreenImage]];
                WXImageObject *ext = [WXImageObject object];
                ext.imageData = UIImagePNGRepresentation([self cutScreenImage]);
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.bText = NO;
                req.message = message;
                req.scene = WXSceneTimeline;
                [WXApi sendReq:req];
            }
            else
            {
                [AlertBox showWithMessage:NSLocalizedString(@"分享失败",@"AirDeivceManageViewController.m")];
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate


@end
