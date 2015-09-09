//
//  DeviceManagementViewController.m
//  AirManager
//

#import "DeviceManagementViewController.h"
#import "AirDevice.h"
#import "IRDevice.h"
#import "DeviceManagerHeader.h"
#import "DeviceManagerCell.h"
#import "ChangeNameViewController.h"
#import "AirDeviceBindViewController.h"
#import "IRDeviceManager.h"
#import "AirDeviceManager.h"
#import "UIDevice+Resolutions.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "SDKRequestManager.h"
#import "IRDeviceModelSelectionViewController.h"
#import "UIViewExt.h"
#import "Utility.h"
#import "AirBoxStatus.h"
#import <uSDKFramework/uSDKDevice.h>

@interface DeviceManagementViewController ()
{
    __weak IBOutlet UIView *bottomView;
    IBOutlet UIView *voiceView;
    __weak IBOutlet UILabel *voiceLabel;
    __weak IBOutlet UIButton *btnAdd;
    __weak IBOutlet UIButton *btnEdit;
    IBOutlet UITableView    *_tableView;
    
    NSOperationQueue        *queue;
    NSMutableDictionary     *allAirDevice;
    NSMutableArray          *arrUserBindedDevice;
    NSMutableArray          *hiddenDeviceList;
    NSInteger               alertTag;
    NSInteger               countDwonloadIrDevice;
    
    BOOL                    isDeleteAirBox;
    BOOL                    isEditStatus;
    
    NSDictionary                *dicCode_Title;
    NSDictionary                *dicTitle_Code;
    NSArray                     *arrTitle;
}
/**
 *  Click to show or hide the infrared device
 **/
- (void)showOrHiddenIRDevice:(UIButton *)sender;

/**
 *  delete small A
 **/
- (void)deleteAirManager:(UIButton *)sender;

/**
 *  edit small A
 **/
- (void)editAirManager:(UIButton *)sender;

/**
 *  edit IRDevice
 **/
- (void)deleteIrDevice:(UIButton *)sender;

/**
 *  edit all deviect
 **/
- (IBAction)eidtDevice:(UIButton *)sender;

/**
 *  bingding new device
 **/
- (IBAction)addNewAirDevice:(UIButton *)sender;

/**
 *  remove binded IRDevice
 **/
- (void)removeBindedIRDevice:(NSNumber *)tag;

/**
 *  remove binded small A device
 **/
- (void)removeBindedAirDevice:(NSInteger)tag;

@property (nonatomic, strong) NSMutableDictionary       *allAirDevice;
@property (nonatomic, strong) NSMutableArray            *hiddenDeviceList;
@property (nonatomic, strong) NSOperationQueue          *queue;
@property (nonatomic, strong) AirDevice                 *curAirDevice;

@end

@implementation DeviceManagementViewController

@synthesize allAirDevice;
@synthesize hiddenDeviceList;
@synthesize queue;

