//
//  SetTimeCell.m
//  AirManager
//

#import "SetTimeCell.h"
#import "UIDevice+Resolutions.h"

@implementation SetTimeCell

@synthesize datePicker;
@synthesize okBtn;
@synthesize cancelBtn;

- (void)dealloc
{
    DDLogFunction();
   
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self customCell];
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)setCountDownDuration:(NSTimeInterval)duration
{
    _countDownDuration = duration;
    self.datePicker.countDownDuration = duration;
    
}

#define BGColor [UIColor colorWithRed:117/255.0 green:113/255.0 blue:114/255.0 alpha:1.0]

- (void)customCell
{
    IDJPickerView *picker = [[IDJPickerView alloc] initWithFrame:CGRectMake(60, 0, 180, 162) dataLoop:YES];
    self.datePicker = picker;
    self.datePicker.countDownDuration = self.countDownDuration;
    [self.datePicker configPickerView];
    self.datePicker.backgroundColor = [UIColor clearColor];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:self.datePicker];
    });
    
    CGRect rect = [UIDevice isRunningOn4Inch] ? CGRectMake(15, 58.5, 40, 40) : CGRectMake(15, 61, 40, 40);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = [UIImage imageNamed:@"01-定时.png"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:imageView];
    });
    
    self.okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.okBtn.tag = 0;
    self.okBtn.frame = CGRectMake(260, 85, 54, 54);
    /* 6.17
    [self.okBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.okBtn.titleLabel.font = [UIFont fontWithName:@"Euphemia UCAS" size:17];
    [self.okBtn setTitleColor:[UIColor scrollViewTexturedBackgroundColor] forState:UIControlStateNormal];
    self.okBtn.backgroundColor = BGColor;
     */
    [self.okBtn setImage:[UIImage imageNamed:@"10-确定.png"] forState:UIControlStateNormal];
    self.okBtn.imageEdgeInsets = [UIDevice isRunningOn4Inch]?UIEdgeInsetsMake(10, 10, 10, 10):UIEdgeInsetsMake(12, 12, 12, 12);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:self.okBtn];
    });
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.tag = 1;
    self.cancelBtn.frame = CGRectMake(260, 15, 54, 54);
    /* 6.17
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont fontWithName:@"Euphemia UCAS" size:17];
    [self.cancelBtn setTitleColor:[UIColor scrollViewTexturedBackgroundColor] forState:UIControlStateNormal];
    self.cancelBtn.backgroundColor = BGColor;
    */
    [self.cancelBtn setImage:[UIImage imageNamed:@"09-删除.png"] forState:UIControlStateNormal];
    self.cancelBtn.imageEdgeInsets = [UIDevice isRunningOn4Inch]?UIEdgeInsetsMake(10, 10, 10, 10):UIEdgeInsetsMake(12, 12, 12, 12);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:self.cancelBtn];
    });
    
    lblHour = [[UILabel alloc] initWithFrame:CGRectMake(130, 70, 42, 21)];
    lblHour.backgroundColor = [UIColor clearColor];
    lblHour.text = NSLocalizedString(@"小时",@"SetTimeCell.m" );
    lblHour.font = [UIFont fontWithName:@"Euphemia UCAS" size:13];
    lblHour.textColor = BGColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:lblHour];
    });
    
    lblMinute = [[UILabel alloc] initWithFrame:CGRectMake(220, 70, 42, 21)];
    lblMinute.backgroundColor = [UIColor clearColor];
    lblMinute.text = NSLocalizedString(@"分钟",@"SetTimeCell.m" );
    lblMinute.font = [UIFont fontWithName:@"Euphemia UCAS" size:13];
    lblMinute.textColor = BGColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:lblMinute];
    });
    
    /* 6.17
    NSArray * frames = @[[NSValue valueWithCGRect:CGRectMake(0, 62, 320, 1)] ,
                         [NSValue valueWithCGRect:CGRectMake(0, 106, 320, 1)] ,
                         [NSValue valueWithCGRect:CGRectMake(0, 161, 320, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 320, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 215, 320, 1)]];
    
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            UIImageView *view = [[UIImageView alloc] initWithFrame:[[frames objectAtIndex:idx] CGRectValue]];
            view.contentMode = UIViewContentModeScaleToFill;
            view.image = [UIImage imageNamed:@"split_hor_2.png"];
            view.alpha = 0.5;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.contentView addSubview:view];
            });
        }
    }];

    UIImageView *separator = [[UIImageView alloc] initWithFrame:CGRectMake(159, 161, 1, 55)];
    separator.contentMode = UIViewContentModeScaleToFill;
    separator.image = [UIImage imageNamed:@"splite_ver.png"];
    separator.alpha = 0.5;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentView addSubview:separator];
    });
     */
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.countDownDuration < 60*60) {
        self.countDownDuration = 60*60;
    }
    int hour = (int)self.countDownDuration/(60*60);
    int minute = (int)self.countDownDuration/60%60;
    [self.datePicker setHour:hour minute:minute];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
