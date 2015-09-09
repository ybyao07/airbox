//
//  CitySelectedProtocol.h
//  wonderweather
//
//  Created by zhongke on 14-5-28.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentCity.h"
@protocol CitySelectedProtocol <NSObject>
- (void)citySelected:(CurrentCity *)city;
@end
