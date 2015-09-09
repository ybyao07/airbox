//
//  CloPageControl.m
//  AirManager
//
//  Created by yuan jie on 14-8-27.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "CloPageControl.h"

@implementation CloPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [Utility setExclusiveTouchAll:self];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    activeImage = [UIImage imageNamed:@"pageControlNormal.png"];
    inActiveIamge = [UIImage imageNamed:@"pageControlSelect.png"];
    
    int count = [self.subviews count];
    for (int i = 0; i < count; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        [dot setFrame:CGRectMake(i*8, 0, 8, 8)];
         if([dot isKindOfClass:[UIImageView class]])
         {
            if (i == 0) {
                [dot setImage:activeImage];
            }else {
                [dot setImage:inActiveIamge];
            }
         }
         else
         {
             UIImageView  *imageView= [[UIImageView alloc] init];
             [imageView setFrame:CGRectMake(i*8, 0, 8, 8)];
             if (i == 0) {
                 [imageView setImage:activeImage];
             }else {
                 [imageView setImage:inActiveIamge];
             }
             [dot removeFromSuperview];
             [self addSubview:imageView];
         }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

- (void)updateDots{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView *dot = [self.subviews objectAtIndex:i];
        if([dot isKindOfClass:[UIImageView class]])
        {
            if (i == self.currentPage) dot.image = activeImage;
            else dot.image = inActiveIamge;
        }
        else
        {
            UIImageView  *imageView= [[UIImageView alloc] init];
             [imageView setFrame:CGRectMake(i*8, 0, 8, 8)];
            if (i == 0) {
                [imageView setImage:activeImage];
            }else {
                [imageView setImage:inActiveIamge];
            }
            [dot removeFromSuperview];
            [self addSubview:imageView];
        }
    }
}

@end