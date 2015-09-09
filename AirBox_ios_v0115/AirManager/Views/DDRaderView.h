//
//  DDRaderView.h
//  TestRadio
//
//  Created by chiery on 14/12/4.
//  Copyright (c) 2014年 qunar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDRaderView : UIView

// 旋转的速度
@property (nonatomic, assign) CGFloat rotationSpeed;


// 子标题展示
@property (nonatomic, strong) NSArray *arrNearAirBoxes;

@property (nonatomic, strong) NSString *cityName;

// 开始动画
- (void)start;

// 停止动画
- (void)stop;

// 重置动画状态
- (void)reset;

// 更改floatingImageView的图片
- (void)resetRadarImageViewImage:(UIImage *)image;

@end
