//
//  DeviceManagerHeader.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface DeviceManagerHeader : UIView
{
    IBOutlet UIButton *voiceBtn;
    IBOutlet UIButton *editBtn;
    IBOutlet UIButton *accessoryBtn;
    IBOutlet UIButton *selectedBtn;
    IBOutlet UILabel  *textLbl;
    IBOutlet UILabel  *macLbl;
}

- (void)editStatus:(BOOL)edit;

@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *accessoryBtn;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UILabel  *textLbl;
@property (nonatomic, strong) UILabel  *macLbl;
@end
