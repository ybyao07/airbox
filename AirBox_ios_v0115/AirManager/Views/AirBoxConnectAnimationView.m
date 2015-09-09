//
//  AirBoxConnectAnimationView.m
//  AirManager
//

#import "AirBoxConnectAnimationView.h"

static const NSUInteger dotNumber = 6;
static const CGFloat dotSeparatorDistance = 8.0f;

@interface AirBoxConnectAnimationView()
{
    NSMutableArray *arrDot;
    CGSize dotSize;
    BOOL animating;
}

@property (nonatomic,strong) NSMutableArray *arrDot;

@end

@implementation AirBoxConnectAnimationView

@synthesize arrDot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)prepareConnect
{
    self.arrDot = [[NSMutableArray alloc] initWithCapacity:6];
    dotSize = CGSizeMake(6, 6);
    CGFloat xPos = 0;
    CGFloat yPos = CGRectGetHeight(self.frame) / 2 - dotSize.height / 2;
    
    for (int i = 0; i < dotNumber; i++)
    {
        CAShapeLayer *dot = [CAShapeLayer new];
        dot.path = [self createDotPath].CGPath;
        dot.frame = CGRectMake(xPos, yPos, dotSize.width, dotSize.height);
        dot.opacity = 0.3 * i;
        dot.fillColor = [UIColor colorWithRed:157.0/255 green:211.0/255 blue:158.0/255 alpha:1.0].CGColor;
        [self.layer addSublayer:dot];
        [arrDot addObject:dot];
        xPos = xPos + (dotSeparatorDistance + dotSize.width);
    }
}

- (UIBezierPath *)createDotPath
{
    CGFloat cornerRadius = dotSize.width / 2;
    CGRect rect = CGRectMake(0, 0, dotSize.width, dotSize.height);
    return [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
}

- (CAAnimation *)fadeInAnimation:(CFTimeInterval)delay
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.2f);
    animation.toValue = @(1.0f);
    animation.duration = 0.6;
    animation.beginTime = delay;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VAL;
    return animation;
}

- (void)startAnimating
{
    if (animating)
    {
        return;
    }
    
    for (int i = 0; i < arrDot.count; i++)
    {
        [arrDot[i] addAnimation:[self fadeInAnimation:i * 0.1 + 0.1] forKey:@"fadeIn"];
    }
    
    animating = YES;
}

- (void)stopAnimating
{
    if (!animating)
    {
        return;
    }
    
    for (int i = 0; i < arrDot.count; i++)
    {
        [arrDot[i] removeAnimationForKey:@"fadeIn"];
    }
    
    animating = NO;
}

- (BOOL)isAnimating
{
    return animating;
}

- (void)removeFromSuperview
{
    [self stopAnimating];
    
    [super removeFromSuperview];
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
