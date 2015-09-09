//
//  ImageSetting.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-7-1.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "ImageSetting.h"

@implementation ImageSetting

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (NSData *)settingScreenImage:(UIViewController *)vc
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 960), YES, 0);
    [vc.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect =CGRectMake(0, ADDHEIGH * 2, 320 * 2, VIEWHEIGHT * 2);//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    NSData *imageViewData = UIImagePNGRepresentation(sendImage);
    CGImageRelease(imageRefRect);
    
    return imageViewData;
}

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2{
    
    if (image1 == nil || image2 == nil) {
        return nil;
    }
    UIGraphicsBeginImageContext(image2.size);
    
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    [image1 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
