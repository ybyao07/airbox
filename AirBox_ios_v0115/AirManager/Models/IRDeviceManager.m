//
//  IRDeviceManager.m
//  AirManager
//

#import "IRDeviceManager.h"
#import "ZipArchive.h"
#import "IRDevice.h"
#import "AirDevice.h"
#import "DDData.h"
#import "AppDelegate.h"

@interface IRDeviceManager (){

}

/**
 *  Start download IRCode
 **/
- (void)downloadIRCode:(IRDevice *)irDevice onDevice:(AirDevice *)airDevice;

/**
 *  Start check IRCode Version
 **/
- (void)checkIRCode:(IRDevice *)irDevice onDevice:(AirDevice *)airDevice curVersion:(NSString *)version;


@end

@implementation IRDeviceManager

@synthesize completionHandler;

- (id)init{
    self = [super init];
    if(self){
    
    }
    return self;
}

#pragma mark - IR Device Check

- (void)checkIRDevice:(IRDevice *)irDevice onAirDevice:(AirDevice *)airDevice
{
    NSMutableDictionary *allIRCode = [NSMutableDictionary dictionaryWithDictionary:[UserDefault objectForKey:IRDeviceIRCodeStore]];
    if([allIRCode count] > 0)
    {
        NSString *name = [NSString stringWithFormat:@"%@%@%@",irDevice.brand,irDevice.devType,irDevice.devModel];
        //Use name gets the current IRCode info
        NSDictionary *irCode = allIRCode[name];
        if([irCode count] > 0)
        {
            //Enter check
            [self checkIRCode:irDevice onDevice:airDevice curVersion:irCode[Version]];
        }
        else
        {
            //Enter Download IRCode
            [self downloadIRCode:irDevice onDevice:airDevice];
        }
    }
    else
    {
        //没有红外码，直接下载
        [self downloadIRCode:irDevice onDevice:airDevice];
    }
}

- (void)checkIRCode:(IRDevice *)irDevice onDevice:(AirDevice *)airDevice curVersion:(NSString *)version
{
    NSString *type = irDevice.devType != nil ? irDevice.devType : @"";
    NSString *brand = irDevice.brand != nil ? irDevice.brand : @"";
    NSString *model = irDevice.devModel != nil ? irDevice.devModel : @"";
    NSString *mac = airDevice.mac != nil ? airDevice.mac : @"";
    NSDictionary *dicDevice = @{@"brand":brand,@"devType":type,@"devModel":model};
    NSDictionary *dicBody = @{@"irdevice":dicDevice,@"irversion":version,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_CHECK_IRCODE(mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             completionHandler(isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->红外编码版本检测--->%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 if(![result[@"result"] isEqual:[NSNull null]] && [isObject(result[@"result"])?result[@"result"]:@"0" boolValue])
                 {
                     //有新版本
                     [self downloadIRCode:irDevice onDevice:airDevice];
                 }
                 else
                 {
                     isSucceed = YES;
                     completionHandler(isSucceed);
                 }
             }
             else
             {
                 completionHandler(isSucceed);
             }
         }
     }];
}

#pragma mark Download and Parse IR Code

