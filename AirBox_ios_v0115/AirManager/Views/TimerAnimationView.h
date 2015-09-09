//
//  TimerAnimationView.h
//

#import <UIKit/UIKit.h>

@interface TimerAnimationView : UIView

@property (nonatomic) BOOL isAnimating;

- (void)startAnimating;
- (void)stopAnimating;

@end
