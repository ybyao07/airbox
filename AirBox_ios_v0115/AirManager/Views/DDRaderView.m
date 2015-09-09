//
//  DDRaderView.m
//  TestRadio
//
//  Created by chiery on 14/12/4.
//  Copyright (c) 2014年 qunar. All rights reserved.
//

#import "DDRaderView.h"
#import "NearAirQuality.h"
#import "AppDelegate.h"
#import "CityViewController.h"

@interface DDRaderView ()

@property (nonatomic, strong) UIImageView *radarImageView;
@property (nonatomic, strong) UILabel *startLodingLabel;

@property (nonatomic, strong) NSArray *radiusArray;
@property (nonatomic, strong) NSMutableArray *threePointsArray;
@property (nonatomic, strong) NSString *myPointString;

@property (nonatomic, strong) UIImageView *flotingImageView;
@property (nonatomic, strong) UIImageView *triangleImageView;

@end

@implementation DDRaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSelf];
    }
    return self;
}

// 视图消失的时候
- (void)removeFromSuperview
{
    [self.radarImageView removeFromSuperview];
    self.radarImageView = nil;
}

// 配置基本的信息
- (void)configureSelf
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelf:)];
    [self addGestureRecognizer:tapGesture];
    
    self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.15f];
    [self configureRadarImageView];
    [self configureRadiusArray];
}

// 配置半径
- (void)configureRadiusArray
{
    if (!self.radiusArray) {
        self.radiusArray = @[
                             @64,
                             @106,
                             @155
                             ];
    }
}

// 雷达扫描视图
- (void)configureRadarImageView
{
    if (!self.radarImageView) {
        self.radarImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.radarImageView.backgroundColor = [UIColor clearColor];
        self.radarImageView.image = [UIImage imageNamed:@"saomiao"];
        // 让图片居中，图片不被压缩
        [self.radarImageView setContentMode:UIViewContentModeCenter];
        [self addSubview:self.radarImageView];
    }
}

// 开始扫描的时候的描述label
- (void)configureStartLodingLabel
{
    if (!self.startLodingLabel) {
        
        NSString *labelText = @"搜索附近的盒子...";
        CGFloat labelWidth = [self characterWidth:labelText withFont:[UIFont systemFontOfSize:11]];
        
        self.startLodingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, 20)];
        self.startLodingLabel.center = self.radarImageView.center;
        self.startLodingLabel.textAlignment = NSTextAlignmentCenter;
        self.startLodingLabel.backgroundColor = [UIColor clearColor];
        self.startLodingLabel.textColor = [UIColor whiteColor];
        self.startLodingLabel.font = [UIFont systemFontOfSize:11];
        self.startLodingLabel.text = labelText;
    }
    [self addSubview:self.startLodingLabel];
}

// 停止扫描时消除label
- (void)removeStartLoaingLabel
{
    if (self.startLodingLabel) {
        [self.startLodingLabel removeFromSuperview];
        self.startLodingLabel = nil;
    }
}

// 扫描结束后分布点
- (void)dispatchAllPoint
{
    // 我的位置图片
    UIImage *myImage = [UIImage imageNamed:@"me"];
    UIImageView *myLocationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    myLocationImageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    myLocationImageView.image = myImage;
    [self addSubview:myLocationImageView];
    
    // 我的位置文字
    NSString *meString = @"我的位置";
    
    UILabel *meLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 [self characterWidth:meString withFont:[UIFont systemFontOfSize:9]],
                                                                 [self characterHeight:meString withFont:[UIFont systemFontOfSize:9]])];
    meLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2 + 26);
    meLabel.backgroundColor = [UIColor clearColor];
    meLabel.font = [UIFont systemFontOfSize:9];
    meLabel.textAlignment = NSTextAlignmentCenter;
    meLabel.text = @"我的位置";
    meLabel.textColor = [UIColor whiteColor];
    [self addSubview:meLabel];
    
//     _myPointString = NSStringFromCGPoint(myLocationImageView.center);
    
    // 配置下面的三个点
    [self dispatchAnotherPoints];
}

