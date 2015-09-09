//
//  IRStudyViewController.m
//  AirManager
//

#import "CustomModelViewController.h"
#import <uSDKFramework/uSDKDevice.h>
#import "SDKRequestManager.h"
#import "AppDelegate.h"
#import "AirDevice.h"
#import "AlertBox.h"
#import "CustomModelCell.h"
#import "IRDeviceModelSelectionViewController.h"
#import "UserLoginedInfo.h"
#import "UIViewExt.h"
#import "UIDevice+Resolutions.h"

#define kIRVersion @"IRVersion"

typedef enum{
    kAlertBoxNotFindIR = 0,
    kAlertBoxCanNotIRStudy
}AlertBoxOkType;

@interface CustomModelViewController ()
{
    IBOutlet UIView *step1;
    IBOutlet UIView *step2;
    IBOutlet UIView *step3;
    IBOutlet UIView *step4;
    
    IBOutlet UIView *step3BodyView;
    
    __weak IBOutlet UIButton *addBtn1;
    __weak IBOutlet UIButton *addBtn2;
    __weak IBOutlet UIButton *editBtn;
    IBOutlet UIView *noIRcodeView;
    
    IBOutlet UIImageView *signalView;
    IBOutlet UITableView *_tableView;
    IBOutlet UITextField *txFIRCodeName;
    BOOL    isDelete;
    NSIndexPath *idxPath;
    
    NSInteger               autoStudyWaitTime;
    NSTimer                 *studyWaitTimer;
    AlertBoxOkType          alertBoxOkType;
    BOOL                    isCountDowning;
    BOOL                    pageIsDisplay;
}

@property (strong, nonatomic) NSMutableArray        *irCodes;               //IRCode list
@property (strong, nonatomic) NSString              *autoStudyCode;         //IRCode
@property (strong, nonatomic) NSMutableArray        *irCodes_addOutLine;               //IRCode list
@property (strong, nonatomic) NSMutableArray        *irCodes_DeleteOutLine;               //IRCode list
@property (strong, nonatomic) NSMutableArray        *irCodes_OnLine;               //IRCode list
@property (nonatomic, assign) NSInteger keyboardHeight;                 // 键盘高度


/**
 *  download IRCode List
 */
- (void)downloadIRCodeList;

/**
 *  Reload tableview
 */
- (void)reloadTableView;

/**
 *  Custom TableView
 *
 *  @param tableView hide the extra dividers
 */
- (void)customTableView:(UITableView *)tableView;

/**
 *  Open the IR study mode
 */
- (uSDKErrorConst)openAirBoxAutoStudyModel:(BOOL)open;

/**
 *  Remote returned IR code
 *
 *  @param notify IR Code
 */
- (void)receiveAutoStudyIrCode:(NSNotification *)notify;

/**
 *  delete selected IR study
 */
- (void)deleteCurrentIRStudy:(UIButton *)sender;

/**
 *  get IR code list
 *  @return local IR code list
 */
- (NSMutableArray *)localIRCodeList;

/**
 *  Open View
 *
 *  @param view - view object
 *  @param complete - Open view after Callback
 */
- (void)openView:(UIView *)view completion:(void(^)())complete;

/**
 *  Close View
 *
 *  @param view - view object
 *  @param complete - Close view after Callback
 */
- (void)closeView:(UIView *)view completion:(void(^)())complete;

/**
 *  edit ir study list
 */
- (IBAction)editButtonOnClicked:(UIButton *)sender;

/**
 *  Add IRCode
 *
 *  @param sender event object
 */
- (IBAction)addIRCodeButtonOnClicked:(id)sender;

/**
 *  Complete IR study
 *
 *  @param sender event object
 */
- (IBAction)completeButtonOnClicked:(id)sender;

/**
 *  back previous page
 *
 *  @param sender event objecdt
 */
- (IBAction)backButtonOnClicked:(id)sender;

/**
 *  cacen IR study and back previous page
 *
 *  @param sender event objecdt
 */
- (IBAction)cancenButtonOnClicked:(id)sender;

/**
 *  start IR study
 *
 *  @param sender event object
 */
- (IBAction)startIRStudyButtonOnClicked:(id)sender;

/**
 *  store IR code
 *
 *  @param sender event object
 */
- (IBAction)storeIRCodeButtonOnClicked:(id)sender;

/**
 *  continue IR study
 *
 *  @param sender event object
 */
