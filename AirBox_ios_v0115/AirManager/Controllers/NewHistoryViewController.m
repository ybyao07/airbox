//
//  NewHistoryViewController.m
//  AirManager
//
//  Created by Luo Lin on 14-6-12.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "NewHistoryViewController.h"
#import "AirDevice.h"
#import "NewCurveView.h"
#import "PointInHistoryView.h"
#import "UIDevice+Resolutions.h"
#import "AppDelegate.h"
#import "AlertBox.h"
#import "CityDataHelper.h"

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

#define TempCurveTag    665
#define HumCurveTag     666
#define MarkCurveTag    667
#define PMCurveTag      668

@interface NewHistoryViewController ()
{
    IBOutlet UIButton *chgangeCurveBtn;
    IBOutlet UIScrollView *curveScroll1;
    IBOutlet UIScrollView *curveScroll2;
    IBOutlet UIScrollView *curveScroll3;
    IBOutlet UIScrollView *curveScroll4;
    IBOutlet UIScrollView *classScroll; // TreeJohn
    IBOutlet UIScrollView *timeScroll; // TreeJohn
    IBOutlet UILabel *rankLbl;
    
    NSMutableArray *arrMarks;
    NSMutableArray *arrTemps;
    NSMutableArray *arrHums;
    NSMutableArray *arrPMs;
    BOOL isDayCurve;
}

@end

@implementation NewHistoryViewController

@synthesize airDevice;
@synthesize rankValue;

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
    
    isDayCurve = NO;
    arrMarks = [[NSMutableArray alloc] init];
    arrTemps = [[NSMutableArray alloc] init];
    arrHums = [[NSMutableArray alloc] init];
    arrPMs = [[NSMutableArray alloc] init];
    
    int value  = 0;
    if(!MainDelegate.isCustomer)
    {
        [self fetchHistoryData:0];
        
        value = rankValue?(isObject(rankValue)?[rankValue intValue]:0):0;
    }
    else
    {
        [self initData];
        value = 10;
    }
    
    NSString *city = [CityDataHelper cityNameOfSelectedCity];
    NSString *message;
    NSMutableAttributedString *attr;
    UIColor *color = [UIColor colorWithRed:75/255.0 green:190/255.0 blue:64/255.0 alpha:1.0];
    NSString *cityEnOrCn;
    cityEnOrCn = [MainDelegate cityNameInternationalized:city];
    
    if(value == 0)
    {
        rankLbl.hidden = YES;
    }
    else
    {
        if ([MainDelegate isLanguageEnglish]) {
            //ybyao
    //        message = [NSString stringWithFormat:@"Your air quality is better than %d%@ of users in %@",value,PercentSymbol,city];
              message = [NSString stringWithFormat:@"Your air quality is better than %d%@ of users in %@",value,PercentSymbol,cityEnOrCn];
            attr = [[NSMutableAttributedString alloc] initWithString:message];
            [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],
                                  NSForegroundColorAttributeName:color}
                          range:NSMakeRange(32, message.length - 32 - cityEnOrCn.length - 13)];
        }
        else{
           message = [NSString stringWithFormat:@"你的空气健康指数已经超过%@%d%@的用户",cityEnOrCn,value,PercentSymbol];
            attr = [[NSMutableAttributedString alloc] initWithString:message];
            [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],
                                  NSForegroundColorAttributeName:color}
                          range:NSMakeRange(12 + cityEnOrCn.length, message.length - 12 - cityEnOrCn.length - 3)];
        }

        rankLbl.attributedText = attr;
        rankLbl.hidden = NO;
    }
    
    // TreeJohn
//    curveScroll.directionalLockEnabled = YES;
//    curveScroll.delegate = self;
    classScroll.contentSize = CGSizeMake(320, 626);
//    classScroll.delegate = self;
    
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

