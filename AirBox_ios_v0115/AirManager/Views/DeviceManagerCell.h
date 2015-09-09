//
//  DeviceManagerCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface DeviceManagerCell : UITableViewCell
{
    IBOutlet UIButton *editBtn;
    IBOutlet UILabel  *textLbl;
}

- (void)editStatus:(BOOL)edit;

@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UILabel  *textLbl;

@end
