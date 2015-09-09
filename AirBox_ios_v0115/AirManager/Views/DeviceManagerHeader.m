//
//  DeviceManagerHeader.m
//  AirManager
//


#import "DeviceManagerHeader.h"

@implementation DeviceManagerHeader

@synthesize editBtn;
@synthesize accessoryBtn;
@synthesize selectedBtn;
@synthesize textLbl;
@synthesize macLbl;
@synthesize voiceBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
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
//            accessoryBtn.hidden = NO;
            selectedBtn.hidden = YES;
            textLbl.frame = CGRectMake(52,textLbl.frame.origin.y,textLbl.frame.size.width,textLbl.frame.size.height);
            macLbl.frame = CGRectMake(52,macLbl.frame.origin.y,macLbl.frame.size.width,macLbl.frame.size.height);
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            editBtn.hidden = YES;
//            accessoryBtn.hidden = YES;
            selectedBtn.hidden = NO;
            textLbl.frame = CGRectMake(10,textLbl.frame.origin.y,textLbl.frame.size.width,textLbl.frame.size.height);
            macLbl.frame = CGRectMake(10,macLbl.frame.origin.y,macLbl.frame.size.width,macLbl.frame.size.height);
        });
    }
}

@end
