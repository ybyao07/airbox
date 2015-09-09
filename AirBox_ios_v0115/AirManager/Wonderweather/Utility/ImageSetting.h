//
//  ImageSetting.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-7-1.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSetting : NSObject

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+ (NSData *)settingScreenImage:(UIViewController *)vc;
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;

@end
