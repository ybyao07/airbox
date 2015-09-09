//
//  HintViewController.h
//  AirManager
//
//  Created by bluE on 14-11-10.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "AlertBoxViewController.h"

@interface HintViewController : AlertBoxViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)okButtonOnClicked:(id)sender;

@end
