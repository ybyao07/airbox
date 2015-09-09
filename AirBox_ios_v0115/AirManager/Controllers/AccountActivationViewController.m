//
//  AccountActivationViewController.m
//  AirManager
//

#import "AccountActivationViewController.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "MainViewController.h"
#import "RegisterViewController.h"
#import "MainViewController.h"

@interface AccountActivationViewController ()
{
    IBOutlet UILabel        *tipMessage1;
    IBOutlet UILabel        *tipMessage2;
    IBOutlet UIView         *registeResult;
    IBOutlet UIImageView    *registeResultIcon;
    IBOutlet UILabel        *registeResultTips;
    IBOutlet UILabel        *autoSkipSec;
    NSTimer                 *autoSkipTimer;
    NSInteger               autoSkipSecond;
    NSInteger               errorCount;
    BOOL                    isActivateSucceed;
}

@end

@implementation AccountActivationViewController

@synthesize phoneNumber;
@synthesize passWord;
@synthesize isOpenFromRegiste;

- (void)dealloc
{
    if(_countDownTimer.isValid)
    {
        [_countDownTimer invalidate];
    }
    _countDownTimer = nil;
    
    if([autoSkipTimer isValid])
    {
        [autoSkipTimer invalidate];
    }
    autoSkipTimer = nil;
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
    
    _phoneNumberLabel.text = self.phoneNumber;
    
    if(isOpenFromRegiste)
    {
        [self startCountDown];
    }
    else
    {
        [self countDownButtonOnClicked:nil];
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
    // Dispose of any resources that can be recreated.
}

- (void)stopCountDown
{
    if(_countDownTimer.isValid)
    {
        [_countDownTimer invalidate];
    }
    _countDownTimer = nil;
}

- (IBAction)backButtonOnClicked:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [self stopCountDown];
    
    if ([_parentVC isKindOfClass:[MainViewController class]])
    {
        [(MainViewController *)_parentVC clearLoginInfo];
    }
    
    [self closeCurrentViewFromParentView];
}


- (IBAction)countDownButtonOnClicked:(id)sender
{
    if(![MainDelegate isNetworkAvailable])return;
    [self requestActiveCode:0];
}

- (void)requestActiveCode:(NSInteger)requestCount
{
    if([_activationCodeTextField isFirstResponder])
    {
        [_activationCodeTextField resignFirstResponder];
    }
    isActivateSucceed = NO;
    [MainDelegate showProgressHubInView:self.view];
    
    NSString *number = self.phoneNumber != nil ? self.phoneNumber : @"";
    NSDictionary *dicBody = @{@"loginId":number,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_GET_CODE
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = NSLocalizedString(@"获取激活码失败，请稍候重试",@"AccountActivationViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             
             if(![MainDelegate isNetworkAvailable])
             {
                 [AlertBox showWithMessage:NSLocalizedString(@"网络异常,请检查网络设置!",@"WeatherMainViewController")];
                 return;
             }
             
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->requestActiveCode Response: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _phoneNumberLabel.hidden = NO;
                     tipMessage1.hidden = NO;
                     tipMessage2.hidden = NO;
                 });
                 [self startCountDown];
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
                                [self requestActiveCode:requestCount + 1];
                             }];
                             return;
                         }
                     }
                 }

                 [MainDelegate hiddenProgressHubInView:self.view];
                 [AlertBox showWithMessage:errorInfo];
             }
         }
     }];
}

- (void)startCountDown
{
    
    _countDownButton.enabled = NO;
    _leftSeconds = kCountDownSeconds;
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                       target:self
                                                     selector:@selector(updateCountDownButton)
                                                     userInfo:nil
                                                      repeats:YES];
    
}

- (void)updateCountDownButton
{
    _leftSeconds--;
    [UIView setAnimationsEnabled:NO];
    //-----------ybyao-------------------
    NSMutableString *timeSeconds = [NSMutableString stringWithFormat:@"%d", _leftSeconds];
    [timeSeconds appendString:NSLocalizedString(@"秒", @"AccountActivationViewController1.m")];
    NSString *timeTitle = [[NSString alloc] initWithString:timeSeconds];
 //    [_countDownButton setTitle:[NSString stringWithFormat:@"%d秒", _leftSeconds]
//                      forState:UIControlStateDisabled];
    [_countDownButton setTitle:timeTitle
                      forState:UIControlStateDisabled];
    //——————ybyao-------------

    [UIView setAnimationsEnabled:YES];
    
    if (_leftSeconds == 0)
    {
        [self stopCountDown];
        _countDownButton.enabled = YES;
        [_countDownButton setTitle:NSLocalizedString(@"重新获取", @"AccountActivationViewController.m")
                          forState:UIControlStateNormal];
        //-----------ybyao-------------------
        NSMutableString *timeSeconds = [NSMutableString stringWithFormat:@"%d", kCountDownSeconds];
        [timeSeconds appendString:NSLocalizedString(@"秒", @"AccountActivationViewController1.m")];
        NSString *timeTitle = [[NSString alloc] initWithString:timeSeconds];
        //    [_countDownButton setTitle:[NSString stringWithFormat:@"%d秒", kCountDownSeconds]
        //                      forState:UIControlStateDisabled];
        [_countDownButton setTitle:timeTitle
                          forState:UIControlStateDisabled];
        //——————ybyao-------------
    }
}

