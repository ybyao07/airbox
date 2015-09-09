//
//  ApAdjustCell.h
//  AirManager
//
//  Created by Luo Lin on 14-6-17.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApAdjustCell : UITableViewCell
{
    IBOutlet UILabel *title;
    IBOutlet UIButton *onOffBtn;
    IBOutlet UIView *subBg;
}

@property (nonatomic, strong)UIButton *onOffBtn;
@property (nonatomic, strong)UIView *subBg;
@property (nonatomic, strong)UILabel *title;

@end
