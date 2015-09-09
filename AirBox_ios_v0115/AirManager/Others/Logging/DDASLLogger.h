#import <Foundation/Foundation.h>
#import <asl.h>

#import "DDLog.h"

@interface DDASLLogger : DDAbstractLogger <DDLogger>
{
    aslclient client;
}

+ (instancetype)sharedInstance;

// Inherited from DDAbstractLogger

// - (id <DDLogFormatter>)logFormatter;
// - (void)setLogFormatter:(id <DDLogFormatter>)formatter;

@end
