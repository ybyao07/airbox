#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface DDMultiFormatter : NSObject <DDLogFormatter>

/**
 *  Array of chained formatters
 */
@property (readonly) NSArray *formatters;

- (void)addFormatter:(id<DDLogFormatter>)formatter;
- (void)removeFormatter:(id<DDLogFormatter>)formatter;
- (void)removeAllFormatters;
- (BOOL)isFormattingWithFormatter:(id<DDLogFormatter>)formatter;

@end
