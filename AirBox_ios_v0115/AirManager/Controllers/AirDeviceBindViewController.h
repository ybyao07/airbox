//
//  AirDeviceBindViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>
#import "LocationController.h"

@interface AirDeviceBindViewController : UIViewController <LocationDelegate>
{
    
}

- (IBAction)completeInStep4:(id)sender;
@property (nonatomic, strong) UIView *baseview;
@property (nonatomic,strong)  UIViewController *parentVC;

@end