- (IBAction)continueIRStudyButtonOnClicked:(id)sender;

@end

@implementation CustomModelViewController


#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    NSArray *images = @[[UIImage imageNamed:@"ir_signal1.png"],
                        [UIImage imageNamed:@"ir_signal2.png"],
                        [UIImage imageNamed:@"ir_signal3.png"]
                        ];
    signalView.animationImages = images;
    signalView.animationDuration = 1;
    signalView.animationRepeatCount = 0;
    [signalView startAnimating];
    
    isDelete = NO;
    
    [self customTableView:_tableView];
    self.irCodes = [NSMutableArray array];
    self.irCodes_addOutLine = [[NSMutableArray alloc] init];
    self.irCodes_DeleteOutLine = [[NSMutableArray alloc] init];
    self.irCodes_OnLine = [[NSMutableArray alloc] init];
    [self initData];
    [self performSelector:@selector(downloadIRCodeList) withObject:nil afterDelay:0.1];
    
    pageIsDisplay = YES;
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)initData
{
    NSMutableArray *localCodesAdd =[NSMutableArray arrayWithArray:[UserDefault objectForKey:IRCodeAddOutline(self.macID,MainDelegate.loginedInfo.loginID)]];
    if (localCodesAdd)
    {
        self.irCodes_addOutLine = localCodesAdd;
    }
    
    NSMutableArray *localCodesDelete = [NSMutableArray arrayWithArray:[UserDefault objectForKey:IRCodeDeleteOutLine(self.macID,MainDelegate.loginedInfo.loginID)]];
    if (localCodesAdd)
    {
        self.irCodes_DeleteOutLine = localCodesDelete;
    }
    
    NSMutableArray *localCodesOnline = [NSMutableArray arrayWithArray:[UserDefault objectForKey:IRCodeOnline(self.macID,MainDelegate.loginedInfo.loginID)]];
    if (localCodesOnline)
    {
        self.irCodes_OnLine = localCodesOnline;
    }
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
//    [NotificationCenter addObserver:self
//                           selector:@selector(keyboardFrameWillChanged:)
//                               name:UIKeyboardWillChangeFrameNotification
//                             object:nil];
    
    [self regKeyboardNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
   
    pageIsDisplay = NO;
    [super viewWillDisappear:animated];
    [self stopCountStudyWaitTime];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unregKeyboardNotification];
}

- (void)regKeyboardNotification
{
    // 键盘显示消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    // 键盘隐藏消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


// 键盘显示
- (void)keyboardDidShow:(NSNotification *)notification
{
    if(_keyboardHeight == 0)
    {
        NSValue *frameEnd = nil;
        
        frameEnd = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        // 3.2以后的版本
        if(frameEnd != nil)
        {
            // 键盘的Frame
            CGRect keyBoardFrame;
            [frameEnd getValue:&keyBoardFrame];
            
            // 保存键盘的高度
            [self setKeyboardHeight:keyBoardFrame.size.height];
        }
        else
        {
            // 保存键盘的高度
            [self setKeyboardHeight:216];
        }
        [UIView animateWithDuration:0.2 animations:^{
            // 修正TableView的高度
            [self.view setViewY:(self.view.frame.origin.y - _keyboardHeight + 40)];
        } completion:^(BOOL finished){
        }];
        
    }
}

// 键盘消失
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view setViewY:(self.view.frame.origin.y + _keyboardHeight - 40)];
    [self setKeyboardHeight:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Responder methods
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([txFIRCodeName isFirstResponder])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [txFIRCodeName resignFirstResponder];
        });
    }
    [super touchesEnded:touches withEvent:event];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark - Private

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
    DDLogCVerbose(@"changeWaitTime in ir study %d",autoStudyWaitTime);
    if(!isCountDowning)return;
    if(autoStudyWaitTime <= 0)
    {
        [self removeAutoStudyNotification];
        [self stopCountStudyWaitTime];
        [AlertBox showWithMessage:NSLocalizedString(@"没有收到红外命令",@"CustomModelViewController.m") delegate:(id)self showCancel:NO];
        // 关闭盒子的红外学习状态
        [self openAirBoxAutoStudyModel:NO];
        alertBoxOkType = kAlertBoxNotFindIR;
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

- (void)downloadIRCodeList
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    NSDictionary *bodyDict = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:bodyDict];
    
    /*
     NSString *irVersion = [UserDefault objectForKey:kIRVersion];
     if (isEmptyString(irVersion))
     {
     irVersion = @"0";
     }
     */
    
    NSString *userID     = MainDelegate.loginedInfo.userID;
    
    NSURLRequest *request = [MainDelegate requestUrl:SERVER_GET_IRCODE(self.macID,userID,@"10") method:HTTP_POST body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                            completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         
         if (connectionError)
         {
             self.irCodes = [self localIRCodeList];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->downloadIRCodeList接口信息%@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0 && ![result[@"userIRCodes"] isEqual:[NSNull null]])
             {
                 self.irCodes = [NSMutableArray arrayWithArray:isObject(result[@"userIRCodes"])?result[@"userIRCodes"]:[NSArray array]];
                 [UserDefault setObject:self.irCodes forKey:IRCodeOnline(self.macID,MainDelegate.loginedInfo.loginID)];
                 [UserDefault synchronize];
             }
         }
         [self reloadTableView];
     }];
}