- (void)dealloc
{
    DDLogFunction();
   
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    [self initDicData];
    
    self.title = NSLocalizedString(@"设备管理",@"DeviceManagementViewController.m");
    self.allAirDevice = [NSMutableDictionary dictionary];
    self.hiddenDeviceList = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    
    isEditStatus = NO;
    
    if(!MainDelegate.isCustomer)
    {
        [self downloadIrDevice];
        
        if([MainDelegate isNetworkAvailable])
        {
            bottomView.hidden = NO;
        }
        else
        {
            bottomView.hidden = YES;

            [_tableView setViewHeight:_tableView.height + bottomView.height];
        }
    }
    else
    {
        [self initData];
        
        bottomView.hidden = NO;
        
        [btnAdd setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateNormal];
        [btnAdd setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateHighlighted];
        [btnAdd setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateDisabled];
        [btnEdit setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateNormal];
        [btnEdit setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateHighlighted];
        [btnEdit setTitleColor:[UIColor colorWithHex:0xbbbbbb alpha:1.0f] forState:UIControlStateDisabled];
    }
    [self customTableVIew];
    
    [Utility setExclusiveTouchAll:self.view];
}
-(void)initDicData
{
    dicTitle_Code = @{@"关闭":@"30w000",
                      @"小":@"30w001",
                      @"中":@"30w002",
                      @"大":@"30w003",
                      };
                      
    dicCode_Title = @{
                      @"30w000":@"关闭",
                      @"30w001":@"小",
                      @"30w002":@"中",
                      @"30w003":@"大",
                };
    
    arrTitle = @[@"关闭",@"小",@"中",@"大"];
}
-(void)initData
{
    arrUserBindedDevice = [[NSMutableArray alloc] init];
    
    AirDevice *device = [[AirDevice alloc] initWithAirDeviceInfo:@{@"name":NSLocalizedString(@"盒子总部",@"DeviceManagementViewController.m"),@"mac":@"C89346419D8A"}];
    [arrUserBindedDevice addObject:device];
    
    IRDevice *irDevice1 = [[IRDevice alloc] initWithDevice:@{@"brand":@"GREE",
                                                             @"brandName":NSLocalizedString(@"格力",@"DeviceManagementViewController.m"),
                                                             @"devModel":@"YBOFB2",
                                                             @"devModelName":@"YBOFB2",
                                                             @"devType":@"AC",
                                                             @"devTypeName":NSLocalizedString(@"空调",@"DeviceManagementViewController.m")}];
    
    IRDevice *irDevice2 = [[IRDevice alloc] initWithDevice:@{@"brand":@"AIGO",
                                                             @"brandName":NSLocalizedString(@"爱国者",@"DeviceManagementViewController.m"),
                                                             @"devModel":@"aigo-01",
                                                             @"devModelName":@"aigo-01",
                                                             @"devType":@"AP",
                                                             @"devTypeName":NSLocalizedString(@"空气净化器",@"DeviceManagementViewController.m")}];
    [allAirDevice setObject:@[irDevice1,irDevice2] forKey:device.mac];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) reloadTableView1
{
    DDLogFunction();
    //ybyao07-随便逛逛有测试数据
    if(!MainDelegate.isCustomer)
    {
        [self downloadIrDevice];
    }
    //ybyao07
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
- (void)reloadTableView
{
    //ybyao07
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
}

- (void)irDeviceOnAirDevice:(AirDevice *)device
{
    DDLogFunction();
    @autoreleasepool
    {
        IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
        [irDeviceManager loadIRDeviceBindOnAirDevice:device.mac
                                   completionHandler:^(NSMutableArray *array,BOOL isLoadSucceed,BOOL isBindAC)
         {
             if(isLoadSucceed)
             {
                 [allAirDevice setObject:array forKey:device.mac];
             }
             
             countDwonloadIrDevice--;
             if(countDwonloadIrDevice == 0)
             {
                [self reloadTableView];
                [MainDelegate hiddenProgressHubInView:self.view];
             }
         }];
    }
}

- (void)addTarget:(id)target action:(SEL)action onButton:(UIButton *)btn
{
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Button Action

- (IBAction)back:(id)sender
{
    DDLogFunction();
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)eidtDevice:(UIButton *)sender
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"AirConditionViewController")];
        return;
    }
    sender.selected = !sender.selected;
    isEditStatus = sender.selected;
    [self reloadTableView];
}

- (IBAction)addNewAirDevice:(UIButton *)sender
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"AirConditionViewController")];
        return;
    }
    AirDeviceBindViewController *deviceBind = [[AirDeviceBindViewController alloc]initWithNibName:@"AirDeviceBindViewController" bundle:nil];
    deviceBind.view.frame = self.view.frame;
    deviceBind.view.alpha = 0.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            deviceBind.view.alpha = 1.0;
             [MainDelegate.window addSubview:deviceBind.view];
            [self addChildViewController:deviceBind];
         }];
    });
}

