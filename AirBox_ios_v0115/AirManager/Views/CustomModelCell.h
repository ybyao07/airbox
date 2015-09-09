//
//  IRStudyCell.h
//  AirManager
//

#import <UIKit/UIKit.h>

@interface CustomModelCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong, nonatomic) IBOutlet UILabel *lblName;

- (void)deleteStatus:(BOOL)isDelete;

@end
