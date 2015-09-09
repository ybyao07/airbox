//
//  TimingCell.m
//

#import "TimingCell.h"
#import "UIDevice+Resolutions.h"

@implementation TimingCell

@synthesize lblTime;
@synthesize limitBtn;
@synthesize lblAirBoxName;
@synthesize onOffBtn;

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

- (void)layoutSubviews
{
   
    
    if (!_timerView)
    {
        CGRect rect = [UIDevice isRunningOn4Inch] ? CGRectMake(110, 20, 35, 36) : CGRectMake(110, 12, 35, 36);
        _timerView = [[TimerAnimationView alloc] initWithFrame:rect];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:_timerView];
        });
    }
}

@end