// 配置其他的三个点
- (void)dispatchAnotherPoints
{
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (int i = 0; i < self.arrNearAirBoxes.count; i++) {
        NearAirQuality *diction = self.arrNearAirBoxes[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:@"other"];
        
        // 给出一个随机的角度
        CGFloat angle = arc4random()%360;
        
        // 调整角度
        CGFloat fixedAngle = angle/360 * (M_PI * 2);
        
        if (i == self.arrNearAirBoxes.count - 1) {
            if (fixedAngle >= 3 * M_PI_4 && fixedAngle <= 5 * M_PI_4) {
                fixedAngle = 6 * M_PI_4;
            }else if (fixedAngle >= 7 * M_PI_4 && fixedAngle <= 8 * M_PI_4){
                fixedAngle = 2 * M_PI_4;
            } else if (fixedAngle >=0 && fixedAngle <= M_PI_4){
                fixedAngle = 2 * M_PI_4;
            }
        }
                
        CGFloat X = CGRectGetWidth(self.bounds)/2 + ([self.radiusArray[i] floatValue]*cos(fixedAngle));
        CGFloat Y = CGRectGetHeight(self.bounds)/2 + ([self.radiusArray[i] floatValue]*sin(fixedAngle));
        
        
        imageView.center = CGPointMake(X, Y);
        
        NSString *point = NSStringFromCGPoint(imageView.center);
        [tempArray addObject:point];

        
        [self addSubview:imageView];
        
        NSString *subTitleText = [NSString stringWithFormat:@"PM2.5 %@",diction.pm25];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   [self characterWidth:subTitleText withFont:[UIFont systemFontOfSize:9]],
                                                                   [self characterHeight:subTitleText withFont:[UIFont systemFontOfSize:9]])];
        label.center = CGPointMake(imageView.center.x,
                                   imageView.center.y + 10 + [self characterHeight:subTitleText withFont:[UIFont systemFontOfSize:9]]/2 + 8);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:9];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = subTitleText;
        [self addSubview:label];
    }
    
    self.threePointsArray = tempArray;
    
    // 随机展示一个附近盒子
    if(self.threePointsArray.count > 0)
    {
        NSInteger count = [self.threePointsArray count];
        NSInteger index = rand() % count;
        
        if(index >= 0 && index < count)
        {
            [self configureTagImageViewWithIndex:index andPoint:CGPointFromString(self.threePointsArray[index])];
        }
    }
}

#pragma mark - 点击事件
- (void)tapSelf:(UITapGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    
    BOOL tagSelcted = NO;
    NSInteger tagRadio = 0;
    
    // 判断手势之间的距离是不是在15个像素之内,显示窗口
    for (int i = 0; i < self.threePointsArray.count; i++) {
        CGPoint temp = CGPointFromString(self.threePointsArray[i]);
        
        CGFloat pointLenth = sqrt((pow(point.x-temp.x, 2) + pow(point.y - temp.y,2)));
        
        if (pointLenth < 15)
        {
            tagSelcted = YES;
            tagRadio = i;
            break;
        }
    }
    
    if (tagSelcted) {
        [self configureTagImageViewWithIndex:tagRadio andPoint:CGPointFromString(self.threePointsArray[tagRadio])];
    }
    else
    {
//        if(_myPointString)
//        {
//            CGPoint temp = CGPointFromString(self.myPointString);
//            
//            CGFloat pointLenth = sqrt((pow(point.x-temp.x, 2) + pow(point.y - temp.y,2)));
//            
//            if (pointLenth < 15 && _cityName.length > 0)
//            {
//                [self configureMyPointImageView:CGPointFromString(self.myPointString)];
//            }
//            else
//            {
//                if (self.triangleImageView) {
//                    [self.triangleImageView removeFromSuperview];
//                    self.triangleImageView = nil;
//                }
//                if (self.flotingImageView) {
//                    [self.flotingImageView removeFromSuperview];
//                    self.flotingImageView = nil;
//                }
//            }
//        }
//        else
        {
            if (self.triangleImageView) {
                [self.triangleImageView removeFromSuperview];
                self.triangleImageView = nil;
            }
            if (self.flotingImageView) {
                [self.flotingImageView removeFromSuperview];
                self.flotingImageView = nil;
            }
        }
    }
}

