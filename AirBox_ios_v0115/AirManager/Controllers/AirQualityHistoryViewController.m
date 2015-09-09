//
//  AirQualityHistoryViewController.m
//  AirManager
//

#import "AirQualityHistoryViewController.h"
#import "AirDevice.h"
#import "CurveView.h"
#import "PointInHistoryView.h"
#import "UIDevice+Resolutions.h"
#import "AppDelegate.h"
#import "AlertBox.h"

#define kMaxDays    5

#define kDatas          @"datas"

#define kHighHumidity   @"high_humidity"
#define kHighPM25       @"high_pm25"
#define kHighTemp       @"high_temp"
#define kHighVoc        @"high_voc"

#define kLowHumidity    @"low_humidity"
#define kLowPM25        @"low_pm25"
#define kLowTemp        @"low_temp"
#define kLowVoc         @"low_voc"


@interface AirQualityHistoryViewController ()
{
    IBOutlet UIView *contentView;
    IBOutlet UILabel *lblFirstDate;
    IBOutlet UILabel *lblSecondDate;
    IBOutlet UILabel *lblThirdDate;
    IBOutlet UILabel *lblForthDate;
    IBOutlet UILabel *lblFifthDate;
    NSMutableArray *arrMarks;
    NSMutableArray *arrTemps;
    NSMutableArray *arrHums;
    NSMutableArray *arrPMs;
}

@end

@implementation AirQualityHistoryViewController

@synthesize airDevice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    DDLogFunction();
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    DDLogFunction();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = [UIDevice isRunningOn4Inch] ? CGRectMake(50, 483, 250, 4) : CGRectMake(50, 407, 250, 4);
    PointInHistoryView *pointView = [[PointInHistoryView alloc] initWithFrame:frame];
    [contentView addSubview:pointView];
    
    arrMarks = [[NSMutableArray alloc] initWithCapacity:5];
    arrTemps = [[NSMutableArray alloc] initWithCapacity:10];
    arrHums = [[NSMutableArray alloc] initWithCapacity:5];
    arrPMs = [[NSMutableArray alloc] initWithCapacity:5];
    
    [self fetchHistoryData:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeButtonOnClicked:(id)sender
{
    DDLogFunction();
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished){
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    });
}

- (NSString *)startDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    DDLogVerbose(@"%@",[formatter stringFromDate:[NSDate date]]);
    return [formatter stringFromDate:[NSDate date]];
}

- (void)fetchHistoryData:(NSInteger)requestCount
{
    DDLogFunction();
    
    [MainDelegate showProgressHubInView:self.view];
    NSDictionary *dicBody = @{@"startDateTime":[self startDate],@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_HISTORY(airDevice.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         
         NSString *errorInfo = Localized(@"获取数据失败,请检查网络");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogVerbose(@"Response: %@", result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 if([result[kDatas] isEqual:[NSNull null]])
                 {
                     [AlertBox showWithMessage:errorInfo];
                 }
                 else
                 {
                     [self categoryHistoryData:result[kDatas]];
                 }
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
                                 [self fetchHistoryData:requestCount + 1];
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
                 [AlertBox showWithMessage:errorInfo];
             }
         }
     }];
}

- (void)categoryHistoryData:(NSArray *)data
{
    DDLogFunction();
    NSMutableArray *arrDate = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 2; i < data.count; i++)
    {
        NSDictionary *dict = data[i];
        [arrMarks addObject:dict[@"mark"]];
        [arrTemps addObject:[NSNumber numberWithInt:[MainDelegate countTempVlue:dict[@"low_temp"]]]];
        [arrTemps addObject:[NSNumber numberWithInt:[MainDelegate countTempVlue:dict[@"high_temp"]]]];
        NSNumber *aveTemp = [NSNumber numberWithDouble:([dict[@"low_temp"] doubleValue] + [dict[@"high_temp"] doubleValue]) / 2];
        [arrHums addObject:[NSNumber numberWithInt:[MainDelegate countHumValue:dict[@"humidity"] withTemp:aveTemp hardWare:airDevice.baseboard_software]]];
        [arrPMs addObject:dict[@"pm25"]];
        [arrDate addObject:dict[@"dateTime"]];
    }
    [self addCureViews];
    
    lblFirstDate.text = [self coventString:arrDate[0]];
    lblSecondDate.text = [self coventString:arrDate[1]];
    lblThirdDate.text = [self coventString:arrDate[2]];
    lblForthDate.text = [self coventString:arrDate[3]];
    lblFifthDate.text = [self coventString:arrDate[4]];
}

- (NSString *)coventString:(NSString *)string
{
    NSMutableString *newStr = [NSMutableString stringWithString:[string substringFromIndex:4]];
    [newStr insertString:@"." atIndex:2];
    return newStr;
}

//4.0 inch
/** 5.25
#define MarkFrame CGRectMake(50, 46, 250, 110)
#define TempFrame CGRectMake(50, 156, 250, 110)
#define HumFrame CGRectMake(50, 266, 250, 110)
#define PMFrame CGRectMake(50, 376, 250, 110)
 */


#define MarkFrame CGRectMake(50, 65, 250, 110)
#define TempFrame CGRectMake(50, 211, 250, 110)
#define HumFrame CGRectMake(50, 358, 250, 110)


//3.5 inch
/** 5.25
#define MarkFrame35 CGRectMake(50, 45, 250, 92)
#define TempFrame35 CGRectMake(50, 136, 250, 92)
#define HumFrame35 CGRectMake(50, 227, 250, 92)
#define PMFrame35 CGRectMake(50, 318, 250, 92)
*/


#define MarkFrame35 CGRectMake(50, 60, 250, 92)
#define TempFrame35 CGRectMake(50, 181, 250, 92)
#define HumFrame35 CGRectMake(50, 302, 250, 92)


- (void)addCureViews
{
    BOOL isLarge = [UIDevice isRunningOn4Inch];
    
    CurveView *markCurve = [[CurveView alloc] initWithFrame:(isLarge ? MarkFrame : MarkFrame35) andData:arrMarks isPM:NO];
    [contentView addSubview:markCurve];
    
    CurveView *tempCurve = [[CurveView alloc] initWithFrame:(isLarge ? TempFrame : TempFrame35) andData:arrTemps isPM:NO];
    [contentView addSubview:tempCurve];
    
    CurveView *humCurve = [[CurveView alloc] initWithFrame:(isLarge ? HumFrame : HumFrame35) andData:arrHums isPM:NO];
    [contentView addSubview:humCurve];
    
//    CurveView *pmCurve = [[CurveView alloc] initWithFrame:(isLarge ? PMFrame : PMFrame35) andData:arrPMs isPM:YES];
//    [contentView addSubview:pmCurve];
}

@end