- (void)downloadIRCode:(IRDevice *)irDevice onDevice:(AirDevice *)airDevice
{
    NSString *type = irDevice.devType != nil ? irDevice.devType : @"";
    NSString *brand = irDevice.brand != nil ? irDevice.brand : @"";
    NSString *model = irDevice.devModel != nil ? irDevice.devModel : @"";
    NSString *mac = airDevice.mac != nil ? airDevice.mac : @"";
    NSDictionary *dicDevice = @{@"brand":brand,@"devType":type,@"devModel":model};
    NSDictionary *dicBody = @{@"irdevice":dicDevice,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_DOWNLOAD_IRCODE(mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             completionHandler(isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->空气盒子绑定的红外设备的红外编码%@",result);
             
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 NSString *zipFileName = [NSString stringWithFormat:@"%@_%@_%@_%@",type,brand,model,result[Version]];
                 zipFileName = [zipFileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
                 zipFileName = [zipFileName stringByReplacingOccurrencesOfString:@"(" withString:@""];
                 zipFileName = [zipFileName stringByReplacingOccurrencesOfString:@")" withString:@""];
                 /**---------------
                 *  存储红外设备红外码
                 NSString *irCodeStoreName = [NSString stringWithFormat:@"%@%@%@%@",mac,brand,type,model];
                 ---------------**/
                 NSString *irCodeStoreName = [NSString stringWithFormat:@"%@%@%@",brand,type,model];
                 NSDictionary *dicFinalIRCode = [self parserIRCode:result fileName:zipFileName devType:type];
                 NSMutableDictionary *allIRCode = [NSMutableDictionary dictionaryWithDictionary:[UserDefault objectForKey:IRDeviceIRCodeStore]];
                 NSString *version = result[Version] != nil ? result[Version] : @"";
                 if(!dicFinalIRCode)
                 {
                     dicFinalIRCode = [NSDictionary dictionary];
                 }
                 NSDictionary *irCodeInfo = @{Version:version,IRCode:dicFinalIRCode};
                 [allIRCode setObject:irCodeInfo forKey:irCodeStoreName];
                 [UserDefault setObject:allIRCode forKey:IRDeviceIRCodeStore];
                 [UserDefault synchronize];
                 
                 isSucceed = YES;
                 completionHandler(isSucceed);
             }
             else
             {
                 completionHandler(isSucceed);
             }
         }
     }];
}

- (NSDictionary *)parserIRCode:(NSDictionary *)dicCode fileName:(NSString *)name devType:(NSString *)type{
    //先将IRCode写入本地，再解析，
    //NSData *irZip = [dicCode[IRZIPCode] dataUsingEncoding:NSISOLatin1StringEncoding];
    NSData *zip = [dicCode[IRZIPCode] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *irZip = [zip base64Decoded];
    NSURL *url = [MainDelegate applicationDocumentsDirectory];
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@.zip",[url path],name];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",[url path],name];
    NSError *error;
    if(![irZip writeToFile:zipPath options:NSDataWritingAtomic error:&error])
    {
        DDLogCVerbose(@"保存红外码ZIP失败");
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] initWithFileManager:[NSFileManager defaultManager]];
    if([zipArchive UnzipOpenFile:zipPath]){
        [zipArchive UnzipFileTo:[url path] overWrite:YES];
        [zipArchive UnzipCloseFile];
    }

    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if(string == nil)
    {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        string = [NSString stringWithContentsOfFile:filePath encoding:enc error:nil];
        string = [string stringByReplacingOccurrencesOfString:@"自动" withString:@"30e0W6"];
        string = [string stringByReplacingOccurrencesOfString:@"高风" withString:@"30e0W2"];
        string = [string stringByReplacingOccurrencesOfString:@"中风" withString:@"30e0W3"];
        string = [string stringByReplacingOccurrencesOfString:@"低风" withString:@"30e0W4"];
        string = [string stringByReplacingOccurrencesOfString:@"智能" withString:@"30e0M1"];
        string = [string stringByReplacingOccurrencesOfString:@"制冷" withString:@"30e0M2"];
        string = [string stringByReplacingOccurrencesOfString:@"制热" withString:@"30e0M3"];
        string = [string stringByReplacingOccurrencesOfString:@"送风" withString:@"30e0M4"];
        string = [string stringByReplacingOccurrencesOfString:@"除湿" withString:@"30e0M5"];
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dicIRCode = [MainDelegate parseJsonData:data];
    
    //用于存储解析完的红外码数据
    NSMutableDictionary *dicParserIRCode = [[NSMutableDictionary alloc] init];
    NSArray *arrIRCode = dicIRCode[IRCode];
    BOOL healthyFunction = NO;
    for(int i = 0; i < [arrIRCode count]; i++)
    {
        NSDictionary *code = arrIRCode[i];
        NSDictionary *condition = code[@"props"];
        NSString *key = [NSString stringWithFormat:@"%@%@%@%@",
                         condition[@"temperature"],
                         condition[@"windspeed"],
                         condition[@"mode"],
                         condition[@"onoff"]];
        if(condition[HealthyState])
        {
            healthyFunction = YES;
            key = [key stringByAppendingString:condition[HealthyState]];
        }
        
        if([condition[@"onoff"] isEqualToString:IRDeviceClose])
        {
            key = IRDeviceCloseCodeTag;
        }
        else if([condition[@"onoff"] isEqualToString:IRDeviceOpen] && [type isEqualToString:@"AP"])
        {
            key = APDeviceOpenCodeTag;
        }
        [dicParserIRCode setObject:code[@"op_code"] forKey:key];
    }
    
    if(dicIRCode[TempLimt])
    {
        [dicParserIRCode setObject:dicIRCode[TempLimt] forKey:TempLimt];
    }
    else
    {
        [dicParserIRCode setObject:@"" forKey:TempLimt];
    }
    
    [dicParserIRCode setObject:[NSNumber numberWithBool:healthyFunction] forKey:HealthyState];
    
    [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    return [NSDictionary dictionaryWithDictionary:dicParserIRCode];
}

#pragma mark - Download IR Device List

- (void)loadIRDeviceBindOnAirDevice:(NSString *)mac
                  completionHandler:(void(^)(NSMutableArray *irDevices,BOOL isLoadSucceed,BOOL isBindAC))handler
{
    //空气盒子存在，进入空气盒子绑定的红外设备check流程
    NSDictionary *dicBody = @{@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_BINDED_IRDEV(mac)
                                                    method:HTTP_POST
                                                       body:body];
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@",SERVER_BINDED_IRDEV(mac)];
    [NSURLConnection sendAsynchronousRequestCache:request
                                            queue:[NSOperationQueue mainQueue]
                                         cacheKey:cacheKey
                                completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isLoadSucceed = NO;
         BOOL isBindACDevice = NO;
         NSMutableArray *arrBindedIRDevice = nil;

         if(error)
         {
             handler(arrBindedIRDevice,isLoadSucceed,isBindACDevice);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->loadIRDeviceBindOnAirDevice信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 [[DataController getInstance] addCache:data andCacheKey:cacheKey];
                 isLoadSucceed = YES;
                 arrBindedIRDevice = [self parserIRDevice:isObject(result[@"irdevices"])?result[@"irdevices"]:[NSArray array]];
                 if([self isBindedACDevice:arrBindedIRDevice])
                 {
                     isBindACDevice = YES;
                 }
                 handler(arrBindedIRDevice,isLoadSucceed,isBindACDevice);
             }
             else
             {
                 handler(arrBindedIRDevice,isLoadSucceed,isBindACDevice);
             }
         }
     }];
}

