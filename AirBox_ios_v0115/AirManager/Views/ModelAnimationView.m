//
//  ModelAnimationView.m
//  AirManager
//

#import "ModelAnimationView.h"

@interface ModelAnimationView ()
{
    IBOutlet UIImageView *bgImageView;
    IBOutlet UIImageView *modelImageView;
}

@end

@implementation ModelAnimationView

@synthesize actionBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#define kModelAnimation     @"ModelRotationAnimation"

- (void)startAnimating
{
   
    
    if (self.isAnimating)
    {
        CAAnimation *ani = [bgImageView.layer animationForKey:kModelAnimation];
        
        if (ani) return;
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    animation.duration = 10.0;
    animation.repeatCount = HUGE_VALF;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [bgImageView.layer addAnimation:animation forKey:kModelAnimation];
    });
    
    self.isAnimating = YES;
}

- (void)stopAnimating
{
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [bgImageView.layer removeAllAnimations];
    });
    
    self.isAnimating = NO;
}

- (void)imageForModel:(NSString *)model
{
    if([model isEqualToString:NSLocalizedString(@"手动控制", ) ])
    {
        modelImageView.image = [UIImage imageNamed:@"manualModel.png"];
    }
    else if([model isEqualToString:NSLocalizedString(@"智能调节", ) ])
    {
        modelImageView.image = [UIImage imageNamed:@"intellectualModel.png"];
    }
}

@end
