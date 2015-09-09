//
//  IRDeviceModelSelectionViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

#define kDeviceTypeAC   @"AC"
#define kDeviceTypeAP   @"AP"

@class AirDevice;
@class AirPurgeModel;

@interface IRDeviceModelSelectionViewController : UIViewController
{
    AirDevice *selectedAirDevice;
    AirPurgeModel *airPurgeModel;
}

@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) AirDevice *selectedAirDevice;
@property (nonatomic, strong) AirPurgeModel *airPurgeModel;
@property (nonatomic, strong) UIView *baseview;

- (IBAction)backButtonOnClicked:(id)sender;

@end
