//
//  AirBoxStatus.h
//  AirManager
//

#import <Foundation/Foundation.h>

@interface AirBoxStatus : NSObject
{
    NSNumber *temperature;
    NSNumber *humidity;
    NSString *voc;
    NSString *pm25;
    NSString *moodPoint;
    NSString *voiceVaule;
}

@property(nonatomic,strong)NSNumber *temperature;
@property(nonatomic,strong)NSNumber *humidity;
@property(nonatomic,strong)NSString *voc;
@property(nonatomic,strong)NSString *pm25;
@property(nonatomic,strong)NSString *moodPoint;
@property(nonatomic,strong)NSString *voiceVaule;

@end