- (void)customTableView:(UITableView *)tableView
{
    DDLogFunction();
    UIView *footerView = [[UIView allocWithZone:nil] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
}

- (void)reloadTableView
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.irCodes count] > 0)
        {
            [self.irCodes sortUsingComparator:^(NSDictionary *obj1,NSDictionary *obj2){
                return [obj1[@"keycode"] compare:obj2[@"keycode"] options:NSCaseInsensitiveSearch];
            }];
            _tableView.hidden = NO;
            noIRcodeView.hidden = YES;
            addBtn2.hidden = NO;
            editBtn.hidden = NO;
            addBtn1.hidden = YES;
            [_tableView reloadData];
        }
        else
        {
            addBtn2.hidden = YES;
            editBtn.hidden = YES;
            addBtn1.hidden = NO;
            noIRcodeView.hidden = NO;
            _tableView.hidden = YES;
        }
    });
}

static int cmdsn = 0;
- (uSDKErrorConst)openAirBoxAutoStudyModel:(BOOL)open
{
    DDLogFunction();
    cmdsn = (cmdsn + 1) / 10000;
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[MainDelegate.curBindDevice.mac];
    uSDKDeviceAttribute *attr = [[uSDKDeviceAttribute alloc] init];
    attr.attrName = open ? @"20w00i" : @"20w00j";
    attr.attrValue = @"";
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:attr,nil];
    DDLogCVerbose(@"sdkDevice execDeviceOperation 开启红外学习模式 开始: %@",@">>>>>>>");
    uSDKErrorConst errorConst = [device execDeviceOperation:array withCmdSN:cmdsn withGroupCmdName:nil];
    DDLogCVerbose(@"sdkDevice execDeviceOperation 开启红外学习模式 开始: %@",@">>>>>>>");
    DDLogCVerbose(@"Set air box to auto status result : %d",errorConst);
    return errorConst;
}

- (void)receiveAutoStudyIrCode:(NSNotification *)notify
{
    DDLogFunction();
    DDLogCVerbose(@"红外学习收到的红外码通知 :%@",notify.object);
    [self stopCountStudyWaitTime];
    [self removeAutoStudyNotification];
    self.autoStudyCode = notify.object;
    [self openView:step3 completion:^{
        [self closeView:step2 completion:nil];
    }];
}

- (void)deleteCurrentIRStudy:(UIButton *)sender
{
    DDLogFunction();
    NSInteger idx = sender.tag;
    NSDictionary *irCode = [self.irCodes objectAtIndex:idx];
    [MainDelegate showProgressHubInView:self.view];
    
    NSString *userID     = MainDelegate.loginedInfo.userID;
    NSString *keyCode    = irCode[@"keycode"];
    NSString *sequenceID = [MainDelegate sequenceID];
    
    NSURLRequest *request = [MainDelegate requestUrl:SERVER_DEL_IRCODE(self.macID, userID, keyCode, sequenceID) method:HTTP_DELETE body:@""];
    
    DDLogCVerbose(@"request IR code : %@",SERVER_DEL_IRCODE(self.macID, userID, keyCode, sequenceID));
    
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         NSDictionary *result = [MainDelegate parseJsonData:data];
         result = isObject(result) ? result : nil;
         DDLogCVerbose(@"--->Del IR code : %@",result);
         
         if (connectionError)
         {
             if([MainDelegate isNetworkAvailable])
             {
                 [AlertBox showWithMessage:NSLocalizedString(@"删除红外码失败，请稍后再试",@"CustomModelViewController.m")];
             }
             else
             {
                 [self removeOneIRCode:idx isOnline:NO];
                 [self reloadTableView];
             }
         }
         else
         {
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [self removeOneIRCode:idx isOnline:YES];;
                 [self reloadTableView];
             }
             else
             {
                 if(result)
                 {
                     NSString *errorInfo = [MainDelegate erroInfoWithErrorCode:result[HttpReturnCode]];
                     if (errorInfo == nil)
                     {
                         errorInfo = isObject(result[HttpReturnInfo]) ? result[HttpReturnInfo] : NSLocalizedString(@"删除红外码失败，请稍后再试", @"CustomModelViewController.m") ;
                     }
                     [AlertBox showWithMessage:errorInfo];
                 }
             }
         }
     }];
}

