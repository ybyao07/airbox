#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIColor.h>   // iOS
#elif !defined (COCOAPODS_POD_AVAILABLE_CocoaLumberjack_CLI)
#import <AppKit/NSColor.h>  // OS X with AppKit
#else
#import "CLIColor.h"        // OS X without AppKit
#endif

#import "DDLog.h"

#define LOG_CONTEXT_ALL INT_MAX

@interface DDTTYLogger : DDAbstractLogger <DDLogger>
{
    NSCalendar *calendar;
    NSUInteger calendarUnitFlags;
    
    NSString *appName;
    char *app;
    size_t appLen;
    
    NSString *processID;
    char *pid;
    size_t pidLen;
    
    BOOL colorsEnabled;
    NSMutableArray *colorProfilesArray;
    NSMutableDictionary *colorProfilesDict;
}

+ (instancetype)sharedInstance;

@property (readwrite, assign) BOOL colorsEnabled;

/**
 * The default color set (foregroundColor, backgroundColor) is:
 * 
 * - LOG_FLAG_ERROR = (red, nil)
 * - LOG_FLAG_WARN  = (orange, nil)
 * 
 * You can customize the colors however you see fit.
 * Please note that you are passing a flag, NOT a level.
 * 
 * GOOD : [ttyLogger setForegroundColor:pink backgroundColor:nil forFlag:LOG_FLAG_INFO];  // <- Good :)
 *  BAD : [ttyLogger setForegroundColor:pink backgroundColor:nil forFlag:LOG_LEVEL_INFO]; // <- BAD! :(
 * 
 * LOG_FLAG_INFO  = 0...00100
 * LOG_LEVEL_INFO = 0...00111 <- Would match LOG_FLAG_INFO and LOG_FLAG_WARN and LOG_FLAG_ERROR
 * 
 * If you run the application within Xcode, then the XcodeColors plugin is required.
 * 
 * If you run the application from a shell, then DDTTYLogger will automatically map the given color to
 * the closest available color. (xterm-256color or xterm-color which have 256 and 16 supported colors respectively.)
 * 
 * This method invokes setForegroundColor:backgroundColor:forFlag:context: and applies it to `LOG_CONTEXT_ALL`.
**/
#if TARGET_OS_IPHONE
- (void)setForegroundColor:(UIColor *)txtColor backgroundColor:(UIColor *)bgColor forFlag:(int)mask;
#elif !defined (COCOAPODS_POD_AVAILABLE_CocoaLumberjack_CLI)
- (void)setForegroundColor:(NSColor *)txtColor backgroundColor:(NSColor *)bgColor forFlag:(int)mask;
#else
- (void)setForegroundColor:(CLIColor *)txtColor backgroundColor:(CLIColor *)bgColor forFlag:(int)mask;
#endif

/**
 * Just like setForegroundColor:backgroundColor:flag, but allows you to specify a particular logging context.
 * 
 * A logging context is often used to identify log messages coming from a 3rd party framework,
 * although logging context's can be used for many different functions.
 * 
 * Use LOG_CONTEXT_ALL to set the deafult color for all contexts that have no specific color set defined.
 * 
 * Logging context's are explained in further detail here:
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/CustomContext
**/
#if TARGET_OS_IPHONE
- (void)setForegroundColor:(UIColor *)txtColor backgroundColor:(UIColor *)bgColor forFlag:(int)mask context:(int)ctxt;
#elif !defined (COCOAPODS_POD_AVAILABLE_CocoaLumberjack_CLI)
- (void)setForegroundColor:(NSColor *)txtColor backgroundColor:(NSColor *)bgColor forFlag:(int)mask context:(int)ctxt;
#else
- (void)setForegroundColor:(CLIColor *)txtColor backgroundColor:(CLIColor *)bgColor forFlag:(int)mask context:(int)ctxt;
#endif

/**
 * Similar to the methods above, but allows you to map DDLogMessage->tag to a particular color profile.
 * For example, you could do something like this:
 * 
 * static NSString *const PurpleTag = @"PurpleTag";
 * 
 * #define DDLogPurple(frmt, ...) LOG_OBJC_TAG_MACRO(NO, 0, 0, 0, PurpleTag, frmt, ##__VA_ARGS__)
 * 
 * And then in your applicationDidFinishLaunching, or wherever you configure Lumberjack:
 * 
 * #if TARGET_OS_IPHONE
 *   UIColor *purple = [UIColor colorWithRed:(64/255.0) green:(0/255.0) blue:(128/255.0) alpha:1.0];
 * #else
 *   NSColor *purple = [NSColor colorWithCalibratedRed:(64/255.0) green:(0/255.0) blue:(128/255.0) alpha:1.0];
 *
 * Note: For CLI OS X projects that don't link with AppKit use CLIColor objects instead
 * 
 * [[DDTTYLogger sharedInstance] setForegroundColor:purple backgroundColor:nil forTag:PurpleTag];
 * [DDLog addLogger:[DDTTYLogger sharedInstance]];
 * 
 * This would essentially give you a straight NSLog replacement that prints in purple:
 * 
 * DDLogPurple(@"I'm a purple log message!");
**/
#if TARGET_OS_IPHONE
- (void)setForegroundColor:(UIColor *)txtColor backgroundColor:(UIColor *)bgColor forTag:(id <NSCopying>)tag;
#elif !defined (COCOAPODS_POD_AVAILABLE_CocoaLumberjack_CLI)
- (void)setForegroundColor:(NSColor *)txtColor backgroundColor:(NSColor *)bgColor forTag:(id <NSCopying>)tag;
#else
- (void)setForegroundColor:(CLIColor *)txtColor backgroundColor:(CLIColor *)bgColor forTag:(id <NSCopying>)tag;
#endif

/**
 * Clearing color profiles.
**/
- (void)clearColorsForFlag:(int)mask;
- (void)clearColorsForFlag:(int)mask context:(int)context;
- (void)clearColorsForTag:(id <NSCopying>)tag;
- (void)clearColorsForAllFlags;
- (void)clearColorsForAllTags;
- (void)clearAllColors;

@end
