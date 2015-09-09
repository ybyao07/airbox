//
//  CoutourView.m
//  TestLine
//
//  Created by chiery on 14/11/20.
//  Copyright (c) 2014年 None. All rights reserved.
//

#import "DDCoutourView.h"
#import "DDLineView.h"

static CGFloat const Xmargin = 20;
static CGFloat const Ymargin = 20;

@interface DDCoutourView ()

@property (nonatomic, strong) DDLineView *lineView;

@end


@implementation DDCoutourView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLineView];
        [self addXLineAndYLine];
        
         [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)configureLineView
{
    if (self.lineView) {
        [self.lineView removeFromSuperview];
        self.lineView = nil;
    }
    self.lineView = [[DDLineView alloc] initWithFrame:CGRectMake(Xmargin,
                                                               0,
                                                               CGRectGetWidth(self.bounds) - Xmargin,
                                                               CGRectGetHeight(self.bounds) - Ymargin)];

    [self addSubview:self.lineView];
}

// 添加X,Y轴
- (void)addXLineAndYLine
{
    self.lineView.layer.borderWidth = 0.7;
    self.lineView.layer.borderColor = [[UIColor colorWithRed:0.9019 green:0.9019 blue:0.9019 alpha:1] CGColor];
}

// 添加虚线
- (void)AddDottedLine
{
    
    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(Xmargin,
                                                                              0,
                                                                              CGRectGetWidth(self.bounds) - Xmargin,
                                                                              CGRectGetHeight(self.bounds) - Ymargin)];
    [self addSubview:lineImageView];
    
    
    UIGraphicsBeginImageContext(lineImageView.frame.size);   //开始画线
    [lineImageView.image drawInRect:CGRectMake(0, 0, lineImageView.frame.size.width, lineImageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    
    CGFloat lengths[] = {2,2};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1].CGColor);
    
    
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    
    // X虚线之间的距离
    CGFloat lineXWidth = (CGRectGetWidth(self.frame) - Xmargin - 2 * _xEdgeMargin )/(_XValues.count - 1);
    
    // y虚线之间的距离
    CGFloat lineYHeight = (CGRectGetHeight(self.frame) - Ymargin - 2 * _yEdgeMargin)/(_YValues.count - 1);
    
    // 添加多条虚线
    for (int i = 0; i < _XValues.count; i ++)
    {
        CGContextMoveToPoint(line, _xEdgeMargin + lineXWidth*(i), 0.0);
        CGContextAddLineToPoint(line,_xEdgeMargin + lineXWidth*(i), CGRectGetHeight(lineImageView.frame));
    }
    
    for (int i = 0; i < _YValues.count; i ++)
    {
        CGContextMoveToPoint(line, 0.0, _yEdgeMargin + lineYHeight*(i));
        CGContextAddLineToPoint(line, CGRectGetWidth(lineImageView.frame), _yEdgeMargin + lineYHeight*(i));
    }
    
    CGContextSetLineWidth(line, 0.2);
    CGContextStrokePath(line);
    
    lineImageView.image = UIGraphicsGetImageFromCurrentImageContext();
}

// 返回文字的宽度
- (CGFloat)widthWithString:(NSString *)string font:(UIFont *)font
{
    CGSize stringSize = [string sizeWithAttributes:@{
                                                     NSFontAttributeName:font
                                                     }];
    return stringSize.width;
}

// 计算文字的高度
- (CGFloat)heightWithString:(NSString *)string font:(UIFont *)font
{
    CGSize stringSize = [string sizeWithAttributes:@{
                                                     NSFontAttributeName:font
                                                     }];
    return stringSize.height;
}

#pragma mark - Public

// 添加X轴表面的刻度
- (void)setXValues:(NSArray *)XValues
{
    // 保护数据
    _XValues = XValues;
    
    // 计算每个Label最大的宽度
    CGFloat labelXWidth = (CGRectGetWidth(self.frame) - Xmargin - 2 * _xEdgeMargin )/(XValues.count - 1);
    
    for (int i = 0; i < XValues.count; i ++) {
        NSString *xValue = XValues[i];
        
        // 计算label的宽度
        CGFloat labelWidth = [self widthWithString:xValue font:[UIFont systemFontOfSize:9]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, Ymargin)];
        
        // 用文字的中心点加上文字切实的宽度会更合适
        label.center = CGPointMake((Xmargin + _xEdgeMargin) + labelXWidth * i, CGRectGetHeight(self.frame) - Ymargin/2);
        label.text = xValue;
        label.textColor = [UIColor colorWithRed:0.6862 green:0.6862 blue:0.6862 alpha:1];
        label.font = [UIFont systemFontOfSize:9];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
}

// 添加Y轴表面的刻度
- (void)setYValues:(NSArray *)YValues
{
    // 保护数据
    _YValues = YValues;
    
    CGFloat labelYHeight = (CGRectGetHeight(self.frame) - Ymargin - 2 * _yEdgeMargin)/(YValues.count - 1);
    
    for (int i = 0; i < YValues.count; i ++) {
        NSString *yValue = YValues[i];
        
        CGFloat labelHeight = [self heightWithString:yValue font:[UIFont systemFontOfSize:9]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Xmargin, labelHeight)];
        
        // 用文字的中心点加上文字切实的宽度会更合适
        label.center = CGPointMake(Xmargin/2, _yEdgeMargin + labelYHeight * i);
        
        label.text = [NSString stringWithFormat:@"%@º",yValue];
        label.textColor = [UIColor colorWithRed:0.6862 green:0.6862 blue:0.6862 alpha:1];
        label.font = [UIFont systemFontOfSize:9];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
    
    [self AddDottedLine];
}

- (void)setPointValues:(NSArray *)pointValues
{
    // 重新调整Point
    
    NSMutableArray *point = [NSMutableArray new];
    for (int i = 0; i < pointValues.count; i ++) {
        CGFloat valueXWidth = (CGRectGetWidth(self.frame) - Xmargin - 2 * _xEdgeMargin )/(_XValues.count - 1);
        
        CGFloat value = [pointValues[i] floatValue];
        
        // 该点的X轴Point
        CGFloat pointX = _xEdgeMargin + valueXWidth * i;
        // 该点的Y轴Point
        CGFloat pointY = (CGRectGetHeight(self.frame)- Ymargin - _yEdgeMargin) - ((value - [[_YValues lastObject] floatValue])/([[_YValues firstObject] floatValue] - [[_YValues lastObject] floatValue]))*(CGRectGetHeight(self.frame)-Ymargin - 2 * _yEdgeMargin);
        
        CGPoint temp = CGPointMake(pointX, pointY);
        
        [point addObject:NSStringFromCGPoint(temp)];
    }
    
    self.lineView.pointOriginValues = [pointValues copy];
    self.lineView.pointValues = [point copy];
}

- (void)setFillColors:(NSArray *)fillColors
{
    self.lineView.fillColors = fillColors;
}

- (void)setLineColor:(UIColor *)lineColor
{
    self.lineView.lineColor = lineColor;
}

- (void)setXEdgeMargin:(CGFloat)xEdgeMargin
{
    if (_xEdgeMargin != xEdgeMargin) {
        _xEdgeMargin = xEdgeMargin;
    }
}

- (void)setYEdgeMargin:(CGFloat)yEdgeMargin
{
    if (_yEdgeMargin != yEdgeMargin) {
        _yEdgeMargin = yEdgeMargin;
    }
}


@end