- (void)deleteAirManager:(UIButton *)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])return;
    
    NSString *message = NSLocalizedString(@"确定删除所选内容",@"DeviceManagementViewController.m");
    if([arrUserBindedDevice count] == 1)
    {
        message = NSLocalizedString(@"只剩下1台绑定的设备,删除后将重新登录帐号",@"DeviceManagementViewController.m");
    }
    isDeleteAirBox = YES;
    alertTag = sender.tag;
    [AlertBox showWithMessage:message delegate:(id)self showCancel:YES];
}

- (void)deleteIrDevice:(UIButton *)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])return;
    isDeleteAirBox = NO;
    alertTag = sender.tag;
    [AlertBox showWithMessage:NSLocalizedString(@"确定解除该设备绑定",@"DeviceManagementViewController.m") delegate:(id)self showCancel:YES];
}

- (void)editAirManager:(UIButton *)sender
{
    DDLogFunction();
    sender.userInteractionEnabled = NO;//ybyao07,防止多次点击
    AirDevice *device =arrUserBindedDevice[sender.tag];
    ChangeNameViewController *changeName = [[ChangeNameViewController alloc] initWithNibName:@"ChangeNameViewController" bundle:nil];
    DDLogCVerbose(@"******%@",device.mac);
    changeName.airDevice = device;
    [self.navigationController pushViewController:changeName animated:YES];
}

- (void)showSelectDevice:(UIButton *)sender
{
    DDLogFunction();
    AirDevice *device = arrUserBindedDevice[sender.tag];
    
    if([[SDKRequestManager sharedInstance] isWaitConnect:device.mac])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"空气盒子不在线，请稍后再试",@"DeviceManagementViewController.m")];
        return;
    }
    
    NSMutableArray *array = allAirDevice[device.mac];
    
    if(array.count == 0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"选择设备类型", @"DeviceManagementViewController.m")
                                      delegate:(id)self
                                      cancelButtonTitle:NSLocalizedString(@"取消", @"DeviceManagementViewController.m")
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"空调", @"DeviceManagementViewController.m") , NSLocalizedString(@"净化器", @"DeviceManagementViewController.m") ,nil];
        actionSheet.tag = sender.tag;
        [actionSheet showInView:self.view];
    }
    else if(array.count == 1)
    {
        IRDevice *irDevice = array[0];
        NSString *type = [irDevice.devType isEqualToString:kDeviceTypeAC] ? kDeviceTypeAP : kDeviceTypeAC;
        [self addDeviceType:type withAirDeviceTag:sender.tag];
    }

}

- (void)addDeviceType:(NSString *)type withAirDeviceTag:(NSInteger)tag
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = @"IRDeviceModelSelectionViewController";
        IRDeviceModelSelectionViewController *vc = [[NSClassFromString(name) alloc] initWithNibName:name bundle:nil];
        vc.deviceType = type;
        vc.selectedAirDevice = arrUserBindedDevice[tag];
        vc.view.frame = self.view.frame;
        vc.view.alpha = 0.0;
        [MainDelegate.window addSubview:vc.view];
        [self addChildViewController:vc];
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.alpha = 1.0;
        }];
    });

}

- (void)showOrHiddenIRDevice:(UIButton *)sender
{
    DDLogFunction();
    AirDevice *device = arrUserBindedDevice[sender.tag];
    if([hiddenDeviceList containsObject:device.mac])
    {
        [hiddenDeviceList removeObject:device.mac];
    }
    else
    {
        [hiddenDeviceList addObject:device.mac];
    }
    [self reloadTableView];
}

- (void)openView:(UIView *)view completion:(void(^)())complete
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       view.frame = _baseview.frame;
                       view.alpha = 0;
                       [UIView animateWithDuration:0.2 animations:^
                        {
                            view.alpha = 1;
                            [self.view addSubview:view];
                        } completion:^(BOOL finished)
                        {
                            if (finished && complete)
                            {
                                complete();
                            }
                        }];
                   });
}

