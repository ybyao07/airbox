//
//  SegmentControl.m
//  TestSegControl
//
//  Created by gang.xu on 13-7-5.
//  Copyright (c) 2013年 去哪儿. All rights reserved.
//


#import "SegmentControl.h"
#import "SegmentButton.h"

// ==================================================================
// 布局参数
// ==================================================================
// 字体
#define kSegControlTitleButtonFont			kCurNormalFontOfSize(14)

// 默认颜色
#define kSegControlTitleButtonColor			[UIColor whiteColor]
#define kSegControlTitleButtonSelectColor	[UIColor colorWithHex:0x3b3b3b alpha:1.0]

@interface SegmentControl ()

@property (nonatomic, strong) NSMutableArray *arraySegment;		// 选项
@property (nonatomic, assign) NSInteger selectedIndex;			// 当前选中项
@property (nonatomic, strong) UIColor* titleColor; //默认标题颜色
@property (nonatomic, strong) UIColor* titleSelectColor; //选中标题颜色


// 调整Segment
- (void)reLayout;

// 按钮选择事件
- (void)buttonSelected:(id)sender;

@end

// ==================================================================
// 实现
// ==================================================================
@implementation SegmentControl

// 初始化
- (SegmentControl *)initWithFrame:(CGRect)frameInit
{
	if((self = [super initWithFrame:frameInit]) != nil)
	{
		_selectedIndex = -1;
		// 设置Item数组
		_arraySegment = [[NSMutableArray alloc] initWithCapacity:0];
        
        _titleColor = kSegControlTitleButtonColor;
        _titleSelectColor = kSegControlTitleButtonSelectColor;
        
        [Utility setExclusiveTouchAll:self];
		
		return self;
	}
    
	return nil;
}

// 设置Frame
- (void)setFrame:(CGRect)frameNew
{
	[super setFrame:frameNew];
	
	// 刷新
	[self reLayout];
}

- (void)setSegControlTitleButtonColor:(NSInteger)hexValue alpha:(CGFloat)alpha{
    _titleColor = [UIColor colorWithHex:hexValue alpha:alpha];
    // 刷新
    [self reLayout];
    
}

- (void)setSegControlTitleButtonSelectColor:(NSInteger)hexValue alpha:(CGFloat)alpha{
    _titleSelectColor = [UIColor colorWithHex:hexValue alpha:alpha];
    // 刷新
    [self reLayout];
}

// 添加item
- (void)appendSegmentWithTitle:(NSString *)title
{
	NSUInteger segmentCount = [_arraySegment count];
	[self insertSegmentWithTitle:title atIndex:segmentCount];
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)index
{
	// 获取Segment的数目
	NSUInteger segmentCount = [_arraySegment count];
	if(index <= segmentCount)
	{
		// 创建新的Button
		SegmentButton *button = [SegmentButton buttonWithType:UIButtonTypeCustom];
		[[button titleLabel] setFont:kSegControlTitleButtonFont];
		[button setTitle:title forState:UIControlStateNormal];
		[button setTitleColor:_titleColor forState:UIControlStateNormal];
		[button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchDown];
		
		// 保存
		[_arraySegment addObject:button];
		[self addSubview:button];
		
		// 调整
		[self reLayout];
	}
}

// 删除Item
- (void)removeSegmentAtIndex:(NSUInteger)index
{
	NSInteger segmentCount = [_arraySegment count];
	if(index < segmentCount)
	{
		UIButton *button = [_arraySegment objectAtIndex:index];
		[button removeFromSuperview];
		[_arraySegment removeObjectAtIndex:index];
		
		// 设置新的选中项
		NSInteger segmentCountNew = [_arraySegment count];
		if(_selectedIndex >= segmentCountNew)
		{
			_selectedIndex = -1;
		}
		
		// 调整
		[self reLayout];
	}
}

- (void)removeAllSegments
{
	NSInteger segmentCount = [_arraySegment count];
	for(NSInteger i = 0; i < segmentCount; i++)
	{
		UIButton *button = [_arraySegment objectAtIndex:i];
		[button removeFromSuperview];
	}
	
	[_arraySegment removeAllObjects];
	_selectedIndex = -1;
}

// 设置文本
- (NSString *)titleForSegmentAtIndex:(NSUInteger)index
{
	NSInteger segmentCount = [_arraySegment count];
	if(index < segmentCount)
	{
		UIButton *button = [_arraySegment objectAtIndex:index];
		return [[button titleLabel] text];
	}
	
	return nil;
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)index
{
	NSInteger segmentCount = [_arraySegment count];
	if(index < segmentCount)
	{
		UIButton *button = [_arraySegment objectAtIndex:index];
		[button setTitle:title forState:UIControlStateNormal];
	}
}

