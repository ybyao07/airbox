//
//  Utility.m
//  AirManager
//
//  Created by yuan jie on 14-8-27.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"
#import "IRDevice.h"

@implementation Utility

+ (NSInteger) getPM25Color:(NSString *)pm25
{
    NSInteger pm25Color =  0x0fcf26;
   
    if([pm25 integerValue]<= 35)
    {
        pm25Color =  0x0fcf26;
    }
    else if([pm25 integerValue]<= 75 && [pm25 integerValue] >35)
    {
        pm25Color =  0xb9e508;
    }
    else if([pm25 integerValue]<= 115 && [pm25 integerValue] >75)
    {
        pm25Color =  0xfff600;
    }
    else if([pm25 integerValue]<= 150 && [pm25 integerValue] >115)
    {
        pm25Color =  0xffb400;
    }
    else if([pm25 integerValue]<= 250 && [pm25 integerValue] > 150)
    {
        pm25Color =  0xff6c00;
    }
    else if([pm25 integerValue]<= 500 && [pm25 integerValue] > 250)
    {
        pm25Color =  0xc71700;
    }
    else
    {
        pm25Color =  0xc71700;
    }
    
    return pm25Color;
}

+ (NSString *) getPM25StatusString:(NSString *)pm25
{
    NSString *pm25String =  @"优";
    
    if([pm25 integerValue]<= 35)
    {
        pm25String =  @"优";
    }
    else if([pm25 integerValue]<= 75 && [pm25 integerValue]> 35)
    {
        pm25String =  @"良";
    }
    else if([pm25 integerValue]<= 115 && [pm25 integerValue]> 75)
    {
        pm25String =  @"轻度污染";
    }
    else if([pm25 integerValue]<= 150 && [pm25 integerValue]> 115)
    {
        pm25String =  @"中度污染";
    }
    else if([pm25 integerValue]< 250 && [pm25 integerValue]> 150)
    {
        pm25String =  @"重度度污染";
    }
    else if([pm25 integerValue]<= 500 && [pm25 integerValue]> 250)
    {
        pm25String = @"严重污染";
    }
    else
    {
        pm25String = @"严重污染";
    }
    
    return pm25String;
}

+  (NSString *)coventPM25StatusForAirManagerIndoor:(NSString *)code withMac:(NSString *)mac
{
    NSString* str = @"";
    
    if([code isEqualToString:@"30w001"])
    {
        str = @"25";
    }
    else if([code isEqualToString:@"30w002"])
    {
        str =  @"75";
    }
    else if([code isEqualToString:@"30w003"])
    {
        str =  @"125";
    }
    else if([code isEqualToString:@"30w004"])
    {
        str =  @"325";
    }
    else if([code intValue] > 0 && [code intValue] <= 500)
    {
        return code;
    }
    else if([code intValue] > 500)
    {
        return @"500";
    }
    else
    {
        return @"--";
    }
    
    NSArray *arrPm25 = [MainDelegate.pm25FloatRange objectForKey:mac];
    float xNum = 70.0f ;
    float yNum = 30.0f;
    float zNum = 4.0f;
    float aNum = 0.0f;
    if(arrPm25 && arrPm25.count >= 3)
    {
        xNum =[[arrPm25 objectAtIndex:0] floatValue];
        yNum=[[arrPm25 objectAtIndex:1] floatValue];
        zNum=[[arrPm25 objectAtIndex:2] floatValue];
        if(arrPm25.count >= 4)
        {
            aNum = [[arrPm25 objectAtIndex:3] floatValue];
        }
    }
    
    float totalFloat=xNum/ 100 *[ str floatValue] +(yNum / 100) * aNum + zNum;
    DDLogCVerbose(@"intLblPM=%d",(int)totalFloat);
    return  [NSString stringWithFormat:@"%d",(int)totalFloat];
}

+  (NSString *)coventPM25StatusForAirManager:(NSString *)code
{
    if ([code isEqualToString:@"--"])
    {
         return @"--";
    }
    else if([code intValue] > 0 && [code intValue] <= 500)
    {
        return code;
    }
    else if([code intValue] > 500)
    {
        return @"500";
    }
    else
    {
        return @"--";
    }
}


//真实温度算法：
+ (NSInteger) getRealTemp:(NSInteger) temp
{
    return (int) round((temp - 300) / 10.0 - 4.5);
}
//真实湿度算法：
+ (NSInteger)  getRealHumi2:(NSInteger)humi Temp:(NSInteger)temp
{
    int realHumi = (int) round((humi / 10.0)
                                    * exp(4283.78 * (4.5 - 1) / (243.12 + (temp - 300) / 10.0)
                                               / (243.12 + ((temp - 300) / 10.0 - 4.5))));
    if (realHumi > 100) {
        return 100;
    } else if (realHumi < 0) {
        return 0;
    } else {
        return realHumi;
    }
}

