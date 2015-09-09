//
//  RegisterViewController.m
//  AirManager
//

#import "RegisterViewController.h"
#import "AgreementViewController.h"
#import "AccountActivationViewController.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "MainViewController.h"

@interface RegisterViewController (){
    IBOutlet UITextField *txfUserName;
    IBOutlet UITextField *txfPwd;
    IBOutlet UITextField *txfComfirmPwd;
    IBOutlet UIButton *agreementBtn;
}

- (IBAction)registerAccount:(id)sender;
- (IBAction)readAgreement:(id)sender;
- (IBAction)acceptAgreement:(id)sender;
- (IBAction)backToMainView:(id)sender;
- (void)acceptAgreementOnAgreePage;

@end

@implementation RegisterViewController

- (void)dealloc
{
    [NotificationCenter removeObserver:self];
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
    
    [NotificationCenter addObserver:self
                           selector:@selector(acceptAgreementOnAgreePage)
                               name:AgreeUserAgreementNotification
                             object:nil];
    
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

- (void)removeFromParentView
{
//    [UIView animateWithDuration:0.2 animations:^{
//        self.view.alpha = 0.0;
//    } completion:^(BOOL finished){
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
//    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    });
}

- (void)startRegister:(NSNumber *)requestCountNum
{
    [MainDelegate showProgressHubInView:self.view];
    
     NSInteger requestCount = [requestCountNum integerValue];
    
    NSDictionary *dicBody = @{@"user" : @{@"loginId": txfUserName.text},
                              @"password" : txfPwd.text,
                              @"sequenceId" : [MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_REGISTER
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
    {
        if(!response)
        {
            if(requestCount < 5)
            {
                [self performSelector:@selector(startRegister:) withObject:[NSNumber numberWithInt:(requestCount + 1)] afterDelay:1];
                
                return;
            }
        }
        
        NSString *errorInfo = NSLocalizedString(@"注册失败",@"RegisterViewController.m");
        if(error)
        {
            if(!data && !response)
            {
                errorInfo =  NSLocalizedString(@"网络异常,请检查网络设置!",@"RegisterViewController.m");
            }
            [MainDelegate hiddenProgressHubInView:self.view];
            [AlertBox showWithMessage:errorInfo];
        }
        else
        {
            NSDictionary *result = [MainDelegate parseJsonData:data];
            result = isObject(result) ? result : nil;
            DDLogCVerbose(@"--->Register response: %@",result);
            
            if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
            {
                [MainDelegate hiddenProgressHubInView:self.view];
                // display account activation page
                AccountActivationViewController *activation = [[AccountActivationViewController alloc] initWithNibName:@"AccountActivationViewController" bundle:nil];
                activation.phoneNumber = txfUserName.text;
                activation.passWord = txfPwd.text;
                activation.isOpenFromRegiste = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    activation.view.alpha = 0.0;
                    [MainDelegate.window addSubview:activation.view];
                    [UIView animateWithDuration:0.3 animations:^{
                        activation.view.alpha = 1.0;
                    }];
                    [self addChildViewController:activation];
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
                                [self startRegister:[NSNumber numberWithInt:(requestCount + 1)]];
                            }];
                            return;
                        }
                    }
                }
                
                [MainDelegate hiddenProgressHubInView:self.view];
                if(result)
                {
                    errorInfo = [MainDelegate erroInfoWithErrorCode:result[HttpReturnCode]];
                    if (errorInfo == nil)
                    {
                        errorInfo = isObject(result[HttpReturnInfo]) ? result[HttpReturnInfo] : NSLocalizedString(@"注册失败",@"RegisterViewController1.m");//ybyao
                    }
                }
                [AlertBox showWithMessage:errorInfo];
            }
        }
    }];
}

- (IBAction)registerAccount:(id)sender
{
    if ([txfUserName.text length] == 0) {
        [AlertBox showWithMessage:NSLocalizedString(@"手机号不能为空",@"RegisterViewController.m")];
        return;
    }
    else if([txfPwd.text length] == 0)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"密码不能为空",@"RegisterViewController.m")];
        return;
    }
    else if(![MainDelegate isMobileNumber:txfUserName.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入正确的手机号码格式",@"RegisterViewController.m")];
        return;
    }
    
    if ([txfPwd.text length]>20 || [txfPwd.text length]<6)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入正确的密码格式,长度6-20位的数字或字母",@"RegisterViewController.m")];
        return;
    }
    
    NSString *regex = @"^[A-Za-z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:txfPwd.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"密码由字母或数字组成，不能包含其他符号",@"RegisterViewController.m")];
        return;
    }
    
    if(txfComfirmPwd.text.length == 0)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请输入确认密码",@"RegisterViewController.m")];
        return;
    }
    
    if(![txfPwd.text isEqualToString:txfComfirmPwd.text])
    {
        [AlertBox showWithMessage:NSLocalizedString(@"输入密码不一致",@"RegisterViewController.m")];
        return;
    }
    
    if(!agreementBtn.selected)
    {
        [AlertBox showWithMessage:NSLocalizedString(@"请确认您已经阅读了《用户使用协议》",@"RegisterViewController.m")];
        return;
    }
    
    if([txfUserName isFirstResponder])
    {
        [txfUserName resignFirstResponder];
    }
    
    if([txfPwd isFirstResponder])
    {
        [txfPwd resignFirstResponder];
    }
    
    if([txfComfirmPwd isFirstResponder])
    {
        [txfComfirmPwd resignFirstResponder];
    }
    
    
    [self startRegister:[NSNumber numberWithInt:0]];
}

- (IBAction)readAgreement:(id)sender
{
    AgreementViewController *agreement = [[AgreementViewController alloc] initWithNibName:@"AgreementViewController" bundle:nil];
    agreement.isFromRegisteView = YES;
    //[self.navigationController pushViewController:agreement animated:YES];
    agreement.view.frame = self.view.frame;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MainDelegate.window addSubview:agreement.view];
        agreement.view.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            agreement.view.alpha = 1.0;
            [self addChildViewController:agreement];
        }];
    });
}

- (IBAction)acceptAgreement:(id)sender
{
    agreementBtn.selected = !agreementBtn.selected;
}

- (void)acceptAgreementOnAgreePage
{
    agreementBtn.selected = YES;
}

- (IBAction)backToMainView:(id)sender
{
    [NotificationCenter removeObserver:self name:AgreeUserAgreementNotification object:nil];
    
    if ([_parentVC isKindOfClass:[MainViewController class]])
    {
        [(MainViewController *)_parentVC clearLoginInfo];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });

    /**
    [self.navigationController popViewControllerAnimated:YES];
     **/
}

#pragma mark-
#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