// 获取选中索引
- (NSUInteger)numberOfSegments
{
	return [_arraySegment count];
}

// 设置选中索引
- (NSInteger)selectedSegmentIndex
{
	return _selectedIndex;
}

- (void)setSelectedSegmentIndex:(NSInteger)index
{
	if(index != _selectedIndex)
	{
		NSInteger segmentCount = [_arraySegment count];
		if(index < segmentCount)
		{
			_selectedIndex = index;
			
			// 刷新
			[self reLayout];
		}
	}
}

// 调整Segment的Frame
- (void)reLayout
{
	// 父窗口属性
	CGRect parentFrame = [self frame];
	
	// 游标
	NSInteger spaceX = 0;
	
	// 遍历
	NSInteger segmentCount = [_arraySegment count];
	if(segmentCount != 0)
	{
		NSInteger segmentWidth = parentFrame.size.width / segmentCount;
		for(NSInteger i = 0; i < segmentCount; i++)
		{
			SegmentButton *button = [_arraySegment objectAtIndex:i];
			
			if(i != (segmentCount - 1))
			{
				[button setFrame:CGRectMake(spaceX, 0, segmentWidth, parentFrame.size.height)];
				spaceX += [button frame].size.width;
			}
			else
			{
				[button setFrame:CGRectMake(spaceX, 0, parentFrame.size.width - spaceX, parentFrame.size.height)];
			}
			
			// 当前选中项
			if(i == _selectedIndex)
			{
                [button setTitleColor:_titleSelectColor forState:UIControlStateNormal];
				// 只有一个Segment
				if(segmentCount == 1)
				{
					[button setBackgroundImage:_singleSelectedImage forState:UIControlStateNormal];
					[button setBackgroundImage:_singleSelectedImage forState:UIControlStateHighlighted];
				}
				// 多个Segment
				else if(segmentCount >= 2)
				{
					if(i == 0)
					{
						[button setBackgroundImage:_leftSelectedImage forState:UIControlStateNormal];
						[button setBackgroundImage:_leftSelectedImage forState:UIControlStateHighlighted];
                        
					}
					else if(i == (segmentCount - 1))
					{
						[button setBackgroundImage:_rightSelectedImage forState:UIControlStateNormal];
						[button setBackgroundImage:_rightSelectedImage forState:UIControlStateHighlighted];
					}
					else
					{
						[button setBackgroundImage:_middleSelectedImage forState:UIControlStateNormal];
						[button setBackgroundImage:_middleSelectedImage forState:UIControlStateHighlighted];
					}
				}
			}
			else
			{
                
                [button setTitleColor:_titleColor forState:UIControlStateNormal];
				// 只有一个Segment
				if(segmentCount == 1)
				{
					[button setBackgroundImage:_singleImage forState:UIControlStateNormal];
					[button setBackgroundImage:_singleImage forState:UIControlStateHighlighted];
				}
				// 多个Segment
				else if(segmentCount >= 2)
				{
					if(i == 0)
					{
						[button setBackgroundImage:_leftImage forState:UIControlStateNormal];
						[button setBackgroundImage:_leftImage forState:UIControlStateHighlighted];
					}
					else if(i == (segmentCount - 1))
					{
						[button setBackgroundImage:_rightImage forState:UIControlStateNormal];
						[button setBackgroundImage:_rightImage forState:UIControlStateHighlighted];
					}
					else
					{
						[button setBackgroundImage:_middleImage forState:UIControlStateNormal];
						[button setBackgroundImage:_middleImage forState:UIControlStateHighlighted];
					}
				}
			}
		}
	}
}

// Segment选中
- (void)buttonSelected:(id)sender
{
	UIButton *buttonItem = (UIButton *)sender;
	
	// 查找按钮
	NSInteger segmentCount = [_arraySegment count];
	for(NSInteger i = 0; i < segmentCount; i++)
	{
		UIButton *button = [_arraySegment objectAtIndex:i];
		if(buttonItem == button)
		{
			if(i != _selectedIndex)
			{
				// 设置新的选中索引值
				[self setSelectedSegmentIndex:i];
				
				// 传递消息
				[self sendActionsForControlEvents:UIControlEventValueChanged];
			}
			
			break;
		}
	}
}

@end
