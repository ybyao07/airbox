//
//  NewCurveView.m
//  AirManager
//

#import "NewCurveView.h"
#import "UIDevice+Resolutions.h"
#import "AppDelegate.h"

@interface NewCurveView()
{
    NSMutableArray *arrLowValue;
    NSMutableArray *arrHighValue;
    
    NSNumber *lowValue;
    NSNumber *highValue;
    
    BOOL isPM;
    BOOL isDay;
    CurveType curveType;
}

@property (nonatomic,strong)NSMutableArray *arrLowValue;
@property (nonatomic,strong)NSMutableArray *arrHighValue;

@end

@implementation NewCurveView

@synthesize arrLowValue;
@synthesize arrHighValue;

- (id)initWithFrame:(CGRect)frame andData:(NSMutableArray *)array isPM:(BOOL)pm curveType:(CurveType)type isDay:(BOOL)day
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if(type == kTemp && day)
        {
            NSMutableArray *lowArr = [[NSMutableArray alloc] init];
            self.arrLowValue = lowArr;
            NSMutableArray *highArr = [[NSMutableArray alloc] init];
            self.arrHighValue = highArr;
            for (int i = 0; i < array.count / 2; i++)
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
        isPM = pm;
        isDay = day;
        curveType = type;
        
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
    // have pm
    /*
     if([UIDevice isRunningOn4Inch])
     {
     return (range == 0) ? 50 : (((55.0 / range) * ([highValue intValue] - [num intValue]) + 22) * 1.0);
     }
     else
     {
     return (range == 0) ? 41 : (((42.0 / range) * ([highValue intValue] - [num intValue]) + 20) * 1.0);
     }
     */
    // no pm
    if([UIDevice isRunningOn4Inch])
    {
        return (range == 0) ? 66 : (((48.0 / range) * ([highValue intValue] - [num intValue]) + 20) * 1.0) ;
    }
    else
    {
        return (range == 0) ? 66 : (((48.0 / range) * ([highValue intValue] - [num intValue]) + 20) * 1.0);
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

- (void)drawLine:(CGContextRef)context start:(CGPoint)start end:(CGPoint)end value:(NSNumber *)value
{
    //    float lengths[] = {2,2};
    float lengths[] = {5,1};//ybyao07
    //ybyao07值为0时虚线
    if([value intValue] == 0)
    {
        CGContextSetLineDash(context, 0, lengths, 1);
    }
    else
    {
        CGContextSetLineDash(context, 0, lengths, 0);
    }
    //    CGContextMoveToPoint(context, start.x+6, start.y+2);
    //    CGContextAddLineToPoint(context, end.x-2, end.y+2);
    CGContextMoveToPoint(context, start.x, start.y);
    CGContextAddLineToPoint(context, end.x, end.y);
    CGContextStrokePath(context);
    CGContextClosePath(context);
}

//added by ybyao07
-(float)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end
{
    float distance;
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

- (void)drawInContext:(CGContextRef)context withValue:(NSArray *)value isLowValue:(BOOL)low
{
    float tag =72.0;
        if (isDay) {
            tag = 44.0;
        } else {
            tag = 72.0;
        }

    //--------------------draw line
    switch (curveType) {
        case kExponent:
        {
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context,1.0, 1.0, 1.0, 1.0);
        }
            break;
        case kTemp:
        {
            if(low)
            {
                CGContextSetRGBStrokeColor(context,1.0, 1.0, 1.0, 1.0);
                CGContextSetRGBFillColor(context,1.0, 1.0, 1.0, 1.0);
            }
            else
            {
                if(isDay)
                {
                    CGContextSetRGBStrokeColor(context,255.0/255,145.0/255,0.0/255, 1.0);
                    CGContextSetRGBFillColor(context, 255.0/255,145.0/255,0.0/255, 1.0);
                }
                else
                {
                    CGContextSetRGBStrokeColor(context,1.0, 1.0, 1.0, 1.0);
                    CGContextSetRGBFillColor(context,1.0, 1.0, 1.0, 1.0);
                }
            }
            
        }
            break;
        case kHum:
        {
            CGContextSetRGBStrokeColor(context,1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context,1.0, 1.0, 1.0, 1.0);
        }
            break;
        case kPM25:
        {
            //ybyao07
            CGContextSetRGBStrokeColor(context,1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context,1.0, 1.0, 1.0, 1.0);
            //            CGContextSetRGBStrokeColor(context,185.0/255,181.0/255,177.0/255, 1.0);
            //            CGContextSetRGBFillColor(context, 185.0/255,181.0/255,177.0/255, 1.0);
        }
            break;
            
        default:
            break;
    }
    
    CGContextSetLineWidth(context, 1.0);
    
    for (int i = 0; i < value.count - 1; i++)
    {
        //        CGPoint startPoint = CGPointMake(10.0 + 72 * i, [self yValue:value[i]]);
        //        CGPoint endPoint = CGPointMake(10.0 + 72 * (i + 1), [self yValue:value[i + 1]]);
        CGPoint startPoint1 = CGPointMake(10.0 + tag * i, [self yValue:value[i]]);
        CGPoint endPoint1 = CGPointMake(10.0 + tag * (i + 1), [self yValue:value[i + 1]]);
        float x1 = startPoint1.x + 4.0*(endPoint1.x-startPoint1.x)/[self distanceFromPointX:startPoint1 distanceToPointY:endPoint1];
        float y1 = startPoint1.y + 3.0*(endPoint1.y-startPoint1.y)/[self distanceFromPointX:startPoint1 distanceToPointY:endPoint1];
        
        float x2 = endPoint1.x -2.0*(endPoint1.x-startPoint1.x)/[self distanceFromPointX:startPoint1 distanceToPointY:endPoint1];
        float y2 = endPoint1.y - 4.0*(endPoint1.y-startPoint1.y)/[self distanceFromPointX:startPoint1 distanceToPointY:endPoint1];
        //应该以圆心做为绘制的焦点
        CGPoint startPoint = CGPointMake(x1, y1);
        CGPoint endPoint = CGPointMake(x2, y2);
        [self drawLine:context start:startPoint end:endPoint value:value[i]];
    }
    
    //------------------------draw point
    
    switch (curveType) {
        case kExponent:
        {
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        }
            break;
        case kTemp:
        {
            if(low)
            {
                CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
                CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
            }
            else
            {
                if(isDay)
                {
                    CGContextSetRGBStrokeColor(context,255.0/255,145.0/255,34.0/255, 1.0);
                    CGContextSetRGBFillColor(context, 255.0/255,145.0/255,34.0/255, 1.0);
                }
                else
                {
                    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
                    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                }
            }
        }
            break;
        case kHum:
        {
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        }
            break;
        case kPM25:
        {
            CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
            CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        }
            break;
            
        default:
            break;
    }
    
    CGRect rect;
    rect.size = CGSizeMake(8, 8);
    
    for (int i = 0; i < value.count; i++)
    {
        //ybyao07
        //        rect.origin = CGPointMake(7.5 + 72 * i, [self yValue:value[i]] - 2.5);
        rect.origin = CGPointMake(7.0 + tag * i, [self yValue:value[i]] - 4.0);
        //        CGContextFillEllipseInRect(context, rect);//ybyao07
        // TreeJohn 用图片吧 ybyao07
        UIImageView *circle = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"yuan"]];
        circle.frame = rect;
        [self addSubview:circle];
    }
    
    //--------------------------draw text
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    
    CGContextSelectFont(context, "Thonburi", 12.0, kCGEncodingMacRoman);
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    for (int i = 0; i < value.count; i++)
    {
        float x = low ? ([self yValue:value[i]] + 3) : ([self yValue:value[i]] - 20);
        NSString *str = [value[i] stringValue];
        float strX = (10 + i * tag) - ([self wordSize:str].width - 4) / 2-1;
        [str drawAtPoint:CGPointMake(strX, x) withFont:[UIFont fontWithName:@"Thonburi" size:12.0]];
    }
}




@end
