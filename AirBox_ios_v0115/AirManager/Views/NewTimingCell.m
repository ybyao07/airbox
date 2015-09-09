//
//  NewTimingCell.m
//  AirManager
//

#import "NewTimingCell.h"

@implementation NewTimingCell

@synthesize rightBtn;
@synthesize lblContent;
@synthesize lblTitle;
@synthesize iconImg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [Utility setExclusiveTouchAll:self];
    
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
