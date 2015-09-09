//
//  ChangeNameViewController.m
//  AirManager
//

#import "ChangeNameViewController.h"
#import "AirDevice.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"

static const int nameMaxLength = 16;

@interface ChangeNameViewController ()
{
    IBOutlet UITextField *nameTxf;
    NSMutableArray *airBoxNameList;
}

- (IBAction)confirmToChangeName:(id)sender;

- (void)modifyNickName:(NSInteger)requestCount;

@end

@implementation ChangeNameViewController

@synthesize airDevice;

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
    
    self.title = NSLocalizedString(@"设备管理",@"ChangeNameViewController.m");
    nameTxf.text = NSLocalizedString(airDevice.name,@"ChangeNameViewController1.m");//ybyao
    
    airBoxNameList = [[NSMutableArray alloc] init];
    for (int i = 0; i < MainDelegate.loginedInfo.arrUserBindedDevice.count; i++)
    {
        AirDevice *device = MainDelegate.loginedInfo.arrUserBindedDevice[i];
        [airBoxNameList addObject:device.name];
    }
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender
{
    DDLogFunction();
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmToChangeName:(id)sender
{
    DDLogFunction();
    if(![MainDelegate isNetworkAvailable])return;
    
    if([nameTxf.text isEqualToString:airDevice.name])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([[nameTxf.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0)
        {
            [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能为空",@"ChangeNameViewController.m")];
            return;
        }
        
        if([nameTxf.text length] > nameMaxLength){
            [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能超过16个字符", @"ChangeNameViewController.m") ];
            return;
        }
        
        NSString *regex = @"^[A-Za-z0-9\u4E00-\u9FA5_-]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![predicate evaluateWithObject:nameTxf.text])
        {
            [AlertBox showWithMessage:NSLocalizedString(@"设备名称不能包含特殊字符",@"ChangeNameViewController.m")];
            return;
        }
        
        if([airBoxNameList containsObject:nameTxf.text])
        {
            [AlertBox showWithMessage:NSLocalizedString(@"不能与其他设备同名，请重新设置新的名称",@"ChangeNameViewController.m")];
        }
        else
        {
            [MainDelegate showProgressHubInView:self.view];
            [self modifyNickName:0];
        }
    }
}

- (void)modifyNickName:(NSInteger)requestCount
{
    DDLogFunction();
    NSDictionary *dicBody = @{@"name":nameTxf.text,
                              @"userId":MainDelegate.loginedInfo.userID,
                              @"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_RENAME(airDevice.mac)
                                                     method:HTTP_PUT
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = NSLocalizedString(@"修改空气盒子名称失败",@"ChangeNameViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->修改空气盒子名称接口信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 NSUInteger index = [MainDelegate.loginedInfo.arrUserBindedDevice indexOfObject:airDevice];
                 airDevice.name = NSLocalizedString(nameTxf.text,@"ChangeNameViewController1.m");//ybyao
                 [MainDelegate.loginedInfo.arrUserBindedDevice replaceObjectAtIndex:index withObject:airDevice];
                 [NotificationCenter postNotificationName:ChangeAirBoxSucceedNotification object:nil];
                 
                 // 更新缓存
                 [NotificationCenter postNotificationName:AirDevicesChangedNotification object:nil];
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }
             else
             {
                 if(requestCount < 3)
                 {
                     [MainDelegate reDownloadToken:^(BOOL succeed){
                         [self modifyNickName:requestCount + 1];
                     }];
                     return;
                 }
                 
                 [MainDelegate hiddenProgressHubInView:self.view];
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


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
    if ([textField.text length] >= 16 && range.length == 0  && ![string isEqualToString:@""]) {
        [AlertBox showWithMessage:@"设备名称不能超过16个字符"];
        [self.view endEditing:YES];
        return NO;
    }
     */
    return YES;
}

@end
