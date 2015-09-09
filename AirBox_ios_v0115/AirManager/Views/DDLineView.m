//
//  LineView.m
//  TestLine
//
//  Created by chiery on 14/11/20.
//  Copyright (c) 2014年 None. All rights reserved.
//

#import "DDLineView.h"

@interface DDLineView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;       //梯度渲染层
@property (nonatomic, strong) UIImageView *tagImageView;            //标签图层

@end

@implementation DDLineView

// 变化本类的类型
+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // 添加手势交互
        self.userInteractionEnabled = YES;
        [self addGestureInCurrentView];
        
         [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    ((CAShapeLayer *)self.layer).fillColor=[UIColor clearColor].CGColor;
    ((CAShapeLayer *)self.layer).strokeColor = [UIColor clearColor].CGColor;
    ((CAShapeLayer *)self.layer).path = [self graphPathFromPoints].CGPath;
    
    [self AddLine];
}

#pragma mark - 基本的配置

// 绘制背景Layer
- (UIBezierPath *)graphPathFromPoints{
    
    BOOL fill=self.fillColors.count;
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    for (NSInteger i=0;i<self.pointValues.count;i++) {
        
        CGPoint point = CGPointFromString(self.pointValues[i]);
        
        if(i==0)
            [path moveToPoint:point];
        else
            [path addLineToPoint:point];
        
    }
    
    // 调整面部识别
    
    if (fill) {
        // 获取当前视图的高度
        CGFloat currentYHeight = CGRectGetHeight(self.frame);
        
        CGPoint last = CGPointFromString([self.pointValues lastObject]);
        CGPoint first = CGPointFromString([self.pointValues firstObject]);
        [path addLineToPoint:CGPointMake(last.x,currentYHeight)];
        [path addLineToPoint:CGPointMake(first.x,currentYHeight)];
        [path addLineToPoint:first];
    }
    
    if (fill) {
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        
        self.gradientLayer.mask = maskLayer;
    }
    
    path.lineWidth = 1;
    
    return path;
    
}

// 绘制线条
- (void)AddLine
{
    [self addDottedLine];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    [self.layer addSublayer:shapeLayer];
    
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    
    for (NSInteger i=0;i<self.pointValues.count;i++) {
        
        CGPoint point = CGPointFromString(self.pointValues[i]);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, 6, 6);
        imageView.layer.cornerRadius = imageView.frame.size.height/2;
        imageView.center = point;
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.image = [UIImage imageNamed:@"diannotselected"];
        
        imageView.tag = 10000 + i;
        
        [self addSubview:imageView];
        
        
        if(i==0)
            [path moveToPoint:point];
        else
            [path addLineToPoint:point];
        
    }
    
    path.lineWidth = 1;
    
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.strokeColor = [_lineColor CGColor];
    shapeLayer.path = path.CGPath;
}

// 添加头和尾的两条虚线
- (void)addDottedLine
{
    UIImageView *lineImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    [self addSubview:lineImageView];
    
    
    UIGraphicsBeginImageContext(lineImageView.frame.size);   //开始画线
    [lineImageView.image drawInRect:CGRectMake(0, 0, lineImageView.frame.size.width, lineImageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    
    CGFloat lengths[] = {2,2};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, _lineColor.CGColor);
    
    
    CGContextSetLineDash(line, 0, lengths, 2);  //画虚线
    
    CGPoint last = CGPointFromString([self.pointValues lastObject]);
    CGPoint first = CGPointFromString([self.pointValues firstObject]);
    
    // 添加头部的虚线
    CGContextMoveToPoint(line, 0.0, first.y);
    CGContextAddLineToPoint(line, first.x, first.y);
    
    // 添加尾部的虚线
    CGContextMoveToPoint(line, last.x, last.y);
    CGContextAddLineToPoint(line, CGRectGetWidth(self.bounds), last.y);
    
    CGContextSetLineWidth(line, 1);
    CGContextStrokePath(line);
    
    lineImageView.image = UIGraphicsGetImageFromCurrentImageContext();
}


#pragma mark - 添加手势
- (void)addGestureInCurrentView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

// 手势的处理
- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    
    BOOL tagSelcted = NO;
    NSInteger tagRadio = 0;
    
    // 判断手势之间的距离是不是在22个像素之内,显示窗口
    for (int i = 0; i < _pointValues.count; i++) {
        CGPoint temp = CGPointFromString(_pointValues[i]);
        
        CGFloat pointLenth = sqrt((pow(point.x-temp.x, 2) + (point.y - temp.y)));
        
        if (pointLenth < 15)
        {
            tagSelcted = YES;
            tagRadio = i;
            break;
        }
    }
    
    if (tagSelcted) {
        [self configureTagImageViewWithIndex:tagRadio andPoint:CGPointFromString(_pointValues[tagRadio])];
    }
    else
    {
        if (self.tagImageView) {
            [self.tagImageView removeFromSuperview];
            self.tagImageView = nil;
        }
    }
}

// 配置标签图层
- (void)configureTagImageViewWithIndex:(NSInteger)tag andPoint:(CGPoint)point
{
    if (self.tagImageView) {
        [self.tagImageView removeFromSuperview];
        self.tagImageView = nil;
        
        // 将所有的imageView的图片变换过来
        for (int i = 0; i < _pointValues.count; i++)
        {
            UIImageView *imageView = (UIImageView *)[self viewWithTag:10000 + i];
            imageView.image = [UIImage imageNamed:@"diannotselected"];
        }
    }
    
    // 将之前的image变换图片
    UIImageView *imageView = (UIImageView *)[self viewWithTag:10000 + tag];
    imageView.image = [UIImage imageNamed:@"dianselected"];
    
    UIImage *image = [UIImage imageNamed:@"biaoqian"];
    
    self.tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(point.x - image.size.width/2, point.y - image.size.height-3, image.size.width, image.size.height)];
    self.tagImageView.image = image;
    self.tagImageView.backgroundColor = [UIColor clearColor];
    
    // 添加文字
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tagImageView.frame), CGRectGetHeight(self.tagImageView.frame) - 4)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.9843 green:0.2980 blue:0.1921 alpha:1];
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"%@º",_pointOriginValues[tag]];
    label.textAlignment = NSTextAlignmentCenter;
    [self.tagImageView addSubview:label];
    [self addSubview:self.tagImageView];
}

#pragma mark - Public

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
}

- (void)setPointValues:(NSArray *)pointValues
{
    _pointValues = pointValues;
}

- (void)setPointOriginValues:(NSArray *)pointOriginValues
{
    _pointOriginValues = pointOriginValues;
}

// 设置梯度颜色
- (void)setFillColors:(NSArray *)fillColors
{
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    
    if(fillColors.count){
        
        NSMutableArray *colors=[[NSMutableArray alloc] initWithCapacity:fillColors.count];
        
        for (UIColor* color in fillColors) {
            if ([color isKindOfClass:[UIColor class]]) {
                [colors addObject:(id)[color CGColor]];
            }else{
                [colors addObject:(id)color];
            }
        }
        _fillColors=colors;
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bounds;
        self.gradientLayer.colors = _fillColors;
        [self.layer addSublayer:self.gradientLayer];
        
        
    }
    else
        _fillColors=fillColors;
    
    
    [self setNeedsDisplay];
}

@end
