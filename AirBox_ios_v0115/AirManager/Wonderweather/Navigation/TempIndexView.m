//
//  TempIndexView.m
//  wonderweather
//
//  Created by 先丰 刘 on 14-6-4.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import "TempIndexView.h"

@implementation TempIndexView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _heightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hightimage.png"]];
        _heightImageView.hidden = YES;
        [self addSubview:_heightImageView];
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    
    if (self.arry == nil) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    [[UIColor colorWithHex:0xffffff alpha:1.0] set];
    CGContextSetLineWidth(context, 1.5f);
    int count = 0;
    for (NSString *yString in self.arry) {
        int y = [yString intValue];
        if (count == 0) {
            CGContextMoveToPoint(context, 32.0f, y);
            count ++;
            continue;
        }
        CGContextAddLineToPoint(context, 32 + 64 * count - 2, y);
        CGContextMoveToPoint(context, 32 + 64 * count + 2, y);
        count ++;
    }
    CGContextStrokePath(context);
    
    count = 0;
    for (NSString *yString in self.arry) {
        int y = [yString intValue];
        
        if (self.selectedCount == count) {
            _heightImageView.hidden = NO;
            _heightImageView.frame = CGRectMake(32 + 64 * count - 4, y - 4, 8, 8);
            count ++;
            continue;
        }
        
        UIBezierPath *aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(32 + 64 * count - 2, y - 2, 4, 4)];
        [[UIColor clearColor] setFill];
        CGContextSaveGState(context);
        aPath.lineWidth = 2.0;
        [aPath fill];
        [aPath stroke];
        CGContextRestoreGState(context);
        count ++;
    }

    
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