- (void)autoSkipCountDown
{
    autoSkipSecond = 3;
    autoSkipTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(updateAutoSkipTime)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)updateAutoSkipTime
{
    autoSkipSecond--;
    autoSkipSec.text = [NSString stringWithFormat:@"%d",autoSkipSecond];
    
    if (autoSkipSecond == 0)
    {
        [autoSkipTimer invalidate];
        autoSkipTimer = nil;
        
        if(isActivateSucceed)
        {
            //[self.navigationController popToRootViewControllerAnimated:YES];
            //if([self.navigationController.parentViewController isKindOfClass:[MainViewController class]])
            //{
            //    [self doAutoLogin];
            //}
            [self doAutoLogin];
        }
        else
        {
            [self closeView:registeResult complttion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    autoSkipSec.text = @"3";
                });
            }];
        }
    }
}

- (void)closeCurrentViewFromParentView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isOpenFromRegiste)
        {
            [(RegisterViewController *)self.parentViewController removeFromParentView];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });
}

- (void)doAutoLogin
{
    [self stopCountDown];
    [self closeCurrentViewFromParentView];
    MainViewController *mainPage = isOpenFromRegiste ? (MainViewController *)[self.navigationController parentViewController] : (MainViewController *)[self parentViewController];
    [mainPage autoLogin:phoneNumber andPassword:passWord];
}

- (IBAction)activationButtonOnClicked:(id)sender
{
    [_activationCodeTextField resignFirstResponder];
    if(![MainDelegate isNetworkAvailable])return;
    [self doActive:0];
}

- (void)doActive:(NSInteger)requestCount
{
    [self.view endEditing:YES];
    
    /** 6.13
    if (errorCount >= 5) {
     [AlertBox showWithMessage:NSLocalizedString(@"请稍后再试",@"AccountActivationViewController.m")];
        errorCount = 0;
        return;
    }
     */
    
    if (isEmptyString(_activationCodeTextField.text))
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入激活码",@"AccountActivationViewController.m")];
        return;
    }
    
    [MainDelegate showProgressHubInView:self.view];
    
    NSString *number = self.phoneNumber != nil ? self.phoneNumber : @"";
    NSString *activeCode = _activationCodeTextField.text != nil ? _activationCodeTextField.text : @"";
    NSDictionary *dicBody = @{@"loginId":number,@"code":activeCode,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_ACTIVE
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         if(error)
         {
             
             NSString *returninfo = NSLocalizedString(@"注册失败",@"AccountActivationViewController.m");
             
             if(![MainDelegate isNetworkAvailable])
             {
                 returninfo = NSLocalizedString(@"网络异常,请检查网络设置!",@"AccountActivationViewController.m");
                 return;
             }
             
             [MainDelegate hiddenProgressHubInView:self.view];
             dispatch_async(dispatch_get_main_queue(), ^{
                 registeResultIcon.image = [UIImage imageNamed:@"pop_cancel.png"];
                 registeResultTips.text = returninfo;
             });
             errorCount++;
             isActivateSucceed = NO;
             [self openView:registeResult completion:^{
                 [self autoSkipCountDown];
             }];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"---> doActive Response: %@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     registeResultIcon.image = [UIImage imageNamed:@"pop_ok.png"];
                     registeResultTips.text = NSLocalizedString(@"注册成功",@"AccountActivationViewController.m");
                 });
                 isActivateSucceed = YES;
                 [self openView:registeResult completion:^{
                     [self autoSkipCountDown];
                 }];
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
                                [self doActive:requestCount + 1];
                             }];
                             return;
                         }
                     }
                 }

                 [MainDelegate hiddenProgressHubInView:self.view];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     registeResultIcon.image = [UIImage imageNamed:@"pop_cancel.png"];
                     
                     NSString *returninfo = result[HttpReturnInfo];
                     if(isObject(returninfo))
                     {
                         NSRange range = [returninfo rangeOfString:@"激活"];//判断字符串是否包含
                         
                         //if (range.location ==NSNotFound)//不包含
                         if (range.length >0)//包含
                         {
                             
                             returninfo = NSLocalizedString(@"激活码不正确，请重新输入",@"AccountActivationViewController.m");
                             
                         }
                         else//不包含
                         {
                             returninfo = NSLocalizedString(@"注册失败",@"AccountActivationViewController.m");
                         }
                     }
                     else
                     {
                         returninfo = NSLocalizedString(@"注册失败",@"AccountActivationViewController.m");
                     }
                     registeResultTips.text =  returninfo;//ybyao
                 });
                 errorCount++;
                 isActivateSucceed = NO;
                 [self openView:registeResult completion:^{
                     [self autoSkipCountDown];
                 }];
             }
         }
     }];
}

- (void)openView:(UIView *)view completion:(void(^)())animteComplete
{
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

- (void)closeView:(UIView *)view complttion:(void(^)())animteComplete
{
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

//- (void)alertBoxOkButtonOnClicked
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
