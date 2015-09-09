//
//  FeedbackCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface FeedbackCell : UITableViewCell

/**
 *  c=用户，s客服
 */

@property (strong, nonatomic) IBOutlet UILabel *lblcName;
@property (strong, nonatomic) IBOutlet UILabel *lblcDate;
@property (strong, nonatomic) IBOutlet UILabel *lblcInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblsName;
@property (strong, nonatomic) IBOutlet UILabel *lblsDate;
@property (strong, nonatomic) IBOutlet UILabel *lblsInfo;
@end
