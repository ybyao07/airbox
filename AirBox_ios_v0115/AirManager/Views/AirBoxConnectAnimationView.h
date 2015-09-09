//
//  AirBoxConnectAnimationView.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface AirBoxConnectAnimationView : UIView

- (void)prepareConnect;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