- (void)closeView:(UIView *)view completion:(void(^)())complete
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:0.3 animations:^
                        {
                            view.alpha = 0;
                        } completion:^(BOOL finished)
                        {
                            [view removeFromSuperview];
                            if (finished && complete)
                            {
                                complete();
                            }
                        }];
                   });
}


- (void)settingVoice:(UIButton *)sender
{
    DDLogFunction();
    if(MainDelegate.isCustomer)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"您还没有登录",@"AirConditionViewController")];
        return;
    }
    
    NSUInteger tag = sender.tag;
    _curAirDevice = arrUserBindedDevice[tag];
    if(_curAirDevice.voiceValue.length>0)
    {
        voiceLabel.text = [dicTitle_Code objectForKey:_curAirDevice.voiceValue];
    }
    else
    {
        voiceLabel.text = @"关闭";
    }
    [self openView:voiceView completion:nil];
}

- (IBAction)rightButtonClick:(id)sender
{
    DDLogFunction();
    NSInteger index = [arrTitle indexOfObject:voiceLabel.text];
    index ++;
    if(index > ([arrTitle count] -1))
    {
        index = [arrTitle count] -1;
    }
    
    voiceLabel.text = [arrTitle objectAtIndex:index];
}

- (IBAction)leftButtonClick:(id)sender
{
    NSInteger index = [arrTitle indexOfObject:voiceLabel.text];
    index --;
    if(index < 0)
    {
        index = 0;
    }
    voiceLabel.text = [arrTitle objectAtIndex:index];
}

- (IBAction)cancelButtonClick:(id)sender
{
     [self closeView:voiceView completion:nil];
}

- (IBAction)okButtonClick:(id)sender
{
    DDLogFunction();
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[MainDelegate.curBindDevice.mac];
    
    DDLogCVerbose(@" 当前盒子的状态 -----> device.netType = @%d",device.netType);
    if(device.netType == NET_TYPE_REMOTE)
    {
        UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                           message:@"弹窗提示“音量设置需将您的盒子与手机置于同一无线路由器下"
                                                          delegate:nil
                                                 cancelButtonTitle:NSLocalizedString(@"知道了",@"CityViewController.m")
                                                 otherButtonTitles:nil];
        [pwdAlert show];
    }
    else
    {
        NSString *voiceCode = [dicCode_Title objectForKey:voiceLabel.text];
        
        uSDKErrorConst errorConst = [self settingAirBoxVoiceValue:voiceCode];
        
        if(errorConst == RET_USDK_OK)
        {
            _curAirDevice.voiceValue = voiceCode;
            [self closeView:voiceView completion:nil];
        }
        else
        {
            UIAlertView *pwdAlert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                               message:@"音量设置失败，请点击“确定”按钮重试"
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"确定",@"CityViewController.m")
                                                     otherButtonTitles:NSLocalizedString(@"取消",@"CityViewController.m"),nil];
            [pwdAlert setTag:1000];
            [pwdAlert show];
        }
    }
}

static int cmdsnVoice = 0;
- (uSDKErrorConst )settingAirBoxVoiceValue:(NSString *)voiceCode
{
    DDLogFunction();
    cmdsnVoice = (cmdsnVoice + 1) / 10000;
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[_curAirDevice.mac];
    uSDKDeviceAttribute *attr = [[uSDKDeviceAttribute alloc] init];
    attr.attrName = @"20w00o";
    attr.attrValue = voiceCode;
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:attr,nil];
    uSDKErrorConst errorConst = [device execDeviceOperation:array withCmdSN:cmdsnVoice withGroupCmdName:nil];
    DDLogCVerbose(@"Set air box to auto status result : %d",errorConst);
    return errorConst;
}

