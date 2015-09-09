//
//  CityDataHelper.m
//  AirManager
//

#import "CityDataHelper.h"
#import "AppDelegate.h"
#define kCitiesPlistFileName    @"Cities.plist"
#define kCitiesPlistFileNameEn    @"CitiesEn.plist"



@implementation CityDataHelper

+ (NSArray *)cityArray
{
    NSString *filePath;
    if ([MainDelegate isLanguageEnglish]) {
        filePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kCitiesPlistFileNameEn];
    }
    else{
        filePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), kCitiesPlistFileName];
    }
    
    
    NSArray *cities = nil;
    
    BOOL fileExisted = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!fileExisted)
    {
        DDLogCVerbose(@"%@ does not exist", filePath);
        
        cities = [CityDataHelper readCitysTextFile];
        BOOL succeeded = [cities writeToFile:filePath atomically:YES];
        if (!succeeded)
        {
            DDLogCVerbose(@"Failed to write to file: %@", filePath);
        }
    }
    else
    {
        DDLogCVerbose(@"%@ exists", filePath);
        
        cities = [[NSArray alloc] initWithContentsOfFile:filePath];
        
    }
    
    return cities;
}

+ (NSArray *)readCitysTextFile
{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"citys" ofType:@"txt"];
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error)
    {
        DDLogCVerbose(@"%@", error);
        
        return nil;
    }
    
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    NSMutableArray *cities = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSString *line in lines)
    {
        NSArray *items = [line componentsSeparatedByString:@","];
        if (items.count < 10) {
            continue;
        }
        
        NSMutableDictionary *city = [NSMutableDictionary dictionaryWithCapacity:4];
        city[kCityID] = items[0];
        city[kCityName] = items[2];
        city[kProvinceID] = items[6];
        city[kCityNameEN] = items[1];
        
        [cities addObject:city];
        
        
    }
    
    DDLogCVerbose(@"Cities (%d):\n%@", cities.count, cities);
    
    return cities;
}

+ (void)updateSelectedCity:(NSDictionary *)city
{
    if (!city) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:kSelectedCity];
}

+ (void)removeSelectedCity
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSelectedCity];
}

+ (NSDictionary *)selectedCity
{
    NSDictionary *city = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSelectedCity];
    
    return city;
}

+ (NSString *)cityIDOfSelectedCity
{
    NSDictionary *city = [CityDataHelper selectedCity];
    if (!city) return kCityIDBeijing;
    
    return city[kCityID];
}

+ (NSString *)cityNameOfSelectedCity
{
    NSDictionary *city = [CityDataHelper selectedCity];
    if (!city) return NSLocalizedString(kCityNameBeijing, @"CityName");
    
    return city[kCityName];
}


@end