- (void)initData
{
    [arrMarks removeAllObjects];
    [arrTemps removeAllObjects];
    [arrHums removeAllObjects];
    [arrPMs removeAllObjects];

    int num = -1;
    if(isDayCurve)
    {
        for(int i =0 ; i< 7; i++)
        {
            if(i % 2 ==0 )
            {
                num = 1;
            }
            else
            {
                num = -1;
            }
            [arrMarks addObject:[NSNumber  numberWithInt:(80 + num* (i % 5) )]];
            [arrTemps addObject:[NSNumber  numberWithInt:(10 + num* (i % 5))]];
            [arrTemps addObject:[NSNumber  numberWithInt:(20 + num* (i % 3))]];
            [arrHums addObject:[NSNumber  numberWithInt:(60 + num* (i % 5)) ]];
            [arrPMs addObject:[NSNumber  numberWithInt:(20 + num* (i % 5))]];
        }
        [arrMarks replaceObjectAtIndex:6 withObject: @80];
        [arrTemps replaceObjectAtIndex:12 withObject: @18];
        [arrTemps replaceObjectAtIndex:13 withObject: @26];
        [arrHums replaceObjectAtIndex:6 withObject: @60];
        [arrPMs replaceObjectAtIndex:6 withObject: @26];
    }
    else
    {
        for(int i =0 ; i< 24; i++)
        {
            
            if(i % 2 ==0 )
            {
                num = 1;
            }
            else
            {
                num = -1;
            }
            [arrMarks addObject:[NSNumber  numberWithInt:(80 + num* (i % 5))]];
            [arrTemps addObject:[NSNumber  numberWithInt:(20 + num* (i % 5))]];;
            [arrHums addObject:[NSNumber  numberWithInt:(60 + num* (i % 5))]];
            [arrPMs addObject:[NSNumber  numberWithInt:(20 + num* (i % 5))]];
        }
        [arrMarks replaceObjectAtIndex:23 withObject: @80];
        [arrTemps replaceObjectAtIndex:23 withObject: @21];
        [arrHums replaceObjectAtIndex:23 withObject: @60];
        [arrPMs replaceObjectAtIndex:23 withObject: @26];
    }
    
    if(isDayCurve)
    {
        [self categoryHistoryData:nil];
    }
    else
    {
        [self categoryHistoryHourData:nil];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)selectHistoryStyle:(UIButton *)sender
{
    DDLogFunction();
    isDayCurve = !isDayCurve;
    if(!MainDelegate.isCustomer)
    {
        [self fetchHistoryData:0];
    }
    else
    {
        [self initData];
    }
    [sender setImage:[UIImage imageNamed:isDayCurve?@"07-天.png":@"06-小时.png"] forState:UIControlStateNormal];
}

- (IBAction)closeButtonOnClicked:(id)sender
{
    
    DDLogFunction();
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)startDateyyyyMMdd
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    DDLogCVerbose(@"%@",[formatter stringFromDate:[NSDate date]]);
    return [formatter stringFromDate:[NSDate date]];
}
- (NSString *)startDateyyyyMMddHH
{
    NSDate *dateTmp = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHH"];
    DDLogCVerbose(@"%@",[formatter stringFromDate:dateTmp]);
    return [formatter stringFromDate:dateTmp];
}

