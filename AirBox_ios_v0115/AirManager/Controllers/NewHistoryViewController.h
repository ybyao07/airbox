//
//  NewHistoryViewController.h
//  AirManager
//
//  Created by Luo Lin on 14-6-12.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AirDevice;

@interface NewHistoryViewController : UIViewController <UIScrollViewDelegate>
{
    __weak IBOutlet UIView *view1;
    __weak IBOutlet UIView *view3;
    __weak IBOutlet UIView *view2;
    AirDevice *airDevice;
    NSNumber *rankValue;
}

@property (nonatomic, strong) AirDevice *airDevice;
@property (nonatomic, strong) NSNumber *rankValue;
@property (nonatomic, strong) UIView *baseview;

@end
