//
//  CurveView.m
//  AirManager
//

#import "CurveView.h"
#import "UIDevice+Resolutions.h"
#import "AppDelegate.h"

@interface CurveView()
{
    NSMutableArray *arrLowValue;
    NSMutableArray *arrHighValue;
    
    NSNumber *lowValue;
    NSNumber *highValue;
    
    BOOL isPM;
}

@property (nonatomic,strong)NSMutableArray *arrLowValue;
@property (nonatomic,strong)NSMutableArray *arrHighValue;
@property (nonatomic,assign)BOOL isPM;

@end

@implementation CurveView

@synthesize arrLowValue;
@synthesize arrHighValue;
@synthesize isPM;

- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)array isPM:(BOOL)pm
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if(array.count > 5)
        {
            self.arrLowValue = [[NSMutableArray alloc] initWithCapacity:5];
            self.arrHighValue = [[NSMutableArray alloc] initWithCapacity:5];
            for (int i = 0; i < 5; i++)
            {
                [arrLowValue addObject:array[i*2]];
                [arrHighValue addObject:array[i*2+1]];
            }
        }
        else
        {
            arrHighValue = [[NSMutableArray alloc] initWithArray:array];
        }
        
        [array sortUsingComparator:^(NSNumber *num1,NSNumber *num2)
        {
            return [num1 compare:num2];
        }];
        lowValue = array[0];
        highValue = array.lastObject;
        self.backgroundColor = [UIColor clearColor];
        self.isPM = pm;
        
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    if(arrLowValue != nil)
    {
        [self drawInContext:UIGraphicsGetCurrentContext() withValue:arrLowValue isLowValue:YES];
    }
    
    if(arrHighValue != nil)
    {
        [self drawInContext:UIGraphicsGetCurrentContext() withValue:arrHighValue isLowValue:NO];
    }
}

- (CGFloat)yValue:(NSNumber *)num
{
    int range = [highValue intValue] - [lowValue intValue];
    
    
    if([UIDevice isRunningOn4Inch])
    {
        return (range == 0) ? 55 : (((50.0 / range) * ([highValue intValue] - [num intValue]) + 30) * 1.0);
    }
    else
    {
        return (range == 0) ? 46 : (((40.0 / range) * ([highValue intValue] - [num intValue]) + 26) * 1.0);
    }
}

