//
//  AlertBox.h
//  AirManager
//

#import <Foundation/Foundation.h>

@protocol AlertBoxDelegate <NSObject>

@optional

/**
 *  normal alert "ok" button click delegate
 **/
- (void)alertBoxOkButtonOnClicked;

- (void)alertBoxOkButtonOnClicked:(id)alertBoxViewController;

/**
 *  retry alert "retry" button click delegate
 **/
- (void)retryBoxOkButtonOnClicked;

/**
 *  retry alert "cancel" button click delegate
 **/
- (void)retryBoxCancelButtonOnClicked;

/**
 *  check succeed alert "succeed" button click delegate
 **/
- (void)succeedBoxOkButtonOnClicked;

/**
 *  check succeed alert "failed" button click delegate
 **/
- (void)succeedBoxCancelButtonOnClicked;

/**
 *  update version now
 **/
- (void)updateVersionButtonOnClicked;

/**
 *  not update version
 **/
- (void)notUpdateVersionButtonOnClicked;

@end

@interface AlertBox : NSObject

// This method will show an alert box when it needs only a OK button, without a Cancel button
+ (void)showWithMessage:(NSString *)message;

// This method will show an alert box when it needs a OK button and a Cancel button
// Set delegate to nil if it does not need any callback action in OK button calling
+ (void)showWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show;

+ (void)showWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show withTag:(NSInteger)tag;

//ybyao07
+ (void)showHintWithMessage:(NSString *)message;
+ (void)showHintWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate showCancel:(BOOL)show;

+ (void)showIsRetryBoxWithDelegate:(id <AlertBoxDelegate>)delegate;

+ (void)showIsSucceedWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate;

+ (void)showIsUpdateWithMessage:(NSString *)message delegate:(id <AlertBoxDelegate>)delegate;

@end
