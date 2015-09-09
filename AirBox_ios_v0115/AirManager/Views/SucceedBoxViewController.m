//
//  SucceedBoxViewController.m
//  AirManager
//

#import "SucceedBoxViewController.h"

@interface SucceedBoxViewController ()

@end

@implementation SucceedBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Utility setExclusiveTouchAll:self.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)succeedButtonOnClicked:(id)sender
{
    [self dismiss:^
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(succeedBoxOkButtonOnClicked)])
        {
            [self.delegate succeedBoxOkButtonOnClicked];
        }
    }];
}

- (IBAction)failedButtonOnClicked:(id)sender
{
    [self dismiss:^
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(succeedBoxCancelButtonOnClicked)])
        {
            [self.delegate succeedBoxCancelButtonOnClicked];
        }
    }];
}

@end
