//
//  WebViewController.h
//  AirManager
//
//  Created by chen on 14-5-27.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, strong) UIView *baseview;

@end
