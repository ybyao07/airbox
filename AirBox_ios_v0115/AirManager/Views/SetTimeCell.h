//
//  SetTimeCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

#import "IDJPickerView.h"

@interface SetTimeCell : UITableViewCell{
    IBOutlet IDJPickerView *datePicker;
    IBOutlet UIButton *okBtn;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UILabel *lblHour;
    IBOutlet UILabel *lblMinute;
}

@property (nonatomic, strong) IDJPickerView *datePicker;
@property (nonatomic, strong) UIButton *okBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic) NSTimeInterval countDownDuration;

@end
