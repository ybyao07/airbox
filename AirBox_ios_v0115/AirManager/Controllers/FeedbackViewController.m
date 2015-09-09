//
//  FeedbackViewController.m
//  AirManager
//

#import "FeedbackViewController.h"
#import "UserLoginedInfo.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "IRDeviceModelSelectionViewController.h"
#import "NewFeedbackCell.h"
#import "UIViewExt.h"
#import "AirDeviceBindViewController.h"

@interface FeedbackViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UIButton *backBtn;
    IBOutlet UITextView *_textView;
    IBOutlet UILabel *placeHolder;
    IBOutlet UITableView *_tableView;
}

@property (strong, nonatomic) __block NSMutableArray *feedbacks;

- (IBAction)back:(id)sender;
- (IBAction)sendButonOnClicked:(id)sender;

@end

@implementation FeedbackViewController

#pragma mark - View LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setParentContoller:(UIViewController *)parentContoller
{
    _parentContoller = parentContoller;
    
    if ([_parentContoller isKindOfClass:[IRDeviceModelSelectionViewController class]])
    {
        placeHolder.text = NSLocalizedString(@"请输入您的空调或净化器型号，我们会尽快开发支持该型号设备，谢谢", @"FeedbackViewController.m") ;
        [placeHolder sizeToFit];
    }
    else if ([_parentContoller isKindOfClass:[AirDeviceBindViewController class]])
    {
        //ybyao07
        _lblTitle.text = NSLocalizedString(@"问题反馈", @"FeedbackViewController.m") ;
        placeHolder.text = NSLocalizedString(@"请告知您的路由器品牌及型号，我们会尽快处理", @"FeedbackViewController.m") ;
        [placeHolder sizeToFit];
    }
    else if([[self parentContoller] isKindOfClass:[FeedbackViewController class]])
    {
        placeHolder.text =NSLocalizedString(@"请输入意见或建议", @"FeedbackViewController.m") ;
        [placeHolder sizeToFit];
    }
    else
    {
        placeHolder.text =NSLocalizedString(@"请输入意见或建议", @"FeedbackViewController.m") ;
        [placeHolder sizeToFit];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutView];
    
    [self customTableView:_tableView];
    [self downloadFeedbackList];
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


#pragma mark - Private Methods

- (void)customTableView:(UITableView *)tableView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableViewHiddenKeyboard)];
    [tableView addGestureRecognizer:tap];
}

- (void)tapTableViewHiddenKeyboard
{
    [self.view endEditing:YES];
}

- (void)downloadFeedbackList
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    NSDictionary *bodyDict = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:bodyDict];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_FEEDBACK(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    
    [NSURLConnection sendAsynchronousRequestTest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [MainDelegate hiddenProgressHubInView:self.view];
         if (error)
         {
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             self.feedbacks = isObject(result[@"datas"])?result[@"datas"]:[NSMutableArray array];
             DDLogCVerbose(@"--->downloadFeedbackList接口信息%@",result);
             
             for (int i=0; i<[self.feedbacks count]; i++)
             {
                 if(![self.feedbacks[i][@"submitTime"] isEqual:[NSNull null]])
                 {
                     self.feedbacks[i][@"submitTime"] = [self convertDateFromString:self.feedbacks[i][@"submitTime"]];
                 }
                 
                 if (![self.feedbacks[i][@"feedbackTime"] isEqual:[NSNull null]])
                 {
                     self.feedbacks[i][@"feedbackTime"] = [self convertDateFromString:self.feedbacks[i][@"feedbackTime"]];
                 }
             }
             [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
         }
    }];
}

- (NSString *)convertDateFromString:(NSString*)string
{
    DDLogFunction();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date=[formatter dateFromString:string];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}


- (float)calcTextHeightWithText:(NSString *)text
{
    DDLogFunction();
    CGSize cellSize = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(270, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    return cellSize.height + 10;
}

#pragma mark - UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogFunction();
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}


#pragma mark - Protocol Conformance
#pragma mark - UITextViewDelegate

int const MaxNumberOfDescriptionChars = 256;

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    DDLogFunction();
    /*
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    //If the delete operator executes
    char c=[text UTF8String][0];
    if (c=='\000')
    {
        if (textView.text.length > MaxNumberOfDescriptionChars)
        {
            textView.text = [textView.text substringToIndex:MaxNumberOfDescriptionChars];
        }
        return YES;
    }
    
    if([[textView text] length] + [text length] > MaxNumberOfDescriptionChars){
        [AlertBox showWithMessage:@"反馈信息不能超过256个字符"];
        [textView resignFirstResponder];
        return NO;
    }
    
    if([[textView text] length] + [text length] == MaxNumberOfDescriptionChars)
    {
        if(![text isEqualToString:@"\b"])
            [AlertBox showWithMessage:@"反馈信息不能超过256个字符"];
        [textView resignFirstResponder];
        return NO;
    }
     */

    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    DDLogFunction();
    placeHolder.hidden = YES;
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    DDLogFunction();
    if(textView.text.length == 0)
    {
        placeHolder.hidden = NO;
    }
}


