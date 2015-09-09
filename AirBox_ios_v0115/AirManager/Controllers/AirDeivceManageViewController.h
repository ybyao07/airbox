//
//  AirViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@class AirQuality;
@class AirDevice;
@class AirDeviceViewController;

@interface AirDeivceManageViewController : UIViewController{
    IBOutlet UIScrollView *airDeviceScrollView;
    IBOutlet UIButton *intelligentBtn;
    IBOutlet UIButton *airConditionBtn;
}


/**
 *  Exit air box info page
 **/
- (void)backToHomePage;

/**
 *  Share air box info
 **/
- (void)shareAirBoxInfo:(UIButton *)sender;

- (void)addModelAnimation;

- (void)refreshModelAnimation:(BOOL)isConnect withMac:(NSString *)mac;

- (void)openOpenModePage:(void(^)())handler;


@property (nonatomic, strong)UIScrollView *airDeviceScrollView;
@property (nonatomic, strong)UIButton *intelligentBtn;
@property (nonatomic, strong)UIButton *airConditionBtn;
@property (nonatomic, assign)BOOL  isFromMannul;

@property (nonatomic, strong) AirDeviceViewController *curDeviceVC;
@property (nonatomic, strong) NSString *pm25OutDoor;

@end
