//
//  IRStudyCell.m
//  AirManager
//

#import "CustomModelCell.h"
#import "UIViewExt.h"

@implementation CustomModelCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Public

- (void)deleteStatus:(BOOL)isDelete
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isDelete) {
            self.deleteButton.hidden = NO;
            CGRect frame = CGRectMake(52, self.lblName.top, self.lblName.width, self.lblName.height);
            self.lblName.frame = frame;
        }
        else
        {
            self.deleteButton.hidden = YES;
            CGRect frame = CGRectMake(10, self.lblName.top, self.lblName.width, self.lblName.height);
            self.lblName.frame = frame;
        }
    });
}

@end
