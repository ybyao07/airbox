//
//  GenerateRandom.h
//  GenerateRandomData
//
//  Created by bluE on 14-9-5.
//  Copyright (c) 2014年 skyware. All rights reserved.
//
/**
 **产生随机整数和随机浮点数
 */
#import <Foundation/Foundation.h>

@interface GenerateRandom : NSObject
+(int)getRandomNumber:(int)from to:(int)to;
//在[seed - range, seed +range]产生随机数
+(int)GetRandomNum:(int)seed rangOf:(int)range;
//在[seed -rangeMin, seed +rangeMax]产生随机数
+(int)GetRandomNum:(int)seed rangeMin:(int)rangeMin rangeMax:(int)rangeMax;

+(float)randomFloatBetween:(float)num1 andLargerFloat:(float)num2;


@end
