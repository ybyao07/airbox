//
//  AirQualityHistoryViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@class AirDevice;

@interface AirQualityHistoryViewController : UIViewController
{
    AirDevice *airDevice;
}

@property (nonatomic, strong) AirDevice *airDevice;

@end
