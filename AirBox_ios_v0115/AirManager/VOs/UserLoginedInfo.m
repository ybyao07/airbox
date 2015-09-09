//
//  UserLoginedInfo.m
//  AirManager
//

#import "UserLoginedInfo.h"

@implementation UserLoginedInfo

@synthesize userID;
@synthesize loginPwd;
@synthesize loginID;
@synthesize accessToken;
@synthesize name;
@synthesize accessIP;
@synthesize accessPort;
@synthesize arrUserBindedDevice;

- (id)init{
    self = [super init];
    if(self)
    {
        self.accessToken = @"";
    }
    return self;
}

@end
