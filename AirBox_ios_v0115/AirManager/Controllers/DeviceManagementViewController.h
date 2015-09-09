//
//  DeviceManagementViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface DeviceManagementViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UIView *baseview;

- (void)reloadTableView1;
- (void)downloadIrDevice;


@end