#pragma mark - 浮层视图的配置
- (void)configureMyPointImageView:(CGPoint)point
{
    [self configureTriangleImageView];
    
    NSInteger offset = 16;
    self.triangleImageView.center = CGPointMake(point.x, point.y - offset);
    [self addSubview:self.triangleImageView];
    
    [self configureFlotingImageView:YES];
    
    if (point.x > ((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flotingImageView.frame)/2) - 8)) {
        self.flotingImageView.center = CGPointMake(((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flotingImageView.frame)/2) - 8), point.y - CGRectGetHeight(self.flotingImageView.frame)/2 - offset - 3.5);
    } else if (point.x < (CGRectGetWidth(self.flotingImageView.frame)/2 + 8)){
        self.flotingImageView.center = CGPointMake((CGRectGetWidth(self.flotingImageView.frame)/2 + 8), point.y - CGRectGetHeight(self.flotingImageView.frame)/2 - offset - 3.5);
    } else {
        self.flotingImageView.center = CGPointMake(point.x, point.y - CGRectGetHeight(self.flotingImageView.frame)/2 -offset - 3.5);
    }
    [self addSubview:self.flotingImageView];
    [self configureMyPointSubViews:_cityName];
}


- (void)configureTagImageViewWithIndex:(NSInteger)index andPoint:(CGPoint)point
{
    [self configureTriangleImageView];
    
    self.triangleImageView.center = CGPointMake(point.x, point.y - 13);
    [self addSubview:self.triangleImageView];
    
    [self configureFlotingImageView];
    
    if (point.x > ((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flotingImageView.frame)/2) - 8)) {
        self.flotingImageView.center = CGPointMake(((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flotingImageView.frame)/2) - 8), point.y - CGRectGetHeight(self.flotingImageView.frame)/2 - 13 - 3);
    } else if (point.x < (CGRectGetWidth(self.flotingImageView.frame)/2 + 8)){
        self.flotingImageView.center = CGPointMake((CGRectGetWidth(self.flotingImageView.frame)/2 + 8), point.y - CGRectGetHeight(self.flotingImageView.frame)/2 - 13 - 3);
    } else {
        self.flotingImageView.center = CGPointMake(point.x, point.y - CGRectGetHeight(self.flotingImageView.frame)/2 -13 - 3);
    }
    [self addSubview:self.flotingImageView];
    [self configureSubViews:self.arrNearAirBoxes[index]];
}

- (void)configureTriangleImageView
{
    if (!self.triangleImageView) {
        self.triangleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8.5, 7)];
        self.triangleImageView.backgroundColor = [UIColor clearColor];
        self.triangleImageView.image = [UIImage imageNamed:@"fukuang-1"];
    }
}

- (void)configureFlotingImageView
{
    [self configureFlotingImageView:NO];
}

