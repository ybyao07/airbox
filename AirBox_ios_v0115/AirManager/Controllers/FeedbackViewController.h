//
//  FeedbackViewController.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface FeedbackViewController : UIViewController <UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIView *baseview;
@property (nonatomic, strong) UIViewController *parentContoller;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;//ybyao07

@end
