//
//  IntellAirAdjustCell.h
//  AirManager
//
//  Created by yuan jie on 14-11-21.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntellAirAdjustCell : UITableViewCell
{
    IBOutlet UIImageView *cellIcon;
    IBOutlet UIButton *leftBtn;
    IBOutlet UIButton *rightBtn;
    IBOutlet UILabel *lblContent;
}

@property (nonatomic, strong) UIImageView *cellIcon;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *lblContent;

@end