- (CGSize)wordSize:(NSString *)word
{
    CGSize size = CGSizeZero;
    if([UIDevice isSystemVersionOnIos7])
    {
        size = [word sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Thonburi" size:12.0]}];
    }
    else
    {
        size = [word sizeWithFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    }
    return size;
}

/*
 
 
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [UIColorwhiteColor].CGColor);
 
 
    float lengths[] = {10,10};
    CGContextSetLineDash(context, 0, lengths,2);
    CGContextMoveToPoint(context, 10.0, 20.0);
    CGContextAddLineToPoint(context, 310.0,20.0);
    CGContextStrokePath(context);
    CGContextClosePath(context);
 
     CGContextMoveToPoint(ctx, x1, y1);
     CGContextAddLineToPoint(ctx, x2, y2);
     CGContextClosePath(ctx);
     CGContextStrokePath(ctx);
 
 */

- (void)drawLine:(CGContextRef)context start:(CGPoint)start end:(CGPoint)end value:(NSNumber *)value
{
    float lengths[] = {2,2};
    if([value intValue] == 0)
    {
        CGContextSetLineDash(context, 0, lengths, 2);
    }
    else
    {
        CGContextSetLineDash(context, 0, lengths, 0);
    }
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

- (void)drawInContext:(CGContextRef)context withValue:(NSArray *)value isLowValue:(BOOL)low
{
    //--------------------draw line
	CGContextSetRGBStrokeColor(context,170.0/255,170.0/255,170.0/255, 1.0);
    CGContextSetRGBFillColor(context, 170.0/255,170.0/255,170.0/255, 1.0);
	CGContextSetLineWidth(context, 2.0);
    
    [self drawLine:context start:CGPointMake(10.0,[self yValue:value[0]]) end:CGPointMake(60.0,[self yValue:value[1]]) value:value[0]];
    [self drawLine:context start:CGPointMake(60.0, [self yValue:value[1]]) end:CGPointMake(110.0, [self yValue:value[2]]) value:value[1]];
    [self drawLine:context start:CGPointMake(110.0, [self yValue:value[2]]) end:CGPointMake(160.0, [self yValue:value[3]]) value:value[2]];
    [self drawLine:context start:CGPointMake(160.0, [self yValue:value[3]]) end:CGPointMake(210.0, [self yValue:value[4]]) value:value[3]];

    //------------------------draw point
    CGRect rect;
    rect.size = CGSizeMake(4, 4);
    
    rect.origin = CGPointMake(8.0, [self yValue:value[0]] - 2);
    CGContextFillEllipseInRect(context, rect);
    
    rect.origin = CGPointMake(58.0, [self yValue:value[1]] - 2);
    CGContextFillEllipseInRect(context, rect);
    
    rect.origin = CGPointMake(108.0, [self yValue:value[2]] - 2);
	CGContextFillEllipseInRect(context, rect);
    
    rect.origin = CGPointMake(158.0, [self yValue:value[3]] - 2);
	CGContextFillEllipseInRect(context, rect);
    
    rect.origin = CGPointMake(208.0, [self yValue:value[4]] - 2);
	CGContextFillEllipseInRect(context, rect);
    
    //--------------------------draw text
    
	CGContextSelectFont(context, "Thonburi", 12.0, kCGEncodingMacRoman);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));

    CGFloat x1 = [self yValue:value[0]] - 25;
    CGFloat x2 = [self yValue:value[1]] - 25;
    CGFloat x3 = [self yValue:value[2]] - 25;
    CGFloat x4 = [self yValue:value[3]] - 25;
    CGFloat x5 = [self yValue:value[4]] - 25;
    
    if(low)
    {
        x1 = [self yValue:value[0]] + 10;
        x2 = [self yValue:value[1]] + 10;
        x3 = [self yValue:value[2]] + 10;
        x4 = [self yValue:value[3]] + 10;
        x5 = [self yValue:value[4]] + 10;
    }
    
    float lblX = 0;
    NSString *str = isPM ? [MainDelegate coventPM25Status:[value[0] stringValue]] : [value[0] stringValue];
    //const char *value1 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    lblX = 8 - ([self wordSize:str].width - 4) / 2;
    [str drawAtPoint:CGPointMake(lblX, x1) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    //CGContextShowTextAtPoint(context,lblX,x1,value1,strlen(value1));
    
    str = isPM ? [MainDelegate coventPM25Status:[value[1] stringValue]] : [value[1] stringValue];
    //const char *value2 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    lblX = 58 - ([self wordSize:str].width - 4) / 2;
    [str drawAtPoint:CGPointMake(lblX, x2) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    //CGContextShowTextAtPoint(context,lblX,x2,value2,strlen(value2));
    
    str = isPM ? [MainDelegate coventPM25Status:[value[2] stringValue]] : [value[2] stringValue];
    //const char *value3 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    lblX = 108 - ([self wordSize:str].width - 4) / 2;
    [str drawAtPoint:CGPointMake(lblX, x3) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    //CGContextShowTextAtPoint(context,lblX,x3,value3,strlen(value3));
    
    str = isPM ? [MainDelegate coventPM25Status:[value[3] stringValue]] : [value[3] stringValue];
    //const char *value4 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    lblX = 158 - ([self wordSize:str].width - 4) / 2;
    [str drawAtPoint:CGPointMake(lblX, x4) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    //CGContextShowTextAtPoint(context,lblX,x4,value4,strlen(value4));
    
    str = isPM ? [MainDelegate coventPM25Status:[value[4] stringValue]] : [value[4] stringValue];
    //const char *value5 = [str cStringUsingEncoding:NSUTF8StringEncoding];
    lblX = 208 - ([self wordSize:str].width - 4) / 2;
    [str drawAtPoint:CGPointMake(lblX, x5) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    //CGContextShowTextAtPoint(context,lblX,x5,value5,strlen(value5));
}




@end
