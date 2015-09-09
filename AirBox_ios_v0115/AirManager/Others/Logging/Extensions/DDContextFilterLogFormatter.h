#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface DDContextWhitelistFilterLogFormatter : NSObject <DDLogFormatter>

- (id)init;

- (void)addToWhitelist:(int)loggingContext;
- (void)removeFromWhitelist:(int)loggingContext;

- (NSArray *)whitelist;

- (BOOL)isOnWhitelist:(int)loggingContext;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This class provides a log formatter that filters log statements from a logging context on the blacklist.
**/
@interface DDContextBlacklistFilterLogFormatter : NSObject <DDLogFormatter>

- (id)init;

- (void)addToBlacklist:(int)loggingContext;
- (void)removeFromBlacklist:(int)loggingContext;

- (NSArray *)blacklist;

- (BOOL)isOnBlacklist:(int)loggingContext;

@end
