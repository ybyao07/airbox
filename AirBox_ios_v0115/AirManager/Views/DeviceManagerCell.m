//
//  DeviceManagerCell.m
//  AirManager
//

#import "DeviceManagerCell.h"
#import "UIViewExt.h"

@implementation DeviceManagerCell

@synthesize editBtn;
@synthesize textLbl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [Utility setExclusiveTouchAll:self];
    }
    return self;
}

- (void)editStatus:(BOOL)edit
{
    if(edit)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            editBtn.hidden = NO;
            editBtn.top = (self.height - editBtn.height)/2;
            textLbl.frame = CGRectMake(62,textLbl.frame.origin.y,textLbl.frame.size.width,textLbl.frame.size.height);
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            editBtn.hidden = YES;
            textLbl.frame = CGRectMake(20,textLbl.frame.origin.y,textLbl.frame.size.width,textLbl.frame.size.height);
        });
    }
}

@end