#pragma mark - IBAction Methods

- (IBAction)back:(id)sender
{
    DDLogFunction();
    if ([[self parentContoller] isKindOfClass:[IRDeviceModelSelectionViewController class]])
    {
        IRDeviceModelSelectionViewController *irdeviceModel = (IRDeviceModelSelectionViewController *)[self parentContoller];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                [irdeviceModel backButtonOnClicked:sender];
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        });
    }
    else if ([[self parentContoller] isKindOfClass:[AirDeviceBindViewController class]])
    {
//        AirDeviceBindViewController *irdeviceModel = (AirDeviceBindViewController *)[self parentContoller];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
                [self removeFromParentViewController];
            }];
        });
    }
    else if([[self parentContoller] isKindOfClass:[FeedbackViewController class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                self.view.alpha = 0;
            } completion:^(BOOL finished) {
                [self.view removeFromSuperview];
            }];
        });
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (IBAction)sendButonOnClicked:(id)sender
{
    DDLogFunction();
    //if([_textView.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
    if(isEmptyString(_textView.text))
    {
        [AlertBox showWithMessage:NSLocalizedString(@"反馈内容不能为空!",@"FeedbackViewController.m")];
        return;
    }
    
    if([[_textView text] length] > MaxNumberOfDescriptionChars){
        [AlertBox showWithMessage:NSLocalizedString(@"反馈信息不能超过256个字符",@"FeedbackViewController.m")];
        [_textView resignFirstResponder];
        return;
    }
    
    [MainDelegate showProgressHubInView:self.view];
    NSDictionary *dicBody = @{@"txtContent":_textView.text,
                              @"picType":[NSNumber numberWithInt:0],
                              @"picContent":@"",
                              @"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_SUGGESTION(MainDelegate.loginedInfo.userID)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         NSString *errorInfo = NSLocalizedString(@"提交反馈失败，请重试",@"FeedbackViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:errorInfo
                                                            delegate:self
                                                   cancelButtonTitle:@"重试"
                                                   otherButtonTitles:@"放弃",nil];
             [alert show];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->提交意见接口信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [AlertBox showWithMessage:NSLocalizedString(@"谢谢您的反馈!",@"FeedbackViewController.m")];
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _textView.text = @"";
                     placeHolder.hidden = NO;
                 });
                 [self downloadFeedbackList];
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
                 [MainDelegate hiddenProgressHubInView:self.view];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:errorInfo
                                                                delegate:self
                                                       cancelButtonTitle:@"重试"
                                                       otherButtonTitles:@"放弃",nil];
                 [alert show];
             }
         }
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertView cancelButtonIndex])
    {
        [self sendButonOnClicked:nil];
    }
    else
    {
        [self back:backBtn];
    }
}


- (void)alertBoxOkButtonOnClicked
{
//    [self back:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.feedbacks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /**
    static NSString *cellIdentifier = @"FeedbackCellIdentifier";
    FeedbackCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:@"FeedbackCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (FeedbackCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lblcName.text = @"我的意见";
    cell.lblcDate.text = self.feedbacks[indexPath.row][@"submitTime"];
    cell.lblcInfo.text = self.feedbacks[indexPath.row][@"txtContent"];
    if ([self.feedbacks[indexPath.row][@"feedbackTime"] isEqual:[NSNull null]])
    {
        cell.lblsName.text = @"";
        cell.lblsDate.text = @"";
        cell.lblsInfo.text = @"";
    }
    else
    {
        cell.lblsName.text = @"客服回复";
        cell.lblsDate.text = self.feedbacks[indexPath.row][@"feedbackTime"];
        cell.lblsInfo.text = self.feedbacks[indexPath.row][@"feedbackContent"];
    }
    
    return cell;
     */

    static NSString *cellIdentifier = @"FeedbackCellIdentifier";
    NewFeedbackCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        UINib *nib = [UINib nibWithNibName:@"NewFeedbackCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        cell = (NewFeedbackCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    float height = [self calcTextHeightWithText:self.feedbacks[indexPath.row][@"txtContent"]];
    [cell.lblInfo setHeight:height];
    
    cell.lblDate.text =NSLocalizedString(self.feedbacks[indexPath.row][@"submitTime"],"FeedbackViewController1.m");//ybyao
    cell.lblInfo.text = NSLocalizedString(self.feedbacks[indexPath.row][@"txtContent"],"FeedbackViewController1.m");//ybyao

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = self.feedbacks[indexPath.row][@"txtContent"];
    float height = [self calcTextHeightWithText:text]+50;
    return height;
}

@end
