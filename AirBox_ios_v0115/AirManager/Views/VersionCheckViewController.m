//
//  VersionCheckViewController.m
//  AirManager
//
//  Created by Luo Lin on 14-6-9.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "VersionCheckViewController.h"

@interface VersionCheckViewController ()

@end

@implementation VersionCheckViewController

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
         if (self.delegate && [self.delegate respondsToSelector:@selector(updateVersionButtonOnClicked)])
         {
             [self.delegate updateVersionButtonOnClicked];
         }
     }];
}

- (IBAction)failedButtonOnClicked:(id)sender
{
    [self dismiss:^
     {
         if (self.delegate && [self.delegate respondsToSelector:@selector(notUpdateVersionButtonOnClicked)])
         {
             [self.delegate notUpdateVersionButtonOnClicked];
         }
     }];
}

@end