- (void)fetchHistoryData:(NSInteger)requestCount
{
    DDLogFunction();
    [MainDelegate showProgressHubInView:self.view];
    NSDictionary *dicBody  = nil;
    if(isDayCurve)
    {
        dicBody = @{@"startDateTime":[self startDateyyyyMMdd],@"sequenceId":[MainDelegate sequenceID]};
    }
    else
    {
         dicBody = @{@"startDateTime":[self startDateyyyyMMddHH],@"hour":@"-24",@"sequenceId":[MainDelegate sequenceID]};
    }
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSURL *url = isDayCurve ? SERVER_HISTORY(airDevice.mac) : SERVER_HISTORY_HOUR(airDevice.mac);
    NSMutableURLRequest *request = [MainDelegate requestUrl:url
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         
         NSString *errorInfo = NSLocalizedString(@"获取数据失败,请检查网络",@"NewHistoryViewController.m");
         if(error)
         {
             [MainDelegate hiddenProgressHubInView:self.view];
             [AlertBox showWithMessage:errorInfo];
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->fetchHistoryData Response: %@", result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [MainDelegate hiddenProgressHubInView:self.view];
                 if([result[kDatas] isEqual:[NSNull null]])
                 {
                     [AlertBox showWithMessage:errorInfo];
                 }
                 else
                 {
                     if(isDayCurve)
                     {
                         [self categoryHistoryData:result[kDatas]];
                     }
                     else
                     {
                         [self categoryHistoryHourData:result[kDatas]];
                     }
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
    NSMutableArray *arrDate = [[NSMutableArray alloc] init];
    if(!MainDelegate.isCustomer)
    {
        [arrMarks removeAllObjects];
        [arrTemps removeAllObjects];
        [arrHums removeAllObjects];
        [arrPMs removeAllObjects];
        
        int start = (data.count > 7) ? (data.count - 7) : 0;
        for (int i = start; i < data.count; i++)
        {
            NSDictionary *dict = data[i];
            [arrMarks addObject:dict[@"mark"]];
            [arrTemps addObject:[NSNumber numberWithInt:[MainDelegate countTempVlue:dict[@"low_temp"]
                                                                           hardWare:airDevice.baseboard_software
                                                                             typeID:airDevice.type]]];
            [arrTemps addObject:[NSNumber numberWithInt:[MainDelegate countTempVlue:dict[@"high_temp"]
                                                                           hardWare:airDevice.baseboard_software
                                                                             typeID:airDevice.type]]];
            NSNumber *aveTemp = [NSNumber numberWithDouble:([dict[@"low_temp"] doubleValue] + [dict[@"high_temp"] doubleValue]) / 2];
            [arrHums addObject:[NSNumber numberWithInt:[MainDelegate countHumValue:dict[@"humidity"]
                                                                          withTemp:aveTemp
                                                                          hardWare:airDevice.baseboard_software
                                                                            typeID:airDevice.type]]];
            [arrPMs addObject:dict[@"pm25"]];
            [arrDate addObject:[self coventString:dict[@"dateTime"]]];
        }
    }
    else
    {
        // 获取Key
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        NSDate *curDate = [[NSDate alloc] init];
        for(int i =6 ; i>=0; i--)
        {
            NSDate *dateTmp = [NSDate dateWithTimeInterval:-i * 60*60*24 sinceDate:curDate];
            NSString *dateString = [dateFormatter stringFromDate:dateTmp];
            [arrDate addObject:[self coventString:dateString]];
        }
    }
    
    if(arrDate.count > 0)
    {
        [arrDate replaceObjectAtIndex:arrDate.count - 1 withObject:NSLocalizedString(@"今天",@"NewHistoryViewController.m")];
    }
    
    [self addCureViews:arrDate];
}

- (void)categoryHistoryHourData:(NSArray *)data
{
    NSMutableArray *arrTime = [[NSMutableArray alloc] init];
    if(!MainDelegate.isCustomer)
    {
        [arrMarks removeAllObjects];
        [arrTemps removeAllObjects];
        [arrHums removeAllObjects];
        [arrPMs removeAllObjects];
    
        int startIndex = 0;
        if(data.count > 24)
        {
            startIndex  = data.count - 24;
        }
        for (int i = startIndex; i < data.count; i++)
        {
            NSDictionary *dict = data[i];
            [arrMarks addObject:dict[@"mark"]];
            [arrTemps addObject:[NSNumber numberWithInt:[MainDelegate countTempVlue:dict[@"temperature"]
                                                                           hardWare:airDevice.baseboard_software
                                                                             typeID:airDevice.type]]];
            [arrHums addObject:[NSNumber numberWithInt:[MainDelegate countHumValue:dict[@"humidity"]
                                                                          withTemp:dict[@"temperature"]
                                                                          hardWare:airDevice.baseboard_software
                                                                            typeID:airDevice.type]]];
            [arrPMs addObject:dict[@"pm25"]];
            NSString *time = dict[@"hourTime"] ;
            if(time.length >1)
            {
                [arrTime addObject:[NSString stringWithFormat:@"%d:00",[[time substringFromIndex:(time.length - 2)] intValue]]];
            }
            else
            {
                [arrTime addObject:[NSString stringWithFormat:@"%d:00",[time intValue]]];
            }
        }
    }
    else
    {
        // 获取Key
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH"];
        NSDate *curDate = [[NSDate alloc] init];
        for(int i =23 ; i>=0; i--)
        {
            NSDate *dateTmp = [NSDate dateWithTimeInterval:-i * 60*60 sinceDate:curDate];
            NSString *dateString = [dateFormatter stringFromDate:dateTmp];
            [arrTime addObject:[NSString stringWithFormat:@"%d:00",[dateString intValue]]];
        }
    }
    
    if(arrTime.count > 0)
    {
        [arrTime replaceObjectAtIndex:arrTime.count - 1 withObject:NSLocalizedString(@"当前",@"NewHistoryViewController.m")];
    }
    
    [self addCureViews:arrTime];
}

- (NSString *)coventString:(NSString *)string
{
    //ybyao07
    //20141101
    NSMutableString *newStr;
    if (string !=nil && string.length== 8) {
        newStr = [NSMutableString stringWithString:[string substringFromIndex:4]];
        [newStr insertString:@"." atIndex:2];
    }
    //ybyao07
    return newStr;
}

//4.0 inch

//#define MarkFrame CGRectMake(9.5, 0, 200, 99)
//#define TempFrame CGRectMake(9.5, 99, 200, 99)
//#define HumFrame CGRectMake(9.5, 198, 200, 99)
//#define PMFrame CGRectMake(9.5, 297, 200, 99)

//3.5 inch

//#define MarkFrame35 CGRectMake(9.5, 0, 200, 82)
//#define TempFrame35 CGRectMake(9.5, 82, 200, 82)
//#define HumFrame35 CGRectMake(9.5, 164, 200, 82)
//#define PMFrame35 CGRectMake(9.5, 246, 200, 82)

//4.0 inch no pm

#define MarkFrame CGRectMake(9.5, 0, 200, 132)
#define TempFrame CGRectMake(9.5, 132, 200, 132)
#define HumFrame CGRectMake(9.5, 264, 200, 132)


//3.5 inch no pm

#define MarkFrame35 CGRectMake(9.5, 0, 200, 109)
#define TempFrame35 CGRectMake(9.5, 109, 200, 109)
#define HumFrame35 CGRectMake(9.5, 218, 200, 109)

- (UILabel *)getTextLableWithFrame: (CGRect) frame text: (NSString *) textStr
{
    UILabel *text = [[UILabel alloc] initWithFrame:frame];
    [text setAdjustsFontSizeToFitWidth:YES];
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor colorWithARGB:0xa2ffffff];
//    text.font = [UIFont fontWithName:@"Thonburi" size:13.0];
     text.font = [UIFont fontWithName:@"Thonburi" size:11.0];//ybyao07
    text.textAlignment = NSTextAlignmentCenter;
    
    text.text = textStr;
    return text;
}

- (UIImageView *)getLineViewWithFrame: (CGRect) frame
{
    UIImageView *lineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"14-分割.png"]];
    lineView.frame = frame;
    lineView.backgroundColor = [UIColor clearColor];
    lineView.contentMode = UIViewContentModeScaleToFill;
    return lineView;
}

