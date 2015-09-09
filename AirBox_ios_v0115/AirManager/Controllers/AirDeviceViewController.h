//
//  AirDeviceViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@class AirDevice;
@class AirQuality;

@interface AirDeviceViewController : UIViewController{
    
    AirDevice *curDevice;               //current air device
    AirQuality *curDeviceAirQuality;    //current air device quality
    NSMutableArray *arrBindedIRDevice;
    __weak IBOutlet UIButton *btnRetryConnect;

}

/**
 *  open ac control page
 **/


- (void)openACoperatePage:(void(^)())handler;

- (void)openIntelligencePage:(void(^)())handler;

//- (void)downloadIrDevice;

- (void)checkIRCode;

- (BOOL)isIntellgentMode;

- (void)changeAirBoxName;

- (void)downloadAirBoxModel;


- (void)startCheckWaitCountDownCase1;

@property (nonatomic, strong) AirDevice *curDevice;
@property (nonatomic, strong) AirQuality *curDeviceAirQuality;
@property (nonatomic, strong) NSMutableArray *arrBindedIRDevice;

@end