- (NSMutableArray *)localIRCodeList
{
    DDLogFunction();
    _irCodes_OnLine = [NSMutableArray arrayWithArray:[UserDefault objectForKey:IRCodeOnline(self.macID,MainDelegate.loginedInfo.loginID)]];
    NSMutableArray *oldCodes = [[NSMutableArray alloc] init];
    if (_irCodes_OnLine)
    {
        [oldCodes addObjectsFromArray:_irCodes_OnLine];
    }
    
    _irCodes_addOutLine = [NSMutableArray arrayWithArray:[UserDefault objectForKey:IRCodeAddOutline(self.macID,MainDelegate.loginedInfo.loginID)]];
    
    if (_irCodes_addOutLine)
    {
        [oldCodes addObjectsFromArray:_irCodes_addOutLine];
    }
    
    return oldCodes;
}

-(void) addOneIRCode:(NSDictionary *)dicIRCode isOnline:(BOOL)isOnline
{
    DDLogFunction();
    if(isOnline)
    {
        [_irCodes_OnLine addObject:dicIRCode];
        
        [UserDefault setObject:_irCodes_OnLine forKey:IRCodeOnline(self.macID,MainDelegate.loginedInfo.loginID)];
        [UserDefault synchronize];
    }
    else
    {
        [_irCodes_addOutLine addObject:dicIRCode];
        [UserDefault setObject:_irCodes_addOutLine forKey:IRCodeAddOutline(self.macID,MainDelegate.loginedInfo.loginID)];
        [UserDefault synchronize];
    }
    [self.irCodes addObject:dicIRCode];
}

-(void) removeOneIRCode:(NSInteger)index isOnline:(BOOL)isOnline
{
    DDLogFunction();
    NSDictionary *dicIRCode = [self.irCodes objectAtIndex:index];
    if([_irCodes_OnLine containsObject:dicIRCode])
    {
        [_irCodes_OnLine removeObject:dicIRCode];
        
        if(!isOnline)
        {
            [_irCodes_DeleteOutLine addObject:dicIRCode];
            [UserDefault setObject:_irCodes_DeleteOutLine forKey:IRCodeDeleteOutLine(self.macID,MainDelegate.loginedInfo.loginID)];
        }
        
        [UserDefault setObject:_irCodes_OnLine forKey:IRCodeOnline(self.macID,MainDelegate.loginedInfo.loginID)];
        [UserDefault synchronize];
    }
    else if([_irCodes_addOutLine containsObject:dicIRCode])
    {
        [_irCodes_addOutLine removeObject:dicIRCode];
        [UserDefault setObject:_irCodes_addOutLine forKey:IRCodeAddOutline(self.macID,MainDelegate.loginedInfo.loginID)];
        [UserDefault synchronize];
    }
    
    [self.irCodes removeObjectAtIndex:index];
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


#pragma mark - IBActions


- (IBAction)editButtonOnClicked:(UIButton *)sender
{
    DDLogFunction();
    sender.selected = !sender.selected;
    isDelete = sender.selected;
    [self reloadTableView];
}

- (IBAction)addIRCodeButtonOnClicked:(id)sender
{
    DDLogFunction();
    [self openView:step1 completion:nil];
}

- (IBAction)completeButtonOnClicked:(id)sender
{
    DDLogFunction();
    [self closeView:step4 completion:^{
        //[self reloadTableView];
    }];
}

- (IBAction)backButtonOnClicked:(id)sender
{
    DDLogFunction();
    [self removeAutoStudyNotification];
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            if ([[self parentViewController] isKindOfClass:[IRDeviceModelSelectionViewController class]])
            {
                IRDeviceModelSelectionViewController *irdeviceModel = (IRDeviceModelSelectionViewController *)[self parentViewController];
                [irdeviceModel backButtonOnClicked:sender];
            }
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });
}