static const NSInteger bestSSD=70;

//温度大于等于60时健康指数调用的方法：
+ (NSInteger) happyScore:(double_t) i_t :(double_t) i_f :(NSInteger) pm25 :(NSInteger) voc
{
    i_t = [Utility getRealTemp:(int) i_t];
    i_f = [Utility getRealHumi2:(int)i_f Temp:i_t];
    double i_ssd = [Utility comfortScore:i_t :i_f : 0];
    double i_score = 100 - (i_ssd > bestSSD ? (i_ssd - bestSSD) * 3
                            : (bestSSD - i_ssd) * 2);
    if (i_score < 0) {
        i_score = 0;
    }
    double pm_score = 100 - (pm25 / 25) * 10;
    double voc_score = 100 - (voc / 25) * 10;
    double result = i_score * 0.3 + pm_score * 0.35 + voc_score * 0.35;
    if (result > 100) {
        result = 100;
    } else if (result < 0) {
        result = 0;
    }
    return (int) result;
}
//其他情况健康指数调用的方法：
+ (NSInteger) happyScore3:(double_t) i_t :(double_t) i_f :(NSInteger) pm25 :(NSInteger) voc
{
    double i_ssd = [Utility comfortScore:i_t :i_f : 0];
    double i_score = 100 - (i_ssd > bestSSD ? (i_ssd - bestSSD) * 3
                            : (bestSSD - i_ssd) * 2);
    if (i_score < 0) {
        i_score = 0;
    }
    double pm_score = 100 - (pm25 / 25) * 10;
    double voc_score = 100 - (voc / 25) * 10;
    double result = i_score * 0.3 + pm_score * 0.35 + voc_score * 0.35;
    if (result > 100) {
        result = 100;
    } else if (result < 0) {
        result = 0;
    }
    return (int) result;
}
//舒适度算法：
+ (double)comfortScore:(double) t  :(double) f :(int) v
{
    if (t == 45) {
        t = 45.1;
    }
    double ssd = 0.0;// 舒适度
    // 舒适度计算公式 
    // ssd=(1.818t+ 18.18)(0.88 + 0.002f)+(t- 32) / (45 -t)- 3.2v+ 18.2 
    ssd = (1.818 * t + 18.18) * (0.88 + 0.002 * f) + (t - 32) / (45 - t) 
    - 3.2 * v + 18.2; 
    // 四舍五入 
    // int result= new BigDecimal(ssd).setScale(0, 
    // BigDecimal.ROUND_HALF_UP).intValue(); 
    // return result; 
    if (ssd < 0) { 
        ssd = 0; 
    } 
    return ssd; 
}


//计算时间差防止按钮连续点击
+ (NSString*)GetCurTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    NSString*timeString=[formatter stringFromDate: [NSDate date]];
    return timeString;
}

+ (double)GetStringTimeDiff:(NSString*)timeS timeE:(NSString*)timeE
{
    double timeDiff = 0.0;
    NSDateFormatter *formatters = [[NSDateFormatter alloc] init];
    [formatters setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    NSDate *dateS = [formatters dateFromString:timeS];
    
    NSDateFormatter *formatterE = [[NSDateFormatter alloc] init];
    [formatterE setDateFormat:@"yyyy/MM/dd HH:mm:ss:SSS"];
    NSDate *dateE = [formatterE dateFromString:timeE];
    timeDiff = [dateE timeIntervalSinceDate:dateS ];
    DDLogCVerbose(@"timeInterval=%lf",timeDiff);
    return timeDiff;
}
+(void)storeCurrentTime
{
    NSString *curTime = [self GetCurTime];
    [UserDefault setObject:curTime forKey:CurrentTime];
}


+ (void)setExclusiveTouchAll:(UIView *)sender
{
    for (UIView *subView in sender.subviews) {
        [subView setExclusiveTouch:YES];
        if (subView.subviews.count !=0 && [subView isKindOfClass:[UIView class]]) {
            [self setExclusiveTouchAll:subView];
        }
    }
}

+ (BOOL)isBindedDevice:(NSMutableArray *)list withType:(NSString *)type
{
    DDLogFunction();
    for (int i = 0; i < [list count]; i++)
    {
        IRDevice *irDevice = list[i];
        if([irDevice.devType isEqualToString:type])
        {
            return YES;
        }
    }
    return NO;
}
+ (NSMutableDictionary *)jsonValue :(NSString *)str
{
    DDLogFunction();
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}


+ (BOOL)isVoiceAirDevice:(AirDevice *)device
{
    if(MainDelegate.isCustomer)
    {
        return YES;
    }
    // 语音盒子
    if([device.type isEqualToString:AIRBOX_IDENTIFIER_V15])
    {
        return YES;
    }
    return NO;
}

@end
