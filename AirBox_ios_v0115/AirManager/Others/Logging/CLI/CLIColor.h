//
//  CLIColor.h
//

#import <Foundation/Foundation.h>

/**
 Simple NSColor replacement for CLI projects that don't link with AppKit
 */
@interface CLIColor : NSObject

+ (CLIColor *)colorWithCalibratedRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (void)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

@end
