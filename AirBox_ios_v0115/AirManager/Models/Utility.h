//
//  Utility.h
//  AirManager
//
//  Created by yuan jie on 14-8-27.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AirDevice.h"

@interface Utility : NSObject

+ (NSInteger) getPM25Color:(NSString *)pm25;

+ (NSString *) getPM25StatusString:(NSString *)pm25;


/**
 *  covent pm2.5 value to string
 **/
+  (NSString *)coventPM25StatusForAirManagerIndoor:(NSString *)code withMac:(NSString *)mac;
+ (NSString *)coventPM25StatusForAirManager:(NSString *)code;

+ (NSInteger) happyScore:(double_t) i_t :(double_t) i_f :(NSInteger) pm25 :(NSInteger) voc;
+ (NSInteger) happyScore3:(double_t) i_t :(double_t) i_f :(NSInteger) pm25 :(NSInteger) voc;

//ybyao
+ (NSString*)GetCurTime;
+ (double)GetStringTimeDiff:(NSString*)timeS timeE:(NSString*)timeE;
+(void)storeCurrentTime;

+ (void)setExclusiveTouchAll:(UIView *)sender;

+ (BOOL)isBindedDevice:(NSMutableArray *)list withType:(NSString *)type;
+ (NSMutableDictionary *)jsonValue :(NSString *)str;

+ (BOOL)isVoiceAirDevice:(AirDevice *)device;

@end
