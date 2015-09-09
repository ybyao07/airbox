//
//  RetryBoxViewController.m
//  AirManager
//

#import "RetryBoxViewController.h"

@interface RetryBoxViewController ()

@end

@implementation RetryBoxViewController

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


- (IBAction)retryButtonOnClicked:(id)sender
{
    [self dismiss:^
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(retryBoxOkButtonOnClicked)])
        {
            [self.delegate retryBoxOkButtonOnClicked];
        }
    }];
}

- (IBAction)retryCancelButtonOnClicked:(id)sender
{
    [self dismiss:^
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(retryBoxCancelButtonOnClicked)])
        {
            [self.delegate retryBoxCancelButtonOnClicked];
        }
    }];
}

@end
