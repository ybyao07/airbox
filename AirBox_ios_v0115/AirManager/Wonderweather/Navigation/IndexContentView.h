//
//  IndexContentView.h
//  wonderweather
//
//  Created by 先丰 刘 on 14-6-12.
//  Copyright (c) 2014年 先丰 刘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexData.h"
@interface IndexContentView : UIView
{
    UIImageView *_indexImageView;
    UILabel *_indexTitleLabel;
    UILabel *_indexContentLabel;
    UILabel *_indexDecripeLabel;
}
- (void)updateContentView:(IndexData *)indexData;
@end
