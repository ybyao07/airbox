//
//  ChangeNameViewController.h
//  AirManager
//


@class AirDevice;

@interface ChangeNameViewController : UIViewController
{
    AirDevice *airDevice;
}

@property (nonatomic, strong) AirDevice *airDevice;
@property (nonatomic, strong) UIView *baseview;

@end
