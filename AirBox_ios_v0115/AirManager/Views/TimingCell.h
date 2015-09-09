//
//  TimingCell.h
//

#import <UIKit/UIKit.h>
#import "TimerAnimationView.h"

@interface TimingCell : UITableViewCell{
    IBOutlet UILabel *lblTime;
    IBOutlet UIButton *limitBtn;
    IBOutlet UILabel *lblAirBoxName;
    IBOutlet UIButton *onOffBtn;
}

@property (nonatomic, strong) UILabel *lblTime;
@property (nonatomic, strong) UIButton *limitBtn;
@property (nonatomic, strong) UILabel *lblAirBoxName;
@property (nonatomic, strong) UIButton *onOffBtn;
@property (nonatomic, strong) TimerAnimationView *timerView;

@end