#pragma mark - UITableViewDelegate view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrUserBindedDevice.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AirDevice *device = arrUserBindedDevice[section];
    if([hiddenDeviceList containsObject:device.mac])
    {
        return 0;
    }
    NSMutableArray *array = allAirDevice[device.mac];
    return [array count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AirDevice *device = arrUserBindedDevice[section];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DeviceManagerHeader" owner:self options:nil];
    DeviceManagerHeader *headerView = [nib objectAtIndex:0];
    [headerView editStatus:isEditStatus];
    headerView.textLbl.text = NSLocalizedString(device.name,@"DeviceManagementViewController1.m");//ybyao
    headerView.textLbl.frame = CGRectMake(headerView.textLbl.frame.origin.x,
                                          headerView.textLbl.frame.origin.y - 10,
                                          headerView.textLbl.frame.size.width,
                                          headerView.textLbl.frame.size.height);
    headerView.editBtn.tag = section;
    headerView.accessoryBtn.tag = section;
    headerView.selectedBtn.tag = section;
    headerView.macLbl.text = [NSString stringWithFormat:@"MAC:%@",device.mac];
    headerView.macLbl.frame = CGRectMake(headerView.macLbl.frame.origin.x,
                                          headerView.macLbl.frame.origin.y - 8,
                                          headerView.macLbl.frame.size.width,
                                          headerView.macLbl.frame.size.height);
    headerView.macLbl.hidden = NO;
    [self addTarget:self action:@selector(deleteAirManager:) onButton:headerView.editBtn];
    [self addTarget:self action:@selector(showOrHiddenIRDevice:) onButton:headerView.selectedBtn];
    
    headerView.voiceBtn.hidden = ![Utility isVoiceAirDevice:device];
    headerView.voiceBtn.tag = section;
    [self addTarget:self action:@selector(settingVoice:) onButton:headerView.voiceBtn];
    
    if (isEditStatus)
    {
        [headerView.accessoryBtn setImage:[UIImage imageNamed:@"btn_right.png"] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(editAirManager:) onButton:headerView.accessoryBtn];
    }
    else
    {
        NSMutableArray *array = allAirDevice[device.mac];
        if([MainDelegate isNetworkAvailable])
        {
            headerView.accessoryBtn.hidden = (array.count == 2) ? YES : NO;
        }
        else
        {
            headerView.accessoryBtn.hidden = YES;
        }
        
        [headerView.accessoryBtn setImage:[UIImage imageNamed:@"addDevice.png"] forState:UIControlStateNormal];
        
        headerView.accessoryBtn.enabled = MainDelegate.isNetworkAvailable;
        [self addTarget:self action:@selector(showSelectDevice:) onButton:headerView.accessoryBtn];
    }
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DeviceManagerCell";
    DeviceManagerCell *cell = (DeviceManagerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"DeviceManagerCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = (DeviceManagerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    AirDevice *device = arrUserBindedDevice[indexPath.section];
    NSMutableArray *array = allAirDevice[device.mac];
    IRDevice *irDevice = array[indexPath.row];
    cell.textLbl.text = [NSString stringWithFormat:@"%@_%@_%@",NSLocalizedString(irDevice.brandName,@"DeviceManagementViewController1.m"),NSLocalizedString(irDevice.devTypeName,@"DeviceManagementViewController1.m"),NSLocalizedString(irDevice.devModelName,@"DeviceManagementViewController1.m")];//ybyao

    cell.editBtn.tag = indexPath.section * 10000 + indexPath.row;
    [cell editStatus:isEditStatus];
    [self addTarget:self action:@selector(deleteIrDevice:) onButton:cell.editBtn];
    
    return cell;
}


#pragma mark - Alert Box Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1000:
        {
            if(buttonIndex == [alertView cancelButtonIndex])
            {
                // 重新设置音量
                [self okButtonClick:nil];
            }
//            else
//            {
//                [self closeView:voiceView completion:nil];
//            }
        }
            break;
    }
}

- (void)alertBoxOkButtonOnClicked
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    if(isDeleteAirBox)
    {
        [self removeBindedAirDevice:alertTag];
    }
    else
    {
        [self removeBindedIRDevice:@(alertTag)];
    }
}