- (IBAction)cancenButtonOnClicked:(id)sender
{
    DDLogFunction();
    //[self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self stopCountStudyWaitTime];
    dispatch_async(dispatch_queue_create("CloseStudyModel", NULL), ^{
        [self openAirBoxAutoStudyModel:NO];
    });
    [self backButtonOnClicked:sender];
}

- (IBAction)startIRStudyButtonOnClicked:(id)sender
{
    DDLogFunction();
    [self registeAutoStudyNotification];
    uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[MainDelegate.curBindDevice.mac];
    DDLogCVerbose(@"device.netType : %d",device.netType);
    if(device.netType == NET_TYPE_REMOTE)
    {
        [self removeAutoStudyNotification];
        [AlertBox showWithMessage:NSLocalizedString(@"红外学习需手机与空气盒子连接至同一无线路由器，请连接后再次尝试",@"CustomModelViewController.m")
                         delegate:(id)self
                       showCancel:NO];
        alertBoxOkType = kAlertBoxCanNotIRStudy;
        return;
    }
    
    [self openView:step2 completion:^{
        dispatch_async(dispatch_queue_create("OpenStudyModel", NULL), ^{
            [self openAirBoxAutoStudyModel:YES];
            if(pageIsDisplay)
            {
                [self performSelectorOnMainThread:@selector(startCountStudyWaitTime) withObject:nil waitUntilDone:NO];
            }
        });
        [self closeView:step1 completion:nil];
    }];
}

- (IBAction)storeIRCodeButtonOnClicked:(id)sender
{
    DDLogFunction();
    if (isEmptyString(txFIRCodeName.text))
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入指令名称",@"CustomModelViewController.m")];
        return;
    }
    
    for (NSDictionary *obj in self.irCodes)
    {
        if ([obj[@"name"] isEqualToString:txFIRCodeName.text])
        {
            [AlertBox showWithMessage:NSLocalizedString(@"名称重复", @"CustomModelViewController.m") ];
            return;
        }
    }
    
    [MainDelegate showProgressHubInView:self.view];
    
    NSString *keyCode = [[[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByReplacingOccurrencesOfString:@"." withString:@""] substringToIndex:13];
    NSDictionary *bodyDict =  @{@"userIRCode":@{@"ircode":self.autoStudyCode,
                                                @"name":txFIRCodeName.text,
                                                @"keycode":keyCode},
                                @"sequenceId":  [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:bodyDict];
    NSString *userID = MainDelegate.loginedInfo.userID;
    NSURLRequest *request =[MainDelegate requestUrl:SERVER_SET_IRCODE(self.macID, userID) method:HTTP_POST body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         NSDictionary *result = [MainDelegate parseJsonData:data];
         DDLogCVerbose(@"--->SET irCode List : %@",result);
         result = isObject(result) ? result : nil;
         if (connectionError)
         {
             if([MainDelegate isNetworkAvailable])
             {
                 [AlertBox showWithMessage:NSLocalizedString(@"保存红外码失败，请稍后再试",@"CustomModelViewController.m")];
             }
             else
             {
                 NSDictionary *dictCode = @{@"ircode":isObject(self.autoStudyCode)?self.autoStudyCode:@"",
                                            @"name":txFIRCodeName.text,
                                            @"keycode":keyCode,
                                            @"irversion":@""};
                 [self addOneIRCode:dictCode isOnline:NO];
                 [self reloadTableView];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self openView:step4 completion:^{
                         [self closeView:step3 completion:^{
                             txFIRCodeName.text = @"";
                             self.autoStudyCode = @"";
                         }];
                     }];
                 });
             }
             
         }
         else
         {
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSDictionary *dictCode = @{@"ircode":isObject(result[@"ircode"])?result[@"ircode"]:@"",
                                            @"name":txFIRCodeName.text,
                                            @"keycode":keyCode,
                                            @"irversion":isObject(result[@"irversion"])?result[@"irversion"]:@""};
                 [self addOneIRCode:dictCode isOnline:YES];
                 [self reloadTableView];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self openView:step4 completion:^{
                         [self closeView:step3 completion:^{
                             txFIRCodeName.text = @"";
                             self.autoStudyCode = @"";
                         }];
                     }];
                 });
                 
             }
         }
     }];
}

