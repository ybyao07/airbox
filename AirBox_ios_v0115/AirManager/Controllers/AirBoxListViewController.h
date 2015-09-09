//
//  AirBoxListViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>
#import "AlertBox.h"

@interface AirBoxListViewController : UIViewController <AlertBoxDelegate>
{
    BOOL isFromAutoLogin;
}

@property (nonatomic,assign) BOOL isFromAutoLogin;
@property (nonatomic, strong) UIView *baseview;
@property (nonatomic,strong)  UIViewController *parentVC;

@end