- (void)configureFlotingImageView:(BOOL)isMyPoint
{
    if (!self.flotingImageView) {
        self.flotingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 188, 123)];
        self.flotingImageView.backgroundColor = [UIColor clearColor];
        self.flotingImageView.image = [UIImage imageNamed:@"fukuang"];
    }
    if(isMyPoint)
    {
        CGSize size = [self characterSize:_cityName withFont:[UIFont systemFontOfSize:15]];
        if(size.width < 80)
        {
            size.width = 80;
        }
        if(size.height < 30)
        {
            size.height = 30;
        }
        self.flotingImageView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    else
    {
        self.flotingImageView.frame = CGRectMake(0, 0, 188, 123);
    }
}
- (void)configureMyPointSubViews:(NSString *)loctionStr
{
    for(UIView *view in self.flotingImageView.subviews)
    {
        [view removeFromSuperview];
    }
    
    
    CGSize size = [loctionStr sizeWithFont:[UIFont systemFontOfSize:15]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.flotingImageView.frame) - size.width) / 2,
                                                                    (CGRectGetHeight(self.flotingImageView.frame) - size.height) / 2,
                                                                    size.width,
                                                                    size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithHex:0x000000 alpha:1.0f];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = loctionStr;
    [self.flotingImageView addSubview:titleLabel];
    
    
}
- (void)configureSubViews:(NearAirQuality *)dict
{
    for(UIView *view in self.flotingImageView.subviews)
    {
        [view removeFromSuperview];
    }
    CGFloat xStart = 10;
    CGFloat yStart = 20;
    
    // icon
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xStart, yStart, 52, 52)];
    iconImageView.backgroundColor = [UIColor clearColor];
    iconImageView.image = [UIImage imageNamed:@"mood_icon_100.png"];
    
    int moodTag = [MainDelegate moodValueConvert:[dict.mark intValue]];
    NSString *name = [NSString stringWithFormat:@"mood_icon_%d.png",moodTag];
    DDLogCVerbose(@"info.mark  %@  moodtag  %d    name %@",dict.mark,moodTag,name);
    if(dict.mark && dict.mark.length > 0)
    {
        iconImageView.image = [UIImage imageNamed:name];
    }
    
    [self.flotingImageView addSubview:iconImageView];
    
    // 调整X
    xStart = xStart + 52 + 17;
    // title
    
    NSString *titleString =[CityViewController getCityNameByID:dict.city];

    if (!titleString)
    {
        titleString = @"--";
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xStart,
                                                                    yStart,
                                                                    CGRectGetWidth(self.flotingImageView.frame) - xStart - 10,
                                                                    [self characterHeight:titleString withFont:[UIFont systemFontOfSize:15]])];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorWithHex:0x000000 alpha:1.0f];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = titleString;
    [self.flotingImageView addSubview:titleLabel];
    
    // 调整Y
    yStart = yStart + [self characterHeight:titleString withFont:[UIFont systemFontOfSize:15]] + 12;
    
    NSString *pollutionString = dict.pm25;
    
    // 污染指数
    UILabel *pollutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(xStart,
                                                                        yStart - 4,
                                                                        [self characterWidth:pollutionString withFont:[UIFont systemFontOfSize:23]],
                                                                        [self characterHeight:pollutionString withFont:[UIFont systemFontOfSize:23]])];
    pollutionLabel.backgroundColor = [UIColor clearColor];
    pollutionLabel.textColor = [UIColor colorWithHex:0xff5e26 alpha:1.0f];
    pollutionLabel.font = [UIFont systemFontOfSize:23];
    pollutionLabel.text = pollutionString;
    [self.flotingImageView addSubview:pollutionLabel];
    
    // 调整X
    xStart = xStart + [self characterWidth:pollutionString withFont:[UIFont systemFontOfSize:21]] + 7;
    
    NSString *labelString1 = @"PM2.5";
    NSString *labelString2 = [Utility getPM25StatusString:dict.pm25]; // 污染严重
    for (int i = 0; i < 2; i ++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xStart,
                                                                   yStart + i * [self characterHeight:labelString1 withFont:[UIFont systemFontOfSize:8] ] + 3 * i,
                                                                   [self characterWidth:i==0?labelString1:labelString2 withFont:[UIFont systemFontOfSize:8]],
                                                                   [self characterHeight:i==0?labelString1:labelString2 withFont:[UIFont systemFontOfSize:8]])];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHex:0x000000 alpha:0.5f];
        label.font = [UIFont systemFontOfSize:8];
        label.text = i==0?labelString1:labelString2;
        [self.flotingImageView addSubview:label];
    }
    
    // 调整X,Y
    xStart = 0;
    yStart = CGRectGetHeight(self.flotingImageView.frame) - 40;
    
    // 添加分割线
    UIImageView *lineImageViewH = [[UIImageView alloc] initWithFrame:CGRectMake(xStart,
                                                                                yStart,
                                                                                CGRectGetWidth(self.flotingImageView.frame),
                                                                                0.5)];
    lineImageViewH.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.2f];
    [self.flotingImageView addSubview:lineImageViewH];
    
    // 调整Y
    yStart = yStart + 0.5;
    
    NSArray *tempArray = @[
                           @{
                               @"buttonName":@"温度",
                               @"value":dict.temperature
                               },
                           @{
                               @"buttonName":@"湿度",
                               @"value":dict.humidity
                               }
                           ];
    
    CGFloat marginX = CGRectGetWidth(self.flotingImageView.frame)/2;
    
    for (int i = 0; i < tempArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15 + i * marginX,
                                                                   yStart,
                                                                   [self characterWidth:tempArray[i][@"buttonName"] withFont:[UIFont systemFontOfSize:12]],
                                                                   39.5)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithHex:0x000000 alpha:0.5f];
        label.font = [UIFont systemFontOfSize:12];
        label.text = tempArray[i][@"buttonName"];
        [self.flotingImageView addSubview:label];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX * (i+1) - 12 - [self characterWidth:tempArray[i][@"value"] withFont:[UIFont systemFontOfSize:12]],
                                                                        yStart,
                                                                        [self characterWidth:tempArray[i][@"value"] withFont:[UIFont systemFontOfSize:12]],
                                                                        39.5)];
        valueLabel.backgroundColor = [UIColor clearColor];
        valueLabel.textColor = [UIColor blackColor];
        valueLabel.font = [UIFont systemFontOfSize:12];
        valueLabel.text = tempArray[i][@"value"];
        [self.flotingImageView addSubview:valueLabel];
    }
    
    // // 添加分割线
    UIImageView *lineImageViewV = [[UIImageView alloc] initWithFrame:CGRectMake(marginX - 0.25,
                                                                                yStart + 5,
                                                                                0.5,
                                                                                30)];
    lineImageViewV.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.2f];
    [self.flotingImageView addSubview:lineImageViewV];
}

