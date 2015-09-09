//
//  UserLoginedInfo.h
//  AirManager
//

#import <Foundation/Foundation.h>

@interface UserLoginedInfo : NSObject{
    NSString *loginID;
    NSString *loginPwd;
    
    NSString *userID;
    NSString *accessToken;
    NSString *name;
    NSString *accessIP;
    NSNumber *accessPort;
    NSMutableArray *arrUserBindedDevice;
}

@property (nonatomic, strong) NSString *loginID;
@property (nonatomic, strong) NSString *loginPwd;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *accessIP;
@property (nonatomic, strong) NSNumber *accessPort;
@property (nonatomic, strong) NSMutableArray *arrUserBindedDevice;

@end
