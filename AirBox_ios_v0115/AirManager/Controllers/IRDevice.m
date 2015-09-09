//
//  IRDevice.m
//  AirManager
//

#import "IRDevice.h"

@implementation IRDevice

- (id)initWithDevice:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.brand          = dict[@"brand"];
        self.brandName      = dict[@"brandName"];
        self.devModel       = dict[@"devModel"];
        self.devModelName   = dict[@"devModelName"];
        self.devType        = dict[@"devType"];
        self.devTypeName    = dict[@"devTypeName"];
    }
    return self;
}

@end
