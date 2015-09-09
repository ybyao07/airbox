//
//  CustomIndexViewController.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-6-25.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CitySelectedProtocol.h"

@interface CustomIndexViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *baseview;
@property (strong, nonatomic) NSArray *indexArray;
- (IBAction)back:(id)sender;
- (IBAction)commitAction:(id)sender;
@property (nonatomic, weak) id<CitySelectedProtocol> citySelectedProtocol;

@end
