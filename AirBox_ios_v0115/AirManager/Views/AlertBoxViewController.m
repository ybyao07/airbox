//
//  AlertBoxViewController.m
//  AirManager
//

#import "AlertBoxViewController.h"
#import "AppDelegate.h"

@interface AlertBoxViewController ()
{
    IBOutlet UIButton       *_okButtonLeft;
    IBOutlet UIButton       *_okButtonCenter;
    IBOutlet UIButton       *_cancelButton;
    IBOutlet UIImageView    *_splitImageView;
    IBOutlet UILabel        *_titleLabel;
}

@end

@implementation AlertBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _delegate = nil;
        _tag = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Utility setExclusiveTouchAll:self.view];
}

- (void)didReceiveMemoryWarning
{
   
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter / Setter Methods

- (void)setMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _titleLabel.text = message;
        DDLogCVerbose(@"--->AlertBox message: %@",message);
    });
}

- (void)setHasCancelButton:(BOOL)hasCancelButton
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        _okButtonCenter.hidden = hasCancelButton;
        _okButtonLeft.hidden = !hasCancelButton;
        _cancelButton.hidden = !hasCancelButton;
        _splitImageView.hidden = !hasCancelButton;
    });
}

#pragma mark - Button Events Methods

- (void)dismiss:(void(^)())completionHandler
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0;
        }
        completion:^(BOOL finished){
            [self.view removeFromSuperview];
            MainDelegate.isShowingAlertBox = NO;
            if(completionHandler)
            {
                completionHandler();
            }
        }];
    });
}

- (IBAction)okButtonOnClicked:(id)sender
{
    [self dismiss:^
    {
        if (_delegate && [_delegate respondsToSelector:@selector(alertBoxOkButtonOnClicked)])
        {
            [_delegate alertBoxOkButtonOnClicked];
        }
        else if(_delegate && [_delegate respondsToSelector:@selector(alertBoxOkButtonOnClicked:)])
        {
            [_delegate alertBoxOkButtonOnClicked:self];
        }
            
    }];
    

}

- (IBAction)cancelButtonOnClicked:(id)sender
{
   
    
    [self dismiss:^{}];
}

@end
