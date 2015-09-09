//
//  GenerateRandom.m
//  GenerateRandomData
//
//  Created by bluE on 14-9-5.
//  Copyright (c) 2014年 skyware. All rights reserved.
//

#import "GenerateRandom.h"
#define ARC4RANDOM_MAX      0x100000000
@implementation GenerateRandom
+(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

+(int)GetRandomNum:(int)seed rangOf:(int)range
{
    return (int)((seed - range) + (arc4random() % (seed +range + range+ 1)));
}
+(int)GetRandomNum:(int)seed rangeMin:(int)rangeMin rangeMax:(int)rangeMax
{
      return (int)((seed - rangeMin) + (arc4random() % (seed +rangeMin + rangeMax+ 1)));
}

+(float)randomFloatBetween:(float)num1 andLargerFloat:(float)num2
{
    int startVal = num1*10000;
    int endVal = num2*10000;
    
    int randomValue = startVal +(arc4random()%(endVal - startVal));
    float a = randomValue;
    
    return(a /10000.0);
}
@end
