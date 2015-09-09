//
//  CoutourView.h
//  TestLine
//
//  Created by chiery on 14/11/20.
//  Copyright (c) 2014年 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDCoutourView : UIView

@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) NSArray *XValues;
@property (nonatomic, strong) NSArray *YValues;


@property (nonatomic, strong) NSArray *pointValues;
@property (nonatomic, strong) NSArray *fillColors;

// 设置与左右边框的边距
@property (nonatomic, assign) CGFloat xEdgeMargin;

// 设置与上下边框的边距
@property (nonatomic, assign) CGFloat yEdgeMargin;

@end
