//
//  RetrievePasswordViewController.m
//  AirManager
//

#import "RetrievePasswordViewController.h"
#import "AppDelegate.h"

#define kRetrievePasswordURL    @"http://m.haier.com/ids/mobile/find-pwd-loginName.jsp"

@interface RetrievePasswordViewController ()
{
    IBOutlet UIView *step2;                         //输入验证码的视图
    IBOutlet UIView *step3;                         //输入新密码的视图
    
    IBOutlet UITextField *txfUserName;              //用户
    IBOutlet UITextField *txfVerificationCode;      //验证码
    IBOutlet UITextField *txfPwd;                   //新密码
    IBOutlet UITextField *txfConfirPwd;             //确认新密码
    
    IBOutlet UILabel *lblPhoneNumber;               //用户
}

- (IBAction)getTheVerificationCode:(id)sender;      //获取验证码
- (IBAction)lastStepInStep2:(id)sender;             //返回到step1
- (IBAction)nextStepInStep2:(id)sender;             //进入到step2
- (IBAction)LastStepInStep3:(id)sender;             //返回到step2
- (IBAction)submitNewPassword:(id)sender;           //提交新密码

@end

@implementation RetrievePasswordViewController


#pragma mark - View LifeCycle

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark - Private Methods

/**
 *  打开视图
 *
 *  @param view 视图对象
 */
- (void)openView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        view.frame = self.view.frame;
        view.alpha = 0;
        [UIView animateWithDuration:0.2f animations:^{
            view.alpha = 1;
            [self.view addSubview:view];
        }];
    });
}

/**
 *  关闭视图
 *
 *  @param view 视图对象
 */
- (void)closeView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f animations:^{
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    });
}

#pragma mark - Protocol Conformance

#pragma mark - AlertBoxDelegate

- (void)alertBoxOkButtonOnClicked
{
    [txfUserName becomeFirstResponder];
    [txfVerificationCode becomeFirstResponder];
    [txfPwd becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - IBAction Methods

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)getTheVerificationCode:(id)sender
{
    [self.view endEditing:YES];

    if(![MainDelegate isNetworkAvailable])return;

    if (![MainDelegate isMobileNumber:txfUserName.text])
    {
        [AlertBox showWithMessage:Localized(@"用户名格式不正确") delegate:self showCancel:NO];
        return;
    }

    lblPhoneNumber.text = txfUserName.text;
    [self openView: step2];
    
//#warning 获取验证码
    
    /*

    // 获取验证码
    NSString *body = [NSString stringWithFormat:@"{\"loginId\":\"%@\"}",txfPwd.text];
    NSString *adress = [NSString stringWithFormat:@"%@/api/users/getcode",Server_Adress];
    NSURL *url = [NSURL URLWithString:adress];
    NSMutableURLRequest *request = [MainDelegate requestUrl:url method:HttpMethodPost body:body];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = Localized(@"密码修改失败，请稍候重试");
         if(error)
         {
             [AlertBox showWithMessage:errorInfo];
             return;
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             DDLogVerbose(@"Response: %@",[result description]);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [AlertBox showWithMessage:Localized(@"修改密码成功")];
                 [self openView:step2];
             }
             else
             {
                 if(result[HttpReturnInfo] && ![result[HttpReturnInfo] isEqualToString:@"会话过期"])
                 {
                     errorInfo = result[HttpReturnInfo];
                 }
                 [AlertBox showWithMessage:errorInfo];
                 return;
             }
         }
     }];
     
     */
}

- (IBAction)lastStepInStep2:(id)sender
{
    [self closeView:step2];
}

- (IBAction)LastStepInStep3:(id)sender
{
    [self closeView:step3];
}

- (IBAction)nextStepInStep2:(id)sender
{
    [self.view endEditing:YES];
    if ([txfVerificationCode.text length] <= 0) {
        [AlertBox showWithMessage:Localized(@"验证码不能为空")  delegate:self showCancel:NO];
        return;
    }
    
//#warning 检验验证码是否正确
    
    if (YES)
    {
        [self openView:step3];
    }
    else
    {
        [AlertBox showWithMessage:Localized(@"验证码输入错误，请重新密码")  delegate:self showCancel:NO];
    }
}

- (IBAction)submitNewPassword:(id)sender
{
    [self.view endEditing:YES];
    
    if(![MainDelegate isNetworkAvailable])return;
    
    if ([txfPwd.text length]>255 || [txfPwd.text length]<6)
    {
        [AlertBox showWithMessage:Localized(@"密码格式不正确，请输入6位以上的数字或字母")];
        return;
    }
    NSString *regex = @"^[A-Za-z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![predicate evaluateWithObject:txfPwd.text])
    {
        [AlertBox showWithMessage:Localized(@"密码由字母和数字组成，不能包含其他符号")];
        return;
    }
    
    if(![txfPwd.text isEqualToString:txfConfirPwd.text])
    {
        [AlertBox showWithMessage:Localized(@"输入密码不一致")];
        return;
    }
    
//#warning 提交新密码
    /*
    // 提交新密码到服务器
    NSString *body = [NSString stringWithFormat:@"{\"loginId\":\"%@\"}",txfPwd.text];
    NSString *adress = [NSString stringWithFormat:@"%@/api/users/getcode",Server_Adress];
    NSURL *url = [NSURL URLWithString:adress];
    NSMutableURLRequest *request = [MainDelegate requestUrl:url method:HttpMethodPost body:body];
    
    [MainDelegate showProgressHubInView:self.view];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         NSString *errorInfo = Localized(@"密码修改失败，请稍候重试");
         if(error)
         {
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             
             DDLogVerbose(@"Response: %@",[result description]);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [AlertBox showWithMessage:Localized(@"修改密码成功")];
                 [self back:nil];
             }
             else
             {
                 if(result[HttpReturnInfo] && ![result[HttpReturnInfo] isEqualToString:@"会话过期"])
                 {
                     errorInfo = result[HttpReturnInfo];
                 }
                 [AlertBox showWithMessage:errorInfo];
             }
         }
     }];
     
     */
}

@end
