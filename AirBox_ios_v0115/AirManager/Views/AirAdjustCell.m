//
//  AirAdjustCell.m
//  AirManager
//

#import "AirAdjustCell.h"

@implementation AirAdjustCell

@synthesize cellIcon;
@synthesize leftBtn;
@synthesize rightBtn;
@synthesize lblContent;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