#pragma mark - 辅助函数

- (CGSize)characterSize:(NSString *)string withFont:(UIFont *)font
{
    CGSize size = [string sizeWithAttributes:@{
                                               NSFontAttributeName:font
                                               }];
    return CGSizeMake(size.width + 16, size.height + 8);
}
// 文字的高度
- (CGFloat)characterHeight:(NSString *)string withFont:(UIFont *)font
{
    CGSize size = [string sizeWithAttributes:@{
                                               NSFontAttributeName:font
                                               }];
    return size.height;
}

// 文字的宽度
- (CGFloat)characterWidth:(NSString *)string withFont:(UIFont *)font
{
    CGSize size = [string sizeWithAttributes:@{
                                               NSFontAttributeName:font
                                               }];
    return size.width;
}

#pragma mark - Public
- (void)start
{
    // 开始前清除所有的已有图片
    [self removeFromSuperview];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    // 配置扫描图片
    [self configureRadarImageView];
    
    [self.radarImageView setImage:[UIImage imageNamed:@"saomiao"]];
    
    // 加上描述文案
    [self configureStartLodingLabel];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = @(2 * M_PI);
    rotationAnimation.speed = self.rotationSpeed;
    rotationAnimation.duration = 1.0;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.radarImageView.layer addAnimation:rotationAnimation forKey:@"radarAnimation"];
}

- (void)stop
{
    [self.radarImageView.layer removeAnimationForKey:@"radarAnimation"];
    [self.radarImageView setImage:[UIImage imageNamed:@"quanquan"]];
    
    [self removeStartLoaingLabel];
    [self dispatchAllPoint];
}

- (void)reset{
    [self.radarImageView.layer removeAnimationForKey:@"radarAnimation"];
    
    // 开始前清除所有的已有图片
    [self removeFromSuperview];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    // 配置扫描图片
    [self configureRadarImageView];
    
    [self.radarImageView setImage:[UIImage imageNamed:@"saomiao"]];
    
    // 加上描述文案
    [self configureStartLodingLabel];
}

- (void)resetRadarImageViewImage:(UIImage *)image
{
    if (self.radarImageView) {
        self.radarImageView.image = image;
    }
}

@end
