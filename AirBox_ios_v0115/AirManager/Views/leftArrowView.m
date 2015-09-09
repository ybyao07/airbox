//
//  leftArrowView.m
//  AirManager
//
//  Created by qitmac000242 on 14-12-8.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "leftArrowView.h"

@interface leftArrowView ()

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@end

@implementation leftArrowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSelf];
    }
    return self;
}



// 配置基本的信息
- (void)configureSelf
{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x, 0, 1, self.frame.size.height / 2)];
    
    _topView.layer.anchorPoint = CGPointMake(self.center.x , self.center.y);
    _topView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_topView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(self.center.x, self.frame.size.height / 2, 1, self.frame.size.height / 2)];
    _bottomView.layer.anchorPoint = CGPointMake(self.center.x , self.center.y);
    _bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bottomView];
    
    
}


@end
