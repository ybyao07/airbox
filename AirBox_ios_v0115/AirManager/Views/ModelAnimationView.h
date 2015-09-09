//
//  ModelAnimationView.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface ModelAnimationView : UIViewController
{
    IBOutlet UIButton *actionBtn;
}

- (void)startAnimating;
- (void)stopAnimating;
- (void)imageForModel:(NSString *)model;

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) UIButton *actionBtn;

@end
