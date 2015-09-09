//
//  SegmentControl.h
//  TestSegControl
//
//  Created by gang.xu on 13-7-5.
//  Copyright (c) 2013年 去哪儿. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentControl : UIControl

@property (nonatomic, strong) UIImage *singleImage;
@property (nonatomic, strong) UIImage *singleSelectedImage;

@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *leftSelectedImage;

@property (nonatomic, strong) UIImage *middleImage;
@property (nonatomic, strong) UIImage *middleSelectedImage;

@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, strong) UIImage *rightSelectedImage;

// 初始化
- (SegmentControl *)initWithFrame:(CGRect)frameInit;

// 设置Frame
- (void)setFrame:(CGRect)frameNew;

// 设置item 标题字的颜色
- (void)setSegControlTitleButtonColor:(NSInteger)hexValue alpha:(CGFloat)alpha;
- (void)setSegControlTitleButtonSelectColor:(NSInteger)hexValue alpha:(CGFloat)alpha;

// 添加item
- (void)appendSegmentWithTitle:(NSString *)title;
- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index;

// 删除Item
- (void)removeSegmentAtIndex:(NSUInteger)index;
- (void)removeAllSegments;

// 获取选中索引
- (NSUInteger)numberOfSegments;

// 设置选中索引
- (NSInteger)selectedSegmentIndex;
- (void)setSelectedSegmentIndex:(NSInteger)index;

@end