- (void)removeBindedIRDevice:(NSNumber *)tag
{
    DDLogFunction();
    int section = [tag integerValue] / 10000;
    int row = [tag integerValue] % 10000;
    AirDevice *device = arrUserBindedDevice[section];
    __block NSMutableArray *array = allAirDevice[device.mac];
    IRDevice *irDevice = array[row];
    
    IRDeviceManager *irDeviceManager = [[IRDeviceManager alloc] init];
    [irDeviceManager removeBindIRDevice:irDevice onAirDevice:device completionHandler:^(BOOL isSucceed){
        if(isSucceed)
        {
            [array removeObject:irDevice];
            [allAirDevice setObject:array forKey:device.mac];
            [self reloadTableView];
            if(!isDeleteAirBox)
            {
                [MainDelegate hiddenProgressHubInView:self.view];
            }
            
            [NotificationCenter postNotificationName:IRDevicesChangedNotification object:device.mac];
        }
        else
        {
            if(!isDeleteAirBox)
            {
                [MainDelegate hiddenProgressHubInView:self.view];
                [AlertBox showWithMessage:NSLocalizedString(@"删除失败",@"DeviceManagementViewController.m")];
            }
        }
    }];
}



- (void)removeBindedAirDevice:(NSInteger)tag
{
    DDLogFunction();
    AirDevice *device = arrUserBindedDevice[tag];
//    NSMutableArray *array = allAirDevice[device.mac];
    
    AirDeviceManager *airDeviceManager = [[AirDeviceManager alloc] init];
    [airDeviceManager removeBindedAirDevice:device completionHandler:^(BOOL isSucceed){
        
        if(!isSucceed)
        {
            [MainDelegate hiddenProgressHubInView:self.view];
            [AlertBox showWithMessage:NSLocalizedString(@"空气盒子解除绑定失败!",@"DeviceManagementViewController.m")];
            return;
        }
       
        NSArray *macList = @[arrUserBindedDevice[tag]];
        [[SDKRequestManager sharedInstance] unSubscribeDeviceNotification:macList];
        [arrUserBindedDevice removeObjectAtIndex:tag];
        [allAirDevice removeObjectForKey:device.mac];
        if([arrUserBindedDevice count] == 0)
        {
            [NotificationCenter postNotificationName:AllAirDeviceRemovedNotificationByDeleted object:nil];
        }
        else
        {
            if(![arrUserBindedDevice containsObject:MainDelegate.curBindDevice])
            {
                MainDelegate.curBindDevice = arrUserBindedDevice[0];
            }
            [self reloadTableView];
            [NotificationCenter postNotificationName:AirDeviceRemovedNotification object:nil];
        }
        
        // 更新缓存
        [NotificationCenter postNotificationName:AirDevicesChangedNotification object:nil];
        
        [MainDelegate hiddenProgressHubInView:self.view];
    }];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLogFunction();
    if (buttonIndex == 0)
    {
        [self addDeviceType:kDeviceTypeAC withAirDeviceTag:actionSheet.tag];
    }
    else if (buttonIndex == 1)
    {
        [self addDeviceType:kDeviceTypeAP withAirDeviceTag:actionSheet.tag];
    }
}


#pragma mark - Private Methods

- (void)downloadIrDevice
{
    DDLogFunction();
    arrUserBindedDevice = MainDelegate.loginedInfo.arrUserBindedDevice;
    countDwonloadIrDevice =arrUserBindedDevice.count;
    
    if(countDwonloadIrDevice > 0)
    {
        [MainDelegate showProgressHubInView:self.view];
    }
    
    for (int i = 0; i < countDwonloadIrDevice; i++)
    {
        AirDevice *device = arrUserBindedDevice[i];
        [queue addOperation:[MainDelegate operationWithTarget:self selector:@selector(irDeviceOnAirDevice:) object:device]];
    }
}


- (void)customTableVIew
{
    DDLogFunction();
    //set the line TableView separator
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footerView;
}


@end
