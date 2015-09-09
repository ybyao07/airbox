//
//  AirQualityCell.h
//  AirManager
//
//  Created by Chen on 14-6-13.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointsWeatherView : UIView

@property (strong, nonatomic) IBOutlet UILabel *lblHour;
@property (strong, nonatomic) IBOutlet UIImageView *airIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblTemperature;

@end