- (NSMutableArray *)parserIRDevice:(NSArray *)list
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if([list isEqual:[NSNull null]])
    {
        return array;
    }
    
    for (int i = 0; i < [list count]; i++)
    {
        IRDevice *irDevice = [[IRDevice alloc] initWithDevice:list[i]];
        [array addObject:irDevice];
    }
    return array;
}

- (BOOL)isBindedACDevice:(NSMutableArray *)list
{
    for (int i = 0; i < [list count]; i++)
    {
        IRDevice *irDevice = list[i];
        if([irDevice.devType isEqualToString:@"AC"])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Remove Binded IR Device 

- (void)removeBindIRDevice:(IRDevice *)irDevice onAirDevice:(AirDevice *)airDevice completionHandler:(void(^)(BOOL isSucceed))handler
{
    NSDictionary *dicDevice = @{@"brand":irDevice.brand,
                                @"devType":irDevice.devType,
                                @"devModel":irDevice.devModel};
    NSDictionary *dicBody = @{@"irdevice":dicDevice,@"sequenceId":[MainDelegate sequenceID]};
    NSString *body = [MainDelegate createJsonString:dicBody];
    NSMutableURLRequest *request = [MainDelegate requestUrl:SERVER_UNBIND_IRDEV(airDevice.mac)
                                                     method:HTTP_POST
                                                       body:body];
    [NSURLConnection sendAsynchronousRequestTest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
     {
         BOOL isSucceed = NO;
         if(error)
         {
             handler(isSucceed);
         }
         else
         {
             NSDictionary *result = [MainDelegate parseJsonData:data];
             result = isObject(result) ? result : nil;
             DDLogCVerbose(@"--->removeBindIRDevice接口信息%@",result);
             if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
             {
                 isSucceed = YES;
                 handler(isSucceed);
             }
             else
             {
                 handler(isSucceed);
             }
         }
     }];
}

@end
