#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>
#import "DDLog.h"

@interface DDDispatchQueueLogFormatter : NSObject <DDLogFormatter> {
@protected
    
    NSString *dateFormatString;
}

/**
 * Standard init method.
 * Configure using properties as desired.
**/
- (id)init;

/**
 * The minQueueLength restricts the minimum size of the [detail box].
 * If the minQueueLength is set to 0, there is no restriction.
 * 
 * For example, say a dispatch_queue has a label of "diskIO":
 * 
 * If the minQueueLength is 0: [diskIO]
 * If the minQueueLength is 4: [diskIO]
 * If the minQueueLength is 5: [diskIO]
 * If the minQueueLength is 6: [diskIO]
 * If the minQueueLength is 7: [diskIO ]
 * If the minQueueLength is 8: [diskIO  ]
 * 
 * The default minQueueLength is 0 (no minimum, so [detail box] won't be padded).
 * 
 * If you want every [detail box] to have the exact same width,
 * set both minQueueLength and maxQueueLength to the same value.
**/
@property (assign) NSUInteger minQueueLength;

/**
 * The maxQueueLength restricts the number of characters that will be inside the [detail box].
 * If the maxQueueLength is 0, there is no restriction.
 * 
 * For example, say a dispatch_queue has a label of "diskIO":
 *
 * If the maxQueueLength is 0: [diskIO]
 * If the maxQueueLength is 4: [disk]
 * If the maxQueueLength is 5: [diskI]
 * If the maxQueueLength is 6: [diskIO]
 * If the maxQueueLength is 7: [diskIO]
 * If the maxQueueLength is 8: [diskIO]
 * 
 * The default maxQueueLength is 0 (no maximum, so [detail box] won't be truncated).
 * 
 * If you want every [detail box] to have the exact same width,
 * set both minQueueLength and maxQueueLength to the same value.
**/
@property (assign) NSUInteger maxQueueLength;

/**
 * Sometimes queue labels have long names like "com.apple.main-queue",
 * but you'd prefer something shorter like simply "main".
 * 
 * This method allows you to set such preferred replacements.
 * The above example is set by default.
 * 
 * To remove/undo a previous replacement, invoke this method with nil for the 'shortLabel' parameter.
**/
- (NSString *)replacementStringForQueueLabel:(NSString *)longLabel;
- (void)setReplacementString:(NSString *)shortLabel forQueueLabel:(NSString *)longLabel;

@end

/**
 * Method declarations that make it easier to extend/modify DDDispatchQueueLogFormatter
**/
@interface DDDispatchQueueLogFormatter (OverridableMethods)

- (NSString *)stringFromDate:(NSDate *)date;
- (NSString *)queueThreadLabelForLogMessage:(DDLogMessage *)logMessage;
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage;

@end

