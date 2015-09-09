//
//  CityDataHelper.h
//  AirManager
//

#import <Foundation/Foundation.h>

#define kCityID         @"CityID"
#define kCityName       @"CityName"
#define kCityNameEN     @"CityNameEN"
#define kProvinceID     @"ProvinceID"

@interface CityDataHelper : NSObject

+ (NSArray *)cityArray;
+ (void)updateSelectedCity:(NSDictionary *)city;
+ (NSDictionary *)selectedCity;
+ (void)removeSelectedCity;
+ (NSString *)cityIDOfSelectedCity;
+ (NSString *)cityNameOfSelectedCity;


@end
