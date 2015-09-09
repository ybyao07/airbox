//
//  AirAdjustCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface AirAdjustCell : UITableViewCell{
    IBOutlet UIImageView *cellIcon;
    IBOutlet UIButton *leftBtn;
    IBOutlet UIButton *rightBtn;
    IBOutlet UILabel *lblContent;
}

@property (nonatomic, strong) UIImageView *cellIcon;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *lblContent;

@end
