//
//  IntelligenceViewController.m
//  AirManager
//

#import "IntelligenceViewController.h"
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
#import "SegControl.h"

#define Temp            @"temperature"
#define Speed           @"windspeed"
#define OperateModel    @"OperateModel"
#define APOperate       @"IRAP"

#define UserAirMode     @"userAirMode"
#define ModelTime       @"time"
#define ModelNum        @"mode"
#define ACModel         @"acmode"
#define OnOff           @"onoff"
#define NotLimitTag     @"9999"
#define CoolImg         @"04-制冷.png"
#define HotImg          @"制热-640.png"
#define JieNengImg      @"ic_jineng.png"
#define ShuShiImg       @"ic_shushi.png"
#define OnOrOffModel    @"30e0M0"

typedef enum {
    kSendApIrCode = 0,
    kSendAcIrCode,
    kSendNone
}SendIrCodeType;

@interface IntelligenceViewController ()
{

    BOOL                        isLeavePage;
    BOOL                        openOrCloseTemperatureMode;
    BOOL                        openOrClosePM25Mode;
    BOOL                        apOpened;
    BOOL                        acOpened;
    AirPurgeModel               *curPurgeModel;     //current data
    SegControl                  *segControlType;
    
}

@property (nonatomic, strong) UIView *baseview;

@end

@implementation IntelligenceViewController




- (void)dealloc
{
   
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
    
//    [self layoutView];
    
    [self setupRootView:[self view]];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    spaceYStart += 54;
    
    // =======================================================================
    // 单程往返TabControl
    // =======================================================================
    // 创建TabControl
    UIView *segControlBGView = [[UIView alloc] initWithFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, 32)];
    [segControlBGView setBackgroundColor:[UIColor whiteColor]];
    
    segControlType = [[SegControl alloc] initWithFrame:CGRectMake(46, 5, segControlBGView.frame.size.width - 2*46, segControlBGView.frame.size.height - 2*5)];
    [segControlType appendSegmentWithTitle:@"个人模式"];
    [segControlType appendSegmentWithTitle:@"睡眠迷失"];
    [segControlType setSelectedSegmentIndex:0];
    [segControlType addTarget:self action:@selector(changeTabValue:) forControlEvents:UIControlEventValueChanged];
    [segControlBGView addSubview:segControlType];
    
    [viewParent addSubview:segControlBGView];
    
    spaceYStart += 32;
    
    // =======================================================================
    // 搜索结果TableView
    // =======================================================================
    // 创建TableView
    UITableView *tableViewResultTmp = [[UITableView alloc] initWithFrame:CGRectMake(0, spaceYStart, parentFrame.size.width, spaceYEnd -spaceYStart) style:UITableViewStylePlain];
    [tableViewResultTmp setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableViewResultTmp setBackgroundColor:[UIColor whiteColor]];
    [tableViewResultTmp setBackgroundView:nil];
    [tableViewResultTmp setDataSource:self];
    [tableViewResultTmp setDelegate:self];
    
    [viewParent addSubview:tableViewResultTmp];

}


- (void)setAirAdjustCell:(AirAdjustCell *)cell withIndex:(NSInteger)row
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.leftBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [cell.rightBtn removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        if(row == 0)
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.cellIcon.image = [UIImage imageNamed:@"02-室内温度.png"];
            cell.lblContent.text = curPurgeModel.temperature;
            
            if(MainDelegate.isCustomer)
            {
                cell.leftBtn.hidden = NO;
                cell.rightBtn.hidden = NO;
            }
            else
            {
//                if([lblModelTitle.text isEqualToString:curPurgeModel.airModelList[0]])
//                {
//                    cell.leftBtn.hidden = NO;
//                    cell.rightBtn.hidden = NO;
//                }
//                else
                {
                    cell.leftBtn.hidden = YES;
                    cell.rightBtn.hidden = YES;
                }
            }
            
            /*----------------------------------------
             if(devLimitTemp.length == 0)
             {
             cell.lblContent.text = curPurgeModel.temperature;
             cell.leftBtn.hidden = NO;
             cell.rightBtn.hidden = NO;
             }
             else
             {
             cell.lblContent.text = [NSString stringWithFormat:@"%@%@",devLimitTemp,CelciusSymbol];
             cell.leftBtn.hidden = YES;
             cell.rightBtn.hidden = YES;
             }
             ----------------------------------------*/
            [cell.leftBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(row == 1)
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:249.0/255.0 blue:239.0/255.0 alpha:1.0];
            
            if(MainDelegate.isCustomer)
            {
                NSString *img = [curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]]?CoolImg:HotImg;
                cell.cellIcon.image = [UIImage imageNamed:img];
                cell.lblContent.text = curPurgeModel.acMode;
                cell.leftBtn.hidden = NO;
                cell.rightBtn.hidden = NO;
            }
            else
            {
//                if([lblModelTitle.text isEqualToString:curPurgeModel.airModelList[0]])
                {
                    NSString *img = [curPurgeModel.acMode isEqualToString:curPurgeModel.acModelList[0]]?CoolImg:HotImg;
                    cell.cellIcon.image = [UIImage imageNamed:img];
                    cell.lblContent.text = curPurgeModel.acMode;
                    cell.leftBtn.hidden = NO;
                    cell.rightBtn.hidden = NO;
                }
//                else
//                {
//                    NSString *img = [lblModelTitle.text isEqualToString:curPurgeModel.airModelList[1]]?ShuShiImg:JieNengImg;
//                    cell.cellIcon.image = [UIImage imageNamed:img];
//                    cell.lblContent.text = lblModelTitle.text;
//                    cell.leftBtn.hidden = YES;
//                    cell.rightBtn.hidden = YES;
//                }
            }
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
            if(MainDelegate.isCustomer)
            {
                cell.leftBtn.hidden = NO;
                cell.rightBtn.hidden = NO;
            }
            else
            {
//                if([lblModelTitle.text isEqualToString:curPurgeModel.airModelList[0]])
//                {
//                    cell.leftBtn.hidden = NO;
//                    cell.rightBtn.hidden = NO;
//                }
//                else
                {
                    cell.leftBtn.hidden = YES;
                    cell.rightBtn.hidden = YES;
                }
            }
            
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