- (IBAction)continueIRStudyButtonOnClicked:(id)sender
{
    DDLogFunction();
    [self registeAutoStudyNotification];
    
    [self openView:step2 completion:^{
        dispatch_async(dispatch_queue_create("OpenStudyModel", NULL), ^{
            [self openAirBoxAutoStudyModel:YES];
            if(pageIsDisplay)
            {
                [self performSelectorOnMainThread:@selector(startCountStudyWaitTime) withObject:nil waitUntilDone:NO];
            }
        });
        [self closeView:step4 completion:nil];
    }];
}


#pragma mark - Protocol conformance

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.irCodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    CustomModelCell *cell = (CustomModelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"CustomModelCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (CustomModelCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    [cell deleteStatus:isDelete];
    NSInteger tag = self.irCodes.count - indexPath.row - 1;
    cell.deleteButton.tag = tag;
    [cell.deleteButton addTarget:self action:@selector(deleteCurrentIRStudy:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.lblName.text = NSLocalizedString(self.irCodes[tag][@"name"],"CustomModelViewController1.m");//ybyao
    return cell;
}

static int sendsn = 0;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger tag = self.irCodes.count - indexPath.row - 1;

        sendsn = (sendsn + 1) / 10000;
        
        uSDKDevice *device = [SDKRequestManager sharedInstance].sdkReturnedDeviceDict[self.macID];
        
        uSDKDeviceAttribute *attr = [[uSDKDeviceAttribute alloc] init];
        attr.attrName = SendIRCommand;
        attr.attrValue = isObject(self.irCodes[tag][@"ircode"]) ? self.irCodes[tag][@"ircode"] : @"";
        
        DDLogCVerbose(@"---------%@",self.irCodes[tag]);
        DDLogCVerbose(@"Send ir code : %@",self.irCodes[tag][@"ircode"]);
        
        NSMutableArray *exeList = [NSMutableArray arrayWithObject:attr];
        uSDKErrorConst error = [device execDeviceOperation:exeList withCmdSN:cmdsn withGroupCmdName:nil];
        
        if (error == RET_USDK_OK)
        {
            //ybyao07,更改标题名称
//            [AlertBox showWithMessage:NSLocalizedString(@"操作指令发送成功",@"CustomModelViewController.m")];
                   [AlertBox showHintWithMessage:NSLocalizedString(@"操作指令发送成功",@"CustomModelViewController.m")];
        }
        else
        {
            idxPath = indexPath;
            [AlertBox showIsRetryBoxWithDelegate:(id)self];
        }
    });
}


#pragma mark - UITextFieldDelegate

//- (void)textFieldDidBeginEditing:(UITextField *)textField;
//{
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    NSString *text = [txFIRCodeName.text stringByReplacingCharactersInRange:range withString:string];
    if ([text length] > 32)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Alert Box Delegate

- (void)alertBoxOkButtonOnClicked
{
    if(alertBoxOkType == kAlertBoxNotFindIR)
    {
        [self openView:step1 completion:^{
            [self closeView:step2 completion:nil];
        }];
    }
    else
    {
        [self backButtonOnClicked:nil];
    }
}

- (void)retryBoxOkButtonOnClicked
{
    [self tableView:_tableView didSelectRowAtIndexPath:idxPath];
}

- (void)retryBoxCancelButtonOnClicked
{

}

#pragma mark - Keyboard notification

const int txFIRCodeNameHeight = 50;

//- (void)keyboardFrameWillChanged:(NSNotification *)notify
//{
//    NSDictionary* info = [notify userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    CGPoint kbPoint = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
//    if(kbPoint.y >= 480)
//    {
//        [UIView animateWithDuration:0.25 animations:^{
//            step3BodyView.top = 44;
//        }];
//    }
//    else
//    {
//        float txfY = txFIRCodeName.top + 44;
//        float kbY = self.view.height - kbSize.height;
//        txfY = txfY + txFIRCodeNameHeight;
//        if(txfY > kbY)
//        {
//            [UIView animateWithDuration:0.25 animations:^{
//                step3BodyView.top = 44 - (txfY - kbY);
//            }];
//        }
//    }
//}

@end
