//
//  AccountActivationViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface AccountActivationViewController : UIViewController
{
    IBOutlet UILabel        *_phoneNumberLabel;
    IBOutlet UITextField    *_activationCodeTextField;
    IBOutlet UIButton       *_countDownButton;
    
    int                     _leftSeconds;
    NSTimer                 *_countDownTimer;
    NSString                *phoneNumber;
    NSString                *passWord;
    BOOL                    isOpenFromRegiste;
}

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *passWord;
@property (nonatomic, assign) BOOL isOpenFromRegiste;
@property (nonatomic, strong) UIView *baseview;
@property (nonatomic,strong)  UIViewController *parentVC;

@end
