//
//  PointInHistoryView.m
//  AirManager
//

#import "PointInHistoryView.h"

@implementation PointInHistoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context,170.0/255,170.0/255,170.0/255, 1.0);
    CGContextSetRGBFillColor(context, 170.0/255,170.0/255,170.0/255, 1.0);
    CGRect pointRect;
    pointRect.size = CGSizeMake(4, 4);
    
    pointRect.origin = CGPointMake(8.0, 0);
    CGContextFillEllipseInRect(context, pointRect);
    
    pointRect.origin = CGPointMake(58.0, 0);
    CGContextFillEllipseInRect(context, pointRect);
    
    pointRect.origin = CGPointMake(108.0, 0);
	CGContextFillEllipseInRect(context, pointRect);
    
    pointRect.origin = CGPointMake(158.0, 0);
	CGContextFillEllipseInRect(context, pointRect);
    
    pointRect.origin = CGPointMake(208.0, 0);
	CGContextFillEllipseInRect(context, pointRect);
}

@end