// 创建空View的子界面
- (void)setupCellNoteSubs:(UIView *)viewParent
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
    [imageView setFrame:CGRectMake(spaceXStart, 13, 13, 13)];
    [imageView setImage:[UIImage imageNamed:@""]];
    [viewParent addSubview:imageView];
    
    spaceXStart += 13;
    spaceXStart += 5;
    NSString *noteStr = @"室内低于设定温度(+区间),盒子君将自动为您打开空调;高于审定温度自动关闭空调";
    
    CGSize size = [noteStr sizeWithFontCompatible:kCurBoldFontOfSize(12)
                                       constrainedToSize:CGSizeMake(spaceXEnd - spaceXStart, CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByCharWrapping];
    UILabel *noteLabel = [[UILabel alloc] init];
    [noteLabel setFrame:CGRectMake(spaceXStart, (NSInteger) (parentFrame.size.height - size.height)/2, size.width, size.height)];
    [noteLabel setFont:kCurBoldFontOfSize(12)];
    [noteLabel setText:noteStr];
    [noteLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [noteLabel setNumberOfLines:0];
    [noteLabel setTextColor:[UIColor colorWithHex:0x757171 alpha:1.0f]];
    
    // 保存
    [viewParent addSubview:noteLabel];
}



#pragma mark Table view data source

#define HeaderColor [UIColor colorWithRed:240/255.0 green:239/255.0 blue:230/255.0 alpha:1.0]

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if(openOrCloseTemperatureMode)
        {
            return 5;
        }
        else
        {
            return 1;
        }
    }
    else if(section == 1)
    {
        if(openOrClosePM25Mode)
        {
            return 3;
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 )
    {
        if(indexPath.row == 0)
        {
            return 60;
        }
        else
        {
            return [UIDevice isRunningOn4Inch] ? 74 : 60;
        }
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            return 60;
        }
        else
        {
            return [UIDevice isRunningOn4Inch] ? 74 : 60;
        }
    }
    return 0;
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
        if(indexPath.row == 0)
        {
            static NSString *identifier = @"ApAdjustCell";
            ApAdjustCell *cell = (ApAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if(cell == nil)
            {
                UINib *nib = [UINib nibWithNibName:@"ApAdjustCell" bundle:nil];
                [tableView registerNib:nib forCellReuseIdentifier:identifier];
                cell = (ApAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.subBg.backgroundColor = [UIColor colorWithRed:apOpened ? 71.0/255.0 : 158.0/255.0
                                                         green:apOpened ? 189.0/255.0 : 158.0/255.0
                                                          blue:apOpened ? 60.0/255.0 : 158.0/255.0
                                                         alpha:1.0];
            [cell.onOffBtn addTarget:self action:@selector(aCControl:) forControlEvents:UIControlEventTouchUpInside];
            cell.title.text = @"恒温控制";
             NSString *imgName = apOpened ? @"08-开.png" : @"08-关.png";
            [cell.onOffBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            return cell;

        }
        else if(indexPath.row < 4)
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
            [self setupCellNoteSubs:[cell contentView]];
            
            return cell;
        }
        
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            static NSString *identifier = @"ApAdjustCell";
            ApAdjustCell *cell = (ApAdjustCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if(cell == nil)
            {
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
            cell.title.text = @"恒净控制";
            [cell.onOffBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            return cell;
        }
        else if(indexPath.row == 1)
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
            
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.cellIcon.image = [UIImage imageNamed:@"02-室内温度.png"];
            cell.lblContent.text = curPurgeModel.temperature;
            
            if(MainDelegate.isCustomer)
            {
                cell.leftBtn.hidden = NO;
                cell.rightBtn.hidden = NO;
            }
            else
            {
                {
                    cell.leftBtn.hidden = YES;
                    cell.rightBtn.hidden = YES;
                }
            }
            
            [cell.leftBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
            [cell.rightBtn addTarget:self action:@selector(tempControl:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            
        }
    }
    return nil;
}

#pragma mark - Alert Box Delegate




@end
