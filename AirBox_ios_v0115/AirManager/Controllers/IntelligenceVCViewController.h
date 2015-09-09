//
//  IntelligenceVCViewController.h
//  AirManager
//
//  Created by yuan jie on 14-11-19.
//  Copyright (c) 2014年 luolin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IntelligenceVCViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UIImageView *oldRunningImageView;
    
    __weak IBOutlet UIImageView *womanRuningImageView;
    __weak IBOutlet UIImageView *manRuningImageView;
    __weak IBOutlet UIImageView *childRuningImageView;
    IBOutlet UIView *viewCurve;
    IBOutlet UIView *viewSleepModule;
    __weak IBOutlet UIButton *btnSleepModule;
    __weak IBOutlet UIButton *btnOld;
    __weak IBOutlet UIButton *btnChild;
    __weak IBOutlet UIButton *btnMan;
    __weak IBOutlet UIButton *btnWoman;
    __weak IBOutlet UIButton *btnApply;
    __weak IBOutlet UILabel *labelCureTitle;
     IBOutlet UIView *viewCurveContent;
    __weak IBOutlet UIButton *btnConver;
    __weak IBOutlet UILabel *labelCureContent;
}



- (void)changeApStatus;

/**
 *  Small A download user mode
 **/
- (void)downloadAirBoxModel:(NSInteger)requestCount;

@property (nonatomic, strong) NSMutableArray *arrBindIRDevice;
@property (nonatomic, assign) BOOL isFromSleepModule;


@end
