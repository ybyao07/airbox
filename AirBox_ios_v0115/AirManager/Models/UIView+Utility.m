//
//  UIView+Utility.m
//  QunariPhone
//
//  Created by Neo on 11/12/12.
//  Copyright (c) 2012 姜琢. All rights reserved.
//

#import "UIView+Utility.h"

@implementation UIView (Utility)

// 设置UIView的X
- (void)setViewX:(CGFloat)newX
{
	CGRect viewFrame = [self frame];
	viewFrame.origin.x = newX;
	[self setFrame:viewFrame];
}

// 设置UIView的Y
- (void)setViewY:(CGFloat)newY
{
	CGRect viewFrame = [self frame];
	viewFrame.origin.y = newY;
	[self setFrame:viewFrame];
}

// 设置UIView的Origin
- (void)setViewOrigin:(CGPoint)newOrigin
{
	CGRect viewFrame = [self frame];
	viewFrame.origin = newOrigin;
	[self setFrame:viewFrame];
}

// 设置UIView的width
- (void)setViewWidth:(CGFloat)newWidth
{
	CGRect viewFrame = [self frame];
	viewFrame.size.width = newWidth;
	[self setFrame:viewFrame];
}

// 设置UIView的height
- (void)setViewHeight:(CGFloat)newHeight
{
	CGRect viewFrame = [self frame];
	viewFrame.size.height = newHeight;
	[self setFrame:viewFrame];
}

// 设置UIView的Size
- (void)setViewSize:(CGSize)newSize
{
	CGRect viewFrame = [self frame];
	viewFrame.size = newSize;
	[self setFrame:viewFrame];
}

@end
