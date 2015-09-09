//
//  AirConditionViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@class AirQuality;
@class AirDevice;

@interface AirConditionViewController : UIViewController
{
    AirQuality *airQuality;
    NSMutableArray *arrBindIRDevice;
}

- (void)changeApStatus;

/**
 *  Small A download user mode
 **/
- (void)downloadAirBoxModel:(NSInteger)requestCount;

- (void)checkIsIncludeHeathly;

@property (nonatomic, strong) AirQuality *airQuality;
@property (nonatomic, strong) NSMutableArray *arrBindIRDevice;
@property (nonatomic, strong) UIView *baseview;
@property (nonatomic, strong) AirDevice *curDevice;

@end
