//
//  IntellAirAdjustCell.m
//  AirManager
//
//  Created by yuan jie on 14-11-21.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import "IntellAirAdjustCell.h"

@implementation IntellAirAdjustCell

@synthesize cellIcon;
@synthesize leftBtn;
@synthesize rightBtn;
@synthesize lblContent;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
