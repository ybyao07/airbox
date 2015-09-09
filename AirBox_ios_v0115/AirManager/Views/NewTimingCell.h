//
//  NewTimingCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface NewTimingCell : UITableViewCell
{
    IBOutlet UIButton *rightBtn;
    IBOutlet UILabel *lblContent;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *iconImg;
}

@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *lblContent;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UIImageView *iconImg;

@end
