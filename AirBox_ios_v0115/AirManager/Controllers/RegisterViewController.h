//
//  RegisterViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (nonatomic, strong) UIView *baseview;

- (void)removeFromParentView;
@property (nonatomic,strong)  UIViewController *parentVC;

@end