- (void)addCureViews:(NSMutableArray *)date
{
    float tag = 72;//blue
    if (isDayCurve) {
         tag = 44.0;
    } else {
        tag = 72.0;
    }
    
    
    [[curveScroll1 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[curveScroll2 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[curveScroll3 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[curveScroll4 subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (int i = 0; i < arrMarks.count; i++)
    {

        
        //ybyao07
        CGRect lineFrame = CGRectMake((20 + tag * i), 0, 1, curveScroll1.frame.size.height - 30);
        [curveScroll1 addSubview:[self getLineViewWithFrame:lineFrame]];
        [curveScroll2 addSubview:[self getLineViewWithFrame:lineFrame]];
        [curveScroll3 addSubview:[self getLineViewWithFrame:lineFrame]];
        [curveScroll4 addSubview:[self getLineViewWithFrame:lineFrame]];
        
//        UIImageView *pointView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"15-分割点.png"]];
//        pointView.frame = CGRectMake((17 + 72 * i), 0, 5, 5);
//        pointView.backgroundColor = [UIColor clearColor];
//        pointView.contentMode = UIViewContentModeScaleToFill;
//        [curveScroll addSubview:pointView];
        
        //ybyao07
//        CGRect textFrame = CGRectMake((0 + i * 72), 90, 38, 17);
        CGRect textFrame = CGRectMake((0 + i * tag), 90, 38, 17);
        [curveScroll1 addSubview:[self getTextLableWithFrame:textFrame text:date[i]]];
        [curveScroll2 addSubview:[self getTextLableWithFrame:textFrame text:date[i]]];
        [curveScroll3 addSubview:[self getTextLableWithFrame:textFrame text:date[i]]];
        [curveScroll4 addSubview:[self getTextLableWithFrame:textFrame text:date[i]]];
    }
    
    if(arrMarks.count > 0)
    {
        CGRect markRect = CGRectMake(9.5, 0, 200,  curveScroll1.frame.size.height);
//        markRect.size.width = 72 * (arrMarks.count - 1) + 32;
        markRect.size.width = tag * (arrMarks.count - 1) + 32;//ybyao07
        
        NewCurveView *markCurve = [[NewCurveView alloc] initWithFrame:markRect
                                                              andData:arrMarks
                                                                 isPM:NO
                                                            curveType:kExponent
                                                                isDay:isDayCurve];
        markCurve.tag = MarkCurveTag;
        [curveScroll1 addSubview:markCurve];
        
        CGRect tempRect =  CGRectMake(9.5, 0, 200, curveScroll2.frame.size.height);
        
        tempRect.size.width = tag * (arrMarks.count - 1) + 36;
        NewCurveView *tempCurve = [[NewCurveView alloc] initWithFrame:tempRect
                                                              andData:arrTemps
                                                                 isPM:NO
                                                            curveType:kTemp
                                                                isDay:isDayCurve];
        tempCurve.tag = TempCurveTag;
        [curveScroll2 addSubview:tempCurve];
        
        CGRect humRect = CGRectMake(9.5, 0, 200, curveScroll3.frame.size.height);
        humRect.size.width = tag * (arrMarks.count - 1) + 36;
        NewCurveView *humCurve = [[NewCurveView alloc] initWithFrame:humRect
                                                             andData:arrHums
                                                                isPM:NO
                                                           curveType:kHum
                                                               isDay:isDayCurve];
        humCurve.tag = HumCurveTag;
        [curveScroll3 addSubview:humCurve];
        

        CGRect pmRect = CGRectMake(9.5, 0, 200, curveScroll4.frame.size.height);
        pmRect.size.width = tag * (arrMarks.count - 1) + 36;
        NewCurveView *pmCurve = [[NewCurveView alloc] initWithFrame:pmRect
                                                            andData:arrPMs
                                                               isPM:YES
                                                          curveType:kPM25
                                                              isDay:isDayCurve];
        pmCurve.tag = PMCurveTag;
        [curveScroll4 addSubview:pmCurve];
        
        curveScroll1.contentSize = CGSizeMake(markRect.size.width, curveScroll1.frame.size.height); // by TreeJohn
        curveScroll2.contentSize = CGSizeMake(markRect.size.width, curveScroll2.frame.size.height); // by TreeJohn
        curveScroll3.contentSize = CGSizeMake(markRect.size.width, curveScroll3.frame.size.height); // by TreeJohn
        curveScroll4.contentSize = CGSizeMake(markRect.size.width, curveScroll4.frame.size.height); // by TreeJohn
//        timeScroll.contentSize = CGSizeMake(markRect.size.width, 26);
//        if(curveScroll.contentSize.width > 320)
        {
            CGPoint point = CGPointMake(curveScroll1.contentSize.width - curveScroll1.frame.size.width, 0);
            [curveScroll1 setContentOffset:point animated:YES];
            [curveScroll2 setContentOffset:point animated:YES];
            [curveScroll3 setContentOffset:point animated:YES];
            [curveScroll4 setContentOffset:point animated:YES];
//            [timeScroll setContentOffset:point animated:YES];
        }
    }
}

// add by TreeJohn
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView == classScroll) {
//        curveScroll.contentOffset = CGPointMake(curveScroll.contentOffset.x, classScroll.contentOffset.y);
//    } else if (scrollView == curveScroll) {
//        classScroll.contentOffset = CGPointMake(classScroll.contentOffset.x, curveScroll.contentOffset.y);
//        timeScroll.contentOffset = CGPointMake(curveScroll.contentOffset.x, timeScroll.contentOffset.y);
//    }
}

@end
