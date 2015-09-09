//
//  HintViewController.m
//  AirManager
//
//  Created by bluE on 14-11-10.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "HintViewController.h"

@interface HintViewController ()

@end

@implementation HintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utility setExclusiveTouchAll:self.view];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter / Setter Methods

- (void)setMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _titleLabel.text = message;
        DDLogCVerbose(@"--->HintView message: %@",message);
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)okButtonOnClicked:(id)sender {
    [self dismiss:^{
    }];
}
@end
