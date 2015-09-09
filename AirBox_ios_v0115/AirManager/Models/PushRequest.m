//
//  PushRequest.m
//  AirManager
//
//  Created by qitmac000242 on 15-1-16.
//  Copyright (c) 2015年 luolin. All rights reserved.
//

#import "PushRequest.h"
#import "AppDelegate.h"
#import "UserLoginedInfo.h"
#import "PushMessage.h"

static PushRequest *globalPushRequest = nil;


@implementation PushRequest


+ (PushRequest *)getInstance
{
    @synchronized(self)
    {
        // 实例对象只分配一次
        if(globalPushRequest == nil)
        {
            globalPushRequest = [[super allocWithZone:NULL] init];
        }
    }
    
    return globalPushRequest;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


// 发送Token
+ (void)sendTokenStart:(NSData *)deviceToken
{
}


// 获取推送消息信息
+ (void)getMessageDetail:(NSDictionary *)userInfoAps
{
    // 网络可用，且userid不为空的时候，才需要获取
    if(MainDelegate.loginedInfo.userID.length > 0 && [MainDelegate isNetworkAvailable])
    {
        NSString *messageID = [userInfoAps objectForKey:@"msg"];
        NSString *local;
        if ([MainDelegate isLanguageEnglish]) {
            local = @"en";
        }else{
            local = @"zh";
        }
        
        NSString *requestStr = [NSString stringWithFormat:@"%@?sequenceId=%@&appId=%@&type=M&messageIds=%@&local=%@",SERVER_PUSH_MESSAGE(MainDelegate.loginedInfo.userID),[MainDelegate sequenceID],APP_ID,messageID,local];
        NSURL *url = [NSURL URLWithString:requestStr];
        NSMutableURLRequest *request = [MainDelegate requestUrl:url
                                                         method:HTTP_GET
                                                           body:nil];
        [NSURLConnection sendAsynchronousRequestTest:request
                                               queue:[NSOperationQueue currentQueue]
                                   completionHandler:^(NSURLResponse *response,NSData *data,NSError *error)
         {
             if(error)
             {
#warning 袁杰测试需要删除
//                 PushMessage *pushMessage = [[PushMessage alloc] init];
//                 pushMessage.titleMessage = [userInfoAps objectForKey:@"titleText"];
//                 pushMessage.contentType = messageID;
//                 pushMessage.contentMessage = [userInfoAps objectForKey:@"contentText"];
//                 
//                 [MainDelegate doHandleMessage:pushMessage];
//                 return;
             }
             else
             {
                 NSDictionary *result = [MainDelegate parseJsonData:data];
                 result = isObject(result) ? result : nil;
                 
                 DDLogCVerbose(@"--->getMessageDetail%@",result);
                 if(result && ![result[HttpReturnCode] isEqual:[NSNull null]] && [result[HttpReturnCode] intValue] == 0)
                 {
                     if(result[@"data"] && ![result[@"data"] isEqual:[NSNull null]])
                     {
                         if(result[@"data"][@"message"] && ![result[@"data"][@"message"] isEqual:[NSNull null]])
                         {
                             NSMutableArray *arrMessage = result[@"data"][@"message"];
                             if(arrMessage.count > 0)
                             {
                                 NSDictionary *dicMessage = [arrMessage objectAtIndex:0];
                                 if(dicMessage && ![dicMessage isEqual:[NSNull null]])
                                 {
                                     if(dicMessage[@"body"] && ![dicMessage[@"body"] isEqual:[NSNull null]])
                                     {
                                         PushMessage *pushMessage = [[PushMessage alloc] init];
                                         if(dicMessage[@"body"][@"title"] && ![dicMessage[@"body"][@"title"] isEqual:[NSNull null]])
                                         {
                                             pushMessage.titleMessage = dicMessage[@"body"][@"title"];
                                         }
                                         if(dicMessage[@"body"][@"contentType"] && ![dicMessage[@"body"][@"contentType"] isEqual:[NSNull null]])
                                         {
                                             pushMessage.contentType = dicMessage[@"body"][@"contentType"];
                                         }
                                         if(dicMessage[@"body"][@"content"] && ![dicMessage[@"body"][@"content"] isEqual:[NSNull null]])
                                         {
                                             pushMessage.contentMessage = dicMessage[@"body"][@"content"];
                                         }
                                         
                                         [MainDelegate doHandleMessage:pushMessage];
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
         }];
    }
    
}

+ (void)startHandleMessage:(NSDictionary *)userInfo
{
    if (userInfo != nil)
    {
        // 获得推送的参数
        NSDictionary *userInfoAps = [userInfo objectForKey:@"aps"];
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        
        // 推送消息过来，设置程序接收的参数
        if (userInfoAps != nil)
        {
            NSString *pushMessageID = [userInfoAps objectForKey:@"msg"];
            
            [MainDelegate setPushMessageID:pushMessageID];
            
            
#warning 袁杰测试需要删除
//            [MainDelegate sendConfirmMessage:@YES];
            
            // 启动带ID的消息处理
            if (pushMessageID != nil)
            {
                [PushRequest getMessageDetail:userInfoAps];
            }
        }
    }
}


@end
