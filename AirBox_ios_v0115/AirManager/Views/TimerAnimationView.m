//
//  TimerAnimationView.m
//

#import "TimerAnimationView.h"

#define kTimerAnimation     @"TimerRotationAnimation"

@interface TimerAnimationView()
{
    UIImageView     *_timerImageView;
}

@end

@implementation TimerAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addImageSubViews];
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)addImageSubViews
{
    CGRect rect = self.frame;
    rect.origin = CGPointMake(0, 0);
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:rect];
    bg.image = [UIImage imageNamed:@"ic_timer_bg.png"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:bg];
    });
    
    _timerImageView = [[UIImageView alloc] initWithFrame:rect];
    _timerImageView.image = [UIImage imageNamed:@"ic_timer_pointer.png"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:_timerImageView];
    });
}

- (void)startAnimating
{
   
    
    if (self.isAnimating)
    {
        CAAnimation *ani = [_timerImageView.layer animationForKey:kTimerAnimation];
        
        if (ani) return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    animation.duration = 10.0;
    animation.repeatCount = HUGE_VALF;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_timerImageView.layer addAnimation:animation forKey:kTimerAnimation];
    });
    
    self.isAnimating = YES;
}

- (void)stopAnimating
{
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_timerImageView.layer removeAllAnimations];
    });
    
    self.isAnimating = NO;
}


@end
