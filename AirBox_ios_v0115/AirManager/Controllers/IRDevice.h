//
//  IRDevice.h
//  AirManager
//

#import <Foundation/Foundation.h>

@interface IRDevice : NSObject

@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *devModel;
@property (nonatomic, strong) NSString *devModelName;
@property (nonatomic, strong) NSString *devType;
@property (nonatomic, strong) NSString *devTypeName;

- (id)initWithDevice:(NSDictionary *)dict;

@end
